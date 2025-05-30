from .Modules.RiskCalculatorInterfaceModule import RiskCalculatorInterface
from .Modules.ExecutionHandlerInterfaceModule import ExecutionHandlerInterface
from .Modules.DBHandlerInterfaceModule import DBHandlerInterface

include "console.iol"

service riskcalculator {
    execution: concurrent

    inputPort RiskCalculatorPort {
        location: "socket://localhost:8007"
        protocol: http { format = "json" }
        interfaces: RiskCalculatorInterface
    }
    outputPort DBHandlerPort {
        location: "socket://localhost:8001"
        protocol: http { format = "json" }
        interfaces: DBHandlerInterface
    }
    outputPort ExecutionhandlerPort {
        location: "socket://localhost:8004"
        protocol: http { format = "json" }
        interfaces: ExecutionHandlerInterface
    }

    init {
        println@Console("Risk Calculator Running")()
    }

    main {
        [checkOrder(request)(response) {
            clientRequest.ClientId = request.ClientId
            getClientFromId@DBHandlerPort(clientRequest)(clientResponse)

            if(request.Side == "Right") {
                price = (request.Price + request.SpreadPrice) * request.Size
                if(clientResponse.Client.Balance >= price) {
                    //Figuring out if we should hedge
                    getDanskeBankHoldings@DBHandlerPort()(holdingsResponse)
                    bankInventory = 0
                    for(item in holdingsResponse.Holdings) {
                        if(item.InstrumentId == request.InstrumentId) {
                            bankInventory = item.Size
                        }
                    }
                    targetRequest.InstrumentId = request.InstrumentId
                    getInstrumentTarget@DBHandlerPort(targetRequest)(targetResponse)

                    executionRequest.HedgeOrder = bankInventory <= targetResponse.Target || bankInventory < request.Size
                    
                    executionRequest.ClientId = request.ClientId
                    executionRequest.Side = request.Side
                    executionRequest.InstrumentId = request.InstrumentId
                    executionRequest.Size = request.Size
                    executionRequest.Price = request.Price
                    executionRequest.SpreadPrice = request.SpreadPrice

                    handleOrder@ExecutionhandlerPort(executionRequest)(executionResponse)

                    response.Status = executionResponse.Status
                    response.ErrorMessage = executionResponse.ErrorMessage
                }else {
                    response.Status = "Rejected"
                    response.ErrorMessage = "Insufficient Funds"
                }
            }else {
                getClientHoldings@DBHandlerPort(clientRequest)(clientHoldingsResponse)
                clientInventory = 0
                for(item in clientHoldingsResponse.Holdings) {
                    if(item.InstrumentId == request.InstrumentId) {
                        clientInventory = item.Size
                    }
                }
                if(clientInventory > request.Size) {
                    //Figuring out if we should hedge
                    getDanskeBankHoldings@DBHandlerPort()(holdingsResponse)
                    bankInventory = 0
                    for(item in holdingsResponse.Holdings) {
                        if(item.InstrumentId == request.InstrumentId) {
                            bankInventory = item.Size
                        }
                    }
                    targetRequest.InstrumentId = request.InstrumentId
                    getInstrumentTarget@DBHandlerPort(targetRequest)(targetResponse)

                    executionRequest.HedgeOrder = bankInventory + request.Size > targetResponse.Target
                    executionRequest.ClientId = request.ClientId
                    executionRequest.Side = request.Side
                    executionRequest.InstrumentId = request.InstrumentId
                    executionRequest.Size = request.Size
                    executionRequest.Price = request.Price
                    executionRequest.SpreadPrice = request.SpreadPrice

                    handleOrder@ExecutionhandlerPort(executionRequest)(executionResponse)

                    response.Status = executionResponse.Status
                    response.ErrorMessage = executionResponse.ErrorMessage
                }else {
                    response.Status = "Rejected"
                    response.ErrorMessage = "Client does not own enough of " + request.InstrumentId + " to sell specified quantity"
                }
            }
        }]

        [ shutdown()() ]{
            exit
        }
    }
}
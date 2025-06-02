from .Modules.ExecutionHandlerInterfaceModule import ExecutionHandlerInterface
from .Modules.BookInterfaceModule import BookInterface
from .Modules.HedgeServiceInterfaceModule import HedgeServiceInterface
from .Modules.PricerEngineInterfaceModule import PricerEngineInterface

include "math.iol"
include "console.iol"

service executionhandler {
    execution: concurrent

    inputPort ExecutionhandlerPort {
        location: "socket://localhost:8004"
        protocol: http { format = "json" }
        interfaces: ExecutionHandlerInterface
    }
    outputPort BookPort {
        location: "socket://localhost:8002"
        protocol: http { format = "json" }
        interfaces: BookInterface
    }
    outputPort HedgePort {
        location: "socket://localhost:8003"
        protocol: http { format = "json" }
        interfaces: HedgeServiceInterface
    }
    outputPort PricerEnginePort {
        location: "socket://localhost:8006"
        protocol: http { format = "json" }
        interfaces: PricerEngineInterface
    }

    init {
        println@Console("Execution Handler Running")()
    }

    main {
        [ handleOrder(request)(response) {
            priceRequest.InstrumentId = request.InstrumentId
            publishPrice@PricerEnginePort(priceRequest)(priceResponse)
            
            if(priceResponse.Price <= 0) {
                response.Status = "Canceled"
                response.ErrorMessage = "Ordered instrument not found"
            }else {
                roundRequest = request.Price
                roundRequest.decimals = 2
                round@Math(roundRequest)(roundResponse)
                if(roundResponse == priceResponse.Price) {
                    transaction.Succeeded = true
                    transaction.InstrumentId = request.InstrumentId
                    transaction.Size = request.Size
                    transaction.Price = request.Price
                    transaction.SpreadPrice = request.SpreadPrice
                    if(request.Side == "Right") {
                        transaction.BuyerId = request.ClientId
                        transaction.SellerId = ""
                    }else {
                        transaction.SellerId = request.ClientId
                        transaction.BuyerId = ""
                    }
                    
                    if(request.HedgeOrder) {
                        hedgeRequest.InstrumentId = request.InstrumentId
                        handleHedgeRequest@HedgePort(hedgeRequest)(hedgeResponse)
                        if(!hedgeResponse.HedgeAccepted) {
                            response.Status = "Canceled"
                            response.ErrorMessage = "Ordered could not be hedged"
                        }else {
                            transaction.Broker = hedgeResponse.Broker
                            hedgeOrder@BookPort(transaction)(res)
                            response.Status = "Success"
                            response.ErrorMessage = ""
                        }
                    }else {
                        bookOrder@BookPort(transaction)(res)
                        response.Status = "Success"
                        response.ErrorMessage = ""
                    }
                }else {
                    response.Status = "Canceled"
                    response.ErrorMessage = "Order cancelled due to price change of instrument"
                }
            }
        }]
        
        [ shutdown()() ]{
            exit
        }
    }
}
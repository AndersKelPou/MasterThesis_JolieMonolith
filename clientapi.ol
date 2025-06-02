from .Modules.ClientAPIInterfaceModule import ClientAPIInterface
from .Modules.DBHandlerInterfaceModule import DBHandlerInterface
from .Modules.RiskCalculatorInterfaceModule import RiskCalculatorInterface
from .Modules.PricerEngineInterfaceModule import PricerEngineInterface
from .Modules.ClientInstanceInterfaceModule import ClientInstanceInterface

include "console.iol"
include "file.iol"

service clientapi {
    execution: concurrent

    inputPort clientAPIPort {
        location: "socket://localhost:8000"
        protocol: http { format = "json" }
        interfaces: ClientAPIInterface
    }
    outputPort DBHandlerPort {
        location: "socket://localhost:8001"
        protocol: http { format = "json" }
        interfaces: DBHandlerInterface
    }
    outputPort pricerEnginePort {
        location: "socket://localhost:8006"
        protocol: http { format = "json" }
        interfaces: PricerEngineInterface
    }
    outputPort riskCalculatorPort {
        location: "socket://localhost:8007"
        protocol: http { format = "json" }
        interfaces: RiskCalculatorInterface
    }
    outputPort clientInstancePort {
        location: "socket://localhost:8011"
        protocol: http { format = "json" }
        interfaces: ClientInstanceInterface
    }

    init {
        file.filename = "./Modules/appsettings/clientapisettings.json";
        file.format = "json";
        readFile@File( file )( config )
        println@Console("ClientAPI Running")()
    }

    main {

        [ handleOrder(request)(response) {
            tierRequest.ClientId = request.ClientId
            getClientTier@DBHandlerPort(tierRequest)(tierResponse)
            spreadPercent = 0
            for( item in config.SpreadPercentages) {
                if(item.Name == tierResponse.ClientTier) {
                    spreadPercent = item.Spread
                }
            }

            orderRequest.ClientId = request.ClientId
            orderRequest.InstrumentId = request.InstrumentId
            orderRequest.Size = request.Size
            orderRequest.Side = request.Side

            if(request.Side == "Right") {
                orderRequest.Price = request.Price * (1.0 / (1.0 + spreadPercent))
                orderRequest.SpreadPrice = request.Price - (request.Price * (1.0 / (1.0 + spreadPercent)))
            }else {
                orderRequest.Price = request.Price * (1.0 / (1.0 - spreadPercent))
                orderRequest.SpreadPrice = (request.Price * (1.0 / (1.0 - spreadPercent))) - request.Price
            }
            checkOrder@riskCalculatorPort(orderRequest)(orderResponse)
            if(orderResponse.Status == "Success") {
                clientRequest.ClientId = request.ClientId
                getClientHoldings@DBHandlerPort(clientRequest)(clientHoldingsResponse)
                getClientFromId@DBHandlerPort(clientRequest)(clientDataResponse)
                for( i=0, i<#clientHoldingsResponse.Holdings, i++) {
                    response.Holdings[i].ClientId = clientHoldingsResponse.Holdings[i].ClientId
                    response.Holdings[i].InstrumentId = clientHoldingsResponse.Holdings[i].InstrumentId
                    response.Holdings[i].Size = clientHoldingsResponse.Holdings[i].Size
                }
                response.Client.ClientId = clientDataResponse.Client.ClientId
                response.Client.Name = clientDataResponse.Client.Name
                response.Client.Tier = clientDataResponse.Client.Tier
                response.Client.Balance = clientDataResponse.Client.Balance
            }else {
                response.Holdings = void
            }
            response.Status = orderResponse.Status
            response.ErrorMessage = orderResponse.ErrorMessage
        }]
        
        [ checkLogin(request)(response) {
            checkLogin@DBHandlerPort(request)(res)
            response -> res
        }]

        [ getStockOptions(request)(response){
            publishInitialPrice@pricerEnginePort()(res)
            getClientTier@DBHandlerPort(request)(tierResponse)
            for( i=0, i<#res.Stocks, i++ ) {
                response.Stocks[i].InstrumentId = res.Stocks[i].InstrumentId
                for( item in config.SpreadPercentages) {
                    if(item.Name == tierResponse.ClientTier) {
                        response.Stocks[i].AskPrice = res.Stocks[i].Price + (res.Stocks[i].Price * item.Spread)
                        response.Stocks[i].BidPrice = res.Stocks[i].Price - (res.Stocks[i].Price * item.Spread)
                    }
                }
            }
        }]

        [ handlePriceUpdate(request)] {
            install (IOException => println@Console("No one is listening")());
            clientRequest.InstrumentId = request.InstrumentId
            for( i=0, i<#config.SpreadPercentages, i++ ) {
                clientRequest.TieredPrice[i].ClientTier = config.SpreadPercentages[i].Name
                clientRequest.TieredPrice[i].AskPrice = request.Price + (request.Price * config.SpreadPercentages[i].Spread)
                clientRequest.TieredPrice[i].BidPrice = request.Price - (request.Price * config.SpreadPercentages[i].Spread)
            }
            handlePriceUpdate@clientInstancePort(clientRequest)
        }
        
        [ shutdown()() ]{
            exit
        }
    }
}
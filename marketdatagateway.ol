from .Modules.MarketDataGatewayInterfaceModule import MarketDataGatewayInterface
from .Modules.PricerEngineInterfaceModule import PricerEngineInterface
from .Modules.MarketSimInterface import MarketSimulationInterface

include "console.iol"

service hedgeservice {
    execution: concurrent

    inputPort marketDataGatewayPort {
        location: "socket://localhost:8005"
        protocol: http { format = "json" }
        interfaces: MarketDataGatewayInterface
    }
    outputPort pricerEnginePort {
        location: "socket://localhost:8006"
        protocol: http { format = "json" }
        interfaces: PricerEngineInterface
    }
    outputPort MarketSimulationPort {
        location: "socket://localhost:8008"
        protocol: http { format = "json" }
        interfaces: MarketSimulationInterface
    }

    init {
        println@Console("MarketDataGateway Running")()
    }


    main {
        [ publishInitialPrice(request)(response){
            getInitialPrices@MarketSimulationPort(request)(res)
            for( i=0, i<#res.Stocks, i++) {
                response.Stocks[i].InstrumentId = res.Stocks[i].InstrumentId
                response.Stocks[i].Price = res.Stocks[i].Price
            }
        }]

        
        [ shutdown()() ]{
            exit
        }
    }
}
from .Modules.PricerEngineInterfaceModule import PricerEngineInterface
from .Modules.ClientAPIInterfaceModule import ClientAPIInterface
from .Modules.MarketDataGatewayInterfaceModule import MarketDataGatewayInterface

include "console.iol"
include "file.iol"

service pricerengine {
    execution: concurrent

    inputPort pricerEnginePort {
        location: "socket://localhost:8006"
        protocol: http { format = "json" }
        interfaces: PricerEngineInterface
    }
    outputPort clientAPIPort {
        location: "socket://localhost:8000"
        protocol: http { format = "json" }
        interfaces: ClientAPIInterface
    }
    outputPort MarketDataGatewayPort {
        location: "socket://localhost:8005"
        protocol: http { format = "json" }
        interfaces: MarketDataGatewayInterface
    }

    init {
        file.filename = "./Modules/appsettings/pricerenginesettings.json";
        file.format = "json";
        readFile@File( file )( config )
        println@Console("Pricer Engine Running")()
    }

    main {
        [ updatePrice(request)] {
            for( i=0, i<#global.Prices, i++) {
                if(request.InstrumentId == global.Prices[i].InstrumentId) {
                    global.Prices[i].Price = request.Price
                    handlePriceUpdate@clientAPIPort(request)
                }
            }
        }

        [ publishInitialPrice()(response) {
            publishInitialPrice@MarketDataGatewayPort(config.TradingOptions) ( res );
            for( i=0, i<#res.Stocks, i++) {
                global.Prices[i].InstrumentId = res.Stocks[i].InstrumentId
                global.Prices[i].Price = res.Stocks[i].Price
            }
            response -> res
        }]

        [ publishPrice(request)(response) {
            if (#global.Prices < 1) {
                scope (MarketDataScope) {
                    install (IOException => println@Console("Could not connect to market data gateway")());
                    publishInitialPrice@MarketDataGatewayPort(config.TradingOptions) ( res );
                    for( i=0, i<#res.Stocks, i++) {
                        global.Prices[i].InstrumentId = res.Stocks[i].InstrumentId
                        global.Prices[i].Price = res.Stocks[i].Price
                    }
                }
            }
            response.Price = 0
            for(item in global.Prices) {
                if(item.InstrumentId == request.InstrumentId) {
                    response.Price = item.Price
                }
            }
        }]

        [ shutdown()() ]{
            exit
        }
    }
}
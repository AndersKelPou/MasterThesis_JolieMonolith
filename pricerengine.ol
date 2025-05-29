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
            for(item in config.TradingOptions.InstrumentIds) {
                if(request.InstrumentId == item) {
                    handlePriceUpdate@clientAPIPort(request)
                }
            }
        }

        [ publishInitialPrice()(response) {
            publishInitialPrice@MarketDataGatewayPort(config.TradingOptions) ( res );
            response -> res
        }]

        [ shutdown()() ]{
            exit
        }
    }
}
from .Modules.ClientAPIInterfaceModule import ClientAPIInterface
from .Modules.DBHandlerInterfaceModule import DBHandlerInterface
from .Modules.RiskCalculatorInterfaceModule import RiskCalculatorInterface
from .Modules.PricerEngineInterfaceModule import PricerEngineInterface

include "console.iol"

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

    init {
        println@Console("ClientAPI Running")()
    }

    main {
        
        [ checkLogin(request)(response) {
            checkLogin@DBHandlerPort(request)(res)
            response -> res
        }]

        [ getStockOptions()(response){
            publishInitialPrice@pricerEnginePort()(res)
            response -> res
        }]
        
        [ shutdown()() ]{
            exit
        }
    }
}
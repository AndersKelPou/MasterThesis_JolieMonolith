from .Modules.RiskCalculatorInterfaceModule import RiskCalculatorInterface
from .Modules.ExecutionHandlerInterfaceModule import ExecutionHandlerInterface
from .Modules.DBHandlerInterfaceModule import DBHandlerInterface

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

    main {

        [checkOrder(request)(response) {
            
        }]

        [ shutdown()() ]{
            exit
        }
    }
}
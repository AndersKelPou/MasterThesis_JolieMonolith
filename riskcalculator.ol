from .Modules.RiskCalculatorInterfaceModule import RiskCalculatorInterface
from .Modules.ExecutionHandlerInterfaceModule import ExecutionHandlerInterface

service riskcalculator {
    execution: concurrent

    inputPort riskCalculatorPort {
        location: "socket://localhost:8007"
        protocol: http { format = "json" }
        interfaces: RiskCalculatorInterface
    }
    outputPort executionhandlerPort {
        location: "socket://localhost:8004"
        protocol: http { format = "json" }
        interfaces: ExecutionHandlerInterface
    }

    main {


        
        [ shutdown()() ]{
            exit
        }
    }
}
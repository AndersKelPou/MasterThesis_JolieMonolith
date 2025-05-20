from .Modules.ExecutionHandlerInterfaceModule import ExecutionHandlerInterface
from .Modules.BookInterfaceModule import BookInterface
from .Modules.HedgeServiceInterfaceModule import HedgeServiceInterface

service executionhandler {
    execution: concurrent

    inputPort executionhandlerPort {
        location: "socket://localhost:8004"
        protocol: http { format = "json" }
        interfaces: ExecutionHandlerInterface
    }
    outputPort bookPort {
        location: "socket://localhost:8002"
        protocol: http { format = "json" }
        interfaces: BookInterface
    }
    outputPort hedgePort {
        location: "socket://localhost:8003"
        protocol: http { format = "json" }
        interfaces: HedgeServiceInterface
    }

    main {
        
        
        [ shutdown()() ]{
            exit
        }
    }
}
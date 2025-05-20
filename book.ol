from .Modules.BookInterfaceModule import BookInterface
from .Modules.DBHandlerInterfaceModule import DBHandlerInterface

service book {
    execution: concurrent

    inputPort bookPort {
        location: "socket://localhost:8002"
        protocol: http { format = "json" }
        interfaces: BookInterface
    }
    outputPort DBHandlerPort {
        location: "socket://localhost:8001"
        protocol: http { format = "json" }
        interfaces: DBHandlerInterface
    }

    main {
        
        
        [ shutdown()() ]{
            exit
        }
    }
}
from .Modules.HedgeServiceInterfaceModule import HedgeServiceInterface

service hedgeservice {
    execution: concurrent

    inputPort hedgePort {
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
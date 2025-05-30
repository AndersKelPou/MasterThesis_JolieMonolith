from .Types import *

type handleOrderRequest: void {
    ClientId: string
    InstrumentId: string
    Size: int
    Side: string(enum(["Right", "Left"]))
    Price: double
    SpreadPrice: double
    HedgeOrder: bool
}

type handleOrderResponse: void {
    Status: string
    ErrorMessage: string
}

interface ExecutionHandlerInterface {
    RequestResponse:
        handleOrder(handleOrderRequest)(undefined),
        shutdown( void )( void )
}
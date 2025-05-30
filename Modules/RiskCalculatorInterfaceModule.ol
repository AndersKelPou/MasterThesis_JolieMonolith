from .Types import *

type checkOrderRequest: void {
    ClientId: string
    InstrumentId: string
    Size: int
    Side: string(enum(["Right", "Left"]))
    Price: double
    SpreadPrice: double
}

type checkOrderResponse: void {
    Status: string
    ErrorMessage: string
}

interface RiskCalculatorInterface {
    RequestResponse:
        checkOrder(checkOrderRequest)(checkOrderResponse),
        shutdown( void )( void )
}
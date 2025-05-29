from .Types import *

type checkOrderRequest: void {
    ClientId: string
    InstrumentId: string
    Size: int
    Side: string(enum(["Right", "Left"]))
    Price: double
    SpreadPrice: double
}

interface RiskCalculatorInterface {
    RequestResponse:
        checkOrder(checkOrderRequest)(undefined),
        shutdown( void )( void )
}
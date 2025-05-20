from .Types import *

interface RiskCalculatorInterface {
    RequestResponse:
        checkOrder(undefined)(undefined),
        shouldWeHedge(undefined)(undefined),
        shutdown( void )( void )
}
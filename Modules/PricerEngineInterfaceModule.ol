from .Types import *

type partialInitialPriceResponse: void {
    InstrumentId: string
    Price: double
}
type initialPriceResponse: void {
    Stocks*: partialInitialPriceResponse
}

interface PricerEngineInterface {
    RequestResponse:
        updatePrice(undefined)(undefined),
        publishInitialPrice(void)(initialPriceResponse),
        shutdown( void )( void )   
}
from .Types import *

type initialPriceRequest: void {
    InstrumentIds*: string
}
type partialInitialPriceResponse: void {
    InstrumentId: string
    Price: double
}
type initialPriceResponse: void {
    Stocks*: partialInitialPriceResponse
}

interface MarketDataGatewayInterface {
    RequestResponse:
        publishInitialPrice( initialPriceRequest )( initialPriceResponse ),
        handleMarketPriceUpdate(undefined)(undefined),
        shutdown( void )( void )
}
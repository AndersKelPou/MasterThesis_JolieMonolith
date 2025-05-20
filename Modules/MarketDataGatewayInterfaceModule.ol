from .Types import *

type Stock: void {
    InstrumentId: string
    Price: double
}

type initialPriceRequest: void {
    InstrumentIds*: string
}

type initialPriceResponse: void {
    Stocks*: Stock
}

interface MarketDataGatewayInterface {
    RequestResponse:
        publishInitialPrice( initialPriceRequest )( initialPriceResponse ),
        marketPriceUpdated( Stock )(undefined),
        shutdown( void )( void )
}
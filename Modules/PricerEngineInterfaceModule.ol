from .Types import *

type Stock: void {
    InstrumentId: string
    Price: double
}

type initialPriceResponse: void {
    Stocks*: Stock
}

interface PricerEngineInterface {
    RequestResponse:
        updatePrice(Stock)(void),
        publishInitialPrice(void)(initialPriceResponse),
        shutdown( void )( void )   
}
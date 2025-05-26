from .Types import *

type Stock: void {
    InstrumentId: string
    Price: double
}

type initialPriceResponse: void {
    Stocks*: Stock
}

interface PricerEngineInterface {
    OneWay:
        updatePrice(Stock)
    RequestResponse:
        publishInitialPrice(void)(initialPriceResponse),
        shutdown( void )( void )   
}
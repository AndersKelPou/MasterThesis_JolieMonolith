from .Types import *

type Stock: void {
    InstrumentId: string
    Price: double
}

type initialPriceResponse: void {
    Stocks*: Stock
}

type priceRequest: void {
    InstrumentId: string
}

type priceResponse: void {
    Price: double
}

interface PricerEngineInterface {
    OneWay:
        updatePrice(Stock)
    RequestResponse:
        publishInitialPrice(void)(initialPriceResponse),
        publishPrice( priceRequest )( priceResponse ),
        shutdown( void )( void )   
}
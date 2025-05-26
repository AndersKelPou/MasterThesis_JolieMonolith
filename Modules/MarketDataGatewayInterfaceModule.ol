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
    OneWay:
        marketPriceUpdated( Stock )
    RequestResponse:
        publishInitialPrice( initialPriceRequest )( initialPriceResponse ),
        shutdown( void )( void )
}
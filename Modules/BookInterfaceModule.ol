from .Types import *

type bookOrderRequest: void {
    BuyerId: string
    SellerId: string
    Succeeded: bool
    InstrumentId: string
    Size: int
    Price: double
    SpreadPrice: double
}

type hedgeOrderRequest: void {
    BuyerId: string
    SellerId: string
    Succeeded: bool
    InstrumentId: string
    Size: int
    Price: double
    SpreadPrice: double
    Broker: string
}

interface BookInterface {
    OneWay:
        bookOrder(bookOrderRequest),
        hedgeOrder(hedgeOrderRequest)
    RequestResponse:
        shutdown( void )( void )
}
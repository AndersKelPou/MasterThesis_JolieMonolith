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

type orderResponse: void {
    Message: string
}

interface BookInterface {
    RequestResponse:
        hedgeOrder(hedgeOrderRequest)(orderResponse),
        bookOrder(bookOrderRequest)(orderResponse),
        shutdown( void )( void )
}
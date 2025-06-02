from .Types import *

type handleOrderRequest: void {
    ClientId: string
    InstrumentId: string
    Price: double
    Size: int
    Side: string(enum(["Right", "Left"]))
}

type handleOrderResponse: void {
    Status: string
    ErrorMessage: string
    Holdings[0,*]: HoldingData
}

type loginRequest: void {
    username: string
    password: string
}

type loginResponse: void {
    Authenticated: bool
    Client[0,1]: ClientData
    Holdings*: HoldingData
}

type Stock: void {
    InstrumentId: string
    Price: double
}

type TieredStock: void {
    InstrumentId: string
    BidPrice: double
    AskPrice: double
}

type stockOptions: void {
    Stocks*: TieredStock
}

type stockOptionRequest: void {
    ClientId: string
}

type handleOrderResponse: void {
    Status: string
    ErrorMessage: string
    Client[0,1]: ClientData
    Holdings[0,*]: HoldingData
}

interface ClientAPIInterface {
    OneWay:
        handlePriceUpdate( Stock )
    RequestResponse:
        handleOrder(handleOrderRequest)(handleOrderResponse),
        checkLogin(loginRequest)(loginResponse),
        getStockOptions(stockOptionRequest)(stockOptions),
        shutdown( void )( void )
}
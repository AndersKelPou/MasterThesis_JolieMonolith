from .Types import *

type loginRequest: void {
    username: string
    password: string
}

type loginResponse: void {
    Authenticated: bool
    Client[0,1]: ClientData
    Holdings*: HoldingData
}

type partialStockOptions: void {
    InstrumentId: string
    Price: double
}
type stockOptions: void {
    Stocks*: partialStockOptions
}

interface ClientAPIInterface {
    RequestResponse:
        handleOrder(undefined)(undefined),
        checkLogin(loginRequest)(loginResponse),
        getStockOptions( void )(stockOptions),
        shutdown( void )( void )
}
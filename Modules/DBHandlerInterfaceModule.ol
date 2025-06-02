from .Types import *

type AddClientRequest: void {
    name: string
    tier: Tier
}

type AddClientCustomerRequest: void {
    name: string
    username: string
    password: string
    tier: Tier
}

type getClientIdRequest: void {
    Name: string
}

type loginRequest: void {
    username: string
    password: string
}

type loginResponse: void {
    Authenticated: bool
    Client[0,1]: ClientData
    Holdings[0,*]: HoldingData
}

type clientRequest: void {
    ClientId: string
}

type clientResponse: void {
    Client: ClientData
}

type clientIdResponse: void {
    ClientId: string
}

type clientTierResponse: void {
    ClientTier: Tier
}

type holdingsResponse: void {
    Holdings[0,*]: HoldingData
}

type InstrumentTargetRequest: void {
    InstrumentId: string
}

type InstrumentTargetResponse: void {
    Target: int
}

type addTransactionRequest: void {
    TransactionId: string
    BuyerId: string
    SellerId: string
    Succeeded: bool
    InstrumentId: string
    Size: int
    Price: double
    SpreadPrice: double
}

type TransactionResponse: void {
    Message: string
}

interface DBHandlerInterface {
    RequestResponse:
        addClient( AddClientRequest )( void ),
        addClientCustomer( AddClientCustomerRequest )( void ),
        getClientId( getClientIdRequest )( clientIdResponse ),
        getClientFromId( clientRequest )( clientResponse ),
        getAllClients( void )( undefined ),
        getClientTier( clientRequest )( clientTierResponse ),
        checkLogin( loginRequest )( loginResponse ),
        getClientHoldings( clientRequest )( holdingsResponse ),
        getDanskeBankHoldings( void )( holdingsResponse ),
        getDanskeBankId( void )( clientIdResponse ),
        getInstrumentTarget( InstrumentTargetRequest )( InstrumentTargetResponse ),
        addTransaction(addTransactionRequest)(TransactionResponse),
        shutdown( void )( void )
}
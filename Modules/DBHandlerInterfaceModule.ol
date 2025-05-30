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
    name: string
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

interface DBHandlerInterface {
    RequestResponse:
        addClient( AddClientRequest )( void ),
        addClientCustomer( AddClientCustomerRequest )( void ),
        getClientId( getClientIdRequest )( undefined ),
        getClientFromId( clientRequest )( clientResponse )
        getAllClients( void )( undefined ),
        getClientTier( clientRequest )( clientTierResponse ),
        checkLogin( loginRequest )( loginResponse ),
        getClientHoldings( clientRequest )( holdingsResponse ),
        getDanskeBankHoldings( void )( holdingsResponse ),
        getInstrumentTarget( InstrumentTargetRequest )( InstrumentTargetResponse ),
        shutdown( void )( void )
}
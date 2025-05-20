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

interface DBHandlerInterface {
    RequestResponse:
        addClient( AddClientRequest )( void ),
        addClientCustomer( AddClientCustomerRequest )( void ),
        getClientId( getClientIdRequest )( undefined ),
        getAllClients( void )( undefined ),
        checkLogin( loginRequest )( loginResponse ),
        shutdown( void )( void )
}
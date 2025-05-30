from .Types import *

type hedgeRequest: void {
    InstrumentId: string
}

type hedgeResponse: void {
    HedgeAccepted: bool
    Broker: string
}

interface HedgeServiceInterface {
    RequestResponse:
        handleHedgeRequest(hedgeRequest)(hedgeResponse),
        shutdown( void )( void )
}
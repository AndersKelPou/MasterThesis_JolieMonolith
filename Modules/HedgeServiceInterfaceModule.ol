from .Types import *


interface HedgeServiceInterface {
    RequestResponse:
        handleHedgeRequest()(),
        shutdown( void )( void )
}
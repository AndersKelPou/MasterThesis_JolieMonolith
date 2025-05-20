from .Types import *


interface ExecutionHandlerInterface {
    RequestResponse:
        handleOrder()(),
        shutdown( void )( void )
}
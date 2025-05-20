from .Types import *


interface BookInterface {
    RequestResponse:
        bookOrder()(),
        hedgeOrder()(),
        shutdown( void )( void )
}
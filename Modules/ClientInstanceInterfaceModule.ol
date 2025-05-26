type Stock: void {
    InstrumentId: string
    Price: double
}

interface ClientInstanceInterface {
    OneWay:
        handlePriceUpdate(Stock)
}
type initialPriceRequest: void {
    InstrumentIds*: string
}

interface MarketSimulationInterface {
    RequestResponse:
        getInitialPrices( initialPriceRequest ) ( undefined )
}
from .Types import *

type TieredStock: void {
    ClientTier: Tier
    BidPrice: double
    AskPrice: double
}

type PriceUpdateRequest: void {
    InstrumentId: string
    TieredPrice*: TieredStock
}

interface ClientInstanceInterface {
    OneWay:
        handlePriceUpdate(PriceUpdateRequest)
}
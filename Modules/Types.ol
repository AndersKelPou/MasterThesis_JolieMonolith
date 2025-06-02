type TargetPosition: void {
    instrumentId: string
    target: int
    targetType: string( enum(["FOK", "IOC", "GTC", "GFD"]))
}

type TransactionData: void {
    transactionId: string //UUID documentation: https://docs.jolie-lang.org/v1.12.x/language-tools-and-standard-library/standard-library-api/string_utils.html#getRandomUUID
    buyerId: string
    sellerId: string
    instrumentId: string
    size: int
    price: double
    spreadPrice: double
    succeeded: bool
}

type HoldingData: void {
    ClientId?: string
    InstrumentId?: string
    Size?: int
}

type Tier: string(enum(["External", "Internal", "Regular", "Premium", "ClientNotFound"]))

type ClientData: void {
    ClientId: string
    Name: string
    Balance: double
    Tier: Tier
}

type CustomerData: void {
    clientId: string
    username: string
    password: string
}

type SaltData: void {
    clientId: string
    salt: string
}
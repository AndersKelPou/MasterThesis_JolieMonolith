from .Modules.MarketDataGatewayInterfaceModule import MarketDataGatewayInterface
from .Modules.PricerEngineInterfaceModule import PricerEngineInterface
from .Modules.MarketSimInterface import MarketSimulationInterface
from .Modules.ExternalBrokerSims.NordeaInterfaceModule import NordeaInterface
from .Modules.ExternalBrokerSims.NASDAQInterfaceModule import NASDAQInterface
from .Modules.ExternalBrokerSims.JPMorganInterfaceModule import JPMorganInterface

include "console.iol"

service marketdatagateway {
    execution: concurrent

    inputPort marketDataGatewayPort {
        location: "socket://localhost:8005"
        protocol: http { format = "json" }
        interfaces: MarketDataGatewayInterface
    }
    outputPort pricerEnginePort {
        location: "socket://localhost:8006"
        protocol: http { format = "json" }
        interfaces: PricerEngineInterface
    }
    outputPort NordeaPort {
        location: "socket://localhost:8008"
        protocol: http { format = "json" }
        interfaces: NordeaInterface
    }
    outputPort NASDAQPort {
        location: "socket://localhost:8009"
        protocol: http { format = "json" }
        interfaces: NASDAQInterface
    }
    outputPort JPMorganPort {
        location: "socket://localhost:8010"
        protocol: http { format = "json" }
        interfaces: JPMorganInterface
    }

    init {
        println@Console("MarketDataGateway Running")()
    }

    main {
        [ publishInitialPrice(request)(response){
            count = 0

            getInitialPrices@NordeaPort()(res1)
            for( i=0, i<#res1.Stocks, i++) {
                for(item in request.InstrumentIds) {
                    if(res1.Stocks[i].InstrumentId == item) {
                        response.Stocks[count].InstrumentId = res1.Stocks[i].InstrumentId
                        response.Stocks[count].Price = res1.Stocks[i].Price
                        count++
                    }
                }
            }
            getInitialPrices@NASDAQPort()(res2)
            for( i=0, i<#res2.Stocks, i++) {
                for(item in request.InstrumentIds) {
                    if(res2.Stocks[i].InstrumentId == item) {
                        duplicate = false
                        for( j=0, j<#response.Stocks, j++) {
                            if(response.Stocks[j].InstrumentId == res2.Stocks[i].InstrumentId && response.Stocks[j].Price > res2.Stocks[i].Price) {
                                response.Stocks[j].Price = res2.Stocks[i].Price
                                duplicate = true
                            }
                        }
                        if(!duplicate) {
                            response.Stocks[count].InstrumentId = res2.Stocks[i].InstrumentId
                            response.Stocks[count].Price = res2.Stocks[i].Price
                            count++
                        }
                    }
                }
            }
            getInitialPrices@JPMorganPort()(res3)
            for( i=0, i<#res3.Stocks, i++) {
                for(item in request.InstrumentIds) {
                    if(res3.Stocks[i].InstrumentId == item) {
                        duplicate = false
                        for( j=0, j<#response.Stocks, j++) {
                            if(response.Stocks[j].InstrumentId == res3.Stocks[i].InstrumentId && response.Stocks[j].Price > res3.Stocks[i].Price) {
                                response.Stocks[j].Price = res3.Stocks[i].Price
                                duplicate = true
                            }
                        }
                        if(!duplicate) {
                            response.Stocks[count].InstrumentId = res3.Stocks[i].InstrumentId
                            response.Stocks[count].Price = res3.Stocks[i].Price
                            count++
                        }
                    }
                }
            }
        }]

        [ marketPriceUpdated(request)] {
            updatePrice@pricerEnginePort(request)
        }

        
        [ shutdown()() ]{
            exit
        }
    }
}
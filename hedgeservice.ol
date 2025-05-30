from .Modules.HedgeServiceInterfaceModule import HedgeServiceInterface
from .Modules.ExternalBrokerSims.NordeaInterfaceModule import NordeaInterface
from .Modules.ExternalBrokerSims.NASDAQInterfaceModule import NASDAQInterface
from .Modules.ExternalBrokerSims.JPMorganInterfaceModule import JPMorganInterface

include "console.iol"

service hedgeservice {
    execution: concurrent

    inputPort hedgePort {
        location: "socket://localhost:8003"
        protocol: http { format = "json" }
        interfaces: HedgeServiceInterface
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
        scope (BrokerStocksScope) {
            install (IOException => println@Console("Market Sim is not running")());
            count = 0
            getInitialPrices@NordeaPort()(res1)
            for(  i=0, i<#res1.Stocks, i++) {
                global.BrokerStocks[count].Broker = "Nordea"
                global.BrokerStocks[count].InstrumentId = res1.Stocks[i].InstrumentId
                count++
            }
            getInitialPrices@NASDAQPort()(res2)
            for(  i=0, i<#res2.Stocks, i++) {
                global.BrokerStocks[count].Broker = "NASDAQ"
                global.BrokerStocks[count].InstrumentId = res2.Stocks[i].InstrumentId
                count++
            }
            getInitialPrices@JPMorganPort()(res3)
            for(  i=0, i<#res3.Stocks, i++) {
                global.BrokerStocks[count].Broker = "JPMorgan"
                global.BrokerStocks[count].InstrumentId = res3.Stocks[i].InstrumentId
                count++
            }
        }

        println@Console("Hedge Service Running")()
    }

    main {
        [handleHedgeRequest(request)(response) {
            scope(MarketSimScope) {
                install (IOException => println@Console("Market Sim is not running")());
                if(#global.BrokerStocks < 1) {
                    count = 0
                    getInitialPrices@NordeaPort()(res1)
                    for( item in res1.Stocks ) {
                        global.BrokerStocks[count].Broker = "Nordea"
                        global.BrokerStocks[count].InstrumentId = item.InstrumentId
                        count++
                    }
                    getInitialPrices@NASDAQPort()(res2)
                    for( item in res2.Stocks ) {
                        global.BrokerStocks[count].Broker = "NASDAQ"
                        global.BrokerStocks[count].InstrumentId = item.InstrumentId
                        count++
                    }
                    getInitialPrices@JPMorganPort()(res3)
                    for( item in res3.Stocks ) {
                        global.BrokerStocks[count].Broker = "JPMorgan"
                        global.BrokerStocks[count].InstrumentId = item.InstrumentId
                        count++
                    }
                }
            }
            response.HedgeAccepted = false
            response.Broker = ""
            for( i=0, i<#global.BrokerStocks, i++) {
                if(request.InstrumentId == global.BrokerStocks[i].InstrumentId) {
                    response.HedgeAccepted = true
                    response.Broker = global.BrokerStocks[i].Broker
                }
            }
        }]

        [ shutdown()() ]{
            exit
        }
    }
}
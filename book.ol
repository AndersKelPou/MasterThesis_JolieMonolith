from .Modules.BookInterfaceModule import BookInterface
from .Modules.DBHandlerInterfaceModule import DBHandlerInterface

include "string_utils.iol"
include "console.iol"

service book {
    execution: concurrent

    inputPort bookPort {
        location: "socket://localhost:8002"
        protocol: http { format = "json" }
        interfaces: BookInterface
    }
    outputPort DBHandlerPort {
        location: "socket://localhost:8001"
        protocol: http { format = "json" }
        interfaces: DBHandlerInterface
    }

    init {
        println@Console("Book Running")()
    }

    main {
        [bookOrder(request)(response) {
            getDanskeBankId@DBHandlerPort()(danskeBankIDResponse)
            getRandomUUID@StringUtils()(transactionId)
            transaction << request
            transaction.TransactionId = transactionId
            if(request.BuyerId == "") {
                transaction.BuyerId = danskeBankIDResponse.ClientId
                transaction.SpreadPrice = 0 - (request.SpreadPrice)
            }else {
                transaction.SellerId = danskeBankIDResponse.ClientId
            }
            addTransaction@DBHandlerPort(transaction)(res)

            response.Message = "OK"
        }]

        [hedgeOrder(request)(response) {
            getDanskeBankId@DBHandlerPort()(danskeBankIDResponse)
            brokerIdRequest.Name = request.Broker
            getClientId@DBHandlerPort(brokerIdRequest)(brokerIdResponse)
            getRandomUUID@StringUtils()(transactionId)
            
            transaction1.TransactionId = transactionId
            transaction1.BuyerId = request.BuyerId
            transaction1.SellerId = request.SellerId
            transaction1.InstrumentId = request.InstrumentId
            transaction1.Size = request.Size
            transaction1.Price = request.Price
            transaction1.SpreadPrice = request.SpreadPrice
            transaction1.Succeeded = request.Succeeded

            transaction2.TransactionId = transactionId
            transaction2.BuyerId = request.BuyerId
            transaction2.SellerId = request.SellerId
            transaction2.InstrumentId = request.InstrumentId
            transaction2.Size = request.Size
            transaction2.Price = request.Price
            transaction2.SpreadPrice = 0.0
            transaction2.Succeeded = request.Succeeded

            if(request.BuyerId == "") {
                transaction1.BuyerId = danskeBankIDResponse.ClientId
                transaction1.SpreadPrice = 0 - (request.SpreadPrice)
                transaction2.SellerId = danskeBankIDResponse.ClientId
                transaction2.BuyerId = brokerIdResponse.ClientId
            }else {
                transaction1.SellerId = danskeBankIDResponse.ClientId
                transaction2.SellerId = brokerIdResponse.ClientId
                transaction2.BuyerId = danskeBankIDResponse.ClientId
            }
            addTransaction@DBHandlerPort(transaction1)(res)
            addTransaction@DBHandlerPort(transaction2)(res)

            response.Message = "OK"
        }]
        
        [ shutdown()() ]{
            exit
        }
    }
}
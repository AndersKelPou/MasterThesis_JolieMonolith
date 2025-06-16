from .Modules.DBHandlerInterfaceModule import DBHandlerInterface

include "console.iol"
include "database.iol"
include "string_utils.iol"
include "file.iol"

service dbhandler {
    execution: concurrent

    inputPort DBHandlerPort {
        location: "socket://localhost:8001"
        protocol: http { format = "json" }
        interfaces: DBHandlerInterface
    }

    init
    {
        file.filename = "./Modules/appsettings/dbhandlersettings.json";
        file.format = "json";
        readFile@File( file )( config )

        file.filename = "./Modules/appsettings/pricerenginesettings.json";
        file.format = "json";
        readFile@File( file )( instrumentconfig )

        with (connectionInfo) {
            .username = "sa";
            .password = "";
            .host = "";
            .database = "file:monolithdb/monolithdb";
            .driver = "hsqldb_embedded"
        };
        connect@Database(connectionInfo)();
        println@Console("DBHandler Running")();

        // create table if it does not exist
        getRandomUUID@StringUtils()(uuid1)
        getRandomUUID@StringUtils()(uuid2)

        getRandomUUID@StringUtils()(danskebankid)
        getRandomUUID@StringUtils()(nordeaid)
        getRandomUUID@StringUtils()(jpmorganid)
        getRandomUUID@StringUtils()(nasdaqid)

        internalTier = "Internal"
        internalBalance = 1000000.0
        internalHoldingSize = 100
        initialTarget = 3
        global.DanskeBankName = "Danske_Bank"

        scope (createClientTable) {
            install (SQLException => println@Console("Client table already exists")());
            update@Database(
                "create table Clients(clientid varchar(255) not null, " +
                "name varchar(255) not null, " +
                "balance decimal(100,2) not null, " +
                "tier varchar(20) not null, " +
                "primary key(clientid))"
            )(ret)
            update@Database(
                "insert into Clients (clientid, name, balance, tier) values (:clientid, :name, :balance, :tier)" {
                    .clientid = uuid1,
                    .name = "Anders",
                    .balance = 1000.0,
                    .tier = "External"
                }
            )(ret)
            update@Database(
                "insert into Clients (clientid, name, balance, tier) values (:clientid, :name, :balance, :tier)" {
                    .clientid = uuid2,
                    .name = "Mathias",
                    .balance = 1000.0,
                    .tier = "Premium"
                }
            )(ret)
            update@Database(
                "insert into Clients (clientid, name, balance, tier) values (:clientid, :name, :balance, :tier)" {
                    .clientid = danskebankid,
                    .name = global.DanskeBankName,
                    .balance = internalBalance,
                    .tier = internalTier
                }
            )(ret)
            update@Database(
                "insert into Clients (clientid, name, balance, tier) values (:clientid, :name, :balance, :tier)" {
                    .clientid = nordeaid,
                    .name = "Nordea",
                    .balance = internalBalance,
                    .tier = internalTier
                }
            )(ret)
            update@Database(
                "insert into Clients (clientid, name, balance, tier) values (:clientid, :name, :balance, :tier)" {
                    .clientid = jpmorganid,
                    .name = "JPMorgan",
                    .balance = internalBalance,
                    .tier = internalTier
                }
            )(ret)
            update@Database(
                "insert into Clients (clientid, name, balance, tier) values (:clientid, :name, :balance, :tier)" {
                    .clientid = nasdaqid,
                    .name = "NASDAQ",
                    .balance = internalBalance,
                    .tier = internalTier
                }
            )(ret)
        }
        scope (createCustomerTable) {
            install (SQLException => println@Console("Customer table already exists")());
            update@Database(
                "create table Customers(clientid varchar(255) not null, " +
                "username varchar(255) not null, " +
                "password varchar(255) not null, " +
                "primary key(clientid))"
            )(ret)
            update@Database(
                "insert into Customers (clientid, username, password) values (:clientid, :username, :password)" {
                    .clientid = uuid1,
                    .username = "KP",
                    .password = "KP"
                }
            )(ret)
            update@Database(
                "insert into Customers (clientid, username, password) values (:clientid, :username, :password)" {
                    .clientid = uuid2,
                    .username = "Dyberg",
                    .password = "Dyberg"
                }
            )(ret)
        }
        scope (createHoldingsTable) {
            install (SQLException => println@Console("Holdings table already exists")());
            update@Database(
                "create table Holdings(clientid varchar(255) not null, " +
                "instrumentid varchar(255) not null, " +
                "size int not null, " +
                "primary key(clientid, instrumentid))"
            )(ret)
            for(item in config.BrokerStocks.JPMorgan) {
                update@Database(
                    "insert into Holdings (clientid, instrumentid, size) values (:clientid, :instrumentid, :size)" {
                        .clientid = jpmorganid,
                        .instrumentid = item,
                        .size = internalHoldingSize
                    }
                )(ret)
            }
            for(item in config.BrokerStocks.NASDAQ) {
                update@Database(
                    "insert into Holdings (clientid, instrumentid, size) values (:clientid, :instrumentid, :size)" {
                        .clientid = nasdaqid,
                        .instrumentid = item,
                        .size = internalHoldingSize
                    }
                )(ret)
            }
            for(item in config.BrokerStocks.Nordea) {
                update@Database(
                    "insert into Holdings (clientid, instrumentid, size) values (:clientid, :instrumentid, :size)" {
                        .clientid = nordeaid,
                        .instrumentid = item,
                        .size = internalHoldingSize
                    }
                )(ret)
            }
        }
        scope (createTransactionsTable) {
            install (SQLException => println@Console("Transactions table already exists")());
            update@Database(
                "create table Transactions(id integer generated always as identity, " +
                "transactionid varchar(255) not null, " +
                "buyerid varchar(255) not null, " +
                "sellerid varchar(255) not null, " +
                "instrumentid varchar(255) not null, " +
                "size int not null, " +
                "price decimal(100,2) not null, " +
                "spreadprice decimal(100,2) not null, " +
                "succeeded boolean not null, " +
                "primary key(id))"
            )(ret)
        }
        scope (createTargetPositionsTable) {
            install (SQLException => println@Console("TargetPositions table already exists")());
            update@Database(
                "create table TargetPositions(instrumentid varchar(255) not null, " +
                "target int, " +
                "primary key(instrumentId))"
            )(ret)

            for(item in instrumentconfig.TradingOptions.InstrumentIds) {
                update@Database(
                    "insert into TargetPositions (instrumentid, target) values (:instrumentid, :target)" {
                        .instrumentid = item,
                        .target = initialTarget
                    }
                )(ret)
            }
        }
    }

	main {
        [ getClientId( request )( response ) {
            query@Database(
                "select clientId from Clients where name=:name" {
                    .name = request.Name
                }
            )(sqlResponse);
            if(#sqlResponse.row < 1) {
                response.ClientId = ""
            }else {
                response.ClientId -> sqlResponse.row.CLIENTID
            }
        } ]

        [ getAllClients( )( response ) {
            query@Database(
                "select * from Clients"
            )(sqlResponse);
            response.values -> sqlResponse.row
        } ]

        [ getClientFromId( request )( response ) {
            query@Database(
                "select * from Clients where clientId=:clientId" {
                    .clientId = string(request.ClientId)
                }
            )(sqlResponse);
            if(#sqlResponse.row < 1) {
                response.Client = void
            }else {
                response.Client.ClientId = request.ClientId
                response.Client.Name = sqlResponse.row.NAME
                response.Client.Balance = sqlResponse.row.BALANCE
                response.Client.Tier = sqlResponse.row.TIER
            }
        }]

        [ checkLogin( request )( response ) {
            query@Database(
                "select * from Customers where username=:username and password=:password" {
                    .username = request.username,
                    .password = request.password
                }
            )(sqlResponse);
            if(#sqlResponse.row < 1) {
                response.Authenticated = false
            }else {
                response.Authenticated = true
                query@Database(
                    "select * from Clients where clientId=:clientId" {
                        .clientId = sqlResponse.row.CLIENTID
                    }
                )(sqlResponse2);

                response.Client.ClientId = sqlResponse2.row.CLIENTID
                response.Client.Name = sqlResponse2.row.NAME
                response.Client.Balance = sqlResponse2.row.BALANCE
                response.Client.Tier = sqlResponse2.row.TIER

                query@Database(
                    "select * from Holdings where clientid=:clientid" {
                        .clientid = sqlResponse.row.CLIENTID
                    }
                )(sqlResponse3);
                if(#sqlResponse3.row < 1) {
                    response.Holdings = void
                }else {
                    for( i=0, i < #sqlResponse3.row, i++ ) {
                        response.Holdings[i].ClientId = sqlResponse3.row[i].CLIENTID
                        response.Holdings[i].InstrumentId = sqlResponse3.row[i].INSTRUMENTID
                        response.Holdings[i].Size = sqlResponse3.row[i].SIZE
                    }
                }
            }
        }]

        [getClientTier(request)(response){
            query@Database(
                "select tier from Clients where clientId=:clientId" {
                    .clientId = string(request.ClientId)
                }
            )(sqlResponse)
            if(#sqlResponse.row < 1) {
                response.ClientTier = void
            }else {
                response.ClientTier = sqlResponse.row.TIER
            }
        }]

        [getClientHoldings(request)(response){
            query@Database(
                "select * from Holdings where clientid=:clientid" {
                    .clientid = string(request.ClientId)
                }
            )(sqlResponse)
            if(#sqlResponse.row < 1) {
                response.Holdings = void
            }else {
                for( i=0, i < #sqlResponse.row, i++ ) {
                    response.Holdings[i].ClientId = sqlResponse.row[i].CLIENTID
                    response.Holdings[i].InstrumentId = sqlResponse.row[i].INSTRUMENTID
                    response.Holdings[i].Size = sqlResponse.row[i].SIZE
                }
            }
        }]

        [getDanskeBankHoldings()(response){
            query@Database(
                "select * from Holdings where clientId=:clientId" {
                    .clientId = string(danskebankid)
                }
            )(sqlResponse)
            if(#sqlResponse.row < 1) {
                response.Holdings = void
            }else {
                for( i=0, i < #sqlResponse.row, i++ ) {
                    response.Holdings[i].ClientId = sqlResponse.row[i].CLIENTID
                    response.Holdings[i].InstrumentId = sqlResponse.row[i].INSTRUMENTID
                    response.Holdings[i].Size = sqlResponse.row[i].SIZE
                }
            }
        }]

        [getDanskeBankId()(response) {
            query@Database(
                "select clientId from Clients where name=:name" {
                    .name = global.DanskeBankName
                }
            )(sqlResponse)
            response.ClientId = sqlResponse.row.CLIENTID
        }]

        [getInstrumentTarget(request)(response){
            query@Database(
                "select * from TargetPositions where instrumentId=:instrumentId" {
                    .instrumentId = request.InstrumentId
                }
            )(sqlResponse)
            if(#sqlResponse.row < 1) {
                response.Target = 0
            }else {
                response.Target = sqlResponse.row.TARGET
            }
        }]

        [addTransaction(request)(response) {
            update@Database(
                "insert into Transactions(transactionid, buyerid, sellerid, instrumentid, size, price, spreadprice, succeeded) values (:transactionid, :buyerid, :sellerid, :instrumentid, :size, :price, :spreadprice, :succeeded)" {
                    .transactionid = string(request.TransactionId)
                    .buyerid = string(request.BuyerId)
                    .sellerid = string(request.SellerId)
                    .instrumentid = string(request.InstrumentId)
                    .size = int(request.Size)
                    .price = double(request.Price)
                    .spreadprice = double(request.SpreadPrice)
                    .succeeded = bool(request.Succeeded)
                }
            )(res)

            if(request.Succeeded) {
                //Update Buyer Holdings
                query@Database(
                    "select * from Holdings where clientId=:clientId and instrumentId=:instrumentId" {
                        .clientId = string(request.BuyerId)
                        .instrumentId = string(request.InstrumentId)
                    }
                )(sqlResponse1)
                if(#sqlResponse1.row < 1) {
                    update@Database(
                        "insert into Holdings(clientid, instrumentid, size) values (:clientid, :instrumentid, :size)" {
                            .clientid = string(request.BuyerId)
                            .instrumentid = string(request.InstrumentId)
                            .size = int(request.Size)
                        }
                    )(res)
                }else {
                    update@Database(
                        "update Holdings set size=size+:size where clientid=:clientid and instrumentid=:instrumentid" {
                            .size = int(request.Size)
                            .clientid = string(request.BuyerId)
                            .instrumentid = string(request.InstrumentId)
                        }
                    )(res)
                }

                //Update Seller Holdings
                query@Database(
                    "select * from Holdings where clientId=:clientId and instrumentId=:instrumentId" {
                        .clientId = string(request.SellerId)
                        .instrumentId = string(request.InstrumentId)
                    }
                )(sqlResponse2)
                if(#sqlResponse2.row < 1) {
                    update@Database(
                        "insert into Holdings(clientid, instrumentid, size) values (:clientid, :instrumentid, :size)" {
                            .clientid = string(request.SellerId)
                            .instrumentid = string(request.InstrumentId)
                            .size = 0 - int(request.Size)
                        }
                    )(res)
                }else {
                    update@Database(
                        "update Holdings set size=size-:size where clientid=:clientid and instrumentid=:instrumentid" {
                            .size = int(request.Size)
                            .clientid = string(request.SellerId)
                            .instrumentid = string(request.InstrumentId)
                        }
                    )(res)
                }

                //Update Client Balances
                update@Database(
                    "update Clients set balance=balance-:cost where clientid=:clientid" {
                        .cost = double(request.Size * (request.Price + request.SpreadPrice))
                        .clientid = string(request.BuyerId)
                    }
                )(res)
                update@Database(
                    "update Clients set balance=balance+:cost where clientid=:clientid" {
                        .cost = double(request.Size * (request.Price + request.SpreadPrice))
                        .clientid = string(request.SellerId)
                    }
                )(res)
            }

            response.Message = "OK"
        }]

        [ shutdown()() ]{
            exit
        }
	}
}


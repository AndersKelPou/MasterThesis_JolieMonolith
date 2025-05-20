from .Modules.DBHandlerInterfaceModule import DBHandlerInterface

include "console.iol"
include "database.iol"
include "string_utils.iol"


service Dbhandler {
    execution: concurrent

    inputPort DBHandlerPort {
        location: "socket://localhost:8001"
        protocol: http { format = "json" }
        interfaces: DBHandlerInterface
    }

    init
    {
        with (connectionInfo) {
            .username = "sa";
            .password = "";
            .host = "";
            .database = "file:monolithdb/monolithdb";
            .driver = "hsqldb_embedded"
        };
        connect@Database(connectionInfo)();
        println@Console("connected")();

        // create table if it does not exist
        getRandomUUID@StringUtils()(uuid1)
        getRandomUUID@StringUtils()(uuid2)
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
                    .tier = "Internal"
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
        }
        scope (createTransactionsTable) {
            install (SQLException => println@Console("Transactions table already exists")());
            update@Database(
                "create table Transactions(transactionid varchar(255) not null, " +
                "buyerid varchar(255) not null, " +
                "sellerid varchar(255) not null, " +
                "instrumentid varchar(255) not null, " +
                "size int not null, " +
                "price decimal(100,2) not null, " +
                "datetime date not null, " +
                "succeeded boolean not null, " +
                "primary key(transactionid))"
            )(ret)
        }
    }

	main {
        [ getClientId( request )( response ) {
            query@Database(
                "select clientId from Clients where name=:name" {
                    .name = request.name
                }
            )(sqlResponse);
            response -> sqlResponse.row.CLIENTID
        } ]

        [ getAllClients( )( response ) {
            query@Database(
                "select * from Clients"
            )(sqlResponse);
            response.values -> sqlResponse.row
        } ]

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
                    "select * from Holdings where clientId=:clientId" {
                        .clientId = sqlResponse.row.CLIENTID
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
        
        
        [ shutdown()() ]{
            exit
        }
	}
}


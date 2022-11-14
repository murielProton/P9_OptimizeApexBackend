/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class Order_TestDataFactory_Test {
    private static String accountName = 'Yukako';
    private static String productName = 'Kinu';
    private static String pricebook2Name = 'Yukako\'s Price Book';
    private static String orderName = 'Yukako\'s Order';
    private static String nameLike = 'accountName-%';

    @TestSetup
    static void setupForOrder_TestDataFactory_Test(){
        //Create an Account
        AccountDataFactory.createAccount(accountName);
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        //create a Contract for this Account
        Contract_TestDataFactory.createContract(accountForThisTest);
        // Make sure the Pricebook2 entry is active and standard
        Pricebook2_TestDataFactory.createPricebook2(pricebook2Name);
    }
    @isTest
    static void testGetOrder(){
        // get sObjects for Test
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        Contract contractForThisTest = Contract_TestDataFactory.getContract(accountForThisTest.Id);
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);

        Order orderConstructed = new Order(
            Name = orderName,
            AccountId = accountForThisTest.Id,
            ContractId = contractForThisTest.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            ShipmentCost__c = 10,
            // essential for the creation of OrderItem
            Pricebook2Id =  pricebookForThisTest.Id
            //TotalAmount = not writable This is Why Order links to a Product2 with OrderItem
        );
        insert orderConstructed;

        Test.startTest();
        Order orderForThisTest = Order_TestDataFactory.getOrder(accountForThisTest, contractForThisTest);
        Test.stopTest();

        System.assertEquals(orderForThisTest.AccountId, accountForThisTest.Id, 'Order_TestDataFactory.getOrder should return one order.');
    }
    @isTest
    static void testGetOrdersAll(){
        // get sObjects for Test
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        Contract contractForThisTest = Contract_TestDataFactory.getContract(accountForThisTest.Id);
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);

        Order orderConstructed = new Order(
            Name = orderName,
            AccountId = accountForThisTest.Id,
            ContractId = contractForThisTest.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            ShipmentCost__c = 10,
            // essential for the creation of OrderItem
            Pricebook2Id =  pricebookForThisTest.Id
            //TotalAmount = not writable This is Why Order links to a Product2 with OrderItem
        );
        insert orderConstructed;

        Test.startTest();
        List<Order> orderListForThisTest = Order_TestDataFactory.getOrdersAll();
        Test.stopTest();

        System.assertEquals(orderListForThisTest.size(), 1, 'Order_TestDataFactory.getOrdersAll should return one order.');
    }
    // TODO getOrdersAllStatusOrdered
    @isTest
    static void testGetOrdersStatusOrdered(){
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        List<Account> accountsListToTest = new List<Account>();
        accountsListToTest.add(accountForThisTest);
        // The Order must have at least one Product, so we can change Order.Status to Ordered
        // Link these accounts to some products = for each accounts create a contract + create pricebook custom + create pricebook standard + create products + create price book entry + create order
        // for each accounts create a contract 
        Contract_TestDataFactory.createContractsList(accountsListToTest);
        // for the test to succeed the Contract Status should be Activated, but it can't be inserted as such, so we need to update it
        List<Contract> contractsListToUpdate = Contract_TestDataFactory.getContractsAll();
        Contract_TestDataFactory.updateContractsListStatusToActivated(contractsListToUpdate);
        Pricebook2_TestDataFactory.createPricebook2(pricebook2Name);
        // to create a Pricebook2 field Standard = true the price book needs to be linked to a Product2
        // Create Product2
        Product2_TestDataFactory.createProduct2(productName);
        // Now make sure the Salesforce process doese create a standard Pricebook2
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2_TestDataFactory.getProduct2(productName);
        // Process needs an entry in th Pricebook2 Standard = true, first ;
        PricebookEntry_TestDataFactory.createPriceBookEntryForPricebookStandard(product2ForThisTest);
        // then PricebookEntry for normal Pricebook2 can be inserted.
        PricebookEntry_TestDataFactory.createPriceBookEntry(pricebookForThisTest, product2ForThisTest);
        
        
        // get contracts List we just inserted
        List<Contract> contractsListForTest = Contract_TestDataFactory.getContractsAll();
        //Create Order for each Contracts
        Order_TestDataFactory.createOrdersListForEachContract(contractsListForTest, pricebookForThisTest);
        // they need to have their Status set to Ordered
        List<Order> orderList = Order_TestDataFactory.getOrdersAll();

        //OrderItem links product to Order 
        // for each Orders create an OrderItem
        List<OrderItem> orderItemsList = new List<OrderItem>();
        PricebookEntry pricebookEntryForThisTest = PricebookEntry_TestDataFactory.getPricebookEntry(pricebookForThisTest, product2ForThisTest);
        for(Order orderCurent : orderList){
            //(Order orderForThisTest, Product2 product2ForThisTest, PricebookEntry pricebookEntryForThisTest)
            orderItemsList.add(OrderItem_TestDataFactory.constructOneOrderItem(orderCurent, product2ForThisTest, pricebookEntryForThisTest));
        }
        insert orderItemsList;
        
        List<Order> orderListForTest = Order_TestDataFactory.getOrdersAll();        
        Order_TestDataFactory.updateOrdersListStatusToOrdered(orderListForTest);

        Test.startTest();
        List<Order> orderListForThisTest = Order_TestDataFactory.getOrdersStatusOrdered();
        Test.stopTest();

        System.assertEquals(orderListForThisTest[0].Status, 'Ordered', 'Order_TestDataFactory.getOrdersStatusOrdered should return at least one Order with the Status Ordered.');
    }

@isTest
static void testGetOrdersListOfNewOrdered(){
    Account accountForThisTest = AccountDataFactory.getAccount(accountName);
    List<Account> accountsListToTest = new List<Account>();
    accountsListToTest.add(accountForThisTest);
    // The Order must have at least one Product, so we can change Order.Status to Ordered
    // Link these accounts to some products = for each accounts create a contract + create pricebook custom + create pricebook standard + create products + create price book entry + create order
    // for each accounts create a contract 
    Contract_TestDataFactory.createContractsList(accountsListToTest);
    // for the test to succeed the Contract Status should be Activated, but it can't be inserted as such, so we need to update it
    List<Contract> contractsListToUpdate = Contract_TestDataFactory.getContractsAll();
    Contract_TestDataFactory.updateContractsListStatusToActivated(contractsListToUpdate);
    Pricebook2_TestDataFactory.createPricebook2(pricebook2Name);
    // to create a Pricebook2 field Standard = true the price book needs to be linked to a Product2
    // Create Product2
    Product2_TestDataFactory.createProduct2(productName);
    // Now make sure the Salesforce process doese create a standard Pricebook2
    Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
    Product2 product2ForThisTest = Product2_TestDataFactory.getProduct2(productName);
    // Process needs an entry in th Pricebook2 Standard = true, first ;
    PricebookEntry_TestDataFactory.createPriceBookEntryForPricebookStandard(product2ForThisTest);
    // then PricebookEntry for normal Pricebook2 can be inserted.
    PricebookEntry_TestDataFactory.createPriceBookEntry(pricebookForThisTest, product2ForThisTest);
    
    
    // get contracts List we just inserted
    List<Contract> contractsListForTest = Contract_TestDataFactory.getContractsAll();
    //Create Order for each Contracts
    Order_TestDataFactory.createOrdersListForEachContract(contractsListForTest, pricebookForThisTest);
    // they need to have their Status set to Ordered
    List<Order> orderList = Order_TestDataFactory.getOrdersAll();

    //OrderItem links product to Order 
    // for each Orders create an OrderItem
    List<OrderItem> orderItemsList = new List<OrderItem>();
    PricebookEntry pricebookEntryForThisTest = PricebookEntry_TestDataFactory.getPricebookEntry(pricebookForThisTest, product2ForThisTest);
    for(Order orderCurent : orderList){
        //(Order orderForThisTest, Product2 product2ForThisTest, PricebookEntry pricebookEntryForThisTest)
        orderItemsList.add(OrderItem_TestDataFactory.constructOneOrderItem(orderCurent, product2ForThisTest, pricebookEntryForThisTest));
    }
    insert orderItemsList;
    
    List<Order> orderListForTest = Order_TestDataFactory.getOrdersAll();        
    Order_TestDataFactory.updateOrdersListStatusToOrdered(orderListForTest);

    // setup for test
    Set<Order> orderSetOld = Order_TestDataFactory.convertOrderListIntoSet(orderList);
    Set<Order> orderSetNew = Order_TestDataFactory.convertOrderListIntoSet(Order_TestDataFactory.getOrdersAll());

    Test.startTest();
    List<Order> orderListForThisTest = Order_TestDataFactory.getOrdersListOfNewOrdered(orderSetNew, orderSetOld);
    Test.stopTest();

    System.assertEquals(orderListForThisTest.size(), 2, 'getOrdersListOfNewOrdered should return at least 2 Order.');
}
    @isTest
    static void testGetOrdersWheregetPriceBook2ListWherePricebookEntryLastModifiedDate(){
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        List<Account> accountsListToTest = new List<Account>();
        accountsListToTest.add(accountForThisTest);
        // The Order must have at least one Product, so we can change Order.Status to Ordered
        // Link these accounts to some products = for each accounts create a contract + create pricebook custom + create pricebook standard + create products + create price book entry + create order
        // for each accounts create a contract 
        Contract_TestDataFactory.createContractsList(accountsListToTest);
        // for the test to succeed the Contract Status should be Activated, but it can't be inserted as such, so we need to update it
        List<Contract> contractsListToUpdate = Contract_TestDataFactory.getContractsAll();
        Contract_TestDataFactory.updateContractsListStatusToActivated(contractsListToUpdate);
        Pricebook2_TestDataFactory.createPricebook2(pricebook2Name);
        // to create a Pricebook2 field Standard = true the price book needs to be linked to a Product2
        // Create Product2
        Product2_TestDataFactory.createProduct2(productName);
        // Now make sure the Salesforce process doese create a standard Pricebook2
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2_TestDataFactory.getProduct2(productName);
        // Process needs an entry in th Pricebook2 Standard = true, first ;
        PricebookEntry_TestDataFactory.createPriceBookEntryForPricebookStandard(product2ForThisTest);
        // then PricebookEntry for normal Pricebook2 can be inserted.
        PricebookEntry_TestDataFactory.createPriceBookEntry(pricebookForThisTest, product2ForThisTest);
        
        
        // get contracts List we just inserted
        List<Contract> contractsListForTest = Contract_TestDataFactory.getContractsAll();
        //Create Order for each Contracts
        Order_TestDataFactory.createOrdersListForEachContract(contractsListForTest, pricebookForThisTest);
        // they need to have their Status set to Ordered
        List<Order> orderList = Order_TestDataFactory.getOrdersAll();

        //OrderItem links product to Order 
        // for each Orders create an OrderItem
        List<OrderItem> orderItemsList = new List<OrderItem>();
        PricebookEntry pricebookEntryForThisTest = PricebookEntry_TestDataFactory.getPricebookEntry(pricebookForThisTest, product2ForThisTest);
        for(Order orderCurent : orderList){
            //(Order orderForThisTest, Product2 product2ForThisTest, PricebookEntry pricebookEntryForThisTest)
            orderItemsList.add(OrderItem_TestDataFactory.constructOneOrderItem(orderCurent, product2ForThisTest, pricebookEntryForThisTest));
        }
        insert orderItemsList;
        
        List<Order> orderListForTest = Order_TestDataFactory.getOrdersAll();        
        Order_TestDataFactory.updateOrdersListStatusToOrdered(orderListForTest);

        Test.startTest();
        List<Order> orderListForThisTest = Order_TestDataFactory.getOrdersWheregetPriceBook2ListWherePricebookEntryLastModifiedDate();
        Test.stopTest();

        System.assertEquals(orderListForThisTest.size(), 2, 'Order_TestDataFactory.getOrdersWheregetPriceBook2ListWherePricebookEntryLastModifiedDate should return at least 2 records of Order.');
    }

    @isTest
    static void testConstructOneOrder(){
        // get sObjects for Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        Contract contractForThisTest = Contract_TestDataFactory.getContract(accountForThisTest.Id);

        Test.startTest();
        Order orderForThisTest = Order_TestDataFactory.constructOneOrder( orderName, accountForThisTest.ID, contractForThisTest.ID, pricebookForThisTest);
        Test.stopTest();

        System.assertEquals(orderForThisTest.Status, 'Draft', 'Order_TestDataFactory.constructOneOrder should create one order.');
    }
    @isTest
    static void testCreateOrdersList(){
        // get sObjects for Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        Contract contractForThisTest = Contract_TestDataFactory.getContract(accountForThisTest.Id);

        Test.startTest();
        Order_TestDataFactory.createOrdersList(100, accountForThisTest.Id, contractForThisTest.Id , pricebookForThisTest);
        Test.stopTest();

        List<Order> ordersListToTest = Order_TestDataFactory.getOrdersAll();
        System.assertEquals(ordersListToTest.size(), 100, 'Order_TestDataFactory.createOrdersList should create 100 records of Orders.');
    }
    @isTest
    static void testUpdateOrderShipmentCost(){
        // get sObjects for Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        Contract contractForThisTest = Contract_TestDataFactory.getContract(accountForThisTest.Id);

        //insert an order
        Order orderConstructed = new Order(
            Name = orderName,
            AccountId = accountForThisTest.Id,
            ContractId = contractForThisTest.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            ShipmentCost__c = 10,
            // essential for the creation of OrderItem
            Pricebook2Id =  pricebookForThisTest.Id
            //TotalAmount = not writable This is Why Order links to a Product2 with OrderItem
        );
        insert orderConstructed;

        //get this order
        Order orderToUpdate = [SELECT Id, AccountId, TotalAmount, ShipmentCost__c
                               FROM Order
                               WHERE AccountId = :accountForThisTest.Id AND ContractId = :contractForThisTest.Id
                               LIMIT 1];

        Test.startTest();
        Order_TestDataFactory.updateOrderShipmentCost(orderToUpdate);
        Test.stopTest();

        Order orderForThisTest = [SELECT Id, AccountId, TotalAmount, ShipmentCost__c
                               FROM Order
                               WHERE AccountId = :accountForThisTest.Id AND ContractId = :contractForThisTest.Id
                               LIMIT 1];

        System.assertEquals(orderForThisTest.ShipmentCost__c, 20, 'Order_TestDataFactory.updateOrderShipmentCost should force ShipmentCost field to 20.');
    }
    @isTest
    static void testCreateOrdersListForEachContract(){
        // create some Accounts
        AccountDataFactory.createAccountsList(5);
        List<Account> accountsListToTest = [SELECT Id,
                                                    AccountRevenue__c,
                                                    Name
                                            FROM Account
                                            WHERE Name LIKE :nameLike
                                            ];
        // for each accounts create a contract 
        Contract_TestDataFactory.createContractsList(accountsListToTest);
        // Create Product2
        Product2_TestDataFactory.createProduct2(productName);
        // Now make sure the Salesforce process doese create a standard Pricebook2
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2_TestDataFactory.getProduct2(productName);
        // Process needs an entry in th Pricebook2 Standard = true, first ;
        PricebookEntry_TestDataFactory.createPriceBookEntryForPricebookStandard(product2ForThisTest);
        // then PricebookEntry for normal Pricebook2 can be inserted.
        PricebookEntry_TestDataFactory.createPriceBookEntry(pricebookForThisTest, product2ForThisTest);
        // get contracts List we just inserted
        List<Contract> contractListToCreateOrders = Contract_TestDataFactory.getContractsAll();
        Test.startTest();
        Order_TestDataFactory.createOrdersListForEachContract(contractListToCreateOrders, pricebookForThisTest);
        Test.stopTest();
        List<Order> orderListToTest = Order_TestDataFactory.getOrdersAll();
        System.assertEquals(orderListToTest.size(), 6, 'Order_TestDataFactory.createOrdersListForEachContract should isert 5 records on Order.');
    }
    // TODO 
    @isTest
    static void testUpdateOrdersListStatusToOrdered(){
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        List<Account> accountsListToTest = new List<Account>();
        accountsListToTest.add(accountForThisTest);
        // The Order must have at least one Product, so we can change Order.Status to Ordered
        // Link these accounts to some products = for each accounts create a contract + create pricebook custom + create pricebook standard + create products + create price book entry + create order
        // for each accounts create a contract 
        Contract_TestDataFactory.createContractsList(accountsListToTest);
        // for the test to succeed the Contract Status should be Activated, but it can't be inserted as such, so we need to update it
        List<Contract> contractsListToUpdate = Contract_TestDataFactory.getContractsAll();
        Contract_TestDataFactory.updateContractsListStatusToActivated(contractsListToUpdate);
        Pricebook2_TestDataFactory.createPricebook2(pricebook2Name);
        // to create a Pricebook2 field Standard = true the price book needs to be linked to a Product2
        // Create Product2
        Product2_TestDataFactory.createProduct2(productName);
        // Now make sure the Salesforce process doese create a standard Pricebook2
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2_TestDataFactory.getProduct2(productName);
        // Process needs an entry in th Pricebook2 Standard = true, first ;
        PricebookEntry_TestDataFactory.createPriceBookEntryForPricebookStandard(product2ForThisTest);
        // then PricebookEntry for normal Pricebook2 can be inserted.
        PricebookEntry_TestDataFactory.createPriceBookEntry(pricebookForThisTest, product2ForThisTest);
        
        
        // get contracts List we just inserted
        List<Contract> contractsListForTest = Contract_TestDataFactory.getContractsAll();
        //Create Order for each Contracts
        Order_TestDataFactory.createOrdersListForEachContract(contractsListForTest, pricebookForThisTest);
        // they need to have their Status set to Ordered
        List<Order> orderList = Order_TestDataFactory.getOrdersAll();

        //OrderItem links product to Order 
        // for each Orders create an OrderItem
        List<OrderItem> orderItemsList = new List<OrderItem>();
        PricebookEntry pricebookEntryForThisTest = PricebookEntry_TestDataFactory.getPricebookEntry(pricebookForThisTest, product2ForThisTest);
        for(Order orderCurent : orderList){
            //(Order orderForThisTest, Product2 product2ForThisTest, PricebookEntry pricebookEntryForThisTest)
            orderItemsList.add(OrderItem_TestDataFactory.constructOneOrderItem(orderCurent, product2ForThisTest, pricebookEntryForThisTest));
        }
        insert orderItemsList;
        List<Order> orderListForTest = Order_TestDataFactory.getOrdersAll();

        Test.startTest();
        Order_TestDataFactory.updateOrdersListStatusToOrdered(orderListForTest);
        Test.stopTest();

        List<Order> orderListForThisTest = Order_TestDataFactory.getOrdersStatusOrdered();
        System.assertEquals(orderListForThisTest[0].Status, 'Ordered', 'Order_TestDataFactory.updateOrdersListStatusToOrdered should update Status to Ordered.');
    }
    @isTest
    static void testConvertOrderListIntoSet(){
        String pricebook2Name ='Ruby Shoo\'s priceboock';
        List<Account> accountsListForThisTest = [SELECT Id,
                                                        AccountRevenue__c,
                                                        Name
                                                 FROM Account
                                                 WHERE Name = :accountName ];
        Account accountForThisTest = accountsListForThisTest[0];                                      
        //create a Contract for this Account
        Contract_TestDataFactory.createContract(accountForThisTest);
        // Make sure the Pricebook2 entry is active and standard
        Pricebook2_TestDataFactory.createPricebook2(pricebook2Name);

        // get sObjects for Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Contract contractForThisTest = Contract_TestDataFactory.getContract(accountForThisTest.Id);
        //Create Orders
        List<Order> ordersList = new List<Order>();
        for (Account currentAccount : accountsListForThisTest){
            Order orderForThisTest = Order_TestDataFactory.constructOneOrder(orderName, currentAccount.Id, contractForThisTest.Id, pricebookForThisTest);
            ordersList.add(orderForThisTest);
        }

        Test.startTest();
        Set<Order> orderSetForTest = Order_TestDataFactory.convertOrderListIntoSet(ordersList);
        Test.stopTest();

        System.assertEquals(orderSetForTest.size(), 1, 'Order_TestDataFactory.convertOrderListIntoSet should convert a list of 5 into a set of 5.');
    }
}

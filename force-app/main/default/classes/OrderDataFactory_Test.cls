/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class OrderDataFactory_Test {
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
        ContractDataFactory.createContract(accountForThisTest);
        // Make sure the Pricebook2 entry is active and standard
        Pricebook2_TestDataFactory.createPricebook2(pricebook2Name);
    }
    @isTest
    static void testGetOrder(){
        // get sObjects for Test
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        Contract contractForThisTest = ContractDataFactory.getContract(accountForThisTest.Id);
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
        Order orderForThisTest = OrderDataFactory.getOrder(accountForThisTest, contractForThisTest);
        Test.stopTest();

        System.assertEquals(orderForThisTest.AccountId, accountForThisTest.Id, 'OrderDataFactory.getOrder should return one order.');
    }
    @isTest
    static void testGetOrdersAll(){
        // get sObjects for Test
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        Contract contractForThisTest = ContractDataFactory.getContract(accountForThisTest.Id);
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
        List<Order> orderListForThisTest = OrderDataFactory.getOrdersAll();
        Test.stopTest();

        System.assertEquals(orderListForThisTest.size(), 1, 'OrderDataFactory.getOrdersAll should return one order.');
    }
    // getOrdersAllStatusOrdered
    @isTest
    static void testGetOrdersStatusOrdered(){
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        List<Account> accountsListToTest = new List<Account>();
        accountsListToTest.add(accountForThisTest);
        // The Order must have at least one Product, so we can change Order.Status to Ordered
        // Link these accounts to some products = for each accounts create a contract + create pricebook custom + create pricebook standard + create products + create price book entry + create order
        // for each accounts create a contract 
        ContractDataFactory.createContractsList(accountsListToTest);
        // for the test to succeed the Contract Status should be Activated, but it can't be inserted as such, so we need to update it
        List<Contract> contractsListToUpdate = ContractDataFactory.getContractsAll();
        ContractDataFactory.updateContractsListStatusToActivated(contractsListToUpdate);
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
        List<Contract> contractsListForTest = ContractDataFactory.getContractsAll();
        //Create Order for each Contracts
        OrderDataFactory.createOrdersListForEachContract(contractsListForTest, pricebookForThisTest);
        // they need to have their Status set to Ordered
        List<Order> orderList = OrderDataFactory.getOrdersAll();

        //OrderItem links product to Order 
        // for each Orders create an OrderItem
        List<OrderItem> orderItemsList = new List<OrderItem>();
        PricebookEntry pricebookEntryForThisTest = PricebookEntry_TestDataFactory.getPricebookEntry(pricebookForThisTest, product2ForThisTest);
        for(Order orderCurent : orderList){
            //(Order orderForThisTest, Product2 product2ForThisTest, PricebookEntry pricebookEntryForThisTest)
            orderItemsList.add(OrderItemDataFactory.constructOneOrderItem(orderCurent, product2ForThisTest, pricebookEntryForThisTest));
        }
        insert orderItemsList;
        
        List<Order> orderListForTest = OrderDataFactory.getOrdersAll();        
        OrderDataFactory.updateOrdersListStatusToOrdered(orderListForTest);

        Test.startTest();
        List<Order> orderListForThisTest = OrderDataFactory.getOrdersStatusOrdered();
        Test.stopTest();

        System.assertEquals(orderListForThisTest[0].Status, 'Ordered', 'OrderDataFactory.getOrdersStatusOrdered should return at least one Order with the Status Ordered.');
    }

@isTest
static void testGetOrdersListOfNewOrdered(){
    Account accountForThisTest = AccountDataFactory.getAccount(accountName);
    List<Account> accountsListToTest = new List<Account>();
    accountsListToTest.add(accountForThisTest);
    // The Order must have at least one Product, so we can change Order.Status to Ordered
    // Link these accounts to some products = for each accounts create a contract + create pricebook custom + create pricebook standard + create products + create price book entry + create order
    // for each accounts create a contract 
    ContractDataFactory.createContractsList(accountsListToTest);
    // for the test to succeed the Contract Status should be Activated, but it can't be inserted as such, so we need to update it
    List<Contract> contractsListToUpdate = ContractDataFactory.getContractsAll();
    ContractDataFactory.updateContractsListStatusToActivated(contractsListToUpdate);
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
    List<Contract> contractsListForTest = ContractDataFactory.getContractsAll();
    //Create Order for each Contracts
    OrderDataFactory.createOrdersListForEachContract(contractsListForTest, pricebookForThisTest);
    // they need to have their Status set to Ordered
    List<Order> orderList = OrderDataFactory.getOrdersAll();

    //OrderItem links product to Order 
    // for each Orders create an OrderItem
    List<OrderItem> orderItemsList = new List<OrderItem>();
    PricebookEntry pricebookEntryForThisTest = PricebookEntry_TestDataFactory.getPricebookEntry(pricebookForThisTest, product2ForThisTest);
    for(Order orderCurent : orderList){
        //(Order orderForThisTest, Product2 product2ForThisTest, PricebookEntry pricebookEntryForThisTest)
        orderItemsList.add(OrderItemDataFactory.constructOneOrderItem(orderCurent, product2ForThisTest, pricebookEntryForThisTest));
    }
    insert orderItemsList;
    
    List<Order> orderListForTest = OrderDataFactory.getOrdersAll();        
    OrderDataFactory.updateOrdersListStatusToOrdered(orderListForTest);

    // setup for test
    Set<Order> orderSetOld = OrderDataFactory.convertOrderListIntoSet(orderList);
    Set<Order> orderSetNew = OrderDataFactory.convertOrderListIntoSet(OrderDataFactory.getOrdersAll());

    Test.startTest();
    List<Order> orderListForThisTest = OrderDataFactory.getOrdersListOfNewOrdered(orderSetNew, orderSetOld);
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
        ContractDataFactory.createContractsList(accountsListToTest);
        // for the test to succeed the Contract Status should be Activated, but it can't be inserted as such, so we need to update it
        List<Contract> contractsListToUpdate = ContractDataFactory.getContractsAll();
        ContractDataFactory.updateContractsListStatusToActivated(contractsListToUpdate);
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
        List<Contract> contractsListForTest = ContractDataFactory.getContractsAll();
        //Create Order for each Contracts
        OrderDataFactory.createOrdersListForEachContract(contractsListForTest, pricebookForThisTest);
        // they need to have their Status set to Ordered
        List<Order> orderList = OrderDataFactory.getOrdersAll();

        //OrderItem links product to Order 
        // for each Orders create an OrderItem
        List<OrderItem> orderItemsList = new List<OrderItem>();
        PricebookEntry pricebookEntryForThisTest = PricebookEntry_TestDataFactory.getPricebookEntry(pricebookForThisTest, product2ForThisTest);
        for(Order orderCurent : orderList){
            //(Order orderForThisTest, Product2 product2ForThisTest, PricebookEntry pricebookEntryForThisTest)
            orderItemsList.add(OrderItemDataFactory.constructOneOrderItem(orderCurent, product2ForThisTest, pricebookEntryForThisTest));
        }
        insert orderItemsList;
        
        List<Order> orderListForTest = OrderDataFactory.getOrdersAll();        
        OrderDataFactory.updateOrdersListStatusToOrdered(orderListForTest);

        Test.startTest();
        List<Order> orderListForThisTest = OrderDataFactory.getOrdersWheregetPriceBook2ListWherePricebookEntryLastModifiedDate();
        Test.stopTest();

        System.assertEquals(orderListForThisTest.size(), 2, 'OrderDataFactory.getOrdersWheregetPriceBook2ListWherePricebookEntryLastModifiedDate should return at least 2 records of Order.');
    }

    @isTest
    static void testConstructOneOrder(){
        // get sObjects for Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        Contract contractForThisTest = ContractDataFactory.getContract(accountForThisTest.Id);

        Test.startTest();
        Order orderForThisTest = OrderDataFactory.constructOneOrder( orderName, accountForThisTest.ID, contractForThisTest.ID, pricebookForThisTest);
        Test.stopTest();

        System.assertEquals(orderForThisTest.Status, 'Draft', 'OrderDataFactory.constructOneOrder should create one order.');
    }
    @isTest
    static void testCreateOrdersList(){
        // get sObjects for Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        Contract contractForThisTest = ContractDataFactory.getContract(accountForThisTest.Id);

        Test.startTest();
        OrderDataFactory.createOrdersList(100, accountForThisTest.Id, contractForThisTest.Id , pricebookForThisTest);
        Test.stopTest();

        List<Order> ordersListToTest = OrderDataFactory.getOrdersAll();
        System.assertEquals(ordersListToTest.size(), 100, 'OrderDataFactory.createOrdersList should create 100 records of Orders.');
    }
    @isTest
    static void testUpdateOrderShipmentCost(){
        // get sObjects for Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        Contract contractForThisTest = ContractDataFactory.getContract(accountForThisTest.Id);

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
        OrderDataFactory.updateOrderShipmentCost(orderToUpdate);
        Test.stopTest();

        Order orderForThisTest = [SELECT Id, AccountId, TotalAmount, ShipmentCost__c
                               FROM Order
                               WHERE AccountId = :accountForThisTest.Id AND ContractId = :contractForThisTest.Id
                               LIMIT 1];

        System.assertEquals(orderForThisTest.ShipmentCost__c, 20, 'OrderDataFactory.updateOrderShipmentCost should force ShipmentCost field to 20.');
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
        ContractDataFactory.createContractsList(accountsListToTest);
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
        List<Contract> contractListToCreateOrders = ContractDataFactory.getContractsAll();
        Test.startTest();
        OrderDataFactory.createOrdersListForEachContract(contractListToCreateOrders, pricebookForThisTest);
        Test.stopTest();
        List<Order> orderListToTest = OrderDataFactory.getOrdersAll();
        System.assertEquals(orderListToTest.size(), 6, 'OrderDataFactory.createOrdersListForEachContract should isert 5 records on Order.');
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
        ContractDataFactory.createContractsList(accountsListToTest);
        // for the test to succeed the Contract Status should be Activated, but it can't be inserted as such, so we need to update it
        List<Contract> contractsListToUpdate = ContractDataFactory.getContractsAll();
        ContractDataFactory.updateContractsListStatusToActivated(contractsListToUpdate);
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
        List<Contract> contractsListForTest = ContractDataFactory.getContractsAll();
        //Create Order for each Contracts
        OrderDataFactory.createOrdersListForEachContract(contractsListForTest, pricebookForThisTest);
        // they need to have their Status set to Ordered
        List<Order> orderList = OrderDataFactory.getOrdersAll();

        //OrderItem links product to Order 
        // for each Orders create an OrderItem
        List<OrderItem> orderItemsList = new List<OrderItem>();
        PricebookEntry pricebookEntryForThisTest = PricebookEntry_TestDataFactory.getPricebookEntry(pricebookForThisTest, product2ForThisTest);
        for(Order orderCurent : orderList){
            //(Order orderForThisTest, Product2 product2ForThisTest, PricebookEntry pricebookEntryForThisTest)
            orderItemsList.add(OrderItemDataFactory.constructOneOrderItem(orderCurent, product2ForThisTest, pricebookEntryForThisTest));
        }
        insert orderItemsList;
        List<Order> orderListForTest = OrderDataFactory.getOrdersAll();

        Test.startTest();
        OrderDataFactory.updateOrdersListStatusToOrdered(orderListForTest);
        Test.stopTest();

        List<Order> orderListForThisTest = OrderDataFactory.getOrdersStatusOrdered();
        System.assertEquals(orderListForThisTest[0].Status, 'Ordered', 'OrderDataFactory.updateOrdersListStatusToOrdered should update Status to Ordered.');
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
        ContractDataFactory.createContract(accountForThisTest);
        // Make sure the Pricebook2 entry is active and standard
        Pricebook2_TestDataFactory.createPricebook2(pricebook2Name);

        // get sObjects for Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Contract contractForThisTest = ContractDataFactory.getContract(accountForThisTest.Id);
        //Create Orders
        List<Order> ordersList = new List<Order>();
        for (Account currentAccount : accountsListForThisTest){
            Order orderForThisTest = OrderDataFactory.constructOneOrder(orderName, currentAccount.Id, contractForThisTest.Id, pricebookForThisTest);
            ordersList.add(orderForThisTest);
        }

        Test.startTest();
        Set<Order> orderSetForTest = OrderDataFactory.convertOrderListIntoSet(ordersList);
        Test.stopTest();

        System.assertEquals(orderSetForTest.size(), 1, 'OrderDataFactory.convertOrderListIntoSet should convert a list of 5 into a set of 5.');
    }
}

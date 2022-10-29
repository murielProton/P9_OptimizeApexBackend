/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-29-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class Order_TestDataFactory_Test {
    private static String accountName = 'Yukako';
    private static String productName = 'Kinu';
    private static String pricebook2Name = 'Yukako\'s Price Book';
    private static String orderName = 'Yukako\'s Order';
    @TestSetup
    static void setupForOrder_TestDataFactory_Test(){
        //Create an Account
        Account_TestDataFactory.createAccount(accountName);
        Account accountForThisTest = Account_TestDataFactory.getAccount(accountName);
        //create a Contract for this Account
        Contract_TestDataFactory.createContract(accountForThisTest);
        // Make sure the Pricebook2 entry is active and standard
        Pricebook2_TestDataFactory.createPricebook2(pricebook2Name);
    }
    @isTest
    static void testGetOrder(){
        // get sObjects for Test
        Account accountForThisTest = Account_TestDataFactory.getAccount(accountName);
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
        Account accountForThisTest = Account_TestDataFactory.getAccount(accountName);
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
    @isTest
    static void testConstructOneOrder(){
        // get sObjects for Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Account accountForThisTest = Account_TestDataFactory.getAccount(accountName);
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
        Account accountForThisTest = Account_TestDataFactory.getAccount(accountName);
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
        Account accountForThisTest = Account_TestDataFactory.getAccount(accountName);
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

}

/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

@isTest
public with sharing class OrderItemDataFactory_Test {
    private static String accountName = 'Yukako';
    private static String productName = 'Kinu';
    private static String pricebook2Name = 'Yukako\'s Price Book';
    private static String orderName = 'Yukako\'s Order';
    @TestSetup
    static void setupForOrderItem_TestDataFactory_Test(){
        //Create an Account
        AccountDataFactory.createAccount(accountName);
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        //create a Contract for this Account
        ContractDataFactory.createContract(accountForThisTest);
        // Make sure the Pricebook2 entry is active and standard
        Pricebook2DataFactory.createPricebook2(pricebook2Name);
        // to create a Pricebook2 field Standard = true the price book needs to be linked to a Product2
        // Create Product2
        Product2DataFactory.createProduct2(productName);
        // Now make sure the Salesforce process doese create a standard Pricebook2
        Pricebook2 pricebookForThisTest = Pricebook2DataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2DataFactory.getProduct2(productName);
        // Process needs an entry in th Pricebook2 Standard = true, first ;
        PricebookEntryDataFactory.createPriceBookEntryForPricebookStandard(product2ForThisTest);
        // then PricebookEntry for normal Pricebook2 can be inserted.
        PricebookEntryDataFactory.createPriceBookEntry(pricebookForThisTest, product2ForThisTest);
        // get contract
        Contract contractForThisTest = ContractDataFactory.getContract(accountForThisTest.Id);
        Account accountForThisTest1 = AccountDataFactory.getAccount(accountName);
        //Create Order
        Order orderForThisTest = OrderDataFactory.constructOneOrder( orderName, accountForThisTest1.Id, contractForThisTest.Id, pricebookForThisTest);
        insert orderForThisTest;

    }
    @isTest
    static void testConstructOneOrderItem(){
        // get sObjects to run the test
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        Contract contractForThisTest = ContractDataFactory.getContract(accountForThisTest.Id);
        Order orderForThisTest = OrderDataFactory.getOrder(accountForThisTest, contractForThisTest);
        Product2 product2ForThisTest = Product2DataFactory.getProduct2(productName);
        Pricebook2 pricebookForThisTest = Pricebook2DataFactory.getPriceBook2ByName(pricebook2Name);
        PricebookEntry pricebookEntryForThisTest = PricebookEntryDataFactory.getPricebookEntry(pricebookForThisTest, product2ForThisTest);

        Test.startTest();
        OrderItem orderToTest = OrderItemDataFactory.constructOneOrderItem(orderForThisTest, product2ForThisTest, pricebookEntryForThisTest);
        Test.stopTest();

        System.assertEquals(orderToTest.UnitPrice, 240, 'OrderItemDataFactory.constructOneOrderItem should return one OrderItem.');
    }
}


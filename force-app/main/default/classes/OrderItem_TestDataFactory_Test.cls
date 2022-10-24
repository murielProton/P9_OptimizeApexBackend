/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-24-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

@isTest
public with sharing class OrderItem_TestDataFactory_Test {
    private static String accountName = 'Yukako';
    private static String productName = 'Kinu';
    private static String pricebook2Name = 'Yukako\'s Price Book';
    private static String orderName = 'Yukako\'s Order';
    @TestSetup
    static void setupForOrderItem_TestDataFactory_Test(){
        //Create an Account
        Account_TestDataFactory.createAccount(accountName);
        Account accountForThisTest = Account_TestDataFactory.getAccount(accountName);
        //create a Contract for this Account
        Contract_TestDataFactory.createContract(accountForThisTest);
        // Make sure the Pricebook2 entry is active and standard
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
        // get contract
        Contract contractForThisTest = Contract_TestDataFactory.getContract(accountForThisTest.Id);
        Account accountForThisTest1 = Account_TestDataFactory.getAccount(accountName);
        //Create Order
        Order orderForThisTest = Order_TestDataFactory.constructOneOrder( accountForThisTest1.Id, contractForThisTest.Id, pricebookForThisTest);
        insert orderForThisTest;

    }
    @isTest
    static void testConstructOneOrderItem(){
        // get sObjects to run the test
        Account accountForThisTest = Account_TestDataFactory.getAccount(accountName);
        Contract contractForThisTest = Contract_TestDataFactory.getContract(accountForThisTest.Id);
        Order orderForThisTest = Order_TestDataFactory.getOrder(accountForThisTest, contractForThisTest);
        Product2 product2ForThisTest = Product2_TestDataFactory.getProduct2(productName);
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        PricebookEntry pricebookEntryForThisTest = PricebookEntry_TestDataFactory.getPricebookEntry(pricebookForThisTest, product2ForThisTest);

        Test.startTest();
        OrderItem orderToTest = OrderItem_TestDataFactory.constructOneOrderItem(orderForThisTest, product2ForThisTest, pricebookEntryForThisTest);
        Test.stopTest();

        System.assertEquals(orderToTest.UnitPrice, 240, 'OrderItem_TestDataFactory.constructOneOrderItem should return one OrderItem.');
    }
}


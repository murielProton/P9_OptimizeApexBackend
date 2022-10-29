/**
 * @description       : 
 * @author            : Muriel Proton
 * @group             : 
 * @last modified on  : 10-29-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
/* Some informations on the correct way to juggle between Product2, Pricebook2 and PricebookEntry
STANDARD_PRICE_NOT_DEFINED, Before creating a custom price, create a standard price.:
First a new product needs to be added to the standard PricebookEntry
Then it needs to be added to a custom Pricebook.
THERE ARE NO standard Pricebook2 in a new instance of Organasation.

The standard price book is the master list of all your products and their default standard prices. Salesforce creates the standard price book when you start 
creating product records. It includes all your products and their standard prices regardless of any custom price books that include those products.
A custom price book is a separate list of products with custom prices, called list prices. Custom price books are ideal for offering products at different 
prices to different market segments, regions, or other subsets of your customers. Create a separate price book for each set of customers that you want to 
address. For example, if you have one set of prices for domestic customers and another for international customers, create a domestic price book and an 
international one.
Pricebook standard == true, not updatable. We can work only with the ID of the standard price book. Use Id pricebookId = Test.getStandardPricebookId(); 
from https://salesforce.stackexchange.com/questions/115098/standard-price-not-defined-no-standard-price-defined-for-this-product
SOAP **sObject** on google opens directly the documentation of this sObject.
*/
@isTest
public with sharing class OrderTrigger_Test {
    // init class variables
    private static String accountName = 'Yukako';
    private static String productName = 'Kinu';
    private static String pricebook2Name = 'Yukako\'s Price Book';
    private static String orderName = 'Yukako\'s Order';
    
    @TestSetup
    static void setupForTestAccountUpdateTrigger(){
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
        Order orderForThisTest = Order_TestDataFactory.constructOneOrder(orderName, accountForThisTest1.Id, contractForThisTest.Id, pricebookForThisTest);
        insert orderForThisTest;
        // Create OrderItem
        PricebookEntry pricebookEntryForThisTest = PricebookEntry_TestDataFactory.getPricebookEntry(pricebookForThisTest, product2ForThisTest);
        OrderItem constructedOrderItem = OrderItem_TestDataFactory.constructOneOrderItem(orderForThisTest, product2ForThisTest, pricebookEntryForThisTest);
        insert constructedOrderItem;
        
    }
    @isTest
    static void testAccountUpdateTrigger(){
        //init Test
        Account accountForThisTest = Account_TestDataFactory.getAccount(accountName);
        Contract contractForThisTest = Contract_TestDataFactory.getContract(accountForThisTest.Id);
        // get the field to test before update
        Decimal accountRevenueBeforeUpdate = accountForThisTest.AccountRevenue__c;

        //get the order for the test
        Order orderForTheTest = Order_TestDataFactory.getOrder(accountForThisTest, contractForThisTest);

        // Update Order
        Test.startTest();
        Order_TestDataFactory.updateOrderShipmentCost(orderForTheTest);
        Test.stopTest();

        // get the field to test aftier update
        Decimal accountRevenueAfterUpdate = Account_TestDataFactory.getAccount(accountName).AccountRevenue__c;

        // test if the two values are different
        Boolean isAccountRevenueChanged = accountRevenueBeforeUpdate != accountRevenueAfterUpdate;     
        System.assertEquals(isAccountRevenueChanged, true, 'After updating Order, the field AccountRevenue on Account should Change.');
    }
    @isTest
    static void testOrderBeforeUpdateTrigger(){
        //init Test
        Account accountForThisTest = Account_TestDataFactory.getAccount(accountName);
        Contract contractForThisTest = Contract_TestDataFactory.getContract(accountForThisTest.Id);
        //get the Order's ShipmentCost__c beforre test
        Order orderForTheTest = Order_TestDataFactory.getOrder(accountForThisTest, contractForThisTest);
        Decimal orderShipmentCostBeforeUpdate = orderForTheTest.ShipmentCost__c;

        // Update Order
        Test.startTest();
        Order_TestDataFactory.updateOrderShipmentCost(orderForTheTest);
        Test.stopTest();

        //get the Order's ShipmentCost__c after test
        Decimal orderShipmentCostAfterUpdate = orderForTheTest.ShipmentCost__c;

        // test if the two values are different
        Boolean isOrderShipmentCostChanged = orderShipmentCostBeforeUpdate != orderShipmentCostAfterUpdate;     
        System.assertEquals(isOrderShipmentCostChanged, true, 'After updating Order, the field ShipmentCost__c on Order should Change.');
    }
}
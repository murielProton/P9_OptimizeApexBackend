/**
 * @description       : 
 * @author            : Muriel Proton
 * @group             : 
 * @last modified on  : 11-14-2022
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
        AccountDataFactory.createAccount(accountName);
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        //create a Contract for this Account
        ContractDataFactory.createContract(accountForThisTest);
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
        Contract contractForThisTest = ContractDataFactory.getContract(accountForThisTest.Id);
        Account accountForThisTest1 = AccountDataFactory.getAccount(accountName);
        //Create Order
        Order orderForThisTest = OrderDataFactory.constructOneOrder(orderName, accountForThisTest1.Id, contractForThisTest.Id, pricebookForThisTest);
        insert orderForThisTest;
        // Create OrderItem
        PricebookEntry pricebookEntryForThisTest = PricebookEntry_TestDataFactory.getPricebookEntry(pricebookForThisTest, product2ForThisTest);
        OrderItem constructedOrderItem = OrderItemDataFactory.constructOneOrderItem(orderForThisTest, product2ForThisTest, pricebookEntryForThisTest);
        insert constructedOrderItem;
        
    }
    @isTest
    static void testAccountUpdateTrigger(){
        //init Test
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        Contract contractForThisTest = ContractDataFactory.getContract(accountForThisTest.Id);
        // get the field to test before update
        Decimal accountRevenueBeforeUpdate = accountForThisTest.AccountRevenue__c;

        //get the order for the test
        Order orderForTheTest = OrderDataFactory.getOrder(accountForThisTest, contractForThisTest);

        // Update Order
        Test.startTest();
        OrderDataFactory.updateOrderShipmentCost(orderForTheTest);
        Test.stopTest();

        // get the field to test aftier update
        Decimal accountRevenueAfterUpdate = AccountDataFactory.getAccount(accountName).AccountRevenue__c;

        // test if the two values are different
        Boolean isAccountRevenueChanged = accountRevenueBeforeUpdate != accountRevenueAfterUpdate;     
        System.assertEquals(isAccountRevenueChanged, true, 'After updating Order, the field AccountRevenue on Account should Change.');
    }
    @isTest
    static void testOrderBeforeUpdateTrigger(){
        //init Test
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        Contract contractForThisTest = ContractDataFactory.getContract(accountForThisTest.Id);
        //get the Order's ShipmentCost__c beforre test
        Order orderForTheTest = OrderDataFactory.getOrder(accountForThisTest, contractForThisTest);
        Decimal orderShipmentCostBeforeUpdate = orderForTheTest.ShipmentCost__c;

        // Update Order
        Test.startTest();
        OrderDataFactory.updateOrderShipmentCost(orderForTheTest);
        Test.stopTest();

        //get the Order's ShipmentCost__c after test
        Decimal orderShipmentCostAfterUpdate = orderForTheTest.ShipmentCost__c;

        // test if the two values are different
        Boolean isOrderShipmentCostChanged = orderShipmentCostBeforeUpdate != orderShipmentCostAfterUpdate;     
        System.assertEquals(isOrderShipmentCostChanged, true, 'After updating Order, the field ShipmentCost__c on Order should Change.');
    }
    /* TODO Revue the trigger so it updates -> Mise à jour du chiffre d’affaires (AccountRevenue__c)   
sur le Compte (Account) au passage du statut (Status)
de la Commande(Order) à Ordered ;
Adapt the folowing code to do so
// Create a bunch of Accounts
// link an some Orders to thees Accounts (Order.Status = Draft)
// The Contract Status must be Activated, so we can change Order.Status to Ordered
// The Contract cannot be created with a Status set to Activated, to have a Status Activated you need to update Contract
// The Order must have at least one Product, so we can change Order.Status to Ordered
// Change half of the Orders -> Order.Status to Ordered
// Find the list of Accounts linked to the Orders that had their status changed to Ordered
// Account.AccountRevenue__c updated (only thoese that are in the list described above)
// NB Account.AccountRevenue__c = Account.AccountRevenue__c + Order.TotalAmount
// NB Order.TotalAmount not wrightable
@isTest
public with sharing class AccountUpdate_Batch_Test {

    //set variables for test
    private static String nameLike = 'accountName-%';
    private static String pricebook2Name = 'pricebookName';
    private static String productName = 'Momen';

    @isTest
    static void testBatchWhenOrderStatusChangesToOrderedTheAccountRevenueMustBeUpdated(){
        // Create a bunch of Accounts
        AccountDataFactory.createAccountsList(100);
        List<Account> accountList1ToCompare = AccountDataFactory.getAccountsAll();
        Set<Account> accountSet1ToCompare = AccountDataFactory.convertAccountListIntoSet(accountList1ToCompare);
        // The Order must have at least one Product, so we can change Order.Status to Ordered
        // Link these accounts to some products = for each accounts create a contract + create pricebook custom + create pricebook standard + create products + create price book entry + create order
        // for each accounts create a contract 
        ContractDataFactory.createContractsList(accountList1ToCompare);
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


        // Change half of the Orders -> Order.Status to Ordered
        OrderDataFactory.updateOrdersListStatusToOrdered(orderListForTest);

        List<Order> orderListBeforeBatch = OrderDataFactory.getOrdersStatusOrdered();

        List<Account> accountList1BisToCompare = AccountDataFactory.getAccountsAll();
        Set<Account> accountSet1BisToCompare = AccountDataFactory.convertAccountListIntoSet(accountList1BisToCompare);

        Test.startTest();
        //Trigger Batch Here ! 
        //TODO replace folowing line by a call to batch
        Test.stopTest();

        // Find the list of Accounts linked to the Orders that had their status changed to Ordered
        List<Account> accountList2ToCompare = AccountDataFactory.getAccountsWhereOrderSatusOrdered();
        Set<Account> accountSet2ToCompare = AccountDataFactory.convertAccountListIntoSet(accountList2ToCompare);

        //Compare two list to see if they were changed by the batch (using set to be sure that the order of the Items are not accountable)
        Boolean isFirstListIdenticalToFirstBis = accountSet1ToCompare.equals(accountSet1BisToCompare);
        Boolean isFirstListIdenticalToSecond = accountSet1ToCompare.equals(accountSet2ToCompare);
        System.debug(accountSet1ToCompare);
        System.debug(accountSet1BisToCompare);
        System.debug(accountSet2ToCompare);
        System.assertEquals(isFirstListIdenticalToSecond, false, 'The Batch AccountUpdate_Batch should update only the Accounts related to the liste of Orders which Status was updated to Ordered.');


    }  */
}
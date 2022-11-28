/**
 * @description       : 
 * @author            : Muriel Proton
 * @group             : 
 * @last modified on  : 11-28-2022
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
        // Create a bunch of Accounts
        AccountDataFactory.createAccountsList(1);
        List<Account> accountList1ToCompare = AccountDataFactory.getAccountsAll();
        Set<Account> accountSet1ToCompare = AccountDataFactory.convertAccountListIntoSet(accountList1ToCompare);
        // The Order must have at least one Product, so we can change Order.Status to Ordered
        // Link these accounts to some products = for each accounts create a contract + create pricebook custom + create pricebook standard + create products + create price book entry + create order
        // for each accounts create a contract 
        ContractDataFactory.createContractsList(accountList1ToCompare);
        // for the test to succeed the Contract Status should be Activated, but it can't be inserted as such, so we need to update it
        List<Contract> contractsListToUpdate = ContractDataFactory.getContractsAll();
        ContractDataFactory.updateContractsListStatusToActivated(contractsListToUpdate);
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
        
        
        // get records to construct an Order
        Account accountForTest = AccountDataFactory.getAccount('accountName-0');
        Contract contractForTest = ContractDataFactory.getContract(accountForTest.Id);
        //Create Orders
        List<Order> listOfOrdersToInsert = new List<Order>();
        // if you change the numbers below you must change all the sytem asserts
        for(Integer i = 0 ; i < 201 ; i++){
            Order orderToAdd = OrderDataFactory.constructOneOrder('String orderName', accountForTest.Id, contractForTest.Id , pricebookForThisTest);
            listOfOrdersToInsert.add(orderToAdd);
        }
        insert listOfOrdersToInsert;
        // they need to have their Status set to Ordered
        List<Order> orderList = OrderDataFactory.getOrdersAll();

        //OrderItem links product to Order 
        // for each Orders create an OrderItem
        List<OrderItem> orderItemsList = new List<OrderItem>();
        PricebookEntry pricebookEntryForThisTest = PricebookEntryDataFactory.getPricebookEntry(pricebookForThisTest, product2ForThisTest);
        for(Order orderCurent : orderList){
            //(Order orderForThisTest, Product2 product2ForThisTest, PricebookEntry pricebookEntryForThisTest)
            orderItemsList.add(OrderItemDataFactory.constructOneOrderItem(orderCurent, product2ForThisTest, pricebookEntryForThisTest));
        }
        insert orderItemsList;
        List<Order> orderListForTest = OrderDataFactory.getOrdersAll();


        // Change the Orders -> Order.Status to Ordered
        OrderDataFactory.updateOrdersListStatusToOrdered(orderListForTest);
    }

   
    @isTest
    static void testBeforeUpdateTrigger(){
        List<Order> orderListBeforeTrigger = OrderDataFactory.getOrdersStatusOrdered();

        // get order to update to trigger the TRIGGER
        Order orderToUpdate = orderListBeforeTrigger[0];
        orderToUpdate.Name = 'forTest';
        orderToUpdate.ShipmentCost__c = 9;

        Test.startTest();
        update orderToUpdate;
        Test.stopTest();
        // get Order for the test
        Order orderForTest = [SELECT Id, NetAmount__c, TotalAmount, Name, ShipmentCost__c FROM ORDER WHERE Name = 'forTest'];
 
        System.assertEquals(orderForTest.NetAmount__c, 5751.00, 'before updating Order, the field NetAmount__c on one of the records of Order should  equal 5750.00.');
    }
    @isTest
    static void testUpdateTriggerAccountRevenue(){
        List<Order> orderListBeforeTrigger = OrderDataFactory.getOrdersStatusOrdered();

        // get order to update to trigger the TRIGGER
        Order orderToUpdate = orderListBeforeTrigger[0];
        orderToUpdate.Name = 'forTest';
        orderToUpdate.ShipmentCost__c = 9;

        Test.startTest();
        update orderToUpdate;
        Test.stopTest();
        // get Account for the test
        Account accoutForTest = [SELECT Id, AccountRevenue__c, Name FROM Account WHERE Name = 'accountName-0'];
 
        System.assertEquals(accoutForTest.AccountRevenue__c, 1157760.00, 'After updating Order, the field AccountRevenue__c on one of the records of Account should equal 1157760.00.');
    }

    @isTest
    static void testUpdatingAnOrderWhenTheAccountHasMoreThanHundredOrders(){
        // get records to get an Order
        Account accountForTest = AccountDataFactory.getAccount('accountName-0');
        Contract contractForTest = ContractDataFactory.getContract(accountForTest.Id);
        //get order to update for the test
        Order orderToUpdate = OrderDataFactory.getOrder(accountForTest, contractForTest);

        Test.startTest();
        // update order
        OrderDataFactory.updateOrderShipmentCost(orderToUpdate);
        Test.stopTest();

        // get all the orders on this Account
        List<Order> orderListOnThisAccount = [SELECT Id, AccountId, TotalAmount, ShipmentCost__c, NetAmount__c
                                                FROM Order
                                                WHERE AccountId = :accountForTest.Id AND ContractId = :contractForTest.Id];

        System.assertEquals(orderListOnThisAccount.size(), 201, 'When a reccord on Order is updated. And the Account it is on, has more than 100 Orders linked. There should be no problems.');
    }

    @isTest
    static void testUpdateTrigger(){
        //init Test
        Account accountForThisTest = AccountDataFactory.getAccount('accountName-0');
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
   
}
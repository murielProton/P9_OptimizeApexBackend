/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-31-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
//TODO
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

    @TestSetup
    static void setupForAccountUpdate_Batch_Test(){
        // Create a bunch of Accounts
        Account_TestDataFactory.createAccountsList(100);
        List<Account> accountsListToTest = Account_TestDataFactory.getAccountsAll();
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

        // Change half of the Orders -> Order.Status to Ordered
        Order_TestDataFactory.updateOrdersListStatusToOrdered(orderListForTest);
    }
    @isTest
    static void testBatchWhenOrderStatusChangesToOrderedTheAccountRevenueMustBeUpdated(){

        List<Order> orderListBeforeBatch = Order_TestDataFactory.getOrdersStatusOrdered();
        Test.startTest();
        //Trigger Batch Here ! 
        //TODO replace folowing line by a call to batch
        Test.stopTest();
        // Find the list of Accounts linked to the Orders that had their status changed to Ordered
        List<Account> accountListForTest = AccountUpdate_BatchHelper.convertOrdersListIntoAccountsList(orderListBeforeBatch);
        System.assertEquals(accountListForTest.size(), 100, 'The Batch AccountUpdate_Batch should update only the Accounts related to the liste of Orders which Status was updated to Ordered.');


    }  
}

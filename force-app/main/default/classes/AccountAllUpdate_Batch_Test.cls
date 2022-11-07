/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-07-2022
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
public with sharing class AccountAllUpdate_Batch_Test {

    //set variables for test
    private static String nameLike = 'accountName-%';
    private static String pricebook2Name = 'pricebookName';
    private static String productName = 'Momen';

    @isTest
    static void testBatchWhenOrderStatusChangesToOrderedTheAccountRevenueMustBeUpdated(){
        // Create a bunch of Accounts
        Account_TestDataFactory.createAccountsList(100);
        List<Account> accountList1ToCompare = Account_TestDataFactory.getAccountsAll();
        Set<Account> accountSet1ToCompare = Account_TestDataFactory.convertAccountListIntoSet(accountList1ToCompare);
        // The Order must have at least one Product, so we can change Order.Status to Ordered
        // Link these accounts to some products = for each accounts create a contract + create pricebook custom + create pricebook standard + create products + create price book entry + create order
        // for each accounts create a contract 
        Contract_TestDataFactory.createContractsList(accountList1ToCompare);
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


        // Change the Orders -> Order.Status to Ordered
        Order_TestDataFactory.updateOrdersListStatusToOrdered(orderListForTest);

        List<Order> orderListBeforeBatch = Order_TestDataFactory.getOrdersStatusOrdered();

        List<Account> accountList1BisToCompare = Account_TestDataFactory.getAccountsAll();
        Set<Account> accountSet1BisToCompare = Account_TestDataFactory.convertAccountListIntoSet(accountList1BisToCompare);

        Test.startTest();
        AccountAllUpdate_Batch accountUpdateAllBatch = new AccountAllUpdate_Batch();
        Id accountUpdateAllBatchID = Database.executeBatch(accountUpdateAllBatch);
        Test.stopTest();

        // Find the list of Accounts linked to the Orders that had their status changed to Ordered
        List<Account> accountList2ToCompare = Account_TestDataFactory.getAccountsWhereOrderSatusOrdered();
        Set<Account> accountSet2ToCompare = Account_TestDataFactory.convertAccountListIntoSet(accountList2ToCompare);

        //Compare two list to see if they were changed by the batch (using set to be sure that the order of the Items are not accountable)
        Boolean isFirstListIdenticalToFirstBis = accountSet1ToCompare.equals(accountSet1BisToCompare);
        Boolean isFirstListIdenticalToSecond = accountSet1ToCompare.equals(accountSet2ToCompare);
        System.debug(accountSet1ToCompare);
        System.debug(accountSet1BisToCompare);
        System.debug(accountSet2ToCompare);
        System.assertEquals(isFirstListIdenticalToSecond, false, 'The Batch AccountUpdate_Batch should update only the Accounts related to the liste of Orders which Status was updated to Ordered.');


    }  
}

/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class AccountUpdate_BatchHelper_Test {
    private static String pricebook2Name = 'pricebookName';
    private static String productName = 'Momen';

    @TestSetup
    static void setupForAccountUpdate_BatchHelperTest(){
       // Create a bunch of Accounts
       AccountDataFactory.createAccountsList(50);
       List<Account> accountsListToTest = AccountDataFactory.getAccountsAll();
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
       // Create a bunch of Accounts That will have no Orders Linked
       AccountDataFactory.createAccountsList(50);
    }
    @isTest
    static void testConvertOrdersListIntoAccountsList(){
        
        List<Order> orderListForTest = Order_TestDataFactory.getOrdersAll();

        Test.startTest();
        List<Account> accountList = AccountUpdate_BatchHelper.convertOrdersListIntoAccountsList(orderListForTest);
        Test.stopTest();

        System.assertEquals(accountList.size(), 50, 'AccountUpdate_BatchHelper.convertOrdersListIntoAccountsList should return a list of Account.');

    }
    @isTest
    static void testConvertAccountsListIntoOrdersList(){
        
        List<Account> accountListForTest = AccountDataFactory.getAccountsAll();

        Test.startTest();
        List<Order> orderList = AccountUpdate_BatchHelper.convertAccountsListIntoOrdersList(accountListForTest);
        Test.stopTest();

        System.assertEquals(orderList.size(), 50, 'AccountUpdate_BatchHelper.convertAccountsListIntoOrdersList should return a list of Orders.');

    }
}

/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-31-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

@isTest
public with sharing class OrderTriggerHelper_Test {
    private static String orderName = 'Yukako\'s Order';
    @TestSetup
    static void setupOrderTriggerHelper_Test(){
        Account_TestDataFactory.createAccountsList(5);
    }

    @isTest
    static void testGetAccountListAll(){

        Test.startTest();
        List<Account> accountListForTest = OrderTriggerHelper.getAccountListAll();
        Test.stopTest();

        System.assertEquals(accountListForTest.size(), 5, 'Order_TestDataFactory.getAccountListAll should get 5 reccords.');
    }

    
    @isTest
    static void testGetAccountsListToUpdate(){
        String pricebook2Name ='accountName-1\'s priceboock';
        List<Account> accountsListAll = OrderTriggerHelper.getAccountListAll();


        //create List of Contracts for all Accounts
        Contract_TestDataFactory.createContractsList(accountsListAll);
        // Make sure the Pricebook2 entry is active and standard
        Pricebook2_TestDataFactory.createPricebook2(pricebook2Name);

        // get sObjects for Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        List<Contract> contractsListForThisTest = Contract_TestDataFactory.getContractsALL();
        //Create Orders
        List<Order> ordersList = new List<Order>();
        for(Contract contractCurrent : contractsListForThisTest){
            Order orderForThisTest = Order_TestDataFactory.constructOneOrder( orderName, contractCurrent.AccountId, contractCurrent.Id, pricebookForThisTest);
            ordersList.add(orderForThisTest);
        }
        insert(ordersList);
        Set<Order> orderSetNew = Order_TestDataFactory.convertOrderListIntoSet(ordersList);
        
        Set<Account> accountsSetAll = Account_TestDataFactory.convertAccountListIntoSet(accountsListAll);

        Test.startTest();
        List<Account> accountListToTest = OrderTriggerHelper.getAccountsListToUpdate(orderSetNew, accountsSetAll);
        Test.stopTest();

        System.assertEquals(accountListToTest.size(), 5, 'OrderTriggerHelper.getAccountsListToUpdate should return a list of 5.');
    }
    @isTest
    public static void testGetOrdersListWithUpdatedNetAmounts(){
        String pricebook2Name ='accountName-1\'s priceboock';
        List<Account> accountsListAll = OrderTriggerHelper.getAccountListAll();


        //create List of Contracts for all Accounts
        Contract_TestDataFactory.createContractsList(accountsListAll);
        // Make sure the Pricebook2 entry is active and standard
        Pricebook2_TestDataFactory.createPricebook2(pricebook2Name);

        // get sObjects for Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        List<Contract> contractsListForThisTest = Contract_TestDataFactory.getContractsALL();
        //Create Orders
        List<Order> ordersList = new List<Order>();
        for(Contract contractCurrent : contractsListForThisTest){
            Order orderForThisTest = Order_TestDataFactory.constructOneOrder(orderName, contractCurrent.AccountId, contractCurrent.Id, pricebookForThisTest);
            ordersList.add(orderForThisTest);
        }
        insert(ordersList);

        Test.startTest();
        List<Order> orderListToTest = OrderTriggerHelper.getOrdersListWithUpdatedNetAmounts(ordersList);
        Test.stopTest();
        
        System.assertEquals(orderListToTest.size(), 5, 'OrderTriggerHelper.getOrdersListWithUpdatedNetAmounts should return a list of 5.');

    }
    @isTest
    public static void testUpdateListOfAccountsRevenue(){
        String pricebook2Name ='accountName-1\'s priceboock';
        List<Account> accountsListAll = OrderTriggerHelper.getAccountListAll();

        //create List of Contracts for all Accounts
        Contract_TestDataFactory.createContractsList(accountsListAll);
        // Make sure the Pricebook2 entry is active and standard
        Pricebook2_TestDataFactory.createPricebook2(pricebook2Name);

        // get sObjects for Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        List<Contract> contractsListForThisTest = Contract_TestDataFactory.getContractsALL();

        //Create Orders
        List<Order> orderListOld = new List<Order>();
        for(Contract contractCurrent : contractsListForThisTest){
            Order orderForThisTest = Order_TestDataFactory.constructOneOrder(orderName, contractCurrent.AccountId, contractCurrent.Id, pricebookForThisTest);
            orderListOld.add(orderForThisTest);
        }
        insert(orderListOld);
        List<Order> orderListNew = OrderTriggerHelper.getOrdersListWithUpdatedNetAmounts(orderListOld);

        Test.startTest();
        OrderTriggerHelper.updateListOfAccountsRevenue(orderListNew, orderListOld);
        Test.stopTest();

        List<Order> orderListToTest = Order_TestDataFactory.getOrdersAll();

        System.assertNotEquals(orderListToTest[0].TotalAmount, Null, 'OrderTriggerHelper.updateListOfAccountsRevenue should update a list of Orders.');
    }
    @isTest
    public static void testUpdateListOfOrdersNetAmounts(){
        String pricebook2Name ='accountName-1\'s priceboock';
        List<Account> accountsListAll = OrderTriggerHelper.getAccountListAll();

        //create List of Contracts for all Accounts
        Contract_TestDataFactory.createContractsList(accountsListAll);
        // Make sure the Pricebook2 entry is active and standard
        Pricebook2_TestDataFactory.createPricebook2(pricebook2Name);

        // get sObjects for Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        List<Contract> contractsListForThisTest = Contract_TestDataFactory.getContractsALL();

        //Create Orders
        List<Order> orderListOld = new List<Order>();
        for(Contract contractCurrent : contractsListForThisTest){
            Order orderForThisTest = Order_TestDataFactory.constructOneOrder(orderName, contractCurrent.AccountId, contractCurrent.Id, pricebookForThisTest);
            orderListOld.add(orderForThisTest);
        }
        insert(orderListOld);
        List<Order> orderListNew = OrderTriggerHelper.getOrdersListWithUpdatedNetAmounts(orderListOld);

        Test.startTest();
        OrderTriggerHelper.updateListOfOrdersNetAmounts(orderListNew, orderListOld);
        Test.stopTest();

        List<Order> orderListToTest = Order_TestDataFactory.getOrdersAll();

        System.assertNotEquals(orderListToTest[0].ShipmentCost__c, 20, 'OrderTriggerHelper.getOrdersListWithUpdatedNetAmounts should update a list of Orders.');
    }
}

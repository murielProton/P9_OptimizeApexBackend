/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-21-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

@isTest
public with sharing class OrderTriggerHelper_Test {

    private static String orderName = 'Yukako\'s Order';
    private static String pricebook2Name = 'Yukako\'s Pricebook';
    private static String productName = 'Momen';

    @TestSetup
    static void setupOrderTriggerHelper_Test(){
        AccountDataFactory.createAccountsList(5);
    }
    
    @isTest
    static void testGetAccountsListToUpdate(){
        String pricebook2Name ='accountName-1\'s priceboock';
        
        //To cover each line of Code
        AccountDataFactory.createAccount('Not linked with an order.');

        List<Account> accountsListAll = AccountDataFactory.getAccountListAll();

        //create List of Contracts for all Accounts
        ContractDataFactory.createContractsList(accountsListAll);
        // Make sure the Pricebook2 entry is active and standard
        Pricebook2DataFactory.createPricebook2(pricebook2Name);

        // get sObjects for Test
        Pricebook2 pricebookForThisTest = Pricebook2DataFactory.getPriceBook2ByName(pricebook2Name);
        List<Contract> contractsListForThisTest = ContractDataFactory.getContractsALL();
        //Create Orders
        List<Order> ordersList = new List<Order>();
        for(Contract contractCurrent : contractsListForThisTest){
            Order orderForThisTest = OrderDataFactory.constructOneOrder( orderName, contractCurrent.AccountId, contractCurrent.Id, pricebookForThisTest);
            ordersList.add(orderForThisTest);
        }
        insert(ordersList);
        Set<Order> orderSetNew = OrderDataFactory.convertOrderListIntoSet(ordersList);
        
        Set<Account> accountsSetAll = AccountDataFactory.convertAccountListIntoSet(accountsListAll);

        Test.startTest();
        List<Account> accountListToTest = OrderTriggerHelper.getAccountsListToUpdate(orderSetNew, accountsSetAll);
        Test.stopTest();

        System.assertEquals(accountListToTest.size(), 6, 'OrderTriggerHelper.getAccountsListToUpdate should return a list of 6.');
    }
    @isTest
    public static void testGetOrdersListWithUpdatedNetAmounts(){
        String pricebook2Name ='accountName-1\'s priceboock';
        String productName = 'Tape mesurer';
        List<Account> accountsListAll = AccountDataFactory.getAccountListAll();


        //create List of Contracts for all Accounts
        ContractDataFactory.createContractsList(accountsListAll);
        // Make sure the Pricebook2 entry is active and standard
        Pricebook2DataFactory.createPricebook2(pricebook2Name);
        // Create Product2
        Product2DataFactory.createProduct2(productName);

        // get sObjects for Test
        Pricebook2 pricebookForThisTest = Pricebook2DataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2DataFactory.getProduct2(productName);
        // Process needs an entry in th Pricebook2 Standard = true, first ;
        PricebookEntryDataFactory.createPriceBookEntryForPricebookStandard(product2ForThisTest);
        // then PricebookEntry for normal Pricebook2 can be inserted.
        PricebookEntryDataFactory.createPriceBookEntry(pricebookForThisTest, product2ForThisTest);
        List<Contract> contractsListForThisTest = ContractDataFactory.getContractsALL();
        ContractDataFactory.updateContractsListStatusToActivated(contractsListForThisTest);
        //Create Orders
        List<Order> ordersList = new List<Order>();
        for(Contract contractCurrent : contractsListForThisTest){
            Order orderForThisTest = OrderDataFactory.constructOneOrder(orderName, contractCurrent.AccountId, contractCurrent.Id, pricebookForThisTest);
            ordersList.add(orderForThisTest);
        }
        

        insert ordersList;
        List<Order> ordersAllListToUpdate = OrderDataFactory.getOrdersAll();

        //OrderItem links product to Order 
        // for each Orders create an OrderItem
        List<OrderItem> orderItemsList = new List<OrderItem>();
        PricebookEntry pricebookEntryForThisTest = PricebookEntryDataFactory.getPricebookEntry(pricebookForThisTest, product2ForThisTest);
        for(Order orderCurent : ordersAllListToUpdate){
            //(Order orderForThisTest, Product2 product2ForThisTest, PricebookEntry pricebookEntryForThisTest)
            orderItemsList.add(OrderItemDataFactory.constructOneOrderItem(orderCurent, product2ForThisTest, pricebookEntryForThisTest));
        }
        insert orderItemsList;

        List<Order> orderListForTest = OrderDataFactory.getOrdersAll();

        // Change the Orders -> Order.Status to Ordered
        OrderDataFactory.updateOrdersListStatusToOrdered(orderListForTest);
        List<Order> ordersAllList = OrderDataFactory.getOrdersAll();
        
        Test.startTest();
        List<Order> orderListToTest = OrderTriggerHelper.getOrdersListWithUpdatedNetAmounts(ordersAllList);
        Test.stopTest();

        System.debug('getallOrders '+ OrderDataFactory.getOrdersAll());
        
        System.assertEquals(orderListToTest.size(), 5, 'OrderTriggerHelper.getOrdersListWithUpdatedNetAmounts should return a list of 5.');

    }
    
    @isTest
    public static void testUpdateListOfAccountsRevenueWhenOrderStatusOrdered(){

    List<Account> accountsListToTest = AccountDataFactory.getAccountsAll();
    // The Order must have at least one Product, so we can change Order.Status to Ordered
    // Link these accounts to some products = for each accounts create a contract + create pricebook custom + create pricebook standard + create products + create price book entry + create order
    // for each accounts create a contract 
    ContractDataFactory.createContractsList(accountsListToTest);
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
    
    
    // get contracts List we just inserted
    List<Contract> contractsListForTest = ContractDataFactory.getContractsAll();
    //Create Order for each Contracts
    OrderDataFactory.createOrdersListForEachContract(contractsListForTest, pricebookForThisTest);
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
    OrderDataFactory.updateOrdersListStatusToOrdered(orderListForTest);

        Test.startTest();
        OrderTriggerHelper.updateListOfAccountsRevenueWhenOrderStatusOrdered(OrderDataFactory.getOrdersAll(), orderList);
        Test.stopTest();

        List<Order> orderListToTest = OrderDataFactory.getOrdersAll();

        System.assertNotEquals(orderListToTest.size(), 1, 'OrderTriggerHelper.updateListOfAccountsRevenueWhenOrderStatusOrdered should update a list of Orders.');
    }
    @isTest
    public static void testUpdateListOfOrdersNetAmounts(){
        String pricebook2Name ='accountName-1\'s priceboock';
        List<Account> accountsListAll = AccountDataFactory.getAccountListAll();

        //create List of Contracts for all Accounts
        ContractDataFactory.createContractsList(accountsListAll);
        // Make sure the Pricebook2 entry is active and standard
        Pricebook2DataFactory.createPricebook2(pricebook2Name);

        // get sObjects for Test
        Pricebook2 pricebookForThisTest = Pricebook2DataFactory.getPriceBook2ByName(pricebook2Name);
        List<Contract> contractsListForThisTest = ContractDataFactory.getContractsALL();

        //Create Orders
        List<Order> orderListOld = new List<Order>();
        for(Contract contractCurrent : contractsListForThisTest){
            Order orderForThisTest = OrderDataFactory.constructOneOrder(orderName, contractCurrent.AccountId, contractCurrent.Id, pricebookForThisTest);
            orderListOld.add(orderForThisTest);
        }
        insert(orderListOld);
        List<Order> orderListNew = OrderTriggerHelper.getOrdersListWithUpdatedNetAmounts(orderListOld);

        Test.startTest();
        OrderTriggerHelper.changeListOfOrdersNetAmountsForTrigger(orderListNew, orderListOld);
        Test.stopTest();

        List<Order> orderListToTest = OrderDataFactory.getOrdersAll();

        System.assertNotEquals(orderListToTest[0].ShipmentCost__c, 20, 'OrderTriggerHelper.changeListOfOrdersNetAmountsForTrigger should update a list of Orders.');
    }
}

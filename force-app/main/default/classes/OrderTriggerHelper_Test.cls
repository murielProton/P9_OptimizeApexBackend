/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-14-2022
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

        System.assertEquals(accountListToTest.size(), 5, 'OrderTriggerHelper.getAccountsListToUpdate should return a list of 5.');
    }
    @isTest
    public static void testGetOrdersListWithUpdatedNetAmounts(){
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
        List<Order> ordersList = new List<Order>();
        for(Contract contractCurrent : contractsListForThisTest){
            Order orderForThisTest = OrderDataFactory.constructOneOrder(orderName, contractCurrent.AccountId, contractCurrent.Id, pricebookForThisTest);
            ordersList.add(orderForThisTest);
        }
        
        //Added for 100% code coverage
        Order orderShipmentCostNull = new Order(
            Name = 'Vivien',
            AccountId = accountsListAll[0].Id,
            ContractId = contractsListForThisTest[0].Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            ShipmentCost__c = Null,
            // essential for the creation of OrderItem
            Pricebook2Id =  pricebookForThisTest.Id
            //TotalAmount = not writable This is Why Order links to a Product2 with OrderItem
            ); 

        //Insert the Order List and get them
        ordersList.add(orderShipmentCostNull);   
        insert ordersList;
        List<Order> ordersAllList = OrderDataFactory.getOrdersAll();

        Test.startTest();
        List<Order> orderListToTest = OrderTriggerHelper.getOrdersListWithUpdatedNetAmounts(ordersAllList);
        Test.stopTest();

        System.debug('getallOrders '+ OrderDataFactory.getOrdersAll());
        
        System.assertEquals(orderListToTest.size(), 6, 'OrderTriggerHelper.getOrdersListWithUpdatedNetAmounts should return a list of 5.');

    }
    @isTest
    public static void testUpdateListOfAccountsRevenue(){
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
        OrderTriggerHelper.updateListOfAccountsRevenue(orderListNew, orderListOld);
        Test.stopTest();

        List<Order> orderListToTest = OrderDataFactory.getOrdersAll();

        System.assertNotEquals(orderListToTest[0].TotalAmount, Null, 'OrderTriggerHelper.updateListOfAccountsRevenue should update a list of Orders.');
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
    Product2_TestDataFactory.createProduct2(productName);
    // Now make sure the Salesforce process doese create a standard Pricebook2
    Pricebook2 pricebookForThisTest = Pricebook2DataFactory.getPriceBook2ByName(pricebook2Name);
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
        OrderTriggerHelper.updateListOfOrdersNetAmounts(orderListNew, orderListOld);
        Test.stopTest();

        List<Order> orderListToTest = OrderDataFactory.getOrdersAll();

        System.assertNotEquals(orderListToTest[0].ShipmentCost__c, 20, 'OrderTriggerHelper.getOrdersListWithUpdatedNetAmounts should update a list of Orders.');
    }
}

/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class MyTeamOrdersController_Test {
    private static String accountName = 'Yukako';
    private static String pricebook2Name = 'Yukako\'s Price Book';
    private static String productName = 'Kinu';
    @TestSetup
    static void testSetupForMyTeamOrdersController(){
        //Create an Account
        AccountDataFactory.createAccount(accountName);
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        //create a Contract for this Account
        ContractDataFactory.createContract(accountForThisTest);
        List<Contract> contractsListToUpdate = ContractDataFactory.getContractsAll();
        ContractDataFactory.updateContractsListStatusToActivated(contractsListToUpdate);
        Pricebook2DataFactory.createPricebook2(pricebook2Name);
        // Make sure the Pricebook2 entry is active and standard
        Pricebook2DataFactory.createPricebook2(pricebook2Name);

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
    }
    @isTest
    static void testSumOders(){
       
        AggregateResult groupedResults = [SELECT SUM(TotalAmount) total FROM Order];
        Test.startTest();
        MyTeamOrdersController instanceOfMyTemOrdersController = new MyTeamOrdersController();
        decimal groupedResultsMTOC = instanceOfMyTemOrdersController.sumOrders;
        Test.stopTest();

        System.debug('groupedResults - '+groupedResults);
        System.assertEquals(groupedResultsMTOC, (decimal)groupedResults.get('Total'), 'MyTeamOrdersController.sumOrders should retrun the summ of all the TotalAmount fields on all the Orders records.');
        
    }
}

/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
// NB Account.AccountRevenue__c = Account.AccountRevenue__c + Order.TotalAmount
// NB Order.TotalAmount = PricebookEntry.UnitPrice x OrderItem.Quantity

@isTest
public with sharing class AccountDataFactory_Test {
    private static String accountName = 'accountName';
    private static String nameLike = 'accountName-%';
    private static String pricebook2Name = 'pricebookName';
    private static String productName = 'Momen';
    @isTest
    static void testGetAccountListAll(){
        
        List<Account> accountsListToInsertForTest = new List<Account>();
        for(Integer i = 0 ; i < 5 ; i++){
            accountsListToInsertForTest.add(new Account(Name = accountName + i));
        }
        insert accountsListToInsertForTest;

        Test.startTest();
        List<Account> accountListForTest = AccountDataFactory.getAccountListAll();
        Test.stopTest();

        System.assertEquals(accountListForTest.size(), 5, 'AccountDataFactory.getAccountListAll should get 5 reccords.');
    }
    @isTest
    public static void testingGetAccount(){
        List<Account> accountsListToInsertForTest = new List<Account>();
        for(Integer i = 0 ; i < 5 ; i++){
            accountsListToInsertForTest.add(new Account(Name = accountName + i));
        }
        insert accountsListToInsertForTest;
        
        Test.startTest();
        Account accountToTest = AccountDataFactory.getAccount(accountName+3);
        Test.stopTest();

        System.assertEquals(accountToTest.name, accountName+3, 'getAccount(accountName) from AccountDataFactory should return only one Account record by the name of :'+accountName+3+'.');
    }
    @isTest
    public static void testGetAccountsAll(){
        List<Account> accountsListToInsertForTest = new List<Account>();
        for(Integer i = 0 ; i < 5 ; i++){
            accountsListToInsertForTest.add(new Account(Name = accountName + i));
        }
        insert accountsListToInsertForTest;
        
        Test.startTest();
        List<Account> accountsListToTest = AccountDataFactory.getAccountsAll();
        Test.stopTest();

        System.assertEquals(accountsListToTest.size(), 5, 'AccountDataFactory.getAccountsAll() should return a list of five records.');
    }
    @isTest
    public static void testGetAccountsWhereOrderSatusOrdered(){
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


        // Change half of the Orders -> Order.Status to Ordered
        OrderDataFactory.updateOrdersListStatusToOrdered(orderListForTest);

        List<Order> orderListBeforeBatch = OrderDataFactory.getOrdersStatusOrdered();

        Test.startTest();
        List<Account> accountsListToTest = AccountDataFactory.getAccountsWhereOrderSatusOrdered();
        Test.stopTest();

        System.assertEquals(accountsListToTest.size(), 100, 'AccountDataFactory.getAccountsWhereOrderSatusOrdered should return a list of one hundred records.');
    }

    @isTest
    public static void testGetAccountsListWhereEntryLastModifiedDateLessThanAWeek(){
         // Create a bunch of Accounts
         AccountDataFactory.createAccountsList(100);
         List<Account> accountList1ToCompare = AccountDataFactory.getAccountsAll();
         Account accountToCompare1 = [SELECT Id,
                                            AccountRevenue__c,
                                            Name
                                    FROM Account
                                    WHERE Id = :accountList1ToCompare[0].Id
                                    ];

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

        Test.startTest();
        List<Account> accountsListToTest = AccountDataFactory.getAccountsListWhereEntryLastModifiedDateLessThanAWeek();
        Test.stopTest();

        System.assertEquals(accountsListToTest.size(), 100, 'AccountDataFactory.getAccountsListWhereEntryLastModifiedDateLessThanAWeek should return 100 records of Accounts.');
    }

    @isTest
    public static void testingCreateAccount(){
        Test.startTest();
        AccountDataFactory.createAccount(accountName);
        Test.stopTest();
        List<Account> accountsListToTest = [SELECT Id,
                                                    AccountRevenue__c,
                                                    Name
                                            FROM Account
                                            WHERE Name= :accountName 
                                           ];

        System.assertEquals(accountsListToTest.size(), 1, 'createAccount(accountName) from AccountDataFactory should create one record named '+accountName+'.');
    }
    @isTest
    public static void testCreateAccountsList(){
        Test.startTest();
        AccountDataFactory.createAccountsList(5);
        Test.stopTest();
        List<Account> accountsListToTest = [SELECT Id,
                                                    AccountRevenue__c,
                                                    Name
                                            FROM Account
                                            WHERE Name LIKE :nameLike
                                           ];
        System.assertEquals(accountsListToTest.size(), 5, 'AccountDataFactory.createAccountsList should create 5 records of Accounts.');
    }

    @isTest
    public static void testConvertAccountsListIntoMapOfIdsAndRevenues(){
        AccountDataFactory.createAccountsList(5);
        List<Account> accountsListToTest = [SELECT Id,
                                                    AccountRevenue__c,
                                                    Name
                                            FROM Account
                                            WHERE Name LIKE :nameLike
                                           ];
        Test.startTest();
        Map<Id,Decimal> accountsMapIdAndRevenueForTest = AccountDataFactory.convertAccountsListIntoMapOfIdsAndRevenues(accountsListToTest);
        Test.stopTest();

        System.assertEquals(accountsMapIdAndRevenueForTest.size(), 5, 'AccountDataFactory.convertAccountsListIntoMapOfIdsAndRevenues should return a Map of Account.Ids and Account.AccountRevenues__c.');
    }
    @isTest
    static void testConvertAccountListIntoSet(){
        // insert some accounts
        List<Account> accountsListToInsertForTest = new List<Account>();
        for(Integer i = 0 ; i < 5 ; i++){
            accountsListToInsertForTest.add(new Account(Name = accountName + i));
        }
        insert accountsListToInsertForTest;
        //get thees accounts for test
        List<Account> accountsListForThisTest = [SELECT Id,
                                                        AccountRevenue__c,
                                                        Name
                                                 FROM Account
                                                 WHERE Name LIKE 'accountName%' ];

        Test.startTest();
        Set<Account> accountSetForTest = AccountDataFactory.convertAccountListIntoSet(accountsListForThisTest);
        Test.stopTest();

        System.assertEquals(accountSetForTest.size(), 5, 'AccountDataFactory.convertAccountListIntoSet should convert a list of 5 into a set of 5.');
    }
}

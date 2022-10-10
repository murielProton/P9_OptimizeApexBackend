/**
 * @description       : 
 * @author            : Muriel Proton
 * @group             : 
 * @last modified on  : 10-10-2022
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
public with sharing class AccountUpdateTrigger_Test {

    static Account getAccount(String accountName){
        Account accountToReturn = [SELECT Id,
                                          AccountRevenue__c
                                    FROM Account
                                    WHERE Name= :accountName 
                                    LIMIT 1];
        return accountToReturn;
    }
    static Decimal getAccountRevenue(Id accountId){
        Account accountToReturn = [SELECT Id,
                                          AccountRevenue__c
                                    FROM Account
                                    WHERE Name= :accountID 
                                    LIMIT 1];
                                    Decimal accountRevenueToReturn = accountToReturn.AccountRevenue__c;
        return accountRevenueToReturn;
    }
    static void createAccount(String accountName){
        List<Account> accountsToInsertForTest = new List<Account>();
        accountsToInsertForTest.add(new Account(Name = accountName));
        insert accountsToInsertForTest;
    }
    static Contract getContract(ID accountId){
        Contract contractToReturn = [SELECT Id
                                     FROM Contract 
                                     WHERE AccountId= :accountId 
                                     LIMIT 1];
        return contractToReturn;
    }
    static void createContract(Account accountForThisTest){
        List<Contract> contractsToInsertForTest = new List<Contract>();
        contractsToInsertForTest.add(new Contract(
            AccountId = accountForThisTest.Id,
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 6
        ));
        insert contractsToInsertForTest;
    }
    static Product2 getProduct2(String productName){
        Product2 product2toReturn = [SELECT Id,
                                            Name,
                                            IsActive
                                     FROM Product2
                                     WHERE Name = :productName
                                     LIMIT 1];
        return product2toReturn;
    }
    static void createProduct2(String productName){
        List<Product2> productsToInsertFortTest = new List<Product2>();
        productsToInsertFortTest.add(new Product2 (
            Name = productName,
            IsActive = true
        ));
        insert productsToInsertFortTest;
    }
    static List<Pricebook2> getPriceBook2List(){
        List<Pricebook2> pricebook2ListToReturn = [SELECT Id,
                                                Name,
                                                IsActive,
                                                IsStandard
                                         FROM PriceBook2
                                         ];
        return pricebook2ListToReturn;
    }
    static Pricebook2 getPriceBook2ByName(String pricebookName){
        Pricebook2 pricebook2 = [SELECT Id,
                                        Name,
                                        isActive,
                                        IsStandard
                                FROM PriceBook2
                                WHERE Name = :pricebookName
                                LIMIT 1];
        return pricebook2;
    }
    static Pricebook2 getPriceBook2Standard(){
        // this doese not work. We can only get the ID of the PriceBook2 Standard == true
        System.debug('Id of standard Pricebook --> ' + Test.getStandardPricebookId());
        System.debug([
            Select Id
            from pricebook2
            where id =: Test.getStandardPricebookId()
        ]);
        Id priceBook2StandardId = Test.getStandardPricebookId();
        Pricebook2 pricebook2ToReturn = [SELECT Id,
                                                Name,
                                                IsActive,
                                                IsStandard
                                         FROM PriceBook2
                                         WHERE Id = :priceBook2StandardId
                                         LIMIT 1];
        return pricebook2ToReturn;
    }

    //If you create a Pricebook it must be active and standard, but the field Standard is not wrightable.
    static void createPricebook2(String pricebook2Name){
        List<PriceBook2> pricebook2ToInsertForTest = new List<PriceBook2>();
        pricebook2ToInsertForTest.add( new PriceBook2 (
            Name = pricebook2Name,
            IsActive = true
        ));
        insert pricebook2ToInsertForTest;
    }
    //TODO: To Depreciate
    static void updatePricebook2(String pricebook2Name){
        PriceBook2 pricebook2ToUpdate = getPriceBook2Standard();
        // if the price book in question is not null nore empty
        if(pricebook2ToUpdate != null && pricebook2ToUpdate.IsActive != true){
            pricebook2ToUpdate.IsActive = true;
        }
        update pricebook2ToUpdate;
    }
    // Product must be active and added to Pricebook first
    static PricebookEntry getPricebookEntry(PriceBook2 pricebookForThisTest,Product2 product2ForThisTest){
        PricebookEntry pricebookEntryToReturn = [SELECT Id,
                                                        Name,
                                                        Pricebook2Id,
                                                        Product2Id,
                                                        UnitPrice,
                                                        UseStandardPrice,
                                                        IsActive
                                                 FROM PricebookEntry
                                                 WHERE Pricebook2Id = :pricebookForThisTest.Id AND Product2Id = :product2ForThisTest.Id
                                                 LIMIT 1];
        return pricebookEntryToReturn;
    }
    //TODO Unbug this methode
    static void createPriceBookEntryForPricebookStandard(Product2 product2ForThisTest){
        PricebookEntry priceBookEntryToInsert = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product2ForThisTest.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert priceBookEntryToInsert;
    }
    static void createPriceBookEntry(PriceBook2 pricebookForThisTest, Product2 product2ForThisTest){
        PricebookEntry priceBookEntryToInsert = new PricebookEntry(
            Pricebook2Id = pricebookForThisTest.Id,
            Product2Id = product2ForThisTest.Id,
            UnitPrice = 100.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert priceBookEntryToInsert;
    }
    static Order getOrder(Account accountForThisTest, Contract contractForThisTest){
        Order orderToReturn = [SELECT Id, AccountId, TotalAmount
                               FROM Order
                               WHERE AccountId = :accountForThisTest.Id AND ContractId = :contractForThisTest.Id
                               LIMIT 1];
        return orderToReturn;
    }
    static List<Order> getOrdersListToLinkWithOrderItem(Account accountForThisTest, Contract contractForThisTest, PriceBook2 pricebookForThisTest ){
        List<Order> listOfOrdersToReturn = [SELECT Id, AccountId, TotalAmount
                                            FROM Order
                                            WHERE AccountId = :accountForThisTest.Id AND ContractId = :contractForThisTest.Id
                                            AND Pricebook2Id = :pricebookForThisTest.Id
                                            ];
        return listOfOrdersToReturn;
    }
    public static Order constructOneOrder(String orderName, Account accountForThisTest, Contract contractForThisTest, PriceBook2 pricebookForThisTest){
        Order orderConstructed = new Order(
            Name = orderName,
            AccountId = accountForThisTest.Id,
            ContractId = contractForThisTest.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            ShipmentCost__c = 10,
            // essential for the creation of OrderItem
            Pricebook2Id =  pricebookForThisTest.Id
            //TotalAmount = not writable This is Why Order links to a Product2 with OrderItem
        );
        return orderConstructed;
    }
    // TODO get Account.AccountRevenue__c in a Map<Order.ID, AccountRevenue> from list of orders
    /*public static Map<Id, Decimal> getAccountRevenuesForEachOrders(List<Order> listOfOrdersToLink){
        Map<Id, Decimal> mapOfOrdersIDAndAccountRevenues = new Map<Id, Decimal>();
        for (Order thisOrder : listOfOrdersToLink){
            getAccountRevenue(thisOrder.AccountId);
            mapOfOrdersIDAndAccountRevenues.put(thisOrder.Id, thisAccountRevenue);
        }

        return mapOfOrdersIDAndAccountRevenues;
    }*/
    // TODO
    public static void updateOrder(Order orderToUpdate){
        orderToUpdate.ShipmentCost__c = 20;
        update orderToUpdate;
    }
    public static List<OrderItem> getOrderItemList(Product2 product2ForThisTest, PricebookEntry pricebookEntryForThisTest){
        List<OrderItem> listOfOrderItemsToReturn = [SELECT Id
                                                    FROM OrderItem
                                                    WHERE Product2Id = :product2ForThisTest.id AND PricebookEntryId = :pricebookEntryForThisTest.id
                                                   ];
        return listOfOrderItemsToReturn;
    }
    public static OrderItem constructOneOrderItem(Order orderForThisTest, Product2 product2ForThisTest, PricebookEntry pricebookEntryForThisTest){
        OrderItem orderItemToInsert = new OrderItem(
            OrderId = orderForThisTest.id,
            Quantity = 24,
            UnitPrice = 240,
            Product2Id = product2ForThisTest.id,
            PricebookEntryId = pricebookEntryForThisTest.id
        );
        return orderItemToInsert;
    }
    
    static void createOrderItemList(Product2 product2ForThisTest, PricebookEntry pricebookEntryForThisTest, List<Order> listOfOrdersToLink){
        List<OrderItem> listOfOrderItems = new List<OrderItem>();
        Integer numberOfOrders = listOfOrdersToLink.size();

        for(Integer i = 0 ; i < numberOfOrders ; i++){
            listOfOrderItems.add(new OrderItem(
                OrderId = listOfOrdersToLink[i].id,
                Quantity = numberOfOrders,
                UnitPrice = i*10,
                Product2Id = product2ForThisTest.id,
                PricebookEntryId = pricebookEntryForThisTest.id
            ));
        }
        insert listOfOrderItems;
    }
    // init class variables
    private static String accountName = 'Yukako';
    private static String productName = 'Kinu';
    private static String pricebook2Name = 'Yukako\'s Price Book';
    private static String orderName = 'Yukako\'s Order';
    @TestSetup
    static void setupForTestAccountUpdateTrigger(){
        //Ceate an Account
        createAccount(accountName);
        Account accountForThisTest = getAccount(accountName);
        //create a Contract for this Account
        createContract(accountForThisTest);
        // Make sure the Pricebook2 entry is active and standard
        createPricebook2(pricebook2Name);
        // to create a Pricebook2 field Standard = true the price book needs to be linked to a Product2
        // Create Product2
        createProduct2(productName);
        // Now make sure the Salesforce process doese create a standard Pricebook2
        Pricebook2 pricebookForThisTest = getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = getProduct2(productName);
        // Process needs an entry in th Pricebook2 Standard = true, first ;
        createPriceBookEntryForPricebookStandard(product2ForThisTest);
        // then PricebookEntry for normal Pricebook2 can be inserted.
        createPriceBookEntry(pricebookForThisTest, product2ForThisTest);
        // get contract
        Contract contractForThisTest = getContract(accountForThisTest.Id);
        Account accountForThisTest1 = getAccount(accountName);
        //Create Order
        Order orderForThisTest = constructOneOrder(orderName, accountForThisTest1, contractForThisTest, pricebookForThisTest);
        insert orderForThisTest;
        // Create OrderItem
        PricebookEntry pricebookEntryForThisTest = getPricebookEntry(pricebookForThisTest, product2ForThisTest);
        OrderItem constructedOrderItem = constructOneOrderItem(orderForThisTest, product2ForThisTest, pricebookEntryForThisTest);
        insert constructedOrderItem;
        
    }
    @isTest
    static void testAccountUpdateTrigger(){
        //init Test
        Account accountForThisTest = getAccount(accountName);
        Contract contractForThisTest = getContract(accountForThisTest.Id);
        // get the field to test before update
        Decimal accountRevenueBeforeUpdate = accountForThisTest.AccountRevenue__c;

        //get the order for the test
        Order orderForTheTest = getOrder(accountForThisTest, contractForThisTest);

        // Update Order
        Test.startTest();
        updateOrder(orderForTheTest);
        Test.stopTest();

        // get the field to test aftier update
        Decimal accountRevenueAfterUpdate = getAccount(accountName).AccountRevenue__c;

        // test if the two values are different
        Boolean isAccountRevenueChanged = accountRevenueBeforeUpdate != accountRevenueAfterUpdate;     
        System.assertEquals(isAccountRevenueChanged, true, 'After updating Order, the field AccountRevenue on Account should Change.');
    }
}
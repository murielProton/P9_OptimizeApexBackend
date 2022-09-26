/**
 * @description       : 
 * @author            : Muriel Proton
 * @group             : 
 * @last modified on  : 09-26-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
/* Some informations on the correct way to juggle between Product2, Pricebook2 and PricebookEntry
STANDARD_PRICE_NOT_DEFINED, Before creating a custom price, create a standard price.:
First a new product needs to be added to the standard PricebookEntry
Then it needs to be added to a custom Pricebook.
To avoid all this tantrum lets not use custom Pricebook. And asume there will be a standard one in all instance of Organasation.
*/
@isTest
public with sharing class AccountUpdateTrigger_Test {
    
    @TestSetup
    static void setupForTestAccountUpdateTrigger(){
        //Ceate an Account
        String accountName = 'Yukako';
        String productName = 'Kinu';
        String pricebook2Name = 'Yukako\'s Price Book';
        createAccount(accountName);
        //create a Contract for this Account
        createContract(accountName);
        // Create Product2 that is linked to PricebookEntry
        createProduct2(String productName);
        // Make sure the pricebook2 entry is active
        updatePricebook2(pricebook2Name);
        // Create PricebookEntry and link it to PriceBook2 and Product2
        PriceBook2 pricebookForThisTest = getPriceBook2Standard();
        Product2 product2ForThisTest = getProduct2(productName);
        createPriceBookEntry(productName, pricebookForThisTest, product2ForThisTest);
        PricebookEntry pricebookEntryForThisTest = getPricebookEntry(productName, pricebookForThisTest,product2ForThisTest);
        Account accountForThisTest = getAccount(accountName);
        Contract contractForThisTest = getContract(accountForThisTest.Id);
        //Create a bunch of Orders on this Account
        createListOfOrders(accountForThisTest, contractForThisTest, pricebookForThisTest);
        // get the list of Orders to Link to a Price with OrderItem
        List<Order> listOfOrdersToLink = getOrdersListToLinkWithOrderItem(accountForThisTest, contractForThisTest, pricebookForThisTest );
        // link the list of Orders with OrderItem to a Price

        //TODO Update the bunch of Orders
        //TODO Check tha the old Account.AccountRevenue__c is different from the new one
    }
    static Account getAccount(String accountName){
        Account accountToReturn = [SELECT Id,
                                          AccountRevenue__c
                                    FROM Account
                                    WHERE Name= :accountName 
                                    LIMIT 1];
        return accountToReturn;
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
            AccountId = accountForThisContract.Id,
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
    static Pricebook2 getPriceBook2Standard(){
        Pricebook2 pricebook2ToReturn = [SELECT Id,
                                                Name,
                                                IsActive
                                         FROM PriceBook2
                                         WHERE isStandard = true
                                         LIMIT 1];
        return pricebook2ToReturn;
    }
    //If you create a Pricebook it must be active
    static void createPricebook2(String pricebook2Name){
        List<PriceBook2> pricebook2ToInsertForTest = new List<PriceBook2>();
        pricebook2ToInsertForTest.add( new PriceBook2 (
            Name = pricebook2Name,
            IsActive = true
        ));
        insert pricebook2ToInsertForTest;
    }
    static void updatePricebook2(String pricebook2Name){
        PriceBook2 pricebook2ToUpdate = getPriceBook2(pricebook2Name);
        // if the price book in question is not null nore empty
        if(pricebook2ToUpdate != null && pricebook2ToUpdate.IsActive != true){
            pricebook2ToUpdate.IsActive = true;
        }
        update pricebook2ToInsertForTest;
    }
    // Product must be active and added to Pricebook first
    static PricebookEntry getPricebookEntry(String productName, PriceBook2 pricebookForThisTest,Product2 product2ForThisTest){
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
    static void createPriceBookEntry(String productName, PriceBook2 pricebookForThisTest, Product2 product2ForThisTest){
        PricebookEntry priceBookEntryToInsert = new PricebookEntry(
            Pricebook2Id = pricebookForThisTest.Id,
            Product2Id = product2ForThisTest.Id,
            UnitPrice = 100.00,
            UseStandardPrice = false,
            IsActive = true
        );
        insert priceBookEntryToInsert;
    }
    static Order getOrder(Account accountForThisTest, Contract contractForThisTest){
        Order orderToReturn = [SELECT Id
                               FROM Order
                               WHERE AccountId = :accountForThisTest.Id AND ContractId = :contractForThisTest.Id
                               LIMIT 1];
        return orderToReturn;
    }
    static List<Order> getOrdersListToLinkWithOrderItem(Account accountForThisTest, Contract contractForThisTest, PriceBook2 pricebookForThisTest ){
        List<Order> listOfOrdersToReturn = [SELECT Id
                                            FROM Order
                                            WHERE AccountId = :accountForThisTest.Id AND ContractId = :contractForThisTest.Id
                                            AND Pricebook2Id = :pricebookForThisTest.Id
                                            ];
        return listOfOrdersToReturn;
    }
    public static void createListOfOrders(Account accountForThisTest, Contract contractForThisTest, PriceBook2 pricebookForThisTest){
        List<Order> ordersToInsertForTest = new List<Order>();
        //put it into a for i loop
        for(Integer i=0 ; i<500 ; i++){
            Double shipmentCost = i*2;
            ordersToInsertForTest.add(new Order(
                AccountId = accountForThisTest.Id,
                ContractId = contractForThisTest.Id,
                Status = 'Draft',
                EffectiveDate = Date.today(),
                ShipmentCost__c = shipmentCost,
                // essential for the creation of OrderItem
                Pricebook2Id =  pricebookForThisTest.Id
                //TotalAmount = not writable This is Why Order links to a Product2 with OrderItem
            ));
        }
        insert ordersToInsertForTest;
    }
    static void constructOneOrderItem(Order orderForThisTest, Product2 product2ForThisTest, PricebookEntry pricebookEntryForThisTest){
        //TODO put it into a for each loop
        OrderItem orderItemToInsert = new OrderItem(
            OrderId = orderForThisTest.id,
            Quantity = 24,
            UnitPrice = 240,
            Product2Id = product2ForThisTest.id,
            PricebookEntryId = pricebookEntryForThisTest.id
        );
        
    }
    /*J'en suis là
    static void createOrderItemList(Order orderForThisTest, Product2 product2ForThisTest, PricebookEntry pricebookEntryForThisTest, List<Order> listOfOrdersToLink){
        List<OrderItem> listOfOrderItems = new List<OrderItem>();
        Integer quantity = 0;
        Integer price = 0;
        Integer i = 1;
        for(Order currentOrder : listOfOrdersToLink){
            Integer i = 1;
            listOfOrderItems.add(new OrderItem(
                OrderId = orderForThisTest.id,
                Quantity = quantity+1,
                UnitPrice = 240,
                Product2Id = product2ForThisTest.id,
                PricebookEntryId = pricebookEntryForThisTest.id
            ));
        }
        insert listOfOrderItems;
    }*/
}

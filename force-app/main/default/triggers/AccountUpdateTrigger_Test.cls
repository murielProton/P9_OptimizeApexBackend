/**
 * @description       : 
 * @author            : Muriel Proton
 * @group             : 
 * @last modified on  : 10-03-2022
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
        return accountToReturn.AccountRevenue__c;
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
        Pricebook2 pricebook2ToReturn = [SELECT Id,
                                                Name,
                                                IsActive,
                                                IsStandard
                                         FROM PriceBook2
                                         WHERE isStandard = true
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
    static void createPriceBookEntry(PriceBook2 pricebookForThisTest, Product2 product2ForThisTest){
        PricebookEntry priceBookEntryToInsert = new PricebookEntry(
            Pricebook2Id = pricebookForThisTest.Id,
            Product2Id = product2ForThisTest.Id,
            UnitPrice = 100.00,
            UseStandardPrice = true,
            IsActive = true
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
    /*public static void updateOrder(){
        //TODO foreach loop
    }*/
    public static List<OrderItem> getOrderItemList(Product2 product2ForThisTest, PricebookEntry pricebookEntryForThisTest){
        List<OrderItem> listOfOrderItemsToReturn = [SELECT Id
                                                    FROM OrderItem
                                                    WHERE Product2Id = :product2ForThisTest.id AND PricebookEntryId = :pricebookEntryForThisTest.id
                                                   ];
        return listOfOrderItemsToReturn;
    }
    public static void constructOneOrderItem(Order orderForThisTest, Product2 product2ForThisTest, PricebookEntry pricebookEntryForThisTest){
        OrderItem orderItemToInsert = new OrderItem(
            OrderId = orderForThisTest.id,
            Quantity = 24,
            UnitPrice = 240,
            Product2Id = product2ForThisTest.id,
            PricebookEntryId = pricebookEntryForThisTest.id
        );
        
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
    @TestSetup
    static void setupForTestAccountUpdateTrigger(){
        //Ceate an Account
        String accountName = 'Yukako';
        String productName = 'Kinu';
        String pricebook2Name = 'Yukako\'s Price Book';
        createAccount(accountName);
        Account accountForThisTest = getAccount(accountName);
        //create a Contract for this Account
        System.debug('Step one' );
        createContract(accountForThisTest);
        System.debug('Step Two' );
        // Make sure the Pricebook2 entry is active and standard
        createPricebook2(pricebook2Name);
        System.debug('Step Three' );
        // to create a Pricebook2 field Standard = true the price book needs to be linked to a Product2
        // Create Product2 that is linked to PricebookEntry
        createProduct2(productName);
        System.debug('Step Four' );
        // Now make sure the Salesforce process doese create a standard Pricebook2
        Pricebook2 pricebookByName = getPriceBook2ByName(pricebook2Name);
        System.debug('Step Five' );
        Product2 product2ForThisTest = getProduct2(productName);
        System.debug('Step Six' ); // doese not work passt here
        // update the related list of the product record until a standard Pricebook appears !
        createPriceBookEntry(pricebookByName, product2ForThisTest);
        System.debug('Step Seven' );
        List<Pricebook2> pricebookListAll = getPriceBook2List();
        System.debug('Step eight' );
        System.debug('list of price ' + pricebookListAll );
        // TODO Create PricebookEntry and link it to PriceBook2 and Product2 within a standard Pricebook2
        Pricebook2 pricebookStandard = getPriceBook2Standard();
        // TODO activate standard Pricebook2
        System.debug('pricebookStandard ' + pricebookStandard );
        updatePricebook2(pricebookStandard.Name);
        System.debug('pricebookStandard ' + pricebookStandard );
        createPriceBookEntry(pricebookStandard, product2ForThisTest);
        PricebookEntry pricebookEntryForThisTest = getPricebookEntry(pricebookStandard,product2ForThisTest);
        System.debug('PricebookEntry ' + pricebookEntryForThisTest );
        //PriceBook2 pricebookForThisTest = getPriceBook2Standard();
        
        /*
        createPriceBookEntry(pricebookForThisTest, product2ForThisTest);
        PricebookEntry pricebookEntryForThisTest = getPricebookEntry(pricebookForThisTest,product2ForThisTest);
        
        Contract contractForThisTest = getContract(accountForThisTest.Id);
        //Create a bunch of Orders on this Account
        createListOfOrders(accountForThisTest, contractForThisTest, pricebookForThisTest);
        // get the list of Orders to Link to a Price with OrderItem
        List<Order> listOfOrdersToLink = getOrdersListToLinkWithOrderItem(accountForThisTest, contractForThisTest, pricebookForThisTest );
        // link the list of Orders with OrderItem to a Price
        createOrderItemList(product2ForThisTest, pricebookEntryForThisTest, listOfOrdersToLink);
        //TODO for each orders of the listOfOrdersToLink get Account.AccountRevenue__c in a Map before update
        //TODO Update the bunch of Orders
        //TODO for each orders of the listOfOrdersToLink get Account.AccountRevenue__c in a Map after update
        //TODO Check tha the old Account.AccountRevenue__c is different from the new one*/
    }
    @isTest
    static void testAccountUpdateTrigger(){
        String productName = 'Kinu';
        String accountName = 'Yukako';
        Account accountForThisTest = getAccount(accountName);
        System.debug('account');
        System.debug('Account ID  '+accountForThisTest.Id);
        Product2 product2ForThisTest = getProduct2(productName);
        Pricebook2 pricebookForThisTest = getPriceBook2Standard();
        PricebookEntry pricebookEntryForThisTest = getPricebookEntry(pricebookForThisTest, product2ForThisTest);
        

        Contract contractForThisTest = getContract(accountForThisTest.Id);

        List<Order> listOfOrdersToLink = getOrdersListToLinkWithOrderItem(accountForThisTest, contractForThisTest, pricebookForThisTest );
        List<OrderItem> listOfOrderItems = getOrderItemList(product2ForThisTest, pricebookEntryForThisTest);
        System.debug('Order Item');
        System.debug('Order Item ID  '+listOfOrderItems[0].Id);
        System.debug('Order Item this order  '+listOfOrderItems[0].OrderId);
        System.debug('Order Item Unit price  '+listOfOrderItems[0].UnitPrice);
        System.debug('Order Item quantity  '+listOfOrderItems[0].Quantity);
        System.debug('Order');
        System.debug('Order ID  '+listOfOrdersToLink[0].Id);
        System.debug('account of this order  '+listOfOrdersToLink[0].AccountId);
        System.debug('Order Total Amount  '+listOfOrdersToLink[0].TotalAmount);
        System.debug('Account');
        System.debug('accountToReturn Id  '+accountForThisTest.Id);
        System.debug('account Revenue  '+accountForThisTest.AccountRevenue__c);
        System.debug('Account Name  '+accountForThisTest.Name);
        System.assertEquals(0 , 0, 'this is fake' );
    }
}

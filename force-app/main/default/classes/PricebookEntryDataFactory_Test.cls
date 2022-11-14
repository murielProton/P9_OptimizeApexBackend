/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class PricebookEntryDataFactory_Test {
    // init class variables
    private static String accountName = 'Yukako';
    private static String productName = 'Kinu';
    private static String pricebook2Name = 'Yukako\'s Price Book';

   @TestSetup
    static void setupForPricebookEntry_TestDataFactory_Test(){
        //Create an Account
        AccountDataFactory.createAccount(accountName);
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        //create a Contract for this Account
        ContractDataFactory.createContract(accountForThisTest);
        // Make sure the Pricebook2 entry is active and standard
        Pricebook2DataFactory.createPricebook2(pricebook2Name);
        // to create a Pricebook2 field Standard = true the price book needs to be linked to a Product2
        // Create Product2
        Product2DataFactory.createProduct2(productName);
        // Now make sure the Salesforce process doese create a standard Pricebook2
        Pricebook2 pricebookForThisTest = Pricebook2DataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2DataFactory.getProduct2(productName);
        
    }
    @isTest
    static void testGetPricebookEntry(){
        //gest sObjects for the Test
        Pricebook2 pricebookForThisTest = Pricebook2DataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2DataFactory.getProduct2(productName);
        PricebookEntry priceBookEntryToInsert1 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product2ForThisTest.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert priceBookEntryToInsert1;
        PricebookEntry priceBookEntryToInsert2 = new PricebookEntry(
            Pricebook2Id = pricebookForThisTest.Id,
            Product2Id = product2ForThisTest.Id,
            UnitPrice = 100.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert priceBookEntryToInsert2;
        Test.startTest();
        PricebookEntry pricebookEntryForThisTest = PricebookEntryDataFactory.getPricebookEntry(pricebookForThisTest, product2ForThisTest);
        Test.stopTest();
        System.assertEquals(pricebookEntryForThisTest.UnitPrice, 100.00, 'PricebookEntryDataFactory.getPricebookEntry should return a PricebookEntry.');

    }
    @isTest
    static void testGetPricebookEntryAll(){
        //gest sObjects for the Test
        Pricebook2 pricebookForThisTest = Pricebook2DataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2DataFactory.getProduct2(productName);
        PricebookEntry priceBookEntryToInsert1 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product2ForThisTest.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert priceBookEntryToInsert1;
        PricebookEntry priceBookEntryToInsert2 = new PricebookEntry(
            Pricebook2Id = pricebookForThisTest.Id,
            Product2Id = product2ForThisTest.Id,
            UnitPrice = 100.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert priceBookEntryToInsert2;
        Test.startTest();
        List<PricebookEntry> pricebookEntryListForThisTest = PricebookEntryDataFactory.getPricebookEntryAll();
        Test.stopTest();
        System.assertEquals(pricebookEntryListForThisTest.size(), 2, 'PricebookEntryDataFactory.getPricebookEntryAll should return 2 records of PricebookEntry.');

    }

    @isTest
    static void testCreatePriceBookEntryForPricebookStandard(){
        //gest sObjects for the Test
        Pricebook2 pricebookForThisTest = Pricebook2DataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2DataFactory.getProduct2(productName);

        Test.startTest();
        PricebookEntryDataFactory.createPriceBookEntryForPricebookStandard(product2ForThisTest);
        Test.stopTest();
        PricebookEntry pricebookEntryForThisTest = [SELECT Id,
                                                            Name,
                                                            Pricebook2Id,
                                                            Product2Id,
                                                            UnitPrice,
                                                            UseStandardPrice,
                                                            IsActive
                                                    FROM PricebookEntry
                                                    WHERE Product2Id = :product2ForThisTest.Id
                                                    LIMIT 1];
                                                    
        // Test.getStandardPricebookId() is the only way to get trace of a Standard Pricebook entry in a test environnement.
        System.assertEquals(pricebookEntryForThisTest.Pricebook2Id, Test.getStandardPricebookId(), 'PricebookEntryDataFactory.createPriceBookEntryForPricebookStandard should insert a Standard PricebookEntry.');
    }

    @isTest
    static void testCreatePricebookEntry(){
        //gest sObjects for the Test
        Pricebook2 pricebookForThisTest = Pricebook2DataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2DataFactory.getProduct2(productName);

        //before inserting a custom Pricebook Entry, we need a Sandard Pricebook Entry
        PricebookEntry priceBookEntryToInsert = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product2ForThisTest.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert priceBookEntryToInsert;

        Test.startTest();
        PricebookEntryDataFactory.createPriceBookEntry(pricebookForThisTest, product2ForThisTest);
        Test.stopTest();

        PricebookEntry pricebookEntryForThisTest = [SELECT Id,
                                                        Name,
                                                        Pricebook2Id,
                                                        Product2Id,
                                                        UnitPrice,
                                                        UseStandardPrice,
                                                        IsActive
                                                FROM PricebookEntry
                                                WHERE Pricebook2Id = :pricebookForThisTest.Id AND Product2Id = :product2ForThisTest.Id
                                                LIMIT 1];

        System.assertEquals(pricebookEntryForThisTest.UnitPrice, 100.00, 'PricebookEntryDataFactory.createPriceBookEntry should insert a PricebookEntry.');

    }
    
    @isTest
    static void testUpdatePriceBookEntryList(){
        //gest sObjects for the Test
        Pricebook2 pricebookForThisTest = Pricebook2DataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2DataFactory.getProduct2(productName);
        PricebookEntry priceBookEntryToInsert1 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product2ForThisTest.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert priceBookEntryToInsert1;
        PricebookEntry priceBookEntryToInsert2 = new PricebookEntry(
            Pricebook2Id = pricebookForThisTest.Id,
            Product2Id = product2ForThisTest.Id,
            UnitPrice = 100.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert priceBookEntryToInsert2;
        List<PricebookEntry> pricebookEntryListBeforeUpdate = PricebookEntryDataFactory.getPricebookEntryAll();
        Test.startTest();
        PricebookEntryDataFactory.updadePriceBookEntryList(pricebookEntryListBeforeUpdate);
        Test.stopTest();

        List<PricebookEntry> pricebookEntryListForThisTest = PricebookEntryDataFactory.getPricebookEntryAll();

        System.assertEquals(pricebookEntryListForThisTest[0].UnitPrice, 300, 'PricebookEntryDataFactory.updadePriceBookEntryList should update a List of PricebookEntries.');

    }
}

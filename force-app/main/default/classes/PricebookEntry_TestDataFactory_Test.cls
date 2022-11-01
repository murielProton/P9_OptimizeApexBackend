/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-01-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class PricebookEntry_TestDataFactory_Test {
    // init class variables
    private static String accountName = 'Yukako';
    private static String productName = 'Kinu';
    private static String pricebook2Name = 'Yukako\'s Price Book';

   @TestSetup
    static void setupForPricebookEntry_TestDataFactory_Test(){
        //Create an Account
        Account_TestDataFactory.createAccount(accountName);
        Account accountForThisTest = Account_TestDataFactory.getAccount(accountName);
        //create a Contract for this Account
        Contract_TestDataFactory.createContract(accountForThisTest);
        // Make sure the Pricebook2 entry is active and standard
        Pricebook2_TestDataFactory.createPricebook2(pricebook2Name);
        // to create a Pricebook2 field Standard = true the price book needs to be linked to a Product2
        // Create Product2
        Product2_TestDataFactory.createProduct2(productName);
        // Now make sure the Salesforce process doese create a standard Pricebook2
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2_TestDataFactory.getProduct2(productName);
        
    }
    @isTest
    static void testGetPricebookEntry(){
        //gest sObjects for the Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2_TestDataFactory.getProduct2(productName);
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
        PricebookEntry pricebookEntryForThisTest = PricebookEntry_TestDataFactory.getPricebookEntry(pricebookForThisTest, product2ForThisTest);
        Test.stopTest();
        System.assertEquals(pricebookEntryForThisTest.UnitPrice, 100.00, 'PricebookEntry_TestDataFactory.getPricebookEntry should return a PricebookEntry.');

    }
    @isTest
    static void testGetPricebookEntryAll(){
        //gest sObjects for the Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2_TestDataFactory.getProduct2(productName);
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
        List<PricebookEntry> pricebookEntryListForThisTest = PricebookEntry_TestDataFactory.getPricebookEntryAll();
        Test.stopTest();
        System.assertEquals(pricebookEntryListForThisTest.size(), 2, 'PricebookEntry_TestDataFactory.getPricebookEntryAll should return 2 records of PricebookEntry.');

    }
    @isTest
    static void testGetPricebookEntryModifiedDdate(){
        //gest sObjects for the Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2_TestDataFactory.getProduct2(productName);
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
        List<PricebookEntry> listOfDateTimes = PricebookEntry_TestDataFactory.getPricebookEntryListLastModifiedDdate();
        Test.stopTest();
        Date dateFromPricebookEntry = listOfDateTimes[0].LastModifiedDate.date();
        Date dateExpected = Date.today();
        System.assertEquals(dateFromPricebookEntry, dateExpected, 'PricebookEntry_TestDataFactory.getPricebookEntryModifiedDdate should return a list of DateTime, when the PricebookEntry was last modified.');

    }
    @isTest
    static void testCreatePriceBookEntryForPricebookStandard(){
        //gest sObjects for the Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2_TestDataFactory.getProduct2(productName);

        Test.startTest();
        PricebookEntry_TestDataFactory.createPriceBookEntryForPricebookStandard(product2ForThisTest);
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
        System.assertEquals(pricebookEntryForThisTest.Pricebook2Id, Test.getStandardPricebookId(), 'PricebookEntry_TestDataFactory.createPriceBookEntryForPricebookStandard should insert a Standard PricebookEntry.');
    }

    @isTest
    static void testCreatePricebookEntry(){
        //gest sObjects for the Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2_TestDataFactory.getProduct2(productName);

        //before inserting a custom Pricebook Entry, we need a Sandard Pricebook Entry
        PricebookEntry priceBookEntryToInsert = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product2ForThisTest.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert priceBookEntryToInsert;

        Test.startTest();
        PricebookEntry_TestDataFactory.createPriceBookEntry(pricebookForThisTest, product2ForThisTest);
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

        System.assertEquals(pricebookEntryForThisTest.UnitPrice, 100.00, 'PricebookEntry_TestDataFactory.createPriceBookEntry should insert a PricebookEntry.');

    }
    
    @isTest
    static void testUpdatePriceBookEntryList(){
        //gest sObjects for the Test
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2_TestDataFactory.getProduct2(productName);
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
        List<PricebookEntry> pricebookEntryListBeforeUpdate = PricebookEntry_TestDataFactory.getPricebookEntryAll();
        Test.startTest();
        PricebookEntry_TestDataFactory.updadePriceBookEntryList(pricebookEntryListBeforeUpdate);
        Test.stopTest();

        List<PricebookEntry> pricebookEntryListForThisTest = PricebookEntry_TestDataFactory.getPricebookEntryAll();

        System.assertEquals(pricebookEntryListForThisTest[0].UnitPrice, 300, 'PricebookEntry_TestDataFactory.updadePriceBookEntryList should update a List of PricebookEntries.');

    }
}

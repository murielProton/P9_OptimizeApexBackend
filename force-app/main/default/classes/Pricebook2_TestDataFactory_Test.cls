/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-01-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class Pricebook2_TestDataFactory_Test {
    private static String pricebook2Name = 'Yukako\'s Price Book';
    @isTest
    static void testGetPriceBook2ByName(){
        List<PriceBook2> pricebook2ToInsertForTest = new List<PriceBook2>();
            pricebook2ToInsertForTest.add( new PriceBook2 (
                Name = pricebook2Name,
                IsActive = true
            ));
        insert pricebook2ToInsertForTest;

        Test.startTest();
        PriceBook2 pricebook2ToTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Test.stopTest();

        System.assertEquals(pricebook2ToTest.IsActive, true, 'Pricebook2_TestDataFactory.getPriceBook2ByName should return one PriceBook2.');
    }
    @isTest
    static void testGetPriceBook2All(){
        // Create 50 PriceBook2
        List<PriceBook2> pricebook2ToInsertForTest = new List<PriceBook2>();
        for(Integer i=0 ; i<50 ; i++){
            pricebook2ToInsertForTest.add( new PriceBook2 (
                Name = pricebook2Name+i,
                IsActive = true
            ));
        }
        insert pricebook2ToInsertForTest;

        Test.startTest();
        List<PriceBook2> pricebook2ListToTest = Pricebook2_TestDataFactory.getPriceBook2All();
        Test.stopTest();

        System.assertEquals(pricebook2ListToTest.size(), 50, 'Pricebook2_TestDataFactory.getPriceBook2All should return 50 PriceBook2 records.');
    }
    @isTest
    static void testGetPriceBook2ListWherePricebookEntryLastModifiedDate(){
        String productName = 'Momen';
        // Create a bunch of Accounts
        Account_TestDataFactory.createAccountsList(100);
        List<Account> accountList1ToCompare = Account_TestDataFactory.getAccountsAll();
        Set<Account> accountSet1ToCompare = Account_TestDataFactory.convertAccountListIntoSet(accountList1ToCompare);
        // The Order must have at least one Product, so we can change Order.Status to Ordered
        // Link these accounts to some products = for each accounts create a contract + create pricebook custom + create pricebook standard + create products + create price book entry + create order
        // for each accounts create a contract 
        Contract_TestDataFactory.createContractsList(accountList1ToCompare);
        // for the test to succeed the Contract Status should be Activated, but it can't be inserted as such, so we need to update it
        List<Contract> contractsListToUpdate = Contract_TestDataFactory.getContractsAll();
        Contract_TestDataFactory.updateContractsListStatusToActivated(contractsListToUpdate);
        Pricebook2_TestDataFactory.createPricebook2(pricebook2Name);
        // to create a Pricebook2 field Standard = true the price book needs to be linked to a Product2
        // Create Product2
        Product2_TestDataFactory.createProduct2(productName);
        // Now make sure the Salesforce process doese create a standard Pricebook2
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Product2 product2ForThisTest = Product2_TestDataFactory.getProduct2(productName);
        // Process needs an entry in th Pricebook2 Standard = true, first ;
        PricebookEntry_TestDataFactory.createPriceBookEntryForPricebookStandard(product2ForThisTest);
        // then PricebookEntry for normal Pricebook2 can be inserted.
        PricebookEntry_TestDataFactory.createPriceBookEntry(pricebookForThisTest, product2ForThisTest);

        Test.startTest();
        List<Pricebook2> pricebook2ListToTest = Pricebook2_TestDataFactory.getPriceBook2ListWherePricebookEntryLastModifiedDate();
        Test.stopTest();

        System.assertEquals(pricebook2ListToTest.size(), 1, 'Pricebook2_TestDataFactory.getPriceBook2ListWherePricebookEntryLastModifiedDate should return a list of PriceBook2 Linked to PriceBookEntry where LastModifiedDate > 1 week.');
    }

    @isTest
    static void testCreatePricebook2(){
        Test.startTest();
        Pricebook2_TestDataFactory.CreatePricebook2(pricebook2Name); 
        Test.stopTest();

        Pricebook2 pricebook2ToTest = [SELECT Id,
                                        Name,
                                        isActive,
                                        IsStandard
                                FROM PriceBook2
                                WHERE Name = :pricebook2Name
                                LIMIT 1];

        System.assertEquals(pricebook2ToTest.IsActive, true, 'Pricebook2_TestDataFactory.CreatePricebook2 should create one PriceBook2.');

    }
}

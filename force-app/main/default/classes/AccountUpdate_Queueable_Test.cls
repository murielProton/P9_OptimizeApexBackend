/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-29-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
//TODO
        // First Batch 
        // create some Accounts
        // map 1 = get AccountRevenue__c of all the created Accounts
        // update the price of the products by updating pricebookEntry
        // Trigger batch here
        // map 2 = get AccountRevenue__c of all the created Accounts
        // compare the two maps
        //--
        // Second Batch
        // List of Accounts to Update if the order attached to It, passes from state draft to state Ordered.
        // update evry Account field Total Revenue
        //SELECT Id FROM Account
        // order [SELECT Id, TotalAmount, AccountId FROM Order];
        //Create a list of Accounts
@isTest
public with sharing class AccountUpdate_Queueable_Test {
    //set variables for test
    private static String nameLike = 'accountName-%';
    private static String pricebook2Name = 'pricebookName';
    private static String productName = 'Momen';

    @TestSetup
    static void setupForAccountUpdate_Queueable_Test(){
        // create some Accounts
        Account_TestDataFactory.createAccountsList(5);
        List<Account> accountsListToTest = [SELECT Id,
                                                    AccountRevenue__c,
                                                    Name
                                            FROM Account
                                            WHERE Name LIKE :nameLike
                                           ];
        // Link these accounts to some products = for each accounts create a contract + create pricebook custom + create pricebook standard + create products + create price book entry + create order
        // for each accounts create a contract 
        Contract_TestDataFactory.createContractsList(accountsListToTest);
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
        // get contracts List we just inserted
        List<Contract> contractsListForTest = Contract_TestDataFactory.getContractsAll();
        //Create Order for eache Contracts
        Order_TestDataFactory.createOrdersListForEachContract(contractsListForTest, pricebookForThisTest);
       
    }
    @isTest
    static void testBatchWhenProductsAreUpdatedIsTheAccountRevenueUpdated(){
        List<Account> accountListBeforeUpdate = [SELECT Id,
                                                        AccountRevenue__c,
                                                        Name
                                                FROM Account
                                                WHERE Name LIKE :nameLike
                                                ];
        // map 1 = get AccountRevenue__c of all the created Accounts
        Map<Id,Decimal> accountMapIDAndAccountRevenue1 = Account_TestDataFactory.convertAccountsListIntoMapOfIdsAndRevenues(accountListBeforeUpdate);
        Product2 product2ToUpdate = Product2_TestDataFactory.getProduct2(productName);
        List<PricebookEntry> priceBookEntryListToUpdate = PricebookEntry_TestDataFactory.getPricebookEntryAll();
        // Update Price of the product2 price by updating Pricebook2 entries
        PricebookEntry_TestDataFactory.updadePriceBookEntryList(priceBookEntryListToUpdate);
        Test.startTest();
        //Trigger Batch Here ! 
        //TODO replace folowing line by a call to batch
        Test.stopTest();
        // map 2 = get AccountRevenue__c of all the created Accounts
        List<Account> accountListAfterUpdate = [SELECT Id,
                                                        AccountRevenue__c,
                                                        Name
                                                FROM Account
                                                WHERE Name LIKE :nameLike
                                                ];
        Map<Id,Decimal> accountMapIDAndAccountRevenue2 = Account_TestDataFactory.convertAccountsListIntoMapOfIdsAndRevenues(accountListAfterUpdate);
        // compare the two maps
        Boolean areTwoMapsIdentical = accountMapIDAndAccountRevenue1.equals(accountMapIDAndAccountRevenue2);
        System.assertEquals(areTwoMapsIdentical, false, 'The Batch AccountUpdate_Queueable should return update AccountRevenue because the price of the Product2 were updated.');


    }
}
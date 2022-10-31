/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-31-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class Account_TestDataFactory_Test {
    private static String accountName = 'accountName';
    private static String nameLike = 'accountName-%';

    @isTest
    public static void testingGetAccount(){
        List<Account> accountsListToInsertForTest = new List<Account>();
        for(Integer i = 0 ; i < 5 ; i++){
            accountsListToInsertForTest.add(new Account(Name = accountName + i));
        }
        insert accountsListToInsertForTest;
        
        Test.startTest();
        Account accountToTest = Account_TestDataFactory.getAccount(accountName+3);
        Test.stopTest();

        System.assertEquals(accountToTest.name, accountName+3, 'getAccount(accountName) from Account_TestDataFactory should return only one Account record by the name of :'+accountName+3+'.');
    }
    @isTest
    public static void testGetAccountsAll(){
        List<Account> accountsListToInsertForTest = new List<Account>();
        for(Integer i = 0 ; i < 5 ; i++){
            accountsListToInsertForTest.add(new Account(Name = accountName + i));
        }
        insert accountsListToInsertForTest;
        
        Test.startTest();
        List<Account> accountsListToTest = Account_TestDataFactory.getAccountsAll();
        Test.stopTest();

        System.assertEquals(accountsListToTest.size(), 5, 'Account_TestDataFactory.getAccountsAll() should return a list of five records.');
    }
    @isTest
    public static void testingCreateAccount(){
        Test.startTest();
        Account_TestDataFactory.createAccount(accountName);
        Test.stopTest();
        List<Account> accountsListToTest = [SELECT Id,
                                                    AccountRevenue__c,
                                                    Name
                                            FROM Account
                                            WHERE Name= :accountName 
                                           ];

        System.assertEquals(accountsListToTest.size(), 1, 'createAccount(accountName) from Account_TestDataFactory should create one record named '+accountName+'.');
    }
    @isTest
    public static void testCreateAccountsList(){
        Test.startTest();
        Account_TestDataFactory.createAccountsList(5);
        Test.stopTest();
        List<Account> accountsListToTest = [SELECT Id,
                                                    AccountRevenue__c,
                                                    Name
                                            FROM Account
                                            WHERE Name LIKE :nameLike
                                           ];
        System.assertEquals(accountsListToTest.size(), 5, 'Account_TestDataFactory.createAccountsList should create 5 records of Accounts.');
    }
    @isTest
    public static void testConvertAccountsListIntoMapOfIdsAndRevenues(){
        Account_TestDataFactory.createAccountsList(5);
        List<Account> accountsListToTest = [SELECT Id,
                                                    AccountRevenue__c,
                                                    Name
                                            FROM Account
                                            WHERE Name LIKE :nameLike
                                           ];
        Test.startTest();
        Map<Id,Decimal> accountsMapIdAndRevenueForTest = Account_TestDataFactory.convertAccountsListIntoMapOfIdsAndRevenues(accountsListToTest);
        Test.stopTest();

        System.assertEquals(accountsMapIdAndRevenueForTest.size(), 5, 'Account_TestDataFactory.convertAccountsListIntoMapOfIdsAndRevenues should return a Map of Account.Ids and Account.AccountRevenues__c.');
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
        Set<Account> accountSetForTest = Account_TestDataFactory.convertAccountListIntoSet(accountsListForThisTest);
        Test.stopTest();

        System.assertEquals(accountSetForTest.size(), 5, 'Account_TestDataFactory.convertAccountListIntoSet should convert a list of 5 into a set of 5.');
    }
}

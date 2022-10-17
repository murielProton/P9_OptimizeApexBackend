/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-17-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class Account_TestDataFactory_Test {
    private static String accountName = 'accountName';

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
    public static void testingCreateAccountsList(){
        String nameLike = 'accountName-%';
        Test.startTest();
        Account_TestDataFactory.createAccountsList();
        Test.stopTest();
        List<Account> accountsListToTest = [SELECT Id,
                                                    AccountRevenue__c,
                                                    Name
                                            FROM Account
                                            WHERE Name LIKE :nameLike
                                           ];

        System.assertEquals(accountsListToTest.size(), 5, 'createAccountsList() from Account_TestDataFactory should create more than one records.');
    }
}

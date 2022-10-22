/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-22-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class Contract_TestDataFactory_Test {
    // init class variables
    private static String accountName = 'Ich bin ein creator';
    @TestSetup
    static void setupForContract_TestDataFactory_Test(){
        //Create an Account
        Account_TestDataFactory.createAccount(accountName);
        Account accountForThisTest = Account_TestDataFactory.getAccount(accountName);
        //create a Contract for this Account
        Contract_TestDataFactory.createContract(accountForThisTest);
    }
    @isTest
    static void testGetContractWithAccountID(){
        Account accountToTest = Account_TestDataFactory.getAccount(accountName);
        Test.startTest();
        Contract contractToTest = Contract_TestDataFactory.getContract(accountToTest.Id);
        Test.stopTest();
        System.assertEquals(contractToTest.AccountId, accountToTest.Id, 'Order_TestDataFactory.getContract(accountToTest.Id) should return a least one Contract.');
    }
    @isTest
    static void testCreateContractWithAccount(){
        Account accountToTest = Account_TestDataFactory.getAccount(accountName);
        Test.startTest();
        Contract_TestDataFactory.createContract(accountToTest);
        Test.stopTest();
        Contract contractToTest = [SELECT Id,
                                          AccountId
                                   FROM Contract 
                                   WHERE AccountId= :accountToTest.Id 
                                   LIMIT 1];
        System.assertEquals(contractToTest.AccountId, accountToTest.Id, 'Order_TestDataFactory.createContract(accountToTest) should create one Contract.');
    }
}

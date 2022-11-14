/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class ContractDataFactory_Test {
    // init class variables
    private static String accountName = 'Ich bin ein creator';
    @TestSetup
    static void setupForContract_TestDataFactory_Test(){
        //Create an Account
        AccountDataFactory.createAccount(accountName);
        Account accountForThisTest = AccountDataFactory.getAccount(accountName);
        //create a Contract for this Account
        ContractDataFactory.createContract(accountForThisTest);
    }
    @isTest
    static void testGetContractWithAccountID(){
        Account accountToTest = AccountDataFactory.getAccount(accountName);
        Test.startTest();
        Contract contractToTest = ContractDataFactory.getContract(accountToTest.Id);
        Test.stopTest();
        System.assertEquals(contractToTest.AccountId, accountToTest.Id, 'OrderDataFactory.getContract(accountToTest.Id) should return a least one Contract.');
    }
    @isTest
    static void testGetContractsAll(){
        Test.startTest();
        List<Contract> contractList = ContractDataFactory.getContractsAll();
        Test.stopTest();
        System.assertEquals(contractList.size(), 1, 'OrderDataFactory.getContractsAll should get a least one Contract.');
    }
    @isTest
    static void testCreateContractWithAccount(){
        Account accountToTest = AccountDataFactory.getAccount(accountName);
        Test.startTest();
        ContractDataFactory.createContract(accountToTest);
        Test.stopTest();
        Contract contractToTest = [SELECT Id,
                                          AccountId
                                   FROM Contract 
                                   WHERE AccountId= :accountToTest.Id 
                                   LIMIT 1];
        System.assertEquals(contractToTest.AccountId, accountToTest.Id, 'OrderDataFactory.createContract(accountToTest) should create one Contract.');
    }
    @isTest
    static void testUpdateContractsListStatusToActivated(){
        Account accountToTest = AccountDataFactory.getAccount(accountName);
        ContractDataFactory.createContract(accountToTest);
        List<Contract> contractsList = ContractDataFactory.getContractsAll();
        Test.startTest();
        ContractDataFactory.updateContractsListStatusToActivated(contractsList);
        Test.stopTest();
        Contract contractToTest = [SELECT Status
                                   FROM Contract 
                                   WHERE Status = 'Activated'
                                   LIMIT 1];
        System.assertEquals(contractToTest.Status, 'Activated', 'OrderDataFactory.updateContractsListStatusToActivated should create one Contracts with a Status set to Activated.');
    }
}

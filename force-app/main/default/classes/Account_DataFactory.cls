/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-10-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Account_DataFactory {
    public static Account getAccount(String accountName){
        Account accountToReturn = [SELECT Id,
                                          AccountRevenue__c
                                    FROM Account
                                    WHERE Name= :accountName 
                                    LIMIT 1];
        return accountToReturn;
    }
    public static void createAccount(String accountName){
        List<Account> accountsToInsertForTest = new List<Account>();
        accountsToInsertForTest.add(new Account(Name = accountName));
        insert accountsToInsertForTest;
    }
}

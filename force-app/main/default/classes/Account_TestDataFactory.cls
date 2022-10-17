/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-17-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Account_TestDataFactory {
    public static Account getAccount(String accountName){
        Account accountToReturn = [SELECT Id,
                                          AccountRevenue__c,
                                          Name
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
    public static void createAccountsList(){
        List<Account> accountsToInsertForTest = new List<Account>();
        for(Integer i = 0 ; i < 5 ; i++){
            accountsToInsertForTest.add(new Account(Name = 'accountName-'+i));
        }
        insert accountsToInsertForTest;
    }
}

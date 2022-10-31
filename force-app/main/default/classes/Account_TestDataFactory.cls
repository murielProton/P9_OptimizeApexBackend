/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-31-2022
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
    public static List<Account> getAccountsAll(){
        List<Account> accontsList = [SELECT Id,
                                          AccountRevenue__c,
                                          Name
                                     FROM Account
                                    ];
        return accontsList;
    }
    public static void createAccount(String accountName){
        List<Account> accountsToInsertForTest = new List<Account>();
        accountsToInsertForTest.add(new Account(Name = accountName));
        insert accountsToInsertForTest;
    }
    public static void createAccountsList(Integer numberOfAccounts){
        List<Account> accountsListToInsertForTest = new List<Account>();
        for(Integer i = 0 ; i < numberOfAccounts ; i++){
            accountsListToInsertForTest.add(new Account(Name = 'accountName-'+i));
        }
        insert accountsListToInsertForTest;
    }
    public static Map<Id,Decimal> convertAccountsListIntoMapOfIdsAndRevenues(List<Account> accountsList){
        Map<Id,Decimal> accountsMapIdAndRevenue = new  Map<Id,Decimal>();
        for(Account accountCurent: accountsList){
            accountsMapIdAndRevenue.put(accountCurent.Id,accountCurent.AccountRevenue__c);
        }
        return accountsMapIdAndRevenue;
    }
    public static Set<Account> convertAccountListIntoSet(List<Account> accountsList){
        Set<Account> accountsSet = new Set<Account>();
            for(Account accountCurrent : accountsList){
                accountsSet.add(accountCurrent);    
            }
        return accountsSet;
    }
    
    
}

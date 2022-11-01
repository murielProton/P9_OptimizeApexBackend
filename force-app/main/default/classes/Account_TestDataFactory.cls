/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-01-2022
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
    public static List<Account> getAccountsWhereOrderSatusOrdered(){
        List<Account> accontsList= [SELECT Id, AccountRevenue__c,Name FROM Account WHERE Id IN (SELECT AccountId FROM Order WHERE Status = 'Ordered')];
        return accontsList;
    }
    public static List<Account> getAccountsWhereOrderAccountID(){
        List<Account> accontsList= [SELECT Id, AccountRevenue__c,Name FROM Account WHERE Id IN (SELECT AccountId FROM Order)];
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
        
    // Used in Qeueable Batch
    // SOQL does not allow you to nest more than one level down in sub-selects = NOT Possible : List<Account> accountsListtoReturn = [SELECT Id FROM Account WHERE Id IN(SELECT Id FROM Order WHERE Pricebook2Id IN (SELECT Pricebook2Id FROM PricebookEntry WHERE LastModifiedDate > :dateTimeLastWeek))];
    // PricebookEntry modification date >= today -7 jours
    // find list of Accounts linked to Orders Linked to a Pricebook2 that is linked to a PricebookEntry which has been modified during this week.
    public static void updateAccountsWhereEntryLastModifiedDateLessThanAWeek(){
        List<Account> accountListAll = getAccountsAll();
        List<Order> ordersList = Order_TestDataFactory.getOrdersWheregetPriceBook2ListWherePricebookEntryLastModifiedDate();
        
        //Filter duplicated records
        Set<Order> ordersSet = Order_TestDataFactory.convertOrderListIntoSet(ordersList);
        Set<Account> accountSet = convertAccountListIntoSet(accountListAll);

        List<Account> accountsListToUpdate = OrderTriggerHelper.getAccountsListToUpdate(ordersSet, accountSet);

        update accountsListToUpdate;
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

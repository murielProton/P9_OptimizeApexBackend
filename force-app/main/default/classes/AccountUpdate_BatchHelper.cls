/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-31-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class AccountUpdate_BatchHelper {
    public static List<Account> convertOrdersListIntoAccountsList(List<Order> ordersList){
        List<Account> accountsListToReturn = new List<Account>();
        Set<Order> ordersSet = Order_TestDataFactory.convertOrderListIntoSet(ordersList);
        
        List<Account> accountsListToFilter = Account_TestDataFactory.getAccountsAll();
        Set<Account> accountsSet = Account_TestDataFactory.convertAccountListIntoSet(accountsListToFilter);

        for(Order orderCurent : ordersSet){/*
            Account accountCurent = accountsSet.get(orderCurent.AccountId);
            if(accountCurent == null){
                if(!accountsListToReturn.contains(accountCurent)){
                    accountsListToReturn.add(accountCurent);
                }
            }*/
            for(Account accountCurent : accountsSet){

                if(orderCurent.AccountId == accountCurent.Id){
                    if(!accountsListToReturn.contains(accountCurent)){
                        accountsListToReturn.add(accountCurent);
                    }
                    continue;
                }
            }
        }
        return accountsListToReturn;
    }
}

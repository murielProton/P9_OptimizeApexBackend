/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-07-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class AccountUpdate_BatchHelper {
   /* public static List<Account> convertOrdersListIntoAccountsList(List<Order> ordersList){
        List<Account> accountsListToReturn = new List<Account>();
        Set<Order> ordersSet = Order_TestDataFactory.convertOrderListIntoSet(ordersList);
        
        List<Account> accountsListToFilter = Account_TestDataFactory.getAccountsAll();
        Set<Account> accountsSet = Account_TestDataFactory.convertAccountListIntoSet(accountsListToFilter);

        for(Order orderCurent : ordersSet){
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
    }*/
    public static List<Order> convertAccountsListIntoOrdersList(List<Account> accountsList){
        List<Order> ordersListToReturn = new List<Order>();
        List<Order> ordersList = Order_TestDataFactory.getOrdersAll();
        Set<Order> ordersSet = Order_TestDataFactory.convertOrderListIntoSet(ordersList);
        
        Set<Account> accountsSet = Account_TestDataFactory.convertAccountListIntoSet(accountsList);

        for(Order orderCurent : ordersSet){
            for(Account accountCurent : accountsSet){

                if(orderCurent.AccountId == accountCurent.Id){
                    if(!ordersListToReturn.contains(orderCurent)){
                        ordersListToReturn.add(orderCurent);
                    }
                    continue;
                }
            }
        }
        return ordersListToReturn;
    }
}

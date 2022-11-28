/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class AccountUpdate_BatchHelper {

    public static List<Account> convertOrdersListIntoAccountsList(List<Order> ordersList){
        List<Account> accountsListToReturn = new List<Account>();
        Set<Order> ordersSet = OrderDataFactory.convertOrderListIntoSet(ordersList);
        
        List<Account> accountsListToFilter = AccountDataFactory.getAccountsAll();
        Set<Account> accountsSet = AccountDataFactory.convertAccountListIntoSet(accountsListToFilter);

        //convert Order Set into Account ID Set
        Set<String> accountIDSetContainedInOrderSet = new Set<String>();
        for(Order orderCurent : ordersSet){
            accountIDSetContainedInOrderSet.add(orderCurent.AccountId);
        }

        for(Account accountCurent : accountsSet){
            if(accountIDSetContainedInOrderSet.contains(accountCurent.Id)){
                if(!accountsListToReturn.contains(accountCurent)){
                    accountsListToReturn.add(accountCurent);
                }
                continue;
            }
        }
        return accountsListToReturn;
    }
    public static List<Order> convertAccountsListIntoOrdersList(List<Account> accountsList){
        List<Order> ordersListToReturn = new List<Order>();
        List<Order> ordersList = OrderDataFactory.getOrdersAll();
        Set<Order> ordersSet = OrderDataFactory.convertOrderListIntoSet(ordersList);
        
        Set<Account> accountsSet = AccountDataFactory.convertAccountListIntoSet(accountsList);

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

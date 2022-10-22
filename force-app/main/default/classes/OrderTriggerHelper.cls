/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-17-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class OrderTriggerHelper{
    // Todo ??? get this methode forem Account_TestDataFactory
    public static List<Account> getAccountListAll(){
        
        List<Account> accountList = [SELECT Id, 
                              AccountRevenue__c,
                              Name
                       FROM Account];
        return accountList;
    }

    public static Set<Order> convertOrderListIntoSet(List<Order> ordersList){
        Set<Order> ordersSet = new Set<Order>();
            for(Order orderCurrent : ordersList){
                ordersSet.add(orderCurrent);    
            }
        return ordersSet;
    }
    public static Set<Account> convertAccountListIntoSet(List<Account> accountsList){
        Set<Account> accountsSet = new Set<Account>();
            for(Account accountCurrent : accountsList){
                accountsSet.add(accountCurrent);    
            }
        return accountsSet;
    }

    public static List<Account> getAccountsListToUpdate(Set<Order> orderSet, Set<Account> accountSet){
        List<Account> accountsListToUpdate = new List<Account>();
        //No other way than to put a for loop within a for loop
        for(Account accountCurrent : accountSet){
            for(Order orderCurrent : orderSet){
                if(accountCurrent.Id == orderCurrent.AccountId){
                    
                    if(accountCurrent.AccountRevenue__c == null){
                        accountCurrent.AccountRevenue__c = orderCurrent.TotalAmount;
                    }else{
                        accountCurrent.AccountRevenue__c = accountCurrent.AccountRevenue__c + orderCurrent.TotalAmount;
                    }
                    accountsListToUpdate.add(accountCurrent);
                }
            }
        }
        return accountsListToUpdate;
    }
    // Used in Trigger OrderTrigger before Update
    public static List<Order> getOrdersListWithUpdatedNetAmounts(List<Order> orderListNew){
        List<Order> ordersListToUpdate = new List<Order>();
        for(Order orderCurrent : orderListNew){
            orderCurrent.NetAmount__c = orderCurrent.TotalAmount - orderCurrent.ShipmentCost__c;
            ordersListToUpdate.add(orderCurrent);
        }
    return ordersListToUpdate;
    }
    // Used in Trigger OrderTrigger after Update
    public static void updateListOfAccountsRevenue(List<Order> orderListNew, List<Order> orderListOld){
        
        List<Account> accountsListAll = getAccountListAll();
        Set<Account> accountsSetAll = convertAccountListIntoSet(accountsListAll);
        Set<Order> orderSetNew = convertOrderListIntoSet(orderListNew);
        List<Account> accountsListToUpdate = getAccountsListToUpdate(orderSetNew, accountsSetAll);
        /*System.debug('accountsSetAll ID '+accountsSetAll[0]);*/

        // to iterate throgh a map and get the value for ID for(Id id : orderMapNew.keyset()){
        //    Order orderNew = orderMapNew.get(id);
       /* for(Order orderCurrent : orderListNew){
            Order orderNew = orderCurrent;
            Account acc = [SELECT Id, AccountRevenue__c FROM Account WHERE Id =:orderNew.AccountId ];
            System.debug('TRIGGER account debug '+acc);
            if(acc.AccountRevenue__c == null){
                acc.AccountRevenue__c = orderNew.TotalAmount;
            }else{
                acc.AccountRevenue__c = acc.AccountRevenue__c + orderNew.TotalAmount;
            }
            update acc;
        }*/
        update accountsListToUpdate;
    }
    // Todo methode used in Trigger OrderTrigger before update
    public static void updateListOfOrdersNetAmounts(List<Order> orderListNew, List<Order> orderListOld){
        List<Order> ordersListToUpdate = getOrdersListWithUpdatedNetAmounts(orderListNew);
        update ordersListToUpdate;
    }
}
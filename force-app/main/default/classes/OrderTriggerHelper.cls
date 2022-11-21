/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-21-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class OrderTriggerHelper{


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
                }
            }
            accountsListToUpdate.add(accountCurrent);
        }
        return accountsListToUpdate;
    }

    // Used in Trigger OrderTrigger before Update
    public static List<Order> getOrdersListWithUpdatedNetAmounts(List<Order> orderListNew){
        List<Order> ordersListToUpdate = new List<Order>();
        for(Order orderCurrent : orderListNew){
            if(orderCurrent.Status == 'Ordered'){
                if(orderCurrent.ShipmentCost__c == Null){
                    orderCurrent.ShipmentCost__c = 0;
                }
                if(orderCurrent.TotalAmount == Null){
                    // field NetAmount__c not wrightable
                    orderCurrent.NetAmount__c = 0 - orderCurrent.ShipmentCost__c;
                    ordersListToUpdate.add(orderCurrent);
                    continue;
                }
                orderCurrent.NetAmount__c = orderCurrent.TotalAmount - orderCurrent.ShipmentCost__c;
                ordersListToUpdate.add(orderCurrent);
            }
            continue;
        }
    return ordersListToUpdate;
    }

    // Used in Trigger OrderTrigger after Update
    public static void updateListOfAccountsRevenue(List<Order> orderListNew, List<Order> orderListOld){
        
        List<Account> accountsListAll = AccountDataFactory.getAccountListAll();
        Set<Account> accountsSetAll = AccountDataFactory.convertAccountListIntoSet(accountsListAll);
        Set<Order> orderSetNew = OrderDataFactory.convertOrderListIntoSet(orderListNew);
        List<Account> accountsListToUpdate = getAccountsListToUpdate(orderSetNew, accountsSetAll);

        update accountsListToUpdate;
    }
    // Used in Trigger OrderTrigger after Update
    public static void updateListOfAccountsRevenueWhenOrderStatusOrdered(List<Order> orderListNew, List<Order> orderListOld){
        // get the right list to update
        Set<Order> orderSetNewToFilter = OrderDataFactory.convertOrderListIntoSet(orderListNew);
        Set<Order> orderSetOldToFilter = OrderDataFactory.convertOrderListIntoSet(orderListOld);
        Set<Order> orderSetNew = OrderDataFactory.filterOrderSetForStatusOrdered(orderSetNewToFilter);
        Set<Order> orderSetOld = OrderDataFactory.filterOrderSetForStatusNotOrdered(orderSetOldToFilter);
        List<Order> orderList = OrderDataFactory.filterOrderSetForStatusJustChanged(orderSetOld, orderSetNew);
        // LIMIT EXECEPTION CPU TIME LIMIT EXEEDED List<Order> orderList = OrderDataFactory.getOrdersListOfNewOrdered(orderSetNew, orderSetOld);
        List<Account> accountsList = AccountUpdate_BatchHelper.convertOrdersListIntoAccountsList(orderList);

        //update Account Revenue
        Set<Order> orderSet = OrderDataFactory.convertOrderListIntoSet(orderList);
        Set<Account> accountSet = AccountDataFactory.convertAccountListIntoSet(accountsList);
        List<Account> accountsListToUpdate =  getAccountsListToUpdate(orderSet, accountSet);

        update accountsListToUpdate;
    }
    // methode used in Trigger OrderTrigger before update do not return because used in Before Update Trigger
    public static void changeListOfOrdersNetAmountsForTrigger(List<Order> orderListNew, List<Order> orderListOld){
        List<Order> ordersListToUpdate = getOrdersListWithUpdatedNetAmounts(orderListNew);
    }
    
}

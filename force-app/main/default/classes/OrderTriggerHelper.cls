/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-07-2022
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
    return ordersListToUpdate;
    }

    // Used in Trigger OrderTrigger after Update
    public static void updateListOfAccountsRevenue(List<Order> orderListNew, List<Order> orderListOld){
        
        List<Account> accountsListAll = getAccountListAll();
        Set<Account> accountsSetAll = Account_TestDataFactory.convertAccountListIntoSet(accountsListAll);
        Set<Order> orderSetNew = Order_TestDataFactory.convertOrderListIntoSet(orderListNew);
        List<Account> accountsListToUpdate = getAccountsListToUpdate(orderSetNew, accountsSetAll);

        update accountsListToUpdate;
    }
    // Used in Trigger OrderTrigger after Update
    public static void updateListOfAccountsRevenueWhenOrderStatusOrdered(List<Order> orderListNew, List<Order> orderListOld){
        // get the right list to update
        Set<Order> orderSetNew = Order_TestDataFactory.convertOrderListIntoSet(orderListNew);
        Set<Order> orderSetOld = Order_TestDataFactory.convertOrderListIntoSet(orderListOld);
        List<Order> orderList = Order_TestDataFactory.getOrdersListOfNewOrdered(orderSetNew, orderSetOld);
        List<Account> accountsList = AccountUpdate_BatchHelper.convertOrdersListIntoAccountsList(orderList);

        //update Account Revenue
        Set<Order> orderSet = Order_TestDataFactory.convertOrderListIntoSet(orderList);
        Set<Account> accountSet = Account_TestDataFactory.convertAccountListIntoSet(accountsList);
        List<Account> accountsListToUpdate =  getAccountsListToUpdate(orderSet, accountSet);

        update accountsListToUpdate;
    }
    // methode used in Trigger OrderTrigger before update do not return because used in Before Update Trigger
    public static void updateListOfOrdersNetAmounts(List<Order> orderListNew, List<Order> orderListOld){
        List<Order> ordersListToUpdate = getOrdersListWithUpdatedNetAmounts(orderListNew);
    }
    
}

/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-10-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class OrderTriggerHelper{
    public static List<Account> getAccountListAll(){
        
        List<Account> accountList = [SELECT Id, 
                              AccountRevenue__c 
                       FROM Account];
        return accountList;
    }

    public static Set<Order> convertOrderListIntoSet(List<Order> orderListOld){
        Set<Order> orderSet = new Set<Order>();
            for(Order orderCurrent : orderListOld){
                orderSet.add(orderCurrent);    
            }
        return orderSet;
    }
    public static Set<Id> convertOrderListIntoAccountIdSet(List<Order> orderListOld){
        Set<Id> accountIdSet = new Set<Id>();
            for(Order orderCurrent : orderListOld){
                accountIdSet.add(orderCurrent.AccountId);    
            }
        return accountIdSet;
    }
    //Todo 
    /*
    public static Set<Account> getAccountSetToUpdate(List<Account> accountList, Set<Id> accountIdSet){
        Set<Account> accountSetToUpdate = new Set<Account>();
        for(Account accountCurrent : accountList){

            if(orderSet.contains(accountIdSet)){
                accountSetToUpdate.add(accountCurrent);
            }  
        }
        return accountSetToUpdate;
    }*/
    //Todo
    public static Map<Id, Account> getAccountMapToUpdate(List<Order> orderListNew){
        Map<Id, Account> orderAndAccountMap = new Map<Id, Account>();

        return orderAndAccountMap;
    }
    
    public static void setAccountRevenue(List<Order> orderListNew, List<Order> orderListOld){
        set<Id> setAccountIds = new set<Id>();
    
        // to iterate throgh a map and get the value for ID for(Id id : orderMapNew.keyset()){
        //    Order orderNew = orderMapNew.get(id);
        for(Order orderCurrent : orderListNew){
            Order orderNew = orderCurrent;
            Account acc = [SELECT Id, AccountRevenue__c FROM Account WHERE Id =:orderNew.AccountId ];
            System.debug('TRIGGER account debug '+acc);
            if(acc.AccountRevenue__c == null){
                acc.AccountRevenue__c = orderNew.TotalAmount;
            }else{
                acc.AccountRevenue__c = acc.AccountRevenue__c + orderNew.TotalAmount;
            }
            update acc;
        }
    }
}

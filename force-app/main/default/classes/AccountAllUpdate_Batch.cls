/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-07-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class AccountAllUpdate_Batch implements Database.Batchable<sObject>{
    
   global Database.QueryLocator start(Database.BatchableContext info){ 
       // Querry All new Accounts  
       return Database.getQueryLocator('SELECT Id, AccountRevenue__c FROM Account WHERE CreatedDate = LAST_WEEK');
   }
    
   global void execute(Database.BatchableContext info, List<Account> scope){
    // update Account Revenue
       Set<Account> accountSet = Account_TestDataFactory.convertAccountListIntoSet(scope);
       List<Order> ordersList = AccountUpdate_BatchHelper.convertAccountsListIntoOrdersList(scope);
       Set<Order> ordersSet = Order_TestDataFactory.convertOrderListIntoSet(ordersList);
       List<Account> accountsListToUpdate = OrderTriggerHelper.getAccountsListToUpdate(ordersSet, accountSet);
       update accountsListToUpdate;
   }    
    
    global void finish(Database.BatchableContext info){     
            System.debug('@@Post Processsing Batch DONE');
    } 
}
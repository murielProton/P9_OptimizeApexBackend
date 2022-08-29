global class AccountAllUpdate_Batch implements Database.Batchable<sObject>{
    
   global Database.QueryLocator start(Database.BatchableContext info){ 
        //request only the Accounts with at least one Order with the Status 'Ordered'
        // Account and Order are linked by a loockup from Order. There for the querry must fill an Set. We can't do a double Querry.
        return Database.getQueryLocator([SELECT AccountId FROM Order WHERE Status = 'Ordered']);

   }
    
   global void execute(Database.BatchableContext info, List<Account> scope){
       Set<Id> setAccountIds = (new Map<Id,SObject>(scope)).keySet();
       AccountHelper ap01Account = new AccountHelper();
       ap01Account.updateAccountRevenue(setAccountIds);
   }    
    
   global void finish(Database.BatchableContext info){     
       
   } 
}
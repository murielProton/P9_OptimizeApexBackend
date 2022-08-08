global class AccountUpdate_Batch implements Database.Batchable<sObject>{
    
   global Database.QueryLocator start(Database.BatchableContext info){ 
       //Requeter seulement les comptes qui ont au moins une commande avec le Status 'Ordered'
       return Database.getQueryLocator('SELECT Id FROM Account');

   }
    
   global void execute(Database.BatchableContext info, List<Account> scope){      
       list<Order> listOrders =  [SELECT Id, TotalAmount, AccountId FROM Order];
       
		for(integer i=0; i < scope.size(); i++){
			Account myAccount = scope[i];
			myAccount.AccountRevenue__c = 0;
           for(integer j=0; j < listOrders.size(); j++){
               if(listOrders[j].AccountId == myAccount.Id){
                   myAccount.AccountRevenue__c = myAccount.AccountRevenue__c + listOrders[j].TotalAmount;
               }                   
           }
       }
       
       update scope;
   }    
    
   global void finish(Database.BatchableContext info){     
       
   } 
}
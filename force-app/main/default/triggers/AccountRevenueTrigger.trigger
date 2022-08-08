trigger AccountRevenueTrigger on Order (after update) {
	
    set<Id> setAccountIds = new set<Id>();
    
    for(integer i=0; i< trigger.new.size(); i++){
        Order newOrder= trigger.new[i];
       
        Account acc = [SELECT Id, AccountRevenue__c FROM Account WHERE Id =:newOrder.AccountId ];
        acc.AccountRevenue__c = acc.AccountRevenue__c + newOrder.TotalAmount;
        update acc;
    }
}
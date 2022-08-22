trigger AccountRevenueTrigger on Order (after update) {
	
    set<Id> setAccountIds = new set<Id>();
    
    for(integer i=0; i< trigger.new.size(); i++){
        Order newOrder= trigger.new[i];
        Account acc = [SELECT Id, AccountRevenue__c FROM Account WHERE Id =:newOrder.AccountId ];
        if(acc.AccountRevenue__c == null){
            System.debug('On Account the field AccountRevenue__c is null.');
        }else if (newOrder.TotalAmount == null){
            System.debug('On Order the field TotalAmount is null.');
        }else{   
            try{  
                acc.AccountRevenue__c = acc.AccountRevenue__c + newOrder.TotalAmount;
                update acc;
            }catch(DmlException dmlException){
                System.debug('the selected Account was empty. And the following exception has occurred: ' + dmlException.getMessage());
            }
        }

    }
}
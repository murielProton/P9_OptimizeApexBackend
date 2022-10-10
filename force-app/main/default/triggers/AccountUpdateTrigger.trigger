/**
 * @description       : 
 * @author            : Muriel Proton
 * @group             : 
 * @last modified on  : 10-10-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger AccountUpdateTrigger on Order (after update) {
	
    set<Id> setAccountIds = new set<Id>();
    
    for(integer i=0; i< trigger.new.size(); i++){
        Order newOrder= trigger.new[i];
       
        Account acc = [SELECT Id, AccountRevenue__c FROM Account WHERE Id =:newOrder.AccountId ];
        System.debug('TRIGGER account debug '+acc);
        if(acc.AccountRevenue__c == null){
            acc.AccountRevenue__c = newOrder.TotalAmount;
        }else{
            acc.AccountRevenue__c = acc.AccountRevenue__c + newOrder.TotalAmount;
        }
        update acc;
    }
}
/**
 * @description       : 
 * @author            : Muriel Proton
 * @group             : 
 * @last modified on  : 09-19-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger OrderUpdateTrigger on Order (before update) {
	
	Order newOrder= trigger.new[0];
	newOrder.NetAmount__c = newOrder.TotalAmount - newOrder.ShipmentCost__c;
}
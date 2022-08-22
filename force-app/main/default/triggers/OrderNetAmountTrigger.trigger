trigger OrderNetAmountTrigger on Order (before update) {
	Order newOrder= trigger.new[0];
	if (newOrder.TotalAmount == null){
		System.debug('Fatal error Order.TotalAmount is null');
	} else if (newOrder.ShipmentCost__c == null) {
		System.debug('Fatal error Order.ShipmentCost__c is null');
	} else {
		try{
			newOrder.NetAmount__c = newOrder.TotalAmount - newOrder.ShipmentCost__c;
		}catch(DmlException dmlException){
			System.debug('Fatal error while calculating' + newOrder.TotalAmount + ' - ' + newOrder.ShipmentCost__c +
			'The following exception has occurred: ' + dmlException.getMessage());
		}
	}
}
public with sharing class OrderDataFactory {
    public void OrderInsert(Integer numberOfRecordsToInsert, String accountName ) {
        List<Account> listOfAccountID = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
        Id accountID = listOfAccountID[0].Id;
        List<Contract> listOfontractID = [SELECT Id FROM Contract WHERE AccountId = :accountID];
        Id contractID = listOfontractID[0].Id;
        List<Order> listToInsert = new List<Order>();
        for(Integer i = 0 ; i <= numberOfRecordsToInsert ; i++){
            Order orderToCreate = new Order();
            orderToCreate.AccountId = accountID;
            orderToCreate.EffectiveDate = Date.today();
            orderToCreate.ShipmentCost__c = 123 * i; //TODO maybe externalise this value
            // orderToCreate.NetAmount__c = 321 * i; TODO this value is caclulated with the help of sObject OrderItem, it should not be filled
            orderToCreate.ContractId = contractID;
            orderToCreate.Status = 'Draft';
            listToInsert.add(orderToCreate);
        }
        insert listToInsert;
    }
    public void OrderInsert99Records() {
        OrderInsert(99, 'Cartier');
    }
}
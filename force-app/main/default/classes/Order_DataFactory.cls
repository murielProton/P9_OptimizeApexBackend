/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-10-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Order_DataFactory {
    public static String orderName = 'Yukako\'s Order';
    public static Order getOrder(Account accountForThisTest, Contract contractForThisTest){
        Order orderToReturn = [SELECT Id, AccountId, TotalAmount
                               FROM Order
                               WHERE AccountId = :accountForThisTest.Id AND ContractId = :contractForThisTest.Id
                               LIMIT 1];
        return orderToReturn;
    }

    public static Order constructOneOrder(Account accountForThisTest, Contract contractForThisTest, PriceBook2 pricebookForThisTest){
        Order orderConstructed = new Order(
            Name = orderName,
            AccountId = accountForThisTest.Id,
            ContractId = contractForThisTest.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            ShipmentCost__c = 10,
            // essential for the creation of OrderItem
            Pricebook2Id =  pricebookForThisTest.Id
            //TotalAmount = not writable This is Why Order links to a Product2 with OrderItem
        );
        return orderConstructed;
    }

    public static void updateOrder(Order orderToUpdate){
        orderToUpdate.ShipmentCost__c = 20;
        update orderToUpdate;
    }
}
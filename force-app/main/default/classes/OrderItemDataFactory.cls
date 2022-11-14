/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class OrderItemDataFactory {
    
    public static OrderItem constructOneOrderItem(Order orderForThisTest, Product2 product2ForThisTest, PricebookEntry pricebookEntryForThisTest){
        OrderItem orderItemToInsert = new OrderItem(
            OrderId = orderForThisTest.id,
            Quantity = 24,
            UnitPrice = 240,
            Product2Id = product2ForThisTest.id,
            PricebookEntryId = pricebookEntryForThisTest.id
        );
        return orderItemToInsert;
    }
    

}

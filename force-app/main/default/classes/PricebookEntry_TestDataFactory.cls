/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-24-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class PricebookEntry_TestDataFactory {
    // Product must be active and added to Pricebook first
    public static PricebookEntry getPricebookEntry(PriceBook2 pricebookForThisTest,Product2 product2ForThisTest){
        PricebookEntry pricebookEntryToReturn = [SELECT Id,
                                                        Name,
                                                        Pricebook2Id,
                                                        Product2Id,
                                                        UnitPrice,
                                                        UseStandardPrice,
                                                        IsActive
                                                FROM PricebookEntry
                                                WHERE Pricebook2Id = :pricebookForThisTest.Id AND Product2Id = :product2ForThisTest.Id
                                                LIMIT 1];
        return pricebookEntryToReturn;
    }
    
    public static void createPriceBookEntryForPricebookStandard(Product2 product2ForThisTest){
        PricebookEntry priceBookEntryToInsert = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product2ForThisTest.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert priceBookEntryToInsert;
    }
    public static void createPriceBookEntry(PriceBook2 pricebookForThisTest, Product2 product2ForThisTest){
        PricebookEntry priceBookEntryToInsert = new PricebookEntry(
            Pricebook2Id = pricebookForThisTest.Id,
            Product2Id = product2ForThisTest.Id,
            UnitPrice = 100.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert priceBookEntryToInsert;
    }
}

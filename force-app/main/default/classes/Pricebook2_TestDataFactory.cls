/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-01-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Pricebook2_TestDataFactory {

    public static Pricebook2 getPriceBook2ByName(String pricebookName){
        Pricebook2 pricebook2 = [SELECT Id,
                                        Name,
                                        isActive,
                                        IsStandard
                                FROM PriceBook2
                                WHERE Name = :pricebookName
                                LIMIT 1];
        return pricebook2;
    }
    public static List<Pricebook2> getPriceBook2All(){
        List<Pricebook2> pricebook2ListtoReturn = [SELECT Id,
                                                          Name,
                                                          isActive,
                                                          IsStandard
                                                   FROM PriceBook2
                                                  ];
        return pricebook2ListtoReturn;
    }
    public static List<Pricebook2> getPriceBook2ListWherePricebookEntryLastModifiedDate(){
        DateTime dateTimeLastWeek = DateTime.now().addDays(-7);

        List<Pricebook2> pricebook2ListtoReturn=[SELECT Id FROM Pricebook2 WHERE Id IN (SELECT Pricebook2Id FROM PricebookEntry WHERE LastModifiedDate > :dateTimeLastWeek)];

        return pricebook2ListtoReturn;
    }

    //If you create a Pricebook it must be active and standard, but the field Standard is not wrightable.
    public static void createPricebook2(String pricebook2Name){
        List<PriceBook2> pricebook2ToInsertForTest = new List<PriceBook2>();
        pricebook2ToInsertForTest.add( new PriceBook2 (
            Name = pricebook2Name,
            IsActive = true
        ));
        insert pricebook2ToInsertForTest;
    }
}

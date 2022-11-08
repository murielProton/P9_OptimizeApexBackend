/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-08-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class Pricebook2_TestDataFactory_Test {
    private static String pricebook2Name = 'Yukako\'s Price Book';
    @isTest
    static void testGetPriceBook2ByName(){
        List<PriceBook2> pricebook2ToInsertForTest = new List<PriceBook2>();
            pricebook2ToInsertForTest.add( new PriceBook2 (
                Name = pricebook2Name,
                IsActive = true
            ));
        insert pricebook2ToInsertForTest;

        Test.startTest();
        PriceBook2 pricebook2ToTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);
        Test.stopTest();

        System.assertEquals(pricebook2ToTest.IsActive, true, 'Pricebook2_TestDataFactory.getPriceBook2ByName should return one PriceBook2.');
    }


    @isTest
    static void testCreatePricebook2(){
        Test.startTest();
        Pricebook2_TestDataFactory.CreatePricebook2(pricebook2Name); 
        Test.stopTest();

        Pricebook2 pricebook2ToTest = [SELECT Id,
                                        Name,
                                        isActive,
                                        IsStandard
                                FROM PriceBook2
                                WHERE Name = :pricebook2Name
                                LIMIT 1];

        System.assertEquals(pricebook2ToTest.IsActive, true, 'Pricebook2_TestDataFactory.CreatePricebook2 should create one PriceBook2.');

    }
}

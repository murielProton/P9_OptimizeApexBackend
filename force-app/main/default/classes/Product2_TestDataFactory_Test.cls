/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-24-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

@isTest
public with sharing class Product2_TestDataFactory_Test {
    private static String productName = 'asaito';
    @TestSetup
    static void setupForProduct2_TestDataFactory_Test(){
        List<Product2> productsToInsertFortTest = new List<Product2>();
        productsToInsertFortTest.add(new Product2 (
            Name = productName,
            IsActive = true
        ));
        insert productsToInsertFortTest;
    }

    @isTest
    static void testGetProduct2(){
        Test.startTest();
        Product2 product2toTest = Product2_TestDataFactory.getProduct2(productName);
        Test.stopTest();
        System.assertEquals(product2toTest.Name, productName, 'Product2_TestDataFactory.getProduct2 should get at least one record of Product2.'); 
    }

    @isTest
    static void testCreateProduct2(){
        String productName2 = 'momen';
        Test.startTest();
        Product2_TestDataFactory.createProduct2(productName2);
        Test.stopTest();
        Product2 product2toTest = Product2_TestDataFactory.getProduct2(productName);
        System.assertEquals(product2toTest.Name, productName, 'Product2_TestDataFactory.createProduct2 should crete at least one record of Product2.'); 
    }
}

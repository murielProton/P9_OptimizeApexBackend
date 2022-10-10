/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-10-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Product2_DataFactory {
    public static Product2 getProduct2(String productName){
        Product2 product2toReturn = [SELECT Id,
                                            Name,
                                            IsActive
                                     FROM Product2
                                     WHERE Name = :productName
                                     LIMIT 1];
        return product2toReturn;
    }
    public static void createProduct2(String productName){
        List<Product2> productsToInsertFortTest = new List<Product2>();
        productsToInsertFortTest.add(new Product2 (
            Name = productName,
            IsActive = true
        ));
        insert productsToInsertFortTest;
    }
}

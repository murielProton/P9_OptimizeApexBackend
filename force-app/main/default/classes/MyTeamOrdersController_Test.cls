/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-29-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class MyTeamOrdersController_Test {
    private static String accountName = 'Yukako';
    private static String pricebook2Name = 'Yukako\'s Price Book';
    @TestSetup
    static void testSetupForMyTeamOrdersController(){
        //Create an Account
        Account_TestDataFactory.createAccount(accountName);
        Account accountForThisTest = Account_TestDataFactory.getAccount(accountName);
        //create a Contract for this Account
        Contract_TestDataFactory.createContract(accountForThisTest);
        // Make sure the Pricebook2 entry is active and standard
        Pricebook2_TestDataFactory.createPricebook2(pricebook2Name);

        // get sObjects for Test
        Contract contractForThisTest = Contract_TestDataFactory.getContract(accountForThisTest.Id);
        Pricebook2 pricebookForThisTest = Pricebook2_TestDataFactory.getPriceBook2ByName(pricebook2Name);

        Order_TestDataFactory.createOrdersList(100, accountForThisTest.Id, contractForThisTest.Id , pricebookForThisTest);
    }
    /*@isTest
    static void testSumOders(){
        Test.startTest();
        decimal groupedResults = MyTeamOrdersController.sumOders;
        Test.stopTest();
        System.debug('groupedResults - '+groupedResults);
        System.assertEquals(ordersListToTest.size(), 100, 'MyTeamOrdersController.sumOders should retrun the summ of all the TotalAmount fields on all the Orders records.');
        
    }*/
}

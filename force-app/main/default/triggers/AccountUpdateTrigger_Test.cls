/**
 * @description       : 
 * @author            : Muriel Proton
 * @group             : 
 * @last modified on  : 09-19-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class AccountUpdateTrigger_Test {
    
    @TestSetup
    static void setupForTestAccountUpdateTrigger(){
        //Ceate an Account
        String accountName = 'Yukako';
        createAccount(accountName);
        //create a Contract for this Account
        createContract(accountName);
        //TODO Create a Product
        //TODO Create a bunch of Orders on this Account
        //TODO Update the bunch of Orders
        //TODO Check tha the old Account.AccountRevenue__c is different from the new one
    }
    static Account getAccount(String accountName){
        Account accountToReturn = [SELECT Id,
                                          AccountRevenue__c
                                    FROM Account
                                    WHERE Name= :accountName 
                                    LIMIT 1];
        return accountToReturn;
    }
    static void createAccount(String accountName){
        List<Account> accountsToInsertForTest = new List<Account>();
        accountsToInsertForTest.add(new Account(Name = accountName));
        insert accountsToInsertForTest;
    }
    static Contract getContract(ID accountId){
        Contract contractToReturn = [SELECT Id,
                                            TotalAmount
                                     FROM Contract 
                                     WHERE AccountId= :accountId 
                                     LIMIT 1];
        return contractToReturn;
    }
    static void createContract(String accountName){
        Account accountForThisContract = getAccount(accountName);
        List<Contract> contractsToInsertForTest = new List<Contract>();
        contractsToInsertForTest.add(new Contract(
            AccountId = accountForThisContract.Id,
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 6
        ));
        insert contractsToInsertForTest;
    }
    public static void createListOfOrders(String accountName){
        Account accountForTheeseOrders = getAccount(accountName);
        Contract contractForTheeseOrders = getContract(accountForTheeseOrders.Id);
        List<Order> ordersToInsertForTest = new List<Order>();
        //TODO put it into a for i loop
        ordersToInsertForTest.add(new Order(
            AccountId = accountForTheeseOrders.Id,
            ContractId = contractForTheeseOrders.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            ShipmentCost__c = 1000,
            //not writable TODO link an order to a product
            TotalAmount = 10
        ));
        insert ordersToInsertForTest;
    }
    

}

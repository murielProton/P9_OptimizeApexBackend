/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-02-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class AccountUpdate_Queueable implements Database.Batchable<sObject> {
    public static void run(){
        Database.executeBatch(new AccountUpdate_Queueable());
    }
    public List<Account> start(Database.BatchableContext bc){
        //Collect the batches of records or objects to be passed to execute
        // If the field UnitPirce has been updated on PricebookEntry
        // PricebookEntry -> Pricebook2 -> Contract -> Account
        // or
        // PricebookEntry -> Pricebook2 <- Order -> Account
        //IMPORTANT ONLY QUERRY HERE !
        return Account_TestDataFactory.getAccountsListWhereEntryLastModifiedDateLessThanAWeek();
    }
    public void execute(Database.BatchableContext bc, List<Account> accountsRecordsList){
        //process each batch of records
        // update each AccountRevenue__c of the accountsRecordsList
        // To do so a associated list of order is needed
        // IMPORTANT CHANGE VALUE HERE !
        update accountsRecordsList;
    }
    public void finish(Database.BatchableContext bc){
        //execute any post processing operations
        System.debug('@@Post Processsing Batch DONE');
        //Chaining Batch Jobs
        //Database.execut(new BatchCalss2());
    }
}

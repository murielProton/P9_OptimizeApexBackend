/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-02-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class RunAccountUpdate_Queueable implements Schedulable{
    global void execute(SchedulableContext sc) {
        AccountUpdate_Queueable accountUpdateBatch = new AccountUpdate_Queueable();
        Database.executebatch(accountUpdateBatch);

    }
}

/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-07-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class AccountUpdateExecute_Queueable implements Schedulable{
    global void execute(SchedulableContext sc) {
        AccountUpdate_Queueable accountUpdateBatch = new AccountUpdate_Queueable();
        Database.executebatch(accountUpdateBatch);

    }
}

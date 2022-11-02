/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-02-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class RunAccountUpdate_Queueable_Test {
    @isTest
    static void testRunAccountUpdate(){
        Test.startTest();
        RunAccountUpdate_Queueable oneWeek = new RunAccountUpdate_Queueable();
        //every thursday at one AM
        String schedule = '0 0 1 ? * THU *';
        system.schedule('TestAccountRevenueWeekleUpdate', schedule, oneWeek);
        Test.stopTest();
    }
}

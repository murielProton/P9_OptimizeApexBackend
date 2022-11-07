/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-07-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class AccountUpdateExecute_Queueable_Test {
    @isTest
    static void testRunAccountUpdate(){
        Test.startTest();
        AccountUpdateExecute_Queueable oneWeek = new AccountUpdateExecute_Queueable();
        //every thursday at one AM
        String schedule = '0 0 1 ? * SUN *';
        system.schedule('TestAccountRevenueWeekleUpdate', schedule, oneWeek);
        Test.stopTest();
    }
}

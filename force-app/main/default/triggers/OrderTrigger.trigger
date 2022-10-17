/**
 * @description       : 
 * @author            : Muriel Proton
 * @group             : 
 * @last modified on  : 10-17-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger OrderTrigger on Order (after update) {
    System.debug('I am in the Trigger.');
    new OrderTriggerHandler().run();

}
/**
 * @description       : 
 * @author            : Muriel Proton
 * @group             : 
 * @last modified on  : 11-07-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger OrderTrigger on Order (after update, before update) {
    new OrderTriggerHandler().run();

}
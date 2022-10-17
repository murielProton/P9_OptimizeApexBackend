/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-17-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class OrderTriggerHandler extends TriggerHandler {
    List<Order> orderListNew =(List<Order>)Trigger.new;
    List<Order> orderListOld =(List<Order>)Trigger.old;


    public override void afterUpdate() {
        System.debug('I am in the OrderTrigger Handler');
        OrderTriggerHelper.setAccountRevenue(orderListNew, orderListOld);
    }
}

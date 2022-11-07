/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-07-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class OrderTriggerHandler extends TriggerHandler {
    List<Order> orderListNew =(List<Order>)Trigger.new;
    List<Order> orderListOld =(List<Order>)Trigger.old;

    public override void beforeUpdate() {
        OrderTriggerHelper.updateListOfOrdersNetAmounts(orderListNew, orderListOld);
    }

    public override void afterUpdate() {
        OrderTriggerHelper.updateListOfAccountsRevenue(orderListNew, orderListOld);
        OrderTriggerHelper.updateListOfAccountsRevenueWhenOrderStatusOrdered(orderListNew, orderListOld);
    }
    
}

/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-21-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class OrderDataFactory {
    public static Order getOrder(Account accountForThisTest, Contract contractForThisTest){
        Order orderToReturn = [SELECT Id, AccountId, TotalAmount, ShipmentCost__c, NetAmount__c
                               FROM Order
                               WHERE AccountId = :accountForThisTest.Id AND ContractId = :contractForThisTest.Id
                               LIMIT 1];
        return orderToReturn;
    }
    public static List<Order> getOrdersAll(){
        List<Order> orderList = [SELECT Id, 
                                        AccountId, 
                                        TotalAmount, 
                                        ShipmentCost__c,
                                        NetAmount__c,
                                        Status
                                  FROM Order];
        return orderList;
    }
    public static List<Order> getOrdersStatusOrdered(){
        List<Order> orderList = [SELECT Id, 
                                        AccountId, 
                                        TotalAmount, 
                                        ShipmentCost__c,
                                        NetAmount__c,
                                        Status
                                  FROM Order
                                  WHERE Status ='Ordered'];
        return orderList;
    }

    // Used in Qeueable Batch
    // PricebookEntry modification date >= today -7 jours
    // find list of Orders Linked to a Pricebook2 that is linked to a PricebookEntry which has been modified during this week.
    public static List<Order> getOrdersWheregetPriceBook2ListWherePricebookEntryLastModifiedDate(){
        DateTime dateTimeLastWeek = DateTime.now().addDays(-7);

        List<Order> ordersListtoReturn=[SELECT Id, Pricebook2Id, AccountId, NetAmount__c, TotalAmount FROM Order WHERE Pricebook2Id IN (SELECT Pricebook2Id FROM PricebookEntry WHERE LastModifiedDate > :dateTimeLastWeek)];

        return ordersListtoReturn;
    }
    public static List<Order> getOrdersListOfNewOrdered(Set<Order> orderSetNew, Set<Order> orderSetOld){
        List<Order> orderListToReturn = new List<Order>();
        for(Order orderCurentNew : orderSetNew){
            if(orderCurentNew.Status == 'Ordered'){
                for(Order orderCurentOld : orderSetOld){
                    if(orderCurentOld.Id == orderCurentNew.Id &&
                    orderCurentOld.Status != 'Ordered'){
                        if(orderListToReturn.contains(orderCurentNew)==false){
                            orderListToReturn.add(orderCurentNew);
                        }
                    }else{
                        continue;
                    }
                }
            }else{
                continue;
            }
        }
        return orderListToReturn;
    }

    public static Order constructOneOrder(String orderName, Id accountID, Id contractID , PriceBook2 pricebookForThisTest){
        Order orderConstructed = new Order(
            Name = orderName,
            AccountId = accountID,
            ContractId = contractID,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            ShipmentCost__c = 10,
            // essential for the creation of OrderItem
            Pricebook2Id =  pricebookForThisTest.Id
            //TotalAmount = not writable This is Why Order links to a Product2 with OrderItem
        );
        return orderConstructed;
    }

    public static void createOrdersListForEachContract(List<Contract> contractListToCreateOrders, PriceBook2 pricebookForThisTest){
        List<Order> ordersList = new List<Order>();
        String orderName = 'Order-';
        for(Contract contractCurent : contractListToCreateOrders){
            ordersList.add(constructOneOrder(orderName+contractCurent.Name, contractCurent.AccountId, contractCurent.Id , pricebookForThisTest));
        }
        insert ordersList;
    } 
    public static void updateOrderShipmentCost(Order orderToUpdate){
        orderToUpdate.ShipmentCost__c = 20;
        update orderToUpdate;
    }
    public static void updateOrdersListStatusToOrdered(List<Order> orderList){
        List<Order> ordersListToUpdate = new List<Order>();
        for(Order orderCurent : orderList){
            orderCurent.Status = 'Ordered';
            ordersListToUpdate.add(orderCurent);
        }
        update ordersListToUpdate;
    }
    
    public static Set<Order> convertOrderListIntoSet(List<Order> ordersList){
        Set<Order> ordersSet = new Set<Order>();
            for(Order orderCurrent : ordersList){
                ordersSet.add(orderCurrent);    
            }
        return ordersSet;
    }

    // filter Sets
    public static Set<Order> filterOrderSetForStatusOrdered(Set<Order> orderSetNew){
        Set<Order> orderSetToReturn = new Set<Order>();
        for(Order orderCurentNew : orderSetNew){
            if(orderCurentNew.Status == 'Ordered'){
                orderSetToReturn.add(orderCurentNew);
            }
            continue;
        }
        return orderSetToReturn;
    }
    public static Set<Order> filterOrderSetForStatusNotOrdered(Set<Order> orderSetOld){
        Set<Order> orderSetToReturn = new Set<Order>();
        for(Order orderCurentOld : orderSetOld){
            if(orderCurentOld.Status != 'Ordered'){
                orderSetToReturn.add(orderCurentOld);
            }
            continue;
        }
        return orderSetToReturn;
    }
    public static List<Order> filterOrderSetForStatusJustChanged(Set<Order> orderSetOld, Set<Order> orderSetNew){
        Set<String> idOrderSet =new Set<String>();
        for(Order curent : orderSetOld) {
            idOrderSet.add(curent.ID);
        }
        List<Order> orderSetToReturn = new List<Order>();
        for(Order orderCurentNew : orderSetNew){
            if(idOrderSet.contains(orderCurentNew.ID) && !orderSetToReturn.contains(orderCurentNew)){
                orderSetToReturn.add(orderCurentNew);
            }
        }
        return orderSetToReturn;
    }
}

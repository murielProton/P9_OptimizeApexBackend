/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-31-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Order_TestDataFactory {
    public static Order getOrder(Account accountForThisTest, Contract contractForThisTest){
        Order orderToReturn = [SELECT Id, AccountId, TotalAmount, ShipmentCost__c
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
                                        Status
                                  FROM Order];
        return orderList;
    }
    public static List<Order> getOrdersStatusOrdered(){
        List<Order> orderList = [SELECT Id, 
                                        AccountId, 
                                        TotalAmount, 
                                        ShipmentCost__c,
                                        Status
                                  FROM Order
                                  WHERE Status ='Ordered'];
        return orderList;
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
    public static void createOrdersList(Integer numberOfOrdersToCreate, Id accountID, Id contractID , PriceBook2 pricebookForThisTest){
        List<Order> ordersList = new List<Order>();
        String orderName = 'Order-';
        for(Integer i=0 ; i<numberOfOrdersToCreate ; i++){
            ordersList.add(constructOneOrder(orderName+i, accountID, contractID , pricebookForThisTest));
        }
        insert ordersList;
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
        System.debug('before updateOrdersListStatusToOrdered '+orderList);
        for(Order orderCurent : orderList){
            orderCurent.Status = 'Ordered';
            ordersListToUpdate.add(orderCurent);
        }
        System.debug('after updateOrdersListStatusToOrdered '+ordersListToUpdate);
        update ordersListToUpdate;
    }
}

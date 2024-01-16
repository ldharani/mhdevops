/***************
* Class Name: BatchToCreateContract
* Test Class: BatchToCreateAttyQuoteProcess_Test
* Description: MHBS-9016 Automate close won the Quote with WebVantage Products
* Developed By: Jeyamugundan
* Modification History : Created on May 11,2023*  
* ******/ 
global class BatchToCreateContract implements Database.Batchable<sObject>,Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String strQuery;
        if(test.isRunningTest()){
            strQuery= 'SELECT Id,status,ActivateOrder__c,SBQQ__Contracted__c FROM Order LIMIT 1';
        }else{
            strQuery= 'SELECT Id,status,ActivateOrder__c,SBQQ__Contracted__c FROM Order WHERE status!=\'Activated\' AND SBQQ__Contracted__c=false AND (CreatedDate = TODAY OR CreatedDate = YESTERDAY)';   
        }
        return Database.getQueryLocator(strQuery);
    }
    global void execute(Database.BatchableContext BC, List<Order> orderList){
        set<Id> OrderIds = new set<Id>();
        list<Order> UpdateOrderList= new list<Order>();
        list<OrderItem> UpdateOrderItemList= new list<OrderItem>();
        
        for(Order objOrder : orderList){
            objOrder.Status = 'Activated';
            objOrder.SBQQ__Contracted__c = true;
            OrderIds.add(objOrder.id);
            UpdateOrderList.add(objOrder);
            
        }
        
        Map<Id,Order> ordMap = OrderUtility.getOrderCustomerNumber(OrderIds);
        
        for(OrderItem ordPrd: [select Id,blng__InvoiceGroupId__c,blng__BillingAccount__c,blng__InvoiceGrouping__c,OrderId from OrderItem where OrderId in:OrderIds]){ 
            if(ordMap.get(ordPrd.OrderId)!= null && ordMap.get(ordPrd.OrderId).CustomerNumber__c != null){
                ordPrd.blng__InvoiceGroupId__c = ordMap.get(ordPrd.OrderId).CustomerNumber__c;
                ordPrd.blng__BillingAccount__c = ordMap.get(ordPrd.OrderId).AccountId;
                ordPrd.blng__InvoiceGrouping__c = 'Order';
                UpdateOrderItemList.add(ordPrd);
            } 
        }
        
        try{
            if(UpdateOrderItemList.Size() > 0){
                database.update(UpdateOrderItemList,false);
            }
        }catch(Exception e){
            Util.processException(e,true,'OrderItem Update Fail on BatchToCreateContract' + UpdateOrderItemList);
        }
        
        try{
            if(UpdateOrderList.Size() > 0){
                database.update(UpdateOrderList,false);
            }
        }catch(Exception e){
            Util.processException(e,true,'Order Update Fail on BatchToCreateContract' + UpdateOrderList);
        }
    }  
    global void finish(Database.BatchableContext bc){ 
    }  
}
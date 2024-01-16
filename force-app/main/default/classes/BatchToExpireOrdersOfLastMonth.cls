/***********************************************************************************************************************
 * @author - CK
 * @date - 15 Sep 2022
 * @description - To expire Order Products & Orders that have end date older than a month from today. 
 					Also initiates the Contract expiration batch
 * @testclass - BatchToExpireOrdersContracts_Test
 * JIRA - MHBS-5341

Change History
************************************************************************************************************************

************************************************************************************************************************/

global class BatchToExpireOrdersOfLastMonth implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    private Boolean simulateOrderItemDmlFailure = false;
    private Boolean simulateOrderDmlFailure = false;
    global string csvBodyOrderItem;
    global string headerValueOrderItem;
    global string csvBodyOrder;
    global string headerValueOrder;
    global List<Id> oItemIdList = new List<Id>();
    global List<Id> oItemIdListInput = new List<Id>();
    // Constructor1 to run the job for a list of Order Products
    public BatchToExpireOrdersOfLastMonth(List<Id> oItems){
        this.oItemIdListInput = oItems;
        csvBodyOrderItem = '';
        headerValueOrderItem = 'Order Product Id, Error Message \n';
        csvBodyOrder = '';
        headerValueOrder = 'Order Id, Error Message \n';
    }//End of Constructor1
    //Default constructor runs when the class is scheduled
    public BatchToExpireOrdersOfLastMonth(){
        csvBodyOrderItem = '';
        headerValueOrderItem = 'Order Product Id, Error Message \n';
        csvBodyOrder = '';
        headerValueOrder = 'Order Id, Error Message \n';
    }//End of Constructor2
    //Constructor runs when the class is scheduled from test class for validating DML failure scenario
    public BatchToExpireOrdersOfLastMonth(Boolean simulateOrderDmlFailure,Boolean simulateOrderItemDmlFailure) {
        this.simulateOrderItemDmlFailure = simulateOrderItemDmlFailure;
        this.simulateOrderDmlFailure = simulateOrderDmlFailure;
    }//End of Constructor3
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        system.debug('oItemIdListInput '+oItemIdListInput);
        if(oItemIdListInput!=null && !oItemIdListInput.isEmpty()){
            query = 'SELECT Id,Status__c, OrderId, Order.Status__c,SBQQ__BookingsIndicator__c FROM Orderitem WHERE Id IN: oItemIdListInput AND EndDate = LAST_N_MONTHS:1 AND Status__c = \'Active\'';
        }else{
            query = 'SELECT Id,Status__c, OrderId, Order.Status__c,SBQQ__BookingsIndicator__c FROM Orderitem WHERE EndDate = LAST_N_MONTHS:1 AND Status__c = \'Active\'';
        }
        system.debug('Query '+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Orderitem> orderItemList){
        system.debug('orderItemList '+orderItemList);
        List<OrderItem> orderItemUpdateList = new List<OrderItem>();
        Set<Id> orderIdstoExpire =  new Set<Id>();
        List<Order> orderUpdateList =  new List<Order>();
        try{
            //Setting & Updating Order Product status as Expired
            for(Orderitem oItem : orderItemList){
                // Check if we're in the test scenario where we want to simulate a DML failure
                if (Test.isRunningTest() && simulateOrderItemDmlFailure){
                    // Simulate a DML failure
                    oItem.SBQQ__BookingsIndicator__c = 'SBQQ__BookingsIndicator__c';
                    orderItemUpdateList.add(oItem); // This will cause a DML exception
                    if(oItem.Order.Status__c!='Expired'){
                        orderIdstoExpire.add(oItem.OrderId);
                    }
                }else{
                    oItem.Status__c = 'Expired';
                    orderItemUpdateList.add(oItem);
                    if(oItem.Order.Status__c!='Expired'){
                        orderIdstoExpire.add(oItem.OrderId);
                    }
                }
            }
            if(orderItemUpdateList!=null && !orderItemUpdateList.isEmpty()){
                Database.SaveResult[] srListOrdrItem = Database.update(orderItemUpdateList, false);
                system.debug('srListOrdrItem '+srListOrdrItem);
                for (Database.SaveResult sr : srListOrdrItem) {
                    if(sr.isSuccess()){
                        system.debug('Successfully Updated Order Product!');
                        oItemIdList.add(sr.getId());
                    }else{
                        system.debug('sr '+sr);
                        string errorMsg = '';
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            system.debug('Failed ID '+sr.getId());
                            csvBodyOrderItem += sr.getId() + ',';
                            errorMsg += err.getMessage() + ',';
                            
                        }
                        errorMsg = errorMsg.removeEnd(',');
                        csvBodyOrderItem += '"'+errorMsg + '"' + ','; 
                        csvBodyOrderItem += '\n';
                    }
                }
            }//End of Order Product expiration
            if(orderIdstoExpire!=null && !orderIdstoExpire.isEmpty()){
                for(OrderItem oi : [SELECT Id, Status__c, OrderId FROM OrderItem WHERE OrderId IN:orderIdstoExpire]){
                    if(oi.Status__c == 'Active'){
                        orderIdstoExpire.remove(oi.OrderId);
                    }  
                }
            }
            //Setting & Updating Order status as Expired
            if(orderIdstoExpire!=null && !orderIdstoExpire.isEmpty()){
                for(Order odr : [SELECT Id,AccountId, Status__c FROM Order WHERE Id IN:orderIdstoExpire]){
                    // Check if we're in the test scenario where we want to simulate a DML failure
                    if (Test.isRunningTest() && simulateOrderDmlFailure){
                        // Simulate a DML failure
                        odr.AccountId = odr.Id;
                        orderUpdateList.add(odr); // This will cause a DML exception
                    }else{
                        odr.Status__c = 'Expired';
                        orderUpdateList.add(odr);
                    }
                }
            }
            if(orderUpdateList!=null && !orderUpdateList.isEmpty()){
                Database.SaveResult[] srListOrdr = Database.update(orderUpdateList, false);
                system.debug('srListOrdr '+srListOrdr);
                for (Database.SaveResult sr : srListOrdr) {
                    if(sr.isSuccess()){
                        system.debug('Successfully Updated Order!');
                    }else{
                        system.debug('sr '+sr);
                        string errorMsg = '';
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            system.debug('Failed ID '+sr.getId());
                            csvBodyOrder += sr.getId() + ',';
                            errorMsg += err.getMessage() + ',';
                            
                        }
                        errorMsg = errorMsg.removeEnd(',');
                        csvBodyOrder += '"'+errorMsg + '"' + ','; 
                        csvBodyOrder += '\n';                
                    }
                }
            }//End of Order expiration
        }catch(Exception e){
            //Util.processException(e,true,'Error during Orders/Order Products Expiry');
            system.debug('Exception '+e.getMessage());
        }
    }
    public void finish(Database.BatchableContext BC){
        try{
            //Calling the integration logic to expire the Orders at the OFS using Order XML
            if(oItemIdList!=null && !oItemIdList.isEmpty()){
                system.debug('oItemIdList'+oItemIdList);
                BatchToExpireOrderProductsXMLIntegration b = new BatchToExpireOrderProductsXMLIntegration(oItemIdList);
                Database.executeBatch(b,100);
            }
        }catch(Exception e){
            Util.processException(e,true,'Error during Order xml callout from Order Month End Expiry Batch.');
        }
        try{
            //Tailing the Subscription & Contract expiration batch for the list of Order Items expired
            if(oItemIdList!=null && !oItemIdList.isEmpty()){
                BatchToExpireContractsOfLastMonth batchContract = new BatchToExpireContractsOfLastMonth(oItemIdList,true);
                Database.executeBatch(batchContract);
            }
        }catch(Exception e){
            Util.processException(e,true,'Error during Subscription/Contract expiry after Order Expiration.');
        }
        try{
            //Sends email whenever there is a failure in Order/Order Product update
            List<Month_end_expiration_email__c> emailSettingList = Month_end_expiration_email__c.getAll().values();
            String finalCsvOrderItem = '';
            String finalCsvOrder = '';
            List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
            if(csvBodyOrderItem!=null && csvBodyOrderItem != ''){finalCsvOrderItem = headerValueOrderItem + csvBodyOrderItem;}
            if(csvBodyOrder!=null && csvBodyOrder != ''){finalCsvOrder = headerValueOrder + csvBodyOrder;}
            if(finalCsvOrderItem != null && finalCsvOrderItem != ''){
                String orderItemCsvName= 'OrderItem_Update_Errors.csv';
                Messaging.EmailFileAttachment csvAttcOrderItem = new Messaging.EmailFileAttachment();
                csvAttcOrderItem.setFileName(orderItemCsvName);
                csvAttcOrderItem.setBody(Blob.valueOf(finalCsvOrderItem));
                efaList.add(csvAttcOrderItem);
            }
            if(finalCsvOrder != null && finalCsvOrder != ''){
                String orderCsvName= 'Order_Update_Errors.csv';
                Messaging.EmailFileAttachment csvAttcOrder = new Messaging.EmailFileAttachment();
                csvAttcOrder.setFileName(orderCsvName);
                csvAttcOrder.setBody(Blob.valueOf(finalCsvOrder));
                efaList.add(csvAttcOrder);
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{};
                for(Month_end_expiration_email__c email : emailSettingList){
                    String e1 = (String)email.Email__c;
                    toAddresses.add(e1);
                }
            if(toAddresses!=null && !toAddresses.isEmpty()){mail.setToAddresses(toAddresses);}
            mail.setSubject('Orders Month End Expiration Errors ');
            mail.setPlainTextBody('Please check the attachments for Order and/or OrderProduct errors encountered: ');
            if(!efaList.isEmpty()){        
                mail.setFileAttachments(efaList);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }catch(Exception e){
            Util.processException(e,true,'Error while sending Failure email from Order Month End expiration');
        }
    }
}
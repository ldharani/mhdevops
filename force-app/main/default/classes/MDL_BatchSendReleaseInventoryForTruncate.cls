/*****************************************************************************************
Created By : Lister Technologies
Modified Date : June 11,2015
Modified Purpose : MHBS-129
*****************************************************************************************/
global class MDL_BatchSendReleaseInventoryForTruncate implements Database.Batchable<sObject>,Database.AllowsCallouts {
    global String query;
    global User u;
    public List<Id> lstOrderProdIds;
    public List<Id> lstOrderProdToBeReleased;
    public List<invoiceit_s__Job_Product__c> lstOrderProdsToUpdate;
    public Date endDate;
    public Set<String> setInventoryIds;
    public Map<Id,String> mapOrderProductNInventoryId;
    public Set<String> setDuplicateInventoryIds;
    global MDL_BatchSendReleaseInventoryForTruncate(){
        u = [select Id, username from User where Id = :UserInfo.getUserId()];
        query = '';
        lstOrderProdIds = new List<Id>();
        endDate = Date.today().toStartOfMonth().addDays(-1);    
        //endDate = Date.newInstance(2016,06,30);   
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'Select Id,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c '+ 
                'from invoiceit_s__Job_Rate_Plan_Charge__c'+
                ' where invoiceit_s__Service_End_Date__c = :endDate and (RecordType.DeveloperName = \'MDL_Order_Rate_Plan_Charge\' or RecordType.DeveloperName = \'Nolo_Order_Rate_Plan_Charge\') and (invoiceit_s__Status__c = \'Expired\' or (invoiceit_s__Status__c = \'Truncated\' and invoiceit_s__Job_Rate_Plan__r.sentCancelXML__c = true)) and invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c!=\'\' and invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c!=null';
        if(Test.isRunningTest()){
            query += ' LIMIT 5';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<invoiceit_s__Job_Rate_Plan_Charge__c> scope){        
        setInventoryIds = new Set<String>();
        mapOrderProductNInventoryId = new Map<Id,String>();
        lstOrderProdToBeReleased = new List<Id>();
        setDuplicateInventoryIds = new Set<String>();
        lstOrderProdsToUpdate = new List<invoiceit_s__Job_Product__c>();    
        for(invoiceit_s__Job_Rate_Plan_Charge__c orderRPC : scope){
            setInventoryIds.add(orderRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c);
            lstOrderProdIds.add(orderRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c);
            mapOrderProductNInventoryId.put(orderRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,orderRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c);
        }
        for(invoiceit_s__Job_Rate_Plan_Charge__c jobRPC : [Select Id,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c from invoiceit_s__Job_Rate_Plan_Charge__c where invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c in :setInventoryIds and invoiceit_s__Service_End_Date__c > :endDate 
                                                            and (RecordType.DeveloperName = 'MDL_Order_Rate_Plan_Charge' or RecordType.DeveloperName = 'Nolo_Order_Rate_Plan_Charge') and (invoiceit_s__Status__c = 'Active' or invoiceit_s__Status__c = 'Renewed' or invoiceit_s__Status__c = 'Rebased')]){
            setDuplicateInventoryIds.add(jobRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c);
        }
        if(setDuplicateInventoryIds.size()>0){
            for(Id orderProdId : mapOrderProductNInventoryId.keyset()){
                if(!setDuplicateInventoryIds.contains(mapOrderProductNInventoryId.get(orderProdId))){
                    lstOrderProdToBeReleased.add(orderProdId);
                }
            }
            if(lstOrderProdToBeReleased.size()>0){
                if(!Test.isRunningTest()){
                    MDL_Integration_Vim_Efs.releaseInventoryRequestForOrderCancellationFromBatch(lstOrderProdToBeReleased,u.username);
                }
            }
            for(invoiceit_s__Job_Product__c jobProd : [Select Id,Released_Inventory_Id__c from invoiceit_s__Job_Product__c where Id in :lstOrderProdToBeReleased]){
                if(mapOrderProductNInventoryId.containsKey(jobProd.Id)){
                    jobProd.Released_Inventory_Id__c = mapOrderProductNInventoryId.get(jobProd.Id);
                    lstOrderProdsToUpdate.add(jobProd);
                }
            }
            if(lstOrderProdsToUpdate.size() > 0){
                Database.update(lstOrderProdsToUpdate);
            }
        }
        else{
            if(lstOrderProdIds.size()>0){
                if(!Test.isRunningTest()){
                    MDL_Integration_Vim_Efs.releaseInventoryRequestForOrderCancellationFromBatch(lstOrderProdIds,u.username);
                }
            }
            for(invoiceit_s__Job_Product__c jobProd : [Select Id,Released_Inventory_Id__c from invoiceit_s__Job_Product__c where Id in :lstOrderProdIds]){
                if(mapOrderProductNInventoryId.containsKey(jobProd.Id)){
                    jobProd.Released_Inventory_Id__c = mapOrderProductNInventoryId.get(jobProd.Id);
                    lstOrderProdsToUpdate.add(jobProd);
                }
            }
            if(lstOrderProdsToUpdate.size() > 0){
                Database.update(lstOrderProdsToUpdate);
            }
        }
        
    }
    global void finish(Database.BatchableContext BC) {
        Boolean dontExecute = false;
        for(AsyncApexJob batch :[Select ExtendedStatus,NumberOfErrors,Status,JobItemsProcessed,TotalJobItems from AsyncApexJob where Id = :BC.getJobId()]){         
            if(batch.TotalJobItems==batch.NumberOfErrors){
                dontExecute = true;
            }
        }
        if(dontExecute==false){
            List<String> toEmailAddress = new List<String>();    
            List<Id> lstUserIds = new List<Id>();   
            for(GroupMember gm : [Select UserOrGroupId from GroupMember where Group.DeveloperName = 'Release_Inventory_Report_group']){
                lstUserIds.add(gm.UserOrGroupId);
            }
            for(User u : [Select Email from User where Id in :lstUserIds]){
                toEmailAddress.add(u.Email);
            }
            try{
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
                mail.setSubject('Release Inventory batch report');      
                mail.setToAddresses(toEmailAddress);
                String body = '<html><body>The Release Inventory batch has completed running successfully<br><br>'+
                'Click on the following links to view more details regarding the run:<br>'+
                '(1) Report for Release Inventory - Success records  : <a href="https://na43.salesforce.com/00OF0000006J6Ls">https://na43.salesforce.com/00OF0000006J6Ls</a><br>'+
                '(2) Report for Release Inventory - Failed records : <a href="https://na43.salesforce.com/00OF0000006J6M2">https://na43.salesforce.com/00OF0000006J6M2</a><br>'+
                '(3) Report for InventoryIds present with future charges : <a href="https://na43.salesforce.com/00OF0000006J6M7">https://na43.salesforce.com/00OF0000006J6M7</a><br>';
                mail.setHtmlBody(body);
                mails.add(mail);
                Messaging.sendEmail(mails);
            }
            catch(Exception e){
                System.debug('An exception occured' + e.getMessage());
            }
        }
    }
}
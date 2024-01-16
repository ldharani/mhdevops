global class MDL_BatchRelInventoryForTruncateCustom implements Database.Batchable<sObject>,Database.AllowsCallouts {
    global String query;
    global User u;
    global List<Id> lstOrderProdIds;
    global MDL_BatchRelInventoryForTruncateCustom(){
        u = [select Id, username from User where Id = :UserInfo.getUserId()];
        query = '';
        lstOrderProdIds = new List<Id>();
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<String> lstInvIds = new List<String>();
        List<Release_Inventory_IDs__c> relInvIds = Release_Inventory_IDs__c.getAll().values();
        for(Release_Inventory_IDs__c rel : relInvIds){
            lstInvIds.add(rel.Inventory_ID__c);
        }       
        query = 'Select Id,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c '+ 
                'from invoiceit_s__Job_Rate_Plan_Charge__c'+
                ' where invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c in :lstInvIds and (invoiceit_s__Status__c = \'Expired\' or invoiceit_s__Status__c = \'Truncated\') and invoiceit_s__Service_End_Date__c = 2015-05-31';
        if(Test.isRunningTest()){
            query += ' and name like \'%test%\' LIMIT 5';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<invoiceit_s__Job_Rate_Plan_Charge__c> scope){
        List<invoiceit_s__Job_Product__c> lstOrderProdToUpdate = new List<invoiceit_s__Job_Product__c>();       
        for(invoiceit_s__Job_Rate_Plan_Charge__c orderRPC : scope){
            lstOrderProdIds.add(orderRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c);
        }
        /*for(invoiceit_s__Job_Product__c orderProd : [Select Inventory_Id__c from invoiceit_s__Job_Product__c where Id in :lstOrderProdIds]){
            orderProd.Inventory_Id__c = '';
            lstOrderProdToUpdate.add(orderProd);
        }*/
        if(!Test.isRunningTest()){
            if(lstOrderProdIds.size()>0){
                MDL_Integration_Vim_Efs.releaseInventoryRequestForOrderCancellationFromBatch(lstOrderProdIds,u.username);
            }
        }
        /*if(lstOrderProdToUpdate.size()>0){
            Database.update(lstOrderProdToUpdate,false);
        }*/
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}
global class MDL_BatchOrderExpiry implements Database.Batchable<sObject>,Database.AllowsCallouts{
    global String query;
    global Set<Id> setOrderIds;
    global Set<Id> setOrderRPCIds;
    global List<invoiceit_s__Job_Rate_Plan_Charge__c> listOrderRPCtoUpdate;
    global List<invoiceit_s__Job_Rate_Plan__c> listOrderRatePlantoUpdate;
    global User u;
    global MDL_BatchOrderExpiry() {
        u = [select Id, username from User where Id = :UserInfo.getUserId()];
        query ='';
        setOrderIds = new Set<Id>();
        setOrderRPCIds = new Set<Id>(); 
        listOrderRPCtoUpdate = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        listOrderRatePlantoUpdate = new List<invoiceit_s__Job_Rate_Plan__c>();
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'Select Id,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c ,invoiceit_s__Status__c,invoiceit_s__Price_Type__c,Shippable__c,invoiceit_s__Job_Rate_Plan__c '+
                'from invoiceit_s__Job_Rate_Plan_Charge__c ' + 
                'where  invoiceit_s__Service_End_Date__c < TODAY and (RecordType.DeveloperName = \'MDL_Order_Rate_Plan_Charge\' or RecordType.DeveloperName = \'Nolo_Order_Rate_Plan_Charge\') and (invoiceit_s__Status__c=\'Active\' or (invoiceit_s__Status__c=\'Truncated\' and invoiceit_s__Job_Rate_Plan__r.sentCancelXML__c=false))' ;
        if(Test.isRunningTest()) {
            query += ' LIMIT 5';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<invoiceit_s__Job_Rate_Plan_Charge__c> scope){
        Set<Id> setOrderRatePlanId = new Set<Id>();
        for(invoiceit_s__Job_Rate_Plan_Charge__c orderRPC : scope) {
            if(orderRPC.invoiceit_s__Price_Type__c!='One Time' && !(orderRPC.Shippable__c=='Yes' && orderRPC.invoiceit_s__Price_Type__c=='Monthly')){
                setOrderIds.add(orderRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c);
                setOrderRPCIds.add(orderRPC.Id);
            }            
        }      
        
        if(setOrderIds.size()>0 && setOrderRPCIds.size()>0){           
            if(!Test.isRunningTest()){
                    MDL_Integration_Vim_Efs.orderRequestFromBatch(setOrderIds,u.userName,setOrderRPCIds);
            }
        }
        for(invoiceit_s__Job_Rate_Plan_Charge__c orderRPC : scope){
            if(orderRPC.invoiceit_s__Status__c != 'Truncated'){
                orderRPC.invoiceit_s__Status__c = 'Expired';
                listOrderRPCtoUpdate.add(orderRPC);
            }
            else if(orderRPC.invoiceit_s__Status__c == 'Truncated'){
                setOrderRatePlanId.add(orderRPC.invoiceit_s__Job_Rate_Plan__c);
            }
        }
        
        for(invoiceit_s__Job_Rate_Plan__c rp : [select Id,sentCancelXML__c from invoiceit_s__Job_Rate_Plan__c where Id in :setOrderRatePlanId]){
            rp.sentCancelXML__c=true ;
            listOrderRatePlantoUpdate.add(rp);
        }
        
        if(listOrderRPCtoUpdate.size()>0)
        Database.update(listOrderRPCtoUpdate,false);
        
        if(listOrderRatePlantoUpdate.size()>0)
        Database.update(listOrderRatePlantoUpdate,false);    
                
        
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}
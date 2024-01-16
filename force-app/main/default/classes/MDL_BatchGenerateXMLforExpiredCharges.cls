//Author            : akash
//Description       : To generate XML for expired charges, this batch is cascading from
//                    MDL_BatchChargesExpiry class



global class MDL_BatchGenerateXMLforExpiredCharges implements Database.Batchable<sObject>,Database.AllowsCallouts{
    global String query;
    global Date previousmonthEndDate;
    
  
    global User u;
    global MDL_BatchGenerateXMLforExpiredCharges() {
        u = [select Id, username from User where Id = :UserInfo.getUserId()];
        query ='';
        previousmonthEndDate = Date.today().toStartofMonth().addDays(-1); 
       
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'select id, Name, Charge_Expired__c, '+
                       ' (Select Id,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c ,invoiceit_s__Status__c,invoiceit_s__Price_Type__c,Shippable__c,invoiceit_s__Job_Rate_Plan__c '+
                     ' from invoiceit_s__Order_Rate_Plan_Charges__r ' + 
                    ' where  invoiceit_s__Service_End_Date__c =:previousmonthEndDate and (RecordType.DeveloperName = \'MDL_Order_Rate_Plan_Charge\' or RecordType.DeveloperName = \'Nolo_Order_Rate_Plan_Charge\') and (invoiceit_s__Status__c=\'Expired\' OR invoiceit_s__Status__c=\'Truncated\')) '+
                        ' From invoiceit_s__Job__c '+
                        ' where Charge_Expired__c = True';
            
         if(Test.isRunningTest()) {
            query += ' order by CreatedDate DESC LIMIT 5';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<invoiceit_s__Job__c> orderList){
        
        set<Id> setOrderIds                                          = new set<Id>();
        Set<Id> setOrderRPCIds                                       = new set<Id>();
        Set<Id> setOrderRatePlanId                                   = new Set<Id>();
        List<invoiceit_s__Job_Rate_Plan__c>listOrderRatePlantoUpdate = new List<invoiceit_s__Job_Rate_Plan__c>();
        
        for(invoiceit_s__Job__c order : orderList){
            order.Charge_Expired__c = false;
            for(invoiceit_s__Job_Rate_Plan_Charge__c charge : order.invoiceit_s__Order_Rate_Plan_Charges__r){ 
                if(charge.invoiceit_s__Price_Type__c!='One Time' && !(charge.Shippable__c=='Yes' && charge.invoiceit_s__Price_Type__c=='Monthly')){
                  setOrderIds.add(charge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c);
                  setOrderRPCIds.add(charge.Id);
              }
                if(charge.invoiceit_s__Status__c == 'Truncated'){
                  setOrderRatePlanId.add(charge.invoiceit_s__Job_Rate_Plan__c);
              }
                
            }
             
        }
        
        if(setOrderIds.size()>0 && setOrderRPCIds.size()>0){           
            if(!Test.isRunningTest()){
                    MDL_Integration_Vim_Efs.orderRequestFromBatch(setOrderIds,u.userName,setOrderRPCIds);
            }
        }
       
         for(invoiceit_s__Job_Rate_Plan__c rp : [select Id,sentCancelXML__c from invoiceit_s__Job_Rate_Plan__c where Id in :setOrderRatePlanId]){
            rp.sentCancelXML__c=true ;
            listOrderRatePlantoUpdate.add(rp);
        }
        database.update(orderList,false);
        
        if(listOrderRatePlantoUpdate.size()>0){
            Database.update(listOrderRatePlantoUpdate,false);  
        }
        
        
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}
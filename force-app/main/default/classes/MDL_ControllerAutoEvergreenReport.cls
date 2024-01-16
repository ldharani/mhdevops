/**********************************************************************************************
Created By : Lister Technologies
Created Date : September 23,2015
Created Purpose : Report of orders that will be processed by Automate Evergreen process batch
Controller for MDL_AutoEvergreenReport
**********************************************************************************************/
public with sharing class MDL_ControllerAutoEvergreenReport {
    public String queryOrders;
    public Set<Id> setOrderIds;
    public Set<Id> setErrorOrderIds;
    public Set<Id> setExcludeOrderIds;
    public Set<Id> setCorrectOrderIds;
    public Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>> mapOrderIdNLstOrderRPC;
    public Date endDate;
    public Integer noOfDays;
    public MDL_ControllerAutoEvergreenReport(){
        setOrderIds = new Set<Id>();
        setErrorOrderIds = new Set<Id>();
        setCorrectOrderIds = new Set<Id>();
        setExcludeOrderIds = new Set<Id>();
        mapOrderIdNLstOrderRPC = new Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>>();
        endDate = Date.Today().addmonths(1).toStartOfMonth().addDays(-1);
    }
    public PageReference downloadReport(){
        try{
            String query = 'Select '+getObjectFields('invoiceit_s__Job__c')+' from invoiceit_s__Job__c where invoiceit_s__Service_End_Date__c = :endDate and invoiceit_s__Status__c = \'Active\' and Renew_Rebase__c = null and invoiceit_s__Account__r.Credit_Status__c!=\'Bad Debt\' and invoiceit_s__Account__r.Credit_Status__c!=\'Past Due\' and  invoiceit_s__Account__r.BillingCountry!=\'Canada\' and Do_Not_Renew__c!=true and invoiceit_s__Account__r.Sub_Type__c = \'Small Law\' and (RecordType.DeveloperName = \'MH_Orders\' OR RecordType.DeveloperName = \'Nolo_Order\')';
            if(Test.isRunningTest()){
                query += ' and invoiceit_s__Account__r.Name like \'%testAcc%\' LIMIT 5';
            }
            List<invoiceit_s__Job__c> queryOrders = Database.query(query);
            for(invoiceit_s__Job__c order : queryOrders){
                setOrderIds.add(order.Id);
            }
            //consider only Active and 'Monthly' charges
            for(invoiceit_s__Job_Rate_Plan_Charge__c orderRPC : [Select Id,invoiceit_s__Service_End_Date__c,invoiceit_s__Order__c,invoiceit_s__Price_Type__c from invoiceit_s__Job_Rate_Plan_Charge__c where invoiceit_s__Order__c in :setOrderIds and invoiceit_s__Status__c = 'Active' and invoiceit_s__Price_Type__c='Monthly' and Renewable__c = true]){
                if(mapOrderIdNLstOrderRPC.containsKey(orderRPC.invoiceit_s__Order__c)){
                    mapOrderIdNLstOrderRPC.get(orderRPC.invoiceit_s__Order__c).add(orderRPC);
                }
                else{
                    mapOrderIdNLstOrderRPC.put(orderRPC.invoiceit_s__Order__c,new List<invoiceit_s__Job_Rate_Plan_Charge__c>{orderRPC});
                }
            }
            // check if the service end dates of the order and the charges are same
            for(Id orderId : mapOrderIdNLstOrderRPC.keyset()){
                for(invoiceit_s__Job_Rate_Plan_Charge__c jobRPC : mapOrderIdNLstOrderRPC.get(orderId)){
                    if(jobRPC.invoiceit_s__Service_End_Date__c!=endDate){
                        setErrorOrderIds.add(jobRPC.invoiceit_s__Order__c);
                    }
                }
            }
            //to exclude orders which have opportunities in 'QA Review' or 'Closed Won' or 'QA Rejected' Stage
            for(Opportunity opp : [Select Id,Created_From_Order__c from Opportunity where Created_From_Order__c in :mapOrderIdNLstOrderRPC.keyset() and (StageName = 'QA Review' or StageName = 'Closed Won' or StageName = 'QA Rejected')]){
                setExcludeOrderIds.add(opp.Created_From_Order__c);
            }
            for(Id orderId : mapOrderIdNLstOrderRPC.keyset()){
                if(!setErrorOrderIds.contains(orderId) && !setExcludeOrderIds.contains(orderId)){
                    setCorrectOrderIds.add(orderId);
                }
            }
            if(setCorrectOrderIds.size() > 0){
                if(!Test.isRunningTest()){
                    return new PageReference('/apex/MDL_AutoEvergreenReportExcel');
                }        
            }
            else{
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Info,'No order records found that would be processed for Automate Evergreen'); 
                ApexPages.addMessage(errMsg); 
                return null;
            }
        }catch(Exception e){
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()); 
            ApexPages.addMessage(errMsg); 
            return null;
        }
        return null;
    }
    public static String getObjectFields(String objectName) {
        String sQuery = '';
        Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for(Schema.SObjectField column: objectFieldMap.values()) {
            sQuery += column+', ';
        }
        sQuery = sQuery.substring(0, sQuery.length()-2);
        sQuery += ' ';
        return sQuery;
    }
}
/*****************************************************************************************************
Created By : Lister Technologies
Created Date : September 23,2015
Created Purpose : Report in excel of orders that will be processed by Automate Evergreen process batch
Controller for MDL_AutoEvergreenReportExcel
******************************************************************************************************/
public with sharing class MDL_ControllerAutoEvergreenExcel {
    public transient String queryOrders;
    public transient Set<Id> setOrderIds;
    public transient Set<Id> setErrorOrderIds;
    public transient Set<Id> setExcludeOrderIds;
    public transient Set<Id> setCorrectOrderIds;
    public transient Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>> mapOrderIdNLstOrderRPC;
    public transient Date endDate;
    public transient Integer noOfDays;
    public transient List<invoiceit_s__Job__c> lstOrders{get;set;}
    public transient String todayName {get;set;}
    public MDL_ControllerAutoEvergreenExcel(){
        setOrderIds = new Set<Id>();
        setErrorOrderIds = new Set<Id>();
        setCorrectOrderIds = new Set<Id>();
        setExcludeOrderIds = new Set<Id>();
        mapOrderIdNLstOrderRPC = new Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>>();
        lstOrders = new List<invoiceit_s__Job__c>();
        todayName = getname(Date.Today().month())+'_'+Date.Today().day()+'_'+Date.Today().year();
        endDate = Date.Today().addmonths(1).toStartOfMonth().addDays(-1);
        
        String query = 'Select '+getObjectFields('invoiceit_s__Job__c')+',invoiceit_s__Account__r.MH_Cust_Number__c,invoiceit_s__Account__r.Name, invoiceit_s__Account__r.BillingCountry,invoiceit_s__Billing_Contact__r.Email, invoiceit_s__Account__r.Owner.Name from invoiceit_s__Job__c where invoiceit_s__Service_End_Date__c = :endDate and invoiceit_s__Status__c = \'Active\' and Renew_Rebase__c = null and invoiceit_s__Account__r.Credit_Status__c!=\'Bad Debt\' and invoiceit_s__Account__r.Credit_Status__c!=\'Past Due\' and invoiceit_s__Account__r.BillingCountry!=\'Canada\' and Do_Not_Renew__c!=true and invoiceit_s__Account__r.Sub_Type__c = \'Small Law\' and (RecordType.DeveloperName = \'MH_Orders\' OR RecordType.DeveloperName = \'Nolo_Order\')';
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
        for(invoiceit_s__Job__c order : queryOrders){
            if(setCorrectOrderIds.contains(order.Id)){
                lstOrders.add(order);
            }
        }
    }
    public static String getObjectFields(String objectName) {
        String sQuery = '';
        Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for(Schema.SObjectField column: objectFieldMap.values()) {
            //system.debug('column Name is ' + column + 'column permission' + column.getDescribe().isUpdateable());
            sQuery += column+', ';
        }
        sQuery = sQuery.substring(0, sQuery.length()-2);
        sQuery += ' ';
        return sQuery;
    }
    public  String getname(Integer monthSelected){
        String monthName;
        if(monthSelected==1)monthName = 'January';
        else if(monthSelected==2)monthName = 'February';
        else if(monthSelected==3)monthName = 'March';
        else if(monthSelected==4)monthName = 'April';
        else if(monthSelected==5)monthName = 'May';
        else if(monthSelected==6)monthName = 'June';
        else if(monthSelected==7)monthName = 'July';
        else if(monthSelected==8)monthName = 'August';
        else if(monthSelected==9)monthName = 'September';
        else if(monthSelected==10)monthName = 'October';
        else if(monthSelected==11)monthName = 'November';
        else if(monthSelected==12)monthName = 'December';
        return monthName;       
    }
}
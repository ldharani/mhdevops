/*
Apex Class   : Trigger_QuoteLineConsumptionRate_Helper
Created By   : Serge Kandukuri
Description  : This is Helper class for QuoteLineConsumptionRateTrigger
*/
@RestResource(urlMapping='/usageAPI/createUsage/*')
global with sharing class usageAPI{
    @HttpPost
    global static feedbackResponse createUsage() {
    
        RestRequest restRqst = RestContext.request;
        RequestParams req = (RequestParams)Json.deserialize(restRqst.requestBody.toString(),RequestParams.class);
        feedbackResponse objFR = new feedbackResponse();
        string[] arrString = new String[]{};
        // List<OrderItem> lstOI = [SELECT Id, OrderId FROM OrderItem WHERE OrderItemNumber =: req.blng_OrderProduct_c AND SIN__c =: req.blng_SIN_Number_c];
        List<OrderItem> lstOI = [SELECT Id, OrderId, Order.AccountId FROM OrderItem WHERE SIN__c =: req.blng_SIN_Number_c];
       
        if(!lstOI.isEmpty()){
            
            datetime dtTimePST;
            date dtPST;
            try{
                String strStartDatePST = string.valueOf(req.blng_StartDateTime_c).split('T')[0];
                String strStartTimePST = string.valueOf(req.blng_StartDateTime_c).split('T')[1];
                strStartTimePST = strStartTimePST.replace('Z','');
                dtPST = date.valueOf(strStartDatePST);
                
                dtTimePST = datetime.valueOf(strStartDatePST + ' ' + strStartTimePST);
            }catch (Exception ex){
                arrString.add('Invaid datetime format.');
                objFR.success = false;
                objFR.errors = arrString;
                return objFR;
            }
            List<blng__UsageSummary__c> lstUsageSummary = [SELECT Id, blng__MatchingId__c, blng__MatchingAttribute__c, blng__UnitOfMeasure__c FROM blng__UsageSummary__c WHERE blng__OrderProduct__c =: lstOI[0].id AND blng__SummaryStartDate__c <=: dtPST AND blng__SummaryEndDate__c >=: dtPST];
            system.debug('@@@@@@@@@@@@@'+lstUsageSummary.size());
            system.debug('@@@@@@@@@@@@@'+lstUsageSummary);
            if(!lstUsageSummary.isEmpty()){
                blng__Usage__c objUsage = new blng__Usage__c();
                objUsage.blng__Account__c = lstOI[0].Order.AccountId;
                objUsage.blng__Order__c = lstOI[0].OrderId;
                objUsage.blng__OrderProduct__c = lstOI[0].Id;
                
                
                objUsage.blng__StartDateTime__c = dtTimePST;
                objUsage.blng__EndDateTime__c = dtTimePST;
                objUsage.Lead_Id__c = req.blng_Lead_Id_c;
                objUsage.First_name__c = req.firstName;
                objUsage.Last_name__c = req.lastName;
                objUsage.Email__c = req.email;
                objUsage.Phone__c = req.phone;
              
                
                objUsage.blng__Quantity__c = 1;
                objUsage.blng__UsageSummary__c = lstUsageSummary[0].id;
                objUsage.blng__MatchingId__c = lstUsageSummary[0].blng__MatchingId__c;
                objUsage.blng__MatchingAttribute__c = lstUsageSummary[0].blng__MatchingAttribute__c;
                objUsage.blng__UnitOfMeasure__c = lstUsageSummary[0].blng__UnitOfMeasure__c;
                objUsage.Lead_Id__c = req.blng_Lead_Id_c;
                system.debug('#########'+objUsage);
                if(Test.isRunningTest() == false){
                    insert objUsage;
                    objFR.id = objUsage.id;
                }
                objFR.success = true;
                return objFR;
            }else{
                arrString.add('Usage Summary not found.');
            }
        }else{
            arrString.add('Order Product not found.');
        }
        objFR.success = false;
        objFR.errors = arrString;
        return objFR;
    }
    
   
    
    global class feedbackResponse {
        global String id{get;set;}
        global boolean success{get;set;}
        global String[] errors{get;set;}
        
    }

    global class RequestParams{
        global String blng_SIN_Number_c{get;set;}
        global String blng_Lead_Id_c{get;set;}
        // global String blng_OrderProduct_c{get;set;}
        global string blng_StartDateTime_c{get;set;}
        global String firstName {get;set;}
        global String lastName {get;set;}
        global String email {get;set;}
        global String phone {get;set;}       
    }
}
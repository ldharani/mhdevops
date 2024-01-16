@isTest(seealldata = true)
public with sharing class MDL_TestCntlrAutoEvergreenReportExcel {
    static testMethod void testAutomateProcess(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
        Account acc = util.getAccount();
        acc.Credit_Status__c = 'Good Standing';
        acc.Sub_Type__c = 'Small Law';
        update acc; 
                
        invoiceit_s__Currency__c cur = util.getCurrencyObject();
        
        invoiceit_s__Product__c prod = util.getProduct('false'); 
        prod.Product_Provisioning__c = 'Manual Fulfillment';
        update prod;               
        invoiceit_s__Product_Rate_Plan__c pRP = util.getProductRatePlan(prod.Id);       
        invoiceit_s__Product_Rate_Plan_Charge__c pRPC = util.getProductRatePlanCharge(cur.Id, pRP.Id);
        pRPC.Renewable__c = true;
        insert pRPC;
        
        invoiceit_s__Job__c order = new invoiceit_s__Job__c();
        order.Name = 'Test Order for Auto Evergreen Report';
        order.invoiceit_s__Account__c   = acc.Id;
        order.invoiceit_s__CurrencyL__c = cur.Id;
        order.invoiceit_s__Status__c = 'Active';
        order.invoiceit_s__Number_Of_Terms__c = 1;
        order.invoiceit_s__Discount_Percent__c = 0.0;  
        order.invoiceit_s__Service_Activation_Date__c = Date.today().toStartOfMonth();
        order.invoiceit_s__Service_End_Date__c = Date.today().addMonths(1).toStartOfMonth().addDays(-1);   
        order.IsDataLoaded__c = 'Y';                
        insert order;
        
        
        invoiceit_s__Job_Product__c oProd = util.getOrderProduct(order.Id ,prod.Id);
        invoiceit_s__Job_Rate_Plan__c oRP = util.getOrderRatePlan(oProd.Id , pRP.Id);
        
        invoiceit_s__Job_Rate_Plan_Charge__c jobRPC = new invoiceit_s__Job_Rate_Plan_Charge__c();
        jobRPC.Name = 'Test RPC for Auto Evergreen';
        jobRPC.invoiceit_s__Job_Rate_Plan__c = oRP.Id;
        jobRPC.invoiceit_s__Product_Rate_Plan_Charge__c = pRPC.Id;
        jobRPC.invoiceit_s__Quantity__c = 1;
        jobRPC.invoiceit_s__Status__c = 'Active';
        jobRPC.invoiceit_s__Price_Type__c = 'Monthly';      
        insert jobRPC;
        
        Test.startTest();
            MDL_ControllerAutoEvergreenExcel rep = new MDL_ControllerAutoEvergreenExcel();
        Test.stopTest(); 
    }
}
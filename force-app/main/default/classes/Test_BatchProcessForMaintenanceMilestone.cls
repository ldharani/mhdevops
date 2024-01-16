@isTest(seeAlldata = true)
public class Test_BatchProcessForMaintenanceMilestone {
    
    static testmethod void run2condition(){
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        
        Account a = testData.getAccount();
        
        Contact c = testData.getContact(a.Id);  
        
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
        invoiceit_s__Product__c product = testData.getProduct('false');
        product.Product_Provisioning__c = 'Manual Fulfillment';
        update product;
        
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);
        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);
        
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);
        
         
        
        invoiceit_s__Job__c order = testData.getOrder(a.Id, CurrencyObj.Id);
        
        invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
        invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge =  new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC', invoiceit_s__Job_Rate_Plan__c =orderRatePlan.Id,
                                                                                               invoiceit_s__Quantity__c = 12, invoiceit_s__Price_Type__c = 'One Time',
                                                                                               invoiceit_s__Unit_Price__c = 12,invoiceit_s__Service_Activation_Date__c = system.today(),
                                                                                               invoiceit_s__Service_End_Date__c = system.today().addMonths(5),
                                                                                               Quote_Type__c = 'Renew', invoiceit_s__Accounting_Code__c='01808',
                                                                                               invoiceit_s__Price__c=10);
        
        Test.startTest();
        insert orderRatePlanCharge;
        
        invoiceit_s__Job_Rate_Plan_Charge__c charge1= new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC', invoiceit_s__Job_Rate_Plan__c =orderRatePlan.Id,
                                                                                               invoiceit_s__Quantity__c = 12, invoiceit_s__Price_Type__c = 'One Time',
                                                                                               invoiceit_s__Unit_Price__c = 12,invoiceit_s__Service_Activation_Date__c = system.today(),
                                                                                               invoiceit_s__Service_End_Date__c = system.today().addMonths(5),
                                                                                               Quote_Type__c = 'Renew', Created_From_Charge__c = orderRatePlanCharge.id,
                                                                                               invoiceit_s__Accounting_Code__c='01808',
                                                                                               invoiceit_s__Price__c=10);
        MDL_RecursionHandler.milestonecheck = True;
        insert charge1;
        System.debug('=====charge1.id===='+charge1.id);
        System.debug('=====account id===='+a.id);
        Milestone1_Project__c proj1 = new Milestone1_Project__c(Name = 'Platinum Project', Status__c = 'New', Next_Monthly_Milestone_Maintenance_Date__c = System.today(), 
                                                                Next_Quarterly_Milestone_Maint_Date__c = System.Today(),No_of_Maintenance_Milestone__c = 5,
                                                                Order_Rate_Plan_Charge__c=charge1.id, Account__c = a.id);
        
        proj1.recordTypeid= Schema.SObjectType.Milestone1_Project__c.getRecordTypeInfosByName().get('Platinum Project').getRecordTypeId();
        
        //proj1.recordtypeid = '0120G0000013c5H';
        insert proj1;
        System.debug('==========================project==================='+proj1);
        System.debug('==========================Next_Monthly_Milestone_Maintenance_Date__c==================='+proj1.Next_Monthly_Milestone_Maintenance_Date__c);
        System.debug('==========================No_of_Maintenance_Milestone__c==================='+proj1.No_of_Maintenance_Milestone__c);
        
        Milestone1_Milestone__c mil1 = new Milestone1_Milestone__c(Name = 'SEO Month 1.0 Video', Project__c = proj1.id, Status__c = 'Ready to Start');
        
        insert mil1;
        
        Product_code_to_Project_Mapping__c MonthlyMaint = new Product_code_to_Project_Mapping__c(Name = 'Monthly Video Maintenance', Milestone_Id__c = mil1.id,
                                                                                                Project_Name__c = 'Platinum_Maintenance');
        //insert MonthlyMaint;

        BatchProcesForMaintenanceMilestone b = new BatchProcesForMaintenanceMilestone(); 
        Database.executeBatch(b,1);
        Test.stopTest(); 

    }
}
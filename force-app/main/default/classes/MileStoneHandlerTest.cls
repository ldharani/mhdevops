@isTest(seeAlldata = true)
public class MileStoneHandlerTest {
    
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
        Test.stopTest();
    }
    
    static testmethod void scenario1(){
         MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();        
         Account a = testData.getAccount();    
         Contact c = testData.getContact(a.Id);
         Milestone1_Project__c project = new Milestone1_Project__c (name ='Content (General)');
         insert project;    
         invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
         //Milestone1_Milestone__c milestoneObj = new Milestone1_Milestone__c(Project__c = project.Id,Name ='SEO_Renewal');
         MileStoneHandler extn = new MileStoneHandler(new ApexPages.StandardController(project));
         extn.selectedProjName = 'Content (General)';
         extn.saveProject();
     }
    static testmethod void scenario2(){
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
                                                                                               Quote_Type__c = 'Renew', invoiceit_s__Accounting_Code__c='01809',
                                                                                               invoiceit_s__Price__c=10);
        
        Test.startTest();
        insert orderRatePlanCharge;
        invoiceit_s__Job_Rate_Plan_Charge__c charge1= new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC', invoiceit_s__Job_Rate_Plan__c =orderRatePlan.Id,
                                                                                               invoiceit_s__Quantity__c = 12, invoiceit_s__Price_Type__c = 'One Time',
                                                                                               invoiceit_s__Unit_Price__c = 12,invoiceit_s__Service_Activation_Date__c = system.today(),
                                                                                               invoiceit_s__Service_End_Date__c = system.today().addMonths(5),
                                                                                               Quote_Type__c = 'Renew', Created_From_Charge__c = orderRatePlanCharge.id,
                                                                                               invoiceit_s__Accounting_Code__c='01972',
                                                                                               invoiceit_s__Price__c=10);
        MDL_RecursionHandler.milestonecheck = True;
        insert charge1;
        Test.stopTest();
    }
    static testmethod void scenario3(){
         MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();        
         Account a = testData.getAccount();    
         Contact c = testData.getContact(a.Id);
         Milestone1_Project__c project = new Milestone1_Project__c (name ='Web Gold');
         insert project;    
         invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
         MileStoneHandler extn1 = new MileStoneHandler(new ApexPages.StandardController(project));
         extn1.selectedProjName = 'Web Gold';
         extn1.saveProject();
     }
}
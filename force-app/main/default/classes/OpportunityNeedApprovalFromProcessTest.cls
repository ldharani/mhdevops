@isTest(seealldata = true)
public with sharing class OpportunityNeedApprovalFromProcessTest{
    static testMethod void testOpportunityNeedApprovalFromProcess(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();        
        Account acc = util.getAccount();
        acc.Business_Unit__c = 'Nolo-Decline';
        update acc;
        Account acc2 = util.getAccount();
        Contact con = util.getContact(acc.Id);
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        
        invoiceit_s__Payment_Method__c p = util.getPaymentMethod(acc.Id);
        
        Opportunity opp1 = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
                invoiceit_crmx__CurrencyL__c = curr.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
                invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
                invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
                invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
                invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
                invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
                invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 9 , Type = 'New Business',
                Discount__c = 18,Promotional_Credit_Reason__c ='Credit Card',Promotional_Credit__c = 0,
                Promotional_Credit_Payment__c = true,Truncated_Order_Charges__c ='Test'
        );
        insert opp1;
        
        //creating single product
        invoiceit_s__Product__c singleproduct = util.getProduct('true');
        
         //creating single product rate plan
        invoiceit_s__Product_Rate_Plan__c singleprdrpl = util.getProductRatePlan(singleproduct.id);
        
        //creating single opp Product
        invoiceit_crmx__Opportunity_Product__c singleoppProd = util.getOpportunityProduct(singleproduct.id, opp1.Id);
        singleoppProd.Product_SIN__c = 'test';
        update singleoppProd;
        
        invoiceit_crmx__Opportunity_Product__c singleoppProd1 = util.getOpportunityProduct(singleproduct.id, opp1.Id);
        
        //creating single opp rate plan 
        invoiceit_crmx__Opportunity_Rate_Plan__c singleopprpl = util.getOpportunityRatePlan(singleoppProd.id, singleprdrpl.id);
        
        //creating sigle prod rate plan charge
        invoiceit_s__Product_Rate_Plan_Charge__c singleprodrpc = util.getProductRatePlanCharge(curr.id, singleprdrpl.id);
        insert singleprodrpc;
        
        //creating single opp rate plan charge
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c singlerpc = util.getOppRatePlanCharge(singleopprpl.id, singleprodrpc.id);
                
        opp1.invoiceit_crmx__Discount_Percent__c = 25;
        update opp1;
            
        List<Id> IdList = new List<Id>();
        IdList.add(opp1.Id);
        Test.startTest();            
        OpportunityNeedApprovalFromProcess.opptyUpdateFromProcess(IdList);            
        Test.stopTest();        
    }
    static testMethod void testOpportunityNeedApprovalFromProcess1(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();        
        Account acc = util.getAccount();
        acc.Business_Unit__c = 'Nolo-Decline';
        update acc;
        Account acc2 = util.getAccount();
        Contact con = util.getContact(acc.Id);
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        
        invoiceit_s__Payment_Method__c p = util.getPaymentMethod(acc.Id);
        
        Opportunity opp1 = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
                invoiceit_crmx__CurrencyL__c = curr.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
                invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
                invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
                invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
                invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
                invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
                invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 9 , Type = 'New Business',
                Discount__c = 18,Promotional_Credit_Reason__c ='Credit Card',Promotional_Credit__c = 0,
                Promotional_Credit_Payment__c = true,Truncated_Order_Charges__c ='Test'
        );
        insert opp1;
        
        //creating single product
        invoiceit_s__Product__c singleproduct = util.getProduct('true');
        
         //creating single product rate plan
        invoiceit_s__Product_Rate_Plan__c singleprdrpl = util.getProductRatePlan(singleproduct.id);
        
        //creating single opp Product
        invoiceit_crmx__Opportunity_Product__c singleoppProd = util.getOpportunityProduct(singleproduct.id, opp1.Id);
        singleoppProd.Product_SIN__c = 'test';
        update singleoppProd;
        
        invoiceit_crmx__Opportunity_Product__c singleoppProd1 = util.getOpportunityProduct(singleproduct.id, opp1.Id);
        
        //creating single opp rate plan 
        invoiceit_crmx__Opportunity_Rate_Plan__c singleopprpl = util.getOpportunityRatePlan(singleoppProd.id, singleprdrpl.id);
        
        //creating sigle prod rate plan charge
        invoiceit_s__Product_Rate_Plan_Charge__c singleprodrpc = util.getProductRatePlanCharge(curr.id, singleprdrpl.id);
        insert singleprodrpc;
        
        //creating single opp rate plan charge
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c singlerpc = util.getOppRatePlanCharge(singleopprpl.id, singleprodrpc.id);
                
        opp1.invoiceit_crmx__Discount_Percent__c = 32;
        update opp1;
            
        List<Id> IdList = new List<Id>();
        IdList.add(opp1.Id);
        Test.startTest();            
        OpportunityNeedApprovalFromProcess.opptyUpdateFromProcess(IdList);            
        Test.stopTest();        
    }
    static testMethod void testOpportunityNeedApprovalFromProcess2(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();        
        Account acc = util.getAccount();
        acc.Business_Unit__c = 'Nolo-Decline';
        update acc;
        Account acc2 = util.getAccount();
        Contact con = util.getContact(acc.Id);
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        
        invoiceit_s__Payment_Method__c p = util.getPaymentMethod(acc.Id);
        
        Opportunity opp1 = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
                invoiceit_crmx__CurrencyL__c = curr.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
                invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
                invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
                invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
                invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
                invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
                invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 9 , Type = 'New Business',
                Discount__c = 18,Promotional_Credit_Reason__c ='Credit Card',Promotional_Credit__c = 0,
                Promotional_Credit_Payment__c = true,Truncated_Order_Charges__c ='Test'
        );
        insert opp1;
        
        //creating single product
        invoiceit_s__Product__c singleproduct = util.getProduct('true');
        
         //creating single product rate plan
        invoiceit_s__Product_Rate_Plan__c singleprdrpl = util.getProductRatePlan(singleproduct.id);
        
        //creating single opp Product
        invoiceit_crmx__Opportunity_Product__c singleoppProd = util.getOpportunityProduct(singleproduct.id, opp1.Id);
        singleoppProd.Product_SIN__c = 'test';
        update singleoppProd;
        
        invoiceit_crmx__Opportunity_Product__c singleoppProd1 = util.getOpportunityProduct(singleproduct.id, opp1.Id);
        
        //creating single opp rate plan 
        invoiceit_crmx__Opportunity_Rate_Plan__c singleopprpl = util.getOpportunityRatePlan(singleoppProd.id, singleprdrpl.id);
        
        //creating sigle prod rate plan charge
        invoiceit_s__Product_Rate_Plan_Charge__c singleprodrpc = util.getProductRatePlanCharge(curr.id, singleprdrpl.id);
        insert singleprodrpc;
        
        //creating single opp rate plan charge
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c singlerpc = util.getOppRatePlanCharge(singleopprpl.id, singleprodrpc.id);
                
        opp1.invoiceit_crmx__Discount_Percent__c = 52;
        update opp1;
            
        List<Id> IdList = new List<Id>();
        IdList.add(opp1.Id);
        Test.startTest();            
        OpportunityNeedApprovalFromProcess.opptyUpdateFromProcess(IdList);            
        Test.stopTest();        
    }
    static testMethod void testOpportunityNeedApprovalFromProcess3(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();        
        Account acc = util.getAccount();
        acc.Business_Unit__c = 'Nolo-Decline';
        update acc;
        Account acc2 = util.getAccount();
        Contact con = util.getContact(acc.Id);
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        
        invoiceit_s__Payment_Method__c p = util.getPaymentMethod(acc.Id);
        
        Opportunity opp1 = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
                invoiceit_crmx__CurrencyL__c = curr.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
                invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
                invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
                invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
                invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
                invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
                invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 9 , Type = 'New Business',
                Discount__c = 18,Promotional_Credit_Reason__c ='Credit Card',Promotional_Credit__c = 0,
                Promotional_Credit_Payment__c = true,Truncated_Order_Charges__c ='Test'
        );
        insert opp1;
        
        //creating single product
        invoiceit_s__Product__c singleproduct = util.getProduct('true');
        
         //creating single product rate plan
        invoiceit_s__Product_Rate_Plan__c singleprdrpl = util.getProductRatePlan(singleproduct.id);
        
        //creating single opp Product
        invoiceit_crmx__Opportunity_Product__c singleoppProd = util.getOpportunityProduct(singleproduct.id, opp1.Id);
        singleoppProd.Product_SIN__c = 'test';
        update singleoppProd;
        
        invoiceit_crmx__Opportunity_Product__c singleoppProd1 = util.getOpportunityProduct(singleproduct.id, opp1.Id);
        
        //creating single opp rate plan 
        invoiceit_crmx__Opportunity_Rate_Plan__c singleopprpl = util.getOpportunityRatePlan(singleoppProd.id, singleprdrpl.id);
        
        //creating sigle prod rate plan charge
        invoiceit_s__Product_Rate_Plan_Charge__c singleprodrpc = util.getProductRatePlanCharge(curr.id, singleprdrpl.id);
        insert singleprodrpc;
        
        //creating single opp rate plan charge
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c singlerpc = util.getOppRatePlanCharge(singleopprpl.id, singleprodrpc.id);
                
        opp1.invoiceit_crmx__Discount_Percent__c = 9;
        update opp1;
            
        List<Id> IdList = new List<Id>();
        IdList.add(opp1.Id);
        Test.startTest();            
        OpportunityNeedApprovalFromProcess.opptyUpdateFromProcess(IdList);            
        Test.stopTest();        
    }
}
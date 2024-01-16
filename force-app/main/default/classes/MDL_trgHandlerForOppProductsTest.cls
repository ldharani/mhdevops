@isTest(seealldata = true)
public with sharing class MDL_trgHandlerForOppProductsTest{
    static testMethod void testTrgHandlerForOppProducts(){
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
                invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 10 , Type = 'New Business',
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
        singlerpc.invoiceit_crmx__Price__c = 100;
        singlerpc.invoiceit_crmx__Discount_Value__c = 10;
        singlerpc.invoiceit_crmx__VAT__c = 10;
        singlerpc.invoiceit_crmx__Tax__c = 10;
        singlerpc.invoiceit_crmx__Price_Type__c = 'Monthly';
        singlerpc.Quote_Type__c = 'Modify';
        update singlerpc;
        
        List<invoiceit_crmx__Opportunity_Product__c> invOppProdList = new List<invoiceit_crmx__Opportunity_Product__c>();
        invOppProdList.add(singleoppProd);
        
        List<invoiceit_crmx__Opportunity_Product__c> invOppProdList1 = new List<invoiceit_crmx__Opportunity_Product__c>();
        invOppProdList1.add(singleoppProd1);
        
        Map<Id,invoiceit_crmx__Opportunity_Product__c> invOppMap = new Map<Id,invoiceit_crmx__Opportunity_Product__c>(invOppProdList1);
        
        Test.startTest();
            MDL_trgHandlerForOppProducts mdlOppProdsCtrl = new MDL_trgHandlerForOppProducts();
            mdlOppProdsCtrl.restrictDeletionOfAllExistingProds(invOppProdList);
            mdlOppProdsCtrl.sendReleaseInventory(invOppProdList1);
            mdlOppProdsCtrl.setStatusOnProductDeletionDuringRebase(invOppProdList,invOppMap);
        Test.stopTest();
        
    }

    static testMethod void testTrgHandlerForOppProducts1(){
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
                invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 10 , Type = 'New Business',
                Discount__c = 18,Promotional_Credit_Reason__c ='Credit Card',Promotional_Credit__c = 0,
                Promotional_Credit_Payment__c = true
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
        singlerpc.invoiceit_crmx__Price__c = 100;
        singlerpc.invoiceit_crmx__Discount_Value__c = 10;
        singlerpc.invoiceit_crmx__VAT__c = 10;
        singlerpc.invoiceit_crmx__Tax__c = 10;
        singlerpc.invoiceit_crmx__Price_Type__c = 'Monthly';
        singlerpc.Quote_Type__c = 'Modify';
        update singlerpc;
        
        
        
        
        List<invoiceit_crmx__Opportunity_Product__c> invOppProdList = new List<invoiceit_crmx__Opportunity_Product__c>();
        invOppProdList.add(singleoppProd);
        
        List<invoiceit_crmx__Opportunity_Product__c> invOppProdList1 = new List<invoiceit_crmx__Opportunity_Product__c>();
        invOppProdList1.add(singleoppProd1);
        
        Map<Id,invoiceit_crmx__Opportunity_Product__c> invOppMap = new Map<Id,invoiceit_crmx__Opportunity_Product__c>(invOppProdList1);
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Fulfillment Ops Rep' LIMIT 1];
        User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@testsample.com',
                           Username = 'jason.liveston@testsample.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        
        Test.startTest();
        System.runAs(usr){
            MDL_trgHandlerForOppProducts mdlOppProdsCtrl = new MDL_trgHandlerForOppProducts();
            mdlOppProdsCtrl.restrictDeletionOfAllExistingProds(invOppProdList);
            mdlOppProdsCtrl.sendReleaseInventory(invOppProdList1);
            mdlOppProdsCtrl.setStatusOnProductDeletionDuringRebase(invOppProdList,invOppMap);
        }
        Test.stopTest();
        
    }


}
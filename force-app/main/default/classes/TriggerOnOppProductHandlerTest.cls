@isTest(seeAllData = true)
public class TriggerOnOppProductHandlerTest {
    
    static testmethod void run2condition(){
        
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        
        //creating account
        account acc = testData.getAccount();
        
        //creating currency
        invoiceit_s__Currency__c singlecurrency = testData.getCurrencyObject();
        
        //creating contact
        contact con = testData.getContact(acc.Id);
        
        //creating opportunity
        opportunity opp = testData.getOpportunity(acc.Id, con.Id, singlecurrency.id);
        
        //creating product
        invoiceit_s__Product__c prod = testData.getProduct('false');
        
        //creating product
        invoiceit_s__Product__c prod2 = testData.getProduct('false');
        
        //creating product rate plan
        invoiceit_s__Product_Rate_Plan__c prodRP = testData.getProductRatePlan(prod.Id);
        
        //creating product rate plan
        invoiceit_s__Product_Rate_Plan__c prodRP2 = testData.getProductRatePlan(prod2.Id);
        
        //creating product rateplan charge
        invoiceit_s__Product_Rate_Plan_Charge__c pRPC = testData.getProductRatePlanCharge(singlecurrency.Id, prodRP.Id);
        
        //creating product rateplan charge
        invoiceit_s__Product_Rate_Plan_Charge__c pRPC2 = testData.getProductRatePlanCharge(singlecurrency.Id, prodRP2.Id);
        
        //creating opportunity Product
        invoiceit_crmx__Opportunity_Product__c oppProduct = new invoiceit_crmx__Opportunity_Product__c();
        oppProduct.Name                            = 'Opp Product';
        oppProduct.invoiceit_crmx__Product_Code__c = '1234'; 
        oppProduct.invoiceit_crmx__Product__c      = prod.id ;
        oppProduct.invoiceit_crmx__Opportunity__c  = opp.Id;
        oppProduct.invoiceit_crmx__SequenceNumber__c = 1;
        oppProduct.Is_Chat_Option_Shown__c           = 'Yes';
        insert oppProduct;
        
        //creating opportunity Product
        invoiceit_crmx__Opportunity_Product__c oppProduct2 = new invoiceit_crmx__Opportunity_Product__c();
        oppProduct2.Name                            = 'Opp Product2';
        oppProduct2.invoiceit_crmx__Product_Code__c = '1234'; 
        oppProduct2.invoiceit_crmx__Product__c      = prod2.id ;
        oppProduct2.invoiceit_crmx__Opportunity__c  = opp.Id;
        oppProduct2.invoiceit_crmx__SequenceNumber__c = 1;
        oppProduct2.Is_Chat_Option_Shown__c           = 'Yes';
        insert oppProduct2;
        
        //creating opportunity rate plan
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRP = testData.getOpportunityRatePlan(oppProduct.id, prodRP.id);
        
         //creating opportunity rate plan
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRP2 = testData.getOpportunityRatePlan(oppProduct2.id, prodRP2.id);
        
        //creating opportunity rate plan charge
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRPC = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c();
        oppRPC.invoiceit_crmx__Price_Type__c = 'One Time'; 
        oppRPC.invoiceit_crmx__Unit_Price__c = 100;
        oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__c = oppRP.id;
        oppRPC.invoiceit_crmx__Product_Rate_Plan_Charge__c = pRPC.id;
        oppRPC.invoiceit_crmx__Opportunity__c                  = opp.id;
        oppRPC.invoiceit_crmx__Accounting_Code__c              = '01808';
        //oppRPC.Created_From_Charge__c                       = oppRPC1.id;
        oppRPC.Name                                         = 'Mid-Term222';
        insert oppRPC;
        
        //creating opportunity rate plan charge
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRPC2 = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c();
        oppRPC2.invoiceit_crmx__Price_Type__c = 'One Time'; 
        oppRPC2.invoiceit_crmx__Unit_Price__c = 100;
        oppRPC2.invoiceit_crmx__Opportunity_Rate_Plan__c = oppRP2.id;
        oppRPC2.invoiceit_crmx__Product_Rate_Plan_Charge__c = pRPC2.id;
        oppRPC2.invoiceit_crmx__Opportunity__c                  = opp.id;
        oppRPC2.invoiceit_crmx__Accounting_Code__c              = '01808';
        //oppRPC.Created_From_Charge__c                       = oppRPC1.id;
        oppRPC2.Name                                         = 'Mid-Term222';
        insert oppRPC2;
       
        
      
        //creating chat product RPC
        Chat_Product_Opportunity_Charge__c chatPOC = new Chat_Product_Opportunity_Charge__c();
        chatPOC.Chat_Usage_Opp_Rate_Plan_Charge__c   = oppRPC.id;
        chatPOC.Chat_Product_Opp_Rate_Plan_Charge__c = oppRPC2.id;
        insert chatPOC;
        
      
        Test.startTest();
        
        TriggerOnOppProductHandler oppHandlr = new TriggerOnOppProductHandler();
        //oppHandlr.oppProductBeforeDeleteRecursion = true;
        oppHandlr.FkMethod();
          Delete oppProduct;
        Test.stopTest();
        
        
        
    }

}
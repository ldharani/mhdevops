@isTest(seealldata=true)
private class MDL_Test_trgHandlerforOppRenew_Rebase {
    static testMethod void testHandleOppRenew(){
      MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
      Account acc = util.getAccount();
      acc.Credit_Status__c = 'Past Due';
      acc.Credit_Sub_Status__c = 'Override';
      update acc;
      invoiceit_s__Currency__c curr = util.getCurrencyObject();
      Contact con = util.getContact(acc.Id);
      invoiceit_s__Job__c order = util.getOrder(acc.Id ,curr.Id); 
     
        Test.startTest();
        invoiceit_s__Product__c prod1 = util.getProduct('false');
        invoiceit_s__Product_Rate_Plan__c prp = util.getProductRatePlan(prod1.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc = util.getProductRatePlanCharge(curr.Id , prp.Id);       
           
        Opportunity opp1 = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
                invoiceit_crmx__CurrencyL__c = curr.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
                Created_From_Order__c = order.Id,Credit_Approval_Status__c=null
        );
        insert opp1;
        invoiceit_crmx__Opportunity_Product__c oppprod2 = util.getOpportunityProduct(prod1.Id,opp1.Id);     
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp2 = util.getOpportunityRatePlan(oppprod2.Id , prp.Id);
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc2 = util.getOppRatePlanCharge(opprp2.Id , prpc.Id);
        opp1.Credit_Approval_Status__c = 'Approved';
        
        MDL_trgHandlerforOppRenew_Rebase.recursionCheckforoptyBeforeUpdate = true;
        MDL_trgHandlerforOppRenew_Rebase.recursionCheckforopty             = true;
        MDL_trgHandlerforOppRenew_Rebase.recursionCheckforoptyafterUpdate  = true;
        update opp1; 
        Test.stopTest();
    }
    static testmethod void testHandleOppModify(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        acc.Credit_Status__c = 'Past Due';
        acc.Credit_Sub_Status__c = 'Override';
        update acc;
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        Contact con = util.getContact(acc.Id);
        invoiceit_s__Job__c order = util.getOrder(acc.Id ,curr.Id);
         
        Opportunity opp = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
                invoiceit_crmx__CurrencyL__c = curr.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
                Quote_Type__c='Modify',Created_From_Order__c = order.Id,Credit_Approval_Status__c = 'Approved'
        );
        insert opp;
        
        //
        Opportunity opp1 = new Opportunity(Name = 'TestNewOpp', AccountId = acc.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
                invoiceit_crmx__CurrencyL__c = curr.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
                Quote_Type__c='Modify',Created_From_Order__c = order.Id,Credit_Approval_Status__c = 'Approved'
        );
        insert opp1;
        
        Test.startTest();      
        invoiceit_s__Product__c prod1 = util.getProduct('false');
        invoiceit_s__Product_Rate_Plan__c prp = util.getProductRatePlan(prod1.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc = util.getProductRatePlanCharge(curr.Id , prp.Id);
        
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod1.Id,opp.Id);      
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp = util.getOpportunityRatePlan(oppprod1.Id , prp.Id);
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prpc.Id);
        
        opp.StageName = 'Closed Won';
        opp.Reason_Won_Lost__c = 'Good Relationship';
        
        MDL_trgHandlerforOppRenew_Rebase.recursionCheckforoptyBeforeUpdate = true;
        MDL_trgHandlerforOppRenew_Rebase.recursionCheckforopty             = true;
        MDL_trgHandlerforOppRenew_Rebase.recursionCheckforoptyafterUpdate  = true;
        update opp;
        Test.stopTest();       
    }
    
    static testMethod void testhandleoppforCreditSubStatus(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        acc.Credit_Status__c = 'Past Due';
        acc.Credit_Sub_Status__c = 'Override';
        update acc;
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        Contact con = util.getContact(acc.Id);
        invoiceit_s__Job__c order = util.getOrder(acc.Id ,curr.Id);
         
        Opportunity opp = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
                invoiceit_crmx__CurrencyL__c = curr.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
                Quote_Type__c='Modify',Created_From_Order__c = order.Id,Credit_Approval_Status__c = 'Approved'
        );
        
        MDL_trgHandlerforOppRenew_Rebase.recursionCheckforoptyBeforeUpdate = true;
        MDL_trgHandlerforOppRenew_Rebase.recursionCheckforopty             = true;
        MDL_trgHandlerforOppRenew_Rebase.recursionCheckforoptyafterUpdate  = true;
        insert opp;
    
    }
    
    static testMethod void testReleaseInventoryOnOppClosedLost(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();        
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        Contact con = util.getContact(acc.Id);
        Opportunity opp = util.getOpportunity(acc.Id,con.Id,curr.Id);
        Test.startTest();      
        invoiceit_s__Product__c prod1 = util.getProduct('true');
        invoiceit_s__Product_Rate_Plan__c prp = util.getProductRatePlan(prod1.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc = util.getProductRatePlanCharge(curr.Id , prp.Id);
        
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod1.Id,opp.Id);
        oppprod1.InventoryId__c = '11011'; 
        oppprod1.InventoryId__c = '01920';
        
        update oppprod1;     
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp = util.getOpportunityRatePlan(oppprod1.Id , prp.Id);
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prpc.Id);
        
        opp.StageName          = 'Closed Lost';
        opp.Reason_Won_Lost__c = 'Lost to competitor';
        
        MDL_trgHandlerforOppRenew_Rebase.recursionCheckforoptyBeforeUpdate = true;
        MDL_trgHandlerforOppRenew_Rebase.recursionCheckforopty             = true;
        MDL_trgHandlerforOppRenew_Rebase.recursionCheckforoptyafterUpdate  = true;
        update opp;
        Test.stopTest(); 
    }
    
    
    
    static testmethod void run2conditions(){
         MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
      Account acc = util.getAccount();
      acc.Credit_Status__c = 'Past Due';
      acc.Credit_Sub_Status__c = 'Override';
      update acc;
      invoiceit_s__Currency__c curr = util.getCurrencyObject();
      Contact con = util.getContact(acc.Id);
      invoiceit_s__Job__c order = util.getOrder(acc.Id ,curr.Id); 
     
        invoiceit_s__Product__c prod1 = util.getProduct('false');
        invoiceit_s__Product_Rate_Plan__c prp = util.getProductRatePlan(prod1.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc = util.getProductRatePlanCharge(curr.Id , prp.Id);       
           
        Opportunity opp1 = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
                invoiceit_crmx__CurrencyL__c = curr.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
                Created_From_Order__c = order.Id,Credit_Approval_Status__c='Approved', Quote_Type__c = 'Renew'
        );
        insert opp1;
        Test.startTest();
        invoiceit_crmx__Opportunity_Product__c oppprod2 = util.getOpportunityProduct(prod1.Id,opp1.Id);     
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp2 = util.getOpportunityRatePlan(oppprod2.Id , prp.Id);
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc2 = util.getOppRatePlanCharge(opprp2.Id , prpc.Id);
        Test.stopTest();
        
//        opp1.Credit_Approval_Status__c = 'Approved';
        opp1.StageName = 'Closed Won';
//        opp1.Quote_Type__c = 'Renew';
        opp1.Reason_Won_Lost__c = 'Administrative';
        MDL_trgHandlerforOppRenew_Rebase.recursionCheckforoptyBeforeUpdate = true;
        MDL_trgHandlerforOppRenew_Rebase.recursionCheckforopty             = true;
        MDL_trgHandlerforOppRenew_Rebase.recursionCheckforoptyafterUpdate  = true;
        system.debug('Testing the update of Opp1' + opp1.stagename + ' : ' + opp1.id);
        update opp1; 
 
        
    }
}
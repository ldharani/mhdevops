@isTest(seeAllData = True)
public with sharing class Test_createPMOnContractApproval{
    static testMethod void testApproval(){

        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();        
        Account acc = util.getAccount();
        acc.Business_Unit__c = 'Nolo-Decline';
        update acc;
        
        Account acc2 = util.getAccount();
        
        Account NgageAcc = util.getAccount();
        NgageAcc.recordTypeId = '0120G000000WmGr';
        update NgageAcc;       
        
        
        
        Contact con = util.getContact(acc.Id);
        
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        
        invoiceit_s__Payment_Method__c p = util.getPaymentMethod(acc.Id);
        
        Opportunity opp1 = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
                invoiceit_crmx__CurrencyL__c = curr.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
                invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
                invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
                invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,Parent_Opportunity__c =NULL,
                invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
                invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
                invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 9 , Type = 'New Business',
                Discount__c = 18,Promotional_Credit_Reason__c ='Credit Card',Promotional_Credit__c = 0,DocuSign_Quote_Approved__c =False,
                Promotional_Credit_Payment__c = true,Truncated_Order_Charges__c ='Test'
        );
        insert opp1;
        
        Opportunity childOpp1 = new Opportunity(Name = 'TestChildOpp', AccountId = NgageAcc.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
                invoiceit_crmx__CurrencyL__c = curr.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
                invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
                invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
                invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,Parent_Opportunity__c =opp1.id,
                invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
                invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
                invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 9 , Type = 'New Business',
                Discount__c = 18,Promotional_Credit_Reason__c ='Credit Card',Promotional_Credit__c = 0,DocuSign_Quote_Approved__c =False,
                Promotional_Credit_Payment__c = true,Truncated_Order_Charges__c ='Test'
        );
        insert childOpp1;
        
        //creating single product
        invoiceit_s__Product__c singleproduct = util.getProduct('true');
        
        //create child product
          invoiceit_s__Product__c childproduct = new  invoiceit_s__Product__c(Name = 'Test Product',
                invoiceit_s__Valid_From_Date__c = Date.today(),
                invoiceit_s__Valid_To_Date__c = Date.today()+90,
                invoiceit_s__Product_Family__c = 'Default',
                invoiceit_s__Product_Code__c = '60010',
                invoiceit_s__Description__c = 'Product'
               // IsInventoried__c = isInventorable
        );
        insert childproduct;
        
         //creating single child product rate plan
        invoiceit_s__Product_Rate_Plan__c singleChildprdrpl = util.getProductRatePlan(childproduct.id);
        
        //creating single opp Product
        invoiceit_crmx__Opportunity_Product__c childsingleoppProd = util.getOpportunityProduct(childproduct.id, childOpp1.Id);
        
        
        
        //creating single opp rate plan 
        invoiceit_crmx__Opportunity_Rate_Plan__c childsingleopprpl = util.getOpportunityRatePlan(childsingleoppProd .id, singleChildprdrpl.id);
        
        //creating sigle prod rate plan charge
        invoiceit_s__Product_Rate_Plan_Charge__c childsingleprodrpc = util.getProductRatePlanCharge(curr.id, singleChildprdrpl.id);
        insert childsingleprodrpc;
        
        //creating single opp rate plan charge
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c childsinglerpc = util.getOppRatePlanCharge(childsingleopprpl.id, childsingleprodrpc.id);
        /// end
        
        
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
                
                
        opp1.DocuSign_Quote_Approved__c = True;
        update opp1;
            
        List<Opportunity> IdList = new List<Opportunity>();
        IdList.add(opp1);
        
         System.debug('@@@@');
        
        createPMOnContractApproval ctrl = new createPMOnContractApproval();
        
        Test.startTest();            
        createPMOnContractApproval.copyPMFromParent(IdList);       
        ctrl.FkMethod();
        
        invoiceit_s__Payment_Method__c p1 = new invoiceit_s__Payment_Method__c();
        p1.invoiceit_s__Account__c=NgageAcc.Id;
        p1.invoiceit_s__Default__c=False;
        p1.invoiceit_s__Name_on_Card__c='Murali';
        p1.Rank__c='1';
        p1.invoiceit_s__Card_Number__c = string.valueOf(1234567890);
        p1.invoiceit_s__CVV__c = string.valueOf(1234);
        p1.invoiceit_s__Bank_Account_Number__c = string.valueOf(1234567890);
        p1.invoiceit_s__Billing_City__c    = 'alaska';
        p1.invoiceit_s__Billing_Country__c = 'atlanta';
        p1.invoiceit_s__Billing_State_Province__c = 'mexico';
        insert p1;
                 
        Test.stopTest();        
    }
    
    
    
    
    

}
@isTest(seealldata = true)
public with sharing class TestCreatePayment {
	static testMethod void testCreatePaymentCreditCard(){
		MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
		Account acc = util.getAccount();
        acc.Business_Unit__c = 'Nolo-Decline';
        update acc;
		invoiceit_s__Currency__c curr = util.getCurrencyObject();
		Contact con = util.getContact(acc.Id);  
		
		invoiceit_s__Payment_Method__c p = new invoiceit_s__Payment_Method__c();
        p.invoiceit_s__Account__c=acc.Id;
        p.invoiceit_s__Default__c=true;
        p.invoiceit_s__Active__c=true;
        p.invoiceit_s__Name_on_Card__c='Murali';
        p.Rank__c='1';
        p.invoiceit_s__Card_Number__c = string.valueOf(1234567890);
        p.invoiceit_s__CVV__c = string.valueOf(1234);
        insert p;
        
		Opportunity opp = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
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
        insert opp;
        
        invoiceit_s__Job__c order = util.getOrder(acc.Id, Curr.Id);
        order.invoiceit_s__Status__c = 'ACTIVE';
        update order;
         //creating single currency object
        //invoiceit_s__Currency__c singlecurrency = utiltest.getCurrencyObject();
        
        //creating single product
        invoiceit_s__Product__c singleproduct = util.getProduct('true');
        
        //creating single opportunity
        //Opportunity opp = utiltest.getOpportunity(acc.id, con.Id, singlecurrency.id);
        
        //creating single opp Product
        invoiceit_crmx__Opportunity_Product__c singleoppProd = util.getOpportunityProduct(singleproduct.id, opp.Id);
        
        //creating single product rate plan
        invoiceit_s__Product_Rate_Plan__c singleprdrpl = util.getProductRatePlan(singleproduct.id);
        
        
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
        update singlerpc;

        
        CheckCreatePayment.run = true;
        
        Test.startTest();
           opp = [select Name, AccountId , Amount,                                                      
                CloseDate,  StageName  , Probability  ,
                ForecastCategoryName  , invoiceit_crmx__Billing_Contact__c  ,
                invoiceit_crmx__CurrencyL__c  , invoiceit_crmx__Shipping_Contact__c ,
                invoiceit_crmx__VAT__c ,invoiceit_crmx__Total__c  , invoiceit_crmx__Total_Profit__c  ,
                invoiceit_crmx__Total_Cost__c  , invoiceit_crmx__Total_Contract_Value__c  , 
                invoiceit_crmx__TotalProfitPercent__c  , invoiceit_crmx__Sub_Total__c ,
                invoiceit_crmx__Recalculate__c  , invoiceit_crmx__Number_Of_Terms__c ,
                invoiceit_crmx__Net_Total__c  , invoiceit_crmx__Do_Not_Create_Automatic_Order__c  ,
                invoiceit_crmx__Discount_Value__c  , invoiceit_crmx__Discount_Percent__c  , Type,
                Discount__c ,Promotional_Credit_Reason__c ,Promotional_Credit__c,
                 Monthly_Recurring_Total__c 
                  from opportunity 
                   where id=: opp.id];
        system.debug('@@@opp monthly recurring total'+ opp.Monthly_Recurring_Total__c);
        system.debug('@@@opp monthly '+ opp);
        	opp.StageName = 'Closed Won';
        	opp.Reason_Won_Lost__c = 'Good Relationship';
        	opp.Promotional_Credit_Payment__c = true;
            opp.Promotional_Credit__c = 10;
              opp.Created_From_Order__c = order.id;
        	update opp;
          
            opp.Promotional_Credit__c = 15;
            update opp;
            
        Test.stopTest();
	}
	static testMethod void testCreatePaymentACH(){
		MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
		Account acc = util.getAccount();
        acc.Business_Unit__c = 'Nolo-Decline';
        update acc;
		invoiceit_s__Currency__c curr = util.getCurrencyObject();
		Contact con = util.getContact(acc.Id);  
		
		invoiceit_s__Payment_Method__c p = new invoiceit_s__Payment_Method__c();
        p.invoiceit_s__Account__c=acc.Id;
        p.invoiceit_s__Default__c=true;
        p.invoiceit_s__Active__c=true;
        p.Rank__c='1';
        p.invoiceit_s__Payment_Method__c = 'ACH';
        p.invoiceit_s__Bank_Account_Name__c = 'Test';
        p.invoiceit_s__Bank_Account_Number__c = String.valueOf(1234567891);
        p.invoiceit_s__Bank_Routing_Code__c = String.valueOf(123456789);
        p.invoiceit_s__Bank_Name__c = 'Test Bank';
        insert p;
        
		Opportunity opp = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
                invoiceit_crmx__CurrencyL__c = curr.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
                invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
                invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
                invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
                invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
                invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
                invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 10 , Type = 'New Business',
                Discount__c = 18,Promotional_Credit_Reason__c ='ACH',Promotional_Credit__c = 0,
                                          Promotional_Credit_Payment__c = true
                                                        
        );
        insert opp;
         invoiceit_s__Product__c singleproduct = util.getProduct('true');
        
        //creating single opportunity
        //Opportunity opp = utiltest.getOpportunity(acc.id, con.Id, singlecurrency.id);
        
        //creating single opp Product
        invoiceit_crmx__Opportunity_Product__c singleoppProd = util.getOpportunityProduct(singleproduct.id, opp.Id);
        
        //creating single product rate plan
        invoiceit_s__Product_Rate_Plan__c singleprdrpl = util.getProductRatePlan(singleproduct.id);
        
        
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
        update singlerpc;

        CheckCreatePayment.run = true;
        
        Test.startTest();
        	 opp = [select Name, AccountId , Amount,                                                      
                CloseDate,  StageName  , Probability  ,
                ForecastCategoryName  , invoiceit_crmx__Billing_Contact__c  ,
                invoiceit_crmx__CurrencyL__c  , invoiceit_crmx__Shipping_Contact__c ,
                invoiceit_crmx__VAT__c ,invoiceit_crmx__Total__c  , invoiceit_crmx__Total_Profit__c  ,
                invoiceit_crmx__Total_Cost__c  , invoiceit_crmx__Total_Contract_Value__c  , 
                invoiceit_crmx__TotalProfitPercent__c  , invoiceit_crmx__Sub_Total__c ,
                invoiceit_crmx__Recalculate__c  , invoiceit_crmx__Number_Of_Terms__c ,
                invoiceit_crmx__Net_Total__c  , invoiceit_crmx__Do_Not_Create_Automatic_Order__c  ,
                invoiceit_crmx__Discount_Value__c  , invoiceit_crmx__Discount_Percent__c  , Type,
                Discount__c ,Promotional_Credit_Reason__c ,Promotional_Credit__c,
                 Monthly_Recurring_Total__c 
                  from opportunity 
                   where id=: opp.id];
        system.debug('@@@opp monthly recurring total'+ opp.Monthly_Recurring_Total__c);
        system.debug('@@@opp monthly '+ opp);
        	opp.StageName = 'Closed Won';
        	opp.Reason_Won_Lost__c = 'Good Relationship';
        	opp.Promotional_Credit_Payment__c = true;
            opp.Promotional_Credit__c = 10;
        	update opp;
            opp.Promotional_Credit__c = 15;
            update opp;

        Test.stopTest();
	}
}
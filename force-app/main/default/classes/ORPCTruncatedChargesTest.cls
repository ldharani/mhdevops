/**********************************************************************************
 * Author      : Sai
 * Description : test class for ORPCTruncatedChanges
 * 
 * ********************************************************************************/
@isTest(seeAllData = true)
public class ORPCTruncatedChargesTest {
    
    
    static testmethod void run2condition(){
        MDL_UtilClass_TestClass utilclass = new MDL_UtilClass_TestClass();
    	//creating account
    	account acc = utilclass.getAccount();
    
    	//creating contact
    	contact con = utilclass.getContact(acc.Id);
    
    	//creating currency
    	invoiceit_s__Currency__c curr = utilclass.getCurrencyObject();
    
    	//creating order
    	invoiceit_s__Job__c order = utilclass.getOrder(acc.Id, curr.id);
        
        //creating product
        invoiceit_s__Product__c product = utilclass.getProduct('Yes');
        
       
        
         Opportunity opportunity1 = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
                invoiceit_crmx__CurrencyL__c = curr.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
                invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
                invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
                invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
                invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
                Created_From_Order__c = order.id,                                    
                invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
                invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 10 , Type = 'New Business',
                Discount__c = 18 
        );
        insert opportunity1;
        
         //creating opportunity product
        invoiceit_crmx__Opportunity_Product__c oppProduct = utilclass.getOpportunityProduct(Product.Id, opportunity1.id);
        
        invoiceit_s__Product__c prod1                           = utilclass.getProduct('false');
        invoiceit_s__Product_Rate_Plan__c prp                   = utilclass.getProductRatePlan(prod1.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc           = utilclass.getProductRatePlanCharge(curr.Id , prp.Id);
        prpc.Renewable__c = true;
        insert prpc;
        
        invoiceit_crmx__Opportunity_Product__c oppprod2         = utilclass.getOpportunityProduct(prod1.Id,opportunity1.Id);     
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp2         = utilclass.getOpportunityRatePlan(oppprod2.Id , prp.Id);
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc2 = utilclass.getOppRatePlanCharge(opprp2.Id , prpc.Id);
        
        invoiceit_s__Job_Product__c orderproduct1               = utilclass.getOrderProduct(order.Id , prod1.Id);
		invoiceit_s__Job_Rate_Plan__c orp1                      = utilclass.getOrderRatePlan(orderproduct1.Id , prp.Id);
		invoiceit_s__Job_Rate_Plan_Charge__c orpc1              = utilclass.getOrderRatePlanCharge( orp1.Id ,prpc.Id );
      
		
        Id ngagedevRecordTypeId = Schema.SObjectType.invoiceit_s__Job_Rate_Plan_Charge__c.getRecordTypeInfosByName().get('M-NG Order Rate Plan Charge').getRecordTypeId();
        invoiceit_s__Job_Rate_Plan_Charge__c orpc2              = utilclass.getOrderRatePlanCharge( orp1.Id ,prpc.Id );
		
        
        orpc1.invoiceit_s__Status__c = 'Active';	
        Test.startTest();
        	orpc2.RecordTypeId = ngagedevRecordTypeId;
        	orpc2.invoiceit_s__Service_End_Date__c = System.today();
        	orpc2.invoiceit_s__Status__c = 'Truncated';
            //orpc2.Renewable__c = true;
        	//update orpc2;
        
        	opportunity1.StageName           = 'Closed Won';
            opportunity1.Reason_Won_Lost__c  = 'Good Relationship';
          MDL_trgHandlerforOppRenew_Rebase.recursionCheckforoptyBeforeUpdate = true;
            system.debug('@@@@update is happening here');
            update opportunity1;
        Test.stopTest();
        
    }
    
    
    

}
@isTest(seealldata = true)
public with sharing class MDL_Test_BatchSendReleaseInvForTruncate {
	static testMethod void testReleaseInventoryForTruncate(){
		MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
        Account acc = util.getAccount();		
		Contact con = util.getContact(acc.Id);  		
		invoiceit_s__Currency__c cur = util.getCurrencyObject();
        
        invoiceit_s__Product__c prod = util.getProductWithProvisioning('true', 'Manual Fulfillment');    
     	invoiceit_s__Product_Rate_Plan__c pRP = util.getProductRatePlan(prod.Id);		
		invoiceit_s__Product_Rate_Plan_Charge__c pRPC = util.getProductRatePlanCharge(cur.Id, pRP.Id);
		
		
		Opportunity opportunity = util.getOpportunity(acc.Id, con.Id, cur.Id);		
		invoiceit_crmx__Opportunity_Product__c oppProduct = util.getOpportunityProduct(prod.Id, opportunity.Id);
		oppProduct.InventoryId__c = '122345';
		update oppProduct;
		invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = util.getOpportunityRatePlan(oppProduct.Id, pRP.Id);		
		invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = util.getOppRatePlanCharge(OppRatePlan.Id, pRPC.Id);
        
        invoiceit_s__Job__c order = util.getOrder(acc.Id , cur.Id);
        invoiceit_s__Job_Product__c oProd = util.getOrderProduct(order.Id ,prod.Id);
        oProd.Sin_Number__c = '1010101010';
		oProd.Inventory_Id__c = '12345';
		oProd.invoiceit_s__Product_Code__c = '10001100';		
		update oProd;
		
		invoiceit_s__Job_Rate_Plan__c oRP = util.getOrderRatePlan(oProd.Id , pRP.Id);
        invoiceit_s__Job_Rate_Plan__c orderRatePlan = [Select Id,invoiceit_s__Job_Product__r.Inventory_Id__c from invoiceit_s__Job_Rate_Plan__c where Id=:oRP.Id];
        invoiceit_s__Job_Rate_Plan_Charge__c oRPC = new invoiceit_s__Job_Rate_Plan_Charge__c();
		oRPC.Name = 'Test RPC for Release Inv For Truncate';
		oRPC.invoiceit_s__Job_Rate_Plan__c = orderRatePlan.Id;
		oRPC.invoiceit_s__Product_Rate_Plan_Charge__c = pRPC.Id 	;
		oRPC.invoiceit_s__Quantity__c = 1;
		oRPC.invoiceit_s__Status__c = 'In Progress';
		oRPC.invoiceit_s__Service_End_Date__c = Date.Today().addDays(-2);
        oRPC.invoiceit_s__Status__c = 'Expired';
        oRPC.Opportunity_Rate_Plan_Charge__c = oppRatePlanCharge.Id;
		insert oRPC; 
		
		invoiceit_s__Job_Rate_Plan_Charge__c orderRPC = [Select Id, invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c from invoiceit_s__Job_Rate_Plan_Charge__c where Id=:oRPC.Id];
		System.debug('>>>>>'+orderRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c);            
       
        
             
        Test.startTest();
        MDL_BatchSendReleaseInventoryForTruncate b = new MDL_BatchSendReleaseInventoryForTruncate(); 
        Database.executeBatch(b);
        Test.stopTest(); 
	}
}
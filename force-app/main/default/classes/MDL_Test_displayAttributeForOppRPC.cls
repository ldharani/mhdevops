@isTest(seealldata=true)
private class MDL_Test_displayAttributeForOppRPC{
    
    static testMethod void testCase() {
       	MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
		Account acc = util.getAccount();
		invoiceit_s__Currency__c curr = util.getCurrencyObject();
		Contact con = util.getContact(acc.Id);
		
		invoiceit_s__Product__c prod1 = util.getProduct('true');
		invoiceit_s__Product_Rate_Plan__c prp = util.getProductRatePlan(prod1.Id);
		invoiceit_s__Product_Rate_Plan_Charge__c prpc = util.getProductRatePlanCharge(curr.Id , prp.Id);
		Test.startTest();
		Opportunity opp = util.getOpportunity(acc.Id , con.Id ,curr.Id );
		invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod1.Id,opp.Id);
		invoiceit_crmx__Opportunity_Rate_Plan__c opprp = util.getOpportunityRatePlan(oppprod1.Id , prp.Id);
		invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prpc.Id);
		
		Opportunity_Charge_Attribute__c oppCharge1 = util.getOppCharges(opprpc.Id,'Text','Country');
		Opportunity_Charge_Attribute__c oppCharge2 = util.getOppCharges(opprpc.Id,'Text','State');	
        ApexPages.StandardController sc = new ApexPages.StandardController(opprpc);
        MDL_DisplayAttributeForOppRPC test123=new MDL_DisplayAttributeForOppRPC(sc);
		Test.stopTest();
    }
        
}
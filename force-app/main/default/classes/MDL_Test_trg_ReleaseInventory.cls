/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
private class MDL_Test_trg_ReleaseInventory {

    static testMethod void testRelInv() {
    	Test.startTest();
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
		
		Account a = testData.getAccount();		
		Contact c = testData.getContact(a.Id);  		
		invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
		
		invoiceit_s__Product__c product = testData.getProductWithProvisioning('true', 'Manual Fulfillment');
		invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);		
		invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);		
		Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);		
		invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);		
		
		oppProduct.InventoryId__c = '12345';
		update oppProduct;
		
		delete oppProduct;
		Test.stopTest();
    }
    static testMethod void testRenewAddOrDeleteProds() {
    	Test.startTest();
    	MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
		
		Account a = testData.getAccount();		
		Contact c = testData.getContact(a.Id);  		
		invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
		
		invoiceit_s__Product__c product = testData.getProductWithProvisioning('true', 'Manual Fulfillment');
		invoiceit_s__Product__c product1 = testData.getProductWithProvisioning('true', 'Manual Fulfillment');
		invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);		
		invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);	
		
		Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);
		opportunity.Quote_Type__c = 'Renew';
		invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);
		update opportunity;
		invoiceit_crmx__Opportunity_Product__c oppProduct1 = testData.getOpportunityProduct(Product1.Id, opportunity.Id);
		oppProduct.InventoryId__c = '12345';
		update oppProduct;
		delete oppProduct;
		Test.stopTest();
    }
}
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
private class MDL_Test_trgOnQuote {

    static testMethod void myUnitTest() {
        
        try{
	        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
	        
	        Account a = testData.getAccount();		
			Contact c = testData.getContact(a.Id);  		
			invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();		
			
			invoiceit_s__Product__c product = testData.getProduct('true');
			product.Product_Provisioning__c = 'Manual Fulfillment';
			update product;
			
			invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);		
			invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);		
			
			Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);		
			invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);		
			invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = testData.getOpportunityRatePlan(oppProduct.Id, productRatePlan.Id);		
			invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = testData.getOppRatePlanCharge(OppRatePlan.Id, ProductratePlanCharge.Id);	
			Opportunity_Charge_Attribute__c oppCharges = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'AOP');
			oppCharges.String_Value__c = '';
			update oppCharges;
			Opportunity_Charge_Attribute__c oppCharges1 = testData.getOppCharges(oppRatePlanCharge.Id, 'Number', 'ABC');
			oppCharges1.Number_Value__c = null;
			update oppCharges1;
			Opportunity_Charge_Attribute__c oppCharges2 = testData.getOppCharges(oppRatePlanCharge.Id, 'Boolean', 'XYZ');
			oppCharges2.Boolean_Value__c = false;
			update oppCharges2;
			Opportunity_Charge_Attribute__c oppCharges3 = testData.getOppCharges(oppRatePlanCharge.Id, 'Picklist', 'TYU');
			oppCharges3.Picklist_Value__c = null;
			update oppCharges3;
			Opportunity_Charge_Attribute__c oppCharges4 = testData.getOppCharges(oppRatePlanCharge.Id, 'Date', 'Pay Date');
			oppCharges4.Date_Value__c = null;
			update oppCharges4;
			//Opportunity_Charge_Attribute__c oppCharges5 = testData.getOppCharges(oppRatePlanCharge.Id, 'Phone', 'Landline Number');
			//oppCharges5.Phone_Value__c = null;
			//update oppCharges5;
			
			invoiceit_s__Quote__c quote = testData.getQuote(a.Id, opportunity.Id, c.Id, currencyObj.Id);
    	}catch(System.Exception e) {
    		 //System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    		 System.assert(e.getMessage().contains('Oppotunity cannot be converted into an quote since few attributes are blank'));
    	}
    }
}
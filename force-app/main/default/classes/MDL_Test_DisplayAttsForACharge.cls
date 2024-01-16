//Test class for MDL_DisplayAttsForACharge
@isTest(seealldata=true)
public with sharing class MDL_Test_DisplayAttsForACharge {
	static testMethod void dispAttributes(){		
		MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
		//create required objects
		Account account1 = util.getAccount();
		invoiceit_s__Currency__c currency1 = util.getCurrencyObject();
		invoiceit_s__Job__c order1 = util.getOrder(account1.Id, currency1.Id);
				
		invoiceit_s__Product__c product1 = util.getProduct('False');
		invoiceit_s__Product_Rate_Plan__c prp1 = util.getProductRatePlan(product1.Id);
		invoiceit_s__Product_Rate_Plan_Charge__c prpc1 = util.getProductRatePlanCharge(currency1.Id, prp1.Id);
		
		invoiceit_s__Job_Product__c orderproduct1 = util.getOrderProduct(order1.Id , product1.Id);
		invoiceit_s__Job_Rate_Plan__c orp1 = util.getOrderRatePlan(orderproduct1.Id , prp1.Id);
		invoiceit_s__Job_Rate_Plan_Charge__c orpc1 = util.getOrderRatePlanCharge( orp1.Id ,prpc1.Id );
		
		Order_Charge_Attribute__c oca = new Order_Charge_Attribute__c(Attribute_Name__c='Service City',Attribute_Order__c=3,Attribute_Type__c='Text',String_Value__c='New Providence',Order_Rate_Plan_Charge__c=orpc1.Id);
		insert oca;
		
		ApexPages.StandardController sc = new ApexPages.StandardController(orpc1);
		MDL_DisplayAttsForACharge dac = new MDL_DisplayAttsForACharge(sc);	
		
	} 
}
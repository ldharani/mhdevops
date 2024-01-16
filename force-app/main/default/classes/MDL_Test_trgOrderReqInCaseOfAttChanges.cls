@isTest(seealldata=true)
public with sharing class MDL_Test_trgOrderReqInCaseOfAttChanges {
	static testMethod void handleOrderAttributes(){
		MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
		Account acc = util.getAccount();
		invoiceit_s__Currency__c curr = util.getCurrencyObject();
		Contact con = util.getContact(acc.Id);
		
		invoiceit_s__Product__c prod1 = util.getProduct('true');
		invoiceit_s__Product_Rate_Plan__c prp = util.getProductRatePlan(prod1.Id);
		invoiceit_s__Product_Rate_Plan_Charge__c prpc = util.getProductRatePlanCharge(curr.Id , prp.Id);
		Test.startTest();
		invoiceit_s__Job__c order = util.getOrder(acc.Id ,curr.Id);
		invoiceit_s__Job_Product__c orderprod1 = util.getOrderProduct(order.Id ,prod1.Id);
		invoiceit_s__Job_Rate_Plan__c orderrp = util.getOrderRatePlan(orderProd1.Id ,prp.Id);
		invoiceit_s__Job_Rate_Plan_Charge__c orderrpc = util.getOrderRatePlanCharge(orderrp.Id ,prpc.Id);		
		
		Order_Charge_Attribute__c orderCharge1 = util.getOrderCharges(orderrpc.Id , 'Text' ,'Service Test Name Old');
		
		orderCharge1.String_Value__c = 'Service Test Name New';
		update orderCharge1;
		
		Test.stopTest();
	}
}
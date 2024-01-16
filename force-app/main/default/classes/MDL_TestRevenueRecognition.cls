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
@isTest(seeALLData=true)
private class MDL_TestRevenueRecognition {

    static testMethod void myUnitTest() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        
        Account a = testData.getAccount();
        
        Contact c = testData.getContact(a.Id);  
        
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
        invoiceit_s__Product__c product = testData.getProduct('false');
        product.Product_Provisioning__c = 'Manual Fulfillment';
        update product;
        
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);
        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);
        productRatePlanCharge.Revenue_Recognition_Months__c = 2.0;
        insert productRatePlanCharge;
        
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);
        
        invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);
        
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = testData.getOpportunityRatePlan(oppProduct.Id, productRatePlan.Id);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = testData.getOppRatePlanCharge(OppRatePlan.Id, ProductratePlanCharge.Id);    
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge2 = testData.getOppRatePlanCharge(OppRatePlan.Id, ProductratePlanCharge.Id);   
        
        invoiceit_s__Job__c temp_order = testData.getOrder(a.Id, CurrencyObj.Id);
        invoiceit_s__Job_Product__c temp_orderProduct = testdata.getOrderProduct(temp_order.Id, product.Id);
        invoiceit_s__Job_Rate_Plan__c temp_orderRatePlan = testdata.getOrderRatePlan(temp_orderProduct.Id, productRatePlan.Id);
        
        invoiceit_s__Job__c order = testData.getOrder(a.Id, CurrencyObj.Id);
        order.invoiceit_crmx__Opportunity__c = opportunity.Id;
        order.Created_From_Order__c = temp_order.Id;
        update order;
        invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
        Test.starttest();
        invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge = testdata.getOrderRatePlanChargeWithoutInsert(OrderRatePlan.Id, ProductRatePlanCharge.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge2 = testdata.getOrderRatePlanChargeWithoutInsert(OrderRatePlan.Id, ProductRatePlanCharge.Id);
        List<invoiceit_s__Job_Rate_Plan_Charge__c> list_orderRPC = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        List<Id> list_orderRPCId = new List<Id>();
        orderRatePlanCharge.invoiceit_s__Net_Total__c = 100;
        orderRatePlanCharge2.invoiceit_s__Net_Total__c = 100;
        list_orderRPC.add(orderRatePlanCharge);
        list_orderRPC.add(orderRatePlanCharge2);
        insert list_orderRPC;
        Test.stoptest();
        list_orderRPCId.add(orderRatePlanCharge.Id);
        list_orderRPCId.add(orderRatePlanCharge2.Id);
        orderRatePlanCharge.Fulfilment_Start_Date__c = Date.today();
        orderRatePlanCharge.invoiceit_s__Net_Total__c = 200;
        orderRatePlanCharge.invoiceit_s__Service_End_Date__c = Date.today().addDays(30);
        update orderRatePlanCharge;
        
        MDL_RevenueRecognition.trgHandlerOrderRPC(list_orderRPCId);
        MDL_RevenueRecognition.trgHandlerServiceDateChange(list_orderRPC);
        
      }
}
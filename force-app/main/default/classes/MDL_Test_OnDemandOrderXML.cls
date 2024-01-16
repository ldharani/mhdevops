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
private class MDL_Test_OnDemandOrderXML {

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
    
    Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);
    
    invoiceit_s__Job__c temp_order = testData.getOrder(a.Id, CurrencyObj.Id);
    
    invoiceit_s__Job__c order = new invoiceit_s__Job__c();
        order.Name = 'Test Order for On Demand Order XML Test';
        order.invoiceit_s__Account__c = a.Id;
        order.invoiceit_s__CurrencyL__c = CurrencyObj.Id;
        order.invoiceit_s__Status__c = 'Active';
    order.invoiceit_crmx__Opportunity__c = opportunity.Id;
    order.Created_From_Order__c = temp_order.Id;
    insert order;
    
    invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
    invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
    invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge = testdata.getOrderRatePlanChargeWithoutInsert(OrderRatePlan.Id, ProductRatePlanCharge.Id);
    invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge2 = testdata.getOrderRatePlanChargeWithoutInsert(OrderRatePlan.Id, ProductRatePlanCharge.Id);
    List<invoiceit_s__Job_Rate_Plan_Charge__c> list_orderRPC = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
    list_orderRPC.add(orderRatePlanCharge);
    list_orderRPC.add(orderRatePlanCharge2);
    insert list_orderRPC;
         Order_Charge_Attribute__c oppCharges = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'AOP');
        Order_Charge_Attribute__c oppCharges1 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'Service Account Name');
        Order_Charge_Attribute__c oppCharges2 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'State');
        Order_Charge_Attribute__c oppCharges3 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'City');
        Order_Charge_Attribute__c oppCharges4 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'County');
        Order_Charge_Attribute__c oppCharges5 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'Country');
        Order_Charge_Attribute__c oppCharges6 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Number', 'Number');
        Order_Charge_Attribute__c oppCharges7 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Boolean', 'Boolean');
        Order_Charge_Attribute__c oppCharges8 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Picklist', 'Picklist');
        Order_Charge_Attribute__c oppCharges9 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Date', 'Date');
        Order_Charge_Attribute__c oppCharges10 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Phone', 'Phone');
    Test.startTest();    
      MDL_OnDemandOrderXML onDemand = new MDL_OnDemandOrderXML();
      Pagereference pf = onDemand.validateAcc();
      //onDemand.orderObj = order;  
      onDemand.orderObj = [Select Id,Name from invoiceit_s__Job__c where Id = :order.Id];
      Pagereference pf1 = onDemand.validateAcc();
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('orderResponse');
      mock.setStatusCode(200);
      mock.setHeader('Content-Type', 'text/xml');
      // Set the mock callout mode
      Test.setMock(HttpCalloutMock.class, mock);
      Pagereference pf2 = onDemand.generateXML();
      PageReference refreshpage = onDemand.refreshPage();
    Test.stopTest();  
    
    }
    
    //test for 400 response
    static testMethod void myUnitTestFor400Response() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    
    Account a = testData.getAccount();
    
    Contact c = testData.getContact(a.Id);  
    
    invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
    
    invoiceit_s__Product__c product = testData.getProduct('false');
    product.Product_Provisioning__c = 'Manual Fulfillment';
    update product;
    
    invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);
    
    invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);
    
    Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);
    
    invoiceit_s__Job__c temp_order = testData.getOrder(a.Id, CurrencyObj.Id);
    
    invoiceit_s__Job__c order = new invoiceit_s__Job__c();
        order.Name = 'Test Order for On Demand Order XML Test';
        order.invoiceit_s__Account__c = a.Id;
        order.invoiceit_s__CurrencyL__c = CurrencyObj.Id;
        order.invoiceit_s__Status__c = 'Active';
    order.invoiceit_crmx__Opportunity__c = opportunity.Id;
    order.Created_From_Order__c = temp_order.Id;
    insert order;
    
    invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
    invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
    invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge = testdata.getOrderRatePlanCharge(OrderRatePlan.Id, ProductRatePlanCharge.Id);
    
    Test.startTest();      
      MDL_OnDemandOrderXML onDemand = new MDL_OnDemandOrderXML();
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('orderResponseFor400Error');
      mock.setStatusCode(400);
      mock.setHeader('Content-Type', 'text/xml');
      // Set the mock callout mode
      onDemand.orderObj = [Select Id,Name from invoiceit_s__Job__c where Id = :order.Id];
      Test.setMock(HttpCalloutMock.class, mock);
      Pagereference pf = onDemand.validateAcc();  
      Pagereference pf2 = onDemand.generateXML();      
    Test.stopTest();  
    
    }
    
    //added by sai: 25/4/2016
    //test for 502 response which is added as server down functionality
      static testMethod void myUnitTestFor502Response() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    
    Account a = testData.getAccount();
    
    Contact c = testData.getContact(a.Id);  
    
    invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
    
    invoiceit_s__Product__c product = testData.getProduct('false');
    product.Product_Provisioning__c = 'Manual Fulfillment';
    update product;
    
    invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);
    
    invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);
    
    Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);
    
    invoiceit_s__Job__c temp_order = testData.getOrder(a.Id, CurrencyObj.Id);
    
    invoiceit_s__Job__c order = new invoiceit_s__Job__c();
        order.Name = 'Test Order for On Demand Order XML Test';
        order.invoiceit_s__Account__c = a.Id;
        order.invoiceit_s__CurrencyL__c = CurrencyObj.Id;
        order.invoiceit_s__Status__c = 'Active';
    order.invoiceit_crmx__Opportunity__c = opportunity.Id;
    order.Created_From_Order__c = temp_order.Id;
    insert order;
    
    invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
    invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
    invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge = testdata.getOrderRatePlanCharge(OrderRatePlan.Id, ProductRatePlanCharge.Id);
    
    Test.startTest();      
      MDL_OnDemandOrderXML onDemand = new MDL_OnDemandOrderXML();
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('orderResponseFor400Error');
      mock.setStatusCode(502);
      mock.setHeader('Content-Type', 'text/xml');
      // Set the mock callout mode
      onDemand.orderObj = [Select Id,Name from invoiceit_s__Job__c where Id = :order.Id];
      Test.setMock(HttpCalloutMock.class, mock);
      Pagereference pf = onDemand.validateAcc();  
      Pagereference pf2 = onDemand.generateXML();      
    Test.stopTest();  
    
    }
    
      static testMethod void myUnitTestForexceptionResponse() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    
    Account a = testData.getAccount();
    
    Contact c = testData.getContact(a.Id);  
    
    invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
    
    invoiceit_s__Product__c product = testData.getProduct('false');
    product.Product_Provisioning__c = 'Manual Fulfillment';
    update product;
    
    invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);
    
    invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);
    
    Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);
    
    invoiceit_s__Job__c temp_order = testData.getOrder(a.Id, CurrencyObj.Id);
    
    invoiceit_s__Job__c order = new invoiceit_s__Job__c();
        order.Name = 'Test Order for On Demand Order XML Test';
        order.invoiceit_s__Account__c = a.Id;
        order.invoiceit_s__CurrencyL__c = CurrencyObj.Id;
        order.invoiceit_s__Status__c = 'Active';
    order.invoiceit_crmx__Opportunity__c = opportunity.Id;
    order.Created_From_Order__c = temp_order.Id;
    insert order;
    
    invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
    invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
    invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge = testdata.getOrderRatePlanCharge(OrderRatePlan.Id, ProductRatePlanCharge.Id);
    
    Test.startTest();      
      MDL_OnDemandOrderXML onDemand = new MDL_OnDemandOrderXML();
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('orderResponseFor400Error');
      //mock.setStatusCode(502);
      //mock.setHeader('Content-Type', 'text/xml');
      // Set the mock callout mode
      onDemand.orderObj = [Select Id,Name from invoiceit_s__Job__c where Id = :order.Id];
      Test.setMock(HttpCalloutMock.class, mock);
      Pagereference pf = onDemand.validateAcc();  
      Pagereference pf2 = onDemand.generateXML();      
    Test.stopTest();  
    
    }
    
}
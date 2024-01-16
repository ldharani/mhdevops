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
private class MDL_Test_Integration_Callouts {

    static testMethod void testPend() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account a = testData.getAccount();      
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
        invoiceit_s__Product__c product = testData.getProductWithProvisioning('true', 'Manual Fulfillment');
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);     
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);      
        invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = testData.getOpportunityRatePlan(oppProduct.Id, productRatePlan.Id);      
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = testData.getOppRatePlanCharge(OppRatePlan.Id, ProductratePlanCharge.Id);    
        Opportunity_Charge_Attribute__c oppCharges = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'AOP');
        Opportunity_Charge_Attribute__c oppCharges1 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'Service Account Name');
        Opportunity_Charge_Attribute__c oppCharges2 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'State');
        Opportunity_Charge_Attribute__c oppCharges3 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'City');
        Opportunity_Charge_Attribute__c oppCharges4 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'County');
        Opportunity_Charge_Attribute__c oppCharges5 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'Country');
        
        Set<Id> setOppProdIds = new Set<Id>();
        setOppProdIds.add(oppProduct.Id);
        String accId = a.Id;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('pendResponseFor400Response');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        // Call the method that performs the callout
        Test.startTest();
        MDL_Integration_Vim_Efs.pendInventoryRequest(setOppProdIds,'0000012345','TestUser',accId);
        Test.stopTest();
        //System.assert(e.getMessage().contains('Oppotunity cannot be converted into an quote since few attributes are blank'));
            
    }
    static testMethod void testPendFor200Response() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account a = testData.getAccount();      
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
        invoiceit_s__Product__c product = testData.getProductWithProvisioning('true', 'Manual Fulfillment');
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);     
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);      
        invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = testData.getOpportunityRatePlan(oppProduct.Id, productRatePlan.Id);      
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = testData.getOppRatePlanCharge(OppRatePlan.Id, ProductratePlanCharge.Id);    
        Opportunity_Charge_Attribute__c oppCharges = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'AOP');
        Opportunity_Charge_Attribute__c oppCharges1 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'Service Account Name');
        Opportunity_Charge_Attribute__c oppCharges2 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'State');
        Opportunity_Charge_Attribute__c oppCharges3 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'City');
        Opportunity_Charge_Attribute__c oppCharges4 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'County');
        Opportunity_Charge_Attribute__c oppCharges5 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'Country');
        
        Set<Id> setOppProdIds = new Set<Id>();
        setOppProdIds.add(oppProduct.Id);
        String accId = a.Id;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('pendResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        // Call the method that performs the callout
        Test.startTest();
        MDL_Integration_Vim_Efs.pendInventoryRequest(setOppProdIds,'00000123456','TestUser',accId);
        Test.stopTest();
        //System.assert(e.getMessage().contains('Oppotunity cannot be converted into an quote since few attributes are blank'));
            
    }
  
    static testMethod void testRelease200() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account a = testData.getAccount();      
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
        invoiceit_s__Product__c product = testData.getProductWithProvisioning('true', 'Manual Fulfillment');
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);     
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);      
        invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);
        oppProduct.InventoryId__c = '122345';
        update oppProduct;
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = testData.getOpportunityRatePlan(oppProduct.Id, productRatePlan.Id);      
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = testData.getOppRatePlanCharge(OppRatePlan.Id, ProductratePlanCharge.Id);    
        Opportunity_Charge_Attribute__c oppCharges = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'AOP');
        Opportunity_Charge_Attribute__c oppCharges1 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'Service Account Name');
        Opportunity_Charge_Attribute__c oppCharges2 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'State');
        Opportunity_Charge_Attribute__c oppCharges3 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'City');
        Opportunity_Charge_Attribute__c oppCharges4 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'County');
        Opportunity_Charge_Attribute__c oppCharges5 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'Country');
        
        Set<Id> setOppProdIds = new Set<Id>();
        Set<Id> setOppIds = new Set<Id>();
        Map<Id,String> mapOpptyProdNInventoryId = new Map<Id,String>();
        mapOpptyProdNInventoryId.put(oppProduct.Id,oppProduct.InventoryId__c);
        setOppProdIds.add(oppProduct.Id);
        setOppIds.add(opportunity.id);
        String accId = a.Id;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('releaseResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode 
        Test.setMock(HttpCalloutMock.class, mock);
        
        /*StaticResourceCalloutMock mock1 = new StaticResourceCalloutMock();
        mock1.setStaticResource('releaseResponse');
        mock1.setStatusCode(400 );
        mock1.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock1);*/
        
        // Call the method that performs the callout
        Test.startTest();
        MDL_Integration_Vim_Efs.releaseInventoryRequest(setOppProdIds,'TestUser');      
        MDL_Integration_Vim_Efs.releaseInventoryRequest(setOppProdIds,'TestUser',mapOpptyProdNInventoryId);
        id enqid = system.enqueueJob(new ReleaseInventroyQueueable(setOppIds,setOppProdIds,'TestUser',mapOpptyProdNInventoryId));
        Test.stopTest();
    }
    
     static testMethod void testRelease500() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account a = testData.getAccount();      
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
        invoiceit_s__Product__c product = testData.getProductWithProvisioning('true', 'Manual Fulfillment');
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);     
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);      
        invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);
        oppProduct.InventoryId__c = '122345';
        update oppProduct;
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = testData.getOpportunityRatePlan(oppProduct.Id, productRatePlan.Id);      
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = testData.getOppRatePlanCharge(OppRatePlan.Id, ProductratePlanCharge.Id);    
        Opportunity_Charge_Attribute__c oppCharges = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'AOP');
        Opportunity_Charge_Attribute__c oppCharges1 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'Service Account Name');
        Opportunity_Charge_Attribute__c oppCharges2 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'State');
        Opportunity_Charge_Attribute__c oppCharges3 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'City');
        Opportunity_Charge_Attribute__c oppCharges4 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'County');
        Opportunity_Charge_Attribute__c oppCharges5 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'Country');
        
        Set<Id> setOppProdIds = new Set<Id>();
        Set<Id> setOppIds = new Set<Id>();
        Map<Id,String> mapOpptyProdNInventoryId = new Map<Id,String>();
        mapOpptyProdNInventoryId.put(oppProduct.Id,oppProduct.InventoryId__c);
        setOppIds.add(opportunity.id);
        setOppProdIds.add(oppProduct.Id);
        String accId = a.Id;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('releaseResponse');
        mock.setStatusCode(500);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        /*StaticResourceCalloutMock mock1 = new StaticResourceCalloutMock();
        mock1.setStaticResource('releaseResponse');
        mock1.setStatusCode(400);
        mock1.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock1);*/
        
        // Call the method that performs the callout
        Test.startTest();
        MDL_Integration_Vim_Efs.releaseInventoryRequest(setOppProdIds,'TestUser');      
        MDL_Integration_Vim_Efs.releaseInventoryRequest(setOppProdIds,'TestUser',mapOpptyProdNInventoryId);
        id enqid = system.enqueueJob(new ReleaseInventroyQueueable(setOppIds,setOppProdIds,'TestUser',mapOpptyProdNInventoryId));
        Test.stopTest();
    }
    
    
    
    static testMethod void testReleaseFromBatch() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account a = testData.getAccount();      
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
        invoiceit_s__Product__c product = testData.getProductWithProvisioning('true', 'Manual Fulfillment');
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);     
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);      
        invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);
        oppProduct.InventoryId__c = '122345';
        update oppProduct;
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = testData.getOpportunityRatePlan(oppProduct.Id, productRatePlan.Id);      
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = testData.getOppRatePlanCharge(OppRatePlan.Id, ProductratePlanCharge.Id);    
        Opportunity_Charge_Attribute__c oppCharges = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'AOP');
        Opportunity_Charge_Attribute__c oppCharges1 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'Service Account Name');
        Opportunity_Charge_Attribute__c oppCharges2 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'State');
        Opportunity_Charge_Attribute__c oppCharges3 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'City');
        Opportunity_Charge_Attribute__c oppCharges4 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'County');
        Opportunity_Charge_Attribute__c oppCharges5 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'Country');
        
        Set<Id> setOppProdIds = new Set<Id>();
        Map<Id,String> mapOpptyProdNInventoryId = new Map<Id,String>();
        mapOpptyProdNInventoryId.put(oppProduct.Id,oppProduct.InventoryId__c);
        setOppProdIds.add(oppProduct.Id);
        String accId = a.Id;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('releaseResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        /*StaticResourceCalloutMock mock1 = new StaticResourceCalloutMock();
        mock1.setStaticResource('releaseResponse');
        mock1.setStatusCode(400);
        mock1.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock1);*/
        
        // Call the method that performs the callout
        Test.startTest();       
        MDL_Integration_Vim_Efs.releaseInventoryRequestFromBatch(setOppProdIds,'TestUser');     
        Test.stopTest();
    }
    
    static testMethod void testReleaseFor400Response() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account a = testData.getAccount();      
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
        invoiceit_s__Product__c product = testData.getProductWithProvisioning('true', 'Manual Fulfillment');
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);     
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);      
        invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);
        oppProduct.InventoryId__c = '122345577';
        update oppProduct;
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = testData.getOpportunityRatePlan(oppProduct.Id, productRatePlan.Id);      
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = testData.getOppRatePlanCharge(OppRatePlan.Id, ProductratePlanCharge.Id);    
        Opportunity_Charge_Attribute__c oppCharges = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'AOP');
        Opportunity_Charge_Attribute__c oppCharges1 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'Service Account Name');
        Opportunity_Charge_Attribute__c oppCharges2 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'State');
        Opportunity_Charge_Attribute__c oppCharges3 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'City');
        Opportunity_Charge_Attribute__c oppCharges4 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'County');
        Opportunity_Charge_Attribute__c oppCharges5 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'Country');
        
        Set<Id> setOppProdIds = new Set<Id>();
        Map<Id,String> mapOpptyProdNInventoryId = new Map<Id,String>();
        mapOpptyProdNInventoryId.put(oppProduct.Id,oppProduct.InventoryId__c);
        setOppProdIds.add(oppProduct.Id);
        String accId = a.Id;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('releaseResponseFor400Error');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        /*StaticResourceCalloutMock mock1 = new StaticResourceCalloutMock();
        mock1.setStaticResource('releaseResponse');
        mock1.setStatusCode(400);
        mock1.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock1);*/
        
        // Call the method that performs the callout
        Test.startTest();
        MDL_Integration_Vim_Efs.releaseInventoryRequest(setOppProdIds,'TestUser');      
        Test.stopTest();
    }
    static testMethod void testreleaseInventoryForOrderCancellation() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account a = testData.getAccount();      
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
        invoiceit_s__Product__c product = testData.getProductWithProvisioning('true', 'Manual Fulfillment');
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);     
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);      
        invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = testData.getOpportunityRatePlan(oppProduct.Id, productRatePlan.Id);      
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = testData.getOppRatePlanCharge(OppRatePlan.Id, ProductratePlanCharge.Id);
        
        List<Opportunity_Charge_Attribute__c> attributeList = new List<Opportunity_Charge_Attribute__c>();
        Opportunity_Charge_Attribute__c oppCharges = testData.getOppChargeswithoutInsert(oppRatePlanCharge.Id, 'Text', 'AOP');
        Opportunity_Charge_Attribute__c oppCharges1 = testData.getOppChargeswithoutInsert(oppRatePlanCharge.Id, 'Text', 'Service Account Name');
        Opportunity_Charge_Attribute__c oppCharges2 = testData.getOppChargeswithoutInsert(oppRatePlanCharge.Id, 'Text', 'State');
        Opportunity_Charge_Attribute__c oppCharges3 = testData.getOppChargeswithoutInsert(oppRatePlanCharge.Id, 'Text', 'City');
        Opportunity_Charge_Attribute__c oppCharges4 = testData.getOppChargeswithoutInsert(oppRatePlanCharge.Id, 'Text', 'County');
        Opportunity_Charge_Attribute__c oppCharges5 = testData.getOppChargeswithoutInsert(oppRatePlanCharge.Id, 'Text', 'Country');
        attributeList.add(oppCharges);
        attributeList.add(oppCharges1);
        attributeList.add(oppCharges2);
        attributeList.add(oppCharges3);
        attributeList.add(oppCharges4);
        attributeList.add(oppCharges5);
        insert attributeList;
        
        invoiceit_s__Job__c order = testData.getOrder(a.Id, CurrencyObj.Id);
        invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
        
        /*invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge = testdata.getOrderRatePlanCharge(OrderRatePlan.Id, ProductRatePlanCharge.Id);
        orderRatePlanCharge.invoiceit_s__Accounting_Code__c = '1001';
        orderRatePlanCharge.Fulfilment_Start_Date__c = Date.Today();
        update orderRatePlanCharge;
        
        Order_Charge_Attribute__c orderCharges = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'AOP');
        Order_Charge_Attribute__c orderCharges1 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'Service Account Name');
        Order_Charge_Attribute__c orderCharges2 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'State');
        Order_Charge_Attribute__c orderCharges3 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'City');
        Order_Charge_Attribute__c orderCharges4 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'County');
        Order_Charge_Attribute__c orderCharges5 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'Country');*/
         Test.startTest();
        orderProduct.Sin_Number__c = '1010101010';
        orderProduct.Inventory_Id__c = '12345';
        orderProduct.invoiceit_s__Product_Code__c = '10001100';     
        update orderProduct;
        
        List<Id> setOrderProdIds = new List<Id>();
        Map<Id,String> mapOrderProdIdNInvenoryId = new Map<Id,String>();
        setOrderProdIds.add(orderProduct.Id);
        mapOrderProdIdNInvenoryId.put(orderProduct.Id,orderProduct.Inventory_Id__c);
        String accId = a.Id;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('releaseResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        /*StaticResourceCalloutMock mock1 = new StaticResourceCalloutMock();
        mock1.setStaticResource('releaseResponse');
        mock1.setStatusCode(400);
        mock1.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock1);*/
        // Call the method that performs the callout
       
        MDL_Integration_Vim_Efs.releaseInventoryRequestForOrderCancellation(setOrderProdIds,'testUser',mapOrderProdIdNInvenoryId);      
        Test.stopTest();
    }
    static testMethod void testreleaseInventoryForOrderCancellationFromBatch() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account a = testData.getAccount();      
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
        invoiceit_s__Product__c product = testData.getProductWithProvisioning('true', 'Manual Fulfillment');
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);     
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);      
        invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = testData.getOpportunityRatePlan(oppProduct.Id, productRatePlan.Id);      
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = testData.getOppRatePlanCharge(OppRatePlan.Id, ProductratePlanCharge.Id);    
        List<Opportunity_Charge_Attribute__c> attributeList = new List<Opportunity_Charge_Attribute__c>();
        Opportunity_Charge_Attribute__c oppCharges = testData.getOppChargeswithoutInsert(oppRatePlanCharge.Id, 'Text', 'AOP');
        Opportunity_Charge_Attribute__c oppCharges1 = testData.getOppChargeswithoutInsert(oppRatePlanCharge.Id, 'Text', 'Service Account Name');
        Opportunity_Charge_Attribute__c oppCharges2 = testData.getOppChargeswithoutInsert(oppRatePlanCharge.Id, 'Text', 'State');
        Opportunity_Charge_Attribute__c oppCharges3 = testData.getOppChargeswithoutInsert(oppRatePlanCharge.Id, 'Text', 'City');
        Opportunity_Charge_Attribute__c oppCharges4 = testData.getOppChargeswithoutInsert(oppRatePlanCharge.Id, 'Text', 'County');
        Opportunity_Charge_Attribute__c oppCharges5 = testData.getOppChargeswithoutInsert(oppRatePlanCharge.Id, 'Text', 'Country');
        attributeList.add(oppCharges);
        attributeList.add(oppCharges1);
        attributeList.add(oppCharges2);
        attributeList.add(oppCharges3);
        attributeList.add(oppCharges4);
        attributeList.add(oppCharges5);
        insert attributeList;
        
         Test.startTest(); 
        invoiceit_s__Job__c order = testData.getOrder(a.Id, CurrencyObj.Id);
        invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
        
        invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge = testdata.getOrderRatePlanCharge(OrderRatePlan.Id, ProductRatePlanCharge.Id);
        orderRatePlanCharge.invoiceit_s__Accounting_Code__c = '1001';
        orderRatePlanCharge.Fulfilment_Start_Date__c = Date.Today();
        update orderRatePlanCharge;
        
        List<Order_Charge_Attribute__c> orderChargeAttributes   = new  List<Order_Charge_Attribute__c>();
        orderChargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Text', 'AOP'));
        orderChargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Text', 'Service Account Name'));
        orderChargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Text', 'State'));
        orderChargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Text', 'City'));
        orderChargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Text', 'County'));
        orderChargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Text', 'Country'));
        insert orderChargeAttributes;
        
        orderProduct.Sin_Number__c = '1010101010';
        orderProduct.Inventory_Id__c = '12345';
        orderProduct.invoiceit_s__Product_Code__c = '10001100';     
        update orderProduct;
        
        List<Id> setOrderProdIds = new List<Id>();
        Map<Id,String> mapOrderProdIdNInvenoryId = new Map<Id,String>();
        setOrderProdIds.add(orderProduct.Id);
        mapOrderProdIdNInvenoryId.put(orderProduct.Id,orderProduct.Inventory_Id__c);
        String accId = a.Id;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('releaseResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        /*StaticResourceCalloutMock mock1 = new StaticResourceCalloutMock();
        mock1.setStaticResource('releaseResponse');
        mock1.setStatusCode(400);
        mock1.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock1);*/
        // Call the method that performs the callout
             
        MDL_Integration_Vim_Efs.releaseInventoryRequestForOrderCancellationFromBatch(setOrderProdIds,'testUser');
        Test.stopTest();
    }
    static testMethod void testOrderRequestFromBatch() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        
        Account a = testData.getAccount();      
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
        invoiceit_s__Product__c product = testData.getProductWithProvisioning('true', 'Manual Fulfillment');
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);     
        /*Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);      
        invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);
        
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = testData.getOpportunityRatePlan(oppProduct.Id, productRatePlan.Id);      
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = testData.getOppRatePlanCharge(OppRatePlan.Id, ProductratePlanCharge.Id);    
        
        Opportunity_Charge_Attribute__c oppCharges = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'AOP');
        Opportunity_Charge_Attribute__c oppCharges1 = testData.getOppCharges(oppRatePlanCharge.Id, 'Number', 'Service Account Name');
        Opportunity_Charge_Attribute__c oppCharges2 = testData.getOppCharges(oppRatePlanCharge.Id, 'Date', 'State');
        Opportunity_Charge_Attribute__c oppCharges3 = testData.getOppCharges(oppRatePlanCharge.Id, 'Boolean', 'City');
        Opportunity_Charge_Attribute__c oppCharges4 = testData.getOppCharges(oppRatePlanCharge.Id, 'Picklist', 'County');
        //Opportunity_Charge_Attribute__c oppCharges5 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'Country');*/
        invoiceit_s__Job__c order = testData.getOrder(a.Id, CurrencyObj.Id);
        invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
        orderProduct.Sin_Number__c = '1010101010';
        orderProduct.invoiceit_s__Product_Code__c = '10001100';
        orderProduct.Inventory_Id__c = '12345';
        update orderProduct;
        
        Set<Id> setOrderIds = new Set<Id>();        
        setOrderIds.add(order.Id); 
        invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge = testdata.getOrderRatePlanCharge(OrderRatePlan.Id, ProductRatePlanCharge.Id);
        //orderRatePlanCharge.invoiceit_s__Service_End_Date__c = Date.today().addDays(-1);
        orderRatePlanCharge.invoiceit_s__Accounting_Code__c = '1001';
        orderRatePlanCharge.Fulfilment_Start_Date__c = Date.Today();        
        update orderRatePlanCharge;
        
        Set<Id> setORPC = new Set<Id>();
        setORPC.add(orderRatePlanCharge.Id);
        
        
        List<Order_Charge_Attribute__c> orderchargeAttributes  = new List<Order_Charge_Attribute__c>();
        orderchargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Text', 'AOP'));
        orderchargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Text', 'Service Account Name'));
        orderchargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Number', 'State'));
        orderchargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Date', 'City'));
        orderchargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Boolean', 'County'));
        orderchargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Picklist', 'Country'));
        orderchargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Phone', 'Phone'));
        insert orderchargeAttributes;
        
        //creating one chat product here
        Chat_Product_Order_Charge__c chatorpc = testData.createChatProduct(orderRatePlanCharge.Id,orderRatePlanCharge.Id);
        insert chatorpc;
                     
        //Map<Id,Opportunity> mapOrderIdNOpp = new Map<Id,Opportunity>();
        //mapOrderIdNOpp.put(order.Id,opportunity);
        
        List<Id> lstAttIds = new List<Id>();
        lstAttIds.add(orderchargeAttributes[0].Id);
        lstAttIds.add(orderchargeAttributes[1].Id);
        lstAttIds.add(orderchargeAttributes[2].Id);
        lstAttIds.add(orderchargeAttributes[3].Id);
        lstAttIds.add(orderchargeAttributes[4].Id);
        lstAttIds.add(orderchargeAttributes[5].Id);
        lstAttIds.add(orderchargeAttributes[6].Id);
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('orderResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        Test.startTest();
        MDL_Integration_Vim_Efs.orderRequestFromBatch(setOrderIds,'testUser',setORPC);
        MDL_Integration_Vim_Efs.orderReqInCaseOfAttributesChange(setORPC,lstAttIds,'testUser');
        Test.stopTest();
    }
    
    static testMethod void testResendHTTPRequestsForOrder() {
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        invoiceit_s__Currency__c cur = util.getCurrencyObject();
        invoiceit_s__Job__c job = util.getOrder(acc.Id, cur.Id);
        String cNum = acc.MH_Cust_Number__c;
        String orderNum = job.Name;
        
        Error_Log__c err = new Error_Log__c();
        err.XML_Mesaage_Type__c = 'OrderRequest';
        err.XML_Body__c = '<OrderRequest xmlns="http://svcs.martindale.com/MHIntegration/OrderRequest/v1.00"><RequestId>a0Hc0000006OjzCEAS-6/30/2014 11:15 AM</RequestId><Order><UserName>lori.ashley@rainbow2.qa</UserName><CustomerNumber>'+cNum+'</CustomerNumber><OrderNumber>'+orderNum+'</OrderNumber><Products><Product><ProductId>a0Dc000000FHoRxEAL</ProductId><SubscriptionIdentificationNumber>1000000514.11053.a0Dc000000FHoRxEAL</SubscriptionIdentificationNumber><ProductCode>11053</ProductCode><LineItems><LineItem><LineItemId>a0Fc0000003MZDQEA420140630111501</LineItemId><SubscriptionIdentificationNumber>1000000514.01885.a0Fc0000003MZDQEA4</SubscriptionIdentificationNumber><ProductCode>01885</ProductCode><ProductName>CWS Plus Build - WX Yr 1</ProductName><Status>Cancel</Status><PostDate>2014-06-30</PostDate><FulfillmentDate>2014-06-30</FulfillmentDate><CancelDate>2014-06-30</CancelDate><IsProductInventoried>false</IsProductInventoried><Attributes><Attribute><Name>InventoryId</Name><Value></Value></Attribute></Attributes></LineItem></LineItems></Product></Products></Order></OrderRequest>';
        err.Sent_Successfully__c = false;
        err.Error_Reason__c = '400 : There is an error while validating the input XML. Please contact us at mhdevelopers@Martindale.com.';
        insert err;
        
        List<Error_Log__c> lstErrLogs = new List<Error_Log__c>();
        lstErrLogs.add(err);
        
        /*StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('orderResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);*/
        
        StaticResourceCalloutMock mock1 = new StaticResourceCalloutMock();
        mock1.setStaticResource('orderResponseFor400Error');
        mock1.setStatusCode(400);
        mock1.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock1);
        
        // Call the method that performs the callout
        Test.startTest();
        MDL_Integration_Vim_Efs.reSendHttpRequests(lstErrLogs);
        Test.stopTest();
    }
    static testMethod void testResendHTTPRequestsForReleaseInv() {
    /*
        Error_Log__c err = new Error_Log__c();
        err.XML_Mesaage_Type__c = 'ReleaseInventory';
        err.Error_Reason__c = '400:Unauthorized';
        err.XML_Body__c = '<ReleaseInventoryRequest xmlns="http://svcs.martindale.com/MHIntegration/ReleaseInventoryRequest/v1.00"><RequestId>a0Dc000000FEyIYEA1-6/23/2014 12:24 AM</RequestId><UserName>lister@smb.p.rainbowqa</UserName><InventoryId>001000000446.01927.00000.00000.000.001.0803.000.000000</InventoryId><CustomerNumber>1000000446</CustomerNumber><ServiceAccountName>Acertis Test</ServiceAccountName></ReleaseInventoryRequest>';
        insert err;
        
        List<Error_Log__c> lstErrLogs = new List<Error_Log__c>();
        lstErrLogs.add(err);
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('releaseResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        StaticResourceCalloutMock mock1 = new StaticResourceCalloutMock();
        mock1.setStaticResource('releaseResponse');
        mock1.setStatusCode(400);
        mock1.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock1);
        
        // Call the method that performs the callout
        //Test.startTest();
        //MDL_Integration_Vim_Efs.reSendHttpRequests(lstErrLogs);
        //Test.stopTest();
        */
    }
    static testMethod void testSendEmailInCaseOfException() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account a = testData.getAccount();
        Test.startTest();
        MDL_Integration_Vim_Efs.sendEmailInCaseOfException('ReleaseInventory',a.Id,'An Exception has occured');
        Test.stopTest();
    }
    static testMethod void testpendInventoryForMidTermProducts() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> orderRPCList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        Map<String,String> mapAttributeNameAndValue = new Map<String,String>();
        Set<Id> setoRPCIds = new Set<Id>();
        Account a = testData.getAccount();
        a.MH_Cust_Number__c='1001';
        update a;       
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
        invoiceit_s__Product__c product = testData.getProductWithProvisioning('true', 'Manual Fulfillment');                
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);     
        invoiceit_s__Job__c order = testData.getOrder(a.Id, CurrencyObj.Id);
        invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
        orderProduct.Sin_Number__c = '1010101010';
        orderProduct.invoiceit_s__Product_Code__c = '10001';
        orderProduct.Inventory_Id__c = '12345'; 
        update orderProduct;
        invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge = testdata.getOrderRatePlanCharge(OrderRatePlan.Id, ProductRatePlanCharge.Id);
        orderRatePlanCharge.invoiceit_s__Accounting_Code__c = '1001';
        orderRatePlanCharge.Fulfilment_Start_Date__c = Date.Today();
        update orderRatePlanCharge;
        setoRPCIds.add(orderRatePlanCharge.Id);
        
        Order_Charge_Attribute__c orderCharges = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'AOP');
        Order_Charge_Attribute__c orderCharges1 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'Service Account Name');
        Order_Charge_Attribute__c orderCharges2 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'State');
        Order_Charge_Attribute__c orderCharges3 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'City');
        Order_Charge_Attribute__c orderCharges4 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'County');
        Order_Charge_Attribute__c orderCharges5 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'Country');
//      Order_Charge_Attribute__c orderCharges6 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Phone', 'Phone');
        mapAttributeNameAndValue.put(orderCharges.Attribute_Name__c,orderCharges.String_Value__c);
        mapAttributeNameAndValue.put(orderCharges1.Attribute_Name__c,orderCharges1.String_Value__c);
        mapAttributeNameAndValue.put(orderCharges2.Attribute_Name__c,orderCharges2.String_Value__c);
        mapAttributeNameAndValue.put(orderCharges3.Attribute_Name__c,orderCharges3.String_Value__c);
        mapAttributeNameAndValue.put(orderCharges4.Attribute_Name__c,orderCharges4.String_Value__c);
        mapAttributeNameAndValue.put(orderCharges5.Attribute_Name__c,orderCharges5.String_Value__c);
        //mapAttributeNameAndValue.put(orderCharges6.Attribute_Name__c,orderCharges5.String_Value__c);      
        
        orderRPCList = [select invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name from invoiceit_s__Job_Rate_Plan_Charge__c where Id in :setoRPCIds];
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('pendResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
            
        // Call the method that performs the callout
        Test.startTest();
        MDL_Integration_Vim_Efs.pendInventoryForMidTermProducts('testUser',orderRPCList,mapAttributeNameAndValue,order);
        Test.stopTest();
    }
    
    //added by Sai: 19/04 to increase code coverage
    //this class needs to be optimize to make more general
     static testMethod void testpendInventoryForMidTermProducts400Response() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> orderRPCList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        Map<String,String> mapAttributeNameAndValue = new Map<String,String>();
        Set<Id> setoRPCIds = new Set<Id>();
        Account a = testData.getAccount();
        a.MH_Cust_Number__c='1001';
        update a;       
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
        invoiceit_s__Product__c product = testData.getProductWithProvisioning('true', 'Manual Fulfillment');                
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);     
        invoiceit_s__Job__c order = testData.getOrder(a.Id, CurrencyObj.Id);
        invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
        orderProduct.Sin_Number__c = '1010101010';
        orderProduct.invoiceit_s__Product_Code__c = '10001';
        orderProduct.Inventory_Id__c = '12345'; 
        update orderProduct;
        invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge = testdata.getOrderRatePlanCharge(OrderRatePlan.Id, ProductRatePlanCharge.Id);
        orderRatePlanCharge.invoiceit_s__Accounting_Code__c = '1001';
        orderRatePlanCharge.Fulfilment_Start_Date__c = Date.Today();
        update orderRatePlanCharge;
        setoRPCIds.add(orderRatePlanCharge.Id);
        
        Order_Charge_Attribute__c orderCharges = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'AOP');
        Order_Charge_Attribute__c orderCharges1 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'Service Account Name');
        Order_Charge_Attribute__c orderCharges2 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'State');
        Order_Charge_Attribute__c orderCharges3 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'City');
        Order_Charge_Attribute__c orderCharges4 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'County');
        Order_Charge_Attribute__c orderCharges5 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Text', 'Country');
//      Order_Charge_Attribute__c orderCharges6 = testData.getOrderCharges(orderRatePlanCharge.Id, 'Phone', 'Phone');
        mapAttributeNameAndValue.put(orderCharges.Attribute_Name__c,orderCharges.String_Value__c);
        mapAttributeNameAndValue.put(orderCharges1.Attribute_Name__c,orderCharges1.String_Value__c);
        mapAttributeNameAndValue.put(orderCharges2.Attribute_Name__c,orderCharges2.String_Value__c);
        mapAttributeNameAndValue.put(orderCharges3.Attribute_Name__c,orderCharges3.String_Value__c);
        mapAttributeNameAndValue.put(orderCharges4.Attribute_Name__c,orderCharges4.String_Value__c);
        mapAttributeNameAndValue.put(orderCharges5.Attribute_Name__c,orderCharges5.String_Value__c);
        //mapAttributeNameAndValue.put(orderCharges6.Attribute_Name__c,orderCharges5.String_Value__c);      
        
        orderRPCList = [select invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name from invoiceit_s__Job_Rate_Plan_Charge__c where Id in :setoRPCIds];
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('pendResponse');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
            
        // Call the method that performs the callout
        Test.startTest();
        MDL_Integration_Vim_Efs.pendInventoryForMidTermProducts('testUser',orderRPCList,mapAttributeNameAndValue,order);
        Test.stopTest();
    }
    
    
    
    static testmethod void testParseResponseXML(){
        String orderResponse='<OrderResponse xmlns:xsd="http://www.martindale.com/mhintegration/data-model" xmlns:xsi="http://www.martindale.com/mhintegration/data-model-instance"><RequestId>a0HL0000007TZRmMAO-12/2/2014 2:22 PM</RequestId><HttpResponseCode>200</HttpResponseCode><Messages><Message><Code>200</Code><Text>SUCCESS</Text></Message></Messages><Order><CustomerNumber>1000002201</CustomerNumber><OrderNumber>3021447</OrderNumber><LineItems><LineItem><SubscriptionIdentificationNumber>1000002201.11006.a0FL0000002XROqMAO</SubscriptionIdentificationNumber></LineItem><LineItem><SubscriptionIdentificationNumber>1000002201.11009.a0FL0000002XSMrMAO</SubscriptionIdentificationNumber></LineItem></LineItems></Order></OrderResponse>';
        List<String> lstOrderResponses = new List<String>();
        lstOrderResponses.add(orderResponse);
        MDL_Integration_Vim_Efs.parseResponseXML_OrderResponse(lstOrderResponses);
        
        String releaseInventoryResponse = '<ReleaseInventoryResponse xmlns:xsd="http://www.martindale.com/mhintegration/data-model" xmlns:xsi="http://www.martindale.com/mhintegration/data-model-instance"><RequestId>a0kL0000003Y4meIAC-12/2/2014 2:54 PM</RequestId><HttpResponseCode>200</HttpResponseCode><Messages><Message><Code>200</Code><Text>SUCCESS</Text></Message></Messages><UserName>lister@smb.p.rainbow</UserName><InventoryId>001000001159.01920.01942.00000.010.001.0725.000.000000</InventoryId><IsCancelled>true</IsCancelled></ReleaseInventoryResponse>';
        List<String> lstReleaseInventoryResponses = new List<String>();
        lstReleaseInventoryResponses.add(releaseInventoryResponse);
        MDL_Integration_Vim_Efs.parseResponseXML_ReleaseInventoryResponse(lstReleaseInventoryResponses);
        
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account a = testData.getAccount();
        String pendInventoryResponse = '<PendInventoryResponse xmlns:xsd="http://www.martindale.com/mhintegration/data-model" xmlns:xsi="http://www.martindale.com/mhintegration/data-model-instance"><RequestId>a0DL0000002kPkCMAU-12/2/2014 4:08 PM</RequestId><HttpResponseCode>200</HttpResponseCode><Messages><Message><Code>200</Code><Text /></Message></Messages><IsInventoryAvailable>true</IsInventoryAvailable><InventoryId>001000002201.01920.01944.00000.010.001.0635.000.000000</InventoryId></PendInventoryResponse>';
        List<String> lstpendInventoryResponses = new List<String>();
        lstpendInventoryResponses.add(pendInventoryResponse);
        MDL_Integration_Vim_Efs.parseResponseXML_PendInventoryResponse(lstPendInventoryResponses,a.Id);
    }
    
    
    
    
     static testMethod void testorderReqInCaseOfOrdercancel() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        
        Account a = testData.getAccount();      
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
        invoiceit_s__Product__c product = testData.getProductWithProvisioning('true', 'Manual Fulfillment');
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);     
        /*Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);      
        invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);
        
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = testData.getOpportunityRatePlan(oppProduct.Id, productRatePlan.Id);      
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = testData.getOppRatePlanCharge(OppRatePlan.Id, ProductratePlanCharge.Id);    
        
        Opportunity_Charge_Attribute__c oppCharges = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'AOP');
        Opportunity_Charge_Attribute__c oppCharges1 = testData.getOppCharges(oppRatePlanCharge.Id, 'Number', 'Service Account Name');
        Opportunity_Charge_Attribute__c oppCharges2 = testData.getOppCharges(oppRatePlanCharge.Id, 'Date', 'State');
        Opportunity_Charge_Attribute__c oppCharges3 = testData.getOppCharges(oppRatePlanCharge.Id, 'Boolean', 'City');
        Opportunity_Charge_Attribute__c oppCharges4 = testData.getOppCharges(oppRatePlanCharge.Id, 'Picklist', 'County');
        //Opportunity_Charge_Attribute__c oppCharges5 = testData.getOppCharges(oppRatePlanCharge.Id, 'Text', 'Country');*/
        invoiceit_s__Job__c order = testData.getOrder(a.Id, CurrencyObj.Id);
        invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
        orderProduct.Sin_Number__c = '1010101010';
        orderProduct.invoiceit_s__Product_Code__c = '10001100';
        orderProduct.Inventory_Id__c = '12345';
        update orderProduct;
        
        Set<Id> setOrderIds = new Set<Id>();        
        setOrderIds.add(order.Id); 
        invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge = testdata.getOrderRatePlanCharge(OrderRatePlan.Id, ProductRatePlanCharge.Id);
        //orderRatePlanCharge.invoiceit_s__Service_End_Date__c = Date.today().addDays(-1);
        orderRatePlanCharge.invoiceit_s__Accounting_Code__c = '1001';
        orderRatePlanCharge.Fulfilment_Start_Date__c = Date.Today();        
        update orderRatePlanCharge;
        
        Set<Id> setORPC = new Set<Id>();
        setORPC.add(orderRatePlanCharge.Id);
         //creating one chat product here
        Chat_Product_Order_Charge__c chatorpc = testData.createChatProduct(orderRatePlanCharge.Id,orderRatePlanCharge.Id);
        insert chatorpc;
        
        List<Order_Charge_Attribute__c> orderchargeAttributes  = new List<Order_Charge_Attribute__c>();
        orderchargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Text', 'AOP'));
        orderchargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Text', 'Service Account Name'));
        orderchargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Number', 'State'));
        orderchargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Date', 'City'));
        orderchargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Boolean', 'County'));
        orderchargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Picklist', 'Country'));
        orderchargeAttributes.add(testData.getOrderChargeswithoutInsert(orderRatePlanCharge.Id, 'Phone', 'Phone'));
        insert orderchargeAttributes;
        //Map<Id,Opportunity> mapOrderIdNOpp = new Map<Id,Opportunity>();
        //mapOrderIdNOpp.put(order.Id,opportunity);
        
        List<Id> lstAttIds = new List<Id>();
        lstAttIds.add(orderchargeAttributes[0].Id);
        lstAttIds.add(orderchargeAttributes[1].Id);
        lstAttIds.add(orderchargeAttributes[2].Id);
        lstAttIds.add(orderchargeAttributes[3].Id);
        lstAttIds.add(orderchargeAttributes[4].Id);
        lstAttIds.add(orderchargeAttributes[5].Id);
        lstAttIds.add(orderchargeAttributes[6].Id);
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('orderResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        Test.startTest();
       
        MDL_Integration_Vim_Efs.orderReqInCaseOfOrdercancel(setORPC,lstAttIds,'testUser');
        Test.stopTest();
    }
}
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
private class MDL_TestClass_CoverIntegrationCode {

    
    static testMethod void testClsPendInventory() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account acc = testData.getAccount();
        Contact c = testData.getContact(acc.Id);
        invoiceit_s__Currency__c cur = testData.getCurrencyObject();
        invoiceit_s__Product__c prod1 = testData.getProduct('true');
        invoiceit_s__Product__c prod2 = testData.getProduct('false');
        invoiceit_s__Product_Rate_Plan__c pRatePlan1 = testData.getProductRatePlan(prod1.Id);
        invoiceit_s__Product_Rate_Plan__c pRatePlan2 = testData.getProductRatePlan(prod2.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c rpc1 = testData.getProductRatePlanCharge(cur.Id, pRatePlan1.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c rpc2 = testData.getProductRatePlanCharge(cur.Id, pRatePlan2.Id);
        Opportunity o = testData.getOpportunity(acc.Id, c.Id, cur.Id);
        Opportunity o1 = testData.getOpportunity(acc.Id, c.Id, cur.Id);
        invoiceit_crmx__Opportunity_Product__c oppProd = testData.getOpportunityProduct(prod1.Id, o.Id);
        //invoiceit_crmx__Opportunity_Product__c oppProd1 = testData.getOpportunityProduct(prod2.Id, o1.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRP = testData.getOpportunityRatePlan(oppProd.Id, pRatePlan1.Id);
        //invoiceit_crmx__Opportunity_Rate_Plan__c oppRP1 = testData.getOpportunityRatePlan(oppProd1.Id, pRatePlan2.Id);
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oRPC = testData.getOppRatePlanCharge(oppRP.Id, rpc1.Id);
        //invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oRPC1 = testData.getOppRatePlanCharge(oppRP1.Id, rpc2.Id);
        Opportunity_Charge_Attribute__c charge1 = testData.getOppCharges(oRPC.Id, 'Text', 'Service City');
        Opportunity_Charge_Attribute__c charge2 = testData.getOppCharges(oRPC.Id, 'Picklist', 'AOP');
        Opportunity_Charge_Attribute__c charge3 = testData.getOppCharges(oRPC.Id, 'Number', 'Phone');
        Opportunity_Charge_Attribute__c charge4 = testData.getOppCharges(oRPC.Id, 'Date', 'Sell Date');
        Opportunity_Charge_Attribute__c charge5 = testData.getOppCharges(oRPC.Id, 'Boolean', 'AOP');
        
        /*Opportunity_Charge_Attribute__c charge6 = testData.getOppCharges(oRPC1.Id, 'Text', 'Service City');
        Opportunity_Charge_Attribute__c charge7 = testData.getOppCharges(oRPC1.Id, 'Picklist', 'AOP');
        Opportunity_Charge_Attribute__c charge8 = testData.getOppCharges(oRPC1.Id, 'Number', 'Phone');
        Opportunity_Charge_Attribute__c charge9 = testData.getOppCharges(oRPC1.Id, 'Date', 'Sell Date');
        Opportunity_Charge_Attribute__c charge10 = testData.getOppCharges(oRPC1.Id, 'Boolean', 'AOP');
        */
        Test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(o);
        Test.setCurrentPage(new Pagereference('apex/MDL_PendInventoryPage?id='+o.Id));
        MDL_ClsPendInventoryRequest pend = new MDL_ClsPendInventoryRequest(sc);
        ApexPages.currentPage().getParameters().put('id',o.Id);
        Pagereference pf1 = pend.sendPendInventoryRequest(); 
        Test.setCurrentPage(new Pagereference('apex/MDL_PendInventoryPage?id='+o.Id));
        MDL_ClsPendInventoryRequest pend1 = new MDL_ClsPendInventoryRequest(sc);
        Pagereference pf2 = pend1.cancel();
        
        ApexPAges.StandardController sc1 = new ApexPages.StandardController(o1);
        Test.setCurrentPage(new Pagereference('apex/MDL_PendInventoryPage?id='+o1.Id));
        MDL_ClsPendInventoryRequest pend2 = new MDL_ClsPendInventoryRequest(sc1);
        ApexPages.currentPage().getParameters().put('id',o1.Id);
        Pagereference pf3 = pend.sendPendInventoryRequest(); 
        Test.setCurrentPage(new Pagereference('apex/MDL_PendInventoryPage?id='+o1.Id));
        MDL_ClsPendInventoryRequest pend3 = new MDL_ClsPendInventoryRequest(sc1);
        Pagereference pf4 = pend1.cancel();
        
        Test.stopTest();
    }
    static testMethod void testPendInv() {
        
        String rXML;
        String rXML1;
        String relXMl,relXML1;
        String orderXML;
        List<invoiceit_s__Job_Rate_Plan_Charge__c> lstOrderRPC = new List<invoiceit_s__Job_Rate_Plan_Charge__c> ();
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account acc = testData.getAccount();
        Contact c = testData.getContact(acc.Id);
        invoiceit_s__Currency__c cur = testData.getCurrencyObject();
        invoiceit_s__Product__c prod1 = testData.getProduct('true');
        invoiceit_s__Product_Rate_Plan__c pRatePlan1 = testData.getProductRatePlan(prod1.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c rpc1 = testData.getProductRatePlanCharge(cur.Id, pRatePlan1.Id);
        Opportunity o = testData.getOpportunity(acc.Id, c.Id, cur.Id);
        invoiceit_crmx__Opportunity_Product__c oppProd = testData.getOpportunityProduct(prod1.Id, o.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRP = testData.getOpportunityRatePlan(oppProd.Id, pRatePlan1.Id);
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oRPC = testData.getOppRatePlanCharge(oppRP.Id, rpc1.Id);
        Opportunity_Charge_Attribute__c charge1 = testData.getOppCharges(oRPC.Id, 'Text', 'City');
        Opportunity_Charge_Attribute__c charge2 = testData.getOppCharges(oRPC.Id, 'Text', 'State');
        Opportunity_Charge_Attribute__c charge3 = testData.getOppCharges(oRPC.Id, 'Text', 'County');
        Opportunity_Charge_Attribute__c charge4 = testData.getOppCharges(oRPC.Id, 'Text', 'Country');
        Opportunity_Charge_Attribute__c charge5 = testData.getOppCharges(oRPC.Id, 'Picklist', 'AOP');
        Opportunity_Charge_Attribute__c charge6 = testData.getOppCharges(oRPC.Id, 'Text', 'Service Account Name');
        Test.startTest();
        invoiceit_s__Job__c order1 = testData.getOrder(acc.Id, cur.Id);
        invoiceit_s__Job_Product__c orderProd1 = testData.getOrderProduct(order1.Id, prod1.Id);
        orderProd1.Inventory_Id__c = '123.456.789';
        update orderProd1;
        invoiceit_s__Job_Rate_Plan__c orderRP1 = testData.getOrderRatePlan(orderProd1.Id, pRatePlan1.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRPC1 = testData.getOrderRatePlanCharge(orderRP1.Id, rpc1.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRPC2 = testData.getOrderRatePlanCharge(orderRP1.Id, rpc1.Id);
        lstOrderRPC.add(orderRPC1);lstOrderRPC.add(orderRPC2);
        
        
        Order_Charge_Attribute__c orderCharge1 = testData.getOrderCharges(orderRPC1.Id, 'Text', 'Service Account Name');
        Order_Charge_Attribute__c orderCharge2 = testData.getOrderCharges(orderRPC1.Id, 'Number', 'Phone');
        Order_Charge_Attribute__c orderCharge3 = testData.getOrderCharges(orderRPC1.Id, 'Picklist', 'AOP');
        
        rXML = MDL_Integration_Vim_Efs.constructXML_PendInventory(oppProd,'10001','TestUser');
        rXML1 = MDL_Integration_Vim_Efs.constructXML_PendInventory(oppProd,null,'TestUser'); 
        List<String> respStrings = new List<String>();
        respStrings.add('<PendInventoryResponse><RequestId>0123-123</RequestId><HttpResponseCode>200</HttpResponseCode><IsInventoryAvailable>True</IsInventoryAvailable><InventoryId>100001.11002.1111</InventoryId><Messages><Message><QueueName>TBD</QueueName><Code>HTTP 401 Unauthorized</Code><Text>Authentication Failure</Text></Message> </Messages></PendInventoryResponse>');
        respStrings.add('<PendInventoryResponse><RequestId>0125-126</RequestId><HttpResponseCode>401</HttpResponseCode><IsInventoryAvailable/><InventoryId/><Messages><Message><QueueName>TBD</QueueName><Code>HTTP 401 Unauthorized</Code><Text>Authentication Failure</Text></Message> </Messages></PendInventoryResponse>');
        MDL_Integration_Vim_Efs.parseResponseXML_PendInventoryResponse(respStrings,acc.Id);
        relXMl = MDL_Integration_Vim_Efs.constructXML_ReleaseInventory(oppProd,'testUser');
        respStrings.clear();
        respStrings.add('<ReleaseInventoryResponse><RequestId>0f8fad5b-d9cb-469f-a165-70867728950e</RequestId><UserName>SFDC user login</UserName><InventoryId>12345</InventoryId><HttpResponseCode>401</HttpResponseCode><IsCancelled>false</IsCancelled><Messages><Message><QueueName>TBD</QueueName><Code>HTTP 401 Unauthorized</Code><Text>Authentication Failure</Text></Message></Messages></ReleaseInventoryResponse>');
        respStrings.add('<ReleaseInventoryResponse><RequestId>0f8fad5b-d9cb-469f-a165-70867728950e</RequestId><UserName>SFDC user login</UserName><InventoryId>12345</InventoryId><HttpResponseCode>200</HttpResponseCode><IsCancelled>true</IsCancelled><Messages><Message><QueueName>TBD</QueueName><Code>200</Code><Text>Success</Text></Message></Messages></ReleaseInventoryResponse>');
        MDL_Integration_Vim_Efs.parseResponseXML_ReleaseInventoryResponse(respStrings);
        relXML1 = MDL_Integration_Vim_Efs.constructXML_ReleaseInventoryForOrderCancellation(orderProd1,'Test User','123.456.789');
        //orderXML = MDL_Integration_Vim_Efs.constructXML_OrderRequest('Test User',lstOrderRPC ,order1);
        
        
        
        Test.stopTest();
    }
    
    static testMethod void testPendInvForMidTermProducts() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account acc = testData.getAccount();
        Contact c = testData.getContact(acc.Id);
        invoiceit_s__Currency__c cur = testData.getCurrencyObject();
        invoiceit_s__Product__c prod1 = testData.getProduct('true');
        invoiceit_s__Product_Rate_Plan__c pRatePlan1 = testData.getProductRatePlan(prod1.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c rpc1 = testData.getProductRatePlanCharge(cur.Id, pRatePlan1.Id);
        Opportunity o = testData.getOpportunity(acc.Id, c.Id, cur.Id);
        invoiceit_crmx__Opportunity_Product__c oppProd = testData.getOpportunityProduct(prod1.Id, o.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRP = testData.getOpportunityRatePlan(oppProd.Id, pRatePlan1.Id);
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oRPC = testData.getOppRatePlanCharge(oppRP.Id, rpc1.Id);
        Opportunity_Charge_Attribute__c charge1 = testData.getOppCharges(oRPC.Id, 'Text', 'City');
        Opportunity_Charge_Attribute__c charge2 = testData.getOppCharges(oRPC.Id, 'Text', 'State');
        Opportunity_Charge_Attribute__c charge3 = testData.getOppCharges(oRPC.Id, 'Text', 'County');
        Opportunity_Charge_Attribute__c charge4 = testData.getOppCharges(oRPC.Id, 'Text', 'Country');
        Opportunity_Charge_Attribute__c charge5 = testData.getOppCharges(oRPC.Id, 'Picklist', 'AOP');
        Opportunity_Charge_Attribute__c charge6 = testData.getOppCharges(oRPC.Id, 'Text', 'Service Account Name');
        Test.startTest();
        invoiceit_s__Job__c order1 = testData.getOrder(acc.Id, cur.Id);
        invoiceit_s__Job_Product__c orderProd1 = testData.getOrderProduct(order1.Id, prod1.Id);
        invoiceit_s__Job_Rate_Plan__c orderRP1 = testData.getOrderRatePlan(orderProd1.Id, pRatePlan1.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRPC1 = testData.getOrderRatePlanCharge(orderRP1.Id, rpc1.Id);
        
        Order_Charge_Attribute__c orderCharge1 = testData.getOrderCharges(orderRPC1.Id, 'Text', 'Service Account Name');
        Order_Charge_Attribute__c orderCharge2 = testData.getOrderCharges(orderRPC1.Id, 'Number', 'Phone');
        Order_Charge_Attribute__c orderCharge3 = testData.getOrderCharges(orderRPC1.Id, 'Picklist', 'AOP');
        
        
        ApexPAges.StandardController sc = new ApexPages.StandardController(order1);
        Test.setCurrentPage(new Pagereference('apex/MDL_PendInventoryForMidTermProductsPage?id='+order1.Id));
        MDL_ClsPendnventoryForMidTermProducts pend = new MDL_ClsPendnventoryForMidTermProducts(sc);
        ApexPages.currentPage().getParameters().put('id',order1.Id);
        Pagereference pf1 = pend.sendPendRequest(); 
        Test.setCurrentPage(new Pagereference('apex/MDL_PendInventoryForMidTermProductsPage?id='+order1.Id));
        MDL_ClsPendInventoryRequest pend1 = new MDL_ClsPendInventoryRequest(sc);
        Pagereference pf2 = pend.cancel();
        
        ApexPAges.StandardController sc1 = new ApexPages.StandardController(order1);
        Test.setCurrentPage(new Pagereference('apex/MDL_ReadOnlyOrderDetailPage?id='+order1.Id));
        MDL_CtrlReadOnlyOrderDetailPage m = new MDL_CtrlReadOnlyOrderDetailPage(sc1);
        m.initialize();
        m.cancel();
        
        Test.stopTest();
    }
    static testMethod void testMethodForMidTermProds() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account acc = testData.getAccount();
        Contact c = testData.getContact(acc.Id);
        invoiceit_s__Currency__c cur = testData.getCurrencyObject();
        invoiceit_s__Product__c prod1 = testData.getProduct('true');
        invoiceit_s__Product_Rate_Plan__c pRatePlan1 = testData.getProductRatePlan(prod1.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c rpc1 = testData.getProductRatePlanCharge(cur.Id, pRatePlan1.Id);
        Opportunity o = testData.getOpportunity(acc.Id, c.Id, cur.Id);
        invoiceit_crmx__Opportunity_Product__c oppProd = testData.getOpportunityProduct(prod1.Id, o.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRP = testData.getOpportunityRatePlan(oppProd.Id, pRatePlan1.Id);
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oRPC = testData.getOppRatePlanCharge(oppRP.Id, rpc1.Id);
        Opportunity_Charge_Attribute__c charge1 = testData.getOppCharges(oRPC.Id, 'Text', 'City');
        Opportunity_Charge_Attribute__c charge2 = testData.getOppCharges(oRPC.Id, 'Text', 'State');
        Opportunity_Charge_Attribute__c charge3 = testData.getOppCharges(oRPC.Id, 'Text', 'County');
        Opportunity_Charge_Attribute__c charge4 = testData.getOppCharges(oRPC.Id, 'Text', 'Country');
        Opportunity_Charge_Attribute__c charge5 = testData.getOppCharges(oRPC.Id, 'Picklist', 'AOP');
        Opportunity_Charge_Attribute__c charge6 = testData.getOppCharges(oRPC.Id, 'Text', 'Service Account Name');
        Test.startTest();
        invoiceit_s__Job__c order1 = testData.getOrder(acc.Id, cur.Id);
        invoiceit_s__Job_Product__c orderProd1 = testData.getOrderProduct(order1.Id, prod1.Id);
        invoiceit_s__Job_Rate_Plan__c orderRP1 = testData.getOrderRatePlan(orderProd1.Id, pRatePlan1.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRPC1 = testData.getOrderRatePlanCharge(orderRP1.Id, rpc1.Id);
        orderRPC1.invoiceit_s__Mid_Term_Status__c = 'New';
        update orderRPC1;
         
        Order_Charge_Attribute__c orderCharge1 = testData.getOrderCharges(orderRPC1.Id, 'Text', 'Service Account Name');
        Order_Charge_Attribute__c orderCharge2 = testData.getOrderCharges(orderRPC1.Id, 'Number', 'Phone');
        Order_Charge_Attribute__c orderCharge3 = testData.getOrderCharges(orderRPC1.Id, 'Picklist', 'AOP');
        Order_Charge_Attribute__c orderCharge4 = testData.getOrderCharges(orderRPC1.Id, 'Boolean', 'isTrue');
        Order_Charge_Attribute__c orderCharge5 = testData.getOrderCharges(orderRPC1.Id, 'Date', 'TodayDate');
        orderCharge5.Date_Value__c = null;
        update orderCharge5;
       
        ApexPAges.StandardController sc = new ApexPages.StandardController(order1);
        Test.setCurrentPage(new Pagereference('apex/MDL_PendInventoryForMidTermProductsPage?id='+order1.Id));
        MDL_ClsPendnventoryForMidTermProducts pend = new MDL_ClsPendnventoryForMidTermProducts(sc);
        ApexPages.currentPage().getParameters().put('id',order1.Id);
        Pagereference pf1 = pend.sendPendRequest(); 
        orderCharge5.Date_Value__c = Date.today();
        update orderCharge5;
        Pagereference pf2 = pend.sendPendRequest();
        Test.stopTest();
    }
}
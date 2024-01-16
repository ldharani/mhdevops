@isTest(seealldata = true)
public class MDL_Test_PendInventoryRequestCtrl{
    static testmethod void testPendInventoryRequest(){
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
      invoiceit_crmx__Opportunity_Rate_Plan__c oppRP = testData.getOpportunityRatePlan(oppProd.Id, pRatePlan1.Id);
      invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oRPC = testData.getOppRatePlanCharge(oppRP.Id, rpc1.Id);
      Opportunity_Charge_Attribute__c charge1 = testData.getOppCharges(oRPC.Id, 'Text', 'Service City');
      Opportunity_Charge_Attribute__c charge2 = testData.getOppCharges(oRPC.Id, 'Picklist', 'City');
      Opportunity_Charge_Attribute__c charge3 = testData.getOppCharges(oRPC.Id, 'Picklist', 'County');
      Opportunity_Charge_Attribute__c charge4 = testData.getOppCharges(oRPC.Id, 'Picklist', 'State');
      Opportunity_Charge_Attribute__c charge6 = testData.getOppCharges(oRPC.Id, 'Picklist', 'AOP');
      Opportunity_Charge_Attribute__c charge7 = testData.getOppCharges(oRPC.Id, 'Number', 'Phone');
      Opportunity_Charge_Attribute__c charge8 = testData.getOppCharges(oRPC.Id, 'Date', 'Sell Date');
      Opportunity_Charge_Attribute__c charge9 = testData.getOppCharges(oRPC.Id, 'Boolean', 'AOP');
      Opportunity_Charge_Attribute__c charge10 = testData.getOppCharges(oRPC.Id, 'Text', 'Country');
      
      Test.startTest();
      ApexPAges.StandardController sc = new ApexPages.StandardController(o);
      Test.setCurrentPage(new Pagereference('apex/MDL_PendInventoryPage?id='+o.Id));
      MDL_PendInventoryRequestCtrl pend = new MDL_PendInventoryRequestCtrl(sc);
      ApexPages.currentPage().getParameters().put('id',o.Id);
      
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('pendResponseFor400Response');
      mock.setStatusCode(400);
      mock.setHeader('Content-Type', 'application/xml');
      // Set the mock callout mode
      Test.setMock(HttpCalloutMock.class, mock);
      // Call the method that performs the callout
      
      Pagereference pf1 = pend.sendPendInventoryRequest(); 
      Test.setCurrentPage(new Pagereference('apex/MDL_PendInventoryPage?id='+o.Id));
      MDL_PendInventoryRequestCtrl pend1 = new MDL_PendInventoryRequestCtrl(sc);
      Pagereference pf2 = pend1.cancel();
      
      ApexPAges.StandardController sc1 = new ApexPages.StandardController(o1);
      Test.setCurrentPage(new Pagereference('apex/MDL_PendInventoryPage?id='+o1.Id));
      MDL_PendInventoryRequestCtrl pend2 = new MDL_PendInventoryRequestCtrl(sc1);
      ApexPages.currentPage().getParameters().put('id',o1.Id);
      Pagereference pf3 = pend.sendPendInventoryRequest(); 
            
      Test.stopTest();
    }
}
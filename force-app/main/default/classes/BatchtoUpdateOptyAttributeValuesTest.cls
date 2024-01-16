@isTest(seeAllData = true)
public class BatchtoUpdateOptyAttributeValuesTest {
    
    static testmethod void run2condtion(){
        
         //creating test data
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        Contact con = util.getContact(acc.Id);
        
        //product creation
        invoiceit_s__Product__c prod                                = util.getProduct('isInventorable');
        
        //product rate plan creation
        invoiceit_s__Product_Rate_Plan__c prodrateplan              = util.getProductRatePlan(prod.Id);
        
        //product rate plan charge creation
        invoiceit_s__Product_Rate_Plan_Charge__c prodRatePlanCharge = util.getProductRatePlanCharge(Curr.Id, prodrateplan.id);
        
        //Opportunity Creation
        Opportunity opp = util.getOpportunity(acc.Id , con.Id ,curr.Id );
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        //oppprod1.InventoryId__c = '110111';
        //update oppprod1;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);
        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
         //creating orderCharge Attributes
        Opportunity_Charge_Attribute__c serviceCountry                    = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'Service Country', 'TestUSA');
        Opportunity_Charge_Attribute__c serviceState                      = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'Service State', 'TestNC');
        Opportunity_Charge_Attribute__c serviceCounty                     = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'County', 'TestCounty');
        Opportunity_Charge_Attribute__c serviceCity                       = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'Service City', 'TestBoston');
        Opportunity_Charge_Attribute__c xrefCountry                       = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'Xref Country', 'TestUSA');
        Opportunity_Charge_Attribute__c xrefState                         = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'Xref State', 'TestNC');
        Opportunity_Charge_Attribute__c xrefCity                          = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'Xref City', 'TestBoston');
        Opportunity_Charge_Attribute__c country                           = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'Country', 'TestUSA');
        Opportunity_Charge_Attribute__c state                             = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'State', 'TestNC');
        Opportunity_Charge_Attribute__c city                              = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'City', 'TestBoston');
        
        //creating geo location record
        Geo_location__c geo                                         = util.getGeolocation('TestUSA','TestNC','','TestBoston');
        
        Test.startTest();
            database.executeBatch(new BatchtoUpdateAttributeValues(null), 5);
        Test.stopTest();
    }

}
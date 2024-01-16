@isTest(seeAllData = true)
public class BatchtoUpdateOrderAttribValuesTest {
    
    static testmethod void run2condition(){
        
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
        
        //order creation
        invoiceit_s__Job__c order                                   = util.getOrder(acc.Id, curr.id);
        
        //order product creation
        invoiceit_s__Job_Product__c orderprod                       = util.getOrderProduct(order.Id, prod.Id);
        
        //order rate plan creation
        invoiceit_s__Job_Rate_Plan__c orderrateplan                 = util.getOrderRatePlan(orderprod.id, prodrateplan.id);
        
        //order rate plan charge creation
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        
        //creating orderCharge Attributes
        Order_Charge_Attribute__c serviceCountry                    = util.getOrderChargeAttributes(orderRatePlanCharge.id, 'Text', 'Service Country', 'TestUSA');
        Order_Charge_Attribute__c serviceState                      = util.getOrderChargeAttributes(orderRatePlanCharge.id, 'Picklist', 'Service State', 'TestNC');
        Order_Charge_Attribute__c serviceCounty                     = util.getOrderChargeAttributes(orderRatePlanCharge.id, 'Picklist', 'County', 'TestCounty');
        Order_Charge_Attribute__c serviceCounty2                     = util.getOrderChargeAttributes(orderRatePlanCharge.id, 'Text', 'County', 'TestCounty');
        Order_Charge_Attribute__c serviceCity                       = util.getOrderChargeAttributes(orderRatePlanCharge.id, 'Text', 'Service City', 'TestBoston');
        Order_Charge_Attribute__c xrefCountry                       = util.getOrderChargeAttributes(orderRatePlanCharge.id, 'Text', 'Xref Country', 'TestUSA');
        Order_Charge_Attribute__c xrefState                         = util.getOrderChargeAttributes(orderRatePlanCharge.id, 'Picklist', 'Xref State', 'TestNC');
        Order_Charge_Attribute__c xrefCity                          = util.getOrderChargeAttributes(orderRatePlanCharge.id, 'Text', 'Xref City', 'TestBoston');
        Order_Charge_Attribute__c country                           = util.getOrderChargeAttributes(orderRatePlanCharge.id, 'Text', 'Country', 'TestUSA');
        Order_Charge_Attribute__c state                             = util.getOrderChargeAttributes(orderRatePlanCharge.id, 'Picklist', 'State', 'TestNC');
        Order_Charge_Attribute__c city                              = util.getOrderChargeAttributes(orderRatePlanCharge.id, 'Text', 'City', 'TestBoston');
        
        //creating geo location record
        Geo_location__c geo                                         = util.getGeolocation('TestUSA','TestNC','','TestBoston');
        geo.recordTypeid= Schema.SObjectType.GEO_Location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        update geo;
        Test.startTest();
            database.executeBatch(new BatchtoUpdateOrderAttributeValues(), 5);
        Test.stopTest();
        
    }

}
/**@@
#APEX CLASS NAME       :    OrderTriggerTest
#CREATED BY            :    Serge Kandukuri
#DESCRIPTION           :    This is test class for OrderTrigger (Apex Trigger), Trigger_Order_Handler and Trigger_Order_Helper (Apex Class).
@@**/
@IsTest
public class OrderTriggerTest{
    /**@@
    #DESCRIPTION     : Creating test records
    #Paramaters      : None
    @@**/
    @testSetup static void setup() {
         // Load Custom settings
        DataFactory.loadCustomSettings();
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
        // Create Test Opportunity
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Opportunity').getRecordTypeId();
        List<Opportunity> lstOpp = DataFactory.createOpportunity('Test Opp', lstAcc[0], oppRecordTypeId, 1);
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // Create Billing Rule
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
        
        // Create ConsumptionSchedule 
     //   ConsumptionSchedule objCS = DataFactory.createConsumptionSchedule(objBR, objRR, objTR);
        
        // Create ConsumptionSchedule 
    //    ConsumptionRate objCR = DataFactory.creatConsumptionRate(objCS);
        
    //    objCS.IsActive = TRUE;
    //    update objCS;
        
        // Create Test Product
        List<Product2> lstProd = DataFactory.createProduct('Test Product', objBR, objRR, objTR, 1);
        
        // Creaet Test Product Consumption Schedule
    //    ProductConsumptionSchedule objPCS = DataFactory.creatProductConsumptionSchedule(objCS, lstProd[0]);
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        
        // Create Attribute_Lines__c - Practice Area
        Attribute_Lines__c objAL = DataFactory.createAttributeLines(objAR, 'Practice Area', 'String', 'SSDI', '');
        
        // Create Attribute_Lines__c - Service State
    //    Attribute_Lines__c objAL1 = DataFactory.createAttributeLines(objAR, 'Service State', 'Multi-Picklist', '', 'Connecticut;Delaware;');
        
        // Create Attribute_Lines__c - Practice Area
       Attribute_Lines__c objAL2 = DataFactory.createAttributeLines(objAR, 'Service County', 'Multi-Picklist', '', 'Connecticut---Tolland;Delaware---Sussex;Delaware---New Castle;Delaware---Kent');
      
      
        // Create Test Attribute Configuration - Practice Area
   //     Attribute_Configuration__c objAC1 = DataFactory.createAtrConfiguration('Practice Area', 1, 'Text');
   //     ProductAttribute__c objPA1 = DataFactory.createProductAttribute(objAC1, lstProd[0], 'String');
        
        
        // Create Test Attribute Configuration - Service State
    //    Attribute_Configuration__c objAC = DataFactory.createAtrConfiguration('Service State', 4, 'Picklist');
    //    ProductAttribute__c objPA = DataFactory.createProductAttribute(objAC, lstProd[0], 'Multi-Picklist');
        
        
        // Create Test Attribute Configuration - Service County
    //    Attribute_Configuration__c objAC2 = DataFactory.createAtrConfiguration('Service County', 6, 'Text');
    //    ProductAttribute__c objPA2 = DataFactory.createProductAttribute(objAC2, lstProd[0], 'Multi-Picklist');
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        // Create Test Quote Line 
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Quote Line').getRecordTypeId();
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        
        // Create Test Opportunity Line Item
        DataFactory.createOpportunityLineItem(lstOpp[0], lstProd[0], objPBEntry, objQLI);
        
         Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Order').getRecordTypeId();
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = lstAcc[0].id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        insert objOrder;
        
        OrderItem objOI = new OrderItem();
        objOI.OrderId = objOrder.id;
        objOI.Quantity = 24;
        objOI.UnitPrice = 240;
        objOI.Product2id = lstProd[0].id;
            //objOI.Status__c = Constant.ORDER_STATUS_ACTIVE;
        objOI.PricebookEntryId=objPBEntry.id;
        objOI.SBQQ__ChargeType__c = 'Recurring';
        objOI.SBQQ__BillingFrequency__c = 'Monthly';
        objOI.SBQQ__BillingType__c = 'Arrears';
        objOI.blng__BillingRule__c = objBR.Id;
        objOI.blng__RevenueRecognitionRule__c = objRR.Id;
        objOI.SBQQ__Activated__c = TRUE;
        objOI.blng__TaxRule__c = objTR.Id;
        objOI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objOI.Attribute_Relationship__c = objAR.Id;
        objOI.ServiceDate=System.today();
        insert objOI;
        
       // objOI.Status__c = Constant.ORDER_STATUS_CANCELLED;
       // update objOI;
        
        blng__UsageSummary__c objUSummary = new blng__UsageSummary__c();
        
        objUSummary.blng__MatchingId__c = '1234';
        objUSummary.blng__MatchingAttribute__c = 'Quarterly';
        objUSummary.blng__UnitOfMeasure__c = 'Hours';
        objUSummary.blng__Account__c = lstAcc[0].Id;
        objUSummary.blng__Order__c = objOrder.Id;
        objUSummary.blng__OrderProduct__c = objOI.Id;
        objUSummary.blng__TotalQuantity__c = 1;
        objUSummary.blng__SummaryStartDate__c = objOI.ServiceDate;
        objUSummary.blng__SummaryEndDate__c = objOI.ServiceDate.adddays(16);
        insert objUSummary;
       
    }
    
    public static testMethod void testUnitMethod1(){        
        Test.startTest();
        Order objOrder = [SELECT Id FROM Order LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorOItem());
        objOrder.Status = Constant.ORDER_STATUS_ACTIVATED;        
        objOrder.Type = Constant.ORDER_TYPE_AMENDMENT;
        update objOrder;
        Test.stopTest();
    }
    
    public static testMethod void testUnitMethod1UPDATE(){
        Test.startTest();
        Order objOrder = [SELECT Id FROM Order LIMIT 1];
        OrderItem objOrderItem = [SELECT Id,Status__c FROM OrderItem LIMIT 1];
      
         objOrder.Status = Constant.ORDER_STATUS_ACTIVATED;
         update objOrder;
        
        List<id> ordIds = new List<id>(); 
        ordIds.add(objOrder.id);
        
        List<id> ordItemsIds = new List<id>();
        ordItemsIds.add(objOrderItem.id);
        
        Set<id> ordIdset = new Set<id>(); 
        ordIdset.add(objOrder.id);
        
        Set<id> ordItemIdSet = new Set<id>();
        ordItemIdSet.add(objOrderItem.id);
        Trigger_OrderItem_Helper.addNewCampaignAPI(ordItemIdSet,ordIdset);
        Trigger_OrderItem_Helper.prepareRequestBody(objOrder);
        
        Test.stopTest();
    }
    
    public static testMethod void testUnitMethod2(){
        Test.startTest();
        Order objOrder = [SELECT Id FROM Order LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorOItem());
        set<Id> sOrderId = new set<Id>();
        sOrderId.add(objOrder.Id);
        Trigger_Order_Helper.createLawfirmAPIFuture(sOrderId);
        Trigger_Order_Helper.prepareRequestBodyAddCampaign(objOrder);
        Trigger_Order_Helper.updateOrderItemStatus(sOrderId);
        Test.stopTest();
    }
}
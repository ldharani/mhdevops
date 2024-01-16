/**@@
#APEX CLASS NAME       :   UsageTriggerTest
#CREATED BY            :   Serge Kandukuri
#DESCRIPTION           :   This is test class for UsageTrigger (Apex Trigger) and Trigger_Usage_Handler, Trigger_Usage_Helper (Apex Class).
@@**/
@IsTest
public class UsageTriggerTest{
    /**@@
    #DESCRIPTION     : Creating test records
    #Paramaters      : None
    @@**/
    @testSetup static void setup() {
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
        // Create Test Opportunity
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Intake Opportunity').getRecordTypeId();
        List<Opportunity> lstOpp = DataFactory.createOpportunity('Test Opp', lstAcc[0], oppRecordTypeId, 1);
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // Create Billing Rule
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
        
        // Create ConsumptionSchedule 
        ConsumptionSchedule objCS = DataFactory.createConsumptionSchedule(objBR, objRR, objTR);
        
        // Create ConsumptionSchedule 
        ConsumptionRate objCR = DataFactory.creatConsumptionRate(objCS);
        
        objCS.IsActive = TRUE;
        update objCS;
        
        // Create Test Product
        List<Product2> lstProd = DataFactory.createProduct('Test Product', objBR, objRR, objTR, 1);
        
        // Creaet Test Product Consumption Schedule
        ProductConsumptionSchedule objPCS = DataFactory.creatProductConsumptionSchedule(objCS, lstProd[0]);
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        
        // Create Attribute_Lines__c - Practice Area
        Attribute_Lines__c objAL = DataFactory.createAttributeLines(objAR, 'Practice Area', 'String', 'SSDI', '');
        
        // Create Attribute_Lines__c - Service State
        Attribute_Lines__c objAL1 = DataFactory.createAttributeLines(objAR, 'Service State', 'Multi-Picklist', '', 'Connecticut;Delaware;');
        
        // Create Attribute_Lines__c - Practice Area
        Attribute_Lines__c objAL2 = DataFactory.createAttributeLines(objAR, 'Service County', 'Multi-Picklist', '', 'Connecticut---Tolland;Delaware---Sussex;Delaware---New Castle;Delaware---Kent');
      
      
        // Create Test Attribute Configuration - Practice Area
        Attribute_Configuration__c objAC1 = DataFactory.createAtrConfiguration('Practice Area', 1, 'Text');
        ProductAttribute__c objPA1 = DataFactory.createProductAttribute(objAC1, lstProd[0], 'String');
        
        
        // Create Test Attribute Configuration - Service State
        Attribute_Configuration__c objAC = DataFactory.createAtrConfiguration('Service State', 4, 'Picklist');
        ProductAttribute__c objPA = DataFactory.createProductAttribute(objAC, lstProd[0], 'Multi-Picklist');
        
        
        // Create Test Attribute Configuration - Service County
        Attribute_Configuration__c objAC2 = DataFactory.createAtrConfiguration('Service County', 6, 'Text');
        ProductAttribute__c objPA2 = DataFactory.createProductAttribute(objAC2, lstProd[0], 'Multi-Picklist');
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry(lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        
        // Create Test Quote Line
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
       
        
        lstQuote[0].SBQQ__Ordered__c = TRUE;
        update lstQuote;
        

        
        
    }
    
     /**@@
    #DESCRIPTION     : This is a test method used to cover add attribute functionality.
    #Paramaters      : None
    @@**/
    public static testMethod void testUnitMethod1(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorOItem());
        Order objOrder = [SELECT Id, Enddate FROM Order LIMIT 1];
        
        objOrder.Status = 'Activated';
        update objOrder;
        
        objOrder.SBQQ__Contracted__c = TRUE;
        update objOrder;
        
        Account objAcc = [SELECT Id FROM Account LIMIT 1];
        
        Opportunity objOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Contract objContract = DataFactory.createContract(objAcc, objOpp);
        
        Product2 objProd = [SELECT Id FROM Product2 LIMIT 1];
        
        SBQQ__QuoteLine__c objQLI = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        
        SBQQ__Subscription__c objSub = DataFactory.createSubscription(objAcc, objContract, objProd, objQLI);
        
        OrderItem objOI = [SELECT Id, OrderItemNumber, SIN__c, ServiceDate, EndDate FROM OrderItem LIMIT 1];
        
        SBQQ__OrderItemConsumptionSchedule__c objOICS = new SBQQ__OrderItemConsumptionSchedule__c();
        objOICS.SBQQ__BillingTermUnit__c = 'Month';
        objOICS.SBQQ__BillingTerm__c = 1;
        objOICS.SBQQ__Category__c = 'Rates';
        objOICS.SBQQ__RatingMethod__c = 'Tier';
        objOICS.SBQQ__Type__c = 'Range';
        objOICS.SBQQ__OrderItem__c = objOI.Id;
        insert objOICS;
        
        objOICS = [SELECT Id FROM SBQQ__OrderItemConsumptionSchedule__c LIMIT 1];
        
        
        blng__UsageSummary__c objUSummary = DataFactory.createUsageSummary(objAcc, objOrder, objOI);
        objUSummary.blng__OrderItemConsumptionSchedule__c = objOICS.Id;
        update objUSummary;
        
        objUSummary = [SELECT Id, blng__MatchingId__c, blng__UnitOfMeasure__c , blng__MatchingAttribute__c FROM blng__UsageSummary__c LIMIT 1];

        string strTodaydt = string.valueOf(system.now()).replace(' ', 'T');
        string strEnddt = string.valueOf(system.now().adddays(1)).replace(' ', 'T');
        
        blng__Usage__c objUsage = new blng__Usage__c();
        objUsage.blng__Account__c = objAcc.Id;
        objUsage.blng__Order__c = objOrder.Id;
        objUsage.blng__OrderProduct__c = objOI.Id;
        objUsage.blng__UsageSummary__c = objUSummary.Id;
        objUsage.blng__MatchingId__c = objUSummary.blng__MatchingId__c;
        objUsage.blng__MatchingAttribute__c = 'Quarterly';
        objUsage.blng__UnitOfMeasure__c = 'Hours';
        objUsage.Lead_Id__c = '1234';
        objUsage.blng__Quantity__c = 1;
        objUsage.blng__Subtotal__c = 0;
        objUsage.blng__UnitPrice__c = 0;
        objUsage.First_name__c = 'Test Fname';
        objUsage.Last_name__c = 'Test Lname';
        objUsage.Email__c = 'test@test.com';
        objUsage.blng__StartDateTime__c = system.now();
        objUsage.blng__EndDateTime__c = system.now();
        objUsage.blng__Status__c = 'New';
        objUsage.blng__PreratedQuantity__c = 0;
        objUsage.blng__PreratedAmount__c = 0;
        objUsage.blng__ProcessingDate__c = system.today();
        insert objUsage;

    }
}
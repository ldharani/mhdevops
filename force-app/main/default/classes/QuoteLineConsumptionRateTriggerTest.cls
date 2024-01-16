/**@@
#APEX CLASS NAME       :   QuoteLineConsumptionRateTriggerTest
#CREATED BY            :   Serge Kandukuri
#DESCRIPTION           :   This is test class for QuoteLineConsumptionRateTrigger (Apex Trigger) and Trigger_QuoteLineConsumptionRate_Handler and Trigger_QuoteLineConsumptionRate_Helper (Apex Class).
@@**/
@IsTest
public class QuoteLineConsumptionRateTriggerTest{
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
         
    }
    
    /**@@
    #DESCRIPTION     : This is a test method used to cover add attribute functionality.
    #Paramaters      : None
    @@**/
    public static testMethod void testUnitMethod1(){
        
        Test.startTest();
        
        List<SBQQ__Quote__c> lstQuote = [SELECT Id FROM SBQQ__Quote__c];
        List<Product2> lstProd = [SELECT Id FROM Product2];
        PricebookEntry objPBEntry = [SELECT Id FROM PricebookEntry];
        
        ConsumptionSchedule objCS = [SELECT Id FROM ConsumptionSchedule LIMIT 1];
        
        // Create Test Quote Line
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        
        SBQQ.TriggerControl.disable();
        
        SBQQ__QuoteLineConsumptionSchedule__c objQLICS = DataFactory.createQLIConsumptionSchedule(objCS, objQLI);

        
        test.stopTest();
        objQLICS = [SELECT Id FROM SBQQ__QuoteLineConsumptionSchedule__c];
        
        SBQQ__QuoteLineConsumptionRate__c objQLICRate = new SBQQ__QuoteLineConsumptionRate__c();
        objQLICRate.SBQQ__QuoteLineConsumptionSchedule__c = objQLICS.Id;
        objQLICRate.SBQQ__LowerBound__c = 0;
        objQLICRate.SBQQ__Price__c = 0;
        objQLICRate.SBQQ__PricingMethod__c = 'PerUnit';
        objQLICRate.SBQQ__ProcessingOrder__c = 1;
        insert objQLICRate;
        SBQQ.TriggerControl.enable();
       
    }
    

}
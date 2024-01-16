@isTest
public class BatchUpdateAttributeValues_Test {
    static testMethod void testCaseA(){
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
        
        // Create Test Product
        List<Product2> lstProd = DataFactory.createProduct('Test Product', objBR, objRR, objTR, 1);
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        
        // Create Attribute_Lines__c - Practice Area        
        Attribute_Lines__c objAL = new Attribute_Lines__c();
        objAL.Attribute_Junction__c = objAR.Id;
        objAL.Attribute_Name__c = 'State';
        objAL.Attribute_Type__c = 'strDataType';
        objAL.String_Value__c = 'SSDI';
        objAL.Multi_Select_Value__c = 'strMSValue';
        objAL.Picklist_Value__c = 'State';
        insert objAL;
        
        Attribute_Lines__c objALA = new Attribute_Lines__c();
        objALA.Attribute_Junction__c = objAR.Id;
        objALA.Attribute_Name__c = 'City';
        objALA.Attribute_Type__c = 'strDataType';
        objALA.String_Value__c = 'SSDI';
        objALA.Multi_Select_Value__c = 'strMSValue';
        objALA.Picklist_Value__c = 'State';
        insert objALA;
        
        Attribute_Lines__c objALAA = new Attribute_Lines__c();
        objALAA.Attribute_Junction__c = objAR.Id;
        objALAA.Attribute_Name__c = 'Country';
        objALAA.Attribute_Type__c = 'strDataType';
        objALAA.String_Value__c = 'SSDI';
        objALAA.Multi_Select_Value__c = 'strMSValue';
        objALAA.Picklist_Value__c = 'State';
        insert objALAA;
        
        Attribute_Lines__c objALB = new Attribute_Lines__c();
        objALB.Attribute_Junction__c = objAR.Id;
        objALB.Attribute_Name__c = 'County';
        objALB.Attribute_Type__c = 'strDataType';
        objALB.String_Value__c = 'SSDI';
        objALB.Multi_Select_Value__c = 'strMSValue';
        objALB.Picklist_Value__c = 'State';
        insert objALB;
        
        Test.startTest();
        BatchUpdateAttributeValues attBatch = new BatchUpdateAttributeValues();
        Database.executeBatch(attBatch);
        Test.stopTest();
    }
}
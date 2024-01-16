@isTest
public class Test_CPQ_CreateQuotePDF {
    @testSetup static void setup() { 
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
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
        
        Test.startTest();  
        
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
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        // Create Test Quote Line 
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        
        // Create Test Opportunity Line Item
        DataFactory.createOpportunityLineItem(lstOpp[0], lstProd[0], objPBEntry, objQLI);
        CPQ_CreateQuotePDF.attributewrapper at1 = new CPQ_CreateQuotePDF.attributewrapper(objAL,objQLI );
        at1.attrPrice = 0;
        at1.attrStateCountyValue = 'test';
        at1.attrPricewithCurrency = 'test';
        Test.stopTest();
    }
    
    public static testMethod void testCaseA(){
        SBQQ__Quote__c objQuote = [SELECT Id,Locations__c,SBQQ__Status__c FROM SBQQ__Quote__c LIMIT 1];
        ApexPages.currentPage().getParameters().put('id',objQuote.id);
        CPQ_CreateQuotePDF classCQP = new CPQ_CreateQuotePDF();
        classCQP.FkMethod();
        classCQP.testCoverMethod();
        
    }
    /*
    public static testMethod void testCaseB(){
        Account acc = [SELECT Id FROM Account LIMIT 1];   
        Contact objCon = [SELECT Id FROM Contact LIMIT 1];
        SBQQ__Quote__c objQuote = [SELECT Id,Locations__c,SBQQ__Status__c FROM SBQQ__Quote__c LIMIT 1];
        objQuote.SBQQ__PrimaryContact__c = objCon.Id;
        objQuote.Billing_Contact__c = objCon.Id;
        objQuote.Marketing_Contact__c = objCon.Id;
        objQuote.SBQQ__Account__c = acc.Id;
        objQuote.Locations__c = 'ATest';
        Update objQuote;
        List<blng__PaymentMethod__c> payNewMap = new List<blng__PaymentMethod__c>();
        blng__PaymentMethod__c pmRecA = new blng__PaymentMethod__c();
        pmRecA.blng__Account__c = acc.Id;
        pmRecA.blng__PaymentType__c = 'Credit Card';
        pmRecA.blng__Active__c = True;
        pmRecA.blng__AutoPay__c = True;
        pmRecA.Card_Number__c = '4111111111111111';
        pmRecA.blng__Nameoncard__c = 'Jm';
        pmRecA.blng__CVV__c = '22222';
        pmRecA.blng__CardExpirationYear__c = '2030';
        pmRecA.blng__CardExpirationMonth__c = '10'; 
        pmRecA.blng__CardType__c = 'Visa';
        insert pmRecA;
        
        ApexPages.currentPage().getParameters().put('id',objQuote.id);
        CPQ_CreateQuotePDF classCQP = new CPQ_CreateQuotePDF();
        classCQP.FkMethod();
        
    }
        public static testMethod void testCaseC(){
        Account acc = [SELECT Id FROM Account LIMIT 1];   
        Contact objCon = [SELECT Id FROM Contact LIMIT 1];
        SBQQ__Quote__c objQuote = [SELECT Id,Locations__c,SBQQ__Status__c FROM SBQQ__Quote__c LIMIT 1];
        objQuote.SBQQ__PrimaryContact__c = objCon.Id;
        objQuote.Billing_Contact__c = objCon.Id;
        objQuote.Marketing_Contact__c = objCon.Id;
        objQuote.SBQQ__Account__c = acc.Id;
        objQuote.Locations__c = 'BTest';
        Update objQuote;
        List<blng__PaymentMethod__c> payNewMap = new List<blng__PaymentMethod__c>();
        blng__PaymentMethod__c pmRecA = new blng__PaymentMethod__c();
        pmRecA.blng__Account__c = acc.Id;
        pmRecA.blng__PaymentType__c = 'Credit Card';
        pmRecA.blng__Active__c = True;
        pmRecA.blng__AutoPay__c = True;
        pmRecA.Card_Number__c = '4111111111111111';
        pmRecA.blng__Nameoncard__c = 'JmAA';
        pmRecA.blng__CVV__c = '22222';
        pmRecA.blng__CardExpirationYear__c = '2030';
        pmRecA.blng__CardExpirationMonth__c = '10'; 
        pmRecA.blng__CardType__c = 'Visa';
        insert pmRecA;
        
        ApexPages.currentPage().getParameters().put('id',objQuote.id);
        CPQ_CreateQuotePDF classCQP = new CPQ_CreateQuotePDF();
        classCQP.FkMethod();
        
    }
            public static testMethod void testCaseD(){
        Account acc = [SELECT Id FROM Account LIMIT 1];   
        Contact objCon = [SELECT Id FROM Contact LIMIT 1];
        SBQQ__Quote__c objQuote = [SELECT Id,Locations__c,SBQQ__Status__c FROM SBQQ__Quote__c LIMIT 1];
        objQuote.SBQQ__PrimaryContact__c = objCon.Id;
        objQuote.Billing_Contact__c = objCon.Id;
        objQuote.Marketing_Contact__c = objCon.Id;
        objQuote.SBQQ__Account__c = acc.Id;
        objQuote.Locations__c = 'CTest';
        Update objQuote;
        List<blng__PaymentMethod__c> payNewMap = new List<blng__PaymentMethod__c>();
        blng__PaymentMethod__c pmRecA = new blng__PaymentMethod__c();
        pmRecA.blng__Account__c = acc.Id;
        pmRecA.blng__PaymentType__c = 'Credit Card';
        pmRecA.blng__Active__c = True;
        pmRecA.blng__AutoPay__c = True;
        pmRecA.Card_Number__c = '4111111111111111';
        pmRecA.blng__Nameoncard__c = 'Jmssss';
        pmRecA.blng__CVV__c = '22222';
        pmRecA.blng__CardExpirationYear__c = '2030';
        pmRecA.blng__CardExpirationMonth__c = '10'; 
        pmRecA.blng__CardType__c = 'Visa';
        insert pmRecA;
        
        ApexPages.currentPage().getParameters().put('id',objQuote.id);
        CPQ_CreateQuotePDF classCQP = new CPQ_CreateQuotePDF();
        classCQP.FkMethod();
        
    }*/
}
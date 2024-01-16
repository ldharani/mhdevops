@isTest
public class CPQ_MilestoneHandler_Assets_Test {
    
    Public static testmethod void CPQ_createProjects(){
        // Load Custom settings
        DataFactory.loadCustomSettings();
        Product_code_to_Project_Mapping__c aaaa = new Product_code_to_Project_Mapping__c();
        aaaa.Name = '01502';
        aaaa.Project_Record_ID__c = 'm010G000000blSb';
        aaaa.Project_Name__c = 'Website_Redesign';
        insert aaaa;
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
        // Create Test Opportunity
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-H Opportunity').getRecordTypeId();
        List<Opportunity> lstOpp = DataFactory.createOpportunity('Test Opp', lstAcc[0], oppRecordTypeId, 1);
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // Create Billing Rule
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
        
        // Create Test Product
        List<Product2> lstProd = new List<Product2>();
        Product2 objProd = new Product2();
        objProd.Name = 'Web Series Redesign';
        objProd.Productcode = '01502';
        objProd.IsActive = true;
        //objProd.SBQQ__SubscriptionPricing__c = 'One-time';
        //objProd.SBQQ__SubscriptionTerm__c = 12;
        // objProd.SBQQ__SubscriptionType__c = 'Evergreen';
        objProd.SBQQ__SubscriptionType__c = 'One-time';
        objProd.SBQQ__ChargeType__c = 'One-time';
        //objProd.SBQQ__BillingFrequency__c = 'Monthly';
        //objProd.SBQQ__BillingType__c = 'Arrears';
        objProd.SBQQ__PricingMethod__c = 'List';
        objProd.blng__BillingRule__c = objBR.Id;
        objProd.blng__RevenueRecognitionRule__c = objRR.Id;
        objProd.blng__TaxRule__c = objTR.Id; 
        lstProd.add(objProd);
        insert lstProd;
        
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
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
        //SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        
        //inserting quoteline
        SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Quote__c = lstQuote[0].id;
        objQLI.SBQQ__Product__c = lstProd[0].Id;
        objQLI.SBQQ__PricebookEntryId__c = objPBEntry.Id;
        //objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__ProductSubscriptionType__c = 'One-time';
        objQLI.SBQQ__SubscriptionType__c = 'One-time';
        objQLI.SBQQ__ChargeType__c = 'One-time';
        objQLI.RecordTypeId = quoteLineRecordTypeId;
        objQLI.Usage_List_Price__c = 100;
        insert objQLI;
        
        Contract objContract = DataFactory.createContract(lstAcc[0], lstOpp[0]);
        Set<Id> subId = new Set<Id>();
        //SBQQ__Subscription__c objSub = DataFactory.createSubscription(lstAcc[0], objContract, lstProd[0], objQLI);  
        //objSub.SBQQ__Product__c = lstProd[0].Id;
        //Update objSub;
        //subId.add(objSub.Id);
        
        Asset objAsset = new Asset();
        objAsset.Name = 'Web Series Redesign';
        objAsset.Product2Id = lstProd[0].Id;
        objAsset.AccountId = lstAcc[0].Id;
        insert objAsset;
        subId.add(objAsset.Id);
        
        
        Milestone1_Project__c project = new Milestone1_Project__c (name ='Content (General)');
        insert project;    
        //ApexPages.StandardController sc = new ApexPages.StandardController(project);
        //CPQ_MilestoneHandler_Assets handle = new CPQ_MilestoneHandler_Assets(sc);
        test.startTest();
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('proj');
        proj.Asset__c = objAsset.Id;
        insert proj; 
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(proj.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;
        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Started_date__c = system.now();
        testTask.Dued_date__c = system.now();
       // insert testTask;
        CPQ_MilestoneHandler.CPQ_createProjects(subId);
        test.stopTest();
    }
}
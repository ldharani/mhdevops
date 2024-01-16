/****************************************************************
 * Author      : sai
 * Description : Test Class for ProjectTriggerHandler
 * **************************************************************/


@isTest(seeAllData = true)
public class ProjectTriggerHandlerTest {
    
    static testmethod void run2condition(){
        /*
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        User u = testData.getUser_admin();
        
        Account a = new Account(Name='Test Account 1');
        insert a;
        
        Contact c = testData.getContact(a.Id);  
        
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        invoiceit_s__Product__c product = testData.getProductWithProvisioning('false', 'Manual Fulfillment');
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);
        
        invoiceit_s__Job__c temp_order = testData.getOrder(a.Id, CurrencyObj.Id);
        invoiceit_s__Job_Product__c temp_orderProduct = testdata.getOrderProduct(temp_order.Id, product.Id);
        invoiceit_s__Job_Rate_Plan__c temp_orderRatePlan = testdata.getOrderRatePlan(temp_orderProduct.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c temp_orderRatePlanCharge = testdata.getOrderRatePlanChargeWithoutInsert(temp_orderRatePlan.Id, ProductRatePlanCharge.Id);
        insert temp_orderRatePlanCharge; 
        */
        
        // Load Custom settings
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        User u = testData.getUser_admin();
        
        //DataFactory.loadCustomSettings();
        
        //List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
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
        List<Product2> lstProd = DataFactory.createProduct('Test Product', objBR, objRR, objTR, 1);
        
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
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        Contract objContract = DataFactory.createContract(lstAcc[0], lstOpp[0]);
        Set<Id> subId = new Set<Id>();
        SBQQ__Subscription__c objSub = DataFactory.createSubscription(lstAcc[0], objContract, lstProd[0], objQLI);  
        subId.add(objSub.Id);
        
        Test.startTest();
        Milestone1_Project__c p = Milestone1_Test_Utility.sampleProjectActive('TaskCompProject');
        p.Account__c = lstAcc[0].Id;
        //p.Order__c = temp_order.Id;
        p.Subscription__c = objSub.Id;
        insert p;        
        Milestone1_Milestone__c m = Milestone1_Test_Utility.sampleMilestone(p);
        m.Deadline__c = Date.today()-1;
        insert m;        
        List<Milestone1_Task__c> testTasks = new List<Milestone1_Task__c>();
        
        // Incomplete task, not blocked, not late
        Milestone1_Task__c t0 = Milestone1_Test_Utility.sampleTask(
            m.Id, system.now(), system.now()+1, false, false);
        testTasks.add(t0);
        
        // Incomplete task, late, not blocked
        Milestone1_Task__c t1 = Milestone1_Test_Utility.sampleTask(
            m.Id, system.now()-2, system.now()-1, false, false);
        t1.assign_To_Type__c = 'Queue';
        testTasks.add(t1);
        
        // Incomplete task, not late, blocked
        Milestone1_Task__c t2 = Milestone1_Test_Utility.sampleTask(
            m.Id, system.now()-2, system.now()+1, false, true);
        t2.assign_To_Type__c = 'User'; 
        testTasks.add(t2);
       insert testTasks;
        
        system.runAs(u){
            Group Managerqueue = [select Id, Name from Group where Type = 'Queue'
                                                       AND DeveloperName = 'MS_Project_Manager' LIMIT 1];
          GroupMember gm    = new GroupMember(GroupId =Managerqueue.id, UserOrGroupId=u.id );
          insert gm;
        }
        
        
        
        //Test.startTest();
            ProjectTriggerHandler.projectAfterUpdateRecurstion = True;
          p.OwnerId  = u.id;
            p.Status__c = 'In Progress' ;
            update p;
        Test.stopTest();
    }
    static testmethod void run3condition(){
        /*
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        User u = testData.getUser_admin();
        
        Account a = new Account(Name='Test Account 3');
        insert a;
        
        Contact c = testData.getContact(a.Id);  
        
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        invoiceit_s__Product__c product = testData.getProductWithProvisioning('false', 'Manual Fulfillment');
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);
        
        invoiceit_s__Job__c temp_order = testData.getOrder(a.Id, CurrencyObj.Id);
        invoiceit_s__Job_Product__c temp_orderProduct = testdata.getOrderProduct(temp_order.Id, product.Id);
        invoiceit_s__Job_Rate_Plan__c temp_orderRatePlan = testdata.getOrderRatePlan(temp_orderProduct.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c temp_orderRatePlanCharge = testdata.getOrderRatePlanChargeWithoutInsert(temp_orderRatePlan.Id, ProductRatePlanCharge.Id);
        insert temp_orderRatePlanCharge; 
        */
        
        // Load Custom settings
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        User u = testData.getUser_admin();
        
        //DataFactory.loadCustomSettings();
        
        //List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
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
        List<Product2> lstProd = DataFactory.createProduct('Test Product', objBR, objRR, objTR, 1);
        
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
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        Contract objContract = DataFactory.createContract(lstAcc[0], lstOpp[0]);
        Set<Id> subId = new Set<Id>();
        SBQQ__Subscription__c objSub = DataFactory.createSubscription(lstAcc[0], objContract, lstProd[0], objQLI);  
        subId.add(objSub.Id);
        
        Test.startTest();
        Milestone1_Project__c p = Milestone1_Test_Utility.sampleProjectActive('ProjectToBeCancelled');
        p.Status__c = 'New';
        //p.Order__c = temp_order.Id;
        p.Subscription__c = objSub.Id;
        insert p;        
        Milestone1_Milestone__c m = Milestone1_Test_Utility.sampleMilestone(p);
        m.Status__c = 'New';
        m.Deadline__c = Date.today()-1;
        insert m;        
        List<Milestone1_Task__c> testTasks = new List<Milestone1_Task__c>();
        
        // Incomplete task, not blocked, not late
        Milestone1_Task__c t0 = Milestone1_Test_Utility.sampleTask(
            m.Id, system.now(), system.now()+1, false, false);
        insert t0;
        
        //Test.startTest();
            ProjectTriggerHandler.projectAfterUpdateRecurstion = True;
            p.OwnerId  = u.id;
            p.Status__c = 'Cancelled' ;
            update p;
            
            m.Status__c = 'Cancelled';
            update m;
            
            t0.Task_Stage__c = 'Cancelled';
            update t0;
        Test.stopTest();
        
        
    }
    static testmethod void run4condition(){
        /*
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        User u = testData.getUser_admin();
        Account a = new Account(Name='Test Account 2');
        insert a;
        Contact c = testData.getContact(a.Id);  
        
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        invoiceit_s__Product__c product = testData.getProductWithProvisioning('false', 'Manual Fulfillment');
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);
        
        invoiceit_s__Job__c temp_order = testData.getOrder(a.Id, CurrencyObj.Id);
        invoiceit_s__Job_Product__c temp_orderProduct = testdata.getOrderProduct(temp_order.Id, product.Id);
        invoiceit_s__Job_Rate_Plan__c temp_orderRatePlan = testdata.getOrderRatePlan(temp_orderProduct.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c temp_orderRatePlanCharge = testdata.getOrderRatePlanChargeWithoutInsert(temp_orderRatePlan.Id, ProductRatePlanCharge.Id);
        insert temp_orderRatePlanCharge; 
        */
        // Load Custom settings
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        User u = testData.getUser_admin();
        
        //DataFactory.loadCustomSettings();
        
        //List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
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
        List<Product2> lstProd = DataFactory.createProduct('Test Product', objBR, objRR, objTR, 1);
        
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
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        Contract objContract = DataFactory.createContract(lstAcc[0], lstOpp[0]);
        Set<Id> subId = new Set<Id>();
        SBQQ__Subscription__c objSub = DataFactory.createSubscription(lstAcc[0], objContract, lstProd[0], objQLI);  
        subId.add(objSub.Id);
        
        Test.startTest();
        Milestone1_Project__c p = new Milestone1_Project__c();
        
        p.Name = 'SEO_Gold';
        p.Account__c = lstAcc[0].Id;
        p.Status__c = 'New';
        //p.Order__c = temp_order.Id;
        p.Subscription__c = objSub.Id;
        insert p;        
        Milestone1_Milestone__c m = Milestone1_Test_Utility.sampleMilestone(p);
        m.Status__c = 'New';
        m.Deadline__c = Date.today()-1;
        insert m;        
        List<Milestone1_Task__c> testTasks = new List<Milestone1_Task__c>();
        
        // Incomplete task, not blocked, not late
        Milestone1_Task__c t0 = Milestone1_Test_Utility.sampleTask(
            m.Id, system.now(), system.now()+1, false, false);
        insert t0;
        
        Milestone1_Project__c p2 = new Milestone1_Project__c();
        p2.Name = 'Reputation_Boost_Middle';
        p2.Account__c = lstAcc[0].Id;
        p2.Status__c = 'In Progress';
        p2.Order__c = NULL;
        insert p2; 
        
        //Test.startTest();
            ProjectTriggerHandler.projectAfterUpdateRecurstion = True;
            p.OwnerId  = u.id;
            p.Status__c = 'In Progress' ;
            update p;
            
            m.Status__c = 'Cancelled';
            update m;
            
            t0.Task_Stage__c = 'Cancelled';
            update t0;
        Test.stopTest();
    }
    
    static testmethod void run5condition(){
        // Load Custom settings
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        User u = testData.getUser_admin();
        
        //DataFactory.loadCustomSettings();
        
        //List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
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
        List<Product2> lstProd = DataFactory.createProduct('Test Product', objBR, objRR, objTR, 1);
        
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
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        Contract objContract = DataFactory.createContract(lstAcc[0], lstOpp[0]);
        Set<Id> subId = new Set<Id>();
        SBQQ__Subscription__c objSub = DataFactory.createSubscription(lstAcc[0], objContract, lstProd[0], objQLI);  
        subId.add(objSub.Id);
        
        Test.startTest();
        Milestone1_Project__c p = new Milestone1_Project__c();
        
        p.Name = 'SEO_Gold';
        p.Account__c = lstAcc[0].Id;
        p.Status__c = 'New';
        //p.Order__c = temp_order.Id;
        p.Subscription__c = objSub.Id;
        insert p;
        List< Milestone1_Project__c >  projLst = new List<Milestone1_Project__c>();   
        projLst.add(p);
        ProjectTriggerHandler.checkExistingSEOonAccount(projLst);
        Test.stopTest();
    }
    
}
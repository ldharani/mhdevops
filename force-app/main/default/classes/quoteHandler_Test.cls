@istest
public class quoteHandler_Test {
    @testSetup static void setup() { 
        User u1 = [SELECT ID,Name,Username FROM User WHERE Name = 'System Administrator' LIMIT 1];
        System.runas(u1) {
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
            List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
       //List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
            SBQQ__Quote__c objQuote = new SBQQ__Quote__c();
            objQuote.SBQQ__Account__c = lstAcc[0].Id;
            objQuote.SBQQ__PricebookId__c = Test.getStandardPricebookId();
            objQuote.RecordtypeId = quoteRecordTypeId; 
            objQuote.SBQQ__Opportunity2__c = lstOpp[0].Id;
            objQuote.SBQQ__StartDate__c = system.today();
            objQuote.SBQQ__EndDate__c = system.today().adddays(30);
            objQuote.SBQQ__SubscriptionTerm__c = 12;
            objQuote.SBQQ__Primary__c = True;
            //objQuote.SBQQ__Status__c = 'Approved';
            objQuote.SBQQ__ExpirationDate__c = system.today().adddays(30);
            objQuote.SBQQ__BillingFrequency__c = 'Monthly';  
            lstQuote.add(objQuote);
            insert lstQuote;
        
        // Create Test Quote Line 
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        
        // Create Test Opportunity Line Item
        DataFactory.createOpportunityLineItem(lstOpp[0], lstProd[0], objPBEntry, objQLI);
        
        Test.stopTest();
        }
    }
    
    static testMethod void testMethodBs1(){
        SBQQ__Quote__c objQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        List<Id> newList = new List<Id>();
        newList.add(objQuote.Id);
        quoteHandler.reCalculateQuoteLine(newList);
    }
    
    static testMethod void testMethodA() {
        SBQQ__Quote__c quo = new SBQQ__Quote__c();
        quo.SBQQ__SubscriptionTerm__c = 12;
        insert quo;
        
        Account acc = [SELECT Id FROM Account LIMIT 1];   
        acc.Credit_Status__c = 'Good Standing';
        update acc;
        
        SBQQ__Quote__c objQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        objQuote.SBQQ__Account__c = acc.Id;
        objQuote.SBQQ__PrimaryContact__c=con.ID;
        objQuote.Billing_Contact__c=con.ID;
        objQuote.Marketing_Contact__c=con.ID;
        objQuote.SBQQ__PricebookId__c = Test.getStandardPricebookId();
        update objQuote;
        objQuote.SBQQ__Status__c='Closed Won';
        update objQuote;
    }
    static testMethod void testMethodB() {
        List<SBQQ__Quote__c> quoList = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quo = new SBQQ__Quote__c();
        quo.SBQQ__SubscriptionTerm__c = 12;
        quo.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Cancel Quote').getRecordTypeId();
        insert quo;
        quoList.add(quo);
        quoteHandler quoClass = new quoteHandler();
        quoClass.sendQuoteToActivateCancelOrder(quoList);
    }
    static testMethod void testMethodC() {
        test.startTest();
        Set<Id> Quoteids = new Set<Id>();
        Account acc = [SELECT Id FROM Account LIMIT 1];   
        acc.Credit_Status__c = 'Good Standing';
        update acc;
        
        SBQQ__Quote__c objQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        objQuote.SBQQ__Account__c = acc.Id;
        objQuote.CardNumber__c = string.valueOf(1234567890);
        objQuote.NameonCard__c = 'John';
        objQuote.CardType__c ='Visa';
        objQuote.CardExpirationMonth__c ='12';
        objQuote.CardExpirationYear__c = '2050';                   
        objQuote.CVV__c =string.valueOf(1234);
        objQuote.RecordtypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        update objQuote;
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = acc.id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.SBQQ__Quote__c = objQuote.Id;
        insert objOrder;
        
        Quoteids.add(objQuote.Id);
        quoteHandler.activateOrderfromQuote(Quoteids);
        test.stopTest();
    }
    static testMethod void testMethodD() {
        test.startTest();
        Set<Id> Quoteids = new Set<Id>();
        Account acc = [SELECT Id FROM Account LIMIT 1];   
        acc.Credit_Status__c = 'Good Standing';
        update acc;
        
        SBQQ__Quote__c objQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        objQuote.SBQQ__Account__c = acc.Id;
        objQuote.CardNumber__c = string.valueOf(1234567890);
        objQuote.NameonCard__c = 'John';
        objQuote.CardType__c ='Visa';
        objQuote.CardExpirationMonth__c ='12';
        objQuote.CardExpirationYear__c = '2050';                   
        objQuote.CVV__c =string.valueOf(1234);
        objQuote.RecordtypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        objQuote.IsDataLoaded__c ='Y';
        update objQuote;
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = acc.id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.SBQQ__Quote__c = objQuote.Id;
        insert objOrder;
        objOrder.Type = 'Renewal';
        Update objOrder;
        
        Quoteids.add(objQuote.Id);
        
        quoteHandler.activateOrderfromQuote(Quoteids);
        test.stopTest();
        
        
    }
    static testMethod void testMethodE() {
        test.startTest();        
        Set<Id> Quoteids = new Set<Id>();
        List<Id> Orderids = new List<Id>();
        List<SBQQ__Quote__c> qList = new List<SBQQ__Quote__c>();
        Map<Id,SBQQ__Quote__c> oldMap = new Map<Id,SBQQ__Quote__c>();
        Map<Id,SBQQ__Quote__c> newMap = new Map<Id,SBQQ__Quote__c>();
        Account acc = [SELECT Id FROM Account LIMIT 1];   
        Contact objCon = [SELECT Id FROM Contact LIMIT 1];
        Opportunity objOpp = [SELECT Id FROM Opportunity LIMIT 1];
        acc.Credit_Status__c = 'Good Standing';
        update acc;
        
        SBQQ__Quote__c objQuote = [SELECT Id, Ngage_Source__c,SBQQ__Status__c, SBQQ__Opportunity2__c FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteLine__c objQLI = [SELECT Id FROM SBQQ__QuoteLine__c];
        objQuote.SBQQ__Account__c = acc.Id;
        objQuote.CardNumber__c = string.valueOf(1234567890);
        objQuote.NameonCard__c = 'John';
        objQuote.CardType__c ='Visa';
        objQuote.CardExpirationMonth__c ='12';
        objQuote.CardExpirationYear__c = '2050';                   
        objQuote.CVV__c =string.valueOf(1234);
        objQuote.SBQQ__Opportunity2__c = objOpp.id;
        objQuote.RecordtypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        update objQuote;
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = acc.id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.SBQQ__Quote__c = objQuote.Id;
        insert objOrder;

        objOrder.Type = 'Renewal';
        objQuote.SBQQ__PrimaryContact__c = objCon.Id;
        objQuote.Billing_Contact__c = objCon.Id;
        objQuote.Marketing_Contact__c = objCon.Id;
        Update objOrder;
        
        Case c = new Case();
        c.AccountId = acc.Id;
        c.Subject = 'SEO Account potentially at Risk';
        c.Description = 'Account is due for renewal within 120 days';
        c.Priority = 'Medium';
        c.Status = 'New';
        c.Area__c  = 'Create Milestone';
        c.Sub_Area__c  = 'SEO_Audit/Account Review At Risk';
        c.Parent_Opportunity__c = objOpp.Id;
        insert c;
        
        Quoteids.add(objQuote.Id);
        Orderids.add(objOrder.Id);
        qList.add(objQuote);
        newMap.put(objQuote.Id,objQuote);  
        oldMap.put(objQuote.Id,objQuote);  
        quoteHandler.activateOrderfromQuote(Quoteids);
        quoteHandler.activateOrderContract(Orderids);
        quoteHandler.checkforInventoryIds(qList,newMap,oldMap);
        quoteHandler.voidingenvelopefrombatch(Quoteids);
        quoteHelper.updatePrimaryContactOnAccount(qList,oldMap);
        quoteHelper.UpdateNgageSource(qList,newMap,oldMap);
        quoteHelper.updateCaseOwnersinOppty(qList,oldMap,newMap);
        quoteHelper  quoteClass = new quoteHelper();
        quoteClass.FkMethod();
        quoteHandler  quoteClass2 = new quoteHandler();
        quoteClass2.FkMethod();
        test.stopTest();
    }
    
    
    /*static testMethod void testMethodSV() {
        test.startTest();        
        Set<Id> Quoteids = new Set<Id>();
        List<Id> Orderids = new List<Id>();
        List<SBQQ__Quote__c> qList = new List<SBQQ__Quote__c>();
        Map<Id,SBQQ__Quote__c> oldMap = new Map<Id,SBQQ__Quote__c>();
        Map<Id,SBQQ__Quote__c> newMap = new Map<Id,SBQQ__Quote__c>();
        Account acc = [SELECT Id FROM Account LIMIT 1];   
        Contact objCon = [SELECT Id FROM Contact LIMIT 1];
        Opportunity objOpp = [SELECT Id FROM Opportunity LIMIT 1];
        acc.Credit_Status__c = 'Good Standing';
        update acc;
        
        SBQQ__Quote__c objQuote = [SELECT Id,SBQQ__Status__c,SBQQ__NetAmount__c FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteLine__c objQLI = [SELECT Id FROM SBQQ__QuoteLine__c];
        objQuote.SBQQ__Account__c = acc.Id;
        objQuote.RecordtypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        update objQuote;
        
        SBQQ__QuoteLineGroup__c qlR = new SBQQ__QuoteLineGroup__c();
        qlR.SBQQ__Quote__c = objQuote.id;
        qlR.SBQQ__Number__c = 2;
        qlR.Name = 'Original Contract Products';
        qlR.SBQQ__ListTotal__c = objQuote.SBQQ__NetAmount__c;
        qlR.SBQQ__CustomerTotal__c = objQuote.SBQQ__NetAmount__c;
        qlR.SBQQ__NetTotal__c = objQuote.SBQQ__NetAmount__c;
       
        insert qlR;
        
        objQLI.SBQQ__Quantity__c=2;
        objQLI.SBQQ__ProductSubscriptionType__c='Renewable/Evergreen';
        objQLI.SBQQ__Group__c = qlR.id;
        
        update objQLI;
        
         qList.add(objQuote);
         oldMap.put(objQuote.Id,objQuote); 
         quoteHandler.subcriptiontypeValidation(qList,oldMap) ;
         
        }
    */
    static testMethod void testMethodBS() {
        SBQQ__Quote__c objQuote = [SELECT Id,SBQQ__Status__c,Marketing_Contact__c,cancelled__c,WaiveECF__c,SBQQ__PrimaryContact__c,SBQQ__Type__c,SBQQ__Opportunity2__c,Recordtype.developerName FROM SBQQ__Quote__c LIMIT 1];
        objQuote.Cancelled__c = true;
        update objQuote;
        List<String> newListString = new List<String>();
        List<SBQQ__Quote__c> newList = new List<SBQQ__Quote__c>();
       	map<id,SBQQ__Quote__c> mapofoldquote = new map<id,SBQQ__Quote__c>();
        newList.add(objQuote);
        mapofoldquote.put(objQuote.id,objQuote);
        String quoteid = String.valueOf(objQuote.id)+',1';
        newListString.add(quoteid);
        Test.startTest();
        quoteHandler.UpdateMarketingContact(newList,mapofoldquote);
        quoteHandler.reCalculateQuoteFuture(newListString);
        quoteHandler.populatePrimaryContractforAmend(newList);
        quoteHandler.afterUpdateCancelHandler(newList,mapofoldquote);
        Test.stopTest();
    }
}
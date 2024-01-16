@isTest
public class Test_quoteHandler{
    
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
        DataFactory.createContract(lstAcc[0],lstOpp[0]);
        
        Test.stopTest();
    }
    
    static testMethod void testMethod2() {
        
        Account objAcc = [SELECT Id FROM Account LIMIT 1];
        objAcc.Credit_Status__c = 'Good Standing';
        update objAcc;
        
        Contact objCon = [SELECT Id FROM Contact LIMIT 1];
        
        
        
        SBQQ__Quote__c objQuote = [SELECT Id,State__c, FirstName__c, LastName__c, ZipPostalCode__c,SBQQ__Opportunity2__c,OwnerId,SBQQ__Account__c,CardType__c,CardExpirationMonth__c,CardExpirationYear__c,NameonCard__c,CardNumber__c,CVV__c,StreetAddress__c,City__c,Country__c FROM SBQQ__Quote__c LIMIT 1];
        List<Product2> lstProd = new List<Product2>();
        Product2 objProd = [SELECT Id FROM Product2 LIMIT 1];
                objProd.ProductCode = '11006';
        update objProd;
        lstProd.add(objProd);
        
        PricebookEntry objPBEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        
        blng__BillingRule__c objBR = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        
        blng__RevenueRecognitionRule__c objRR = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        
        blng__TaxRule__c objTR = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        
        Attribute_Relationship__c objAR = [SELECT Id FROM  Attribute_Relationship__c];
        
        
        Test.startTest();  
        List<SBQQ__Quote__c> qList = new List<SBQQ__Quote__c>{objQuote};
            Set<Id> qIds = new Set<Id>{objQuote.Id};
                Map<Id,SBQQ__Quote__c> oldMap = new Map<Id,SBQQ__Quote__c>{objQuote.Id=>objQuote};
                    Map<Id,SBQQ__Quote__c> newMap = new Map<Id,SBQQ__Quote__c>{objQuote.Id=>objQuote};    
                        
                              
        // Create Test Quote Line
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(qList[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
                        
        objquote.RecordtypeId = Schema.SObjectType.SBQQ__Quote__C.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        objquote.SBQQ__Type__c ='Quote';
        objquote.Billing_Contact__c = objCon.Id;
        objquote.Marketing_Contact__c = objCon.Id;
        objquote.IsDataLoaded__c ='N';
        objquote.SBQQ__Ordered__c = false;        
        objquote.SBQQ__PrimaryContact__c = objCon.Id;       
        objquote.SBQQ__Primary__c = true;        
        update objQuote;
        
        objQuote.NameonCard__c= 'test';    
        objQuote.CardNumber__c = '411111111111112';
        objQuote.CVV__c = '123';
        objQuote.CardExpirationMonth__c = '12';
        objQuote.CardExpirationYear__c = '2025';
        objQuote.CardType__c ='Visa';
        objquote.SBQQ__Status__c ='QA Review';
        objquote.Reason_Won_Lost__c ='New Business';
        objquote.PMCreation__c = FALSE;
        update objquote;
        
        objquote.SBQQ__Status__c = 'Closed Won';
        objquote.Reason_Won_Lost__c ='Administrative';
        update objquote;

        
        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        
       // Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
       // objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = objAcc.id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        insert objOrder;
        List<Id> ordIdList = new List<Id>{objOrder.Id};
            
        OrderItem objOI = new OrderItem();
        objOI.OrderId = objOrder.id;
        objOI.Quantity = 24;
        objOI.UnitPrice = 240;
        objOI.Product2id = objProd.Id;
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
        objOI.blng__LegalEntity__c = legal.Id;
        insert objOI;
        

        //quoteHandler qh = new quoteHandler();
        quoteHandler.activateOrderContract(ordIdList);
        if(!qIds.isEmpty()){
            quoteHandler.voidingenvelope(qIds);
        }
        quoteHandler.voidingenvelopefrombatch(qIds);
        quoteHandler.checkforInventoryIds(qList,newMap,oldMap);
        quoteHandler qh = new quoteHandler();
        qh.createPaymentMethod(qList,newMap,oldMap);
        Test.stopTest();
    }
    
    static testMethod void testMethod1() {
        
        Account objAcc = [SELECT Id FROM Account LIMIT 1];
        objAcc.Credit_Status__c = 'Good Standing';
        update objAcc;
        
        Contact objCon = [SELECT Id FROM Contact LIMIT 1];
        
        SBQQ__Quote__c objQuote = [SELECT Id,State__c, FirstName__c, LastName__c, ZipPostalCode__c,SBQQ__Opportunity2__c,OwnerId,SBQQ__Account__c,CardType__c,CardExpirationMonth__c,CardExpirationYear__c,NameonCard__c,CardNumber__c,CVV__c,StreetAddress__c,City__c,Country__c FROM SBQQ__Quote__c LIMIT 1];
        
        Product2 objProd = [SELECT Id FROM Product2 LIMIT 1];
        objProd.ProductCode = '11006';
        update objProd;
        
        PricebookEntry objPBEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        
        blng__BillingRule__c objBR = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        
        blng__RevenueRecognitionRule__c objRR = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        
        blng__TaxRule__c objTR = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        
        Attribute_Relationship__c objAR = [SELECT Id FROM  Attribute_Relationship__c];
        
        
        Contract contra = [SELECT Id FROM  Contract LIMIT 1];
        contra.IsMidterm__c = true;
        update contra;
        
        
        
        List<SBQQ__Quote__c> qList = new List<SBQQ__Quote__c>{objQuote};
            Set<Id> qIds = new Set<Id>{objQuote.Id};
                Map<Id,SBQQ__Quote__c> oldMap = new Map<Id,SBQQ__Quote__c>{objQuote.Id=>objQuote};
                    Map<Id,SBQQ__Quote__c> newMap = new Map<Id,SBQQ__Quote__c>{objQuote.Id=>objQuote};    
                        
                        
        objquote.RecordtypeId = Schema.SObjectType.SBQQ__Quote__C.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        objquote.SBQQ__Type__c ='Amendment';
        objquote.Billing_Contact__c = objCon.Id;
        objquote.Marketing_Contact__c = objCon.Id;
        update objquote;
        
        Test.startTest();
        objquote.IsDataLoaded__c ='N';
        objquote.SBQQ__Ordered__c = false;        
        objquote.SBQQ__PrimaryContact__c = objCon.Id;       
        objquote.SBQQ__Primary__c = true;
        objQuote.NameonCard__c= 'test';    
        objQuote.CardNumber__c = '411111111111112';
        objQuote.PMCreation__c = FALSE;
        update objQuote;
        
        objquote.CardNumber__c ='411111111111111';
        objquote.SBQQ__Status__c ='QA Review';
        objquote.Reason_Won_Lost__c ='New Business';
        update objquote;
        
        objquote.SBQQ__Status__c = 'Closed Won';
        objquote.Reason_Won_Lost__c ='Administrative';
        update objquote;
        
       // Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
       // objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = objAcc.id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        insert objOrder;
        List<Id> ordIdList = new List<Id>{objOrder.Id};
            
            OrderItem objOI = new OrderItem();
        objOI.OrderId = objOrder.id;
        objOI.Quantity = 24;
        objOI.UnitPrice = 240;
        objOI.Product2id = objProd.Id;
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
        objOI.blng__LegalEntity__c = legal.Id;
        insert objOI;
        
        Case c = new Case();
        c.AccountId = objAcc.Id;
        c.Parent_Opportunity__c = objquote.SBQQ__Opportunity2__c;
        c.Subject = 'SEO Account potentially at Risk';
        c.Description = 'Account is due for renewal within 120 days';
        c.Priority = 'Medium';
        c.Status = 'New';
        c.Area__c  = 'Editorial';
        c.Sub_Area__c  = 'SEO_Audit/Account Review At Risk';
        insert c;
        
        quoteHandler qh = new quoteHandler();
        quoteHandler.activateOrderContract(ordIdList);
        //quoteHandler.updateTermandDate(qList);
        quoteHandler.voidingenvelope(qIds);
        quoteHandler.voidingenvelopefrombatch(qIds);
        quoteHandler.checkforInventoryIds(qList,newMap,oldMap);
        qh.createPaymentMethod(qList,newMap,oldMap);
        Test.stopTest();
    }
    
    static testMethod void myUnitTest() {
        
        Test.starttest();
        
        Account acc = [SELECT Id FROM Account LIMIT 1];   
        acc.Credit_Status__c = 'Good Standing';
        update acc;
        
        Contact objCon = [SELECT Id FROM Contact LIMIT 1];
        
        Opportunity objOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Product2 objProd = [SELECT Id FROM Product2 LIMIT 1];
        
        blng__BillingRule__c objBR = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        
        blng__RevenueRecognitionRule__c objRR = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        
        blng__TaxRule__c objTR = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        
        SBQQ__Quote__c objQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        List<id> quoteidList = new List<id>();
        Set<id> quoteids = new Set<id>();
        
        SBQQ__QuoteLine__c objQLI = [SELECT Id FROM SBQQ__QuoteLine__c];      
        
      
        PricebookEntry objPBEntry = [SELECT Id FROM PricebookEntry];
        
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        
        //blng__PaymentMethod__c paymntmtd = new blng__PaymentMethod__c();
        objQuote.SBQQ__Account__c = acc.Id;
        objQuote.CardNumber__c = string.valueOf(1234567890);
        objQuote.NameonCard__c = 'John';
        objQuote.CardType__c ='Visa';
        //objOpp.blng__PaymentType__c ='Credit Card';
        objQuote.CardExpirationMonth__c ='12';
        objQuote.CardExpirationYear__c = '2050';                   
        objQuote.CVV__c =string.valueOf(1234);
        //objOpp.blng__AutoPay__c = True;
        //objOpp.blng__Active__c = True;
        objQuote.RecordtypeId = quoteRecordTypeId;
        update objQuote;
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:,';
        insert objAR;           
        
        // Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        // objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = acc.id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        insert objOrder;
        
        OrderItem objOI = new OrderItem();
        objOI.OrderId = objOrder.id;
        objOI.Quantity = 24;
        objOI.UnitPrice = 240;
        objOI.Product2id = objProd.Id;
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
        insert objOI;
        
        
        Quoteids.addAll(quoteidList); 
        
        //update Quoteids; 
        
        quoteHandler qth = new quoteHandler();
        qth.createOrderfromQuote(quoteList);
        
        
        quoteHandler.activateOrderfromQuote(Quoteids);
        
        List<Order> lstOrder = [SELECT Id FROM Order];
        List<Id> ListOrderIds = new List<Id>();
        ListOrderIds.add(lstOrder[0].Id);
        quoteHandler.activateOrderContract(ListOrderIds);
                
        
        objQuote.Cancelled__c = FALSE;
        objquote.SBQQ__PrimaryContact__c = objCon.Id;  
        objquote.Billing_Contact__c = objCon.Id;
        objquote.Marketing_Contact__c = objCon.Id;
        quoteList.add(objQuote);
        update quoteList;
        
        objQuote.SBQQ__Status__c = 'Closed Won';
        update objQuote;
        
        objQuote.SBQQ__Ordered__c = FALSE;
        update objQuote;
        
        quoteList = [SELECT Id, SBQQ__Status__c , Cancelled__c, Recordtype.developerName FROM SBQQ__Quote__c];
        qth.createOrderfromQuote(quoteList);
        Test.stopTest();
    }
    
    
    static testMethod void unitTestMethod1() {
        Test.starttest();
        
        Account acc = [SELECT Id FROM Account LIMIT 1];   
        
        Contact objCon = [SELECT Id FROM Contact LIMIT 1];
        
        Opportunity objOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Product2 objProd = [SELECT Id FROM Product2 LIMIT 1];
        
        blng__BillingRule__c objBR = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        
        blng__RevenueRecognitionRule__c objRR = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        
        blng__TaxRule__c objTR = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        
        
        List<id> quoteidList = new List<id>();
        Set<id> quoteids = new Set<id>();
        
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        
        SBQQ__Quote__c objQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        PricebookEntry objPBEntry = [SELECT Id FROM PricebookEntry];
        
        SBQQ__QuoteLine__c objQLI = [SELECT Id FROM SBQQ__QuoteLine__c];  
        
        //blng__PaymentMethod__c paymntmtd = new blng__PaymentMethod__c();
        objQuote.SBQQ__Account__c = acc.Id;
        objQuote.CardNumber__c = string.valueOf(1234567890);
        objQuote.NameonCard__c = 'John';
        objQuote.CardType__c ='Visa';
        //objOpp.blng__PaymentType__c ='Credit Card';
        objQuote.CardExpirationMonth__c ='12';
        objQuote.CardExpirationYear__c = '2050';                   
        objQuote.CVV__c =string.valueOf(1234);
        //objOpp.blng__AutoPay__c = True;
        //objOpp.blng__Active__c = True;
        objQuote.SBQQ__PrimaryContact__c = objCon.Id;
        objQuote.Billing_Contact__c = objCon.Id;
        objQuote.Marketing_Contact__c = objCon.Id;
        update objQuote;
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:,';
        insert objAR;           
        
        // Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        
        objQuote.SBQQ__Status__c = 'Closed Won';
        objQuote.Reason_Won_Lost__c = 'Administrative';
        objQuote.SBQQ__Ordered__c = FALSE;
        objQuote.Cancelled__c = FALSE;
        update objQuote;
       
        objQuote.SBQQ__Ordered__c = FALSE;
        update objQuote;
        
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        quoteList.add(objQuote);
        quoteHandler qth = new quoteHandler();
        qth.createOrderfromQuote(quoteList);
        
        
        Test.stopTest();
    }
    
    static testMethod void unitTestMethod2() {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];   
        
        Contact objCon = [SELECT Id FROM Contact LIMIT 1];
        
        Opportunity objOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Product2 objProd = [SELECT Id FROM Product2 LIMIT 1];
        
        blng__BillingRule__c objBR = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        
        blng__RevenueRecognitionRule__c objRR = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        
        blng__TaxRule__c objTR = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        List<id> quoteidList = new List<id>();
        Set<id> quoteids = new Set<id>();
        
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        
        SBQQ__Quote__c objQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        PricebookEntry objPBEntry = [SELECT Id FROM PricebookEntry];
        
        SBQQ__QuoteLine__c objQLI = [SELECT Id FROM SBQQ__QuoteLine__c];
        
        
        //blng__PaymentMethod__c paymntmtd = new blng__PaymentMethod__c();
        objQuote.SBQQ__Account__c = acc.Id;
        objQuote.CardNumber__c = string.valueOf(1234567890);
        objQuote.NameonCard__c = 'John';
        objQuote.CardType__c ='Visa';
        //objOpp.blng__PaymentType__c ='Credit Card';
        objQuote.CardExpirationMonth__c ='12';
        objQuote.CardExpirationYear__c = '2050';                   
        objQuote.CVV__c =string.valueOf(1234);
        //objOpp.blng__AutoPay__c = True;
        //objOpp.blng__Active__c = True;
        objQuote.SBQQ__PrimaryContact__c = objCon.Id;
        objQuote.Billing_Contact__c = objCon.Id;
        objQuote.Marketing_Contact__c = objCon.Id;
        update objQuote;
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:,';
        insert objAR;           
        
        // Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        Test.starttest();
        
        objQuote.SBQQ__Status__c = 'Closed Won';
        objQuote.Reason_Won_Lost__c = 'Administrative';
        objQuote.SBQQ__Ordered__c = FALSE;
        objQuote.Cancelled__c = FALSE;
        update objQuote;
        
        objQuote.SBQQ__Ordered__c = FALSE;
        update objQuote;
        
        quoteList.add(objQuote);
        quoteHandler qth = new quoteHandler();        
        Id strMACancelRecTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Cancel Quote').getRecordTypeId();
        
        qth.sendQuoteToActivateCancelOrder(quoteList);
        Test.stopTest();
    }
}
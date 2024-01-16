@isTest

public class Quotehandlertest { 
    
    @testSetup
    static void setupTestdata() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        
        Account acc = testData.getAccount();    
        Contact c = testData.getContact(acc.Id);
        
        Integration_Endpoints__c i =new Integration_Endpoints__c();
        i.NAme ='OrderRequest';
        i.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/efs/v2/handleSalesForceXml';
        i.MethodType__c = 'POST';
        i.xmlns__c = 'http://svcs.martindale.com/MHIntegration/OrderRequest/v1.00';
        i.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i.Endpoint_URL_for_authentication__c = 'svcs.martindale.com/mhintegration/order';
        i.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i;
        
        Restrict_Integration_Calls__c r = new Restrict_Integration_Calls__c();
        r.Name = 'Restrict';
        r.Restrict_Callouts__c = false;
        insert r;
        
        Integration_Endpoints__c inn = new Integration_Endpoints__c();
        inn.Name = 'PendInventory';
        inn.MethodType__c = 'POST';
        inn.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        inn.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        inn.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/reserve';
        inn.xmlns__c = 'http://svcs.martindale.com/MHIntegration/PendInventoryRequest/v1.00';
        inn.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory';
        inn.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert inn;
        
        Integration_Endpoints__c i1 =new Integration_Endpoints__c();
        i1.NAme ='ReleaseInventory';
        i1.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/release';
        i1.MethodType__c = 'POST';
        i1.xmlns__c = 'http://svcs.martindale.com/MHIntegration/ReleaseInventoryRequest/v1.00';
        i1.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i1.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory/release';
        i1.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i1.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i1;
        
        Email_Ids__c em = new Email_Ids__c(Name ='IntegrationErrors',Email_Id__c='test@test.com');
        insert em;
        
        Integration_Endpoints__c ie = new Integration_Endpoints__c(Name='ReleaseInventory',API_key__c='76F1CF765AA41A8E695F66A815B7D345',Endpoint_URL__c='http://stg-back-office-services.lawyers.com/services/inventory/v2/release',Endpoint_URL_for_authentication__c='svcs-stg1.martindale.com/mhintegration/inventory/release',MethodType__c='POST',Private_Key__c='eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa',Public_Key__c='b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966',xmlns__c='http://svcs.martindale.com/MHIntegration/ReleaseInventoryRequest/v1.00');
        insert ie;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Intake Opportunity').getRecordTypeId();
        Opportunity objOpp = new Opportunity();
        objOpp.Name = 'Test';
        objOpp.AccountId = acc.id;
        objOpp.RecordtypeId = oppRecordTypeId ;
        objOpp.Amount = 123.50;                                                      
        objOpp.CloseDate = system.today();
        objOpp.StageName = 'Needs Analysis';
        objOpp.invoiceit_crmx__Number_Of_Terms__c = 12;
        oppList.add(objOpp);
        
        
        insert oppList;  
        
        blng__BillingRule__c objBR = new blng__BillingRule__c();
        objBR.Name = 'Test';
        objBR.blng__Active__c = TRUE;
        objBR.blng__AmendmentBillCycleDateAlignment__c = 'Do not align amended Order Product';
        objBR.blng__GenerateInvoices__c = 'Yes';
        objBR.blng__InitialBillingTrigger__c = 'Order Product Activation Date ';
        objBR.blng__Notes__c = 'Test';
        objBR.blng__PartialPeriodTreatment__c = 'Separate';
        insert objBR;
        
        blng__RevenueRecognitionRule__c objRR = new blng__RevenueRecognitionRule__c();
        objRR.Name = 'Test';
        objRR.blng__Active__c = TRUE;
        objRR.blng__CreateRevenueSchedule__c= 'Yes';
        objRR.blng__Notes__c = 'Test';
        insert objRR;
        
        blng__TaxRule__c objTR = new blng__TaxRule__c();
        objTR.Name = 'Test';
        objTR.blng__Active__c = TRUE;
        objTR.blng__TaxableYesNo__c = 'No';
        objTR.blng__Notes__c = 'Test';
        insert objTR;
        
        List<Product2> prodList = new List<Product2>();
        Product2 objProd = new Product2();
        objProd.Name = 'Test Prod';
        objProd.Productcode = '12345';
        objProd.IsActive = true;
        objProd.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        objProd.SBQQ__SubscriptionTerm__c = 12;
        // objProd.SBQQ__SubscriptionType__c = 'Evergreen';
        objProd.SBQQ__SubscriptionType__c = 'Renewable';
        objProd.SBQQ__ChargeType__c = 'Recurring';
        objProd.SBQQ__BillingFrequency__c = 'Monthly';
        objProd.SBQQ__BillingType__c = 'Arrears';
        objProd.SBQQ__PricingMethod__c = 'List';
        objProd.blng__BillingRule__c = objBR.Id;
        objProd.blng__RevenueRecognitionRule__c = objRR.Id;
        objProd.blng__TaxRule__c = objTR.Id; 
        prodList.add(objProd);
        
        insert prodList; 
    }
    
    static testMethod void myUnitTest() {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];   
        
        Opportunity objOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Product2 objProd = [SELECT Id FROM Product2 LIMIT 1];
        
        blng__BillingRule__c objBR = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        
        blng__RevenueRecognitionRule__c objRR = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        
        blng__TaxRule__c objTR = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        List<id> quoteidList = new List<id>();
        Set<id> quoteids = new Set<id>();
        
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
        
        SBQQ__Quote__c objQuote = new SBQQ__Quote__c();
        objQuote.SBQQ__Account__c = acc.id;
        objQuote.SBQQ__PricebookId__c = Test.getStandardPricebookId();
        objQuote.RecordtypeId = quoteRecordTypeId ; 
        objQuote.SBQQ__Opportunity2__c = objOpp.id;
        objQuote.SBQQ__StartDate__c = system.today();
        objQuote.SBQQ__EndDate__c = system.today().adddays(30);
        objQuote.SBQQ__SubscriptionTerm__c = 12;
        objQuote.SBQQ__Primary__c = True;
        objQuote.SBQQ__Status__c = 'Approved';
        objQuote.SBQQ__ExpirationDate__c = system.today().adddays(30);
        objQuote.SBQQ__BillingFrequency__c = 'Monthly';  
        quoteList.add(objQuote);
        Quoteids.add(objQuote.id);
        // }
        insert quoteList;  
        
        
        
        PricebookEntry objPBEntry = new PricebookEntry();
        objPBEntry.Pricebook2Id = Test.getStandardPricebookId();
        objPBEntry.Product2Id = objProd.Id;
        objPBEntry.UnitPrice = 20;
        objPBEntry.IsActive = true;        
        insert objPBEntry;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Quote__c = objQuote.id;
        objQLI.SBQQ__Product__c = objProd.Id;
        objQLI.SBQQ__PricebookEntryId__c = objPBEntry.id;
        objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__BillingFrequency__c = 'Monthly';
        objQLI.SBQQ__BillingType__c = 'Advance';
        objQLI.RecordTypeId = quoteLineRecordTypeId ;
        objQLI.Usage_List_Price__c = 100;
        objQLI.SBQQ__SubscriptionTerm__c = 1;
        insert objQLI;
        
        
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
        
        
        Test.starttest();
        
        quoteList[0].SBQQ__Status__c = 'closewon';
        update quoteList;
        
        Quoteids.addAll(quoteidList); 
        
        quoteHandler qth = new quoteHandler();
        qth.createOrderfromQuote(quoteList);
        
        quoteHandler.activateOrderfromQuote(Quoteids);
        
        List<Order> lstOrder = [SELECT Id FROM Order];
        List<Id> ListOrderIds = new List<Id>();
        ListOrderIds.add(lstOrder[0].Id);
        quoteHandler.activateOrderContract(ListOrderIds);
        
        Test.stopTest();
    }
    
    
    static testMethod void unitTestMethod1() {
        
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
        
        SBQQ__Quote__c objQuote = new SBQQ__Quote__c();
        objQuote.SBQQ__Account__c = acc.id;
        objQuote.SBQQ__PricebookId__c = Test.getStandardPricebookId();
        objQuote.RecordtypeId = quoteRecordTypeId ; 
        objQuote.SBQQ__Opportunity2__c = objOpp.id;
        objQuote.SBQQ__StartDate__c = system.today();
        objQuote.SBQQ__EndDate__c = system.today().adddays(30);
        objQuote.SBQQ__SubscriptionTerm__c = 12;
        objQuote.SBQQ__Primary__c = True;
        objQuote.SBQQ__ExpirationDate__c = system.today().adddays(30);
        objQuote.SBQQ__BillingFrequency__c = 'Monthly';  
        Quoteids.add(objQuote.id);
        insert objQuote;
        // }        
        
        
        PricebookEntry objPBEntry = new PricebookEntry();
        objPBEntry.Pricebook2Id = Test.getStandardPricebookId();
        objPBEntry.Product2Id = objProd.Id;
        objPBEntry.UnitPrice = 20;
        objPBEntry.IsActive = true;        
        insert objPBEntry;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
        SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Quote__c = objQuote.id;
        objQLI.SBQQ__Product__c = objProd.Id;
        objQLI.SBQQ__PricebookEntryId__c = objPBEntry.id;
        objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__BillingFrequency__c = 'Monthly';
        objQLI.SBQQ__BillingType__c = 'Advance';
        objQLI.RecordTypeId = quoteLineRecordTypeId ;
        objQLI.Usage_List_Price__c = 100;
        objQLI.SBQQ__SubscriptionTerm__c = 1;
        insert objQLI;
        
        
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
        
        SBQQ__Quote__c objQuote = new SBQQ__Quote__c();
        objQuote.SBQQ__Account__c = acc.id;
        objQuote.SBQQ__PricebookId__c = Test.getStandardPricebookId();
        objQuote.RecordtypeId = quoteRecordTypeId ; 
        objQuote.SBQQ__Opportunity2__c = objOpp.id;
        objQuote.SBQQ__StartDate__c = system.today();
        objQuote.SBQQ__EndDate__c = system.today().adddays(30);
        objQuote.SBQQ__SubscriptionTerm__c = 12;
        objQuote.SBQQ__Primary__c = True;
        objQuote.SBQQ__ExpirationDate__c = system.today().adddays(30);
        objQuote.SBQQ__BillingFrequency__c = 'Monthly';  
        quoteList.add(objQuote);
        Quoteids.add(objQuote.id);
        // }
        insert quoteList;  
        
        
        
        PricebookEntry objPBEntry = new PricebookEntry();
        objPBEntry.Pricebook2Id = Test.getStandardPricebookId();
        objPBEntry.Product2Id = objProd.Id;
        objPBEntry.UnitPrice = 20;
        objPBEntry.IsActive = true;        
        insert objPBEntry;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Quote__c = objQuote.id;
        objQLI.SBQQ__Product__c = objProd.Id;
        objQLI.SBQQ__PricebookEntryId__c = objPBEntry.id;
        objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__BillingFrequency__c = 'Monthly';
        objQLI.SBQQ__BillingType__c = 'Advance';
        objQLI.RecordTypeId = quoteLineRecordTypeId ;
        objQLI.Usage_List_Price__c = 100;
        objQLI.SBQQ__SubscriptionTerm__c = 1;
        insert objQLI;
        
        
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

        objQuote.SBQQ__Ordered__c = FALSE;
        objQuote.RecordtypeId = strMACancelRecTypeId;
        update objQuote;
        
        qth.sendQuoteToActivateCancelOrder(quoteList);
        Test.stopTest();
        
        
    }
    
    
    
    
    
}
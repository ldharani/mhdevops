@isTest
private class TestCPQ_OrderRepush{
    /*
    @testSetup static void setup() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = new Account(Name = 'Test', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId());
        insert acc;
        Contact con = new Contact(LastName = 'Test', AccountId = acc.Id, Related_To_Account__c = acc.Id);
        insert con;
        Contact conA = new Contact(LastName = 'TestA', AccountId = acc.Id, Related_To_Account__c = acc.Id);
        insert conA;
        System.debug('contactttt' + con + ' ' + conA);
        Opportunity opp = new Opportunity(StageName = 'Prospect', CloseDate = System.today(), Name = 'Test', AccountId = acc.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Intake Opportunity').getRecordTypeId());
        insert opp;
        blng__BillingRule__c bRule = DataFactory.createBillingRule();
        blng__RevenueRecognitionRule__c bRev = DataFactory.createRevenueRecognitionRule();
        blng__TaxRule__c bTRule = DataFactory.createTaxRule();
        List<Product2> prds = new List<Product2>();
        prds.add(new Product2(Name = 'Avvo.com Sponsored Listings', Family = 'Advertising', Productcode = '11014', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionType__c = 'Renewable', SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Monthly', SBQQ__BillingType__c = 'Arrears', SBQQ__PricingMethod__c = 'List', blng__BillingRule__c = bRule.Id, blng__RevenueRecognitionRule__c = bRev.Id, blng__TaxRule__c = bTRule.Id));
        prds.add(new Product2(Name = 'Avvo.com Sponsored Listings', Family = 'Advertising', Productcode = '11015', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionType__c = 'Renewable', SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Monthly', SBQQ__BillingType__c = 'Arrears', SBQQ__PricingMethod__c = 'List', blng__BillingRule__c = bRule.Id, blng__RevenueRecognitionRule__c = bRev.Id, blng__TaxRule__c = bTRule.Id));
        insert prds;
        List<Attribute_Configuration__c> configs = new List<Attribute_Configuration__c>();
        configs.add(new Attribute_Configuration__c(Name = 'AOP', AttributeType__c = 'Text'));
        insert configs;
        Pricebook2 pBook = new Pricebook2(Name = 'Martindale-Avvo Price Book', IsActive = true);
        insert pBook;
        PricebookEntry priceEntry = new PricebookEntry(Product2Id = prds[0].Id, IsActive = true, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 123);
        insert priceEntry;
        SBQQ__Quote__c quo = new SBQQ__Quote__c(RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId(), SBQQ__Account__c = acc.Id, SBQQ__PricebookId__c = Test.getStandardPricebookId(), SBQQ__Opportunity2__c = opp.Id, SBQQ__StartDate__c = system.today(), SBQQ__EndDate__c = system.today().adddays(30), SBQQ__SubscriptionTerm__c = 12, SBQQ__Primary__c = True, SBQQ__Status__c = 'Approved', SBQQ__ExpirationDate__c = system.today().adddays(30), SBQQ__BillingFrequency__c = 'Monthly');
        insert quo;
        test.stopTest();
        SBQQ__QuoteLine__c quolineA = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quo.id, Contact__c = con.Id, SBQQ__Product__c = prds[0].Id, SBQQ__PricebookEntryId__c = priceEntry.Id, SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__Quantity__c = 1, SBQQ__BillingFrequency__c = 'Monthly', SBQQ__BillingType__c = 'Advance', RecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId(), Usage_List_Price__c = 100, SBQQ__SubscriptionTerm__c = 1, skipFlows__c = true);
        insert quolineA;
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Order').getRecordTypeId();
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = acc.Id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.Type = 'New';
        insert objOrder;
        
        List<OrderItem> objOILst = new List<OrderItem>();
        OrderItem objOI = new OrderItem();
        objOI.OrderId = objOrder.id;
        objOI.Quantity = 1;
        objOI.UnitPrice = 240;
        objOI.Product2id = prds[0].Id;
        objOI.PricebookEntryId = priceEntry.Id;
        objOI.SBQQ__ChargeType__c = 'Recurring';
        objOI.SBQQ__BillingFrequency__c = 'Monthly';
        objOI.SBQQ__BillingType__c = 'Arrears';
        objOI.blng__BillingRule__c = bRule.Id;
        objOI.blng__RevenueRecognitionRule__c = bRev.Id;
        objOI.SBQQ__Activated__c = TRUE;
        objOI.blng__TaxRule__c = bTRule.Id;
        objOI.ServiceDate = system.today()+50;
        objOI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objOI.contact__c = con.Id;
        //objOI.Status__c = Constant.ORDER_STATUS_PAUSE;
        objOI.Attribute_Relationship__c = objAR.id;
        objOI.Fulfillment_date__c = Date.today();
        objOI.Status__c = 'Active';
        objOI.StatusCheck__c = true;
        insert objOI;
        system.debug('rrr orditem ::: ' + objOI);
        system.debug('rrr oi.Productcode__c ' + objOI.Productcode__c +  objOI.Product2 +  objOI.Product2.ProductCode);
        
        OrderItem objOI1 = new OrderItem();
        objOI1.OrderId = objOrder.id;
        objOI1.Quantity = 1;
        objOI1.UnitPrice = 240;
        objOI1.Product2id = prds[0].Id;
        
        objOI1.PricebookEntryId = priceEntry.Id;
        objOI1.SBQQ__ChargeType__c = 'Recurring';
        objOI1.SBQQ__BillingFrequency__c = 'Monthly';
        objOI1.SBQQ__BillingType__c = 'Arrears';
        objOI1.blng__BillingRule__c = bRule.Id;
        objOI1.blng__RevenueRecognitionRule__c = bRev.Id;
        objOI1.SBQQ__Activated__c = TRUE;
        objOI1.blng__TaxRule__c = bTRule.Id;
        objOI1.ServiceDate = system.today()+50;
        objOI1.SBQQ__DefaultSubscriptionTerm__c = 12;
        objOI1.contact__c = con.Id;
        //objOI.Status__c = Constant.ORDER_STATUS_PAUSE;
        objOI1.Attribute_Relationship__c = objAR.id;
        objOI1.Fulfillment_date__c = Date.today();
        objOI1.Status__c = 'Active';
        objOI1.StatusCheck__c = true;
        insert objOI1;
        
        
        Error_Log__c e = new Error_Log__c();
        e.Order_Name__c  = objOrder.Name;
        insert e;
    }
    static testMethod void myUnitTest(){
        Integration_Endpoints__c i1 =new Integration_Endpoints__c();
        i1.NAme ='OrderRequest';
        i1.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/reserve';
        i1.MethodType__c = 'POST'; 
        i1.xmlns__c = 'http://svcs.martindale.com/MHIntegration/OrderRequest/v1.00';
        i1.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i1.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory';
        i1.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i1.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i1;
        
        
        CPQ_OrderRepush testCPQ = new CPQ_OrderRepush();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        testCPQ.validateAcc();
        testCPQ.refreshPage();
        testCPQ.generateXML();
    }
    */
        static testMethod void myUnitTest() {
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
       
        Set<Id> orderprodIds = new Set<Id>();
       
       //  MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
       // Account a = testData.getAccount();
        lstAcc[0].MH_Cust_Number__c='1001';
        update lstAcc;  
        
        //OrderRepush
        Integration_Endpoints__c inCheck = new Integration_Endpoints__c();
        inCheck.Name = 'OrderRequest';
        inCheck.MethodType__c = 'POST';
        inCheck.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        inCheck.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        inCheck.Endpoint_URL__c = 'https://atls-ob-dev-orderbroker-salesforce.internetbrands.com/api/v1/salesforce/orders?action=purchase_order';
        inCheck.xmlns__c = 'http://svcs.martindale.com/MHIntegration/OrderRequest/v1.00';
        inCheck.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/order';
        inCheck.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert inCheck;
        
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
        Attribute_Lines__c objAL = DataFactory.createAttributeLines(objAR, 'Practice Area', 'String', 'SSDI', '');
       
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry(lstProd[0], 100);
            
        Test.startTest();   
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        // Create Test Quote Line
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        objQLI.Attribute_Relationship__c = objAR.Id;
        update objQLI;
        Test.stopTest();
        
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.Status__c = 'Active';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = lstAcc[0].id;
        objOrder.blng__InvoiceBatch__c = 'M-A intake';
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.SBQQ__Quote__c = lstQuote[0].Id;
        insert objOrder;
        
        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        
        OrderItem objOI = new OrderItem();
        objOI.OrderId = objOrder.id;
        objOI.Quantity = 24;
        objOI.UnitPrice = 240;
        objOI.Product2id = lstProd[0].id;
        objOI.PricebookEntryId=objPBEntry.id;
        objOI.SBQQ__ChargeType__c = 'Recurring';
        objOI.SBQQ__BillingFrequency__c = 'Monthly';
        objOI.SBQQ__BillingType__c = 'Arrears';
        objOI.blng__BillingRule__c = objBR.Id;
        objOI.blng__RevenueRecognitionRule__c = objRR.Id;
        objOI.SBQQ__Activated__c = TRUE;
        objOI.blng__TaxRule__c = objTR.Id;
        objOI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objOI.Status__c = 'Active';
        objOI.Resume_Date__c  = system.today();
        objOI.Attribute_Relationship__c = objAR.Id;
        objOI.SBQQ__QuoteLine__c = objQLI.Id;
        objOI.blng__LegalEntity__c = legal.Id;
        insert objOI;
        
        orderprodIds.add(objOI.id ); 
        
        
      //Test.startTest(); 
      // Integration_Endpoints__c aa = [SELECT ID,Name FROM Integration_Endpoints__c WHERE Name = 'OrderRequest' limit 1];    
      CPQ_OrderRepush onDemand = new CPQ_OrderRepush ();
      onDemand.orderObj = objOrder;
      Pagereference pf = onDemand.validateAcc();
      //onDemand.orderObj = order;  
      
      Pagereference pf1 = onDemand.validateAcc();
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('orderResponse');
      mock.setStatusCode(200);
      mock.setHeader('Content-Type', 'text/xml');
      // Set the mock callout mode
      Test.setMock(HttpCalloutMock.class, mock);
      Pagereference pf2 = onDemand.generateXML();
      PageReference refreshpage = onDemand.refreshPage();
       
    
      // CPQ_MDL_Integration_Vim_Efs.orderRequestfrompage(orderprodIds);     
	  /*    
      //CPQ_OrderRepush onDemand1 = new CPQ_OrderRepush();
      StaticResourceCalloutMock mock1 = new StaticResourceCalloutMock();
      mock1.setStaticResource('orderResponseFor400Error');
      mock1.setStatusCode(502);
      mock1.setHeader('Content-Type', 'text/xml');
      // Set the mock callout mode
      onDemand1.orderObj = [Select Id,Name from Order where Id = :objOrder .Id];
      Test.setMock(HttpCalloutMock.class, mock1);
      Pagereference pf5 = onDemand1.validateAcc();  
      Pagereference pf3= onDemand1.generateXML();      
      Test.stopTest(); */
    
    }
    
    //test for 400 response
    static testMethod void myUnitTestFor400Response() {
    	
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].MH_Cust_Number__c = '222000000';
        
        Update lstAcc[0];
        
         Set<Id> orderprodIds = new Set<Id>();
        
         //OrderRepush
        Integration_Endpoints__c inCheck = new Integration_Endpoints__c();
        inCheck.Name = 'OrderRequest';
        inCheck.MethodType__c = 'POST';
        inCheck.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        inCheck.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        inCheck.Endpoint_URL__c = 'https://atls-ob-dev-orderbroker-salesforce.internetbrands.com/api/v1/salesforce/orders?action=purchase_order';
        inCheck.xmlns__c = 'http://svcs.martindale.com/MHIntegration/OrderRequest/v1.00';
        inCheck.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/order';
        inCheck.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert inCheck;
         
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
        Attribute_Lines__c objAL = DataFactory.createAttributeLines(objAR, 'Practice Area', 'String', 'SSDI', '');
       
        
       
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry(lstProd[0], 100);
        Test.startTest();  
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        // Create Test Quote Line
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        objQLI.Attribute_Relationship__c = objAR.Id;
        update objQLI;
        test.stopTest();
        // Create Test Opportunity Line Item

        //Test.startTest();
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.Status__c = 'Active';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = lstAcc[0].id;
        objOrder.blng__InvoiceBatch__c = 'M-A intake';
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.SBQQ__Quote__c = lstQuote[0].Id;
        insert objOrder;
        
        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        
        OrderItem objOI = new OrderItem();
        objOI.OrderId = objOrder.id;
        objOI.Quantity = 24;
        objOI.UnitPrice = 240;
        objOI.Product2id = lstProd[0].id;
        objOI.PricebookEntryId=objPBEntry.id;
        objOI.SBQQ__ChargeType__c = 'Recurring';
        objOI.SBQQ__BillingFrequency__c = 'Monthly';
        objOI.SBQQ__BillingType__c = 'Arrears';
        objOI.blng__BillingRule__c = objBR.Id;
        objOI.blng__RevenueRecognitionRule__c = objRR.Id;
        objOI.SBQQ__Activated__c = TRUE;
        objOI.blng__TaxRule__c = objTR.Id;
        objOI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objOI.Status__c = 'Off set';
        objOI.Resume_Date__c  = system.today();
        objOI.Attribute_Relationship__c = objAR.Id;
        objOI.SBQQ__QuoteLine__c = objQLI.Id;
        objOI.blng__LegalEntity__c = legal.Id;
        insert objOI;
        
        orderprodIds.add(objOI.id ); 
        
          
    /*Test.startTest();      
      CPQ_OrderRepush onDemand = new CPQ_OrderRepush ();
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('orderResponseFor400Error');
      mock.setStatusCode(400);
      mock.setHeader('Content-Type', 'text/xml');
      // Set the mock callout mode
      onDemand.orderObj = [Select Id,Name from Order where Id = :objOrder.Id];
      Test.setMock(HttpCalloutMock.class, mock);
      Pagereference pf = onDemand.validateAcc();  
      Pagereference pf2 = onDemand.generateXML();      
    Test.stopTest();*/

      
      //Integration_Endpoints__c aa = [SELECT ID,Name FROM Integration_Endpoints__c WHERE Name = 'OrderRequest' limit 1];    
      CPQ_OrderRepush onDemand = new CPQ_OrderRepush ();
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('orderResponseFor400Error');
      //mock.setStatusCode(400);
      mock.setHeader('Content-Type', 'text/xml');
      // Set the mock callout mode
      onDemand.orderObj = objOrder;
      Test.setMock(HttpCalloutMock.class, mock);
      Pagereference pf = onDemand.validateAcc();  
      Pagereference pf2 = onDemand.generateXML(); 
      
      //CPQ_MDL_Integration_Vim_Efs.orderRequestfrompage(orderprodIds);   
      CPQ_OrderRepush vimS = new CPQ_OrderRepush();
      vimS.FkMethod();
        //test.stopTest();  
       
    
    
    
    }
    
}
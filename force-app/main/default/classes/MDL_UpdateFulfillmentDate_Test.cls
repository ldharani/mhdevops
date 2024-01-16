@isTest
public class MDL_UpdateFulfillmentDate_Test {
    @testSetup static void setupTestData(){
         // Load Custom settings
        DataFactory.loadCustomSettings();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());

        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].MH_Cust_Number__c = '1001111111';
        Update lstAcc;
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
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
       // Contract objContract = DataFactory.createContract(lstAcc[0], lstOpp[0]);
        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        
        
        
    }
    public static testMethod void testmethod1(){
         Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
      //  Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('MH Order').getRecordTypeId();
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();

        //Order objOrder = [Select id from Order where Name = 'Test Order' limit 1];
        //List<Account> lstAcc = [Select id from Account where Name = 'Test Acc' limit 1];
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].MH_Cust_Number__c = '10343444';
        Update lstAcc[0];
        Order objOrder = new Order();
        objOrder.Name = 'Test Order';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = lstAcc[0].id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.blng__InvoiceBatch__c = 'MH-Arrears';
        insert objOrder;
       
        OrderItem objOI = new OrderItem();
        objOI.OrderId = objOrder.id;
        objOI.Quantity = 24;
        objOI.UnitPrice = 240;
       // objOI.Product2Id = lstProd[0].id;
        blng__BillingRule__c objBR = [Select id from blng__BillingRule__c limit 1];
        blng__RevenueRecognitionRule__c objRR = [Select id from blng__RevenueRecognitionRule__c limit 1];
        blng__TaxRule__c objTR = [Select id from blng__TaxRule__c limit 1];
        Attribute_Relationship__c objAR = [Select id from Attribute_Relationship__c limit 1];
        //blng__LegalEntity__c legal = [Select id from blng__LegalEntity__c limit 1];
         blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        
        PricebookEntry objPBEntry = [Select id from PricebookEntry where Product2.Name like '%Test Product%' limit 1];
        // Create PricebookEntry
        //PricebookEntry objPBEntry = DataFactory.createPricebookEntry(lstProd[0], 100);
        
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
        objOI.Renew_Rebase_Truncate_Date__c = system.today();
        //objOI.EndDate = system.today()
        insert objOI;
        objOI.SIN__c = '1001431176.01972.'+objOI.Id;
        objOI.Quantity = 25;
        update objOI;
        
        OrderItem objOI1 = new OrderItem();
        objOI1.OrderId = objOrder.id;
        objOI1.Quantity = 24;
        objOI1.UnitPrice = 240;
        objOI1.PricebookEntryId=objPBEntry.id;
        objOI1.SBQQ__ChargeType__c = 'Recurring';
        objOI1.SBQQ__BillingFrequency__c = 'Monthly';
        objOI1.SBQQ__BillingType__c = 'Arrears';
        objOI1.blng__BillingRule__c = objBR.Id;
        objOI1.blng__RevenueRecognitionRule__c = objRR.Id;
        objOI1.SBQQ__Activated__c = TRUE;
        objOI1.blng__TaxRule__c = objTR.Id;
        objOI1.SBQQ__DefaultSubscriptionTerm__c = 12;
        objOI1.Attribute_Relationship__c = objAR.Id;
        objOI1.blng__LegalEntity__c = legal.Id;
        objOI1.Status__c = 'Cancelled';
        insert objOI1;
        objOI1.SIN__c = '1001431176.01972.'+objOI.Id;
        objOI1.Quantity = 25;
        update objOI1;
        
        OrderItem objOI2 = new OrderItem();
        objOI2.OrderId = objOrder.id;
        objOI2.Quantity = 24;
        objOI2.UnitPrice = 240;
        objOI2.PricebookEntryId=objPBEntry.id;
        objOI2.SBQQ__ChargeType__c = 'Recurring';
        objOI2.SBQQ__BillingFrequency__c = 'Monthly';
        objOI2.SBQQ__BillingType__c = 'Arrears';
        objOI2.blng__BillingRule__c = objBR.Id;
        objOI2.blng__RevenueRecognitionRule__c = objRR.Id;
        objOI2.SBQQ__Activated__c = TRUE;
        objOI2.blng__TaxRule__c = objTR.Id;
        objOI2.SBQQ__DefaultSubscriptionTerm__c = 12;
        objOI2.Attribute_Relationship__c = objAR.Id;
        objOI2.blng__LegalEntity__c = legal.Id;
        objOI2.Status__c = 'Cancelled';
        objOI2.Renew_Rebase_Truncate_Date__c = system.today();
        objOI2.EndDate = system.today() - 8;
        insert objOI2;
        objOI2.SIN__c = '1001431176.01972.'+objOI.Id;
        objOI2.Quantity = 25;
        update objOI2;
        
        Date dToday = Date.today(); 
        String ss =  dToday.month() + '/' + dToday.day()+ '/' +dToday.year() ;
        String reqXML = '<FulfillmentMessageRequest>'+
            '<RequestId>0f8fad5b-d9cb-469f-a165-70867728950e</RequestId>'+
            '<CustomerNumber>'+'1001111111'+'</CustomerNumber>'+
            '<OrderNumber>'+'00000001'+'</OrderNumber>'+            
            '<LineItem>'+
            '<LineItemId>unique id</LineItemId>'+
            '<SubscriptionIdentificationNumber>' + objOI.SIN__c + '</SubscriptionIdentificationNumber>'+
            '<FulfillmentDate>'+ss+'</FulfillmentDate>'+
            '<FulfillmentID>'+'123'+'</FulfillmentID>'+
            '<Messages>'+
            '<Message>'+
            '<Code>Chat_Err_100</Code>'+
            '<Text>Org ID is not provisioned yet. Hence cannot fulfill Chat Id : 67345</Text>'+
            '<CaseOrigin>Email</CaseOrigin>'+
            '<Area>area</Area>'+
            '<SubArea>SubArea</SubArea>'+
            '</Message>'+
            '</Messages>'+
            '</LineItem>'+
            '</FulfillmentMessageRequest>';
        
        
        
        //As Per Best Practice it is important to instantiate the Rest Context 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/FulfillmentMessage';  //Request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        req.requestBody = Blob.valueof(reqXML);
        RestContext.request = req;
        RestContext.response= res;
        
        Order ord = [Select id,OrderNumber from Order limit 1];
        //objOrder.Name ='1';
        //update objOrder;
        //System.debug(objOrder.Name);

        
        MDL_UpdateFulfillmentDate.doPost();
        List<String> ssss = new List<String>{'String'};
        MDL_UpdateFulfillmentDate.constructSuccessResponse('' , '' , '' , '', '');
        //MDL_UpdateFulfillmentDate.createCase(ssss,lstAcc[0].MH_Cust_Number__c, ord.OrderNumber, objOI.SIN__c, 'reqId', 'caseOrigin', 'area', 'subArea');
        Test.stopTest();        
    }
    
    public static testMethod void testmethod2(){
         Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
      //  Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('MH Order').getRecordTypeId();
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();

        //Order objOrder = [Select id from Order where Name = 'Test Order' limit 1];
        //List<Account> lstAcc = [Select id from Account where Name = 'Test Acc' limit 1];
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].MH_Cust_Number__c = '10343444';
        Update lstAcc[0];
        Order objOrder = new Order();
        objOrder.Name = 'Test Order';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = lstAcc[0].id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.blng__InvoiceBatch__c = 'MH-Arrears';
        insert objOrder;
       
        OrderItem objOI = new OrderItem();
        objOI.OrderId = objOrder.id;
        objOI.Quantity = 24;
        objOI.UnitPrice = 240;
       // objOI.Product2Id = lstProd[0].id;
        blng__BillingRule__c objBR = [Select id from blng__BillingRule__c limit 1];
        blng__RevenueRecognitionRule__c objRR = [Select id from blng__RevenueRecognitionRule__c limit 1];
        blng__TaxRule__c objTR = [Select id from blng__TaxRule__c limit 1];
        Attribute_Relationship__c objAR = [Select id from Attribute_Relationship__c limit 1];
        //blng__LegalEntity__c legal = [Select id from blng__LegalEntity__c limit 1];
         blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        
        PricebookEntry objPBEntry = [Select id from PricebookEntry where Product2.Name like '%Test Product%' limit 1];
        // Create PricebookEntry
        //PricebookEntry objPBEntry = DataFactory.createPricebookEntry(lstProd[0], 100);
        
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
        objOI.Renew_Rebase_Truncate_Date__c = system.today();
        //insert objOI;
        objOI.SIN__c = '1001431176.01972.'+objOI.Id;
        objOI.Quantity = 25;
        //update objOI;
        
        OrderItem objOI1 = new OrderItem();
        objOI1.OrderId = objOrder.id;
        objOI1.Quantity = 24;
        objOI1.UnitPrice = 240;
        objOI1.PricebookEntryId=objPBEntry.id;
        objOI1.SBQQ__ChargeType__c = 'Recurring';
        objOI1.SBQQ__BillingFrequency__c = 'Monthly';
        objOI1.SBQQ__BillingType__c = 'Arrears';
        objOI1.blng__BillingRule__c = objBR.Id;
        objOI1.blng__RevenueRecognitionRule__c = objRR.Id;
        objOI1.SBQQ__Activated__c = TRUE;
        objOI1.blng__TaxRule__c = objTR.Id;
        objOI1.SBQQ__DefaultSubscriptionTerm__c = 12;
        objOI1.Attribute_Relationship__c = objAR.Id;
        objOI1.blng__LegalEntity__c = legal.Id;
        objOI1.Status__c = 'Truncated';
        objOI1.EndDate = system.today() - 8;
        objOI1.Fulfillment_date__c = null;
        insert objOI1;
        objOI1.SIN__c = '1001431176.01972.'+objOI.Id;
        objOI1.Quantity = 25;
        update objOI1;
        
        
        
        Date dToday = Date.today(); 
        String ss =  dToday.month() + '/' + dToday.day()+ '/' +dToday.year() ;
        String reqXML = '<FulfillmentMessageRequest>'+
            '<RequestId>0f8fad5b-d9cb-469f-a165-70867728950e</RequestId>'+
            '<CustomerNumber>'+'1001111111'+'</CustomerNumber>'+
            '<OrderNumber>'+'00000001'+'</OrderNumber>'+            
            '<LineItem>'+
            '<LineItemId>unique id</LineItemId>'+
            '<SubscriptionIdentificationNumber>' + objOI.SIN__c + '</SubscriptionIdentificationNumber>'+
            '<FulfillmentDate>'+ss+'</FulfillmentDate>'+
            '<FulfillmentID>'+'123'+'</FulfillmentID>'+
            '<Messages>'+
            '<Message>'+
            '<Code>Chat_Err_100</Code>'+
            '<Text>Org ID is not provisioned yet. Hence cannot fulfill Chat Id : 67345</Text>'+
            '<CaseOrigin>Email</CaseOrigin>'+
            '<Area>area</Area>'+
            '<SubArea>SubArea</SubArea>'+
            '</Message>'+
            '</Messages>'+
            '</LineItem>'+
            '</FulfillmentMessageRequest>';
        
        
        
        //As Per Best Practice it is important to instantiate the Rest Context 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/FulfillmentMessage';  //Request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        req.requestBody = Blob.valueof(reqXML);
        RestContext.request = req;
        RestContext.response= res;
        
        Order ord = [Select id,OrderNumber from Order limit 1];
        //objOrder.Name ='1';
        //update objOrder;
        //System.debug(objOrder.Name);

        
        MDL_UpdateFulfillmentDate.doPost();
        List<String> ssss = new List<String>{'String'};
        MDL_UpdateFulfillmentDate.constructSuccessResponse('' , '' , '' , '', '');
        MDL_UpdateFulfillmentDate.createCase(ssss,lstAcc[0].MH_Cust_Number__c, ord.OrderNumber, objOI.SIN__c, 'reqId', 'caseOrigin', 'area', 'subArea');
        Test.stopTest();        
    }
    
    public static testMethod void testmethod3(){
         Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
      //  Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('MH Order').getRecordTypeId();
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();

        //Order objOrder = [Select id from Order where Name = 'Test Order' limit 1];
        //List<Account> lstAcc = [Select id from Account where Name = 'Test Acc' limit 1];
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].MH_Cust_Number__c = '10343444';
        Update lstAcc[0];
        Order objOrder = new Order();
        objOrder.Name = 'Test Order';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = lstAcc[0].id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.blng__InvoiceBatch__c = 'MH-Arrears';
        insert objOrder;
       
     
       // objOI.Product2Id = lstProd[0].id;
        blng__BillingRule__c objBR = [Select id from blng__BillingRule__c limit 1];
        blng__RevenueRecognitionRule__c objRR = [Select id from blng__RevenueRecognitionRule__c limit 1];
        blng__TaxRule__c objTR = [Select id from blng__TaxRule__c limit 1];
        Attribute_Relationship__c objAR = [Select id from Attribute_Relationship__c limit 1];
        //blng__LegalEntity__c legal = [Select id from blng__LegalEntity__c limit 1];
         blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        
        PricebookEntry objPBEntry = [Select id from PricebookEntry where Product2.Name like '%Test Product%' limit 1];
        // Create PricebookEntry
        //PricebookEntry objPBEntry = DataFactory.createPricebookEntry(lstProd[0], 100);
           /*OrderItem objOI = new OrderItem();
        objOI.OrderId = objOrder.id;
        objOI.Quantity = 24;
        objOI.UnitPrice = 240;
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
        objOI.Renew_Rebase_Truncate_Date__c = system.today();
        //insert objOI;
        objOI.SIN__c = '1001431176.01972.'+objOI.Id;
        objOI.Quantity = 25;
        //update objOI;
        
        OrderItem objOI1 = new OrderItem();
        objOI1.OrderId = objOrder.id;
        objOI1.Quantity = 24;
        objOI1.UnitPrice = 240;
        objOI1.PricebookEntryId=objPBEntry.id;
        objOI1.SBQQ__ChargeType__c = 'Recurring';
        objOI1.SBQQ__BillingFrequency__c = 'Monthly';
        objOI1.SBQQ__BillingType__c = 'Arrears';
        objOI1.blng__BillingRule__c = objBR.Id;
        objOI1.blng__RevenueRecognitionRule__c = objRR.Id;
        objOI1.SBQQ__Activated__c = TRUE;
        objOI1.blng__TaxRule__c = objTR.Id;
        objOI1.SBQQ__DefaultSubscriptionTerm__c = 12;
        objOI1.Attribute_Relationship__c = objAR.Id;
        objOI1.blng__LegalEntity__c = legal.Id;
        objOI1.Status__c = 'Cancelled';
        insert objOI1;
        objOI1.SIN__c = '1001431176.01972.'+objOI.Id;
        objOI1.Quantity = 25;
        update objOI1;*/
        
        Date dToday = Date.today(); 
        String ss =  dToday.month() + '/' + dToday.day()+ '/' +dToday.year() ;
        String reqXML = '<FulfillmentMessageRequest>'+
            '<RequestId>0f8fad5b-d9cb-469f-a165-70867728950e</RequestId>'+
            '<CustomerNumber>'+'1001111111'+'</CustomerNumber>'+
            '<OrderNumber>'+'00000001'+'</OrderNumber>'+            
            '<LineItem>'+
            '<LineItemId>unique id</LineItemId>'+
            '<SubscriptionIdentificationNumber>' + 'test' + '</SubscriptionIdentificationNumber>'+
            '<FulfillmentDate>'+ss+'</FulfillmentDate>'+
            '<FulfillmentID>'+'123'+'</FulfillmentID>'+
            '<Messages>'+
            '<Message>'+
            '<Code>Chat_Err_100</Code>'+
            '<Text>Org ID is not provisioned yet. Hence cannot fulfill Chat Id : 67345</Text>'+
            '<CaseOrigin>Email</CaseOrigin>'+
            '<Area>area</Area>'+
            '<SubArea>SubArea</SubArea>'+
            '</Message>'+
            '</Messages>'+
            '</LineItem>'+
            '</FulfillmentMessageRequest>';
        
        
        
        //As Per Best Practice it is important to instantiate the Rest Context 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/FulfillmentMessage';  //Request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        req.requestBody = Blob.valueof(reqXML);
        RestContext.request = req;
        RestContext.response= res;
        
        Order ord = [Select id,OrderNumber from Order limit 1];
        //objOrder.Name ='1';
        //update objOrder;
        //System.debug(objOrder.Name);

        
        MDL_UpdateFulfillmentDate.doPost();
        List<String> ssss = new List<String>{'String'};
        MDL_UpdateFulfillmentDate.constructSuccessResponse('' , '' , '' , '', '');
        MDL_UpdateFulfillmentDate.createCase(ssss,lstAcc[0].MH_Cust_Number__c, ord.OrderNumber, 'test', 'reqId', 'caseOrigin', 'area', 'subArea');
        Test.stopTest();        
    }
    
    public static testMethod void testmethod4(){
         Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
      //  Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('MH Order').getRecordTypeId();
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();

        //Order objOrder = [Select id from Order where Name = 'Test Order' limit 1];
        //List<Account> lstAcc = [Select id from Account where Name = 'Test Acc' limit 1];
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].MH_Cust_Number__c = '10343444';
        Update lstAcc[0];
        Order objOrder = new Order();
        objOrder.Name = 'Test Order';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = lstAcc[0].id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.blng__InvoiceBatch__c = 'MH-Arrears';
        insert objOrder;
       
        OrderItem objOI = new OrderItem();
        objOI.OrderId = objOrder.id;
        objOI.Quantity = 24;
        objOI.UnitPrice = 240;
       // objOI.Product2Id = lstProd[0].id;
        blng__BillingRule__c objBR = [Select id from blng__BillingRule__c limit 1];
        blng__RevenueRecognitionRule__c objRR = [Select id from blng__RevenueRecognitionRule__c limit 1];
        blng__TaxRule__c objTR = [Select id from blng__TaxRule__c limit 1];
        Attribute_Relationship__c objAR = [Select id from Attribute_Relationship__c limit 1];
        //blng__LegalEntity__c legal = [Select id from blng__LegalEntity__c limit 1];
         blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        
        PricebookEntry objPBEntry = [Select id from PricebookEntry where Product2.Name like '%Test Product%' limit 1];
        // Create PricebookEntry
        //PricebookEntry objPBEntry = DataFactory.createPricebookEntry(lstProd[0], 100);
        
        
        
        OrderItem objOI1 = new OrderItem();
        objOI1.OrderId = objOrder.id;
        objOI1.Quantity = 24;
        objOI1.UnitPrice = 240;
        objOI1.PricebookEntryId=objPBEntry.id;
        objOI1.SBQQ__ChargeType__c = 'Recurring';
        objOI1.SBQQ__BillingFrequency__c = 'Monthly';
        objOI1.SBQQ__BillingType__c = 'Arrears';
        objOI1.blng__BillingRule__c = objBR.Id;
        objOI1.blng__RevenueRecognitionRule__c = objRR.Id;
        objOI1.SBQQ__Activated__c = TRUE;
        objOI1.blng__TaxRule__c = objTR.Id;
        objOI1.SBQQ__DefaultSubscriptionTerm__c = 12;
        objOI1.Attribute_Relationship__c = objAR.Id;
        objOI1.blng__LegalEntity__c = legal.Id;
        objOI1.Status__c = 'Cancelled';
        //objOI1.EndDate = system.today() - 8;
        objOI1.Fulfillment_date__c = null;
        insert objOI1;
        objOI1.SIN__c = '1001431176.01972.'+objOI.Id;
        objOI1.Quantity = 25;
        update objOI1;
        
        
        
        Date dToday = Date.today(); 
        String ss =  dToday.month() + '/' + dToday.day()+ '/' +dToday.year() ;
        String reqXML = '<FulfillmentMessageRequest>'+
            '<RequestId>0f8fad5b-d9cb-469f-a165-70867728950e</RequestId>'+
            '<CustomerNumber>'+'1001111111'+'</CustomerNumber>'+
            '<OrderNumber>'+'00000001'+'</OrderNumber>'+            
            '<LineItem>'+
            '<LineItemId>unique id</LineItemId>'+
            '<SubscriptionIdentificationNumber>' + objOI.SIN__c + '</SubscriptionIdentificationNumber>'+
            '<FulfillmentDate>'+ss+'</FulfillmentDate>'+
            '<FulfillmentID>'+'123'+'</FulfillmentID>'+
            '<Messages>'+
            '<Message>'+
            '<Code>Chat_Err_100</Code>'+
            '<Text>Org ID is not provisioned yet. Hence cannot fulfill Chat Id : 67345</Text>'+
            '<CaseOrigin>Email</CaseOrigin>'+
            '<Area>area</Area>'+
            '<SubArea>SubArea</SubArea>'+
            '</Message>'+
            '</Messages>'+
            '</LineItem>'+
            '</FulfillmentMessageRequest>';
        
        
        
        //As Per Best Practice it is important to instantiate the Rest Context 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/FulfillmentMessage';  //Request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        req.requestBody = Blob.valueof(reqXML);
        RestContext.request = req;
        RestContext.response= res;
        
        Order ord = [Select id,OrderNumber from Order limit 1];
        //objOrder.Name ='1';
        //update objOrder; 
        //System.debug(objOrder.Name);

        
        MDL_UpdateFulfillmentDate.doPost();
        List<String> ssss = new List<String>{'String'};
        MDL_UpdateFulfillmentDate.constructSuccessResponse('' , '' , '' , '', '');
        MDL_UpdateFulfillmentDate.createCase(ssss,lstAcc[0].MH_Cust_Number__c, ord.OrderNumber, objOI.SIN__c, 'reqId', 'caseOrigin', 'area', 'subArea');
        Test.stopTest();        
    }
    
}
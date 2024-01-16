@isTest
public class Test_CPQ_MDL_Integration_Vim_Efs {
  /*  @testSetup static void setup() {
        DataFactory.loadCustomSettings();
        
        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Credit_Status__c = 'Good Standing';
        Update lstAcc;
        
       
        
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
        
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
       // system.debug('DF Query'+DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1));
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
          Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        // Create Test Quote Line
        SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Quote__c = lstQuote[0].id;
        objQLI.SBQQ__Product__c = lstProd[0].Id;
        objQLI.SBQQ__PricebookEntryId__c = objPBEntry.Id;
        objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__BillingFrequency__c = 'Monthly';
        objQLI.SBQQ__BillingType__c = 'Advance';
        objQLI.RecordTypeId = quoteLineRecordTypeId;
        objQLI.Usage_List_Price__c = 100;
        objQLI.SBQQ__SubscriptionTerm__c = 1;
        objQLI.Attribute_Relationship__c = objAR.Id;
        insert objQLI;
        
        
        // Create Test Opportunity Line Item
        
        
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        /*Order objOrder = new Order();
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
        
        blng__Invoice__c inv = new blng__Invoice__c (blng__Account__c = lstAcc[0].Id, blng__InvoiceStatus__c = 'Posted',blng__Order__c = objOrder.Id);
        insert inv;
        
        Integration_Endpoints__c i1 =new Integration_Endpoints__c();
        i1.NAme ='PendInventory';
        i1.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/reserve';
        i1.MethodType__c = 'POST';
        i1.xmlns__c = 'http://svcs.martindale.com/MHIntegration/PendInventoryRequest/v1.00';
        i1.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i1.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory';
        i1.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i1.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i1;
        
        Integration_Endpoints__c i =new Integration_Endpoints__c();
        i.NAme ='ReleaseInventory';
        i.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/release';
        i.MethodType__c = 'POST';
        i.xmlns__c = 'http://svcs.martindale.com/MHIntegration/ReleaseInventoryRequest/v1.00';
        i.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory/release';
        i.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i;
        
    }*/
    
    public static testMethod void testmethodA(){
        DataFactory.loadCustomSettings();
        
        Integration_Endpoints__c i1 =new Integration_Endpoints__c();
        i1.NAme ='PendInventory';
        i1.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/reserve';
        i1.MethodType__c = 'POST';
        i1.xmlns__c = 'http://svcs.martindale.com/MHIntegration/PendInventoryRequest/v1.00';
        i1.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i1.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory';
        i1.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i1.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i1;
        
        Integration_Endpoints__c i =new Integration_Endpoints__c();
        i.NAme ='ReleaseInventory';
        i.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/release';
        i.MethodType__c = 'POST';
        i.xmlns__c = 'http://svcs.martindale.com/MHIntegration/ReleaseInventoryRequest/v1.00';
        i.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory/release';
        i.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i;
        
        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Credit_Status__c = 'Good Standing';
        Update lstAcc;
        
        
        // Create Test Contact
       /* Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);*/
        
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
        
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
       // system.debug('DF Query'+DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1));
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        test.startTest();
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
          Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        // Create Test Quote Line
        SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Quote__c = lstQuote[0].id;
        objQLI.SBQQ__Product__c = lstProd[0].Id;
        objQLI.SBQQ__PricebookEntryId__c = objPBEntry.Id;
        objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__BillingFrequency__c = 'Monthly';
        objQLI.SBQQ__BillingType__c = 'Advance';
        objQLI.RecordTypeId = quoteLineRecordTypeId;
        objQLI.Usage_List_Price__c = 100;
        objQLI.SBQQ__SubscriptionTerm__c = 1;
        objQLI.Attribute_Relationship__c = objAR.Id;
        insert objQLI;
        
        
        // Create Test Opportunity Line Item
        
        Set<Id> setIds = new Set<Id>();
        setIds.add(objQLI.Id);
        
        CPQ_MDL_Integration_Vim_Efs.pendInventoryRequest(setIds,'customerNumber','userName','acc');
        test.stopTest();
    }
    public static testMethod void testmethodB(){
         DataFactory.loadCustomSettings();
        
        Integration_Endpoints__c i1 =new Integration_Endpoints__c();
        i1.NAme ='PendInventory';
        i1.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/reserve';
        i1.MethodType__c = 'POST';
        i1.xmlns__c = 'http://svcs.martindale.com/MHIntegration/PendInventoryRequest/v1.00';
        i1.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i1.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory';
        i1.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i1.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i1;
        
        Integration_Endpoints__c i =new Integration_Endpoints__c();
        i.NAme ='ReleaseInventory';
        i.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/release';
        i.MethodType__c = 'POST';
        i.xmlns__c = 'http://svcs.martindale.com/MHIntegration/ReleaseInventoryRequest/v1.00';
        i.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory/release';
        i.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i;
        
        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Credit_Status__c = 'Good Standing';
        Update lstAcc;
        
        
        // Create Test Contact
       /* Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);*/
        
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
        
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
       // system.debug('DF Query'+DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1));
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        test.startTest();
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
          Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        // Create Test Quote Line
        SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Quote__c = lstQuote[0].id;
        objQLI.SBQQ__Product__c = lstProd[0].Id;
        objQLI.SBQQ__PricebookEntryId__c = objPBEntry.Id;
        objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__BillingFrequency__c = 'Monthly';
        objQLI.SBQQ__BillingType__c = 'Advance';
        objQLI.RecordTypeId = quoteLineRecordTypeId;
        objQLI.Usage_List_Price__c = 100;
        objQLI.SBQQ__SubscriptionTerm__c = 1;
        objQLI.Attribute_Relationship__c = objAR.Id;
        insert objQLI;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(400));
        Set<Id> setIds = new Set<Id>();
        setIds.add(objQLI.Id);
        CPQ_MDL_Integration_Vim_Efs.pendInventoryRequest(setIds,'customerNumber','userName','acc');
        test.stopTest();
    }
    public static testMethod void testmethodC(){
         DataFactory.loadCustomSettings();
        
        Integration_Endpoints__c i1 =new Integration_Endpoints__c();
        i1.NAme ='PendInventory';
        i1.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/reserve';
        i1.MethodType__c = 'POST';
        i1.xmlns__c = 'http://svcs.martindale.com/MHIntegration/PendInventoryRequest/v1.00';
        i1.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i1.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory';
        i1.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i1.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i1;
        
        Integration_Endpoints__c i =new Integration_Endpoints__c();
        i.NAme ='ReleaseInventory';
        i.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/release';
        i.MethodType__c = 'POST';
        i.xmlns__c = 'http://svcs.martindale.com/MHIntegration/ReleaseInventoryRequest/v1.00';
        i.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory/release';
        i.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i;
        
        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Credit_Status__c = 'Good Standing';
        Update lstAcc;
        
        
        // Create Test Contact
       /* Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);*/
        
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
        
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
       // system.debug('DF Query'+DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1));
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        test.startTest();
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
          Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        // Create Test Quote Line
        SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Quote__c = lstQuote[0].id;
        objQLI.SBQQ__Product__c = lstProd[0].Id;
        objQLI.SBQQ__PricebookEntryId__c = objPBEntry.Id;
        objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__BillingFrequency__c = 'Monthly';
        objQLI.SBQQ__BillingType__c = 'Advance';
        objQLI.RecordTypeId = quoteLineRecordTypeId;
        objQLI.Usage_List_Price__c = 100;
        objQLI.SBQQ__SubscriptionTerm__c = 1;
        objQLI.Attribute_Relationship__c = objAR.Id;
        insert objQLI;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(404));
        Integration_Endpoints__c aa = [SELECT ID,Name FROM Integration_Endpoints__c WHERE Name = 'PendInventory' ];
        Set<Id> setIds = new Set<Id>();
        setIds.add(objQLI.Id);
        CPQ_MDL_Integration_Vim_Efs.pendInventoryRequest(setIds,'customerNumber','userName','acc');
        test.stopTest(); 
    }
    public static testMethod void testmethodD(){
         DataFactory.loadCustomSettings();
        
        Integration_Endpoints__c i1 =new Integration_Endpoints__c();
        i1.NAme ='PendInventory';
        i1.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/reserve';
        i1.MethodType__c = 'POST';
        i1.xmlns__c = 'http://svcs.martindale.com/MHIntegration/PendInventoryRequest/v1.00';
        i1.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i1.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory';
        i1.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i1.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i1;
        
        Integration_Endpoints__c i =new Integration_Endpoints__c();
        i.NAme ='ReleaseInventory';
        i.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/release';
        i.MethodType__c = 'POST';
        i.xmlns__c = 'http://svcs.martindale.com/MHIntegration/ReleaseInventoryRequest/v1.00';
        i.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory/release';
        i.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i;
        
        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Credit_Status__c = 'Good Standing';
        Update lstAcc;
        
        
        // Create Test Contact
       /* Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);*/
        
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
        
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
       // system.debug('DF Query'+DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1));
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        test.startTest();
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
          Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        // Create Test Quote Line
        SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Quote__c = lstQuote[0].id;
        objQLI.SBQQ__Product__c = lstProd[0].Id;
        objQLI.SBQQ__PricebookEntryId__c = objPBEntry.Id;
        objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__BillingFrequency__c = 'Monthly';
        objQLI.SBQQ__BillingType__c = 'Advance';
        objQLI.RecordTypeId = quoteLineRecordTypeId;
        objQLI.Usage_List_Price__c = 100;
        objQLI.SBQQ__SubscriptionTerm__c = 1;
        objQLI.Attribute_Relationship__c = objAR.Id;
        insert objQLI;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(500));
        Integration_Endpoints__c aa = [SELECT ID,Name FROM Integration_Endpoints__c WHERE Name = 'PendInventory' ];
        Set<Id> setIds = new Set<Id>();
        setIds.add(objQLI.Id);
        CPQ_MDL_Integration_Vim_Efs.pendInventoryRequest(setIds,'customerNumber','userName','acc');
        test.stopTest();
    }
    public static testMethod void testmethodE(){
         DataFactory.loadCustomSettings();
        
        Integration_Endpoints__c i1 =new Integration_Endpoints__c();
        i1.NAme ='PendInventory';
        i1.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/reserve';
        i1.MethodType__c = 'POST';
        i1.xmlns__c = 'http://svcs.martindale.com/MHIntegration/PendInventoryRequest/v1.00';
        i1.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i1.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory';
        i1.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i1.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i1;
        
        Integration_Endpoints__c i =new Integration_Endpoints__c();
        i.NAme ='ReleaseInventory';
        i.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/release';
        i.MethodType__c = 'POST';
        i.xmlns__c = 'http://svcs.martindale.com/MHIntegration/ReleaseInventoryRequest/v1.00';
        i.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory/release';
        i.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i;
        
        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Credit_Status__c = 'Good Standing';
        Update lstAcc;
        
        
        // Create Test Contact
       /* Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);*/
        
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
        
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
       // system.debug('DF Query'+DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1));
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        test.startTest();
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
          Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        // Create Test Quote Line
        SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Quote__c = lstQuote[0].id;
        objQLI.SBQQ__Product__c = lstProd[0].Id;
        objQLI.SBQQ__PricebookEntryId__c = objPBEntry.Id;
        objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__BillingFrequency__c = 'Monthly';
        objQLI.SBQQ__BillingType__c = 'Advance';
        objQLI.RecordTypeId = quoteLineRecordTypeId;
        objQLI.Usage_List_Price__c = 100;
        objQLI.SBQQ__SubscriptionTerm__c = 1;
        objQLI.Attribute_Relationship__c = objAR.Id;
        insert objQLI;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(502));
        Integration_Endpoints__c aa = [SELECT ID,Name FROM Integration_Endpoints__c WHERE Name = 'PendInventory' ];
        Set<Id> setIds = new Set<Id>();
        setIds.add(objQLI.Id);
        CPQ_MDL_Integration_Vim_Efs.pendInventoryRequest(setIds,'customerNumber','userName','acc');
        test.stopTest();
    } 
    public static testMethod void testmethodF(){
         DataFactory.loadCustomSettings();
        
        Integration_Endpoints__c i1 =new Integration_Endpoints__c();
        i1.NAme ='PendInventory';
        i1.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/reserve';
        i1.MethodType__c = 'POST';
        i1.xmlns__c = 'http://svcs.martindale.com/MHIntegration/PendInventoryRequest/v1.00';
        i1.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i1.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory';
        i1.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i1.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i1;
        
        Integration_Endpoints__c i =new Integration_Endpoints__c();
        i.NAme ='ReleaseInventory';
        i.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/release';
        i.MethodType__c = 'POST';
        i.xmlns__c = 'http://svcs.martindale.com/MHIntegration/ReleaseInventoryRequest/v1.00';
        i.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory/release';
        i.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i;
        
        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Credit_Status__c = 'Good Standing';
        Update lstAcc;
        
        
        // Create Test Contact
       /* Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);*/
        
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
        
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
       // system.debug('DF Query'+DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1));
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        test.startTest();
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
          Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        // Create Test Quote Line
        SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Quote__c = lstQuote[0].id;
        objQLI.SBQQ__Product__c = lstProd[0].Id;
        objQLI.SBQQ__PricebookEntryId__c = objPBEntry.Id;
        objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__BillingFrequency__c = 'Monthly';
        objQLI.SBQQ__BillingType__c = 'Advance';
        objQLI.RecordTypeId = quoteLineRecordTypeId;
        objQLI.Usage_List_Price__c = 100;
        objQLI.SBQQ__SubscriptionTerm__c = 1;
        objQLI.Attribute_Relationship__c = objAR.Id;
        insert objQLI;
        
        OpportunityLineItem objOLI = new OpportunityLineItem();
        objOLI.Product2Id = lstProd[0].Id;
        objOLI.OpportunityId = lstOpp[0].Id;
        objOLI.PricebookEntryId = objPBEntry.Id;
        objOLI.TotalPrice = objPBEntry.UnitPrice;
        objOLI.SBQQ__QuoteLine__c = objQLI.Id;
        objOLI.Quantity = 1;
        insert objOLI;
        
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.Status__c = 'Active';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = lstAcc[0].id;
        //objOrder.blng__InvoiceBatch__c = 'TEST';
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.SBQQ__Quote__c = lstQuote[0].Id;
        insert objOrder;
        
        
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
        
         blng__Invoice__c inv = new blng__Invoice__c (blng__Account__c = lstAcc[0].Id, blng__InvoiceStatus__c = 'Posted',blng__Order__c = objOrder.Id);
        insert inv;
        
        Map<Id,String> mapS = new Map<Id,String>();
        Map<Id,SBQQ__QuoteLine__c> mapQ = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,Boolean> mapB = new Map<Id,Boolean>();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200));
        List<String> sstt = new List<String>{'RequestId'};
            List<String> responseString = new List<String>{'<OrderResponse xmlns:xsd="http://www.martindale.com/mhintegration/data-model" xmlns:xsi="http://www.martindale.com/mhintegration/data-model-instance"> <RequestId>'+inv.Id+'</RequestId> <HttpResponseCode>200</HttpResponseCode> <Messages> <Message> <Code>200</Code> <Text>SUCCESS - stg-ibmhbows2.internetbrands.com63ce5da112509</Text> </Message> </Messages> <Order> <CustomerNumber></CustomerNumber> <OrderNumber></OrderNumber> <LineItems> <LineItem> <SubscriptionIdentificationNumber></SubscriptionIdentificationNumber> </LineItem> </LineItems> </Order><IsCancelled>true</IsCancelled><InventoryId>1234</InventoryId><Messages><Message>Success</Message></Messages> </OrderResponse>'};
            Integration_Endpoints__c aa = [SELECT ID,Name FROM Integration_Endpoints__c WHERE Name = 'PendInventory' ];
        Integration_Endpoints__c bb = [SELECT ID,Name FROM Integration_Endpoints__c WHERE Name = 'ReleaseInventory' ];
        Set<Id> setIds = new Set<Id>();
        
      
        setIds.add(objQLI.Id);
        mapQ.put(objQLI.Id,objQLI);
        mapS.put(objQLI.Id, 'value');
        mapB.put(objQLI.Id, false);
        CPQ_MDL_Integration_Vim_Efs.releaseInventoryRequestForBatch(setIds,'customerNumber');
        CPQ_MDL_Integration_Vim_Efs.parseResponseXML_PendInventoryResponse(sstt,'customerNumber');
        CPQ_MDL_Integration_Vim_Efs.parseResponseXML_ReleaseInventoryResponse(responseString);
        CPQ_MDL_Integration_Vim_Efs.parseErrorResponsePendInventory(mapS,mapQ,mapB);
        CPQ_MDL_Integration_Vim_Efs.releaseInventoryRequest(setIds,'customerNumber');
        CPQ_MDL_Integration_Vim_Efs.releaseInventoryRequest(setIds,'customerNumber',mapS);
        test.stopTest();
    }
    public static testMethod void testmethodG(){
        DataFactory.loadCustomSettings();
        
        Integration_Endpoints__c i1 =new Integration_Endpoints__c();
        i1.NAme ='PendInventory';
        i1.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/reserve';
        i1.MethodType__c = 'POST';
        i1.xmlns__c = 'http://svcs.martindale.com/MHIntegration/PendInventoryRequest/v1.00';
        i1.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i1.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory';
        i1.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i1.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i1;
        
        Integration_Endpoints__c i =new Integration_Endpoints__c();
        i.NAme ='ReleaseInventory';
        i.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/release';
        i.MethodType__c = 'POST';
        i.xmlns__c = 'http://svcs.martindale.com/MHIntegration/ReleaseInventoryRequest/v1.00';
        i.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory/release';
        i.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i;
        
        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Credit_Status__c = 'Good Standing';
        Update lstAcc;
        
        
        // Create Test Contact
       /* Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);*/
        
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
        
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
       // system.debug('DF Query'+DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1));
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        test.startTest();
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
          Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        // Create Test Quote Line
        SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Quote__c = lstQuote[0].id;
        objQLI.SBQQ__Product__c = lstProd[0].Id;
        objQLI.SBQQ__PricebookEntryId__c = objPBEntry.Id;
        objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__BillingFrequency__c = 'Monthly';
        objQLI.SBQQ__BillingType__c = 'Advance';
        objQLI.RecordTypeId = quoteLineRecordTypeId;
        objQLI.Usage_List_Price__c = 100;
        objQLI.SBQQ__SubscriptionTerm__c = 1;
        objQLI.Attribute_Relationship__c = objAR.Id;
        insert objQLI;
        
        OpportunityLineItem objOLI = new OpportunityLineItem();
        objOLI.Product2Id = lstProd[0].Id;
        objOLI.OpportunityId = lstOpp[0].Id;
        objOLI.PricebookEntryId = objPBEntry.Id;
        objOLI.TotalPrice = objPBEntry.UnitPrice;
        objOLI.SBQQ__QuoteLine__c = objQLI.Id;
        objOLI.Quantity = 1;
        insert objOLI;
        
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.Status__c = 'Active';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = lstAcc[0].id;
        //objOrder.blng__InvoiceBatch__c = 'TEST';
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.SBQQ__Quote__c = lstQuote[0].Id;
        insert objOrder;
        
        
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
        
         blng__Invoice__c inv = new blng__Invoice__c (blng__Account__c = lstAcc[0].Id, blng__InvoiceStatus__c = 'Posted',blng__Order__c = objOrder.Id);
        insert inv;
        
        Map<Id,String> mapS = new Map<Id,String>();
        Map<Id,SBQQ__QuoteLine__c> mapQ = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,Boolean> mapB = new Map<Id,Boolean>();
        List<OrderItem> oi = [Select Id from OrderItem Limit 1];
        
        
        List<String> responseString = new List<String>{'<OrderResponse xmlns:xsd="http://www.martindale.com/mhintegration/data-model" xmlns:xsi="http://www.martindale.com/mhintegration/data-model-instance"> <RequestId>'+oi[0].Id+'-OrderRequest'+'</RequestId> <HttpResponseCode>200</HttpResponseCode> <Messages> <Message> <Code>200</Code> <Text>SUCCESS - stg-ibmhbows2.internetbrands.com63ce5da112509</Text> </Message> </Messages> <Order> <CustomerNumber></CustomerNumber> <OrderNumber></OrderNumber> <LineItems> <LineItem> <SubscriptionIdentificationNumber></SubscriptionIdentificationNumber> </LineItem> </LineItems> </Order><IsCancelled>true</IsCancelled><InventoryId>1234</InventoryId><Messages><Message>Success</Message></Messages> </OrderResponse>'};
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(400));
        List<String> sstt = new List<String>{'RequestId'};
            Integration_Endpoints__c aa = [SELECT ID,Name FROM Integration_Endpoints__c WHERE Name = 'PendInventory' ];
        Integration_Endpoints__c bb = [SELECT ID,Name FROM Integration_Endpoints__c WHERE Name = 'ReleaseInventory' ];
        Set<Id> setIds = new Set<Id>();
        setIds.add(objQLI.Id);
        mapQ.put(objQLI.Id,objQLI);
        mapS.put(objQLI.Id, 'value');
        mapB.put(objQLI.Id, false);
        CPQ_MDL_Integration_Vim_Efs.releaseInventoryRequestForBatch(setIds,'customerNumber');
        CPQ_MDL_Integration_Vim_Efs.releaseInventoryRequest(setIds,'customerNumber');
        CPQ_MDL_Integration_Vim_Efs.parseResponseXML_ReleaseInventoryResponse(responseString);
        
        CPQ_MDL_Integration_Vim_Efs.releaseInventoryRequest(setIds,'customerNumber',mapS);
        
        test.stopTest();
    }
    public static testMethod void testmethodH(){
        DataFactory.loadCustomSettings();
        
        Integration_Endpoints__c i1 =new Integration_Endpoints__c();
        i1.NAme ='PendInventory';
        i1.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/reserve';
        i1.MethodType__c = 'POST';
        i1.xmlns__c = 'http://svcs.martindale.com/MHIntegration/PendInventoryRequest/v1.00';
        i1.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i1.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory';
        i1.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i1.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i1;
        
        Integration_Endpoints__c i =new Integration_Endpoints__c();
        i.NAme ='ReleaseInventory';
        i.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/release';
        i.MethodType__c = 'POST';
        i.xmlns__c = 'http://svcs.martindale.com/MHIntegration/ReleaseInventoryRequest/v1.00';
        i.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory/release';
        i.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i;
        
        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Credit_Status__c = 'Good Standing';
        Update lstAcc;
        
        
        // Create Test Contact
       /* Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);*/
        
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
        
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
       // system.debug('DF Query'+DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1));
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        test.startTest();
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
          Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        // Create Test Quote Line
        SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Quote__c = lstQuote[0].id;
        objQLI.SBQQ__Product__c = lstProd[0].Id;
        objQLI.SBQQ__PricebookEntryId__c = objPBEntry.Id;
        objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__BillingFrequency__c = 'Monthly';
        objQLI.SBQQ__BillingType__c = 'Advance';
        objQLI.RecordTypeId = quoteLineRecordTypeId;
        objQLI.Usage_List_Price__c = 100;
        objQLI.SBQQ__SubscriptionTerm__c = 1;
        objQLI.Attribute_Relationship__c = objAR.Id;
        insert objQLI;
        
        OpportunityLineItem objOLI = new OpportunityLineItem();
        objOLI.Product2Id = lstProd[0].Id;
        objOLI.OpportunityId = lstOpp[0].Id;
        objOLI.PricebookEntryId = objPBEntry.Id;
        objOLI.TotalPrice = objPBEntry.UnitPrice;
        objOLI.SBQQ__QuoteLine__c = objQLI.Id;
        objOLI.Quantity = 1;
        insert objOLI;
        
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.Status__c = 'Active';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = lstAcc[0].id;
        //objOrder.blng__InvoiceBatch__c = 'TEST';
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.SBQQ__Quote__c = lstQuote[0].Id;
        insert objOrder;
        
        
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
        
         blng__Invoice__c inv = new blng__Invoice__c (blng__Account__c = lstAcc[0].Id, blng__InvoiceStatus__c = 'Posted',blng__Order__c = objOrder.Id);
        insert inv;
        
        Map<Id,String> mapS = new Map<Id,String>();
        Map<Id,SBQQ__QuoteLine__c> mapQ = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,Boolean> mapB = new Map<Id,Boolean>();
        List<OpportunityLineItem> oli = [Select Id from OpportunityLineItem limit 1];
        
        List<String> responseString2 = new List<String>{'<OrderResponse xmlns:xsd="http://www.martindale.com/mhintegration/data-model" xmlns:xsi="http://www.martindale.com/mhintegration/data-model-instance"> <RequestId>'+oli[0].Id+'-OrderRequest'+'</RequestId> <HttpResponseCode>200</HttpResponseCode> <Messages> <Message> <Code>200</Code> <Text>SUCCESS - stg-ibmhbows2.internetbrands.com63ce5da112509</Text> </Message> </Messages> <Order> <CustomerNumber></CustomerNumber> <OrderNumber></OrderNumber> <LineItems> <LineItem> <SubscriptionIdentificationNumber></SubscriptionIdentificationNumber> </LineItem> </LineItems> </Order><IsCancelled>true</IsCancelled><InventoryId>1234</InventoryId><Messages><Message>Success</Message></Messages> </OrderResponse>'};
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(300));
        List<String> sstt = new List<String>{'RequestId'};
            Integration_Endpoints__c aa = [SELECT ID,Name FROM Integration_Endpoints__c WHERE Name = 'PendInventory' ];
        Integration_Endpoints__c bb = [SELECT ID,Name FROM Integration_Endpoints__c WHERE Name = 'ReleaseInventory' ];
        Set<Id> setIds = new Set<Id>();
        setIds.add(objQLI.Id);
        mapQ.put(objQLI.Id,objQLI);
        mapS.put(objQLI.Id, 'value');
        mapB.put(objQLI.Id, false);
        CPQ_MDL_Integration_Vim_Efs.releaseInventoryRequestForBatch(setIds,'customerNumber');
        CPQ_MDL_Integration_Vim_Efs.releaseInventoryRequest(setIds,'customerNumber');
        CPQ_MDL_Integration_Vim_Efs.releaseInventoryRequest(setIds,'customerNumber',mapS);
        CPQ_MDL_Integration_Vim_Efs.parseResponseXML_ReleaseInventoryResponse(responseString2);
        test.stopTest();
    }
    public static testMethod void testmethodI(){
         DataFactory.loadCustomSettings();
        
        Integration_Endpoints__c i1 =new Integration_Endpoints__c();
        i1.NAme ='PendInventory';
        i1.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/reserve';
        i1.MethodType__c = 'POST';
        i1.xmlns__c = 'http://svcs.martindale.com/MHIntegration/PendInventoryRequest/v1.00';
        i1.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i1.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory';
        i1.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i1.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i1;
        
        Integration_Endpoints__c i =new Integration_Endpoints__c();
        i.NAme ='ReleaseInventory';
        i.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/release';
        i.MethodType__c = 'POST';
        i.xmlns__c = 'http://svcs.martindale.com/MHIntegration/ReleaseInventoryRequest/v1.00';
        i.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        i.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory/release';
        i.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        i.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert i;
        
        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Credit_Status__c = 'Good Standing';
        Update lstAcc;
        
        
        // Create Test Contact
       /* Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);*/
        
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
        
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
       // system.debug('DF Query'+DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1));
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        test.startTest();
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
          Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        // Create Test Quote Line
        SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Quote__c = lstQuote[0].id;
        objQLI.SBQQ__Product__c = lstProd[0].Id;
        objQLI.SBQQ__PricebookEntryId__c = objPBEntry.Id;
        objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__BillingFrequency__c = 'Monthly';
        objQLI.SBQQ__BillingType__c = 'Advance';
        objQLI.RecordTypeId = quoteLineRecordTypeId;
        objQLI.Usage_List_Price__c = 100;
        objQLI.SBQQ__SubscriptionTerm__c = 1;
        objQLI.Attribute_Relationship__c = objAR.Id;
        insert objQLI;
        
        OpportunityLineItem objOLI = new OpportunityLineItem();
        objOLI.Product2Id = lstProd[0].Id;
        objOLI.OpportunityId = lstOpp[0].Id;
        objOLI.PricebookEntryId = objPBEntry.Id;
        objOLI.TotalPrice = objPBEntry.UnitPrice;
        objOLI.SBQQ__QuoteLine__c = objQLI.Id;
        objOLI.Quantity = 1;
        insert objOLI;
        
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.Status__c = 'Active';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = lstAcc[0].id;
        //objOrder.blng__InvoiceBatch__c = 'TEST';
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.SBQQ__Quote__c = lstQuote[0].Id;
        insert objOrder;
        
        
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
        
         blng__Invoice__c inv = new blng__Invoice__c (blng__Account__c = lstAcc[0].Id, blng__InvoiceStatus__c = 'Posted',blng__Order__c = objOrder.Id);
        insert inv;
        
        Map<Id,String> mapS = new Map<Id,String>();
        Map<Id,SBQQ__QuoteLine__c> mapQ = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,Boolean> mapB = new Map<Id,Boolean>();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(500));
        List<String> sstt = new List<String>{'RequestId'};
            Integration_Endpoints__c aa = [SELECT ID,Name FROM Integration_Endpoints__c WHERE Name = 'PendInventory' ];
        Integration_Endpoints__c bb = [SELECT ID,Name FROM Integration_Endpoints__c WHERE Name = 'ReleaseInventory' ];
        Set<Id> setIds = new Set<Id>();
        setIds.add(objQLI.Id);
        mapQ.put(objQLI.Id,objQLI);
        mapS.put(objQLI.Id, 'value');
        mapB.put(objQLI.Id, false);
        
        CPQ_MDL_Integration_Vim_Efs.releaseInventoryRequest(setIds,'customerNumber');
        CPQ_MDL_Integration_Vim_Efs.releaseInventoryRequestForBatch(setIds,'customerNumber');
        CPQ_MDL_Integration_Vim_Efs.releaseInventoryRequest(setIds,'customerNumber',mapS);
        CPQ_MDL_Integration_Vim_Efs vimS = new CPQ_MDL_Integration_Vim_Efs();
        vimS.FkMethod();
        test.stopTest();
    }
    
  
    /*
    public static testMethod void testmethodK(){
          test.startTest();
          // Load Custom settings
        DataFactory.loadCustomSettings();
        
       // List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
        // Create Test Opportunity
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Opportunity').getRecordTypeId();
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
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        // Create Test Quote Line
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Quote Line').getRecordTypeId();
        
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        objQLI.Attribute_Relationship__c = objAR.Id;
        update objQLI;
        
        // Create Test Opportunity Line Item
        DataFactory.createOpportunityLineItem(lstOpp[0], lstProd[0], objPBEntry, objQLI);
        
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Order').getRecordTypeId();
        
        lstAcc[0].Contact_Email__c = 'Kevintest@gmail.com'; 
        
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
       //objOrder.Account.Contact_Email__c = 'Kevintest@gmail.com';
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
        
      
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(502));
        //Integration_Endpoints__c aa = [SELECT ID,Name FROM Integration_Endpoints__c WHERE Name = 'OrderRequest' ];
        Set<Id> setIds = new Set<Id>();
        //OrderItem objOI = [SELECT Id FROM OrderItem LIMIT 1];
        setIds.add(objOI.Id);
        CPQ_MDL_Integration_Vim_Efs.orderRequest(setIds);
        test.stopTest();
    
    } */
}
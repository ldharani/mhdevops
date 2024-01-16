/**@@
#TEST CLASS OF         :    Batch_MH_Ngage_Association
#CREATED BY            :    VR
#TICKET                :    MHBS-6708

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************
@@**/

@IsTest
public class Batch_MH_Ngage_Association_Test {
    
 /*	@testSetup static void setup() {
        
        DataFactory.loadCustomSettings();
       
 // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
    
    	Id accRecordTypeIdParent = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        List<Account> lstAccIB = DataFactory.createAccount('Test Acc IB', accRecordTypeIdParent, 1);
        lstAcc[0].ParentID = lstAccIB[0].ID;
         lstAcc[0].ShippingStreet = '7 St. John Street';lstAcc[0].ShippingCity =  'Monticello';lstAcc[0].ShippingState =  'NY';lstAcc[0].ShippingCountry =  'USA';lstAcc[0].ShippingPostalCode =  '12701';
    	
    	Update lstAcc;


        DefaultPaymentAccount__c ddd = new DefaultPaymentAccount__c();
        ddd.Name = 'DefaultAccountRecord';
        ddd.Default_Account_ID__c = lstAcc[0].ID;
        ddd.DefaultAccountNumber__c = '1000095499';
        ddd.PaymentAllocationRectypeID__c = '012F0000001K3Lc';
        ddd.PaymentRecordTypeID__c = '012F0000001K3Ld';
        ddd.USDCurrencyID__c = 'a03F0000009vD0D';
        insert ddd;
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> lstCon =DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
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
        //List<Product2> lstProd = DataFactory.createProduct('Test Product', objBR, objRR, objTR, 1);
        
        Product2 prod2 = new Product2(Name='Test Ngage',ProductCode='NgProd',Family='Ngage',IsActive=true,
               SBQQ__ChargeType__c='Recurring',SBQQ__ConfigurationEvent__c='Always',SBQQ__BillingFrequency__c='Monthly',
               SBQQ__BillingType__c = 'Advance',SBQQ__SubscriptionTerm__c = 1,
               SBQQ__NonDiscountable__c=true,SBQQ__PricingMethod__c='List',SBQQ__QuantityEditable__c=false,
               SBQQ__SubscriptionType__c='Renewable',SBQQ__PriceEditable__c=false,
               blng__BillingRule__c=objBR.ID,blng__RevenueRecognitionRule__c=objRR.ID,blng__TaxRule__c=objTR.ID);
        Insert prod2;
         List<Product2> lstProd = new List<Product2>();
    	 lstProd.add(prod2);
       	 
       
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
    
      
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
       // system.debug('DF Query'+DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1));
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
        
        // Create Test Quote Line
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry,quoteLineRecordTypeId, 1);
     
         Test.startTest();
        // Create Test Opportunity Line Item
        //DataFactory.createOpportunityLineItem(lstOpp[0], lstProd[0], objPBEntry, objQLI);

        lstQuote[0].SBQQ__Ordered__c = TRUE;
        lstQuote[0].SBQQ__PrimaryContact__c = lstCon[0].ID;
        lstQuote[0].Marketing_Contact__c = lstCon[0].ID;
        lstQuote[0].Billing_Contact__c = lstCon[0].ID;
       /* Update lstQuote;
    	 List<Order> ordList = [Select ID,Status,SBQQ__Contracted__c from Order  limit 1];
    	
          Contract objContract = new Contract();
            objContract.AccountId = lstOpp[0].AccountId;
            objContract.SBQQ__Opportunity__c = lstOpp[0].Id;
            objContract.SBQQ__Quote__c = lstQuote[0].Id;
            objContract.Status = 'Draft';
            objContract.StartDate = Date.today();
            objContract.ContractTerm = 2;
    	
          INSERT objContract;
			objContract.Original_Order__c = ordList[0].ID;
            objContract.Status = 'Activated';
            objContract.Status__c = 'Active';
            update objContract;
    
    
      Id subRecordTypeId = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('MH Subscriptions').getRecordTypeId();
        
        SBQQ__Subscription__c objSubs = new SBQQ__Subscription__c();
            objSubs.SBQQ__Account__c = lstAcc[0].Id;
            objSubs.SBQQ__Contract__c = objContract.Id; 
            objSubs.SBQQ__Product__c = lstProd[0].Id; 
            objSubs.SBQQ__Quantity__c = 1;
            objSubs.SBQQ__NetPrice__c = 100;
            objSubs.SBQQ__SubscriptionEndDate__c = Date.today().addYears(1);
            objSubs.SBQQ__QuoteLine__c = objQLI.Id;
         	objSubs.RecordTypeID = subRecordTypeId;
        insert objSubs;
     
		blng__PaymentMethod__c pmRec = new blng__PaymentMethod__c();
    
        pmRec.blng__Account__c = lstAcc[0].Id;
        pmRec.blng__PaymentType__c = 'ACH';
        pmRec.blng__Active__c = True;
        pmRec.blng__AutoPay__c = True;
        pmRec.Card_Number__c = '4111111111111111';
        pmRec.blng__Nameoncard__c = 'Jim';
        pmRec.blng__CVV__c = '22222';
        pmRec.blng__CardExpirationYear__c = '2030';
        pmRec.blng__CardExpirationMonth__c = '10';
        pmRec.blng__CardType__c = 'Visa';
        pmRec.Payment_Profile_ID__c = 'testProfileId';
    	pmRec.blng__BankRoutingCode__c = '123456789';
    	pmRec.blng__AutoPay__c = true;
    	pmRec.blng__BankAccountName__c = 'AccountName';
    	pmRec.blng__BankAccountNumber__c = '3456';
    	pmRec.blng__BankAccountType__c = 'Checking';
    	pmRec.blng__BankName__c = 'BankName';
    	pmRec.blng__BillingCity__c = 'City';
    	pmRec.blng__BillingCountry__c = 'Anguilla';
    	pmRec.blng__BillingEmail__c = 'testuser@test.com';
    	pmRec.blng__BillingFirstName__c = 'TestUser';
    	pmRec.blng__BillingLastName__c = 'TestUser';
    	pmRec.blng__BillingStateProvince__c = 'state';
    	pmRec.blng__BillingZipPostal__c = 'blng__BillingZipPostal__c';
    
        insert pmRec;
       Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2()); 
    	Test.stopTest();
    } */
    
     @isTest()  
     public static void testUnitMethod2(){
       	 //CASE 1 : Create Ngage Account and transfer all cons and pms. (If MH Acc has Ngage sub)
         DataFactory.loadCustomSettings();
        
           blng__PaymentGateway__c objPG = new blng__PaymentGateway__c();
        objPG.Name = 'Gateway for Legal Cases - Sandbox';
        objPG.blng__Active__c = true;
        objPG.blng__Default__c = true;
        objPG.blng__GatewayType__c = 'AuthorizeDotNet';
        objPG.TestMode__c = true;
        objPG.adnblng__APILoginId__c = 'Test';
        objPG.adnblng__APITransactionKey__c = 'Test';
        objPG.Endpoint_URL__c = 'https://apitest.authorize.net/xml/v1/request.api';
        insert objPG;
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
         Id accRecordTypeIdParent = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        List<Account> lstAccIB = DataFactory.createAccount('Test Acc IB', accRecordTypeIdParent, 1);
        lstAcc[0].ParentID = lstAccIB[0].ID;
    	Update lstAcc;
         
         blng__PaymentMethod__c pmRec = new blng__PaymentMethod__c();
        pmRec.blng__Account__c = lstAcc[0].Id;
        pmRec.blng__PaymentType__c = 'Credit Card';
        pmRec.blng__Active__c = True;
        pmRec.blng__AutoPay__c = True;
        pmRec.Card_Number__c = '5555555555554444';
        pmRec.blng__Nameoncard__c = 'Jm';
        pmRec.blng__CVV__c = '22222';
        pmRec.blng__CardExpirationYear__c = '2030';
        pmRec.blng__CardExpirationMonth__c = '10';
        pmRec.blng__CardType__c = 'MasterCard';
        //pmRec.blng__PaymentGateway__c = objPG.Id;
        insert pmRec;
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> lstCon =  DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
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
        lstProd[0].ProductCode = '11006';
        lstProd[0].Business_Unit__c = 'Martindale-Ngage';
        lstProd[0].Family ='Ngage';
        
        update lstProd;
        
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
     Cls_UtilTestClass util = new Cls_UtilTestClass();

        List<Account> acc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        

        List<Account> accIB = DataFactory.createAccount('Test Acc IB', accRecordTypeIdParent, 1);
        acc[0].ParentID = accIB[0].ID;
    	Update acc;       
        Contact con = util.getContact(acc[0].Id);
        Opportunity opp = util.getOpportunity(acc[0].Id , con.Id);
         opp.Name =   opp.Name+' '+'Mid-Term';
         opp.CloseDate = system.today().addDays(30);
         update opp;
        
         List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
         SBQQ__Quote__c objQuote = new SBQQ__Quote__c();
            objQuote.SBQQ__Account__c = acc[0].id;
            objQuote.SBQQ__PricebookId__c = Test.getStandardPricebookId();
            objQuote.RecordtypeId = quoteRecordTypeId; 
            objQuote.SBQQ__Opportunity2__c = opp.Id;
            objQuote.SBQQ__StartDate__c = system.today();
            objQuote.SBQQ__EndDate__c = system.today().adddays(30);
            objQuote.SBQQ__SubscriptionTerm__c = 12;
            objQuote.SBQQ__Primary__c = True;
            //objQuote.SBQQ__Status__c = 'Approved';
            objQuote.SBQQ__ExpirationDate__c = system.today().adddays(30);
            objQuote.SBQQ__BillingFrequency__c = 'Monthly';  
            lstQuote.add(objQuote);
            insert lstQuote;
       /* SBQQ__Quote__c quote=new SBQQ__Quote__c();
        quote.Marketing_Contact__c=con.id;
        quote.Billing_Contact__c=con.id;
        quote.SBQQ__PrimaryContact__c=con.id;
        quote.SBQQ__Account__c=acc[0].id;
        quote.SBQQ__Opportunity2__c=opp.id;
        quote.SBQQ__StartDate__c=system.today();
        quote.SBQQ__SubscriptionTerm__c = 12;
         quote.SBQQ__EndDate__c = system.today().addDays(30);
       quote.SBQQ__Primary__c = true;
        
        
            List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
            lstQuote.add(quote);
            insert lstQuote;*/
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        
        test.startTest();
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        
        Contract objContract = DataFactory.createContract(lstAcc[0], lstOpp[0]);
        SBQQ__Subscription__c objSub = DataFactory.createSubscription(lstAcc[0], objContract, lstProd[0], objQLI);        
        
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        blng__LegalEntity__c legalEntity = new blng__LegalEntity__c();
        legalEntity.Name = 'Test';
        legalEntity.blng__Active__c = TRUE;
        Insert legalEntity;
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = lstAcc[0].id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.Type = 'Amendment';
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
        objOI.ServiceDate = system.today()+50;
        objOI.SBQQ__DefaultSubscriptionTerm__c = 12;
        //objOI.Status = Constant.ORDER_STATUS_PAUSE;
        objOI.Attribute_Relationship__c = objAR.id;
        objOI.SBQQ__Subscription__c  = objSub.id;
        objOI.SIN__c = '1234';
        objOI.SBQQ__Contract__c = objContract.Id;
        objOI.blng__LegalEntity__c = legalEntity.Id;
        insert objOI;        
         
         Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2()); 
         Database.executeBatch(new Batch_MH_Ngage_Association(),1);
         Test.stopTest();
 
     }   
    
     @isTest()  
     public static void testUnitMethod3(){
       	 //CASE 1 : Create Ngage Account and transfer all cons and pms. (If MH Acc has Ngage sub)
         DataFactory.loadCustomSettings();
        
           blng__PaymentGateway__c objPG = new blng__PaymentGateway__c();
        objPG.Name = 'Gateway for Legal Cases - Sandbox';
        objPG.blng__Active__c = true;
        objPG.blng__Default__c = true;
        objPG.blng__GatewayType__c = 'AuthorizeDotNet';
        objPG.TestMode__c = true;
        objPG.adnblng__APILoginId__c = 'Test';
        objPG.adnblng__APITransactionKey__c = 'Test';
        objPG.Endpoint_URL__c = 'https://apitest.authorize.net/xml/v1/request.api';
        insert objPG;
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
         
       
        
         Id accRecordTypeIdParent = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        List<Account> lstAccIB = DataFactory.createAccount('Test Acc IB', accRecordTypeIdParent, 1);
        lstAcc[0].ParentID = lstAccIB[0].ID;
    	Update lstAcc;
         
         blng__PaymentMethod__c pmRec = new blng__PaymentMethod__c();
        pmRec.blng__Account__c = lstAcc[0].Id;
        pmRec.blng__PaymentType__c = 'Credit Card';
        pmRec.blng__Active__c = True;
        pmRec.blng__AutoPay__c = True;
        pmRec.Card_Number__c = '5555555555554444';
        pmRec.blng__Nameoncard__c = 'Jm';
        pmRec.blng__CVV__c = '22222';
        pmRec.blng__CardExpirationYear__c = '2030';
        pmRec.blng__CardExpirationMonth__c = '10';
        pmRec.blng__CardType__c = 'MasterCard';
        //pmRec.blng__PaymentGateway__c = objPG.Id;
        insert pmRec;
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> lstCon =  DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
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
        lstProd[0].ProductCode = '11006';
        lstProd[0].Business_Unit__c = 'Martindale-Ngage';
        lstProd[0].Family ='Ngage';
        
        update lstProd;
        
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
     Cls_UtilTestClass util = new Cls_UtilTestClass();

        List<Account> acc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
 List<Account> acc2 = DataFactory.createAccount('Test Acc1', accRecordTypeId, 1);
        
        acc.addAll(acc2);
         
        List<Account> accIB = DataFactory.createAccount('Test Acc IB', accRecordTypeIdParent, 1);
        acc[0].ParentID = accIB[0].ID;
         acc[1].ParentID = accIB[0].ID;
    	Update acc;       
        Contact con = util.getContact(acc[0].Id);
        Opportunity opp = util.getOpportunity(acc[0].Id , con.Id);
         opp.Name =   opp.Name+' '+'Mid-Term';
         opp.CloseDate = system.today().addDays(30);
         update opp;
        
         List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
         SBQQ__Quote__c objQuote = new SBQQ__Quote__c();
            objQuote.SBQQ__Account__c = acc[0].id;
            objQuote.SBQQ__PricebookId__c = Test.getStandardPricebookId();
            objQuote.RecordtypeId = quoteRecordTypeId; 
            objQuote.SBQQ__Opportunity2__c = opp.Id;
            objQuote.SBQQ__StartDate__c = system.today();
            objQuote.SBQQ__EndDate__c = system.today().adddays(30);
            objQuote.SBQQ__SubscriptionTerm__c = 12;
            objQuote.SBQQ__Primary__c = True;
            //objQuote.SBQQ__Status__c = 'Approved';
            objQuote.SBQQ__ExpirationDate__c = system.today().adddays(30);
            objQuote.SBQQ__BillingFrequency__c = 'Monthly';  
            lstQuote.add(objQuote);
            insert lstQuote;
       /* SBQQ__Quote__c quote=new SBQQ__Quote__c();
        quote.Marketing_Contact__c=con.id;
        quote.Billing_Contact__c=con.id;
        quote.SBQQ__PrimaryContact__c=con.id;
        quote.SBQQ__Account__c=acc[0].id;
        quote.SBQQ__Opportunity2__c=opp.id;
        quote.SBQQ__StartDate__c=system.today();
        quote.SBQQ__SubscriptionTerm__c = 12;
         quote.SBQQ__EndDate__c = system.today().addDays(30);
       quote.SBQQ__Primary__c = true;
        
        
            List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
            lstQuote.add(quote);
            insert lstQuote;*/
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        
        test.startTest();
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        
        Contract objContract = DataFactory.createContract(lstAcc[0], lstOpp[0]);
        SBQQ__Subscription__c objSub = DataFactory.createSubscription(lstAcc[0], objContract, lstProd[0], objQLI);        
        
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        blng__LegalEntity__c legalEntity = new blng__LegalEntity__c();
        legalEntity.Name = 'Test';
        legalEntity.blng__Active__c = TRUE;
        Insert legalEntity;
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = lstAcc[0].id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.Type = 'Amendment';
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
        objOI.ServiceDate = system.today()+50;
        objOI.SBQQ__DefaultSubscriptionTerm__c = 12;
        //objOI.Status = Constant.ORDER_STATUS_PAUSE;
        objOI.Attribute_Relationship__c = objAR.id;
        objOI.SBQQ__Subscription__c  = objSub.id;
        objOI.SIN__c = '1234';
        objOI.SBQQ__Contract__c = objContract.Id;
        objOI.blng__LegalEntity__c = legalEntity.Id;
        insert objOI;        
         
         Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2()); 
         Database.executeBatch(new Batch_MH_Ngage_Association(),1);
         Test.stopTest();
 
     }   
      
  /*   @isTest()
     public static void testUnitMethod3(){
     	
        //CASE 2 : For already created Ngage Accs , Transfer Pms 
        
        Id accRecordTypeIdParent = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        List<Account> lstAccIB = [Select ID from Account where RecordTypeID=:accRecordTypeIdParent];
    	
        Id accRecordTypeIdNG = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId();
 
        Account acNG = new Account();
        acNG.Name = 'Test Rach';
        acNG.BillingStreet = '7 St. John Street';acNG.BillingCity =  'Monticello';  acNG.BillingState =  'NY'; acNG.BillingCountry =  'USA'; acNG.BillingPostalCode =  '12701';
        acNG.RecordTypeId = accRecordTypeIdNG;
        acNG.ShippingStreet = '7 St. John Street';acNG.ShippingCity =  'Monticello';acNG.ShippingState =  'NY';acNG.ShippingCountry =  'USA';acNG.ShippingPostalCode =  '12701';
    	acNG.ParentID = lstAccIB[0].ID;
        
        Test.startTest();
        Insert acNG;
         Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2()); 
        Database.executeBatch(new Batch_MH_Ngage_Association(),1);
        Test.stopTest();
         
 
     }   */ 
    

}
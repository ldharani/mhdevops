/***********************************************************************************************************************
 * @author - CK
 * @date - 15 Sep 2022
 * @description - Test class for BatchToExpireOrdersOfLastMonth, BatchToExpireContractsOfLastMonth, BatchToExpireOrderProductsXMLIntegration
 * JIRA - MHBS-5341

Change History
************************************************************************************************************************

************************************************************************************************************************/
@isTest
public class BatchToExpireOrdersContracts_Test {
    @testSetup static void setup() {
        // Load Custom settings
        DataFactory.loadCustomSettings();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Avalara_Address_Validation_Error__c = '';
        lstAcc[0].Contact_Name__c = 'Test Con';
        update lstAcc[0];
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        //List<Contact> conList = DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact(FirstName= 'test', LastName = 'Test Con Mark Beamish');
        con.AccountId = lstAcc[0].Id;
        con.Email = 'test@abc.com';
        con.Phone = '123456789';
        con.RecordTypeId = conRecordTypeId;
        con.Website__c = 'www.test.com';
        con.Professional_ID__c = '987654321';
        conList.add(con);
        insert conList;
        
        // Create Test Opportunity
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Intake Opportunity').getRecordTypeId();
        List<Opportunity> lstOpp = DataFactory.createOpportunity('Test Opp', lstAcc[0], oppRecordTypeId, 2);
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // Create Billing Rule
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        blng__BillingRule__c objBR2 = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        blng__RevenueRecognitionRule__c objRR2 = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
        blng__TaxRule__c objTR2 = DataFactory.createTaxRule();
        
        // Create Test Product
        List<Product2> lstProd = DataFactory.createProduct('Test Product', objBR, objRR, objTR, 1);
        system.debug('lstProd '+lstProd);
        List<Product2> lstProd2 = DataFactory.createProduct('Test Product 2', objBR2, objRR2, objTR2, 1);
        system.debug('lstProd2 '+lstProd2);
        //List<Product2> prodLst = new List<Product2>();
        //lstProd[0].ProductCode = '11014';
        //lstProd2[0].ProductCode = '11017';
        List<Product2> prodLst = new List<Product2>();
        Product2 prod1 = new Product2(Id = lstProd[0].Id, ProductCode = '11014');
        Product2 prod2 = new Product2(Id = lstProd2[0].Id, ProductCode = '11017');
        prodLst.add(prod1);
        prodLst.add(prod2);
        update prodLst;
        system.debug('prodLst '+prodLst);
        system.debug('prod1 code '+lstProd[0].ProductCode);
        system.debug('prod2 code '+lstProd2[0].ProductCode);
        
        for(Product2 prod : prodLst){
            system.debug('Prod code Prod '+prod.Id+' '+prod.ProductCode);
        }
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        
        // Create Attribute_Lines__c - Practice Area
        Attribute_Lines__c objAL = DataFactory.createAttributeLines(objAR, 'Practice Area', 'String', 'SSDI', '');
        
        // Create Attribute_Lines__c - Service State
        Attribute_Lines__c objAL1 = DataFactory.createAttributeLines(objAR, 'Service State', 'Picklist', '', 'Connecticut;Delaware;');
        
        // Create Attribute_Lines__c - Practice Area
        Attribute_Lines__c objAL2 = DataFactory.createAttributeLines(objAR, 'Service County', 'Number', '', 'Connecticut---Tolland;Delaware---Sussex;Delaware---New Castle;Delaware---Kent');
        
        
        // Create Test Attribute Configuration - Practice Area
        Attribute_Configuration__c objAC1 = DataFactory.createAtrConfiguration('Practice Area', 1, 'Text');
        ProductAttribute__c objPA1 = DataFactory.createProductAttribute(objAC1, lstProd[0], 'String');
        ProductAttribute__c objPA5 = DataFactory.createProductAttribute(objAC1, lstProd2[0], 'String');
        
        
        // Create Test Attribute Configuration - Service State
        Attribute_Configuration__c objAC = DataFactory.createAtrConfiguration('Service State', 4, 'Picklist');
        ProductAttribute__c objPA = DataFactory.createProductAttribute(objAC, lstProd[0], 'Multi-Picklist');
        ProductAttribute__c objPA3 = DataFactory.createProductAttribute(objAC, lstProd2[0], 'Multi-Picklist');
        
        
        // Create Test Attribute Configuration - Service County
        Attribute_Configuration__c objAC2 = DataFactory.createAtrConfiguration('Service County', 6, 'Text');
        ProductAttribute__c objPA2 = DataFactory.createProductAttribute(objAC2, lstProd[0], 'Multi-Picklist');
        ProductAttribute__c objPA4 = DataFactory.createProductAttribute(objAC2, lstProd2[0], 'Multi-Picklist');
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry(lstProd[0], 100);
        PricebookEntry objPBEntry2 = DataFactory.createPricebookEntry(lstProd2[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        List<SBQQ__Quote__c> lstQuote2 = DataFactory.createQuote(lstAcc[0], lstOpp[1], quoteRecordTypeId, 1);
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        
        test.startTest();
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        
        //Contract objContract = DataFactory.createContract(lstAcc[0], lstOpp[0]);
        //Creatin contract
        Id contractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('M-A Intake Contract').getRecordTypeId();
         
        Contract objContract = new Contract();
        objContract.AccountId = lstAcc[0].Id;
        objContract.SBQQ__Opportunity__c = lstOpp[0].Id;
        objContract.Status = 'Draft';
        objContract.StartDate = Date.today().addMonths(-12);
        objContract.ContractTerm = 12;
        objContract.RecordtypeId = contractRecordTypeId;
        insert objContract;
        system.debug('Contract end date '+objContract.EndDate);
        
        objContract.Status = 'Activated';
        Update objContract;
        
        
        //SBQQ__Subscription__c objSub = DataFactory.createSubscription(lstAcc[0], objContract, lstProd[0], objQLI);        
        SBQQ__Subscription__c objSubs = new SBQQ__Subscription__c();
        objSubs.SBQQ__Account__c = lstAcc[0].Id;
        objSubs.SBQQ__Contract__c = objContract.Id; 
        objSubs.SBQQ__Product__c = lstProd[0].Id; 
        objSubs.SBQQ__Quantity__c = 1;
        objSubs.SBQQ__NetPrice__c = 100;
        //objSubs.SBQQ__SubscriptionEndDate__c = Date.today().addMonths(-1);
        objSubs.SBQQ__SubscriptionStartDate__c = Date.today().addMonths(-12);
        objSubs.SBQQ__QuoteLine__c = objQLI.Id;
        objSubs.Status__c = 'Active';
        //objSubs.SBQQ__EndDate__c = Date.today().addMonths(-1);
        
        insert objSubs;
        system.debug('Sub endd date '+objSubs.SBQQ__SubscriptionEndDate__c);
        system.debug('Sub end date '+objSubs.SBQQ__EndDate__c);
        
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        blng__LegalEntity__c legalEntity = new blng__LegalEntity__c();
        legalEntity.Name = 'Test';
        legalEntity.blng__Active__c = TRUE;
        Insert legalEntity;
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = Date.today().addMonths(-13);
        objOrder.EndDate = Date.today().addMonths(-1);
        objOrder.AccountId = lstAcc[0].id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.Type = 'Amendment';
        insert objOrder;
        
        List<OrderItem> oItemToInsert = new List<OrderItem>();
        OrderItem objOI = new OrderItem();
        objOI.OrderId = objOrder.id;
        objOI.Quantity = 24;
        objOI.UnitPrice = 240;
        objOI.Product2id = prodLst[0].id;
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
        objOI.SBQQ__Subscription__c  = objSubs.id;
        objOI.SIN__c = '1234';
        objOI.SBQQ__Contract__c = objContract.Id;
        objOI.blng__LegalEntity__c = legalEntity.Id;
        objOI.Status__c = 'Active';
        objOI.ServiceDate = Date.today().addMonths(-13);
        objOI.EndDate = Date.today().addMonths(-1);
        objOI.Contact__c = conList[0].id;
        objOI.SBQQ__TerminatedDate__c = system.today();
        objOI.Fulfillment_date__c = Date.today().addMonths(-2);
        oItemToInsert.add(objOI);
        
        OrderItem objOI2 = new OrderItem();
        objOI2.OrderId = objOrder.id;
        objOI2.Quantity = 24;
        objOI2.UnitPrice = 240;
        objOI2.Product2id = prodLst[1].id;
        objOI2.PricebookEntryId=objPBEntry2.id;
        objOI2.SBQQ__ChargeType__c = 'Recurring';
        objOI2.SBQQ__BillingFrequency__c = 'Monthly';
        objOI2.SBQQ__BillingType__c = 'Arrears';
        objOI2.blng__BillingRule__c = objBR2.Id;
        objOI2.blng__RevenueRecognitionRule__c = objRR2.Id;
        objOI2.SBQQ__Activated__c = TRUE;
        objOI2.blng__TaxRule__c = objTR2.Id;
        objOI2.ServiceDate = system.today()+50;
        objOI2.SBQQ__DefaultSubscriptionTerm__c = 12;
        //objOI2.Status = Constant.ORDER_STATUS_PAUSE;
        objOI2.Attribute_Relationship__c = objAR.id;
        objOI2.SBQQ__Subscription__c  = objSubs.id;
        objOI2.SIN__c = '1234';
        objOI2.SBQQ__Contract__c = objContract.Id;
        objOI2.blng__LegalEntity__c = legalEntity.Id;
        objOI2.Status__c = 'Active';
        objOI2.ServiceDate = Date.today().addMonths(-13);
        objOI2.EndDate = Date.today().addMonths(-1);
        objOI2.Contact__c = conList[0].id;
        objOI2.SBQQ__TerminatedDate__c = system.today();
        objOI2.Fulfillment_date__c = Date.today().addMonths(-2);
        oItemToInsert.add(objOI2);
        
        insert oItemToInsert;
        
        for(OrderItem oItem : [SELECT Id,Product2.ProductCode from OrderItem]){
            system.debug('Prod code from setup '+oItem.Product2+' '+oItem.Product2.ProductCode);
        }
        
        objSubs.SBQQ__OrderProduct__c = objOI.Id;
        update objSubs;
        
        lstOpp[1].SBQQ__RenewedContract__c=objContract.Id;
        update lstOpp[1];
        
        Month_end_expiration_email__c em = new Month_end_expiration_email__c();
        em.Name = 'test';
        em.Email__c = 'test@test.com';
        insert em;
    }
    public static testMethod void testUnitMethod1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200));
        BatchToExpireOrdersOfLastMonth batchOrder = new BatchToExpireOrdersOfLastMonth();
        Database.executeBatch(batchOrder);
    }
    public static testMethod void testUnitMethod2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200));
        List<Id> oItemIds = new List<Id>();
        for(OrderItem oItem : [SELECT Id,Product2.ProductCode from OrderItem]){ 
            system.debug('Prod code '+oItem.Product2+' '+oItem.Product2.ProductCode);
        }
        Id oItemId = [SELECT Id from OrderItem where Product2.ProductCode=:'11017' limit 1 ].Id;
		oItemIds.add(oItemId);
        BatchToExpireOrdersOfLastMonth batchOrder = new BatchToExpireOrdersOfLastMonth(oItemIds);
        Database.executeBatch(batchOrder);
    }
    public static testMethod void orderUpdateFailure(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(500));
        BatchToExpireOrdersOfLastMonth batchOrder = new BatchToExpireOrdersOfLastMonth(true,false);
        Database.executeBatch(batchOrder);
    }
    public static testMethod void orderItemUpdateFailure(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200));
        BatchToExpireOrdersOfLastMonth batchOrderItem = new BatchToExpireOrdersOfLastMonth(false,true);
        Database.executeBatch(batchOrderItem);
    }
    public static testMethod void contractUpdateFailure(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200));
        BatchToExpireContractsOfLastMonth batchContract = new BatchToExpireContractsOfLastMonth(false,true,false);
        Database.executeBatch(batchContract);
    }
    public static testMethod void subscriptionUpdateFailure(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200));
        BatchToExpireContractsOfLastMonth batchSubscription = new BatchToExpireContractsOfLastMonth(true,false,true);
        Database.executeBatch(batchSubscription);
    }
    public static testMethod void testUnitMethod3(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200));
        List<Id> subIds = new List<Id>();
        Id subId = [SELECT Id,SBQQ__EndDate__c,Status__c from SBQQ__Subscription__c limit 1].Id;
        for(SBQQ__Subscription__c sub : [SELECT Id,SBQQ__EndDate__c,Status__c from SBQQ__Subscription__c]){ 
            system.debug('sub end date '+sub.SBQQ__EndDate__c+' '+sub.Status__c);
        }
		subIds.add(subId);
        BatchToExpireContractsOfLastMonth batchContract = new BatchToExpireContractsOfLastMonth(subIds);
        Database.executeBatch(batchContract);
    }
    public static testMethod void testUnitMethod4(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200));
        BatchToExpireContractsOfLastMonth batchContract = new BatchToExpireContractsOfLastMonth();
        Database.executeBatch(batchContract);
    }
}
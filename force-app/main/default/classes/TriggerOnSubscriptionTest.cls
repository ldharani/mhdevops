/*Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHMAC-52     CK            15/03/2022   Jeevan Babu    <T01>    MAC2.1 Custom Enddate & Terms update. Test covers Trigger_QuoteLine_Handler, Trigger_QuoteLine_Helper
************************************************************************************************************************/

@isTest
public class TriggerOnSubscriptionTest{
    @testSetup static void setup() {
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
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
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
        
        test.startTest();
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        
        Contract objContract = DataFactory.createContract(lstAcc[0], lstOpp[0]);
        SBQQ__Subscription__c objSub = DataFactory.createSubscription(lstAcc[0], objContract, lstProd[0], objQLI);        
        
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('MH Order').getRecordTypeId();
        
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
        
        
        Database.executeBatch(new CPQ_BatchSubLinesUpdate (), 10);
        CPQ_BatchSubLinesUpdate m = new CPQ_BatchSubLinesUpdate();
        Database.executeBatch(m);
        subscriptionHandler sub = new subscriptionHandler();
        sub.FkMethod();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Test.stopTest();
    }
    public static testMethod void testUnitMethod1(){
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub =[SELECT id,SIN__c,SBQQ__Contract__c FROM SBQQ__Subscription__c limit 1];
        subList.add(sub);
        sub.Status__c  = 'Cancelled';
        Update sub;
        test.startTest();
        subscriptionHandler.handleUpsellPackagesNew(subList);
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        test.stopTest();
    }
    //<T01> Starts
    public static testMethod void testUnitMethod2(){
        Id MAsubscriptionRecordTypeId = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('M-A Subscriptions').getRecordTypeId();
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        Map<Id, SBQQ__Subscription__c> subOldMap = new Map<Id, SBQQ__Subscription__c>();
        Map<Id, SBQQ__Subscription__c> subNewMap = new Map<Id, SBQQ__Subscription__c>();
        Contract con = [SELECT id from Contract limit 1];
        Account acc = [SELECT id from Account limit 1];
        SBQQ__QuoteLine__c ql = [SELECT id from SBQQ__QuoteLine__c limit 1];
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Account__c = acc.Id;
        sub.SBQQ__NetPrice__c = 100;
        sub.SBQQ__SubscriptionEndDate__c = Date.today().addYears(1);
        sub.SBQQ__QuoteLine__c = ql.Id;
        sub.SBQQ__Quantity__c = 1;
        sub.SBQQ__Contract__c = con.id;
        sub.recordtypeId = MAsubscriptionRecordTypeId;
        sub.End_date__c = Date.newInstance(system.today().year()+2, system.today().month(), system.today().Day());
        sub.Status__c = 'Active';
        Insert sub;
        
        subList.add(sub);
        subOldMap.put(sub.id, sub);
        
        sub.Status__c = 'Truncated';
        update sub;
        
        subNewMap.put(sub.id, sub);
        
        test.startTest();
        subscriptionHelper subhelper = new subscriptionHelper();
        subhelper.updateContractStatus(subNewMap,subOldMap);
        subhelper.updateSubStatus(subList);
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        test.stopTest();
    }//<T01> Ends
}
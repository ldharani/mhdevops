@isTest
public class orderhelper_Test {
    
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
        objOrder.Status__c = 'Active';
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
    }
    
    static testMethod void testMethodA(){
        Contact contest = [SELECT ID FROM Contact WHERE Name = 'TestA'];
        // Create a test record
        OrderItem testRecord = [SELECT OrderId,Quantity,Status__c,Product2id,PricebookEntryId,Product_Code_value__c,Attribute_Relationship__c FROM OrderItem limit 1];
        
        // Retrieve the record with its original values
        OrderItem oldTestRecord = [SELECT OrderId,Status__c,Quantity,Product2id,PricebookEntryId,Product_Code_value__c,Attribute_Relationship__c FROM OrderItem WHERE Id = :testRecord.Id];
        
        // Simulate an update to the record
        testRecord.Quantity = 0;
        //testRecord.contact__c = contest.Id;
        update testRecord;
        
        // Retrieve the updated record
        OrderItem newTestRecord = [SELECT OrderId,Quantity,Status__c,Product2id,PricebookEntryId,Product_Code_value__c,Attribute_Relationship__c FROM OrderItem WHERE Id = :testRecord.Id];
        
        
        Map<Id,OrderItem> oldMap = new Map<Id,OrderItem>();
        oldMap.put(oldTestRecord.Id,oldTestRecord);
        
        List<OrderItem> orderItemLst = new List<OrderItem>();
        orderItemLst.add(newTestRecord);
        
        //System.debug('yvyvyvyvyvd ' + orderItemLst);
        //System.debug('yvyvyvyvyvd ' + oldMap);
        orderhelper.orderXMLhelper(orderItemLst,oldMap );
    }
    
   }
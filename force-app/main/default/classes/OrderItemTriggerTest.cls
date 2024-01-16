/**@@
#APEX CLASS NAME       :   OrderItemTriggerTest
#CREATED BY            :   Serge Kandukuri
#DESCRIPTION           :   This is test class for OrderItemTrigger (Apex Trigger) and Trigger_OrderItem_Handler and Trigger_OrderItem_Helper (Apex Class).
@@*
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-8916    CK            30/03/2023   Kavitha VS      <T01>  Replacing AttributeValues__c with newly created field Attribute_Values__c due to Formula field limitation of pointing to a long text area
*************************************************************************************************************************/
@isTest
global class OrderItemTriggerTest {
    
    /**@@
#DESCRIPTION     : Creating test records
#Paramaters      : None
@@**/
    @testSetup static void setup() {
        
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
        
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
        
        // Create Test Quote Line
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry,quoteLineRecordTypeId, 1);
        
        // Create Test Opportunity Line Item
       // DataFactory.createOpportunityLineItem(lstOpp[0], lstProd[0], objPBEntry, objQLI);
        lstQuote[0].SBQQ__Ordered__c = TRUE;
        //update lstQuote;
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('MH Order').getRecordTypeId();
        
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
        
         //Test.setMock(HttpCalloutMock.class, new OrderItemMockImpl());
         Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
         

        
        
    }
    /**@@
#DESCRIPTION     : This is a test method used to cover add Contract functionality.
#Paramaters      : None
@@**/
    public static testMethod void testUnitMethod1(){
        //Test.setMock(HttpCalloutMock.class, new OrderItemMockImpl());
        //Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        List<Id> ordIds = new List<Id>();
        Order objOrder = [SELECT Id,accountid  FROM Order Limit 1];
        ordIds.add(objOrder.Id);
        system.debug('==ordIds=='+ordIds);
        List<Product2> lstProd= [SELECT Id  FROM Product2 Limit 1];
        PricebookEntry objPBEntry =  [SELECT Id  FROM PricebookEntry Limit 1];
        blng__BillingRule__c objBR =[SELECT Id  FROM blng__BillingRule__c Limit 1];
        blng__RevenueRecognitionRule__c   objRR=[SELECT Id  FROM blng__RevenueRecognitionRule__c Limit 1];
        blng__TaxRule__c     objTR= [SELECT Id  FROM blng__TaxRule__c Limit 1];           
         Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.Attribute_Values__c = 'Practice Area:SSDI,Service County:,';//<T01>
        insert objAR;
        system.debug('==objAR=='+objAR);
         // Create Attribute_Lines__c - Practice Area
         Attribute_Lines__c objAL = DataFactory.createAttributeLines(objAR, 'Practice Area', 'String', 'SSDI', '');

       // Attribute_Lines__c objAL2 = DataFactory.createAttributeLines(objAR, 'Service County', 'Multi-Picklist', '', 'Connecticut---Tolland;Delaware---Sussex;Delaware---New Castle;Delaware---Kent');
        
        //system.assert(od.id!=null );
        Test.startTest();
        
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
        //objOI.Status__c = Constant.ORDER_STATUS_PAUSE;
        objOI.Attribute_Relationship__c = objAR.id;
        objOI.Fulfillment_date__c = Date.today();
        
        insert objOI;
        system.debug('==objOI=='+objOI);
        
       /* blng__UsageSummary__c objUSummary = new blng__UsageSummary__c();
        objUSummary.blng__MatchingId__c = '1234';
        objUSummary.blng__MatchingAttribute__c = 'Quarterly';
        objUSummary.blng__UnitOfMeasure__c = 'Hours';
        objUSummary.blng__Account__c = objOrder.accountid;
        objUSummary.blng__Order__c = objOrder.Id; 
        objUSummary.blng__OrderProduct__c = objOI.Id;
        objUSummary.blng__TotalQuantity__c = 1;
        objUSummary.blng__SummaryStartDate__c = objOI.ServiceDate;
        objUSummary.blng__SummaryEndDate__c = objOI.ServiceDate.adddays(22);
        
        insert objUSummary;
        system.debug('==objUSummary=='+objUSummary);  */      
        
        OrderItem objOI1 = new OrderItem();
        objOI1.OrderId = objOrder.id;
        objOI1.Quantity = 24;
        objOI1.UnitPrice = 250;
        objOI1.Product2id = lstProd[0].id;
        objOI1.PricebookEntryId=objPBEntry.id;
        objOI1.SBQQ__ChargeType__c = 'Recurring';
        objOI1.SBQQ__BillingFrequency__c = 'Monthly';
        objOI1.SBQQ__BillingType__c = 'Arrears';
        objOI1.blng__BillingRule__c = objBR.Id;
        objOI1.blng__RevenueRecognitionRule__c = objRR.Id;
        objOI1.SBQQ__Activated__c = TRUE;
        objOI1.blng__TaxRule__c = objTR.Id;
        objOI1.ServiceDate = system.today()+50;
        objOI1.SBQQ__DefaultSubscriptionTerm__c = 12;
        //objOI1.Status__c = Constant.ORDER_STATUS_ACTIVE;
         objOI1.Attribute_Relationship__c = objAR.id;
        objOI1.Fulfillment_date__c = Date.today(); 
        //objOI1.Status__c = 'Cancelled';
        insert objOI1;
        //system.debug('==objUSummary=='+objUSummary);
        Map<Id,OrderItem> oldMap = new Map<Id,OrderItem>();
        oldMap.put(objOI1.id,objOI1);
        system.debug('==oldMap=='+oldMap);


        OrderItem objOIAB = new OrderItem();
        objOIAB.OrderId = objOrder.id;
        objOIAB.Quantity = -1;
        objOIAB.UnitPrice = 240;
        objOIAB.Product2id = lstProd[0].id;
        objOIAB.PricebookEntryId=objPBEntry.id;
        objOIAB.SBQQ__ChargeType__c = 'Recurring';
        objOIAB.SBQQ__BillingFrequency__c = 'Monthly';
        objOIAB.SBQQ__BillingType__c = 'Arrears';
        objOIAB.blng__BillingRule__c = objBR.Id;
        objOIAB.blng__RevenueRecognitionRule__c = objRR.Id;
        objOIAB.SBQQ__Activated__c = TRUE;
        objOIAB.blng__TaxRule__c = objTR.Id;
        objOIAB.ServiceDate = system.today()+50;
        objOIAB.SBQQ__DefaultSubscriptionTerm__c = 12;
        //objOI.Status__c = Constant.ORDER_STATUS_PAUSE;
        objOIAB.Attribute_Relationship__c = objAR.id;
        //objOIAB.Fulfillment_date__c = Date.today();
        objOIAB.SBQQ__ContractAction__c = 'Cancel';
        objOIAB.SBQQ__TerminatedDate__c = System.today();
        objOIAB.SBQQ__RevisedOrderProduct__c = objOI1.Id;
        
        List<OrderItem> ordPro = new List<OrderItem>();
        ordPro.add(objOI1);
        List<OrderItem> ordProAB = new List<OrderItem>();
        ordPro.add(objOIAB);
        system.debug('==ordPro=='+ordPro);
        //Trigger_OrderItem_Helper.setOrderStatusasCancelled(ordIds);
        Trigger_OrderItem_Helper.updateAssetStatus(ordPro);
        Trigger_OrderItem_Helper.updateInvoiceGroupId(ordPro);
        //Trigger_OrderItem_Handler.afterUpdateHandler(ordPro,oldMap); //Commented <Lakshmi>
       Trigger_OrderItem_Helper.updateCancelOP(ordProAB);
        //objOIAB.isRebaseEGorEG2EG__c = true;
        //Trigger_OrderItem_Handler.afterUpdateHandler(ordPro, oldMap);
      //  Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        test.stopTest();
    }
    public static testMethod void testUnitMethod2(){
    	List<Id> ordIds = new List<Id>();
        Order objOrder = [SELECT Id,accountid  FROM Order Limit 1];
        ordIds.add(objOrder.Id);
        system.debug('==ordIds=='+ordIds);
        List<Product2> lstProd= [SELECT Id  FROM Product2 Limit 1];
        PricebookEntry objPBEntry =  [SELECT Id  FROM PricebookEntry Limit 1];
        blng__BillingRule__c objBR =[SELECT Id  FROM blng__BillingRule__c Limit 1];
        blng__RevenueRecognitionRule__c   objRR=[SELECT Id  FROM blng__RevenueRecognitionRule__c Limit 1];
        blng__TaxRule__c     objTR= [SELECT Id  FROM blng__TaxRule__c Limit 1];           
         Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.Attribute_Values__c = 'Practice Area:SSDI,Service County:,';//<T01>
        insert objAR;
        system.debug('==objAR=='+objAR);
         // Create Attribute_Lines__c - Practice Area
         Attribute_Lines__c objAL = DataFactory.createAttributeLines(objAR, 'Practice Area', 'String', 'SSDI', '');

        //Attribute_Lines__c objAL2 = DataFactory.createAttributeLines(objAR, 'Service County', 'Multi-Picklist', '', 'Connecticut---Tolland;Delaware---Sussex;Delaware---New Castle;Delaware---Kent');
        
        test.startTest();
        
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
        //objOI.Status__c = Constant.ORDER_STATUS_PAUSE;
        objOI.Attribute_Relationship__c = objAR.id;
        objOI.Fulfillment_date__c = Date.today();
        insert objOI;
        
        OrderItem objOI1 = new OrderItem();
        objOI1.OrderId = objOrder.id;
        objOI1.Quantity = 24;
        objOI1.UnitPrice = 250;
        objOI1.Product2id = lstProd[0].id;
        objOI1.PricebookEntryId=objPBEntry.id;
        objOI1.SBQQ__ChargeType__c = 'Recurring';
        objOI1.SBQQ__BillingFrequency__c = 'Monthly';
        objOI1.SBQQ__BillingType__c = 'Arrears';
        objOI1.blng__BillingRule__c = objBR.Id;
        objOI1.blng__RevenueRecognitionRule__c = objRR.Id;
        objOI1.SBQQ__Activated__c = TRUE;
        objOI1.blng__TaxRule__c = objTR.Id;
        objOI1.ServiceDate = system.today()+50;
        objOI1.SBQQ__DefaultSubscriptionTerm__c = 12;
        //objOI1.Status__c = Constant.ORDER_STATUS_ACTIVE;
         objOI1.Attribute_Relationship__c = objAR.id;
        objOI1.Fulfillment_date__c = Date.today(); 
        objOI1.Status__c = 'Active';
        insert objOI1;
        
        Map<Id,OrderItem> oldMap = new Map<Id,OrderItem>();
        oldMap.put(objOI1.id,objOI1);

        OrderItem objOIAB = new OrderItem();
        objOIAB.OrderId = objOrder.id;
        objOIAB.Quantity = -1;
        objOIAB.UnitPrice = 240;
        objOIAB.Product2id = lstProd[0].id;
        objOIAB.PricebookEntryId=objPBEntry.id;
        objOIAB.SBQQ__ChargeType__c = 'Recurring';
        objOIAB.SBQQ__BillingFrequency__c = 'Monthly';
        objOIAB.SBQQ__BillingType__c = 'Arrears';
        objOIAB.blng__BillingRule__c = objBR.Id;
        objOIAB.blng__RevenueRecognitionRule__c = objRR.Id;
        objOIAB.SBQQ__Activated__c = TRUE;
        objOIAB.blng__TaxRule__c = objTR.Id;
        objOIAB.ServiceDate = system.today()+50;
        objOIAB.SBQQ__DefaultSubscriptionTerm__c = 12;
        //objOI.Status__c = Constant.ORDER_STATUS_PAUSE;
        objOIAB.Attribute_Relationship__c = objAR.id;
        //objOIAB.Fulfillment_date__c = Date.today();
        //objOIAB.SBQQ__ContractAction__c = 'Cancel';
        objOIAB.SBQQ__TerminatedDate__c = System.today();
        objOIAB.SBQQ__RevisedOrderProduct__c = objOI1.Id;
        //objOIAB.isRebaseEGorEG2EG__c = true;
        insert objOIAB;
        
        List<OrderItem> ordPro = new List<OrderItem>();
        ordPro.add(objOI1);
        List<OrderItem> ordProAB = new List<OrderItem>();
        ordPro.add(objOIAB);
        
        //Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Trigger_OrderItem_Helper.updateLegalEntity(ordPro);
        test.stopTest();
        
    }
    
     public static testMethod void testUnitMethod3(){
    	List<Id> ordIds = new List<Id>();
        Order objOrder = [SELECT Id,accountid  FROM Order Limit 1];
        ordIds.add(objOrder.Id);
        system.debug('==ordIds=='+ordIds);
        List<Product2> lstProd= [SELECT Id  FROM Product2 Limit 1];
        PricebookEntry objPBEntry =  [SELECT Id  FROM PricebookEntry Limit 1];
        blng__BillingRule__c objBR =[SELECT Id  FROM blng__BillingRule__c Limit 1];
        blng__RevenueRecognitionRule__c   objRR=[SELECT Id  FROM blng__RevenueRecognitionRule__c Limit 1];
        blng__TaxRule__c     objTR= [SELECT Id  FROM blng__TaxRule__c Limit 1];           
         Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.Attribute_Values__c = 'Practice Area:SSDI,Service County:,';//<T01>
        insert objAR;
        system.debug('==objAR=='+objAR);
         // Create Attribute_Lines__c - Practice Area
         Attribute_Lines__c objAL = DataFactory.createAttributeLines(objAR, 'Practice Area', 'String', 'SSDI', '');

        //Attribute_Lines__c objAL2 = DataFactory.createAttributeLines(objAR, 'Service County', 'Multi-Picklist', '', 'Connecticut---Tolland;Delaware---Sussex;Delaware---New Castle;Delaware---Kent');
        
        test.startTest();
        
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
        //objOI.Status__c = Constant.ORDER_STATUS_PAUSE;
        objOI.Attribute_Relationship__c = objAR.id;
        objOI.Fulfillment_date__c = Date.today();
        insert objOI;
        
        OrderItem objOI1 = new OrderItem();
        objOI1.OrderId = objOrder.id;
        objOI1.Quantity = 24;
        objOI1.UnitPrice = 250;
        objOI1.Product2id = lstProd[0].id;
        objOI1.PricebookEntryId=objPBEntry.id;
        objOI1.SBQQ__ChargeType__c = 'Recurring';
        objOI1.SBQQ__BillingFrequency__c = 'Monthly';
        objOI1.SBQQ__BillingType__c = 'Arrears';
        objOI1.blng__BillingRule__c = objBR.Id;
        objOI1.blng__RevenueRecognitionRule__c = objRR.Id;
        objOI1.SBQQ__Activated__c = TRUE;
        objOI1.blng__TaxRule__c = objTR.Id;
        objOI1.ServiceDate = system.today()+50;
        objOI1.SBQQ__DefaultSubscriptionTerm__c = 12;
        //objOI1.Status__c = Constant.ORDER_STATUS_ACTIVE;
         objOI1.Attribute_Relationship__c = objAR.id;
        objOI1.Fulfillment_date__c = Date.today(); 
        objOI1.Status__c = 'Active';
        insert objOI1;
        
        Map<Id,OrderItem> oldMap = new Map<Id,OrderItem>();
        oldMap.put(objOI1.id,objOI1);

        OrderItem objOIAB = new OrderItem();
        objOIAB.OrderId = objOrder.id;
        objOIAB.Quantity = -1;
        objOIAB.UnitPrice = 240;
        objOIAB.Product2id = lstProd[0].id;
        objOIAB.PricebookEntryId=objPBEntry.id;
        objOIAB.SBQQ__ChargeType__c = 'Recurring';
        objOIAB.SBQQ__BillingFrequency__c = 'Monthly';
        objOIAB.SBQQ__BillingType__c = 'Arrears';
        objOIAB.blng__BillingRule__c = objBR.Id;
        objOIAB.blng__RevenueRecognitionRule__c = objRR.Id;
        objOIAB.SBQQ__Activated__c = TRUE;
        objOIAB.blng__TaxRule__c = objTR.Id;
        objOIAB.ServiceDate = system.today()+50;
        objOIAB.SBQQ__DefaultSubscriptionTerm__c = 12;
        //objOI.Status__c = Constant.ORDER_STATUS_PAUSE;
        objOIAB.Attribute_Relationship__c = objAR.id;
        //objOIAB.Fulfillment_date__c = Date.today();
        //objOIAB.SBQQ__ContractAction__c = 'Cancel';
        objOIAB.SBQQ__TerminatedDate__c = System.today();
        objOIAB.SBQQ__RevisedOrderProduct__c = objOI1.Id;
        //objOIAB.isRebaseEGorEG2EG__c = true;
        insert objOIAB;
        
        List<OrderItem> ordPro = new List<OrderItem>();
        ordPro.add(objOI1);
        List<OrderItem> ordProAB = new List<OrderItem>();
        ordPro.add(objOIAB);
        
        //Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Trigger_OrderItem_Helper.updateLegalEntity(ordPro);
        Trigger_OrderItem_Helper.TruncatedStatusUpdateonEGandREG(ordPro);
        test.stopTest();
        
    }
    public static testMethod void testUnitMethod4(){
        // Create Test Account
        List<Id> ordIds = new List<Id>();
        Order objOrder = [SELECT Id,accountid  FROM Order Limit 1];
        ordIds.add(objOrder.Id);
        system.debug('==ordIds=='+ordIds);
        List<Product2> lstProd= [SELECT Id  FROM Product2 Limit 1];
        PricebookEntry objPBEntry =  [SELECT Id  FROM PricebookEntry Limit 1];
        blng__BillingRule__c objBR =[SELECT Id  FROM blng__BillingRule__c Limit 1];
        blng__RevenueRecognitionRule__c   objRR=[SELECT Id  FROM blng__RevenueRecognitionRule__c Limit 1];
        blng__TaxRule__c     objTR= [SELECT Id  FROM blng__TaxRule__c Limit 1];           
         Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.Attribute_Values__c = 'Practice Area:SSDI,Service County:,';//<T01>
        insert objAR;
        system.debug('==objAR=='+objAR);
         // Create Attribute_Lines__c - Practice Area
         Attribute_Lines__c objAL = DataFactory.createAttributeLines(objAR, 'Practice Area', 'String', 'SSDI', '');

       // Attribute_Lines__c objAL2 = DataFactory.createAttributeLines(objAR, 'Service County', 'Multi-Picklist', '', 'Connecticut---Tolland;Delaware---Sussex;Delaware---New Castle;Delaware---Kent');
        
        //system.assert(od.id!=null );
        Test.startTest();
        
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
        //objOI.Status__c = Constant.ORDER_STATUS_PAUSE;
        objOI.Attribute_Relationship__c = objAR.id;
        objOI.Fulfillment_date__c = Date.today();
        
        insert objOI;
        
        
        /*blng__UsageSummary__c objUSummary = new blng__UsageSummary__c();
        objUSummary.blng__MatchingId__c = '1234';
        objUSummary.blng__MatchingAttribute__c = 'Quarterly';
        objUSummary.blng__UnitOfMeasure__c = 'Hours';
        objUSummary.blng__Account__c = objOrder.accountid;
        objUSummary.blng__Order__c = objOrder.Id; 
        objUSummary.blng__OrderProduct__c = objOI.Id;
        objUSummary.blng__TotalQuantity__c = 1;
        objUSummary.blng__SummaryStartDate__c = objOI.ServiceDate;
        objUSummary.blng__SummaryEndDate__c = objOI.ServiceDate.adddays(22);
        
        insert objUSummary;*/
        
        
        OrderItem objOI1 = new OrderItem();
        objOI1.OrderId = objOrder.id;
        objOI1.Quantity = 24;
        objOI1.UnitPrice = 250;
        objOI1.Product2id = lstProd[0].id;
        objOI1.PricebookEntryId=objPBEntry.id;
        objOI1.SBQQ__ChargeType__c = 'Recurring';
        objOI1.SBQQ__BillingFrequency__c = 'Monthly';
        objOI1.SBQQ__BillingType__c = 'Arrears';
        objOI1.blng__BillingRule__c = objBR.Id;
        objOI1.blng__RevenueRecognitionRule__c = objRR.Id;
        objOI1.SBQQ__Activated__c = TRUE;
        objOI1.blng__TaxRule__c = objTR.Id;
        objOI1.ServiceDate = system.today()+50;
        objOI1.SBQQ__DefaultSubscriptionTerm__c = 12;
        //objOI1.Status__c = Constant.ORDER_STATUS_ACTIVE;
         objOI1.Attribute_Relationship__c = objAR.id;
        objOI1.Fulfillment_date__c = Date.today(); 
        objOI1.Status__c = 'Active';
        insert objOI1;
        Map<Id,OrderItem> oldMap = new Map<Id,OrderItem>();
        oldMap.put(objOI1.id,objOI1);

        OrderItem objOIAB = new OrderItem();
        objOIAB.OrderId = objOrder.id;
        objOIAB.Quantity = -1;
        objOIAB.UnitPrice = 240;
        objOIAB.Product2id = lstProd[0].id;
        objOIAB.PricebookEntryId=objPBEntry.id;
        objOIAB.SBQQ__ChargeType__c = 'Recurring';
        objOIAB.SBQQ__BillingFrequency__c = 'Monthly';
        objOIAB.SBQQ__BillingType__c = 'Arrears';
        objOIAB.blng__BillingRule__c = objBR.Id;
        objOIAB.blng__RevenueRecognitionRule__c = objRR.Id;
        objOIAB.SBQQ__Activated__c = TRUE;
        objOIAB.blng__TaxRule__c = objTR.Id;
        objOIAB.ServiceDate = system.today()+50;
        objOIAB.SBQQ__DefaultSubscriptionTerm__c = 12;
        //objOI.Status__c = Constant.ORDER_STATUS_PAUSE;
        objOIAB.Attribute_Relationship__c = objAR.id;
        //objOIAB.Fulfillment_date__c = Date.today();
        objOIAB.SBQQ__ContractAction__c = 'Cancel';
        objOIAB.SBQQ__TerminatedDate__c = System.today();
        objOIAB.SBQQ__RevisedOrderProduct__c = objOI1.Id;
        
        List<OrderItem> ordPro = new List<OrderItem>();
        ordPro.add(objOI1);
        List<OrderItem> ordProAB = new List<OrderItem>();
        ordPro.add(objOIAB);
        Trigger_OrderItem_Helper.updateCancelOP(ordProAB);
        //objOIAB.isRebaseEGorEG2EG__c = true;
        
        Trigger_OrderItem_Helper classinstance = new Trigger_OrderItem_Helper();
        classinstance.FkMethod();
        Trigger_OrderItem_Helper.updateOffSet(ordPro);
        
       // Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        
        test.stopTest();
    }
}
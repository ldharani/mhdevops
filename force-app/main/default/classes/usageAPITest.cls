/**@@
#APEX CLASS NAME       :   usageAPITest
#CREATED BY            :   Serge Kandukuri
#DESCRIPTION           :   This is test class for usageAPI (Apex Class).
@@**/
@IsTest
public class usageAPITest{
    /**@@
    #DESCRIPTION     : Creating test records
    #Paramaters      : None
    @@**/
    @testSetup static void setup() {
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
         List<Contact> lstcon = DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
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
        
        // Create Test Quote Line
         Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        objQLI.Attribute_Relationship__c = objAR.Id;
        update objQLI;
        
        // Create Test Opportunity Line Item
        DataFactory.createOpportunityLineItem(lstOpp[0], lstProd[0], objPBEntry, objQLI);
        
        //lstQuote[0].SBQQ__Ordered__c = TRUE;        
        //lstQuote[0].SBQQ__PrimaryContact__c = lstcon[0].id;
        //update lstQuote;
         
        //lstQuote[0].SBQQ__Status__c = 'Closed Won';
        //update lstQuote;
        
        
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today().adddays(6);
        objOrder.AccountId = lstAcc[0].id;
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
        //objOI.Status__c = Constant.ORDER_STATUS_PAUSE;
        objOI.Resume_Date__c  = system.today();
        objOI.Attribute_Relationship__c = objAR.Id;
        objOI.SBQQ__QuoteLine__c = objQLI.Id;
        objOI.ServiceDate = system.today();
        objOI.EndDate = system.today().adddays(6);
        objOI.blng__BillableUnitPrice__c = 100;
        insert objOI;
        
        
    }
    
     /**@@
    #DESCRIPTION     : This is a test method used to cover add attribute functionality.
    #Paramaters      : None
    @@**/
    public static testMethod void testUnitMethod1(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorOItem());
        Order objOrder = [SELECT Id, Enddate FROM Order LIMIT 1];
        
        objOrder.Status = 'Activated';
        update objOrder;
        
        objOrder.SBQQ__Contracted__c = TRUE;
        update objOrder;
        
        Account objAcc = [SELECT Id FROM Account LIMIT 1];
        
        Opportunity objOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Contract objContract = DataFactory.createContract(objAcc, objOpp);
        
        Product2 objProd = [SELECT Id FROM Product2 LIMIT 1];
        
        SBQQ__QuoteLine__c objQLI = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        
        SBQQ__Subscription__c objSub = DataFactory.createSubscription(objAcc, objContract, objProd, objQLI);
        
        test.stopTest();
        
        OrderItem objOI = [SELECT Id, OrderItemNumber, SIN__c, ServiceDate, EndDate FROM OrderItem LIMIT 1];
        
        SBQQ__OrderItemConsumptionSchedule__c objOICS = new SBQQ__OrderItemConsumptionSchedule__c();
        objOICS.SBQQ__BillingTermUnit__c = 'Month';
        objOICS.SBQQ__BillingTerm__c = 1;
        objOICS.SBQQ__Category__c = 'Rates';
        objOICS.SBQQ__RatingMethod__c = 'Tier';
        objOICS.SBQQ__Type__c = 'Range';
        objOICS.SBQQ__OrderItem__c = objOI.Id;
        insert objOICS;
        
        
        blng__UsageSummary__c objUSummary = DataFactory.createUsageSummary(objAcc, objOrder, objOI);
        
        string strTodaydt = string.valueOf(system.now()).replace(' ', 'T');
        string strEnddt = string.valueOf(system.now().adddays(1)).replace(' ', 'T');
        
        
        string strRequest = '{';
        strRequest += '"blng_SIN_Number_c" : "' + objOI.SIN__c + '",';
        strRequest += '"blng_Lead_Id_c": "285740300",';
        strRequest += '"blng_StartDateTime_c": "' + strTodaydt + '",';
        strRequest += '"firstName": "nolo qa",';
        strRequest += '"lastName": "qa",';
        strRequest += '"email": "roberto.ruiz+3123134342324223249ww5@internetbrands.com",';
        strRequest += '"phone": "8003213505"';
        strRequest += '}';


        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/usageAPI/createUsage'; //Request URL
        req.requestbody = blob.valueOf(strRequest);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
    
        usageAPI.feedbackResponse objFR = usageAPI.createUsage();
        
        usageAPI.createUsage();
        
        objFR.id = '1234';
        objFR.errors = null;
        
    }
}
/**@@
#APEX CLASS NAME       :   orderExtensionTest
#CREATED BY            :   Serge Kandukuri
#DESCRIPTION           :   This is test class for orderExtension (Apex Class).
@@**/
@IsTest
public class orderExtensionTest{
    /**@@
    #DESCRIPTION     : Creating test records
    #Paramaters      : None
    @@**/
    @testSetup static void setup() {
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
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
        
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        // Create Test Quote Line
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        
        // Create Test Opportunity Line Item
        DataFactory.createOpportunityLineItem(lstOpp[0], lstProd[0], objPBEntry, objQLI);
        
         Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = lstAcc[0].id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
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
        insert objOI;
    }
    
     /**@@
    #DESCRIPTION     : This is a test method used to Create Customer Account records.
    #Paramaters      : None
    @@**/
    public static testMethod void testUnitMethod1(){
        Test.startTest();
        // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        OrderItem objOIFetch = [SELECT Id, Status__c FROM OrderItem LIMIT 1];
        apexpages.currentpage().getparameters().put('id', objOIFetch.Id);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(objOIFetch);
        orderExtension objOE = new orderExtension(stdCon);
        
        objOE.activateOrderProductStatus();
        // Confirm Order Product Status changed to Active
        //objOIFetch = [SELECT Id, Status__c FROM OrderItem WHERE Id =: objOIFetch.Id];
        //system.assertEquals(objOIFetch.Status__c, Constant.ORDER_STATUS_ACTIVE);
        
        // Confirm Order Product Status changed to Paused
        //objOE.activateOrderProductStatus();
        //objOIFetch = [SELECT Id, Status__c FROM OrderItem WHERE Id =: objOIFetch.Id];
        //system.assertEquals(objOIFetch.Status__c, Constant.ORDER_STATUS_PAUSE);
        
        
        //objOE.pauseOrderProductStatus();
        // Confirm Order Product Status changed to Paused
        //objOIFetch = [SELECT Id, Status__c FROM OrderItem WHERE Id =: objOIFetch.Id];
        //system.assertEquals(objOIFetch.Status__c, Constant.ORDER_STATUS_PAUSE);
        Test.stopTest();
    }
}
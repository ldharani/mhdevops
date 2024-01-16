/**@@
#APEX CLASS NAME       :    QuoteLineTriggerTest
#CREATED BY            :    Serge Kandukuri
#DESCRIPTION           :    This is test class for QuoteLineTrigger (Apex Trigger) and Trigger_QuoteLine_Handler and Trigger_QuoteLine_Helper (Apex Class).
@@**/
@IsTest()
public class QuoteLineTriggerTest{
    /**@@
    #DESCRIPTION     : Creating test records
    #Paramaters      : None
    @@**/
    
    @testSetup static void setup() {
        DataFactory.loadCustomSettings();
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        
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
       	Attribute_Lines__c objAL2 = DataFactory.createAttributeLines(objAR, 'Service County', 'Multi-Picklist', '', 'Connecticut---Tolland;Delaware---Sussex;Delaware---New Castle;Delaware---Kent');
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        // Create Test Quote Line 
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Quote Line').getRecordTypeId();
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        
        DataFactory.createOpportunityLineItem(lstOpp[0], lstProd[0], objPBEntry, objQLI);
    }
   
    /**@@
    #DESCRIPTION     : This is a test method used to cover add attribute functionality.
    #Paramaters      : None
    @@**/
   
   	public static testMethod void testUnitMethod1(){
       	test.startTest();
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
		sub.SBQQ__Quantity__c = 1;
        insert sub;
        SBQQ__QuoteLine__c objQLI = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        SBQQ__Quote__c objQ = [Select id from SBQQ__Quote__c limit 1];
        objQ.SBQQ__LineItemsGrouped__c = true;
        update objQ;
        objQLI.Part_of_Upsell__c =true;
        objQLI.Amend_Bundle__c = 'Upsell';
        objQLI.SIN__c = null;
        objQLI.Cancel_Now_Date__c = system.today();
        objQLI.SBQQ__Quantity__c = 0;
        objQLI.SBQQ__Group__c = null;
        objQLI.SBQQ__RenewedSubscription__c = sub.Id;
        update objQLI;
        test.stopTest();
    }
    public static testMethod void testUnitMethod6(){
		test.startTest();
        SBQQ__QuoteLine__c objQLI = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        objQLI.Part_of_Upsell__c =true;
        objQLI.Amend_Bundle__c = 'Upsell';
        objQLI.SIN__c = null;
        delete objQLI;
        test.stopTest();
    }
	public static testMethod void testUnitMethodBS(){
        test.startTest();
        SBQQ__Quote__c objQ = [Select id from SBQQ__Quote__c limit 1];
        Product2 p = [Select id from Product2 limit 1];
        p.Name = 'Avvo.com Banner Ads';
        update p;
        PricebookEntry pb = [Select id from PricebookEntry limit 1];
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Quote Line').getRecordTypeId();
		SBQQ__QuoteLine__c objqli = new SBQQ__QuoteLine__c();
        objqli.SIN__c = null;
        objqli.SBQQ__Quote__c = objQ.Id;
        objQLI.SBQQ__Product__c = p.Id;
        objQLI.SBQQ__PricebookEntryId__c = pb.Id;
        objqli.RecordTypeId = quoteLineRecordTypeId;
        objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__BillingFrequency__c = 'Monthly';
        objQLI.SBQQ__BillingType__c = 'Advance';
        objQLI.Usage_List_Price__c = 100;
        objQLI.SBQQ__SubscriptionTerm__c = 1;
        insert objqli;
        
        List<Id> qId = new List<Id>();
        set<Id> quoId = new set<Id>();
        qId.add(objQ.Id);
        quoId.add(objQ.Id);
        Trigger_QuoteLine_Helper.calculateQuote(qId);
        Trigger_QuoteLine_Helper.recalculateQuoteForPromo(qId);
        Trigger_QuoteLine_Helper.calculateBillingUnitPrice(quoId);
        test.stopTest();
    }
}
/***********************************************************************************************************************
* @author - VR
* @date - 01 Apr 2022
* @description - Test class for AddProductAPICPQ
* @testclassfor - AddProductAPICPQ

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6368    VR            1/04/2022                            Added Test Class
************************************************************************************************************************/

@istest(seealldata=true)
public class AddProductAPICPQ_Test { 
    
    static testMethod void testA()
    {
        //DataFactory.loadCustomSettings();
        
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
        
        Test.startTest();  
        
        // Create Test Product
        Product2 objProd = new Product2();
        objProd.Name = 'Promotional Fee';
        objProd.Productcode = 'PROMOFEE';
        objProd.IsActive = true;
        objProd.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        objProd.SBQQ__SubscriptionTerm__c = 12;
        // objProd.SBQQ__SubscriptionType__c = 'Evergreen';
        objProd.SBQQ__SubscriptionType__c = 'Renewable';
        objProd.SBQQ__ChargeType__c = 'Recurring';
        // objProd.SBQQ__BillingFrequency__c = 'Monthly';
        objProd.SBQQ__BillingType__c = 'Arrears';
        objProd.SBQQ__PricingMethod__c = 'List';
        objProd.blng__BillingRule__c = objBR.Id;
        objProd.blng__RevenueRecognitionRule__c = objRR.Id;
        objProd.blng__TaxRule__c = objTR.Id; 
        insert objProd;
        
        Datafactory.createPricebookEntry(objProd,0);
        
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Quote').getRecordTypeId();
        Pricebook2 p = [Select Id from Pricebook2 where Name='4. Martindale-Avvo Price Book'];
        SBQQ__Quote__c objQuote = new SBQQ__Quote__c();
        objQuote.SBQQ__Account__c = lstAcc[0].Id;
        objQuote.SBQQ__PricebookId__c = p.Id;
        objQuote.RecordtypeId = quoteRecordTypeId; 
        objQuote.SBQQ__Opportunity2__c = lstOpp[0].Id;
        objQuote.SBQQ__StartDate__c = system.today();
        objQuote.SBQQ__EndDate__c = system.today().adddays(30);
        objQuote.SBQQ__SubscriptionTerm__c = 12;
        objQuote.SBQQ__Primary__c = True;
        objQuote.SBQQ__Status__c = 'Draft';
        objQuote.SBQQ__ExpirationDate__c = system.today().adddays(30);
        objQuote.SBQQ__BillingFrequency__c = 'Monthly';
        objQuote.Promo_Code__c = 'Waive-ProRate-Plus-1-Mo';
        insert objQuote;
        
        List<ID> quoteIds = new List<ID>();

        List<QuoteLineModel> qlmodel = new List<QuoteLineModel>();
        List<QuoteLineGroupModel> qlmodelGrp = new List<QuoteLineGroupModel>();
        
        QuoteModel quoTest = new QuoteModel();
        quoTest.record = objQuote;
        quoTest.lineItems = qlmodel;
        quoTest.lineItemGroups = qlmodelGrp;
        quoTest.nextKey = 123;
        quoTest.applyAdditionalDiscountLast = true;
        quoTest.applyPartnerDiscountFirst = true;
        quoTest.channelDiscountsOffList = true;
        quoTest.customerTotal = 1.20;
        quoTest.netTotal =1.20;
        quoTest.netNonSegmentTotal = 1.20;
        String myJSON = JSON.serialize(quoTest);
        
                quoteIds.add(objQuote.ID);
        AddProductAPICPQ.addProd(quoteIds);
    }
}
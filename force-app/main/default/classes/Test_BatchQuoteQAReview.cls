@isTest
public class Test_BatchQuoteQAReview {
	static testmethod void BatchQuoteQAReview_TestMethod(){
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Intake Opportunity').getRecordTypeId();
        List<Opportunity> lstOpp = DataFactory.createOpportunity('Test Opp', lstAcc[0], oppRecordTypeId, 1);
        
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();

        Date td = date.today();
        System.debug('td'+td);
         SBQQ__Quote__c objQuote = new SBQQ__Quote__c();
            objQuote.SBQQ__Account__c = lstAcc[0].id;
            objQuote.SBQQ__PricebookId__c = Test.getStandardPricebookId();
            objQuote.RecordtypeId = quoteRecordTypeId; 
            objQuote.SBQQ__Opportunity2__c = lstOpp[0].id;
            objQuote.SBQQ__StartDate__c = td;
            objQuote.SBQQ__EndDate__c = Date.today().adddays(30);
            objQuote.SBQQ__SubscriptionTerm__c = 12;
            objQuote.SBQQ__Primary__c = True;
            objQuote.SBQQ__Status__c = 'QA Review';
            objQuote.SBQQ__ExpirationDate__c = system.today().adddays(30);
            objQuote.SBQQ__BillingFrequency__c = 'Monthly'; 
        insert objQuote;
          
        BatchQuoteQAReview b = new BatchQuoteQAReview();
        database.executeBatch(b,200);
            
            }
}
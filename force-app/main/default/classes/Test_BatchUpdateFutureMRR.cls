/***********************************************************************************************************************
 * @author - SS
 * @date - 30 Mar 2022
 * @description - Test Class for BatchUpdateFutureMRR

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description

************************************************************************************************************************/
@isTest(SeeallData = true)
public class Test_BatchUpdateFutureMRR {
   static testmethod void testMethod1(){
         Test.startTest();
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Intake Opportunity').getRecordTypeId();
        List<Opportunity> lstOpp = DataFactory.createOpportunity('Test Opp', lstAcc[0], oppRecordTypeId, 1);
        
       
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        Account objAcc = [SELECT Id,MH_Daily_MRR_Feed__c FROM Account LIMIT 1];
        
        Opportunity objOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
		// Create Billing Rule
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
        
        // Create Test Product
        List<Product2> lstProd = DataFactory.createProduct('Test Product', objBR, objRR, objTR, 1);
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry(lstProd[0], 100);
        
        // Create Test Quote Line
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
             
        Product2 objProd = [SELECT Id FROM Product2 LIMIT 1];
        
        objQLI = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
      
        Test.stopTest();
       
        BatchUpdateFutureMRR job = new BatchUpdateFutureMRR();
        Database.executeBatch(job);

     }
}
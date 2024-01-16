@isTest
public class quoteUtility_Test {
    
    public static testmethod void testCaseA(){        
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        // Create Test Opportunity
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Intake Opportunity').getRecordTypeId();
        List<Opportunity> lstOpp = DataFactory.createOpportunity('Test Opp', lstAcc[0], oppRecordTypeId, 1);
        
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        quoteUtility.createOrderfromQuote(lstQuote);
        quoteUtility.getPaymntGateWay();
        quoteUtility.getOppName(lstQuote);
    }
    
    public static testmethod void testCaseB(){        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new OrderItemMockImpl());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        String actualValue = res.getBody();
        String expectedValue = '{"example":"test"}';
    }
}
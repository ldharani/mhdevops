@isTest
public class NgageIndicatorOnAccount_Test {  
    
    static testmethod void NgageIndicatorTestMethod(){
        
        
        Map<Id,SBQQ__Subscription__c> newMap = new Map<Id,SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> listSub = new List<SBQQ__Subscription__c>();
        Set<Id> conId = new Set<Id>();
        
        DataFactory.loadCustomSettings();      
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Intake Opportunity').getRecordTypeId();
        List<Opportunity> lstOpp = DataFactory.createOpportunity('Test Opp', lstAcc[0], oppRecordTypeId, 1);
        
        Contract objContract = DataFactory.createContract(lstAcc[0], lstOpp[0]);
        
        // Create Billing Rule
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
        
        // Create Test Product
        List<Product2> lstProd = DataFactory.createProduct('Test Product', objBR, objRR, objTR, 1);
        
                Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry(lstProd[0], 100);
        
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c    .getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        test.startTest();
        SBQQ__Subscription__c objSub = DataFactory.createSubscription(lstAcc[0], objContract, lstProd[0], objQLI);
        
        
        conId.add(objContract.Id);
        listSub.add(objSub);
        newMap.put(objSub.Id, objSub);
        
        NgageIndicatorOnAccount_AC.indicateMethodOpp(listSub,newMap,newMap);
        Contract_UtilityClass.updateFutureContract(conId);
        Contract_UtilityClass.CascadeQuoteContact(conId);
        Contract_UtilityClass.CascadeQuoteContactAA(conId);
        Contract_UtilityClass.CascadeQuoteContactBB(conId);
        Contract_UtilityClass.ngageSub(conId);
        test.stopTest();
    }
    static testmethod void IndicatorOnAccountTest(){
        test.startTest();
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(lstAcc[0].Id));        
        Apexpages.StandardController sc = new Apexpages.StandardController(lstAcc[0]);
        IndicatorOnAccount_AC ext = new  IndicatorOnAccount_AC(sc);
        test.stopTest();
    }
}
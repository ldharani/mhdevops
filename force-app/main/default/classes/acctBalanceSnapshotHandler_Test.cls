@istest
public class acctBalanceSnapshotHandler_Test {
    
    @isTest static void testCase() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        blng__AccountBalanceSnapshot__c accBS = new blng__AccountBalanceSnapshot__c();
        accBS.blng__Account__c = acc.Id;
        insert accBS;
    }
}
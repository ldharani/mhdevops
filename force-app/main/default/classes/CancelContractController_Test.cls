@istest
public class CancelContractController_Test {
    
    public Static Testmethod void testmethodA(){
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        Opportunity opp = new Opportunity();
        opp.Name = 'OppTest'; 
        opp.AccountId = lstAcc[0].Id;
        opp.StageName = 'Prospecting';
        opp.CloseDate = System.today();
        insert opp;
        
        SBQQ__Quote__c quoteRec = new SBQQ__Quote__c();
        quoteRec.SBQQ__Account__c = lstAcc[0].Id;
        quoteRec.State__c = 'Draft';
        insert quoteRec;
        
        Contract conA = new Contract();
        conA.AccountId = lstAcc[0].Id;
        conA.Amend_Quote__c = quoteRec.Id;
        conA.SBQQ__Opportunity__c = opp.Id;
        insert conA;
        
        String conId = conA.Id;
        Test.startTest();
        CancelContractController.getContract(conId);
        CancelContractController.saveContract(conA);  
        //CancelContractController canCon = new CancelContractController();
        //canCon.FkMethod();
        Test.stopTest();
    }
}
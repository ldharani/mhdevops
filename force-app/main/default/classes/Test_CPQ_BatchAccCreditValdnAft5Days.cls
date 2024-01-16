// Author           : Sushmidha
// Description      : Test class for CPQ_BatchCreditValdnAft5Days

@isTest
public class Test_CPQ_BatchAccCreditValdnAft5Days {
    static testmethod void testRun1(){
        
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc =  util.getAccount();
        
        // Order ord = util.getOrder(acc.Id);
        
        Order ord = new Order();
        ord.Name = 'Test Order';
        ord.AccountId = acc.Id;
        ord.Status = 'Draft';   
        ord.EffectiveDate = Date.today();
        insert ord;
        
        Order ord2 = new Order();
        ord2.Name = 'Test Order';
        ord2.AccountId = acc.Id;
        ord2.Status = 'Draft';   
        ord2.EffectiveDate = Date.today();
        insert ord2;
        
        Id recId = Schema.SObjectType.blng__CreditNote__c.getRecordTypeInfosByName().get('Captorra Credit Note').getRecordTypeId();
        blng__CreditNote__c creditNote = new blng__CreditNote__c();
        creditNote.Credit_Reason__c = 'Write-off';
        creditNote.Sub_Reason__c = 'Agency Fees';
        creditNote.Approval_status__c = 'Pending Approval';
        creditNote.Approval_submission_date__c = Date.today();
        creditNote.blng__Account__c = acc.Id;
        creditNote.blng__CreditNoteDate__c = Date.today();
        creditNote.Approved_Amount__c = 400.00;
        creditNote.RecordTypeId = recId;
        upsert creditNote;
        
        blng__CreditNote__c creditNote1 = new blng__CreditNote__c();
        creditNote1.Credit_Reason__c = 'Write-off';
        creditNote1.Sub_Reason__c = 'Agency Fees';
        creditNote1.Approval_status__c = 'Pending Approval';
        creditNote1.Approval_submission_date__c = Date.today();
        creditNote1.blng__Account__c = acc.Id;
        creditNote1.blng__CreditNoteDate__c = Date.today();
        creditNote1.Approved_Amount__c = 6000.00;
        creditNote1.RecordTypeId = recId;
        upsert creditNote1;
        
        // Create an approval request for the Credit Note
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(creditNote.id);
        req1.setSkipEntryCriteria(true);
        //   Approval.ProcessResult result = Approval.process(req1);

        Test.startTest();
        CPQ_BatchAccCreditValdnAft5Days batch = new CPQ_BatchAccCreditValdnAft5Days();
        Database.executebatch(new CPQ_BatchAccCreditValdnAft5Days());
        Test.stopTest();
    }
    static testmethod void testRun2(){
        
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc =  util.getAccount();
        
        // Order ord = util.getOrder(acc.Id);
        
        Order ord = new Order();
        ord.Name = 'Test Order';
        ord.AccountId = acc.Id;
        ord.Status = 'Draft';   
        ord.EffectiveDate = Date.today();
        insert ord;
        
        Order ord2 = new Order();
        ord2.Name = 'Test Order';
        ord2.AccountId = acc.Id;
        ord2.Status = 'Draft';   
        ord2.EffectiveDate = Date.today();
        insert ord2;
        
        Id recId = Schema.SObjectType.blng__CreditNote__c.getRecordTypeInfosByName().get('Captorra Credit Note').getRecordTypeId();
        blng__CreditNote__c creditNote = new blng__CreditNote__c();
        creditNote.Credit_Reason__c = 'Write-off';
        creditNote.Sub_Reason__c = 'Agency Fees';
        creditNote.Approval_status__c = 'Pending Approval';
        creditNote.Approval_submission_date__c = Date.today();
        creditNote.blng__Account__c = acc.Id;
        creditNote.blng__CreditNoteDate__c = Date.today();
        creditNote.Approved_Amount__c = 400.00;
        creditNote.RecordTypeId = recId;
        upsert creditNote;
        
        blng__CreditNote__c creditNote1 = new blng__CreditNote__c();
        creditNote1.Credit_Reason__c = 'Write-off';
        creditNote1.Sub_Reason__c = 'Agency Fees';
        creditNote1.Approval_status__c = 'Pending Approval';
        creditNote1.Approval_submission_date__c = Date.today();
        creditNote1.blng__Account__c = acc.Id; 
        creditNote1.blng__CreditNoteDate__c = Date.today();
        creditNote1.Approved_Amount__c = 6000.00;
        creditNote1.RecordTypeId = recId;
        upsert creditNote1;
        
        // Create an approval request for the Credit Note
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(creditNote.id);
        req1.setSkipEntryCriteria(true);

        Test.startTest();
        CPQ_BatchAccCreditValdnAft5Days batch = new CPQ_BatchAccCreditValdnAft5Days();
        Database.executebatch(new CPQ_BatchAccCreditValdnAft5Days());
        batch.getDiffBusinessDays(System.today().adddays(10) , System.today());
        Test.stopTest();
    }
}
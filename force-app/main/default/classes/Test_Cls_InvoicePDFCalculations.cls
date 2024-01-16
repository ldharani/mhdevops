@IsTest
public class Test_Cls_InvoicePDFCalculations {
    static testmethod void testRun1(){
        
        Account acc = new Account();
        acc.Name = 'testAcc' ; 
        acc.Phone='122-34345-654';
        insert acc; 
        
        List<blng__Invoice__c> invlist = new List<blng__Invoice__c>();
        blng__Invoice__c Inv= new blng__Invoice__c();
        Inv.blng__Account__c = acc.Id;
        Inv.blng__InvoiceDate__c = System.today();
        insert Inv;
        invlist.add(Inv);
        
        blng__CreditNote__c creditNote = new blng__CreditNote__c();
        creditNote.Credit_Reason__c = 'Already Retained';
        creditNote.blng__Account__c = acc.Id;
        creditNote.blng__CreditNoteDate__c = Date.today().adddays(-20);
        creditNote.Approved_Amount__c = 400.00;
        creditNote.RecordTypeId = Schema.SObjectType.blng__CreditNote__c.getRecordTypeInfosByName().get('M-A Intake Credit Note').getRecordTypeId();            
        insert creditNote;
        
        blng__DebitNote__c dNote = new blng__DebitNote__c();
        dNote.blng__Account__c = acc.ID;
        dNote.blng__DebitNoteDate__c = Date.today().adddays(-20);
        dNote.blng__DebitNoteSourceAction__c = 'Manual';
        dNote.blng__Status__c = 'Draft';
        insert dNote;
        
        dNote.blng__Status__c = 'Posted';
        update dNote;
        
        Test.startTest();
        Cls_InvoicePDFCalculations accClass = new Cls_InvoicePDFCalculations();
        Cls_InvoicePDFCalculations.calculatePreviousMonth(invlist);
        Test.stopTest();
    }
}
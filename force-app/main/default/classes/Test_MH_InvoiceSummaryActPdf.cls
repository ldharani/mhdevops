@IsTest
public class Test_MH_InvoiceSummaryActPdf {
    static testmethod void testRun1(){
        
        List<blng__Invoice__c> invList = new List<blng__Invoice__c>();
        
         DefaultPaymentAccount__c ddd = new DefaultPaymentAccount__c();
        ddd.Name = 'DefaultAccountRecord';
        ddd.Default_Account_ID__c = '0017j00000SIlpn';
        ddd.DefaultAccountNumber__c = '1000095499';
        ddd.PaymentAllocationRectypeID__c = '0124D0000000iUN';
        ddd.PaymentRecordTypeID__c = '0124D0000000iWn';
        ddd.USDCurrencyID__c = 'a03F0000009vD0D';
        insert ddd;
    
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc = util.getAccount();        
        Contact con = util.getContact(acc.Id);
        Opportunity opp = util.getOpportunity(acc.Id , con.Id);
        
         blng__Invoice__c invoice= new blng__Invoice__c();
        invoice.blng__Account__c = acc.Id;
        invoice.blng__InvoiceStatus__c = 'Posted';
        invoice.blng__InvoiceDate__c = System.today();
        invoice.IsDataLoaded__c = 'Y';
        invoice.RecordTypeId = Schema.SObjectType.blng__Invoice__c.getRecordTypeInfosByName().get('MH Invoice').getRecordTypeId();
        insert invoice;
        invoice.blng__InvoiceStatus__c ='Posted';
        update invoice;
        
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
        
        invList.add(invoice);
        
        blng__InvoiceLine__c invLines = util.getInvoiceLines(invoice.Id, Ord.Id);
        blng__InvoiceLine__c invLines1 = util.getInvoiceLines(invoice.Id, Ord.Id);
       /* invLines.RecordTypeId = Schema.SObjectType.blng__InvoiceLine__c.getRecordTypeInfosByDeveloperName().get('NOLO_Invoice_Line').getRecordTypeId();
        update invLines;*/
        blng__CreditNote__c cNote = new blng__CreditNote__c();
        cNote.blng__Account__c = acc.ID;
        cNote.blng__CreditNoteDate__c = Date.today();
        cNote.blng__CreditNoteSourceAction__c = 'Manual';
        cNote.blng__Status__c = 'Draft';
        insert cNote;
        
        blng__DebitNote__c dNote = new blng__DebitNote__c();
        dNote.blng__Account__c = acc.ID;
        dNote.blng__DebitNoteDate__c = Date.today();
        dNote.blng__DebitNoteSourceAction__c = 'Manual';
        dNote.blng__Status__c = 'Draft';
        insert dNote;
        
        blng__CreditNoteLine__c cNoteLine = new blng__CreditNoteLine__c();
        cNoteLine.blng__CreditNote__c = cNote.Id;
        cNoteLine.blng__Product__c = util.getProduct(false).Id;
        insert cNoteLine;
        
        blng__DebitNoteLine__c dNoteLine = new blng__DebitNoteLine__c();
        dNoteLine.blng__DebitNote__c = dNote.Id;
        dNoteLine.blng__Product__c = util.getProduct(false).Id;
        insert dNoteLine;
        
        blng__CreditNoteAllocation__c cNoteAlloc = new blng__CreditNoteAllocation__c();
        cNoteAlloc.blng__CreditNoteLine__c = cNoteLine.Id;
        cNoteAlloc.blng__Amount__c = 5;
        cNoteAlloc.blng__InvoiceLine__c = invLines.Id;        
        cNoteAlloc.blng__Type__c = 'Allocation';
        cNoteAlloc.blng__Unallocated__c = false;
        insert cNoteAlloc;
        
        blng__DebitNoteAllocation__c dNoteAlloc = new blng__DebitNoteAllocation__c();
        dNoteAlloc.blng__DebitNoteLine__c = dNoteLine.Id;
        dNoteAlloc.blng__Amount__c = 5;
        dNoteAlloc.blng__InvoiceLine__c = invLines.Id;        
        dNoteAlloc.blng__Type__c = 'Allocation';
        dNoteAlloc.blng__Unallocated__c = false;
        insert dNoteAlloc;
        
        
        blng__Payment__c payment = new blng__Payment__c();
        payment.blng__Account__c = acc.ID;
        payment.blng__PaymentDate__c = Date.today();
        payment.blng__Status__c = 'Draft';
        payment.blng__PaymentType__c = 'ACH';
        payment.blng__Amount__c = 10;
        payment.blng__Invoice__c = invoice.Id;
        payment.blng__Notes__c ='test';
        insert payment;
        
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id',invoice.id);
        MH_InvoiceSummaryActPdf summpdf=new MH_InvoiceSummaryActPdf();
        list<MH_InvoiceSummaryActPdf.wrapProduct> wraplist=new list<MH_InvoiceSummaryActPdf.wrapProduct>();
       // PageReference myVfPage = Page.Invoice_Template;
       // myVfPage.getParameters().put('sInvoiceID', invoice.id);
        //summpdf.sInvoiceID=invoice.id;
        Date st= summpdf.StartDate;
        blng__Invoice__c inv=summpdf.oInvoice;
        Date ed=summpdf.EndDate;
        decimal tot= summpdf.dTotalPayment;
        decimal cd=  summpdf.dCreditPayment;
         wraplist= summpdf.invoiceLinesList;
        summpdf.cancel();
        summpdf.showpdf();
        
        Test.stopTest();
     }

}
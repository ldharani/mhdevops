@isTest
public class InvoiceDebitAllocateCntl_Test {
    private static testmethod void testMethodA() {
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        blng__Invoice__c invoice = util.getInvoice(acc.Id);
        invoice.blng__InvoiceStatus__c ='Posted';
        update invoice;
        
        Order ord = new Order();
        ord.Name = 'Test Order';
        ord.AccountId = acc.Id;
        ord.Status = 'Draft';   
        ord.EffectiveDate = Date.today();
        insert ord;
        
        blng__InvoiceLine__c invLines = util.getInvoiceLines(invoice.Id, Ord.Id);
        
        blng__CreditNote__c cNote = new blng__CreditNote__c();
        cNote.blng__Account__c = acc.ID;
        cNote.blng__CreditNoteDate__c = Date.today();
        cNote.blng__CreditNoteSourceAction__c = 'Manual'; 
        cNote.blng__Status__c = 'Draft';
        insert cNote;
        
        blng__CreditNoteLine__c cNoteLine = new blng__CreditNoteLine__c();
        cNoteLine.blng__CreditNote__c = cNote.Id;
        cNoteLine.blng__Product__c = util.getProduct(false).Id;
        insert cNoteLine;
        
        blng__DebitNote__c dNote = new blng__DebitNote__c();
        dNote.blng__Account__c = acc.ID;
        dNote.blng__DebitNoteDate__c = Date.today();
        dNote.blng__DebitNoteSourceAction__c = 'Manual';
        dNote.blng__Status__c = 'Draft';
        insert dNote;
        
        blng__DebitNoteLine__c dNoteLine = new blng__DebitNoteLine__c();
        dNoteLine.blng__DebitNote__c = dNote.Id;
        dNoteLine.blng__Product__c = util.getProduct(false).Id;
        insert dNoteLine;
        
        String DebitIds = dNote.Id;
        String DebitNoteLineId = dNoteLine.Id;
        
        List<InvoiceDebitAllocateCntl.InvoiceLineWrapper> listofinvlineWrap = new List<InvoiceDebitAllocateCntl.InvoiceLineWrapper>();
        List<InvoiceDebitAllocateCntl.CreditLineWrapper>   listofcredtlineWrap = new List<InvoiceDebitAllocateCntl.CreditLineWrapper>();
        
        InvoiceDebitAllocateCntl.InvoiceLineWrapper invlineW = new InvoiceDebitAllocateCntl.InvoiceLineWrapper();
        invlineW.InvLine=invLines;
        invlineW.Amount =10;
         listofinvlineWrap.add(invlineW);
        InvoiceDebitAllocateCntl.CreditLineWrapper credlineW = new InvoiceDebitAllocateCntl.CreditLineWrapper();
        credlineW.credtLine =cNoteLine;
        credlineW.crdtAmount =10;
        listofcredtlineWrap.add(credlineW);
        ApexPages.StandardController setCon = new ApexPages.StandardController(dNote);
        InvoiceDebitAllocateCntl debtControl = new InvoiceDebitAllocateCntl(setCon);
        InvoiceDebitAllocateCntl.getDebitLines(dNote.Id);
        InvoiceDebitAllocateCntl.getDebitNote(dNote.Id);
        InvoiceDebitAllocateCntl.getCredtLineWithAmt(dNote.Id);
        InvoiceDebitAllocateCntl.getInvLineWithAmt(dNote.Id);
        InvoiceDebitAllocateCntl.DoDebitAllocate(json.serialize(listofinvlineWrap),DebitNoteLineId,DebitIds,json.serialize(listofcredtlineWrap));
    }
}
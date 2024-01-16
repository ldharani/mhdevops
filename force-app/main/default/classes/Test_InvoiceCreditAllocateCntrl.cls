@istest
public class Test_InvoiceCreditAllocateCntrl {
 static testMethod void testValidateCreditAmt(){
     //Cls_UtilTestClass util= new Cls_UtilTestClass();
    // Account acc = util.getAccount();
     
        Account acc = new Account();
        acc.Name = 'testAcc' ; 
        acc.Phone='122-34345-654';
      insert acc;
       
     blng__Invoice__c Inv= new blng__Invoice__c();
     inv.blng__Account__c = acc.Id;
     insert inv;
     ValidateCreditAmt_Cntrl.getRecordtypeName(inv.id);
 }
    
    static testMethod void testCreditAllocate(){
     Account acc = new Account();
        acc.Name = 'testAcc' ; 
        acc.Phone='122-34345-654';
      insert acc;
        
     Product2 prd= new Product2();
     prd.name='Professional Profile';
     prd.productcode='123';
     insert prd;
        
     blng__Invoice__c Inv= new blng__Invoice__c();
     inv.blng__Account__c = acc.Id;
     insert inv;
        
     inv.blng__InvoiceStatus__c='Posted';
     inv.Approval_status__c= 'Approved';
        update inv;
        
     blng__InvoiceLine__c invline = new blng__InvoiceLine__c();
     invline.blng__Product__c=prd.Id;
     invline.blng__Invoice__c = inv.Id;
     invline.blng__Quantity__c=1;   
     insert invline;
      
     
     blng__CreditNote__c  creditNote= new blng__CreditNote__c();
     creditNote.blng__RelatedInvoice__c=inv.id;
         creditNote.blng__Account__c=acc.Id;
         creditNote.blng__CreditNoteDate__c=system.today();
         insert creditNote;
        
       blng__CreditNoteLine__c crdline= new blng__CreditNoteLine__c();
       crdline.blng__CreditNote__c=creditNote.Id;
       crdline.blng__Product__c=prd.Id;
       crdline.blng__CreditNoteLineDate__c=system.today();
       crdline.blng__TotalAmount__c=100;
        insert crdline;
        
        blng__CreditNoteAllocation__c credalloc= new blng__CreditNoteAllocation__c();
        credalloc.blng__InvoiceLine__c=invline.Id;
        credalloc.blng__CreditNoteLine__c=crdline.id;
        credalloc.blng__Amount__c=50;
        credalloc.blng__Type__c='Allocation';
        insert credalloc;
        
        blng__DebitNote__c debit= new blng__DebitNote__c();
        debit.blng__Account__c=acc.Id;
        insert debit; 
         debit.blng__DebitNoteDate__c=system.today();
        update debit;
        
        blng__DebitNoteLine__c debitline = new blng__DebitNoteLine__c();
        debitline.blng__DebitNote__c = debit.id;
        debitline.blng__Product__c=prd.id;
        debitline.blng__DebitNoteLineDate__c=system.today();
        debitline.blng__Subtotal__c=10;
        
        insert debitline;
        debitline.blng__Subtotal__c=0;
        update debitline;
        
     InvoiceCreditAllocateCntl.getCreditLines(creditNote.Id);
        InvoiceCreditAllocateCntl.getCreditNote(creditNote.Id);
        InvoiceCreditAllocateCntl.getInvoiceLines(creditNote.Id);
        InvoiceCreditAllocateCntl.getInvLineWithAmt(creditNote.Id);
        InvoiceCreditAllocateCntl.getAllocations(creditNote.Id);
        InvoiceCreditAllocateCntl.DoUnAllocations(credalloc.Id);
        
        InvoiceCreditAllocateCntl.InvoiceLineWrapper wrap = new InvoiceCreditAllocateCntl.InvoiceLineWrapper();
        wrap.InvLine=invline;
        wrap.Amount=10;
        list<InvoiceCreditAllocateCntl.InvoiceLineWrapper> listwrap= new list<InvoiceCreditAllocateCntl.InvoiceLineWrapper>();
        listwrap.add(wrap);
        string wraptext=JSON.serialize(listwrap) ; 
        string credId = crdline.id;
        InvoiceCreditAllocateCntl.DoCreditAllocate(wraptext,credId);
        
 }
}
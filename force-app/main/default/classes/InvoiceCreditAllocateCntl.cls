global class InvoiceCreditAllocateCntl {
    public string CreditId {get;set;}
    
    public InvoiceCreditAllocateCntl(ApexPages.StandardController controller) {
        CreditId = controller.getId();     
        
    }
    
    @AuraEnabled
    webservice static list<blng__CreditNoteLine__c> getCreditLines(string CreditId){
        list<blng__CreditNoteLine__c> ListofcreditNoteline = new list<blng__CreditNoteLine__c>();
        ListofcreditNoteline = [select Id,Name,blng__Product__r.Name,blng__TotalAmount__c,blng__Allocations__c,blng__Unallocations__c,blng__Balance__c,blng__Status__c from blng__CreditNoteLine__c where blng__CreditNote__c=:CreditId and blng__Balance__c > 0 ];
        system.debug('emter credit method'+CreditId);
        return ListofcreditNoteline;
    }
    
    @AuraEnabled
    webservice static blng__CreditNote__c getCreditNote(string CreditId){
        blng__CreditNote__c CreditNote = [select Id,Name,blng__Account__r.Name,blng__TotalAmount__c,blng__Allocations__c,blng__Unallocations__c,blng__Balance__c from blng__CreditNote__c where Id =:CreditId];
        system.debug('credit method'+CreditId);
        return CreditNote;
    }
    
    @AuraEnabled
    webservice static list<blng__InvoiceLine__c> getInvoiceLines(string CreditId){
        list<blng__InvoiceLine__c> ListofInvline = new list<blng__InvoiceLine__c>();
        system.debug('enter inv method'+CreditId);
        Id invoiceid = [select id,blng__RelatedInvoice__c,blng__Account__c from blng__CreditNote__c where id =: CreditId].blng__RelatedInvoice__c;
        Id ObjaccountId = [select id,blng__RelatedInvoice__c,blng__Account__c from blng__CreditNote__c where id =: CreditId].blng__Account__c;
        if(invoiceid!=null){
         ListofInvline = [select Id,Name,blng__Invoice__r.Name,blng__Invoice__r.blng__Account__c,blng__TotalAmount__c,blng__Payments__c,blng__Credits__c,blng__Debits__c,blng__Balance__c from blng__InvoiceLine__c where blng__Invoice__c=: invoiceId ];
        } else if(ObjaccountId!=null){
           ListofInvline = [select Id,Name,blng__Invoice__r.Name,blng__Invoice__r.blng__Account__c,blng__TotalAmount__c,blng__Payments__c,blng__Credits__c,blng__Debits__c,blng__Balance__c,blng__Invoice__r.blng__InvoiceStatus__c from blng__InvoiceLine__c where blng__Invoice__r.blng__Account__c=: ObjaccountId and blng__Invoice__r.blng__InvoiceStatus__c  !='Cancelled'];
         
      }
        system.debug('enter invoiceline method'+invoiceId+'**'+ObjaccountId);
        return ListofInvline;
    }
    
    @AuraEnabled
    public static list<InvoiceLineWrapper> getInvLineWithAmt(String CreditId){
        list<blng__InvoiceLine__c> ListofInvline = new list<blng__InvoiceLine__c>();
        Id invoiceid = [select id,blng__RelatedInvoice__c,blng__Account__c from blng__CreditNote__c where id =: CreditId].blng__RelatedInvoice__c;
        Id ObjaccountId = [select id,blng__RelatedInvoice__c,blng__Account__c from blng__CreditNote__c where id =: CreditId].blng__Account__c;
        
        /*
        if(invoiceid!=null){
         ListofInvline = [select Id,Name,blng__Invoice__c,blng__Invoice__r.Name,blng__Invoice__r.blng__Account__c,blng__TotalAmount__c,blng__Payments__c,blng__Credits__c,blng__Debits__c,blng__Balance__c from blng__InvoiceLine__c where blng__Invoice__c=: invoiceId and blng__Balance__c >0];
        } else if(ObjaccountId!=null){
           ListofInvline = [select Id,Name,blng__Invoice__c,blng__Invoice__r.Name,blng__Invoice__r.blng__Account__c,blng__TotalAmount__c,blng__Payments__c,blng__Credits__c,blng__Debits__c,blng__Balance__c from blng__InvoiceLine__c where blng__Invoice__r.blng__Account__c=: ObjaccountId and blng__Balance__c >0];
        } 
        */
        
        //MHBS-5466;Point 3;Added by VR;        
        if(invoiceid!=null){
         ListofInvline = [select Id,Name,blng__Invoice__c,blng__Invoice__r.Name,blng__Invoice__r.blng__Account__c,blng__TotalAmount__c,blng__Payments__c,blng__Credits__c,blng__Debits__c,blng__Balance__c,blng__Invoice__r.blng__InvoiceStatus__c,blng__Invoice__r.blng__PaymentStatus__c from blng__InvoiceLine__c where blng__Invoice__c=: invoiceId and blng__Balance__c >0 and blng__Invoice__r.blng__InvoiceStatus__c='Posted' and blng__Invoice__r.blng__PaymentStatus__c!='Paid'];
        } else if(ObjaccountId!=null){
           ListofInvline = [select Id,Name,blng__Invoice__c,blng__Invoice__r.Name,blng__Invoice__r.blng__Account__c,blng__TotalAmount__c,blng__Payments__c,blng__Credits__c,blng__Debits__c,blng__Balance__c,blng__Invoice__r.blng__InvoiceStatus__c,blng__Invoice__r.blng__PaymentStatus__c from blng__InvoiceLine__c where blng__Invoice__r.blng__Account__c=: ObjaccountId and blng__Balance__c >0 and blng__Invoice__r.blng__InvoiceStatus__c='Posted' and blng__Invoice__r.blng__PaymentStatus__c!='Paid'];
        }
        
        
        list<InvoiceLineWrapper> wrapperlist = new list<InvoiceLineWrapper>();
        
        for(blng__InvoiceLine__c Objinvline: ListofInvline){
            
            InvoiceLineWrapper InvLineWrapper = new InvoiceLineWrapper();
            InvLineWrapper.InvLine = Objinvline;
            InvLineWrapper.Amount = 0;
            wrapperlist.add(InvLineWrapper);       
        }  system.debug(wrapperlist.size()+'size');
        System.debug('ListofInvline'+ListofInvline);
        return wrapperlist;
    }
    
    @AuraEnabled
    webservice static list<blng__CreditNoteAllocation__c> getAllocations(string CreditId){
        list<blng__CreditNoteAllocation__c> ListofAlloc = new list<blng__CreditNoteAllocation__c>();
        Id invoiceid = [select id,blng__RelatedInvoice__c from blng__CreditNote__c where id =: CreditId].blng__RelatedInvoice__c;
        Date Alloweddate = system.today().adddays(-60);
        ListofAlloc = [select Id,blng__InvoiceLine__r.Name,blng__CreditNoteLine__r.Name,blng__Amount__c from blng__CreditNoteAllocation__c where blng__InvoiceLine__r.blng__Invoice__c=:invoiceId and blng__CreditNoteLine__r.blng__CreditNote__c=:creditId and blng__Type__c = 'Allocation' and createddate >=: Alloweddate and blng__Unallocated__c=false];
        return ListofAlloc;
    }
    
    @AuraEnabled
    webservice static string DoUnAllocations(string AllocId){
        list<blng__CreditNoteAllocation__c> ListofAlloc = new list<blng__CreditNoteAllocation__c>();
        blng__CreditNoteAllocation__c Alloc = [select Id,blng__InvoiceLine__c,blng__CreditNoteLine__c,blng__Amount__c from blng__CreditNoteAllocation__c where Id=:AllocId];
        Id CreditNoteLineId = Alloc.blng__CreditNoteLine__c;
        Id InvLineId = Alloc.blng__InvoiceLine__c;
        Decimal Amount = Alloc.blng__Amount__c;
        blng__CreditNoteAllocation__c newUnAlloc= new blng__CreditNoteAllocation__c();
        newUnAlloc.blng__Type__c='Unallocation';
        newUnAlloc.blng__CreditNoteLine__c=CreditNoteLineId;
        newUnAlloc.blng__InvoiceLine__c=InvLineId;
        newUnAlloc.blng__Amount__c=Amount;
        try{
            insert newUnAlloc;
        return 'SUCCESS';
        }catch(Exception ex){
            return ex.getmessage();
        }
    }
    
    @AuraEnabled
    webservice static string DoCreditAllocate(string listofinvlineWrap,string CreditNoteLineId){
        set<id> Invoiceids = new set<Id>();
        List<InvoiceLineWrapper> listofinvline = (List<InvoiceLineWrapper>)JSON.deserialize(listofinvlineWrap, List<InvoiceLineWrapper>.class);
        list<blng__CreditNoteAllocation__c> AllocList = new list<blng__CreditNoteAllocation__c>();
        for(InvoiceLineWrapper wrap: listofinvline){
            system.debug('enter1');
            if(wrap.Amount!=0){
                system.debug('enter2');
                blng__CreditNoteAllocation__c newalloc = new blng__CreditNoteAllocation__c();
                newalloc.blng__type__c='Allocation';
                newalloc.blng__Amount__c=wrap.Amount;
                newalloc.blng__InvoiceLine__c=wrap.InvLine.id;
                newalloc.blng__CreditNoteLine__c= CreditNoteLineId;
                AllocList.add(newalloc);
               // Invoiceids.add(wrap.InvLine.blng__Invoice__c);
                system.debug('AllocList'+AllocList.size());
            }
        }
        blng__CreditNoteLine__c CreditNoteline =[select Id,blng__CreditNote__c from blng__CreditNoteLine__c where Id=: CreditNoteLineId];
        string creditid = CreditNoteline.blng__CreditNote__c;
        
        blng__CreditNote__c CreditNote = [select Id,Name,Credit_Type__c,blng__Status__c,blng__RelatedInvoice__c,blng__Balance__c from blng__CreditNote__c where Id =:CreditId];
        CreditNote.blng__Status__c = 'Posted';
        system.debug('Invoiceids'+Invoiceids);
        try{
            update CreditNote;
            system.debug('test'+ CreditNote.blng__Status__c);
            insert AllocList;  
            list<blng__Invoice__c> listofInvToUpdate = new list<blng__Invoice__c>();
            blng__CreditNote__c CreditNt = [select Id,Name,Credit_Type__c,blng__Status__c,blng__RelatedInvoice__c,blng__Balance__c from blng__CreditNote__c where Id =:CreditId];
        
            if( CreditNt.blng__RelatedInvoice__c!=null && CreditNt.blng__Balance__c==0){
                Invoiceids.add(CreditNt.blng__RelatedInvoice__c);
            }
               for(blng__Invoice__c ObjInv : [select Id,Name,Approval_status__c,blng__Balance__c,blng__ARStatus__c,blng__PaymentStatus__c from blng__Invoice__c where Id in: Invoiceids]){
               ObjInv.Approval_status__c=null;
                    listofInvToUpdate.add(ObjInv);
               }
           /* for(blng__Invoice__c ObjInv : [select Id,Name,Approval_status__c,blng__Balance__c,blng__ARStatus__c,blng__PaymentStatus__c from blng__Invoice__c where Id in: Invoiceids]){
                system.debug('test inv'+ObjInv);
                if(ObjInv.blng__Balance__c == 0 && ObjInv.blng__ARStatus__c!='Credited' && ObjInv.blng__PaymentStatus__c=='Paid'){
                    ObjInv.Approval_status__c=null;
                    listofInvToUpdate.add(ObjInv);
                }
            }  system.debug('listofInvToUpdate'+listofInvToUpdate);*/
            update listofInvToUpdate;    
            return 'SUCCESSFUL';
        }catch(exception ex){
            system.debug('ex.getmessage'+ex.getmessage());
            return ex.getmessage();
        }        
    }
    
    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class InvoiceLineWrapper{        
        @AuraEnabled
        public blng__InvoiceLine__c InvLine {get;set;}
        @AuraEnabled
        public decimal Amount{get;set;}
    }
    
    
}
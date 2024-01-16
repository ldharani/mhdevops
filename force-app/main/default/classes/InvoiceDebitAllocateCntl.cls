global class InvoiceDebitAllocateCntl {
    public string DebitId {get;set;}
    
    public InvoiceDebitAllocateCntl(ApexPages.StandardController controller) {
        DebitId = controller.getId();     
    }
    
    @AuraEnabled
    webservice static list<blng__DebitNoteLine__c> getDebitLines(string DebitId){
        list<blng__DebitNoteLine__c> ListofDebitNoteline = new list<blng__DebitNoteLine__c>();
        ListofDebitNoteline = [SELECT Id,Name,blng__Product__r.Name,blng__TotalAmount__c,blng__Allocations__c,blng__Unallocations__c,blng__AvailableBalance__c,blng__Status__c,blng__TotalNetAllocations__c,blng__TotalAvailableForAllocation__c FROM blng__DebitNoteLine__c WHERE blng__DebitNote__c=:DebitId AND blng__AvailableBalance__c > 0 ];
        return ListofDebitNoteline;
    }
    
    @AuraEnabled
    webservice static blng__DebitNote__c getDebitNote(string DebitId){
        blng__DebitNote__c DebitNote = [SELECT Id,Name,blng__Account__r.Name,blng__TotalAmount__c,blng__Allocations__c,blng__Unallocations__c,blng__Balance__c FROM blng__DebitNote__c WHERE Id =: DebitId];
        return DebitNote;
    }
    
    @AuraEnabled
    public static list<CreditLineWrapper> getCredtLineWithAmt(String DebitId){
        Id accId;
        for(blng__DebitNote__c debRec: [SELECT Id,blng__Account__c FROM blng__DebitNote__c WHERE Id =: DebitId]){
            accId = debRec.blng__Account__c;
        } 
        List<Id> credtIdList = new List<Id>();
        for(blng__CreditNote__c CreditNote : [SELECT Id,Name,blng__Account__r.Name,blng__TotalAmount__c,blng__Allocations__c,blng__Unallocations__c,blng__Balance__c FROM blng__CreditNote__c WHERE blng__Account__c =: accId AND blng__Status__c = 'Posted']){
            credtIdList.add(CreditNote.Id);
        }
        list<CreditLineWrapper> credtwrapperlist = new list<CreditLineWrapper>();
        
        for(blng__CreditNoteLine__c ObjCredtline:  [SELECT Id,Name,blng__Product__r.Name,blng__TotalAmount__c,blng__Allocations__c,blng__Unallocations__c,blng__Balance__c,blng__Status__c FROM blng__CreditNoteLine__c WHERE blng__CreditNote__c IN: credtIdList]){
            
            CreditLineWrapper credLineWrapper = new CreditLineWrapper();
            credLineWrapper.credtLine = ObjCredtline;
            credLineWrapper.crdtAmount = 0;
            credtwrapperlist.add(credLineWrapper);       
        }  system.debug(credtwrapperlist.size()+'size');
        return credtwrapperlist;
    }
    
    @AuraEnabled
    public static list<InvoiceLineWrapper> getInvLineWithAmt(String DebitId){
        Id accId;
        for(blng__DebitNote__c debRec: [SELECT Id,blng__Account__c FROM blng__DebitNote__c WHERE Id =: DebitId]){
            accId = debRec.blng__Account__c;
        }
        List<Id> invIdList = new List<Id>();
        for(blng__Invoice__c invRec : [SELECT Id,blng__Account__c,blng__InvoiceStatus__c,blng__PaymentStatus__c FROM blng__Invoice__c WHERE blng__Account__c =: accId]){
            if(invRec.blng__InvoiceStatus__c == 'Posted' 
               //&& (invRec.blng__PaymentStatus__c == 'Paid' || invRec.blng__PaymentStatus__c == 'Partially Paid')
               ){
                  invIdList.add(invRec.Id);
              }
        }
        
        list<InvoiceLineWrapper> wrapperlist = new list<InvoiceLineWrapper>();
        
        for(blng__InvoiceLine__c Objinvline:  [SELECT Id,Name,blng__Invoice__r.Name,blng__TotalAmount__c,blng__Payments__c,blng__Debits__c,blng__Balance__c,blng__Credits__c,blng__ARStatus__c,blng__Invoice__r.blng__PaymentStatus__c,blng__Invoice__r.blng__ARStatus__c FROM blng__InvoiceLine__c WHERE blng__Invoice__c IN: invIdList AND (blng__Credits__c != 0 OR blng__Payments__c != 0)]){
            Decimal Total = Objinvline.blng__TotalAmount__c;
            Decimal Bal = Objinvline.blng__Balance__c;
            if(Total != Bal){
                InvoiceLineWrapper InvLineWrapper = new InvoiceLineWrapper();
                InvLineWrapper.InvLine = Objinvline;
                InvLineWrapper.Amount = 0;
                wrapperlist.add(InvLineWrapper);       
            } 
        }system.debug(wrapperlist.size()+'size');
        return wrapperlist;
    }
    
    @AuraEnabled
    webservice static string DoDebitAllocate(string listofinvlineWrap,string DebitNoteLineId, String DebitIds,string listofcredtlineWrap ){
                System.debug('xxxxxxxxxxxxxxxx' + listofinvlineWrap);
        List<InvoiceLineWrapper> listofinvline = (List<InvoiceLineWrapper>)JSON.deserialize(listofinvlineWrap, List<InvoiceLineWrapper>.class);
        System.debug('xxxxxxxxxxxxxxxx' + listofinvline);
        List<CreditLineWrapper> listofCredtline = (List<CreditLineWrapper>)JSON.deserialize(listofcredtlineWrap, List<CreditLineWrapper>.class);
        
        list<blng__DebitNoteAllocation__c> AllocList = new list<blng__DebitNoteAllocation__c>();
        for(InvoiceLineWrapper wrap: listofinvline){
            system.debug('enter1');
            if(wrap.Amount!=0){
                system.debug('enter2');
                blng__DebitNoteAllocation__c newalloc = new blng__DebitNoteAllocation__c();
                newalloc.blng__type__c='Allocation';
                newalloc.blng__Amount__c=wrap.Amount;
                newalloc.blng__InvoiceLine__c=wrap.InvLine.id;
                newalloc.blng__DebitNoteLine__c= DebitNoteLineId;
                newalloc.blng__DebitNote__c = DebitIds;
                AllocList.add(newalloc);
                system.debug('AllocList'+AllocList.size());
            }
        }
        
        list<blng__DebitNoteAllocationCreditNoteLine__c> AllocListCredt = new list<blng__DebitNoteAllocationCreditNoteLine__c>();
        for(CreditLineWrapper wrapA: listofCredtline){
            system.debug('enter1');
            if(wrapA.crdtAmount!=0){
                system.debug('enter2');
                blng__DebitNoteAllocationCreditNoteLine__c newallocA = new blng__DebitNoteAllocationCreditNoteLine__c();
                newallocA.blng__type__c='Allocation';
                newallocA.blng__Amount__c=wrapA.crdtAmount;
                newallocA.blng__CreditNoteLine__c=wrapA.credtLine.id;
                newallocA.blng__DebitNoteLine__c= DebitNoteLineId;
                newallocA.blng__DebitNote__c = DebitIds;
                AllocListCredt.add(newallocA);
                system.debug('AllocListCredt'+AllocListCredt.size());
            }
        }
        
        blng__DebitNoteLine__c DebitNoteline =[select Id,blng__DebitNote__c from blng__DebitNoteLine__c where Id=: DebitNoteLineId];
        string DebitId = DebitNoteline.blng__DebitNote__c;
        
        blng__DebitNote__c DebitNote = [select Id,Name,blng__Status__c from blng__DebitNote__c where Id =:DebitId];
        DebitNote.blng__Status__c = 'Posted';
        
        try{
            update DebitNote;
            system.debug('test'+ DebitNote.blng__Status__c);
            insert AllocList;   
            insert AllocListCredt;
            return 'SUCCESSFUL';
        }catch(exception ex){
            system.debug('ex.getmessage'+ex.getmessage());
            return ex.getmessage();
        }        
    }
    
    public class InvoiceLineWrapper{        
        @AuraEnabled
        public blng__InvoiceLine__c InvLine {get;set;}
        @AuraEnabled
        public Decimal Amount{get;set;}
        
    }
    public class CreditLineWrapper{        
        @AuraEnabled
        public blng__CreditNoteLine__c credtLine {get;set;}
        @AuraEnabled
        public decimal crdtAmount{get;set;}
        
    } 
}
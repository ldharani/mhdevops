public class Trg_Invoice_Handler{
    public static boolean checkmodify = true;
    
    public static void validateApprovalfield(list<blng__Invoice__c> newlist,map<Id,blng__Invoice__c> oldmapofInvoice){
        for(blng__Invoice__c inv :newlist ){
            if(inv.Approval_status__c== 'Approved' && Trg_Invoice_Handler.checkmodify){
                 if((inv.Credit_Reason__c != oldmapofInvoice.get(inv.Id).Credit_Reason__c && oldmapofInvoice.get(inv.Id).Credit_Reason__c!=null)||
                   (inv.Sub_Reason__c != oldmapofInvoice.get(inv.Id).Sub_Reason__c && oldmapofInvoice.get(inv.Id).Sub_Reason__c!=null)||
                   (inv.Amt_to_be_credited__c != oldmapofInvoice.get(inv.Id).Amt_to_be_credited__c  && oldmapofInvoice.get(inv.Id).Amt_to_be_credited__c!=null)||
                   (inv.Approval_submission_date__c!=oldmapofInvoice.get(inv.Id).Approval_submission_date__c  && oldmapofInvoice.get(inv.Id).Approval_submission_date__c!=null)||                   
                   (inv.Escalate_To__c!=oldmapofInvoice.get(inv.Id).Escalate_To__c  && oldmapofInvoice.get(inv.Id).Escalate_To__c!=null)||
                   (inv.Related_To_Case__c!=oldmapofInvoice.get(inv.Id).Related_To_Case__c && oldmapofInvoice.get(inv.Id).Related_To_Case__c!=null)){
                      
                       
                       inv.adderror('You cannot modify the credit detail fields once the credit is approved'); 
                   }
            }
        }
    }
    
    
    
    public static void updateInvoiceDeliveryType(list<blng__Invoice__c> newlist){
        List<blng__Invoice__c> invLT = new List<blng__Invoice__c>();
        Set<Id> accId = new Set<Id>();
        for(blng__Invoice__c inv : newlist){
            if(inv.blng__Account__c != Null){
                accId.add(inv.blng__Account__c);
            }
        }
        for(blng__Invoice__c invT : [SELECT Id,blng__Account__c,blng__Account__r.Invoice_Delivery_Type__c,blng__InvoiceStatus__c FROM blng__Invoice__c WHERE blng__Account__c IN: accId and blng__InvoiceStatus__c ='Draft']){
            if(invT.blng__Account__r.Invoice_Delivery_Type__c != Null){
                invT.Delivery_Type__c = invT.blng__Account__r.Invoice_Delivery_Type__c;
                invLT.add(invT); 
            }
        }
        if(invLT.size() > 0){
            update invLT;
        }
    }
    
    public static void updateInvoiceDueDate(list<blng__Invoice__c> newlist){
        System.debug('aaaaaaaaaa' + newlist);
        List<blng__Invoice__c> invLT = new List<blng__Invoice__c>();
        Set<Id> accId = new Set<Id>();
        for(blng__Invoice__c inv : newlist){
            System.debug('bbbbbbbbbbbbbb' + inv.blng__Account__c);
            if(inv.blng__Account__c != Null){
                System.debug('cccccccccccc');
                accId.add(inv.blng__Account__c);
            }
        }
        for(blng__Invoice__c invT : [SELECT Id,blng__Account__c,blng__DueDate__c,blng__InvoiceDate__c,blng__Account__r.Payment_Terms__c, blng__InvoiceStatus__c FROM blng__Invoice__c WHERE blng__Account__c IN: accId and blng__InvoiceStatus__c ='Draft']){
            System.debug('dddddddddddd ' + invT.blng__Account__r.Payment_Terms__c +' ' + invT.blng__InvoiceDate__c);
            if(invT.blng__Account__r.Payment_Terms__c != Null && invT.blng__InvoiceDate__c != Null){
                if(invT.blng__Account__r.Payment_Terms__c == 'Net 10'){
                    invT.blng__DueDate__c = invT.blng__InvoiceDate__c.addDays(10);
                    invLT.add(invT); 
                }else if(invT.blng__Account__r.Payment_Terms__c == 'Net 30'){
                    invT.blng__DueDate__c = invT.blng__InvoiceDate__c.addDays(30);
                    invLT.add(invT);   
                }
            }
        }
        if(invLT.size() > 0){
            update invLT;
        }
    }
    
     public static void updateCreditReason(list<blng__Invoice__c> newlist,map<Id,blng__Invoice__c> oldmapofInvoice){
        for(blng__Invoice__c inv :newlist ){
            if(inv.RecordTypeId != oldmapofInvoice.get(inv.Id).RecordTypeId){
                 inv.Credit_Reason__c = null;
              }
            }
        }
    
    
}
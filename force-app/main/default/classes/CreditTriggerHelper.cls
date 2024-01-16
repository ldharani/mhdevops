/***********************************************************************************************************************
* @author - Ieswarya J
* @date - 24 Nov 2020
* @description - Helper class for the credit trigger handler.

*************************************************************************************************************************/

public class CreditTriggerHelper 
{
    
    public static void populateCreditReason(List<blng__CreditNote__c> newList) 
    {
        list<Id> listofInvId = new list<Id>();
        for(blng__CreditNote__c creditNote : newList){
            listofInvId.add(creditNote.blng__RelatedInvoice__c);
        }
        
        map<Id,blng__Invoice__c> mapofIdtoInv = new map<Id,blng__Invoice__c>([select Id,RecordType.Name,Name,Approval_submission_date__c,Approval_status__c ,Related_To_Case__c,Escalate_To__c,Credit_Reason__c,Amt_to_be_credited__c,blng__TotalAmount__c,Sub_Reason__c from blng__Invoice__c where Id in: listofInvId]);
        Map<Id,Id> mapOfInvRecType = new Map<Id,Id>();
        for(blng__Invoice__c inv : mapofIdtoInv.values()){
            String recName = inv.RecordType.Name.remove('Invoice')+'Credit Note';
        Id recid = Schema.SObjectType.blng__CreditNote__c.getRecordTypeInfosByName().get(recName).getRecordTypeId(); 
            mapOfInvRecType.put(inv.Id,recid);
        }
        for(blng__CreditNote__c creditNote : newList) {       
            if(creditNote.blng__RelatedInvoice__c != null && 
               mapofIdtoInv.containskey(creditNote.blng__RelatedInvoice__c)){  
                   creditNote.RecordTypeId = mapOfInvRecType.get(mapofIdtoInv.get(creditNote.blng__RelatedInvoice__c).Id);
                   creditNote.Credit_Reason__c = mapofIdtoInv.get(creditNote.blng__RelatedInvoice__c).Credit_Reason__c;
                   creditNote.Sub_Reason__c = mapofIdtoInv.get(creditNote.blng__RelatedInvoice__c).Sub_Reason__c;
                   creditNote.Approved_Amount__c = mapofIdtoInv.get(creditNote.blng__RelatedInvoice__c).Amt_to_be_credited__c;
                   creditNote.Approval_status__c=mapofIdtoInv.get(creditNote.blng__RelatedInvoice__c).Approval_status__c;
                   creditNote.Approval_submission_date__c=mapofIdtoInv.get(creditNote.blng__RelatedInvoice__c).Approval_submission_date__c;                    
                   creditNote.Escalate_To__c=mapofIdtoInv.get(creditNote.blng__RelatedInvoice__c).Escalate_To__c;
                   creditNote.Related_to_Case_Number__c=mapofIdtoInv.get(creditNote.blng__RelatedInvoice__c).Related_To_Case__c;
                   if(mapofIdtoInv.get(creditNote.blng__RelatedInvoice__c).Amt_to_be_credited__c == mapofIdtoInv.get(creditNote.blng__RelatedInvoice__c).blng__TotalAmount__c){
                       creditNote.Credit_Type__c = 'Full Credit'; 
                   } 
                   else{
                       creditNote.Credit_Type__c='PartialCredit'; 
                   }
                   
               }            
        }
    } 
    
    public static void lockCreditFields(List<blng__CreditNote__c> newList,Map<Id,blng__CreditNote__c> oldMap) 
    {
        list<Id> listofInvId = new list<Id>();
        for(blng__CreditNote__c creditNote : newList){
            system.debug(oldMap.get(creditNote.Id).Approval_status__c+'creditNoteid'+creditNote.Id+creditNote.Approval_status__c);
            system.debug(oldMap.get(creditNote.Id).Credit_Reason__c+'creditNoteid'+creditNote.Id+creditNote.Credit_Reason__c);
            system.debug(oldMap.get(creditNote.Id).Sub_Reason__c+'creditNoteid1'+creditNote.Id+creditNote.Sub_Reason__c);
            system.debug(oldMap.get(creditNote.Id).Approved_Amount__c+'creditNoteid2'+creditNote.Id+creditNote.Approved_Amount__c);
            system.debug(oldMap.get(creditNote.Id).Related_to_Case_Number__c+'creditNoteid3'+creditNote.Id+creditNote.Related_to_Case_Number__c);
            system.debug(oldMap.get(creditNote.Id).Approval_submission_date__c+'creditNoteid4'+creditNote.Id+creditNote.Approval_submission_date__c);
            if(creditNote.Approval_status__c =='Approved' &&
               ((creditNote.Credit_Reason__c <> oldMap.get(creditNote.Id).Credit_Reason__c) ||
                (creditNote.Sub_Reason__c <> oldMap.get(creditNote.Id).Sub_Reason__c) || 
                (creditNote.Approved_Amount__c <> oldMap.get(creditNote.Id).Approved_Amount__c) ||
                (creditNote.Related_to_Case_Number__c <> oldMap.get(creditNote.Id).Related_to_Case_Number__c)
               )){   
                   creditNote.adderror('You cannot modify the approval fields once the credit note is approved'); 
                   
               }
            
            
        }
    } 
    
    //When Balance becomes greater than zero, update Balance Allocated Date with null
    public static void updateAllocatedDate(List<blng__CreditNote__c> newList, Map<Id,blng__CreditNote__c> oldMap) 
    {
        Date todayDate = Date.today();
        Date expirationDate = todayDate.addDays(60);
        
        for(blng__CreditNote__c creditNote : newList) {       
            if(creditNote.blng__Balance__c <> oldMap.get(creditNote.Id).blng__Balance__c &&
               creditNote.blng__Balance__c == 0){            
                   creditNote.Balance_Allocated_Expiration_Date__c = expirationDate;
               }
            
            if(oldMap.get(creditNote.Id).blng__Balance__c == 0 && 
               creditNote.blng__Balance__c > 0){            
                   creditNote.Balance_Allocated_Expiration_Date__c = null;
               }
        }
    }
    
    public static void partialcredInvUpdate(List<blng__CreditNote__c> newList){
        list<Id> listofInvId = new list<Id>();
        list<id> FullCreditlistofInvId = new list<Id>();
        list<blng__Invoice__c> invToUpd = new list<blng__Invoice__c>();
        for(blng__CreditNote__c creditNote : newList){
          if(creditNote.Credit_Type__c == 'Full Credit'){
            FullCreditlistofInvId.add(creditNote.blng__RelatedInvoice__c);
            }else{
            listofInvId.add(creditNote.blng__RelatedInvoice__c);
            }
        }
        
        for(blng__Invoice__c Inv : [select Id,Approval_status__c,Approval_submission_date__c,Amt_to_be_credited__c,Credit_Reason__c,Sub_Reason__c,Credit_Status__c,Escalate_To__c,Related_To_Case__c from  blng__Invoice__c where Id in: listofInvId]){
           // Inv.Approval_status__c=null;
            Inv.Approval_submission_date__c=null;
            Inv.Amt_to_be_credited__c=null;
            Inv.Credit_Reason__c=null;
            Inv.Sub_Reason__c=null;
            Inv.Credit_Status__c=null;
            Inv.Escalate_To__c=null;
            Inv.Related_To_Case__c=null;
            invToUpd.add(Inv);
        } 
        for(blng__Invoice__c Inv : [select Id,Approval_status__c,Approval_submission_date__c,Amt_to_be_credited__c,Credit_Reason__c,Sub_Reason__c,Credit_Status__c,Escalate_To__c,Related_To_Case__c from  blng__Invoice__c where Id in: FullCreditlistofInvId]){
            Inv.Approval_status__c=null;
            Inv.Approval_submission_date__c=null;
            Inv.Amt_to_be_credited__c=null;
            Inv.Credit_Reason__c=null;
            Inv.Sub_Reason__c=null;
            Inv.Credit_Status__c=null;
            Inv.Escalate_To__c=null;
            Inv.Related_To_Case__c=null;
            invToUpd.add(Inv);
        } 
        Trg_Invoice_Handler.checkmodify = false;
        update invToUpd;
        
        
    }
    
    
    
}
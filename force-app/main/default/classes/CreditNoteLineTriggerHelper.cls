/***********************************************************************************************************************
 * @author - Ieswarya J
 * @date - 1 Dec 2020
 * @description - Helper class for the creditnoteline trigger handler.

*************************************************************************************************************************/
public class CreditNoteLineTriggerHelper {
   
    public static void checkvalidAmount(List<blng__CreditNoteLine__c> newList) {
      set<id> creditNoteIds= new set<Id>();
      for(blng__CreditNoteLine__c credline: newList){
            creditNoteIds.add(credline.blng__CreditNote__c);
        }
     
        map<Id,blng__CreditNote__c> mapofIdtoCreditNote = new map<Id,blng__CreditNote__c>([select Id,RecordType.Name,RecordType.DeveloperName,blng__TotalAmount__c,Credit_Type__c,Approved_Amount__c,Approval_Status__c from blng__CreditNote__c where Id in:creditNoteIds]);  
        Map<Id,Id> mapOfCredNoteRecType = new Map<Id,Id>();
        for(blng__CreditNote__c cred : mapofIdtoCreditNote.values()){
            String recName = cred.RecordType.Name+' Lines';
            System.debug(recName);
           Id recid = Schema.SObjectType.blng__CreditNoteLine__c.getRecordTypeInfosByName().get(recName).getRecordTypeId(); 
            mapOfCredNoteRecType.put(cred.Id,recid);
        }
        for(blng__CreditNoteLine__c credline: newList){
            if(mapofIdtoCreditNote.containskey(credline.blng__CreditNote__c) ){
                credline.RecordTypeId = mapOfCredNoteRecType.get(mapofIdtoCreditNote.get(credline.blng__CreditNote__c).Id);
                Decimal sumofamount = mapofIdtoCreditNote.get(credline.blng__CreditNote__c).blng__TotalAmount__c;
                Decimal Approvedamount = mapofIdtoCreditNote.get(credline.blng__CreditNote__c).Approved_Amount__c;
                String Approvalstatus = mapofIdtoCreditNote.get(credline.blng__CreditNote__c).Approval_Status__c;
                if(Approvalstatus!='Approved' && Approvedamount > 355 && mapofIdtoCreditNote.get(credline.blng__CreditNote__c).RecordType.DeveloperName != 'M_A_Intake_Credit_Note'){
                   credline.adderror('Please get the approval before creating the Credit Note lines'); 
                }else if(Approvalstatus!='Approved' && Approvedamount >= 500 && credline.RecordType.DeveloperName == 'M_A_Intake_Credit_Note'){
                   credline.adderror('Please get the approval before creating the Credit Note lines'); 
                }
                Decimal newsumAmt = 0;
                if(sumofamount!=null && credline.blng__TotalAmount__c!=null){
                    newsumAmt = sumofamount + credline.blng__TotalAmount__c;
                }
              if(newsumAmt > Approvedamount &&  (mapofIdtoCreditNote.get(credline.blng__CreditNote__c).Credit_Type__c == 'PartialCredit' || mapofIdtoCreditNote.get(credline.blng__CreditNote__c).Credit_Type__c == null)){
                   credline.adderror('The CreditLine amount exceeds the approved credit amount'); 
                }
            }
           
        }
    }
    
     public static void UpdatePostedStatus(List<blng__CreditNoteLine__c> newList) {
      set<id> creditNoteIds= new set<Id>();
      list<blng__CreditNote__c> creditNoteList = new list<blng__CreditNote__c>();
      for(blng__CreditNoteLine__c credline: newList){
            creditNoteIds.add(credline.blng__CreditNote__c);
        }
     map<Id,blng__CreditNote__c> mapofIdtoCreditNote = new map<Id,blng__CreditNote__c>([select Id,blng__status__c,Approval_Status__c,blng__TotalAmount__c,Credit_Type__c,Approved_Amount__c from blng__CreditNote__c where Id in:creditNoteIds]);  
      
        for(blng__CreditNoteLine__c credline: newList){
        if(mapofIdtoCreditNote.containskey(credline.blng__CreditNote__c) ){
            
            Decimal sumofamount = mapofIdtoCreditNote.get(credline.blng__CreditNote__c).blng__TotalAmount__c;
                Decimal Approvedamount = mapofIdtoCreditNote.get(credline.blng__CreditNote__c).Approved_Amount__c;
                String CreditType = mapofIdtoCreditNote.get(credline.blng__CreditNote__c).Credit_Type__c;
                Decimal newsumAmt = 0;
            System.debug(sumofamount);
             System.debug(credline.blng__TotalAmount__c);
                if(sumofamount!=null && credline.blng__TotalAmount__c!=null){
                    newsumAmt = sumofamount + credline.blng__TotalAmount__c;
                }
                 Id rId = Schema.SObjectType.blng__CreditNoteLine__c.getRecordTypeInfosByName().get('M-A Intake Credit Note Lines').getRecordTypeId();
            Id rIdMH = Schema.SObjectType.blng__CreditNoteLine__c.getRecordTypeInfosByName().get('MH Credit Note Lines').getRecordTypeId();
           
            System.debug(Approvedamount); 
             System.debug(newsumAmt);
            System.debug(newsumAmt == Approvedamount);
            System.debug(credline.RecordTypeId == rId);
            if(Approvedamount <=500 && newsumAmt == Approvedamount && (credline.RecordTypeId == rId || credline.RecordTypeId==rIdMH)){
                 blng__CreditNote__c cdNote = new blng__CreditNote__c(Id=credline.blng__CreditNote__c);
                   cdNote.blng__status__c = 'Posted';
                   creditNoteList.add(cdNote);
                }else if(Approvedamount >500 &&  mapofIdtoCreditNote.get(credline.blng__CreditNote__c).Approval_Status__c =='Approved' && newsumAmt == Approvedamount && (credline.RecordTypeId == rId || credline.RecordTypeId==rIdMH)){
                 blng__CreditNote__c cdNote = new blng__CreditNote__c(Id=credline.blng__CreditNote__c);
                   cdNote.blng__status__c = 'Posted';
                   creditNoteList.add(cdNote);
                }
               
                else if(Approvedamount <=355 && newsumAmt == Approvedamount && credline.RecordTypeId != rId && CreditType !='Full Credit'){
                 System.debug(newsumAmt == Approvedamount);
                    blng__CreditNote__c cdNote = new blng__CreditNote__c(Id=credline.blng__CreditNote__c);
                   cdNote.blng__status__c = 'Posted';
                   creditNoteList.add(cdNote);
                }
            }
        } if(creditNoteList.size()>0){
           update creditNoteList;
        }
      }
}
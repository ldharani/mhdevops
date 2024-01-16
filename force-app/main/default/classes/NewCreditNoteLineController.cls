public class NewCreditNoteLineController {
    public static Map<Id, String> recordtypemap {get;set;}
    
   /*@AuraEnabled        
    public static List<String> fetchRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordtypes = blng__CreditNoteLine__c.SObjectType.getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.getName() != 'Master')
            recordtypemap.put(rt.getRecordTypeId(), rt.getName());
        }        
        return recordtypemap.values();
    }
    
   @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
        System.debug(recordTypeLabel);
        Id recid = Schema.SObjectType.blng__CreditNoteLine__c.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    } */
    
    @AuraEnabled
    public static String getRecTypeId(String creditNoteId){
         blng__CreditNote__c cn =  [Select Id,RecordType.Name from blng__CreditNote__c where id =:creditNoteId];
        Id recid = Schema.SObjectType.blng__CreditNoteLine__c.getRecordTypeInfosByName().get(cn.RecordType.Name+' Lines').getRecordTypeId();        
        System.debug(recid);
        System.debug(cn.RecordType.Name+' Lines');
        String recordType = recId +','+ cn.RecordType.Name+' Lines';
        System.debug('recordType '+recordType);
        return recordType;
    }
    
    @AuraEnabled
    public static blng__CreditNote__c getCreditNoteDetails(String creditNoteId){
        System.debug(creditNoteId);
        blng__CreditNote__c cn =  [Select Id,Approved_Amount__c,Approval_Status__c,RecordType.Name from blng__CreditNote__c where id =:creditNoteId];     
        return cn;
    } 
}
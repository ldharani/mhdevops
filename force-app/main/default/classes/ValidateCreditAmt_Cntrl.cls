global class ValidateCreditAmt_Cntrl {
  @AuraEnabled
        webservice static string getRecordtypeName(string InvoiceId){
           string recordtypename = [select id,recordtype.name from blng__Invoice__c where Id=: InvoiceId].recordtype.name;
            return recordtypename;
        }
    
    @AuraEnabled
    public static String getRecTypeId(String InvoiceId){
         blng__Invoice__c inv =  [Select Id,RecordType.Name from blng__Invoice__c where id =:InvoiceId];
        System.debug(inv.RecordType.Name.remove('Invoice')+'Credit Note');
        Id recid = Schema.SObjectType.blng__CreditNote__c.getRecordTypeInfosByName().get(inv.RecordType.Name.remove('Invoice')+'Credit Note').getRecordTypeId();        
        System.debug(recid);
        
        String recordType = recId +','+ inv.RecordType.Name+'Credit Note';
        System.debug('recordType '+recordType);
        return recordType;
    }
}
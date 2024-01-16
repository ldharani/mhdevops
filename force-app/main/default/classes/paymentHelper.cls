public class paymentHelper {
    public static void setPaymentRecordType(List<blng__Payment__c> payLst){
        List<blng__Payment__c> payLstToUpdate = new List<blng__Payment__c>();
        Id MARecordTypeId = Schema.SObjectType.blng__Payment__c.getRecordTypeInfosByName().get('M-A Payment').getRecordTypeId();
        Id MHRecordTypeId = Schema.SObjectType.blng__Payment__c.getRecordTypeInfosByName().get('MH Payment').getRecordTypeId();
        for(blng__Payment__c paymnt: [select id, blng__Account__r.Business_Unit__c,blng__Account__c
                                       from blng__Payment__c where id=:payLst]){
            system.debug('====acc===='+paymnt.blng__Account__c);
            system.debug('====busunit===='+paymnt.blng__Account__r.Business_Unit__c);
            if(paymnt.blng__Account__r.Business_Unit__c == 'Martindale-Hubbell'){
                paymnt.RecordTypeId = MHRecordTypeId;
            }else if(paymnt.blng__Account__r.Business_Unit__c == 'Martindale-Avvo'){
                paymnt.RecordTypeId = MARecordTypeId;
            }
            payLstToUpdate.add(paymnt);
        }
        if(!payLstToUpdate.isEmpty()){
            update payLstToUpdate;
        }
    }
}
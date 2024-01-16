public class DocusignPaymentsClass {
    public static void getDSstatusRecord(List<dsfs__DocuSign_Status__c> docusignStatus, Map<Id,dsfs__DocuSign_Status__c> oldMap){
        system.debug('==docusignStatus=='+docusignStatus);
        List<dsfs__DocuSign_Status__c> dsRecord = [select id,Quote__c,dsfs__DocuSign_Envelope_ID__c,dsfs__Envelope_Status__c
                                                   from dsfs__DocuSign_Status__c where id IN: docusignStatus];
        String envelopeId = '';
        String accId;
        String conEmail;
        Id quoteId;
        List<SBQQ__Quote__c> quoteLst = new List<SBQQ__Quote__c>();
        for(dsfs__DocuSign_Status__c ds:dsRecord){
            if(ds.dsfs__Envelope_Status__c == 'Completed' && 
               	oldMap.get(ds.Id).dsfs__Envelope_Status__c != ds.dsfs__Envelope_Status__c){
            	envelopeId = ds.dsfs__DocuSign_Envelope_ID__c;
                quoteId = ds.Quote__c;
            }
            
        }
        system.debug('==envelopeId:'+envelopeId);
        system.debug('==quoteId:'+quoteId);
        DocusignPaymentApi.getPaymntInfo(envelopeId,quoteId);
    }
}
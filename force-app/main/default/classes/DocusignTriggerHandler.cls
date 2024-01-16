public class DocusignTriggerHandler {
    public static void updateDocusignExpirationdate(List<dsfs__DocuSign_Status__c> Docusignlist, map<id, dsfs__DocuSign_Status__c> oldmap){
        system.debug('==Docusignlist=='+Docusignlist);
        map<id,datetime> optyIdsVssenddate = new map<id, datetime>(); 
        list<Opportunity> updateoptys = new list<Opportunity>();        
         list<Opportunity> queryoptys = new list<Opportunity>();
         //for quote
         map<id,datetime> quoteIdsVssenddate = new map<id, datetime>();
        list<SBQQ__Quote__c> updatequotes = new list<SBQQ__Quote__c>();        
         list<SBQQ__Quote__c> queryquotes = new list<SBQQ__Quote__c>();
         
        for(dsfs__DocuSign_Status__c doc : Docusignlist){
            if(doc.dsfs__Envelope_Status__c!= null && doc.dsfs__Envelope_Status__c == 'Sent')
            {
                //optyIdsVssenddate.put(doc.dsfs__Opportunity__c,doc.dsfs__Sent_Date_Time__c);
                quoteIdsVssenddate.put(doc.Quote__c,doc.dsfs__Sent_Date_Time__c);
                system.debug('===quoteIdsVssenddate==='+quoteIdsVssenddate);
            }
        }
        /*
         system.debug('@@@@optyids'+ optyIdsVssenddate);
        if(optyIdsVssenddate.keyset().size()>0 && !optyIdsVssenddate.isempty()){
            
            queryoptys = [ select id, Name, stageName, Docusign_Expiration_date__c,Release_Inventory_Date__c
                               from Opportunity 
                               where stageName != 'Closed Lost' AND RecordType.DeveloperName = 'Nolo_Opportunity' AND stageName != 'Closed Lost' AND ID IN:(optyIdsVssenddate.keyset())];

        }
        system.debug('@@@@queryoptys'+ queryoptys);
        
        for(Opportunity opty : queryoptys){
            
            If(opty.Release_Inventory_Date__c != Null && optyIdsVssenddate.containskey(opty.id)){
                if(opty.Release_Inventory_Date__c <=  date.valueOf(optyIdsVssenddate.get(opty.id)) + 7 ){
                    opty.Docusign_Expiration_date__c = opty.Release_Inventory_Date__c;
                    
                }else{
                    opty.Docusign_Expiration_date__c =  date.valueOf(optyIdsVssenddate.get(opty.id)) + 7;
                    
                }
            }
            else{
                
                opty.Docusign_Expiration_date__c =  date.valueOf(optyIdsVssenddate.get(opty.id)) + 14; 
                
            }
            updateoptys.add(opty);
        }
      
        if(updateoptys.size() > 0){  
            update updateoptys;
      }*/
      //for quote - added by saiv
        if(quoteIdsVssenddate.keyset().size()>0 && !quoteIdsVssenddate.isempty()){
            
            queryquotes = [ select id, Name, SBQQ__Status__c, DocusignExpirationdate__c,DocuSignStatus__c,ReleaseInventoryDate__c,
                           RecordType.DeveloperName, isInventoryQLPresent__c from SBQQ__Quote__c 
                           where SBQQ__Status__c != 'Closed Lost' AND ID IN:(quoteIdsVssenddate.keyset())];
        }
        for(SBQQ__Quote__c qo : queryquotes){
            if(qo.RecordType.DeveloperName == 'M_A_Intake_Quote'){
                If(!quoteIdsVssenddate.isempty() && quoteIdsVssenddate.containskey(qo.id)){
                    qo.DocusignExpirationdate__c =  date.valueOf(quoteIdsVssenddate.get(qo.id)) + 15; 
                    updatequotes.add(qo);
                }
            }
            if(qo.RecordType.DeveloperName == 'MH_Quote' && qo.isInventoryQLPresent__c == 0){
                /*if(qo.ReleaseInventoryDate__c != Null && quoteIdsVssenddate.containskey(qo.id)){
                    if(qo.ReleaseInventoryDate__c <=  date.valueOf(quoteIdsVssenddate.get(qo.id)) + 7 ){
                        qo.DocusignExpirationdate__c = qo.ReleaseInventoryDate__c;
                    }else{
                        qo.DocusignExpirationdate__c =  date.valueOf(quoteIdsVssenddate.get(qo.id)) + 7;
                    }
                }*/
                //else{
                    qo.DocusignExpirationdate__c =  date.valueOf(quoteIdsVssenddate.get(qo.id)) + 14; 
                //}
                updatequotes.add(qo);
            }
            if(qo.RecordType.DeveloperName == 'M_A_Quote' || 
               	(qo.RecordType.DeveloperName == 'MH_Quote' && qo.isInventoryQLPresent__c != 0)){ //for ma quotes MHMAC-171
                qo.DocusignExpirationdate__c =  system.today()+1;
                updatequotes.add(qo);
            }
            
        }
        
        system.debug('@@@@queryquotes'+ queryquotes);
        system.debug('@@@@updatequotes'+ updatequotes);
        if(updatequotes.size() > 0){  
            update updatequotes;
        }
        
    }
}
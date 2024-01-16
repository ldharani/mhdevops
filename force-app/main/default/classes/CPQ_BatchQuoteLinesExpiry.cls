global class CPQ_BatchQuoteLinesExpiry implements Database.Batchable<sObject>,Database.AllowsCallouts {
    global String query;
    global User u;
    global Set<Id> setOppProdIds;
    
    global CPQ_BatchQuoteLinesExpiry() {
        u = [select Id, username from User where Id = :UserInfo.getUserId()];
        setOppProdIds = new Set<Id>();
        query = '';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = ' select id,SBQQ__Status__c,InventoryDate__c,ReleaseInventoryDate__c, '+ 
                ' (select id, Inventory_Id__c, SIN__c From SBQQ__LineItems__r '+ 
                ' where SIN__c = Null AND RecordType.DeveloperName = \'MH_Quote_Line\' AND Inventory_Id__c != \'\' )'+
                ' FROM SBQQ__Quote__c '+
                ' where InventoryDate__c != NULL AND ReleaseInventoryDate__c != Null AND ReleaseInventoryDate__c <= TODAY  AND'+
                ' SBQQ__Status__c  != \'Closed Won\' AND SBQQ__Status__c  != \'Closed Lost\'';
        if(Test.isRunningTest()) {
            query += ' order by CreatedDate DESC LIMIT 5';
         }
         system.debug('==QLnsquery=='+query);
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> oppList){ //List<Opportunity> oppList) {
        List<SBQQ__QuoteLine__c> lstOppProdToUpdate = new List<SBQQ__QuoteLine__c>();
        //List<invoiceit_crmx__Opportunity_Product__c> lstOppProdToUpdate = new List<invoiceit_crmx__Opportunity_Product__c>();
        system.debug('==QLnsoppList=='+oppList);
        for(SBQQ__Quote__c opp : oppList){
            if(opp.SBQQ__LineItems__r.size() > 0){
                 for(SBQQ__QuoteLine__c oppProducts : opp.SBQQ__LineItems__r) {
                    //system.debug('@@@@oppProducts name'+oppProducts.Name);
                    if(oppProducts.SIN__c==null || oppProducts.SIN__c==''){
                        setOppProdIds.add(oppProducts.Id);
                    }
                }
            }
            
        }
        system.debug('==setOppProdIds=='+setOppProdIds);
        if(!test.isRunningTest()) {
            CPQ_MDL_Integration_Vim_Efs.releaseInventoryRequestForBatch(setOppProdIds, u.Username);
        } 
    }
    
     global void finish(Database.BatchableContext BC) {
     
     List<Email_Ids_for_Batch_Process__mdt> emailids= new List<Email_Ids_for_Batch_Process__mdt>();
          emailids = [Select id, DeveloperName, MasterLabel,Email_Ids_for_emailing__c, Link_for_Failure_Report__c,
                       Link_for_Success_Report__c From Email_Ids_for_Batch_Process__mdt Where MasterLabel = 'Inventory Release job Process'];
        Boolean dontExecute = false;
        String emailAddressString;
        String successReport;
        String failureReport;
        for(AsyncApexJob batch :[Select ExtendedStatus,NumberOfErrors,Status,JobItemsProcessed,TotalJobItems from AsyncApexJob where Id = :BC.getJobId()]){         
            if(batch.JobItemsProcessed > 0){
                dontExecute = false;
            }
            else{
                dontExecute = true;
            }
        }
        if(dontExecute==false){
            for(Email_Ids_for_Batch_Process__mdt emaildetails: emailids){
            
            
            emailAddressString = emaildetails.Email_Ids_for_emailing__c;
            successReport = emaildetails.Link_for_Success_Report__c;
            failureReport = emaildetails.Link_for_Failure_Report__c;
           // String unmatchedReport = autoEvergreen.Link_for_report_with_unmatching_dates__c;
            }
            List<String> sendTo = new List<String>();   
            List<String> toEmailAddress = new List<String>();       
            if(emailAddressString.contains(',')){
                sendTo = emailAddressString.split(',');
                for(String s : sendTo){
                    if(s!='' && s!=null){
                        toEmailAddress.add(s);
                    }
                }
            }
            else{
                toEmailAddress.add(emailAddressString);
            }
            try{
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
                mail.setSubject('Inventory Release batch Process report');      
                mail.setToAddresses(toEmailAddress);
                String body = '<html><body>The Inventory Release batch process has completed running successfully<br><br>'+
                'Click on the following links to view more details regarding the run:<br>';
                if(successReport != '')
                body += '(1) Report for success records : <a href="'+successReport+'">'+successReport+'</a><br>';
                if(failureReport != '')
                body += '(2) Report for failure records : <a href="'+failureReport+'">'+failureReport+'</a><br>';
                           
                body += '</body></html>';
                mail.setHtmlBody(body);
                mails.add(mail);
                Messaging.sendEmail(mails);
            }
            catch(Exception e){
                System.debug('An exception occured' + e.getMessage());
            }
        }    
    }
}
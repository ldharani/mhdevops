global class MDL_BatchtoVoidDocusignEnvelope  implements Database.Batchable<sObject>,Database.AllowsCallouts{
    global String query;
    global User u;
    global Set<Id> setOppIds;
    
    global MDL_BatchtoVoidDocusignEnvelope() {
        u = [select Id, username from User where Id = :UserInfo.getUserId()];
        setOppIds  = new Set<Id>();
        query = '';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
         query = ' select id, Name, IsVoidable__c ,StageName, Docusign_Expiration_date__c '+
                   ' From Opportunity '+
                   ' Where StageName != \'Closed Lost\' AND Docusign_Expiration_date__c != NUll AND' + 
                   ' StageName != \'Closed Won\' AND Docusign_Expiration_date__c <= TODAY ' ;
        if(Test.isRunningTest()) {
            query += ' order by CreatedDate DESC LIMIT 5';
         }
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        List<opportunity> lstofOppToUpdate = new List<opportunity>();
        for(opportunity opp : oppList){  
            If(opp.Docusign_Expiration_date__c <= date.TODAY()  && opp.IsVoidable__c == False){
                setOppIds.add(opp.id);
                opp.IsVoidable__c = true;
                lstofOppToUpdate.add(opp);
                
            }
        
        }
        
         if(!test.isRunningTest()) {
            MDL_trgHandlerforOppRenew_Rebase.voidingenvelopefrombatch(setOppIds);
        } 
    }
    global void finish(Database.BatchableContext BC) {
    
         List<Email_Ids_for_Batch_Process__mdt> emailids= new List<Email_Ids_for_Batch_Process__mdt>();
          emailids = [Select id, DeveloperName, MasterLabel,Email_Ids_for_emailing__c, Link_for_Failure_Report__c,
                       Link_for_Success_Report__c From Email_Ids_for_Batch_Process__mdt Where MasterLabel = 'Void docusign batch process'];
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
                mail.setSubject('Void Docusign batch process report');      
                mail.setToAddresses(toEmailAddress);
                String body = '<html><body>The void Docusign batch process has completed running successfully<br><br>'+
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
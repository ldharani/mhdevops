/*******************************************************************************************
 * Author       : Akash
 * Description  : Clear Inventory Ids of products for which pend date > 30 days and opty in in open
 * Created Date : 20/05/2017
 * ********************************************************************************************/

global class MDL_BatchOppProductsExpiryopty implements Database.Batchable<sObject>,Database.AllowsCallouts{
    global String query;
    global User u;
    global Set<Id> setOppProdIds;
    
    global MDL_BatchOppProductsExpiryopty() {
        u = [select Id, username from User where Id = :UserInfo.getUserId()];
        setOppProdIds = new Set<Id>();
        query = '';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = ' select id, Name, (Select invoiceit_crmx__Product__c, '+
                   ' Product_SIN__c, Valid_Till__c, Name, IsInventoried__c,' +
                   ' InventoryId__c, Id From invoiceit_crmx__Opportunity_Products__r '+
                   ' where (RecordType.DeveloperName = \'MDL_Opportunity_Product\' or RecordType.DeveloperName = \'Nolo_Opportunity_Product\')'+
                   ' AND InventoryId__c != \'\' )' +
                   ' From Opportunity '+
                   ' Where Inventory_Date__c != NULL AND Release_Inventory_Date__c < TODAY  AND' + 
                   ' StageName != \'Closed Won\' and Quote_Type__c!=\'Renew\'';
         if(Test.isRunningTest()) {
            query += ' order by CreatedDate DESC LIMIT 5';
         }
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        
        List<invoiceit_crmx__Opportunity_Product__c> lstOppProdToUpdate = new List<invoiceit_crmx__Opportunity_Product__c>();
        
        for(opportunity opp : oppList){
            if(opp.invoiceit_crmx__Opportunity_Products__r.size() > 0){
                 for(invoiceit_crmx__Opportunity_Product__c oppProducts : opp.invoiceit_crmx__Opportunity_Products__r) {
                     system.debug('@@@@oppProducts name'+oppProducts.Name);
                    if(oppProducts.Product_SIN__c==null || oppProducts.Product_SIN__c==''){
                        setOppProdIds.add(oppProducts.Id);
                        oppProducts.InventoryId__c = '';
                        lstOppProdToUpdate.add(oppProducts);
                    }
                }
            }
            
        }
         if(!test.isRunningTest()) {
            MDL_Integration_Vim_Efs.releaseInventoryRequestFromBatch(setOppProdIds, u.Username);
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
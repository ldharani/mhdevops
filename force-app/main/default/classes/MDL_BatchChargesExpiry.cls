//Author            : akash
//Description       : To cancel the order rate plan charges for which service end date is at previous month
//                    it contains another chaining batch at finish which generates an XML



global class MDL_BatchChargesExpiry implements Database.Batchable<sObject>,Database.AllowsCallouts{
    global String query;
    global Date previousmonthEndDate;
  
   
    global MDL_BatchChargesExpiry() {
        query ='';
        previousmonthEndDate = Date.today().toStartofMonth().addDays(-1); 

    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'Select Id,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c ,'+
                ' invoiceit_s__Status__c,invoiceit_s__Price_Type__c,Shippable__c,invoiceit_s__Job_Rate_Plan__c, '+
                ' invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.Charge_Expired__c '+
                'from invoiceit_s__Job_Rate_Plan_Charge__c ' + 
                'where  invoiceit_s__Service_End_Date__c = :previousmonthEndDate and (((RecordType.DeveloperName = \'MDL_Order_Rate_Plan_Charge\' or RecordType.DeveloperName = \'Nolo_Order_Rate_Plan_Charge\' or RecordType.DeveloperName = \'M_NG_Order_Rate_Plan_Charge\') and invoiceit_s__Status__c=\'Active\'))';
        if(Test.isRunningTest()) {
            query += ' order by CreatedDate DESC LIMIT 5';
        }
        system.debug('@@@ query'+query );
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<invoiceit_s__Job_Rate_Plan_Charge__c> chargesList){
        Set<Id> setOrderRatePlanId               = new Set<Id>();
        set<Id> setOrderIds                      = new set<Id>();
        list<invoiceit_s__Job__c> orderstoUpdate = new list<invoiceit_s__Job__c>();
        
        for(invoiceit_s__Job_Rate_Plan_Charge__c charge : chargesList){
            charge.invoiceit_s__Status__c = 'Expired';
            System.debug('@@@@ charge' + charge);
            System.debug('@@@@ charge Status' + charge.invoiceit_s__Status__c );

            if(charge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.Charge_Expired__c == null
                 || charge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.Charge_Expired__c == false){
                setOrderIds.add(charge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c);
            }
        }
        
        invoiceit_s__Job__c order;
        for(Id orderId : setOrderIds){
            order = new invoiceit_s__Job__c(id = orderId, Charge_Expired__c = true);
            orderstoUpdate.add(order);
        } 
        
        database.update(chargesList, false);
        if(!orderstoUpdate.isEmpty()){
            database.update(orderstoUpdate, false);
        }
        System.debug('orderstoUpdate' + orderstoUpdate);
        
       
        
    }
    global void finish(Database.BatchableContext BC) {
        //calling MDL_BatchGenerateXMLforExpiredCharges batch class here
       if(!Test.isRunningTest()){
            Id batchJobId = database.executeBatch(new MDL_BatchGenerateXMLforExpiredCharges(),3);
          // Email_Ids_for_Batch_Process__mdt Expirybatch = Email_Ids_for_Batch_Process__mdt.getValues('Expiry Batch Job Process'); 
           
         
        }
        
        List<Email_Ids_for_Batch_Process__mdt> emailids= new List<Email_Ids_for_Batch_Process__mdt>();
          emailids = [Select id, DeveloperName, MasterLabel,Email_Ids_for_emailing__c, Link_for_Failure_Report__c,
                       Link_for_Success_Report__c From Email_Ids_for_Batch_Process__mdt Where MasterLabel = 'Expiry Batch Job Process'];
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
                mail.setSubject('Order Expiry Process batch report');      
                mail.setToAddresses(toEmailAddress);
                String body = '<html><body>The Order Expiry batch has completed running successfully<br><br>'+
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
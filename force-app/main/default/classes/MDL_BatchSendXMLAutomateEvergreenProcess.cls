/*****************************************************************************************
Created By : Lister Technologies
Created Date : June 9,2015
Created Purpose : MHBS-80 Automate Evergreen process
*****************************************************************************************/
global class MDL_BatchSendXMLAutomateEvergreenProcess implements Database.Batchable<sObject>,Database.AllowsCallouts {
    global String query;
    public Set<Id> setOrderRPCIds;
    public List<Id> lstOrderChargeAttributeIds;
    public Date oppCloseDate;
    public User user;
    public Set<Id> setOrderIds;
    global MDL_BatchSendXMLAutomateEvergreenProcess(Date closeDate){
        oppCloseDate = closeDate;
        user = [select Id, username from User where Id = :UserInfo.getUserId()];
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'Select Id from invoiceit_s__Job__c where invoiceit_crmx__Opportunity__r.CloseDate = :oppCloseDate and invoiceit_crmx__Opportunity__r.Quote_Type__c = \'Renew\' and invoiceit_crmx__Opportunity__r.Reason_Won_Lost__c = \'Auto Evergreen\' and invoiceit_crmx__Opportunity__r.Name like \'Auto evergreen%\' and invoiceit_s__Status__c = \'Evergreen\' and invoiceit_s__Account__r.Credit_Status__c!=\'Bad Debt\' and invoiceit_s__Account__r.Credit_Status__c!=\'Past Due\' and invoiceit_s__Account__r.Sub_Type__c = \'Small Law\' and (RecordType.DeveloperName = \'MH_Orders\' OR RecordType.DeveloperName = \'Nolo_Order\'OR RecordType.DeveloperName = \'M_NG_Order\')';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<invoiceit_s__Job__c> scope) {
        setOrderRPCIds = new Set<Id>();
        lstOrderChargeAttributeIds = new List<Id>();
        setOrderIds = new Set<Id>();
        for(invoiceit_s__Job__c order : scope){
            setOrderIds.add(order.Id);
        }
        for(invoiceit_s__Job_Rate_Plan_Charge__c orderRPC : [Select Id,(Select Id From Order_Charge_Attributes__r where (RecordType.DeveloperName = 'MDL_Order_Charge_Attribute' OR RecordType.DeveloperName = 'Nolo_Order_Charge_Attribute'OR RecordType.DeveloperName = 'M_NG_Order_Charge_Attribute')) from invoiceit_s__Job_Rate_Plan_Charge__c where invoiceit_s__Order__c in :setOrderIds and (RecordType.DeveloperName = 'MDL_Order_Rate_Plan_Charge' OR RecordType.DeveloperName = 'Nolo_Order_Rate_Plan_Charge'OR RecordType.DeveloperName = 'M_NG_Order_Rate_Plan_Charge')]){
            setOrderRPCIds.add(orderRPC.Id);
            for(Order_Charge_Attribute__c attribute : orderRPC.Order_Charge_Attributes__r){
                lstOrderChargeAttributeIds.add(attribute.Id);
            }
        }
        if(!Test.isRunningTest()){
            if(setOrderRPCIds.size() > 0){
                MDL_Integration_Vim_Efs.orderRequest(setOrderRPCIds, lstOrderChargeAttributeIds,user.username); 
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        Boolean dontExecute = false;
        for(AsyncApexJob batch :[Select ExtendedStatus,NumberOfErrors,Status,JobItemsProcessed,TotalJobItems from AsyncApexJob where Id = :BC.getJobId()]){         
            if(batch.JobItemsProcessed > 0){
                dontExecute = false;
            }
            else{
                dontExecute = true;
            }
        }
        if(dontExecute==false){
            Auto_Evergreen_Process__c autoEvergreen = Auto_Evergreen_Process__c.getValues('Auto Evergreen Process');
            String emailAddressString = autoEvergreen.Email_Ids_for_Auto_Evergreen_mail__c;
            String successReport = autoEvergreen.Link_for_Success_Report__c;
            String failureReport = autoEvergreen.Link_for_Failure_Report__c;
            String unmatchedReport = autoEvergreen.Link_for_report_with_unmatching_dates__c;
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
                mail.setSubject('Auto Evergreen Process batch report');      
                mail.setToAddresses(toEmailAddress);
                String body = '<html><body>The Auto Evergreen process batch has completed running successfully<br><br>'+
                'Click on the following links to view more details regarding the run:<br>';
                if(successReport != '')
                body += '(1) Report for success records : <a href="'+successReport+'">'+successReport+'</a><br>';
                if(failureReport != '')
                body += '(2) Report for failure records : <a href="'+failureReport+'">'+failureReport+'</a><br>';
                if(unmatchedReport !='')
                body += '(3) Report for orders and charges with unmatched Service End Date : <a href="'+unmatchedReport+'">'+unmatchedReport+'</a>';            
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
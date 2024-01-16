/*****************************************************************************************
Created By : Lister Technologies
Created Date : July 13th 2015
Created Purpose : MHBS-16 Send Credit Card Excpiry Notification 
*****************************************************************************************/

global class MDL_BatchCreditCardEmailNotification implements Database.Batchable<sObject> {   
global Date currentExpiry,nextMonthExpiry,nextNextMonthExpiry;
global List<Date> lstExpiryDates;
global MDL_BatchCreditCardEmailNotification(){    
       
}

global Database.QueryLocator start(Database.BatchableContext BC) {   
    lstExpiryDates = new List<Date>();
    currentExpiry = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
    nextMonthExpiry = Date.today().addMonths(2).toStartOfMonth().addDays(-1);
    nextNextMonthExpiry = Date.today().addMonths(3).toStartOfMonth().addDays(-1);
    lstExpiryDates.add(currentExpiry);
    lstExpiryDates.add(nextMonthExpiry);
    lstExpiryDates.add(nextNextMonthExpiry);
    String query = 'Select '+getObjectFields('invoiceit_s__Payment_Method__c')+' from invoiceit_s__Payment_Method__c where Expiration_Date__c in :lstExpiryDates and invoiceit_s__Payment_Method__c  = \'Credit Card\' and invoiceit_s__Active__c = TRUE and invoiceit_s__Default__c = TRUE ';
    if(Test.isRunningTest()){
        query += ' and invoiceit_s__Account__r.Name like \'%testAcc%\' LIMIT 5'; 
    }
    return Database.getQueryLocator(query);
}
 
global void execute(Database.BatchableContext BC, List<invoiceit_s__Payment_Method__c> scope){   
    Map<Id,Id> mapAccountIdNPayMethId = new Map<Id,Id>();   
    Map<Id,String> mapPayMethIdNContactName = new Map<Id,String>(); 
    Map<String,EmailTemplate> mapDaysNEmailTemplate = new Map<String,EmailTemplate>();  
    Contact con = [select id from contact where Name Like 'Michael Crosby%' and Account.Name like 'JV%Payment%Account%' LIMIT 1];
    /*List<String> emailidlist = new List<String>();
    emailidlist.add('internetbrands@listertechnologies.com');
    emailidlist.add('niketan.badani.1@martindale.com');
    emailidlist.add('lori.ashley@martindale.com');
    emailidlist.add('john.mattheson@martindale.com');
    emailidlist.add('nmohan@martindale.com');
    */
    currentExpiry = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
    nextMonthExpiry = Date.today().addMonths(2).toStartOfMonth().addDays(-1);
    nextNextMonthExpiry = Date.today().addMonths(3).toStartOfMonth().addDays(-1);
    for(invoiceit_s__Payment_Method__c paymentmethod : scope){
        mapAccountIdNPayMethId.put(paymentmethod.invoiceit_s__Account__c,paymentmethod.Id);
    }
    for(Account acc : [Select Id,(select invoiceit_s__Account__c,invoiceit_s__Billing_Contact__r.Name from invoiceit_s__Job__r where invoiceit_s__Status__c = 'Active' LIMIT 1) from Account where Id in :mapAccountIdNPayMethId.keyset()]){
        if(acc.invoiceit_s__Job__r.size() > 0){
            for(invoiceit_s__Job__c job : acc.invoiceit_s__Job__r){
                if(mapAccountIdNPayMethId.containsKey(acc.Id)){
                    mapPayMethIdNContactName.put(mapAccountIdNPayMethId.get(acc.Id),job.invoiceit_s__Billing_Contact__r.Name);
                }   
            }
        }
    }
    for(EmailTemplate emailTemp : [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE developerName = 'Card_Expiry_Notification_Email_template_for_30_days']){
        mapDaysNEmailTemplate.put('30',emailTemp);
    }
    for(EmailTemplate emailTemp : [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE developerName =  'Card_Expiry_Notification_Email_template_for_60_days']){
        mapDaysNEmailTemplate.put('60',emailTemp);
    }
    for(EmailTemplate emailTemp : [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE developerName =  'Card_Expiry_Notification_Email_template_for_90_days']){
        mapDaysNEmailTemplate.put('90',emailTemp);
    }
    try{
        for(invoiceit_s__Payment_Method__c paymentmethod : scope){
            List<Messaging.SingleEmailMessage> msgList= new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{}; 
            EmailTemplate emailTemplate;
            System.debug('$$$$'+paymentmethod.id);
            String plainBody = '';
            String ContactName = '';
            if(mapPayMethIdNContactName.containsKey(paymentmethod.Id)){
                ContactName = mapPayMethIdNContactName.get(paymentmethod.Id);
            }
            if(mapPayMethIdNContactName.containsKey(paymentmethod.Id)){
                if(paymentmethod.Expiration_Date__c == currentExpiry && mapDaysNEmailTemplate.containsKey('30')){           
                    emailTemplate = mapDaysNEmailTemplate.get('30'); 
                }
                else if(paymentmethod.Expiration_Date__c == nextMonthExpiry && mapDaysNEmailTemplate.containsKey('60')){
                    emailTemplate = mapDaysNEmailTemplate.get('60');
                }
                else if(paymentmethod.Expiration_Date__c == nextNextMonthExpiry && mapDaysNEmailTemplate.containsKey('90')){
                    emailTemplate = mapDaysNEmailTemplate.get('90');
                }
                if(paymentmethod.Account_Owner_Email__c != NULL){
                    toAddresses.add(paymentmethod.Account_Owner_Email__c);
                   /* for(String s : emailidlist){
                        if(s == paymentmethod.Account_Owner_Email__c){
                         toAddresses.add(paymentmethod.Account_Owner_Email__c);
                        }
                    }*/
                }
                if(paymentmethod.Collector_Email__c != NULL){
                    toAddresses.add(paymentmethod.Collector_Email__c);
                    /*for(String s : emailidlist){
                        if(s == paymentmethod.Collector_Email__c){
                         toAddresses.add(paymentmethod.Collector_Email__c);
                        }
                    }*/
                }               
                if(toAddresses.size() > 0 && emailTemplate != null){
                   mail.setToAddresses(toAddresses) ;  
                   mail.setWhatId(paymentmethod.id);
                   mail.setTargetObjectId(con.Id);
                   mail.setTemplateId(emailTemplate.Id);
                   msgList.add(mail);
                   //Email is rolled back so that only the email body is populated and the mail is not sent
                   Savepoint sp = Database.setSavepoint();
                        Messaging.sendEmail(msgList);
                   Database.rollback(sp);
                   
                   List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
                   for(Messaging.SingleEmailMessage email : msgList) {
                       Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                       emailToSend.setToAddresses(email.getToAddresses());
                       plainBody = email.getPlainTextBody();
                       system.debug('@@@@email.getToAddresses' + email.getToAddresses());
                       if(plainBody != null){
                           plainBody = plainBody.subString(0,plainBody.indexOf(',',0))+ContactName+plainBody.subString(plainBody.indexOf(',',0),plainBody.length());
                       }
                       emailToSend.setPlainTextBody(plainBody);
                       emailToSend.setSubject(email.getSubject());
                       msgListToBeSend.add(emailToSend);
                   }
                   if(!Test.isRunningTest()){
                        Messaging.sendEmail(msgListToBeSend);
                   }
                }               
            }
        }  
    }catch(exception e){
        system.debug('@@@@exception '+e);
    }
   
 }
 public static String getObjectFields(String objectName) {
        String sQuery = '';
        Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for(Schema.SObjectField column: objectFieldMap.values()) {
            sQuery += column+', ';
        }
        sQuery = sQuery.substring(0, sQuery.length()-2);
        sQuery += ' ';
        return sQuery;
 }
     
  global void finish(Database.BatchableContext BC){
        
  }   
 }
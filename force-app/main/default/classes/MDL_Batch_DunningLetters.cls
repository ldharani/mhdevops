global with sharing class MDL_Batch_DunningLetters implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts  {
    /*global Date firstDunningDate ; 
    global Date secondDunningDate ; 
    global Date thirdDunningDate ; 
    global String TestAccId;
    global List<String> listOfAccId;
    public MDL_Batch_DunningLetters(){
        firstDunningDate = system.today() - 30;
        secondDunningDate = system.today() - 60;
        thirdDunningDate = system.today() - 90;
        TestAccId = '001L000000KYULK';
        listOfAccId = new List<String>();
        listOfAccId.add('001L000000KYg2dIAD');
        
    }*/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        /*String query = 'Select Id ,Name,  invoiceit_s__Invoice_Date__c ,'+    
                                'invoiceit_s__Unpaid_Amount__c, invoiceit_s__Due_Date__c,'+
                                'invoiceit_s__Account__r.MH_Cust_Number__c , '+
                                'invoiceit_s__Account__r.Hold_dunning_letter_till__c , invoiceit_s__Account__c , ' +
                                'invoiceit_s__Account__r.Dunning_Hold_for_30_days__c ' +
                                'from invoiceit_s__Invoice__c ' + 
                                'where (invoiceit_s__Due_Date__c =: firstDunningDate ' +
                                'Or invoiceit_s__Due_Date__c =: secondDunningDate ' +
                                'Or invoiceit_s__Due_Date__c =: thirdDunningDate ) ' +
                                'And (invoiceit_s__Account__r.Hold_dunning_letter_till__c >: firstDunningDate ' +
                                'Or invoiceit_s__Account__r.Hold_dunning_letter_till__c = null ) ' +
                                'And  invoiceit_s__Account__c in :listOfAccId ';*/
                                
        String query = 'Select Id,MH_Cust_Number__c,Hold_dunning_letter_till__c,Dunning_Hold_for_30_days__c, '+
                                    'RecordType.DeveloperName , '+
                                    
                                    '(Select invoiceit_s__Due_Date__c, invoiceit_s__Unpaid_Amount__c , invoiceit_s__Account__c, invoiceit_s__Account__r.Hold_dunning_letter_till__c,  '+                                 // INVOICE SUB QUERY
                                    'RecordType.DeveloperName '+
                                    'From invoiceit_s__Invoices__r ' + 
                                    'where (invoiceit_s__Due_Date__c =: firstDunningDate '+
                                    'Or invoiceit_s__Due_Date__c =: secondDunningDate Or invoiceit_s__Due_Date__c =: thirdDunningDate) '+
                                    'And RecordType.DeveloperName = \'MH_Invoices\' And invoiceit_s__Unpaid_Amount__c > 0), ' + 
                                    //'AND (invoiceit_s__Due_Date__c < invoiceit_s__Account__r.Hold_dunning_letter_till__c '+
                                    //'OR invoiceit_s__Account__r.Hold_dunning_letter_till__c = null) ), ' + 
                                    
                                    '(Select Id, invoiceit_s__Payment_Date__c , invoiceit_s__Account__c , invoiceit_s__Account__r.Hold_dunning_letter_till__c , '+
                                    'RecordType.DeveloperName '+ 
                                    'from Payments__r ' +                                                       //PAYMENT SUB QUERY
                                    'where (invoiceit_s__Payment_Date__c =: firstDunningDate ' + 
                                    'OR invoiceit_s__Payment_Date__c =: secondDunningDate ' +
                                    'OR invoiceit_s__Payment_Date__c =: thirdDunningDate)) '+
                                    //'AND (invoiceit_s__Payment_Date__c < invoiceit_s__Account__r.Hold_dunning_letter_till__c '+
                                    //'OR invoiceit_s__Account__r.Hold_dunning_letter_till__c = null) ) ' +
                                    'from Account ' + //where Id in :listOfAccId;
                                    'where RecordType.DeveloperName = \'MH_Accounts\' ' ; 
                                    //'and Id in :listOfAccId ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        /*system.debug(' +++ ' + scope);
        
        
        set<String> accId_DaysBetween = new set<String>();
        List<Messaging.EmailFileAttachment> mailingListAttachment  = new List<Messaging.EmailFileAttachment>();
        
        List<List<Messaging.EmailFileAttachment>> listOfListOfMailingListAttachment  = new List<List<Messaging.EmailFileAttachment>>();
        for(Account acc : scope){
            system.debug('check1 ' + acc.Id + ' '  + acc.RecordType.DeveloperName);
            if(acc.RecordType.DeveloperName == 'MH_Accounts'){
                    system.debug('check2 ' + acc.invoiceit_s__Invoices__r.size());
                    for(invoiceit_s__Invoice__c iterInv : acc.invoiceit_s__Invoices__r){
                        system.debug('check3 ' + iterInv.Id + ' ' + iterInv.RecordType.DeveloperName);          
                        if((acc.Hold_dunning_letter_till__c < iterinv.invoiceit_s__Due_Date__c || 
                            acc.Hold_dunning_letter_till__c == null) && iterInv.invoiceit_s__Unpaid_Amount__c > 0 && 
                            iterInv.RecordType.DeveloperName == 'MH_Invoices'){             
                            Integer daysBetween = iterInv.invoiceit_s__Due_Date__c.daysBetween(system.today());
                            system.debug('@days ' + daysBetween);
                            if(!accId_DaysBetween.contains(iterInv.invoiceit_s__Account__c + '-' + daysBetween)){ 
                                accId_DaysBetween.add(iterInv.invoiceit_s__Account__c + '-' + daysBetween);             
                                    if(daysBetween == 30){                      
                                        //mailingListAttachment.add(MDL_Ctrl_SendEmail.sendDunningLetter1(iterInv.invoiceit_s__Account__c , 30));                     
                                    }                       
                                    if(daysBetween == 60){                      
                                        //mailingListAttachment.add(MDL_Ctrl_SendEmail.sendDunningLetter1(iterInv.invoiceit_s__Account__c , 60));             
                                    }
                                    if(daysBetween == 90){
                                        //mailingListAttachment.add(MDL_Ctrl_SendEmail.sendDunningLetter1(iterInv.invoiceit_s__Account__c , 90));                                         
                                    }
                            }
                        }
                    }
            }
            for(invoiceit_s__Payment__c iterPay : acc.Payments__r){
                if(acc.Hold_dunning_letter_till__c < iterPay.invoiceit_s__Payment_Date__c || 
                    acc.Hold_dunning_letter_till__c == null){               
                    Integer daysBetween = iterPay.invoiceit_s__Payment_Date__c.daysBetween(system.today());
                    system.debug('@days ' + daysBetween);
                    if(!accId_DaysBetween.contains(iterPay.invoiceit_s__Account__c + '-' + daysBetween)){ 
                        accId_DaysBetween.add(iterPay.invoiceit_s__Account__c + '-' + daysBetween);             
                            if(daysBetween == 30){                      
                                mailingListAttachment.add(MDL_Ctrl_SendEmail.sendDunningLetter1(iterPay.invoiceit_s__Account__c , 30));                     
                            }                       
                            if(daysBetween == 60){                      
                                mailingListAttachment.add(MDL_Ctrl_SendEmail.sendDunningLetter1(iterPay.invoiceit_s__Account__c , 60));             
                            }
                            if(daysBetween == 90){
                                mailingListAttachment.add(MDL_Ctrl_SendEmail.sendDunningLetter1(iterPay.invoiceit_s__Account__c , 90));                                         
                            }
                    }
                }
            }
            
            if(mailingListAttachment.size() >= 300){
                listOfListOfMailingListAttachment.add(mailingListAttachment);
                mailingListAttachment.clear();
            }       
        }
        
        if(mailingListAttachment.size() > 0)
            listOfListOfMailingListAttachment.add(mailingListAttachment);
             system.debug('-----attach ' + mailingListAttachment.size());
             
             String emailMsg = 'HI ,'+'\r\n';
             emailMsg += 'PFA of the Dunning Letter. ';
             List<String> toAddress = new List<String>();
             toAddress.add('venkataraman.sriram@listertechnologies.com');
             toAddress.add('john.mattheson@martindale.com');
             toAddress.add('niketan.badani.1@martindale.com');
             toAddress.add('randy.booth@martindale.com');
             //Creating a SingleEmail
             for(List<Messaging.EmailFileAttachment> attachmentList : listOfListOfMailingListAttachment){
                 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                 mail.setSubject('Dunning Letter Attachment');
                 mail.setHtmlBody(emailMsg);
                 mail.setToAddresses(toAddress);
                 mail.setFileAttachments(attachmentList);           
                 Messaging.SendEmail(new Messaging.SingleEmailMessage[] { mail });
             }
             */
    }
     
     
    global void finish(Database.BatchableContext BC) {
       
    } 
}
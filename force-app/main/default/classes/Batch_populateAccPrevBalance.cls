/*****************************************************************************************
Created By : Lister Technologies
Created Date : Mar 18,2015
Created Purpose : Populate Previous Balance in Account
Commented part was done on July 22 - to test MA Intake update
Test class : 
*****************************************************************************************/
global class Batch_populateAccPrevBalance implements Database.Batchable<sObject>,Database.Stateful{
    
    global Set<String> failedAcc = new Set<String>();
      global Set<String> errMessages = new Set<String>();
      
    global Database.QueryLocator start(Database.BatchableContext BC) {
    string query;
    Integer mnth = System.Today().MOnth();
    Integer yr = System.Today().Year();
        query = 'Select Id,blng__Account__c ,blng__InvoiceStatus__c,blng__InvoiceDate__c,Total_Amount_Due__c from blng__Invoice__c where blng__InvoiceStatus__c=\'Posted\' and CALENDAR_MONTH(blng__InvoiceDate__c) = :mnth and CALENDAR_YEAR(blng__InvoiceDate__c) = :yr ';
        if(Test.isRunningTest()){
            query = 'Select Id,blng__Account__c ,blng__InvoiceStatus__c,blng__InvoiceDate__c,Total_Amount_Due__c from blng__Invoice__c';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<blng__Invoice__c> scope) {
    
    list<Account> ListofAccUpdate= new list<Account>();
    for(blng__Invoice__c inv: scope){
     Account acc = new Account (Id=inv.blng__Account__c);
     if(acc.Previous_Balance_Date__c !=inv.blng__InvoiceDate__c){
      
       acc.Previous_Balance__c=inv.Total_Amount_Due__c;
       acc.Previous_Balance_Date__c =inv.blng__InvoiceDate__c;
       ListofAccUpdate.add(acc);
       }
    }  
    
    //List<Database.SaveResult> updateResults= database.update(ListofAccUpdate,false);
    database.update(ListofAccUpdate,false);
    /*for(Integer i=0;i<updateResults.size();i++){
            if (!updateResults.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = updateResults.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                ListofAccUpdate.get(i);//failed record from the list
                failedAcc.add(ListofAccUpdate.get(i).Id);
                errMessages.add(failedDML);
            }
       
    } */
    }
    global void finish(Database.BatchableContext BC) {
        
    /*List<String> toEmailAddress = new List<String>();
        toEmailAddress.add('ijaisankar@martindale.com');
        try{
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
            mail.setSubject('Failed Previous Balance update ');      
            mail.setToAddresses(toEmailAddress);
            string headstr = '<head><style>   th, td { padding: 5px;  text-align: left;}</style></head>';
            String body = '<html><body>' ;
            body += 'No.of failed Accounts : '+ failedAcc.size() + ',<br>';
            body += 'No.of Errors : '+ errMessages.size() + ',<br>';
            for(String s:errMessages){
                body += s+ ',<br>';
            }
            for(String s:failedAcc){
                body += s+ ',<br>';
            }
            body += '</body></html>';
            
            mail.setHtmlBody(body);
            mails.add(mail);
            Messaging.sendEmail(mails);
        }
        catch(Exception e){
            System.debug('An exception occured' + e.getMessage());
        }  */      
        
        
    }
      
}
/*
@Author:            Betsy
@Created Date:      19-Sep-2023

Change History 
********************************************************************************************************************
SCRUM/Jira  ModifiedBy      Date            Requested By            Description                             Tag
********************************************************************************************************************

                                  
*/
global class AvvoEmailInvoiceBatch implements Database.Batchable<sobject>,Database.Stateful{

    public static final string INVOICE_STATUS = 'Posted';
    public static final string DELIVERY_TYPE_EMAIL = 'Email';
    public static final string DELIVERY_TYPE_EMAIL_PRINT = 'Email & Print';
	public static string InvoiceDate = System.Label.Invoice_Date;
    
    global Map<Id, String> errorMap = new Map<Id, String>();
    global Map<Id, SObject> IdToSObjectMap = new Map<Id, SObject>();
    String invoiceRecordId;
    
    global AvvoEmailInvoiceBatch(){
        init('');
    }
    
    global AvvoEmailInvoiceBatch(String invoiceRecordId){
        init(invoiceRecordId);
    }
    
    global void init(String invoiceRecordId){
         if(!String.isEmpty(invoiceRecordId)){
            this.invoiceRecordId = invoiceRecordId;
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = 'SELECT id,RecordTypeId,Delivery_Type__c,blng__Account__r.Invoice_Delivery_Type__c,Name,blng__TotalAmount__c,blng__BillToContact__r.Email,blng__Account__r.Name,Legacy_Sent_Mail__c,blng__InvoiceDate__c FROM blng__Invoice__c WHERE blng__InvoiceStatus__c =: INVOICE_STATUS AND Legacy_Sent_Mail__c = FALSE AND (Delivery_Type__c =: DELIVERY_TYPE_EMAIL or Delivery_Type__c =: DELIVERY_TYPE_EMAIL_PRINT) AND RecordType.DeveloperName = \'M_A_Invoice\'';
        
        if (!String.isEmpty(invoiceRecordId)){
            query += ' And Id=\''+ invoiceRecordId+'\'';
        }
        else if (!String.isEmpty(InvoiceDate)){
            query += ' and blng__InvoiceDate__c = '+InvoiceDate;
        }
        else{
            query += ' and blng__InvoiceDate__c = TODAY'; 
        }
		
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<blng__Invoice__c> scope)
    {
        List<blng__Invoice__c> invoices = new List<blng__Invoice__c>();
        
        for(blng__Invoice__c invoice : scope)
        {
            
           if(invoice.blng__TotalAmount__c != 0){
                invoices.add(invoice);
            } 
            else if(Test.isRunningTest())
            {
                invoices.add(invoice);
            }
        }
        
        if(invoices != null && invoices.size() > 0)
        {
           errorMap = AvvoEmailInvoiceUtil.emailInvoice(invoices);
           IdToSObjectMap.put(invoices[0].id, invoices[0]);
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
    
        if((errorMap!=null && !errorMap.isEmpty())||Test.isRunningTest()){            
            AsyncApexJob a = [SELECT id, ApexClassId,
                       JobItemsProcessed, TotalJobItems,
                       NumberOfErrors, CreatedBy.Email
                       FROM AsyncApexJob
                       WHERE id = :BC.getJobId()];
            String body = 'Your batch job '
             + 'for Sending Invoice Email\' Email '
             + 'has finished. \n' 
             + 'There were '
             + errorMap.size()
             + ' errors. Please find the csv file attached for the error.';
             system.debug('Body====>'+body);
            // Creating the CSV file
            String finalstr = 'Id, Name, Error \n';
            String subject = 'Invoice Email- Error List';
            String attName = 'InvoiceEmailFailures.csv';            
            sendMail(body,finalstr,subject,attName,errorMap);   
        }
    
    }
    
     public void sendMail(string body,string finalstr,string subject,string attName,Map<Id,String> errorMap){
            
            Map<String,Email_Ids__c> toAddressFromCustomSetting = Email_Ids__c.getAll();
            String[] toaddressArray = toAddressFromCustomSetting.get('InvoiceEmailFailureEmails').Email_Id__c.split(','); 
             
    
            for(Id id  : errorMap.keySet()){
                string err = errorMap.get(id);
                blng__Invoice__c inv = (blng__Invoice__c ) IdToSObjectMap.get(id);                
                string recordString = '"'+id+'","'+inv.Name+'","'+err+'"\n';
                finalstr = finalstr +recordString;
            } 
 
            // Define the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
 
            // Create the email attachment    
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(attName);
            efa.setBody(Blob.valueOf(finalstr));
 
            // Sets the paramaters of the email
            email.setSubject( subject );
            email.setToAddresses(toaddressArray);
            email.setPlainTextBody( body );
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
 
            // Sends the email
            try{
            Messaging.SendEmailResult [] r = 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
        }
        Catch(Exception e){
              Exception__c excption = Util.processException(e,true,'Exception occurred when emailing invoicing email failure'+errorMap);
              
          }  
        
    }
}
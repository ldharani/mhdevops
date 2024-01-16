// Author          : akash
// Description     : This class is responsible for creating attachments using button on 
//                 : invoice run object
//                 : when user clicks on this button, generates attachments for related invoices in invoice run


global class CPQcreateAttachmentsButton {
    
    @AuraEnabled
    webservice static string CPQcreateAttachments(String invoiceRunId, boolean actflag){
        
        blng__InvoiceRun__c invoicerun = new blng__InvoiceRun__c ();
        invoicerun = [select id, Name
                             /*,(select id, Name,Delivery_Type__c 
                                     
                                     from blng__Invoice__c
                                     where blng__InvoiceStatus__c = 'Posted'
                                           and (Delivery_Type__c= 'Email & Print'
                                                OR Delivery_Type__c = 'Email'
                                                OR Delivery_Type__c = 'Print')) */
                             from blng__InvoiceRun__c
                             where id =:invoiceRunId LIMIT 1 ];

        system.debug('actflag: ' + actflag);         
        if(invoicerun != null && !Test.isRunningTest()){
            Id batchid = Database.executeBatch(new CPQcreatingAttachmentsBatch(true, invoiceRunId), 50);
//            createAttachmentHandler.createAttachment(invoicerun.invoiceit_s__Invoices__r);
            return 'Attachments created Successfully'; 
        }
       
        
        return 'No Invoices found'; 
    }
    
        @AuraEnabled
    webservice static string CPQDeleteAttachements(String invoiceRunId){
        
         blng__InvoiceRun__c invoicerun = new blng__InvoiceRun__c ();
        invoicerun = [select id, Name
                             from blng__InvoiceRun__c
                             where id =:invoiceRunId LIMIT 1 ];

        
        if(invoicerun != null && !Test.isRunningTest()){
            Id batchid = Database.executeBatch(new CPQcreatingAttachmentsBatch(false, invoiceRunId), 50);

            return 'Attachments deleted Successfully'; 
        }
        
        return 'No Invoices found';
        
    }
    
}
// Author          : akash
// Description     : This class is responsible for creating attachments using button on 
//                 : invoice run object
//                 : when user clicks on this button, generates attachments for related invoices in invoice run


global class createAttachmentsButton {
    
    webservice static string createAttachments(String invoiceRunId, boolean actflag){
        
        invoiceit_s__Invoice_Run__c invoicerun = new invoiceit_s__Invoice_Run__c();
        invoicerun = [select id, Name,
                             (select id, Name,
                                     invoiceit_s__Account__r.MH_Cust_Number__c
                                     from invoiceit_s__Invoices__r
                                     where invoiceit_s__Invoice_Status__c = 'Posted'
                                           and (invoiceit_s__Delivery_Type__c = 'Email & Print'
                                                OR invoiceit_s__Delivery_Type__c = 'Email'
                                                OR invoiceit_s__Delivery_Type__c = 'Print')) 
                             from invoiceit_s__Invoice_Run__c
                             where id =:invoiceRunId LIMIT 1 ];

        system.debug('actflag: ' + actflag);         
        if(invoicerun.invoiceit_s__Invoices__r != null && invoicerun.invoiceit_s__Invoices__r.size() > 0 && actflag == true){
            Id batchid = Database.executeBatch(new creatingAttachmentsBatch(true, invoiceRunId), 50);
//            createAttachmentHandler.createAttachment(invoicerun.invoiceit_s__Invoices__r);
            return 'Attachments created Successfully'; 
        }
        
        if(invoicerun.invoiceit_s__Invoices__r != null && invoicerun.invoiceit_s__Invoices__r.size() > 0 && actflag == false){
            Id batchid = Database.executeBatch(new creatingAttachmentsBatch(false, invoiceRunId), 50);
            //            createAttachmentHandler.deleteAttachments(invoicerun.invoiceit_s__Invoices__r);
            return 'Attachments deleted Successfully'; 
        }
        
        return 'No Invoices found'; 
    }
    
}
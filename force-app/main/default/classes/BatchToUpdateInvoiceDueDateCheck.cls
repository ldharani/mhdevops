/***************
* Class Name: BatchToUpdateInvoiceDueDateCheck
* Test Class: 
* Description: MHBS-9265: Customers with a past due balance but Past Due Balance Field = 0
* Developed By: Jeyamugundan
* Modification History : Created on May 24,2023* 
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHMAC-622     Chetna     12/25/2024                     T01     Include M-A RecordType for Invoice related batch processes
*/ 
global class BatchToUpdateInvoiceDueDateCheck implements Database.Batchable<sObject>,Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(test.isRunningTest()){
            return Database.getQueryLocator( [SELECT Id,blng__Balance__c,blng__InvoiceStatus__c,blng__PaymentStatus__c,RecordType.Developername FROM blng__Invoice__c LIMIT 1]);
        }else{
            return Database.getQueryLocator( [SELECT Id,blng__Balance__c,blng__InvoiceStatus__c,blng__PaymentStatus__c,RecordType.Developername FROM blng__Invoice__c 
                                              WHERE blng__Balance__c > 0 AND blng__InvoiceStatus__c = 'Posted' AND blng__PaymentStatus__c != 'Paid' AND (RecordType.Developername = 'MH_Invoice' OR RecordType.Developername = 'M_A_Invoice') AND
                                              Is_Due_Date_Less_than_Today__c = False AND blng__DueDate__c < TODAY] );//<T01>
        }
    }
    global void execute(Database.BatchableContext BC, List<blng__Invoice__c> newinvoice){
        List<blng__Invoice__c> InvoiceListUpdate = new List<blng__Invoice__c>();
        for(blng__Invoice__c inv : newinvoice){
            inv.Is_Due_Date_Less_than_Today__c = true;  
            InvoiceListUpdate.add(inv);   
        }
        
        try{
            if(InvoiceListUpdate.Size() > 0){
                Update InvoiceListUpdate;
            }
        }catch(Exception e){
            Util.processException(e,true,'Invoice Update Fail on BatchToUpdateInvoiceDueDateCheck' + InvoiceListUpdate);
        }
        
    }  
    global void finish(Database.BatchableContext bc){
    }  
}
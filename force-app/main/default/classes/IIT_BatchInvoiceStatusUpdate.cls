global class IIT_BatchInvoiceStatusUpdate implements Database.Batchable<sObject>,database.stateful{
   global string sQuery;
   global string InvoiceStatus = 'Draft';
   global invoiceit_s__Batch_Jobs__c batchJob;
   global string errorLog = null;
   global IIT_BatchInvoiceStatusUpdate(string query){
      this.sQuery = query;
       batchJob = new invoiceit_s__Batch_Jobs__c(Name = 'BatchInvoiceStatusUpdate- ' + system.today(), invoiceit_s__Type__c = 'BatchInvoiceStatusUpdate', invoiceit_s__Start_Date_and_Time__c = system.now(), invoiceit_s__Status__c = 'Processing');
       insert batchJob;  
    }
   
   
   global Database.querylocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(sQuery);
    }
 
    global void execute(Database.BatchableContext BC, List<invoiceit_s__Invoice__c> scope){
         try {
             list<invoiceit_s__Invoice__c> listOfInvoice = new  list<invoiceit_s__Invoice__c>();
             invoiceit_s__Invoice__c invToUpdate;
             for(invoiceit_s__Invoice__c inv : scope) {
                 invToUpdate = new invoiceit_s__Invoice__c(id = inv.id,invoiceit_s__Invoice_Status__c = 'Posted');
                 listOfInvoice.add(invToUpdate);
             }
             update listOfInvoice;
         } catch(exception ex) {
            errorLog += '\n' + 'An exception has occured, exception type is ' + ex.getTypeName() + ':'+ex.getMessage() + ':' + ex.getLineNumber() + ':' + ex.getStackTraceString() + '\n';
        }  
         
   }
     
    global void finish(Database.BatchableContext BC){
        batchJob.invoiceit_s__Completed_Date_and_Time__c = system.now();

        if(errorLog == null) {
            batchJob.invoiceit_s__Status__c = 'Completed';
        } else {
            batchJob.invoiceit_s__Status__c = 'Completed with Errors';
            
            if(errorLog.Length() < 32768) {
                batchJob.invoiceit_s__Exception_Log__c = errorLog; 
            } 
        }

        update batchJob;
    }
}
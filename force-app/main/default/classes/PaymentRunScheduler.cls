global class PaymentRunScheduler implements Schedulable{
  
  set<Id> setofPaymentRunIds;
  global PaymentRunScheduler(set<Id> setofPaymentRunIDs) {
        this.setofPaymentRunIds = setofPaymentRunIDs; 
    }
    
   global void execute(SchedulableContext sc) {
       string sQuery = 'SELECT Id FROM invoiceit_s__Transaction__c';
    BatchProcessRetryFailedTransaction batch = new BatchProcessRetryFailedTransaction(sQuery,setofPaymentRunIds, null);
    Id batchId = dataBase.executebatch(batch, 1);
   }
}
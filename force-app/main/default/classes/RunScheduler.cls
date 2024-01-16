global class RunScheduler implements Schedulable {
  set<Id> setofRun;
  global RunScheduler(set<Id> setofRunIDs) {
        this.setofRun = setofRunIDs; 
    }
    
   global void execute(SchedulableContext sc) {
    BatchProcessArrearsInvoice batch = new BatchProcessArrearsInvoice(setofRun);
    Id batchId = dataBase.executebatch(batch,1);
   }
}
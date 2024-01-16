global class CPQ_MDL_ScheduleBatchQuoteLinesExpiry implements Schedulable{
  global void execute(SchedulableContext SC) { 
    CPQ_BatchQuoteLinesExpiry b = new CPQ_BatchQuoteLinesExpiry();
    Database.executeBatch(b, 1);
  }
}
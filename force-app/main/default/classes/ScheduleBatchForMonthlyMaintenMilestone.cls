global class ScheduleBatchForMonthlyMaintenMilestone implements Schedulable{
  global void execute(SchedulableContext SC) { 
    BatchProcesForMaintenanceMilestone b = new BatchProcesForMaintenanceMilestone();
    Database.executeBatch(b,1); 
  }
}
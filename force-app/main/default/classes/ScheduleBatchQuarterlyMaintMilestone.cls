global class ScheduleBatchQuarterlyMaintMilestone implements Schedulable{
  global void execute(SchedulableContext SC) { 
    BatchProcessForQuarterlyMaintMilestone b = new BatchProcessForQuarterlyMaintMilestone();
    Database.executeBatch(b,1); 
  }
}
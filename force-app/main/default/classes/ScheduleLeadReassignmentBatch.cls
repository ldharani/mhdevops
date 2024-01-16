global class ScheduleLeadReassignmentBatch implements Schedulable{
  global void execute(SchedulableContext SC) { 
    LeadReassignmentBatch b = new LeadReassignmentBatch();
    Database.executeBatch(b,1); 
  }
}
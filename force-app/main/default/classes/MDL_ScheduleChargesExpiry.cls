global class MDL_ScheduleChargesExpiry implements Schedulable{
  global void execute(SchedulableContext SC) { 
    MDL_BatchChargesExpiry b = new MDL_BatchChargesExpiry();
    Database.executeBatch(b,1);
  }
}
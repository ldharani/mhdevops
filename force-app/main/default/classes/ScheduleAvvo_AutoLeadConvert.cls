global class ScheduleAvvo_AutoLeadConvert implements Schedulable{
  global void execute(SchedulableContext SC) { 
    Avvo_AutoLeadConvert b = new Avvo_AutoLeadConvert();
    Database.executeBatch(b,1); 
  }
}
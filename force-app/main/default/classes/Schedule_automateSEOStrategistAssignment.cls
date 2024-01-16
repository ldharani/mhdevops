/*added by saiv - MHBS-6700 - 08/22/20222*/
global class Schedule_automateSEOStrategistAssignment implements Schedulable{
	global void execute(SchedulableContext SC) { 
    Batch_automateSEOStrategistAssignment b = new Batch_automateSEOStrategistAssignment();
    Database.executeBatch(b, 1);
  }
}
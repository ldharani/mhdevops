global class MDL_ScheduleOrderExpiry implements Schedulable{
	global void execute(SchedulableContext SC) { 
		MDL_BatchOrderExpiry b = new MDL_BatchOrderExpiry();
		Database.executeBatch(b,9);
	}
}
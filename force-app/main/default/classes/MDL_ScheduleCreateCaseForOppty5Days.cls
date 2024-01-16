global class MDL_ScheduleCreateCaseForOppty5Days implements Schedulable{
	global void execute(SchedulableContext SC) { 
		MDL_BatchCreateCaseForOppty5Days b = new MDL_BatchCreateCaseForOppty5Days();
		Database.executeBatch(b);
	}
}
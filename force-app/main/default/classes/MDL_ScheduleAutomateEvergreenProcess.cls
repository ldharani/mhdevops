global class MDL_ScheduleAutomateEvergreenProcess implements Schedulable{
	global void execute(SchedulableContext SC) { 
		MDL_BatchAutomateEvergreenProcess b = new MDL_BatchAutomateEvergreenProcess();
		Database.executeBatch(b,1);
	}
}
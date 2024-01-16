global class MDL_ScheduleReSendHTTPRequests implements Schedulable{
	global void execute(SchedulableContext SC) { 
		MDL_BatchReSendHttpRequests b = new MDL_BatchReSendHttpRequests();
		Database.executeBatch(b,9);
	}
}
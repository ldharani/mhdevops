global class MDL_ScheduleCreateCaseForOrders120Days implements Schedulable{
	global void execute(SchedulableContext SC) { 
		MDl_BatchCreateCaseForOrders120Days b = new MDl_BatchCreateCaseForOrders120Days();
		Database.executeBatch(b);
	}
}
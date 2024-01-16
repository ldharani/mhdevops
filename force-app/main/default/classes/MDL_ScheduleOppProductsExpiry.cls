global class MDL_ScheduleOppProductsExpiry implements Schedulable{
	global void execute(SchedulableContext SC) { 
		MDL_BatchOppProductsExpiry b = new MDL_BatchOppProductsExpiry();
		Database.executeBatch(b);
	}
}
global class MDL_ScheduleSendReleaseInvForTruncate implements Schedulable{
	global void execute(SchedulableContext SC) { 
		MDL_BatchSendReleaseInventoryForTruncate b = new MDL_BatchSendReleaseInventoryForTruncate();
		Database.executeBatch(b,9);
	}
}
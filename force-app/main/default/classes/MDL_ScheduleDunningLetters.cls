global class MDL_ScheduleDunningLetters implements Schedulable{
	global void execute(SchedulableContext SC) { 
		MDL_Batch_DunningLetters b = new MDL_Batch_DunningLetters();
		Database.executeBatch(b);
	}
}
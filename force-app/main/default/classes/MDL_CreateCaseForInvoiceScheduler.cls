global class MDL_CreateCaseForInvoiceScheduler implements Schedulable {
	global void execute(SchedulableContext SC) { 
		MDL_Batch_CreateCaseForInvoice m = new MDL_Batch_CreateCaseForInvoice();
		Database.executeBatch(m);
	}
}
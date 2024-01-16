global class MDL_InvoiceReportScheduler implements Schedulable {
	global void execute(SchedulableContext SC) { 
		MDL_Batch_InvoiceReportGenerator b = new MDL_Batch_InvoiceReportGenerator();
		Database.executeBatch(b);
	}
}
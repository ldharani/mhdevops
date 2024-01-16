global class MDL_GenerateCSVFromButton {
	webservice static boolean generateCSV(String invoiceRunId){
		boolean isRunning = false;
		for(AsyncApexJob jobs : [Select Id from AsyncApexJob where ApexClass.Name like 'InvoiceCSV%Batch' and Status in ('Holding','Queued','Preparing','Processing')]){
			isRunning = true;
		}
		if(isRunning==false){
			if(!Test.isRunningTest()){
				InvoiceCSVBatch b = new InvoiceCSVBatch(invoiceRunId);
				Database.executeBatch(b,100);
			}
		}
		return isRunning;		
	}
}
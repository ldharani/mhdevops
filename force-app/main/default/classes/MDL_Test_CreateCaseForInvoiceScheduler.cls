@isTest
private class MDL_Test_CreateCaseForInvoiceScheduler {
    static testMethod void scheduleForInvoice(){
        MDL_CreateCaseForInvoiceScheduler m = new MDL_CreateCaseForInvoiceScheduler();
    	String sch = '0 0 23 * * ?';
    	system.schedule('Test check', sch, m);
    }
}
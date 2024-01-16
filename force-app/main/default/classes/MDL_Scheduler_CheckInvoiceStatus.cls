global with sharing class MDL_Scheduler_CheckInvoiceStatus implements Schedulable{
    global void execute(SchedulableContext sc) {
        MDL_CheckInvoiceStatus c = new MDL_CheckInvoiceStatus();
        Database.executebatch(c);
    }
}
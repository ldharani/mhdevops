@isTest
private class MDL_Test_ScheduleCreditValidAfter5Days{
    static testMethod void scheduleForInvoice(){
        MDL_ScheduleCreditValidationAfter5Days  m = new MDL_ScheduleCreditValidationAfter5Days ();
      String sch = '0 0 23 * * ?';
      system.schedule('Test check', sch, m);
    }
}
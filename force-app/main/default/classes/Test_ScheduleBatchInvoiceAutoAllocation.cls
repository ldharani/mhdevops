/****************************************************************
 * Author       : Sai C
 * Description  : test class for Test_ScheduleBatchInvoiceAutoAllocation 
 * Created Date : 04/20/2023
 * **************************************************************
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date          Requested By    Tag     Description
************************************************************************************************************************/

@isTest
private class Test_ScheduleBatchInvoiceAutoAllocation {
  static testMethod void testscheduleBatch(){
        Test.startTest();
        ScheduleBatchInvoiceAutoAllocation sch = new ScheduleBatchInvoiceAutoAllocation();
        String s = '0 0 23 * * ?';
      system.schedule('Test check', s, sch);
      Test.stopTest();
    }
}
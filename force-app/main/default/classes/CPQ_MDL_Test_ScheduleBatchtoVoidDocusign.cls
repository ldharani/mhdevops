@isTest
private class CPQ_MDL_Test_ScheduleBatchtoVoidDocusign{
  static testMethod void testscheduleBatch(){
        Test.startTest();
        CPQ_MDL_ScheduleBatchtoVoidDocusign  sch = new CPQ_MDL_ScheduleBatchtoVoidDocusign();
        String s = '0 0 23 * * ?';
      system.schedule('Test check', s, sch);
      Test.stopTest();
    }
}
@isTest
private class MDL_Test_ScheduleBatchtoVoidDocusign{
  static testMethod void testscheduleBatch(){
        Test.startTest();
        MDL_ScheduleBatchtoVoidDocusignEnvelope  sch = new MDL_ScheduleBatchtoVoidDocusignEnvelope();
        String s = '0 0 23 * * ?';
      system.schedule('Test check', s, sch);
      Test.stopTest();
    }
}
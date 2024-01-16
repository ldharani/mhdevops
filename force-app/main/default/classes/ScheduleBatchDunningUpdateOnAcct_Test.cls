@isTest
private class ScheduleBatchDunningUpdateOnAcct_Test {
  static testMethod void testscheduleBatch(){
        Test.startTest();
        ScheduleBatch_DunningUpdateOnAccount sch = new ScheduleBatch_DunningUpdateOnAccount();
        String s = '0 0 23 * * ?';
      system.schedule('Test check', s, sch);
      Test.stopTest();
    }
}
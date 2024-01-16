@isTest
private class Test_ScheduleOrderStatusCancelledBatch {
  static testMethod void testscheduleBatch(){
        Test.startTest();
        ScheduleOrderStatusCancelledbatch sch = new ScheduleOrderStatusCancelledbatch();
        String s = '0 0 23 * * ?';
      system.schedule('Test check', s, sch);
      Test.stopTest();
    }
}
@isTest
private class Test_ScheduleRulesOfEngagementBatch {
  static testMethod void testscheduleBatch(){
        Test.startTest();
        ScheduleRulesOfEngagementBatch sch = new ScheduleRulesOfEngagementBatch();
        String s = '0 0 23 * * ?';
      system.schedule('Test monthly', s, sch);
      Test.stopTest();
    }
}
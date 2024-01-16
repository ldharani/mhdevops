@isTest
private class Test_ScheduleBatchForMonthlyMaintMilest {
  static testMethod void testscheduleBatch(){
        Test.startTest();
        ScheduleBatchForMonthlyMaintenMilestone sch = new ScheduleBatchForMonthlyMaintenMilestone();
        String s = '0 0 23 * * ?';
      system.schedule('Test monthly', s, sch);
      Test.stopTest();
    }
}
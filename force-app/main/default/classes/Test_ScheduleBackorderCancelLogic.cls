@isTest
private class Test_ScheduleBackorderCancelLogic {
  static testMethod void testscheduleBatch(){
        Test.startTest();
        ScheduleBackorderCancelLogic sch = new ScheduleBackorderCancelLogic();
        String s = '0 0 23 * * ?';
      system.schedule('Test check', s, sch);
      Test.stopTest();
    }
}
@isTest
private class Test_ScheduleSubscriptionCancelLogic {
  static testMethod void testscheduleBatch(){
        Test.startTest();
        ScheduleSubscriptionCancelLogic    sch = new ScheduleSubscriptionCancelLogic    ();
        String s = '0 0 23 * * ?';
      system.schedule('Test check', s, sch);
      Test.stopTest();
    }
}
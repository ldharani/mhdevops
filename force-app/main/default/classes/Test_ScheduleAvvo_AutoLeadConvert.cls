@isTest
private class Test_ScheduleAvvo_AutoLeadConvert{
  static testMethod void testscheduleBatch(){
        Test.startTest();
        ScheduleAvvo_AutoLeadConvert sch = new ScheduleAvvo_AutoLeadConvert ();
        String s = '0 0 23 * * ?';
      system.schedule('Test check', s, sch);
      Test.stopTest();
    }
}
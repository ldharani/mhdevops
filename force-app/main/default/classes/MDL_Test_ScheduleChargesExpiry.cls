@isTest
private class MDL_Test_ScheduleChargesExpiry {
  static testMethod void testscheduleBatch(){
        Test.startTest();
        MDL_ScheduleChargesExpiry sch = new MDL_ScheduleChargesExpiry();
        String s = '0 0 23 * * ?';
      system.schedule('Test check', s, sch);
      Test.stopTest();
    }
}
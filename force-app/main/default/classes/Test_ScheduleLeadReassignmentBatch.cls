@isTest
private class Test_ScheduleLeadReassignmentBatch {
  static testMethod void testscheduleBatch(){
        Test.startTest();
        ScheduleLeadReassignmentBatch sch = new ScheduleLeadReassignmentBatch();
        String s = '0 0 23 * * ?';
      system.schedule('Test everyday', s, sch);
      Test.stopTest();
    }
}
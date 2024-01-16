@isTest
private class Test_ScheduleBatchUpdateQuoteStartDate {
  static testMethod void testscheduleBatch(){
        Test.startTest();
        ScheduleBatchUpdateQuoteStartDate  sch = new ScheduleBatchUpdateQuoteStartDate();
        String s = '0 0 23 * * ?';
      system.schedule('Test everyday', s, sch);
      Test.stopTest();
    }
}
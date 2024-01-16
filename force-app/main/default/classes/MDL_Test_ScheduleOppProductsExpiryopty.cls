@isTest
private class MDL_Test_ScheduleOppProductsExpiryopty {
  static testMethod void testscheduleBatch(){
        Test.startTest();
        MDL_ScheduleOppProductsExpiryopty  sch = new MDL_ScheduleOppProductsExpiryopty();
        String s = '0 0 23 * * ?';
      system.schedule('Test check', s, sch);
      Test.stopTest();
    }
}
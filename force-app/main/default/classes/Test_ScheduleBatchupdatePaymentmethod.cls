@isTest
private class Test_ScheduleBatchupdatePaymentmethod {
  static testMethod void testscheduleBatch(){
        Test.startTest();
        ScheduleBatchupdatePaymentmethod sch = new ScheduleBatchupdatePaymentmethod();
        String s = '0 0 23 * * ?';
      system.schedule('Test check', s, sch);
      Test.stopTest();
    }
}
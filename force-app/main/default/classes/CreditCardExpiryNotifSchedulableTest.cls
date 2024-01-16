@isTest
private class CreditCardExpiryNotifSchedulableTest{
    static testMethod void testscheduleBatch(){
        Test.startTest();
        //CreditCardExpiryNotificationSchedulable.scheduleIt();
       // CreditCardExpiryNotificationSchedulable  sch = new CreditCardExpiryNotificationSchedulable();
       // String s = '0 0 0 15,30 * ? *';
       // system.schedule('Test check', s, sch);
       
       CreditCardExpiryNotificationSchedulable  canCon = new CreditCardExpiryNotificationSchedulable();
        canCon.FkMethod();
        
        Test.stopTest();
    }
}
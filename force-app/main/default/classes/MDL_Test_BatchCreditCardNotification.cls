@isTest(seealldata = true)
public class MDL_Test_BatchCreditCardNotification {
    static testMethod void testCreditCardEmailNotification(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        List<invoiceit_s__Payment_Method__c> lstPayMeths = new List<invoiceit_s__Payment_Method__c>();
        Account acc = util.getAccount();
        Account acc1 = util.getAccount();
        Contact con = util.getContact(acc.Id);
        Contact con1 = util.getContact(acc1.Id);
        invoiceit_s__Currency__c Curr = util.getCurrencyObject();
        invoiceit_s__Job__c job = util.getOrder(acc.Id ,Curr.Id);
        job.invoiceit_s__Status__c = 'Active';
        job.invoiceit_s__Billing_Contact__c = con.Id;
        update job;
        invoiceit_s__Job__c job1 = util.getOrder(acc1.Id ,Curr.Id);
        job1.invoiceit_s__Status__c = 'Active';
        job1.invoiceit_s__Billing_Contact__c = con1.Id;
        update job1;        
        invoiceit_s__Payment_Method__c paymethod = new  invoiceit_s__Payment_Method__c(
                                                invoiceit_s__Account__c=acc.Id,
                                                invoiceit_s__Active__c=True,
                                                invoiceit_s__Card_Expiration_Month__c=String.valueOf(Date.Today().month()),
                                                invoiceit_s__Card_Expiration_Year__c=String.valueOf(Date.Today().year()),
                                                invoiceit_s__Card_Number__c='378282246310005',
                                                invoiceit_s__Card_Type__c = 'American Express',
                                                invoiceit_s__Payment_Method__c = 'Credit Card',
                                                invoiceit_s__Default__c = True,
                                                Rank__c = '1',  invoiceit_s__CVV__c='123'
                                                );
        lstPayMeths.add(paymethod);
        invoiceit_s__Payment_Method__c paymethod1 = new  invoiceit_s__Payment_Method__c(
                                                invoiceit_s__Account__c=acc1.Id,
                                                invoiceit_s__Active__c=True,
                                                invoiceit_s__Card_Expiration_Month__c=String.valueOf(Date.Today().addMonths(1).month()),
                                                invoiceit_s__Card_Expiration_Year__c=String.valueOf(Date.Today().year()),
                                                invoiceit_s__Card_Number__c='4111111111111111',
                                                invoiceit_s__Card_Type__c = 'Visa',
                                                invoiceit_s__Payment_Method__c = 'Credit Card',
                                                invoiceit_s__Default__c = True,
                                                Rank__c = '1',  invoiceit_s__CVV__c='234'
                                                );
        lstPayMeths.add(paymethod1);
        insert lstPayMeths;        
        Test.startTest();
        MDL_BatchCreditCardEmailNotification b = new MDL_BatchCreditCardEmailNotification();
        Database.executeBatch(b);
        Test.stopTest();
    }
    
    static testMethod void TestscheduledCreditCardNotification() {

            Test.startTest();
            String CRON_EXP = '0 0 0 1 1 ? 2025';  
            String jobId = System.schedule('MDL_BatchCreditCard_Scheduler', CRON_EXP, new MDL_BatchCreditCard_Scheduler() );

            CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);
            System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime));

            Test.stopTest();
    }
}
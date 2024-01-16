@IsTest
public class Test_Batch_populateAccPrevBalance {
    static testmethod void testRun1(){
    
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc = util.getAccount();        
        Contact con = util.getContact(acc.Id);
        Opportunity opp = util.getOpportunity(acc.Id , con.Id);
        
        blng__Invoice__c invoice = util.getInvoice(acc.Id);
       
        Order ord = new Order();
        ord.Name = 'Test Order';
        ord.AccountId = acc.Id;
        ord.Status = 'Draft';   
        ord.EffectiveDate = Date.today();
        insert ord;
        
        Order ord2 = new Order();
        ord2.Name = 'Test Order';
        ord2.AccountId = acc.Id;
        ord2.Status = 'Draft';   
        ord2.EffectiveDate = Date.today();
        insert ord2;
        
        blng__InvoiceLine__c invLines = util.getInvoiceLines(invoice.Id, Ord.Id);
        blng__InvoiceLine__c invLines1 = util.getInvoiceLines(invoice.Id, Ord.Id);
        
        String CRON_EXP = '0 0 0 15 3 ? *';
         
        Test.startTest();
        Batch_populateAccPrevBalance batch = new Batch_populateAccPrevBalance();
        Database.executebatch(new Batch_populateAccPrevBalance());
        
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new Schedule_batch_populateAccPrevBalance());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
        Test.stopTest();
     }

}
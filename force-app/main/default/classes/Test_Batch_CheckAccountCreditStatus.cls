@IsTest
public class Test_Batch_CheckAccountCreditStatus {
     static testmethod void testRun1(){
         
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
    
        Cls_UtilTestClass util = new Cls_UtilTestClass();        
        Account acc = util.getAccount(); 
        acc.Name ='testtInvStatus';
        acc.Credit_Status__c ='Bad Debt';
        acc.Finance_Class__c = 'Elite';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        update acc;
         
        System.debug(acc.RecordTypeId);
        Contact con = util.getContact(acc.Id);
        Opportunity opp = util.getOpportunity(acc.Id , con.Id);
         
         blng__Invoice__c invoice = util.getInvoice(acc.Id);
         invoice.blng__InvoiceStatus__c = 'Draft';
         invoice.blng__DueDate__c = System.today().adddays(-61);
         update invoice;
         invoice.blng__InvoiceStatus__c = 'Posted';
         
         update invoice;
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
        Batch_CheckAccountCreditStatus batch = new Batch_CheckAccountCreditStatus();
        Database.executebatch(new Batch_CheckAccountCreditStatus());
        
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new Schedule_batch_populatecreditstatus());
        
        Test.stopTest();
     }
}
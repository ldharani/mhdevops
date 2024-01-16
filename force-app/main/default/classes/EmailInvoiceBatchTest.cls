@isTest(seeAllData = true)

public class EmailInvoiceBatchTest {
 
    @isTest
    static void testMethod1()
    {
       Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
       Cls_UtilTestClass util = new Cls_UtilTestClass();
       Account acc = util.getAccount();
       acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
       acc.Invoice_Delivery_Type__c = 'Email';
       update acc;
       Contact con = util.getContact(acc.Id);
       Opportunity opp = util.getOpportunity(acc.Id , con.Id);
       
        Order ord = new Order();
        ord.Name = 'Test Order';
        ord.AccountId = acc.Id;
        ord.Status = 'Draft';   
        ord.EffectiveDate = Date.today();
        insert ord;
        blng__Invoice__c invoice = util.getInvoice(acc.Id);
        
        
        blng__InvoiceLine__c invLines = util.getInvoiceLines(invoice.Id, Ord.Id);
        
        invoice.Legacy_Sent_Mail__c = False;
        invoice.RecordTypeId = Schema.SObjectType.blng__Invoice__c.getRecordTypeInfosByName().get('MH Invoice').getRecordTypeId();
        invoice.blng__InvoiceStatus__c = 'Posted';
        update invoice;
        
        Test.startTest();
         
        Id batchJobId1 = Database.executeBatch(new EmailInvoiceBatch(invoice.Id), 1);
        EmailInvoiceUtil.createTask(invoice);
        
        Test.stopTest();        
    } 
        
       
    }
@isTest
public class Test_AvvoEmailInvoiceBatch {
	@isTest(seealldata=true)
    static void testBatchExecution() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        id mainvoice = Schema.SObjectType.blng__Invoice__c.getRecordTypeInfosByName().get('M-A Invoice').getRecordTypeId();
        Account acc = new Account(Name='test');
        insert acc;
		Contact con = new Contact(LastName='test con',AccountId=acc.id);
        insert con;
        blng__Invoice__c testInvoice = new blng__Invoice__c(blng__Account__c=acc.id,blng__BillToContact__c = con.id,blng__InvoiceStatus__c='Posted',Legacy_Sent_Mail__c=false,Delivery_Type__c='Email',RecordtypeId=mainvoice);
        insert testInvoice;
        List<blng__Invoice__c> testInvoices = new List<blng__Invoice__c>{testInvoice};
        Map<Id, String> errorMap = AvvoEmailInvoiceUtil.emailInvoice(testInvoices);
        Task t = AvvoEmailInvoiceUtil.createTask(testInvoice);
        AvvoEmailInvoiceBatch batchJob = new AvvoEmailInvoiceBatch(testInvoice.Id);
        Database.executeBatch(batchJob);
        Test.stopTest();
    }
}
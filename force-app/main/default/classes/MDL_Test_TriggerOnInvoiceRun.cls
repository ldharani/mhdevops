@isTest
public with sharing class MDL_Test_TriggerOnInvoiceRun {
	static testMethod void testInvoiceRun(){
		Date invoiceDate = Date.Today().toStartOfMonth();
		
		invoiceit_s__Invoice_Run__c invRun = new invoiceit_s__Invoice_Run__c();
        invRun.invoiceit_s__Invoices_Generated__c = 10;
        invRun.invoiceit_s__Invoice_Date__c = invoiceDate;
        invRun.invoiceit_s__Status__c = 'Started';
        insert invRun;
        
        Test.startTest();
        invRun.invoiceit_s__Status__c = 'Completed';
        update invRun;
        Test.stopTest();
	}
}
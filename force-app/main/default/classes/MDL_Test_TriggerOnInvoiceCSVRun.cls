@isTest
public with sharing class MDL_Test_TriggerOnInvoiceCSVRun{
	static testMethod void testInvoiceCSVRun(){
		Date invoiceDate = Date.Today().toStartOfMonth();
		
		Invoice_CSV_Generator__c invCSV = Invoice_CSV_Generator__c.getValues('Test');
		if(invCSV==null){
	        invCSV = new Invoice_CSV_Generator__c();
	        invCSV.Name = 'Test';
	        invCSV.Invoice_Test_Date__c = Date.today().toStartOfMonth();
	        invCSV.No_of_re_trials__c = 2;
	        insert invCSV;
        }
    	Decimal reqTrials = invCSV.No_of_re_trials__c;
		        
        invoiceit_s__Invoice_Run__c invRun = new invoiceit_s__Invoice_Run__c();
        invRun.invoiceit_s__Invoices_Generated__c = 10;
        invRun.invoiceit_s__Invoice_Date__c = invoiceDate;
        insert invRun;
        
        //insert new Invoice CSV Run record
        Invoice_CSV_Run__c invCSVRun = new Invoice_CSV_Run__c();        
        invCSVRun.No_of_Trials__c = reqTrials-1;
        invCSVRun.Run_Date__c = Date.Today();
        invCSVRun.Status__c = 'In Progress';
        invCSVRun.Time_Stamp__c = system.now();
        invCSVRun.Related_Invoice_Run__c = invRun.Id;
        insert invCSVRun;
        
        Test.startTest();        
        invCSVRun.Status__c = 'Completed with Errors';
        update invCSVRun;
        Test.stopTest();
	}
	static testMethod void testCaseCreation(){
		Date invoiceDate = Date.Today().toStartOfMonth();
		
		Invoice_CSV_Generator__c invCSV = Invoice_CSV_Generator__c.getValues('Test');
		if(invCSV==null){
	        invCSV = new Invoice_CSV_Generator__c();
	        invCSV.Name = 'Test';
	        invCSV.Invoice_Test_Date__c = Date.today().toStartOfMonth();
	        invCSV.No_of_re_trials__c = 2;
	        insert invCSV;
        }
    	Decimal reqTrials = invCSV.No_of_re_trials__c;
    	
		        
        invoiceit_s__Invoice_Run__c invRun = new invoiceit_s__Invoice_Run__c();
        invRun.invoiceit_s__Invoices_Generated__c = 10;
        invRun.invoiceit_s__Invoice_Date__c = invoiceDate;
        insert invRun;
        
        //insert new Invoice CSV Run record
        Invoice_CSV_Run__c invCSVRun = new Invoice_CSV_Run__c();        
        invCSVRun.No_of_Trials__c = reqTrials;
        invCSVRun.Run_Date__c = Date.Today();
        invCSVRun.Status__c = 'In Progress';
        invCSVRun.Time_Stamp__c = system.now();
        invCSVRun.Related_Invoice_Run__c = invRun.Id;
        insert invCSVRun;
        
        Test.startTest();        
        invCSVRun.Status__c = 'Completed with Errors';
        update invCSVRun;
        Test.stopTest();
	}
}
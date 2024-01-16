@isTest(seeAllData=true)
public with sharing class MDL_Test_CheckInvoiceStatus {
	static testMethod void Test_TriggerHandlerOnOrderRPC() {
		MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();		
			
			Account a = testData.getAccount();
			a.Name = 'TestAccForInvStatus1';
			update a;
			invoiceit_s__Invoice__c invoice = testData.getInvoice(a.id);
			invoice.invoiceit_s__Due_Date__c = Date.today().addYears(1);
			update invoice;
			
			Account a1 = testData.getAccount();
			a.Name = 'TestAccForInvStatus2';
			update a;
			invoiceit_s__Invoice__c invoice1 = testData.getInvoice(a1.id);
			invoice1.invoiceit_s__Due_Date__c = Date.today().addDays(-100);
			update invoice1;
			
			Test.startTest();
			MDL_CheckInvoiceStatus b = new MDL_CheckInvoiceStatus();
			Database.executeBatch(b);			
	        
    		MDL_Scheduler_CheckInvoiceStatus m = new MDL_Scheduler_CheckInvoiceStatus();
    		String sch = '0 0 23 * * ?';
    		system.schedule('Test check', sch, m);
    		Test.stopTest(); 
	}	
}
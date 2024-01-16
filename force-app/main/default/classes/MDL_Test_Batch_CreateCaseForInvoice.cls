@isTest
public with sharing class MDL_Test_Batch_CreateCaseForInvoice {
		static testMethod void Test_TriggerHandlerOnOrderRPC() {
			MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
			
			Database.QueryLocator QL;
        	Database.BatchableContext BC;
			Account a = testData.getAccount();
			invoiceit_s__Invoice__c invoice = testData.getInvoice(a.id);
			Test.starttest();
			MDL_Batch_CreateCaseForInvoice m = new MDL_Batch_CreateCaseForInvoice();
			Database.executeBatch(m);
			Test.stopTest();
			/*QL = b.start(bc);
			Database.QueryLocatorIterator QIT =  QL.iterator();
			List<invoiceit_s__Invoice__c> list_invoice = new List<invoiceit_s__Invoice__c>(); 
			while (QIT.hasNext())
	        {
	            invoiceit_s__Invoice__c inv = (invoiceit_s__Invoice__c)QIT.next();           
	            list_invoice.add(inv);
	        } 
	        
	        b.execute(BC, list_invoice);
	        b.finish(BC);*/	        
	                
    		MDL_CreateCaseForInvoiceScheduler m1 = new MDL_CreateCaseForInvoiceScheduler();
    		String sch = '0 0 23 * * ?';
    		system.schedule('Test check', sch, m1);
		}
}
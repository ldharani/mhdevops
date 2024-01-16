//Test method for MDL_CtrlDebitMemoForPayment
@isTest(seealldata=true)
public with sharing class MDL_Test_CtrlDebitMemoForPayment {
	static testmethod void testCtrlDebitMemo(){
		MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
		//create required objects
		Account account1 = util.getAccount();
        invoiceit_s__Currency__c currency1 = util.getCurrencyObject();
		invoiceit_s__Payment__c payment1 = util.getPayment(account1.Id,currency1.Id);
		payment1.invoiceit_s__Payment_Type__c = 'Adjustment';
		payment1.Adjustment_Reason__c='DM(Manual Debits)';
        update payment1;
		invoiceit_s__Job__c order1 = util.getOrder(account1.Id, currency1.Id);
		invoiceit_s__Invoice__c invoice1 = util.getInvoice(account1.Id);
		invoiceit_s__Invoice_Lines__c invlines1 = util.getInvoiceLines(invoice1.Id,order1.id);
		invoiceit_s__Payment_Allocation__c palloc1 = util.getPaymentAlloc(payment1.Id,invoice1.Id);
				
		//create the standard controller
		ApexPages.StandardController sc = new ApexPages.StandardController(payment1);
		MDL_CtrlDebitMemoForPayment cdmp = new MDL_CtrlDebitMemoForPayment(sc);
		
		//call the method from class and check the results
		PageReference cancelpage = cdmp.cancel();
		PageReference p = new PageReference('/' + payment1.Id);
		System.assertEquals(string.valueOf(cancelpage),String.valueOf(p));
		
		PageReference debitpage = cdmp.debitMemoForPayment();
		PageReference p1 = new PageReference('/' + payment1.invoiceit_s__Account__c);
		System.assertEquals(string.valueOf(debitpage),String.valueOf(p1));
	}		
}
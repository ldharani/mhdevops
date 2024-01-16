@isTest(seeAllData = true)
public class VirtualTerminalTestControllerInvoiceTest {
    
    static testmethod void run2condition(){
         MDL_UtilClass_TestClass util             = new MDL_UtilClass_TestClass();
    
    	 account acc                              = util.getAccount();
    
    	 invoiceit_s__Invoice__c invoice          = util.getInvoice(acc.Id);

    	 invoiceit_s__Currency__c currencyobj     = util.getCurrencyObject();

    	 invoiceit_s__Job__c order                = util.getOrder(acc.Id, currencyobj.Id);
    
    	 invoiceit_s__Invoice_Lines__c invline    = util.getInvoiceLines(invoice.id, order.id);
    
    	 invoiceit_s__Payment_Method__c paymethod = util.getPaymentMethod(acc.Id);
        
         invoiceit_s__Gateway__c paymentGateWay   = new invoiceit_s__Gateway__c(Name = 'Test1234');
         insert paymentGateWay;
        
        invoiceit_s__Transaction__c t = new invoiceit_s__Transaction__c();
        t.invoiceit_s__Payment_Method__c = paymethod.Id;
        t.invoiceit_s__Currency__c = currencyobj.Id;
        t.invoiceit_s__Payment_Gateway__c = paymentGateWay.Id;
        t.invoiceit_s__Request_Invoice__c = invoice.id;
        t.invoiceit_s__Is_Payment_Processed_Successfully__c = true;
        insert t;
         
        invoiceit_s__Transaction__c t1 = [select Id,Name,invoiceit_s__Is_Payment_Processed_Successfully__c,invoiceit_s__Exception_Message__c,invoiceit_s__Request_Invoice__c,invoiceit_s__Payment_Method__c from invoiceit_s__Transaction__c where invoiceit_s__Request_Invoice__c=:invoice.Id and invoiceit_s__Payment_Method__c=:paymethod.Id order by LastModifiedDate desc limit 1];
        system.debug('@@@@in test class transaction'+ t1);
         //invoiceit_s__Transaction__c invTransaction = util.getTransactionObj(paymethod.id, invoice.Id, currencyobj.Id, paymentGateWay.Id);
    
         test.startTest();
    	 virtualTerminalTestControllerinvoice ctrl = new virtualTerminalTestControllerinvoice(new ApexPages.StandardController(acc));
         ctrl.invid =  invoice.id;
        
         PageReference pageRef = Page.virtualTerminalAccountPage;
          Test.setCurrentPage(pageRef);
         
        ctrl.getAllCreditCards();
         ctrl.getItems();
         ctrl.getItems();
         ctrl.getrecordTypes();
         ctrl.submitPayment();
        ctrl.sResponseMessage = 'Error Occured';
         ctrl.makePaymentNew();
        
        ctrl.sResponseMessage = 'Successful';
        ctrl.credicardselectedValue = paymethod.Id;
        
        ctrl.submitPayment();
         ctrl.makePaymentNew();
         ctrl.yesOrNoSelection();
         ctrl.processPaymentRedirect();
        test.stopTest();
    
    }
    
   
    
    

}
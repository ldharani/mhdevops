/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
private class MDL_test_InvoiceCSVBatch {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test       
        
        //initializing Util Class
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
        //inserting custom setting needed
        Invoice_CSV_Generator__c gen = Invoice_CSV_Generator__c.getValues('Test');
        if(gen==null){
	        gen = new Invoice_CSV_Generator__c();
	        gen.Name = 'Test123';
	        gen.Invoice_Test_Date__c = Date.today().toStartOfMonth();
	        gen.No_of_re_trials__c = 2;
	        insert gen;
        }
		
		//inserting objects needed        
        Account acc = util.getAccount();  
        acc.Name = 'Test Account For InvoiceCSV Batch';
        update acc;
              
        invoiceit_s__Currency__c cur = util.getCurrencyObject();
        invoiceit_s__Payment_Method__c payMeth = util.getPaymentMethod(acc.Id);	
        
        Date invoiceDate = Date.Today().toStartOfMonth();
        
        invoiceit_s__Invoice_Run__c invRun = new invoiceit_s__Invoice_Run__c();
        invRun.invoiceit_s__Invoices_Generated__c = 10;
        invRun.invoiceit_s__Invoice_Date__c = invoiceDate;
        insert invRun;
        
        invoiceit_s__Job__c order = util.getOrder(acc.Id , cur.Id);
        invoiceit_s__Invoice__c inv = new invoiceit_s__Invoice__c(
                                                    invoiceit_s__Account__c=acc.Id,
                                                    invoiceit_s__Invoice_Date__c=invoiceDate,invoiceit_s__Due_Date__c = invoiceDate.addMonths(1),
                                                    invoiceit_s__Invoice_Run_Created_By__c = invRun.Id,
                                                    invoiceit_s__Invoice_Status__c='Posted',Purchase_Order_Number__c='112233'
                                                    );
        insert inv;        
        invoiceit_s__Invoice__c invPast = new invoiceit_s__Invoice__c(
                                                    invoiceit_s__Account__c=acc.Id,
                                                    invoiceit_s__Invoice_Date__c=invoiceDate.adddays(-90),	invoiceit_s__Due_Date__c = invoiceDate.adddays(-60),
                                                    invoiceit_s__Invoice_Status__c='Posted',Purchase_Order_Number__c='445566'
                                                    );
        insert invPast;
        invoiceit_s__Payment__c pay = new invoiceit_s__Payment__c(
                                                    invoiceit_s__Account__c=acc.Id,
                                                    invoiceit_s__Amount__c=2000,
                                                    invoiceit_s__Currency__c=cur.Id,
                                                    invoiceit_s__Payment_Date__c=invoiceDate.addMonths(-1),
                                                    invoiceit_s__Status__c='Completed'
                                                    );
        insert pay;
        Test.startTest();
        invoiceit_s__Payment__c payAdj = new invoiceit_s__Payment__c(
                                                    invoiceit_s__Account__c=acc.Id,
                                                    invoiceit_s__Amount__c=3000,
                                                    invoiceit_s__Currency__c=cur.Id,
                                                    invoiceit_s__Payment_Date__c=invoiceDate.addMonths(-1),
                                                    invoiceit_s__Status__c='Completed',
                                                    invoiceit_s__Payment_Type__c = 'Adjustment',
                                                    Applied_Type__c = 'Credit',
                                                    Adjustment_Reason__c = 'Cancellation'
                                                    );
        insert payAdj;
        invoiceit_s__Payment__c payPast = new invoiceit_s__Payment__c(
                                                    invoiceit_s__Account__c=acc.Id,
                                                    invoiceit_s__Amount__c=500,
                                                    invoiceit_s__Currency__c=cur.Id,
                                                    invoiceit_s__Payment_Date__c=invoiceDate.addDays(-90),
                                                    invoiceit_s__Status__c='Completed',
                                                    invoiceit_s__Payment_Type__c = 'Adjustment',
                                                    Applied_Type__c = 'Credit',
                                                    Adjustment_Reason__c = 'Cancellation'
                                                    );
        insert payPast;        
        invoiceit_s__Invoice_Lines__c invLinePast = util.getInvoiceLines(invPast.Id,order.Id);
        invoiceit_s__Invoice_Lines__c invLine = util.getInvoiceLines(inv.Id,order.Id);        
        
        
	    InvoiceCSVBatch b = new InvoiceCSVBatch(invRun.Id);              
	    Database.executeBatch(b,100);
        Test.stopTest();
    }
    static testMethod void checkException(){
    	// TO DO: implement unit test       
        
        //initializing Util Class
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
        //inserting custom setting needed
        Invoice_CSV_Generator__c gen = Invoice_CSV_Generator__c.getValues('Test');
        if(gen==null){
	        gen = new Invoice_CSV_Generator__c();
	        gen.Name = 'Test123';
	        gen.Invoice_Test_Date__c = Date.today().toStartOfMonth();
	        gen.No_of_re_trials__c = 2;
	        insert gen;
        }
		
		//inserting objects needed        
        Account acc = util.getAccount();  
        acc.Name = 'Test Account For InvoiceCSV Batch';
        update acc;
              
        invoiceit_s__Currency__c cur = util.getCurrencyObject();
        invoiceit_s__Payment_Method__c payMeth = util.getPaymentMethod(acc.Id);	
        
        Date invoiceDate = Date.Today().toStartOfMonth();
        
        invoiceit_s__Invoice_Run__c invRun = new invoiceit_s__Invoice_Run__c();
        invRun.invoiceit_s__Invoices_Generated__c = 10;
        invRun.invoiceit_s__Invoice_Date__c = invoiceDate;
        insert invRun;
        
        invoiceit_s__Job__c order = util.getOrder(acc.Id , cur.Id);
        invoiceit_s__Invoice__c inv = new invoiceit_s__Invoice__c(
                                                    invoiceit_s__Account__c=acc.Id,
                                                    invoiceit_s__Invoice_Date__c=invoiceDate,
                                                    invoiceit_s__Invoice_Run_Created_By__c = invRun.Id,
                                                    invoiceit_s__Invoice_Status__c='Posted',Purchase_Order_Number__c='112233'
                                                    );
        insert inv;        
        invoiceit_s__Invoice__c invPast = new invoiceit_s__Invoice__c(
                                                    invoiceit_s__Account__c=acc.Id,
                                                    invoiceit_s__Invoice_Date__c=invoiceDate.adddays(-90),
                                                    invoiceit_s__Invoice_Status__c='Posted',Purchase_Order_Number__c='445566'
                                                    );
        insert invPast;
        invoiceit_s__Payment__c pay = new invoiceit_s__Payment__c(
                                                    invoiceit_s__Account__c=acc.Id,
                                                    invoiceit_s__Amount__c=2000,
                                                    invoiceit_s__Currency__c=cur.Id,
                                                    invoiceit_s__Payment_Date__c=invoiceDate.addMonths(-1),
                                                    invoiceit_s__Status__c='Completed'
                                                    );
        insert pay;
        Test.startTest();
        invoiceit_s__Payment__c payAdj = new invoiceit_s__Payment__c(
                                                    invoiceit_s__Account__c=acc.Id,
                                                    invoiceit_s__Amount__c=3000,
                                                    invoiceit_s__Currency__c=cur.Id,
                                                    invoiceit_s__Payment_Date__c=invoiceDate.addMonths(-1),
                                                    invoiceit_s__Status__c='Completed',
                                                    invoiceit_s__Payment_Type__c = 'Adjustment',
                                                    Applied_Type__c = 'Credit',
                                                    Adjustment_Reason__c = 'Cancellation'
                                                    );
        insert payAdj;
        invoiceit_s__Payment__c payPast = new invoiceit_s__Payment__c(
                                                    invoiceit_s__Account__c=acc.Id,
                                                    invoiceit_s__Amount__c=500,
                                                    invoiceit_s__Currency__c=cur.Id,
                                                    invoiceit_s__Payment_Date__c=invoiceDate.addDays(-90),
                                                    invoiceit_s__Status__c='Completed',
                                                    invoiceit_s__Payment_Type__c = 'Adjustment',
                                                    Applied_Type__c = 'Credit',
                                                    Adjustment_Reason__c = 'Cancellation'
                                                    );
        insert payPast;        
        invoiceit_s__Invoice_Lines__c invLinePast = util.getInvoiceLines(invPast.Id,order.Id);
        invoiceit_s__Invoice_Lines__c invLine = util.getInvoiceLines(inv.Id,order.Id);        
        
        
	    InvoiceCSVBatch b = new InvoiceCSVBatch(invRun.Id);              
	    Database.executeBatch(b);
        Test.stopTest();
    }
}
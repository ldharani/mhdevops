@isTest(seeAllData=true)
public with sharing class MDL_test_InvoiceCSVReprocessBatch {
	static testMethod void testInvoiceCSVReprocessBatch(){
		 //initializing Util Class
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
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
        
        //insert new Invoice CSV Run record
        Invoice_CSV_Run__c invCSVRun = new Invoice_CSV_Run__c();        
        invCSVRun.No_of_Trials__c = 1;
        invCSVRun.Run_Date__c = Date.Today();
        invCSVRun.Status__c = 'In Progress';
        invCSVRun.Time_Stamp__c = system.now();
        invCSVRun.Related_Invoice_Run__c = invRun.Id;
        insert invCSVRun;
        
        Invoice_CSV_Run__c invCSVRunName = [Select Name from Invoice_CSV_Run__c where Id=:invCSVRun.Id];
        
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
        
        InvoiceCSVReprocessBatch b = new InvoiceCSVReprocessBatch(invCSVRunName.Name,invCSVRun.No_of_Trials__c,invRun.Id,invoiceDate);              
	    Database.executeBatch(b);
        Test.stopTest();    
	}
	static testMethod void testException(){
		 //initializing Util Class
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
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
        
        //insert new Invoice CSV Run record
        Invoice_CSV_Run__c invCSVRun = new Invoice_CSV_Run__c();        
        invCSVRun.No_of_Trials__c = 1;
        invCSVRun.Run_Date__c = Date.Today();
        invCSVRun.Status__c = 'In Progress';
        invCSVRun.Time_Stamp__c = system.now();
        invCSVRun.Related_Invoice_Run__c = invRun.Id;
        insert invCSVRun;
        
        Invoice_CSV_Run__c invCSVRunName = [Select Name from Invoice_CSV_Run__c where Id=:invCSVRun.Id];
        
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
        
        InvoiceCSVReprocessBatch b = new InvoiceCSVReprocessBatch(invCSVRunName.Name,invCSVRun.No_of_Trials__c,invRun.Id,invoiceDate);              
	    Database.executeBatch(b);
        Test.stopTest();    
	}
}
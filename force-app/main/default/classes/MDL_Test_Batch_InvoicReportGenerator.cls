@isTest(SeeAllData=true)
public with sharing class MDL_Test_Batch_InvoicReportGenerator {
        static testMethod void Test_Invoice() {
           /* MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
            Test.starttest();
            Database.QueryLocator QL;
            Database.BatchableContext BC;
            MDL_Batch_InvoiceReportGenerator b = new MDL_Batch_InvoiceReportGenerator();
            QL = b.start(bc);
            Database.QueryLocatorIterator QIT =  QL.iterator();
            List<invoiceit_s__Invoice__c> list_invoice = new List<invoiceit_s__Invoice__c>(); 
            List<Account> list_acct = new List<Account>(); 
            for (Account a : [Select a.invoiceit_s__Payment_Method__c, a.Unpaid_amount__c,a.Name,
                        (Select Id, IsDeleted, Name, RecordTypeId,invoiceit_s__Billing_Contact__r.id,invoiceit_s__Account__r.Name,invoiceit_s__Account__r.BillingStreet,invoiceit_s__Account__r.BillingCity,
                         invoiceit_s__Account__c, invoiceit_s__Billing_Contact__c, invoiceit_s__CurrencyL__c,invoiceit_s__Billing_Contact__r.Name,invoiceit_s__Account__r.BillingState ,invoiceit_s__Account__r.BillingPostalCode,invoiceit_s__Account__r.MH_Cust_Number__c,
                         invoiceit_s__Due_Date__c, invoiceit_s__Exchange_Rate_Applied__c, invoiceit_s__Invoice_Date__c,
                         invoiceit_s__Invoice_Reference__c, invoiceit_s__Invoice_Run_Created_By__c, invoiceit_s__Account__r.Total_Account_Balance__c,
                         invoiceit_s__Invoice_Status__c, invoiceit_s__Net_Total__c, invoiceit_s__Order__c, 
                         invoiceit_s__Payment_Request_Amount__c, invoiceit_s__Payment_Status__c, 
                         invoiceit_s__Shipping_Contact__c, invoiceit_s__Status_Flag__c, invoiceit_s__Total_Invoice_Value__c,
                         invoiceit_s__Unpaid_Amount__c, invoiceit_s__Amount__c, invoiceit_s__Discount_Value__c,Purchase_Order_Number__c, 
                         invoiceit_s__Number_Of_Invoice_Lines__c, invoiceit_s__Paid_Amount__c, invoiceit_s__Tax__c, 
                         invoiceit_s__VAT__c, invoiceit_s__Cancellation_Reason__c, invoiceit_s__Unpost_Reason__c, Exception_Log__c, 
                         Arrears_Invoice__c, Date_From__c, Date_To__c, Invoice_Reporting_Data__c, Invoice_Reporting_Date__c, Age__c, 
                         Invoice_Age__c, Total_Invoice_Value_Tax_Exempt__c, Age_Open_Days__c, Good__c, Invoice_Value__c, First__c, 
                         IsDataLoaded__c, Unallocated_Credits__c, Unallocated_Payments__c, Unpaid_amount1__c, TotalAllocatedPayments__c, Tax_Exempt_value__c,
                         Total_Payments__c, Total_Credits__c, Amount_Due__c,
                         Account_Balance__c From invoiceit_s__Invoices__r) From Account a limit 20]) 
                {
                list_acct.add(a);
                }
            b.execute(BC, list_acct);
            b.finish(BC); 
            MDL_InvoiceReportScheduler m = new MDL_InvoiceReportScheduler();
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, m);
            Test.stoptest(); */
            
        }   
}
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
@isTest(seeAlldata = true)
private class TestClassBatchProcessArrearsInvoice {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Account account = new Account(Name = 'Test Account',  Billing_Schedule__c = 'Arrears');
        insert account;
        
        Contact contact =  new Contact(LastName = 'Laxman', AccountId = account.Id);                                 
        insert contact;
        
        invoiceit_s__Currency__c currencyObj = new invoiceit_s__Currency__c(Name = 'GBP', invoiceit_s__Symbol__c = '£1');
        insert currencyObj;   
        
        invoiceit_s__Product__c product = new  invoiceit_s__Product__c(Name = 'Test Product',Billing_Schedule__c = 'Arrears', invoiceit_s__Valid_From_Date__c = system.today() - 100,invoiceit_s__Valid_To_Date__c = system.today() + 100,invoiceit_s__Product_Family__c = 'Default',invoiceit_s__Product_Code__c = 'Code1',invoiceit_s__Description__c = 'Product');
        insert product;
        
        invoiceit_s__Product__c productAdv = new  invoiceit_s__Product__c(Name = 'Test Product',Billing_Schedule__c = 'Advance', invoiceit_s__Valid_From_Date__c = system.today() - 100,invoiceit_s__Valid_To_Date__c = system.today() + 100,invoiceit_s__Product_Family__c = 'Default',invoiceit_s__Product_Code__c = 'Code1',invoiceit_s__Description__c = 'Product');
        insert productAdv;
        
        
        invoiceit_s__Job__c job = new invoiceit_s__Job__c(Name = 'Test Job', 
                invoiceit_s__Account__c = account.Id,
                invoiceit_s__Billing_Contact__c = contact.Id,
                invoiceit_s__Shipping_Contact__c = contact.Id,
                invoiceit_s__Number_Of_Terms__c = 24,
                invoiceit_s__CurrencyL__c = currencyObj.Id,
                invoiceit_s__Start_Date__c = system.today(), 
                invoiceit_s__Service_Activation_Date__c = system.today(), 
                invoiceit_s__Service_End_Date__c = system.today().addMonths(10),
                invoiceit_s__Preferred_Billing_Day__c = '1'
        );
        
        
        insert job;
        
        invoiceit_s__Invoice_RunScheduler__c runScheduler = new invoiceit_s__Invoice_RunScheduler__c(Name = 'InvoiceRun', invoiceit_s__Invoice_Currency__c = currencyObj.Id,invoiceit_s__Type__c = 'Once', invoiceit_s__Invoice_Date__c = system.today(), invoiceit_s__Target_Date__c = system.today());
        insert runScheduler;
        
        invoiceit_s__Invoice_Run__c invoiceRun = new invoiceit_s__Invoice_Run__c(Name = 'InvoiceRun' , invoiceit_s__Status__c = 'Started');
        insert invoiceRun;
        
        list<invoiceit_s__Invoice__c> listInvoice = new list<invoiceit_s__Invoice__c>();
        invoiceit_s__Invoice__c invoice = new invoiceit_s__Invoice__c(invoiceit_s__Account__c = account.id,
                                            invoiceit_s__Billing_Contact__c = contact.Id,
                                            invoiceit_s__Shipping_Contact__c = contact.Id,
                                            invoiceit_s__CurrencyL__c = currencyObj.Id, 
                                            invoiceit_s__Target_Date__c = Date.today(),
                                            invoiceit_s__Delivery_Type__c = 'Both',
                                            invoiceit_s__Invoice_Status__c = 'Posted',
                                            invoiceit_s__Payment_Request_Amount__c = 20,
                                            invoiceit_s__Invoice_Run_Created_By__c = invoiceRun.Id  ,
                                            invoiceit_s__Due_Date__c = system.today() + 100,
                                            invoiceit_s__Invoice_Date__c = system.today()                                   
                                            );
        insert invoice;
        
        list<invoiceit_s__Invoice_Lines__c> listInvoiceLines = new list<invoiceit_s__Invoice_Lines__c>();
        listInvoiceLines.add(new invoiceit_s__Invoice_Lines__c(invoiceit_s__Product__c = product.id, invoiceit_s__Invoice__c = invoice.id, invoiceit_s__Charge_Date__c = system.today(), invoiceit_s__Line_Name__c = 'Broadband Installation For L',invoiceit_s__Quantity__c = 1,invoiceit_s__Unit_Price__c = 40.00,invoiceit_s__VAT__c = 8.00,invoiceit_s__Line_Amount__c = 40.00,invoiceit_s__Job__c = job.Id , invoiceit_s__Service_End_Date__c = system.today()));
        listInvoiceLines.add(new invoiceit_s__Invoice_Lines__c(invoiceit_s__Product__c = product.id, invoiceit_s__Invoice__c = invoice.id, invoiceit_s__Charge_Date__c = system.today(), invoiceit_s__Line_Name__c = 'Broadband Installation For X',invoiceit_s__Quantity__c = 1,invoiceit_s__Unit_Price__c = 40.00,invoiceit_s__VAT__c = 8.00,invoiceit_s__Line_Amount__c = 40.00,invoiceit_s__Job__c = job.Id, invoiceit_s__Service_End_Date__c = system.today()-1));
        listInvoiceLines.add(new invoiceit_s__Invoice_Lines__c(invoiceit_s__Product__c = productAdv.id, invoiceit_s__Invoice__c = invoice.id, invoiceit_s__Charge_Date__c = system.today(), invoiceit_s__Line_Name__c = 'Broadband Installation For M',invoiceit_s__Quantity__c = 1,invoiceit_s__Unit_Price__c = 40.00,invoiceit_s__VAT__c = 8.00,invoiceit_s__Line_Amount__c = 40.00,invoiceit_s__Job__c = job.Id, invoiceit_s__Service_End_Date__c = system.today()+1));
        insert listInvoiceLines;
        invoiceRun.invoiceit_s__Status__c = 'Completed';
        update invoiceRun;
        
        test.startTest();
        
        BatchProcessArrearsInvoice batch=new BatchProcessArrearsInvoice(new set<Id>());
        Database.executebatch(batch);
        
        test.stopTest();
        
    }
}
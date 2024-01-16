@isTest
        private class ClassAfterOnInvoiceRunTest{
           static testmethod void  testClassAfterOnInvoiceRun(){
           Test.StartTest();
  map<Id,invoiceit_s__Invoice_Run__c> newMap = new map<Id,invoiceit_s__Invoice_Run__c>(); 
map<Id,invoiceit_s__Invoice_Run__c> oldMap = new map<Id,invoiceit_s__Invoice_Run__c>();
 Date invoiceDate = Date.Today().toStartOfMonth(); 
invoiceit_s__Invoice_Run__c invRun = new invoiceit_s__Invoice_Run__c();
        invRun.invoiceit_s__Invoices_Generated__c = 10;
        invRun.invoiceit_s__Invoice_Date__c = invoiceDate;
invRun.invoiceit_s__Status__c = 'Completed with errors';
        insert invRun;
        newMap.put(invRun.id,invRun);
        
invoiceit_s__Invoice_Run__c invRun1 = new invoiceit_s__Invoice_Run__c();
        invRun1.invoiceit_s__Invoices_Generated__c = 10;
        invRun1.invoiceit_s__Invoice_Date__c = invoiceDate;
invRun1.invoiceit_s__Status__c = 'Completed';
        insert invRun1;
oldMap.put(invRun.id,invRun1);
  
         ClassAfterOnInvoiceRun clsAftrInvoiceRun = new ClassAfterOnInvoiceRun(); 
        clsAftrInvoiceRun.handleBeforerOnJob(newMap, oldMap);
        Test.stopTest();
     }
    }
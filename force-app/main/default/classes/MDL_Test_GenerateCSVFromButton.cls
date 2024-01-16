@isTest(seeAllData = true)
public with sharing class MDL_Test_GenerateCSVFromButton {
    static testMethod void testGenerateCSV(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount(); 
        
        Date invoiceDate = Date.Today().toStartOfMonth();
        
        invoiceit_s__Invoice_Run__c invRun = new invoiceit_s__Invoice_Run__c();
        invRun.invoiceit_s__Invoices_Generated__c = 10;
        invRun.invoiceit_s__Invoice_Date__c = invoiceDate;
        insert invRun;
        
        invoiceit_s__Invoice__c inv = new invoiceit_s__Invoice__c(
                                                    invoiceit_s__Account__c=acc.Id,
                                                    invoiceit_s__Invoice_Date__c=invoiceDate,invoiceit_s__Due_Date__c = invoiceDate.addMonths(1),
                                                    invoiceit_s__Invoice_Run_Created_By__c = invRun.Id,
                                                    invoiceit_s__Invoice_Status__c='Posted',Purchase_Order_Number__c='112233'
                                                    );
        insert inv;  
        Test.startTest();
        Boolean returnValue = MDL_GenerateCSVFromButton.generateCSV(invRun.Id);
        Test.stopTest();
    }
}
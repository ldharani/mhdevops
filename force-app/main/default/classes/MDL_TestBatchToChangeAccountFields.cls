/****************************************************************
Created Date : October 9,2015
Created Purpose : Test class for mdl_BatchtochangeAccountfields
****************************************************************/
@isTest(seeAlldata = true)
public with sharing class MDL_TestBatchToChangeAccountFields {
    static testMethod void testBatchToChangeAcctFields(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();   
        Account acc = util.getAccount();  
        acc.Business_Unit__c = 'Pending Migration';
        acc.Legal_Entity__c = 'MH Taxable';
        update acc;
        Account acc2 = util.getAccount();  
        acc2.Business_Unit__c = 'Pending Migration';
        acc2.Legal_Entity__c = 'MH Non-Taxable';
        update acc2;
        invoiceit_s__Currency__c cur = util.getCurrencyObject();
        Date invoiceDate = date.newInstance(date.today().year(), date.today().month(), 01);
        invoiceit_s__Invoice__c inv = new invoiceit_s__Invoice__c(
                                                    invoiceit_s__Account__c=acc.Id,
                                                    invoiceit_s__Invoice_Date__c=invoiceDate,invoiceit_s__Due_Date__c = invoiceDate.addMonths(1),
                                                    invoiceit_s__Invoice_Status__c='Posted'
                                                    );
        insert inv;
        invoiceit_s__Invoice__c inv2 = new invoiceit_s__Invoice__c(
                                                    invoiceit_s__Account__c=acc2.Id,
                                                    invoiceit_s__Invoice_Date__c=invoiceDate,invoiceit_s__Due_Date__c = invoiceDate.addMonths(1),
                                                    invoiceit_s__Invoice_Status__c='Posted'
                                                    );
        insert inv2;
        Test.startTest();
            mdl_BatchtochangeAccountfields b = new mdl_BatchtochangeAccountfields();
            Database.executeBatch(b);
        Test.stopTest();
    }
}
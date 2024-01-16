/****************************************************************

Created Purpose : Test class for MDL_BatchtochangePX_MigrateAccountfields
****************************************************************/
@isTest(seeAllData= true)
public with sharing class MDL_TestBatchtochangePX_MigrateAccfields{
    static testMethod void testBatchToChangePX_MigrateAcctFields(){
        Date invoiceDate = date.newInstance(date.today().year(), date.today().month(), 01);
        Test.startTest();
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();  
        Account acc = util.getAccount();
        Account acc1 = util.getAccount();
        id recordtypid_nolo = [Select Id 
                               From RecordType 
                               where sobjecttype = 'Account' 
                               and DeveloperName = 'nolo_account'].id;
        
        
        //System.assertEquals(acc.Legal_Entity__c, 'M-H Taxable');
        List<invoiceit_s__Invoice__c> invList = new List<invoiceit_s__Invoice__c>();
        List<Account> acclist = new List<Account>();
        invoiceit_s__Invoice__c inv = new invoiceit_s__Invoice__c(
            invoiceit_s__Account__c=acc.Id,
            invoiceit_s__Invoice_Date__c=invoiceDate,invoiceit_s__Due_Date__c = invoiceDate.addMonths(1),
            invoiceit_s__Invoice_Status__c='Posted');
        invList.add(inv);
        invoiceit_s__Invoice__c inv2 = new invoiceit_s__Invoice__c(
            invoiceit_s__Account__c=acc.Id,
            invoiceit_s__Invoice_Date__c=invoiceDate,invoiceit_s__Due_Date__c = invoiceDate.addMonths(1),
            invoiceit_s__Invoice_Status__c='Posted');
        
        invList.add(inv2);
        invoiceit_s__Invoice__c inv3 = new invoiceit_s__Invoice__c(
            invoiceit_s__Account__c=acc1.Id,
            invoiceit_s__Invoice_Date__c=invoiceDate,invoiceit_s__Due_Date__c = invoiceDate.addMonths(1),
            invoiceit_s__Invoice_Status__c='Posted');
        invList.add(inv3);
        invoiceit_s__Invoice__c inv4 = new invoiceit_s__Invoice__c(
            invoiceit_s__Account__c=acc1.Id,
            invoiceit_s__Invoice_Date__c=invoiceDate,invoiceit_s__Due_Date__c = invoiceDate.addMonths(1),
            invoiceit_s__Invoice_Status__c='Posted');
        
        invList.add(inv4);
        insert invList;
        acc.invoiceit_s__Invoice_Delivery_Type__c = 'Email & Print';
        acc.RecordTypeId = recordtypid_nolo;
        //acc.invoiceit_s__Payment_Terms__c = 'Net 10';
        acc.Business_Unit__c = 'Martindale-Hubbell';
        acc.Migration_Status__c = 'MH-PX Migration Completed';
        acc.invoiceit_s__Gateway__c = system.Label.Nolo_Test_Gateway;
        acc.Business_Unit__c = 'PX Pending Migration';
        acc.Legal_Entity__c = 'JV Taxable';
        accList.add(acc);
        acc1.invoiceit_s__Invoice_Delivery_Type__c = 'Email & Print';
        acc1.RecordTypeId = recordtypid_nolo;
        //acc.invoiceit_s__Payment_Terms__c = 'Net 10';
        acc1.Business_Unit__c = 'Martindale-Hubbell';
        acc1.Migration_Status__c = 'MH-PX Migration Completed';
        acc1.invoiceit_s__Gateway__c = system.Label.Nolo_Test_Gateway;
        acc1.Business_Unit__c = 'PX Pending Migration';
        acc1.Legal_Entity__c = 'JV Taxable';
        accList.add(acc1);
        update accList;
        
        MDL_BatchtochangePX_MigrateAccountfields b = new MDL_BatchtochangePX_MigrateAccountfields();
        Database.BatchableContext bc;
        b.start(bc);
        //List<account> accList = new List<account>();
        accList.add(acc);
        b.execute(bc, accList);
        b.finish(bc);
        Test.stopTest();
    }
}
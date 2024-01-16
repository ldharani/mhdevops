@isTest(seealldata = true)
public with sharing class MDL_Test_BatchAgingReport {
    static testMethod void testAgingReport(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        invoiceit_s__Job__c order = util.getOrder(acc.Id , curr.Id);
        
        invoiceit_s__Invoice__c inv = new invoiceit_s__Invoice__c(
                                                    invoiceit_s__Account__c=acc.Id,
                                                    invoiceit_s__Invoice_Date__c=Date.Today().adddays(-90),invoiceit_s__Due_Date__c=Date.Today(),
                                                    invoiceit_s__Invoice_Status__c='Posted'
                                                    );
        insert inv;
        invoiceit_s__Payment__c pay = new invoiceit_s__Payment__c(
                                                    invoiceit_s__Account__c=acc.Id,
                                                    invoiceit_s__Amount__c=1000,
                                                    invoiceit_s__Currency__c=curr.Id,
                                                    invoiceit_s__Payment_Date__c=Date.Today(),
                                                    invoiceit_s__Status__c='Completed'
                                                    );
        insert pay;        
        invoiceit_s__Invoice_Lines__c invLine = util.getInvoiceLines(inv.Id,order.Id);
        String monthSelected = String.valueOf(Date.Today().month());
        String yearSelected = String.valueOf(Date.Today().year());
        Test.startTest();
        MDL_Batch_AgingReport b = new MDL_Batch_AgingReport(monthSelected,yearSelected);
        Database.executeBatch(b);
        Test.stopTest();
    }
}
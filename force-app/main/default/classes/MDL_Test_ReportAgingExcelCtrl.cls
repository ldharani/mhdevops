@isTest(seealldata=true)
public with sharing class MDL_Test_ReportAgingExcelCtrl {
    static testMethod void reportagingctrl(){
        Test.Starttest();
        MDL_ReportAgingExcelCtrl testCtrl = new MDL_ReportAgingExcelCtrl();
        Test.Stoptest();
        /*
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        
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
        PageReference PageRef = Page.MDL_ReportAgingExcel;
        Test.setCurrentPage(PageRef);
        PageRef.getParameters().put('Month',String.valueOf(Date.Today().month()));
        PageRef.getParameters().put('Year',String.valueOf(Date.Today().year()));
        MDL_ReportAgingExcelCtrl ctrl= new MDL_ReportAgingExcelCtrl();        
        String dateformat = ctrl.getDynamicFormatString();
        
        PageRef.getParameters().put('Month',String.valueOf(Date.Today().addDays(90).month()));
        PageRef.getParameters().put('Year',String.valueOf(Date.Today().addDays(90).year()));
        MDL_ReportAgingExcelCtrl ctrl1= new MDL_ReportAgingExcelCtrl();
                
        Test.startTest();
        PageRef.getParameters().put('Month',String.valueOf(Date.Today().addDays(200).month()));
       PageRef.getParameters().put('Year',String.valueOf(Date.Today().addDays(200).year()));
        MDL_ReportAgingExcelCtrl ctrl2= new MDL_ReportAgingExcelCtrl();     
        Test.stopTest();    
    */  
    }
}
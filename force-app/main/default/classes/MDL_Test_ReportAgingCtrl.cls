@isTest(seealldata=true)
public with sharing class MDL_Test_ReportAgingCtrl {
    static testMethod void reportagingctrl(){
        
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
        MDL_ReportAgingCtrl ctrl= new MDL_ReportAgingCtrl();
        ctrl.monthSelected = String.valueOf(Date.Today().month());
        ctrl.yearSelected = String.valueOf(Date.Today().year());
        String dateformat = ctrl.getDynamicFormatString();
        PageReference pr = ctrl.filterSubmit();     
        
        ctrl.monthSelected = String.valueOf(Date.Today().addDays(90).month());
        ctrl.yearSelected = String.valueOf(Date.Today().addDays(90).year());       
        PageReference pr1 = ctrl.filterSubmit();
        
        ctrl.downloadFile();
        Test.startTest();       
        ctrl.monthSelected = String.valueOf(Date.Today().addDays(200).month());
        ctrl.yearSelected = String.valueOf(Date.Today().addDays(200).year());       
        PageReference pr2 = ctrl.filterSubmit();    
        try{
            ctrl.monthSelected = '0';
            PageReference pr3 = ctrl.filterSubmit();
        }catch(Exception e){}
        
        Test.stopTest();    
    }
}
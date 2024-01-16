@isTest(seealldata = true)
public with sharing class MDL_Test_CtrlDunningDisplayPage_newTest {
    /*
    static testMethod void testDunningInitialization(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
        list<account> acclist = util.creatingbulkAccounts(250);
        for(account acc: acclist){
            acc.Dunning_Hold__c             = false;
            acc.Hold_dunning_letter_till__c = System.today().addDays(2);
        }
        insert acclist;
        
        
        invoiceit_s__Currency__c currencyObj = util.getCurrencyObject();
        
        list<invoiceit_s__Job__c> orders = util.creatingbulkOrders(acclist, currencyObj.id);
        insert orders;
         
        
        list<invoiceit_s__Invoice__c> invoices = util.creatingbulkinvoices(acclist);
        insert invoices;
        
        list<invoiceit_s__Invoice_Lines__c> invlines = new List<invoiceit_s__Invoice_Lines__c>();
        for(invoiceit_s__Invoice__c singleinv : invoices){
            invoiceit_s__Invoice_Lines__c invLine = new  invoiceit_s__Invoice_Lines__c();
            invLine.invoiceit_s__Invoice__c = singleinv.id;
            invLine.invoiceit_s__Job__c = orders[0].Id;
            invLine.invoiceit_s__Unit_Price__c = 100.00;
            invLine.invoiceit_s__Line_Amount__c = 100.00;
            invlines.add(invLine);
        }
        insert invlines;
        
       
        
        test.startTest();
        MDL_CtrlDunningDisplayPage_newTest ctrl = new MDL_CtrlDunningDisplayPage_newTest();
        PageReference pg = ctrl.generateDunningLetters();
        PageReference pg1= ctrl.viewDunningLetters();
        test.stopTest();
    }*/
}
@isTest(seeALLData=true)
private class MDL_test_ctrl_dunningLetters {

    static testMethod void dunningTest() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        RecordType rt = [Select id from RecordType where DeveloperName = 'MH_Invoices'];
        RecordType rt_pay = [Select id from RecordType where DeveloperName = 'MH_Payments'];
        Recordtype rt_Acc = [Select id from RecordType where DeveloperName ='MH_Accounts'];
        Account acc = testData.getAccount();
        Account acc2 = testData.getAccount();
        Dunning_Account_ids__c dunaccid = new Dunning_Account_ids__c(Name='01-30',Account_Ids__c=acc.Id + ',' + acc2.Id,Used__c=true);
        insert dunaccid;        
        invoiceit_s__Currency__c cur = testData.getCurrencyObject();
        invoiceit_s__Invoice__c inv = testData.getInvoice(acc.id);
        //updating invoice for query to provide test data
        inv.RecordTypeId = rt.id;
        inv.invoiceit_s__Invoice_Status__c='Posted';
        //inv.invoiceit_s__Unpaid_Amount__c  = 100;
        update inv;
        //inv.RecordTypeId = rt.id;
        //Database.update(inv);
        invoiceit_s__Job__c ord = testData.getOrder(acc.Id, cur.Id);
        invoiceit_s__Invoice_Lines__c invLines = testData.getInvoiceLines(inv.Id, ord.Id);
        invoiceit_s__Payment__c pay = testData.getPayment(acc.id, cur.id);
        
        
        //pay.RecordTypeId = rt_pay.Id;
        //Database.update(pay); 
        User u = testData.getUser();
        acc.Collector__c = u.Id;
        acc.RecordTypeId = rt_Acc.Id;
        acc.BillingCity = 'Chennai';acc.BillingState = 'TN';acc.BillingCountry = 'USA';acc.BillingPostalCode = '1234';
        Database.update(acc);
        ApexPAges.StandardController sc = new ApexPages.StandardController(acc);
        ApexPages.currentPage().getParameters().put('id',acc.Id);
        ApexPages.currentPage().getParameters().put('DunningAccountId',dunaccid.Id);
        ApexPages.currentPage().getParameters().put('Seq','1');
        MDL_Ctrl_DunningLetters m = new MDL_Ctrl_DunningLetters();
        MDL_Ctrl_DunningLetters.invoiceWrapper invwrapper = new MDL_Ctrl_DunningLetters.invoiceWrapper(pay, 'test');
    }
}
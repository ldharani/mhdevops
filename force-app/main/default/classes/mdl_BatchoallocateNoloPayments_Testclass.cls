@isTest(seeAllData = true)
public class mdl_BatchoallocateNoloPayments_Testclass {
   
    static testmethod void run2condition(){
        
        MDL_UtilClass_TestClass testutil = new MDL_UtilClass_TestClass();
        
        //creating single account
        account acc = testutil.getAccount();
        acc.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Account).getRecordTypeId();
        update acc;
        
        //creating currency
        invoiceit_s__Currency__c cur = testutil.getCurrencyObject();
        
        
        //creating payment
        invoiceit_s__Payment__c pay1 = getPayments(acc.Id, cur.Id);
       
        
        invoiceit_s__Payment__c pay2 = getPayments(acc.Id, cur.Id);
        
        system.debug('@@@payment'+ pay1);
        
        //creating invoice
        invoiceit_s__Invoice__c inv = new  invoiceit_s__Invoice__c();
       
        inv.invoiceit_s__Account__c = acc.Id;    
        inv.invoiceit_s__Due_Date__c = date.Today().addDays(-90);
        inv.invoiceit_s__Invoice_Date__c = date.Today().addDays(-10);
        inv.RecordTypeId = Schema.SObjectType.invoiceit_s__Invoice__c.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Invoice).getRecordTypeId();
        inv.invoiceit_s__Invoice_Status__c = 'Posted';
        insert inv;
        
        //creating order
        invoiceit_s__Job__c order = testutil.getOrder(acc.Id, Cur.id);
        
        invoiceit_s__Invoice_Lines__c invline = testutil.getInvoiceLines(inv.id, order.Id);
        
        inv = [select id, Name, invoiceit_s__Account__c,
                      invoiceit_s__Due_Date__c,
                      invoiceit_s__Invoice_Date__c,
                      invoiceit_s__Unpaid_Amount__c,
                      RecordTypeId,
                      RecordType.Name,
                      invoiceit_s__Invoice_Status__c
                      From invoiceit_s__Invoice__c
                      where id =: inv.id];
       

        
        invoiceit_s__Payment_Allocation__c paymentAllocation = testutil.getPaymentAlloc(pay1.Id, inv.Id);
        //system.debug('@@@@paymentAllocation'+ paymentAllocation);
                                                               

        
        test.startTest();
            Database.executeBatch(new mdl_BatchtoallocateNoloPayments());
        test.stopTest();
    }
    
    public static invoiceit_s__Payment__c getPayments(Id accId,Id curId) {
        invoiceit_s__Payment__c pay = new invoiceit_s__Payment__c();
        pay.invoiceit_s__Account__c = accId;
        pay.invoiceit_s__Currency__c = curId;
        pay.RecordTypeId = Schema.SObjectType.invoiceit_s__Payment__c.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Payments).getRecordTypeId();
        pay.invoiceit_s__Amount__c = 200.00;
        pay.invoiceit_s__Payment_Date__c = Date.today();
        pay.invoiceit_s__Payment_Type__c = 'ACH';
        pay.invoiceit_s__Status__c = 'Completed';
        pay.Adjustment_Reason__c = 'M-H Promotional Credit';
        pay.isTestRunning__c = true;
        insert pay;
        
        return pay;
    }

}
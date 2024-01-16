@isTest(seeAllData = true)
public class MDL_Test_createnewPayments{
   
    static testmethod void run2condition(){
        
        MDL_UtilClass_TestClass testutil = new MDL_UtilClass_TestClass();
        
        //creating single account
        account acc = testutil.getAccount_withoutInsert();
        acc.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Account).getRecordTypeId();
       insert acc;
        
        //creating currency
        invoiceit_s__Currency__c cur = testutil.getCurrencyObject();
        
        
        //creating payments
        List<invoiceit_s__Payment__c>  payments = new List<invoiceit_s__Payment__c>();
         payments.add(getPayments(acc.Id, cur.Id));
         payments.add(getPayments(acc.Id, cur.Id));
         insert payments;
     
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
       

        
        invoiceit_s__Payment_Allocation__c paymentAllocation = testutil.getPaymentAlloc(payments[0].Id, inv.Id);
        //system.debug('@@@@paymentAllocation'+ paymentAllocation);
          invoiceit_s__Payment_Method__c p = new invoiceit_s__Payment_Method__c();
        p.invoiceit_s__Account__c=acc.Id;
        p.invoiceit_s__Default__c=true;
        p.invoiceit_s__Active__c=true;
        p.Rank__c='1';
        p.invoiceit_s__Payment_Method__c = 'ACH';
        p.invoiceit_s__Bank_Account_Name__c = 'Test';
        p.invoiceit_s__Bank_Account_Number__c = String.valueOf(1234567891);
        p.invoiceit_s__Bank_Routing_Code__c = String.valueOf(123456789);
        p.invoiceit_s__Bank_Name__c = 'Test Bank';
        insert p;
        
        test.startTest();
        
            Database.executeBatch(new createnewPayments('Nolo_Invoice'));
           
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
        //pay.Adjustment_Reason__c = 'M-H Promotional Credit';
        //pay.isTestRunning__c = true;
        //insert pay;
        
        return pay;
        
        
    }

}
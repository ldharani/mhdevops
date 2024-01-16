@isTest
public class Test_Trg_Payment_Handler {
    
    static testmethod void testRun1(){
        DefaultPaymentAccount__c ddd = new DefaultPaymentAccount__c();
        ddd.Name = 'DefaultAccountRecord';
        /*
        ddd.Default_Account_ID__c = '0017j00000SIlpn';
        ddd.DefaultAccountNumber__c = '1000095499';
        ddd.PaymentAllocationRectypeID__c = '0124D0000000iUN';
        ddd.PaymentRecordTypeID__c = '0124D0000000iWn';
        ddd.USDCurrencyID__c = 'a03F0000009vD0D';
        */
        ddd.Default_Account_ID__c = '001F000001ae0eX';
        ddd.DefaultAccountNumber__c = '1000095499';
        ddd.PaymentAllocationRectypeID__c = '012F0000001K3Lc';
        ddd.PaymentRecordTypeID__c = '012F0000001K3Ld';
        ddd.USDCurrencyID__c = 'a03F0000009vD0D';
        insert ddd;
        
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account  acc = util.getAccount();
        acc.MH_Cust_Number__c = '10';
        update acc;
        
        blng__Invoice__c invoice = new blng__Invoice__c();
        invoice.blng__Account__c = acc.Id;
        invoice.blng__DueDate__c = date.Today().addDays(-90);
        invoice.blng__InvoiceDate__c = Date.newInstance(2021, 08, 01);
        invoice.blng__InvoiceStatus__c ='Posted';
        insert invoice;
        /*
        blng__Invoice__c invoice = util.getInvoice(acc.Id);
        invoice.blng__InvoiceStatus__c ='Posted';
        update invoice;
        */
        blng__Invoice__c innc = [SELECT ID,Name FROM blng__Invoice__c];
        System.debug('asssadsaa ' + innc.Name);
        blng__Payment__c payment = new blng__Payment__c();
        payment.blng__Account__c = acc.ID;
        payment.blng__PaymentDate__c = Date.today();
        payment.blng__Status__c = 'Draft';
        payment.blng__PaymentType__c = 'ACH';
        payment.blng__Amount__c = 10;
        payment.blng__Invoice__c = invoice.Id;
        payment.blng__Notes__c ='test';
        payment.Uploaded_payment__c = true;
        payment.CSVReference_Amount__c = '10';
        payment.CSVReference_CheckAmt__c = '10';
        payment.CSVReference_Account__c = '10';
        payment.CSVReference_Invoice__c = innc.Name;
        insert payment;
        
        payment.blng__Status__c = 'Posted';
        update payment;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Trg_Payment_Handler payTrg = new Trg_Payment_Handler();
    }
}
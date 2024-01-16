@isTest(seeAllData =true)
public class mdl_InvoiceDetailPageControllerTest {
    
    static testmethod void run2condition(){
        
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        //inserting single account
        account acc = util.getAccount();
        
         
         acc = [select id,name, MH_Cust_Number__c
                       from account where id =: acc.id];
        
      
         invoiceit_s__Invoice__c singleInvoice = new invoiceit_s__Invoice__c();
         singleInvoice.invoiceit_s__Account__c = acc.Id;    
        singleInvoice.invoiceit_s__Due_Date__c = date.Today().addDays(-90);
        singleInvoice.invoiceit_s__Invoice_Date__c = date.Today().addDays(-10);
        singleInvoice.invoiceit_s__Invoice_Status__c = 'Posted';
        singleInvoice.IsDataLoaded__c = 'N';
         insert singleInvoice;
        
        //creating currency
        invoiceit_s__Currency__c singlecurrency = util.getCurrencyObject();
        
        //creating payment
        invoiceit_s__Payment__c singlepayment = new invoiceit_s__Payment__c();
        singlepayment =  util.getPayment(acc.Id, singlecurrency.id);
        singlepayment.Invoice__c = singleInvoice.id;
        update singlepayment;
        
        invoiceit_s__Payment_Method__c singlepaymentmethod = util.getPaymentMethod(acc.Id);
        
        invoiceit_s__Payment_Method__c p = new invoiceit_s__Payment_Method__c();
        p.invoiceit_s__Account__c=acc.Id;
       // p.invoiceit_s__Default__c=true;
        p.invoiceit_s__Name_on_Card__c='Murali';
        p.Rank__c='1';
        p.invoiceit_s__Card_Number__c = string.valueOf(1234567890);
        p.invoiceit_s__CVV__c = string.valueOf(1234);
        p.invoiceit_s__Bank_Account_Number__c = string.valueOf(1234567890);
        insert p;
        
        ApexPages.currentPage().getParameters().put('c', acc.MH_Cust_Number__c);
        
        MDL_InvoiceDetailPageController invoking = new MDL_InvoiceDetailPageController();
        invoking.getselectedFilterMonthItems();
        invoking.selectedFilterMonth ='0';
        invoking.fliterInvoicePayment();
        invoking.selectedFilterMonth ='1';
        invoking.fliterInvoicePayment();
        invoking.selectedFilterMonth ='3';
        invoking.fliterInvoicePayment();
        invoking.selectedFilterMonth ='6';
        invoking.fliterInvoicePayment();
        invoking.selectedFilterMonth ='9';
        invoking.fliterInvoicePayment();
        invoking.selectedFilterMonth ='12';
        invoking.fliterInvoicePayment();
        invoking.FkMethod();
        invoking.signOut();
         MDL_InvoiceDetailPageController.downloadinv(singleInvoice.id);
        MDL_InvoiceDetailPageController.todeleteInvId = singlepaymentmethod.id;
        invoking.deleteInvoice();
        invoking.openHelp();
        MDL_InvoiceDetailPageController.deleteinv(p.id);
       
    }

}
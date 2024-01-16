@isTest(seealldata = true)
public class MDL_Test_Invoice_Detail_controller{
    static testMethod void testSuccess() {         
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        acc.MH_Cust_Number__c = '12334';
        update acc;
        
        invoiceit_s__Currency__c currencyObj = util.getCurrencyObject();
        
        invoiceit_s__Job__c order = util.getOrder(acc.Id , currencyObj.Id);
            
        invoiceit_s__Invoice__c inv= util.getInvoice(acc.id);
        inv.invoiceit_s__Invoice_Status__c='Posted';
        update inv;       
        invoiceit_s__Invoice_Lines__c invLine = util.getInvoiceLines(inv.Id,order.Id);
        
        /*CSC_token__c csctoken = new CSC_token__c(Name='ExpectedToken');
        csctoken.Actual_Token__c = 'encryptedToken';
        csctoken.Base_URL__c = 'http://csc.stg2.lawyers.com';
        csctoken.Form_Submit_URL__c = 'http://invoice.stg2.lawyers.com';
        insert csctoken;*/
        
        PageReference myVfPage = Page.MDL_invoice_detail_page;
        myVfPage.getParameters().put('sessionId', 'D843AEDFFAAC4D000C3F3CBE6293D82C');
        myVfPage.getParameters().put('c', acc.MH_Cust_Number__c);
        myVfPage.getHeaders().put('Authorization','bWFydGluZGFsZXNhbGVzZm9yY2Vjc2NpbnZvaWNlcGF5bWVudGludGVncmF0aW9u');
        myVfPage.getHeaders().put('UID','uid=acf+==ert=');
        Test.setCurrentPage(myVfPage);
        
        Test.startTest();
        MDL_invoice_detail_controller cntrl = new MDL_invoice_detail_controller();
        List<invoiceit_s__Invoice__c> invList = cntrl.getInvoices();
        cntrl.setInvoices();
        string accName = cntrl.getAccName();
        cntrl.setAccName();
        Test.stopTest();
    }    
    static testMethod void testFailure() {         
        PageReference myVfPage = Page.MDL_invoice_detail_page;
        myVfPage.getParameters().put('sessionId', 'D843AEDFFAAC4D000C3F3CBE6293D82C');
        myVfPage.getHeaders().put('Authorization','bWFydGluZGFsZXNhbG');
        myVfPage.getParameters().put('c','12334');      
        myVfPage.getHeaders().put('UID','uid=acf+==ert=');
        Test.setCurrentPage(myVfPage);
        
        Test.startTest();
        MDL_invoice_detail_controller cntrl = new MDL_invoice_detail_controller();  
        Test.stopTest();  
    }    
}
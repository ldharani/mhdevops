@isTest(seealldata = true)
public class MDL_Test_Paynow{
    static testMethod void testAuthorize(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        acc.MH_Cust_Number__c = '12334';
        update acc;
        
        invoiceit_s__Currency__c currencyObj = util.getCurrencyObject();
        
        invoiceit_s__Job__c order = util.getOrder(acc.Id , currencyObj.Id);
            
        invoiceit_s__Invoice__c inv= util.getInvoice(acc.id);
        invoiceit_s__Invoice_Lines__c invLine = util.getInvoiceLines(inv.Id,order.Id);
        
        invoiceit_s__Payment_Method__c payMeth = util.getPaymentMethod(acc.Id);
        invoiceit_s__Payment_Method__c payMeth1 = util.getPaymentMethodActive(acc.Id);
        /*payMeth.invoiceit_s__Card_Number__c = '5555555555554444';
        payMeth.invoiceit_s__Card_Expiration_Month__c = '08';
        payMeth.invoiceit_s__Card_Expiration_Year__c = '2020';
        payMeth.invoiceit_s__Card_Type__c = 'Master';
        update payMeth;*/ 
        
        PageReference myVfPage = Page.MDL_PayNow;
        myVfPage.getParameters().put('sessionId', 'D843AEDFFAAC4D000C3F3CBE6293D82C');
        myVfPage.getParameters().put('Id', inv.Id);
        myVfPage.getHeaders().put('Authorization','bWFydGluZGFsZXNhbGVzZm9yY2Vjc2NpbnZvaWNlcGF5bWVudGludGVncmF0aW9u');
        myVfPage.getHeaders().put('UID','uid=acf+==ert=');
        Test.setCurrentPage(myVfPage);      
        
        MDL_PayNowController cntrl = new MDL_PayNowController();
        cntrl.conid = payMeth.id;
        cntrl.index = '1';
        cntrl.selectcon();
        cntrl.getAllCreditCards();
        cntrl.reset();
        
        
        myVfPage.getParameters().put('authorize-pay','0');
        Test.setCurrentPage(myVfPage);
        
        MDL_PayNowController cntrl1 = new MDL_PayNowController();
        
        Test.startTest();       
        myVfPage.getParameters().put('toValidate','toValidate');
        myVfPage.getParameters().put('CardholderName','Test');
        myVfPage.getParameters().put('CardBillingStreet','Lark Street');
        myVfPage.getParameters().put('CardBillingCity','California');
        myVfPage.getParameters().put('CardBillingCountry','USA');
        myVfPage.getParameters().put('CardBillingState','CA');
        myVfPage.getParameters().put('Phone','1800');
        myVfPage.getParameters().put('Phone2','200');
        myVfPage.getParameters().put('Phone3','300');
        myVfPage.getParameters().put('Zip','12345');
        myVfPage.getParameters().put('CardType','Master');  
        myVfPage.getParameters().put('CardExpirationMonth','08');   
        myVfPage.getParameters().put('ActualCardNumber','5555555555554444');    
        myVfPage.getParameters().put('CardExpirationYear','2020');  
        myVfPage.getParameters().put('InvoiceId',inv.Id);   
        myVfPage.getParameters().put('defaultCard','on');      
        Test.setCurrentPage(myVfPage);
        
        MDL_PayNowController cntrl2 = new MDL_PayNowController();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('successResponseForAuthorization');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        PageReference pg1 = cntrl2.getValues();
        Test.stopTest();   
        
    }
    static testMethod void testPayment(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        acc.MH_Cust_Number__c = '12334';
        update acc;
        
        invoiceit_s__Currency__c currencyObj = util.getCurrencyObject();
        
        invoiceit_s__Job__c order = util.getOrder(acc.Id , currencyObj.Id);
            
        invoiceit_s__Invoice__c inv= util.getInvoice(acc.id);
        invoiceit_s__Invoice_Lines__c invLine = util.getInvoiceLines(inv.Id,order.Id);
        
        invoiceit_s__Payment_Method__c payMeth = util.getPaymentMethod(acc.Id); 
        /*payMeth.invoiceit_s__Card_Number__c = '5555555555554444';
        payMeth.invoiceit_s__Card_Expiration_Month__c = '08';
        payMeth.invoiceit_s__Card_Expiration_Year__c = '2020';
        payMeth.invoiceit_s__Card_Type__c = 'Master';
        update payMeth;*/ 
        
        PageReference myVfPage = Page.MDL_PayNow;
        myVfPage.getParameters().put('sessionId', 'D843AEDFFAAC4D000C3F3CBE6293D82C');
        myVfPage.getParameters().put('Id', inv.Id);
        myVfPage.getHeaders().put('Authorization','bWFydGluZGFsZXNhbGVzZm9yY2Vjc2NpbnZvaWNlcGF5bWVudGludGVncmF0aW9u');
        myVfPage.getHeaders().put('UID','uid=acf+==ert=');
        myVfPage.getParameters().put('authorize-pay','1');     
        myVfPage.getParameters().put('toValidate','toValidate');
        myVfPage.getParameters().put('CardholderName','Test');
        myVfPage.getParameters().put('CardBillingStreet','Lark Street');
        myVfPage.getParameters().put('CardBillingCity','California');
        myVfPage.getParameters().put('CardBillingCountry','USA');
        myVfPage.getParameters().put('CardBillingState','CA');
        myVfPage.getParameters().put('Phone','1800');
        myVfPage.getParameters().put('Phone2','200');
        myVfPage.getParameters().put('Phone3','300');
        myVfPage.getParameters().put('Zip','12345');
        myVfPage.getParameters().put('CardType','Master');  
        myVfPage.getParameters().put('CardExpirationMonth','08');   
        myVfPage.getParameters().put('ActualCardNumber','5555555555554444');    
        myVfPage.getParameters().put('CardExpirationYear','2020');  
        myVfPage.getParameters().put('InvoiceId',inv.Id);   
        myVfPage.getParameters().put('defaultCard','on');   
        myVfPage.getParameters().put('payMethID',payMeth.Id);      
        Test.setCurrentPage(myVfPage);
        Test.startTest();
        MDL_PayNowController cntrl2 = new MDL_PayNowController();    
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('responseForUserId');
        mock.setStatusCode(200);
        //mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);   
        PageReference pg1 = cntrl2.getValues();
         //cntrl2.toUpdate = true;
        cntrl2.toInsert = true;
        cntrl2.toupdatePaymentMethod = true;
        cntrl2.ValidateandSave();
        
        
        Test.stopTest();
        
    }
    static testMethod void testAll(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        acc.MH_Cust_Number__c = '12334';
        update acc;
        
        invoiceit_s__Currency__c currencyObj = util.getCurrencyObject();
        
        invoiceit_s__Job__c order = util.getOrder(acc.Id , currencyObj.Id);
            
        invoiceit_s__Invoice__c inv= util.getInvoice(acc.id);
        invoiceit_s__Invoice_Lines__c invLine = util.getInvoiceLines(inv.Id,order.Id);
        
        invoiceit_s__Payment_Method__c payMeth = util.getPaymentMethod(acc.Id); 
        /*payMeth.invoiceit_s__Card_Number__c = '5555555555554444';
        payMeth.invoiceit_s__Card_Expiration_Month__c = '08';
        payMeth.invoiceit_s__Card_Expiration_Year__c = '2020';
        payMeth.invoiceit_s__Card_Type__c = 'Master';
        update payMeth;*/ 
        PageReference myVfPage = Page.MDL_PayNow;
        myVfPage.getParameters().put('sessionId', 'D843AEDFFAAC4D000C3F3CBE6293D82C');
        myVfPage.getParameters().put('Id', inv.Id);
        myVfPage.getHeaders().put('Authorization','bWFydGluZGFsZXNhbGVzZm9yY2Vjc2NpbnZvaWNlcGF5bWVudGludGVncmF0aW9u');
        myVfPage.getHeaders().put('UID','uid=acf+==ert=');
        myVfPage.getParameters().put('authorize-pay','0');     
        myVfPage.getParameters().put('toValidate','toValidate');
        myVfPage.getParameters().put('CardholderName','Test');
        myVfPage.getParameters().put('CardBillingStreet','Lark Street');
        myVfPage.getParameters().put('CardBillingCity','California');
        myVfPage.getParameters().put('CardBillingCountry','USA');
        myVfPage.getParameters().put('CardBillingState','CA');
        myVfPage.getParameters().put('Phone','1800');
        myVfPage.getParameters().put('Phone2','200');
        myVfPage.getParameters().put('Phone3','300');
        myVfPage.getParameters().put('Zip','12345');
        myVfPage.getParameters().put('CardType','Master');  
        myVfPage.getParameters().put('CardExpirationMonth','08');   
        myVfPage.getParameters().put('ActualCardNumber','5555555555554444');    
        myVfPage.getParameters().put('CardExpirationYear','2020');  
        myVfPage.getParameters().put('InvoiceId',inv.Id);   
        myVfPage.getParameters().put('defaultCard','on'); 
        myVfPage.getParameters().put('payMethID',payMeth.id); 
        Test.setCurrentPage(myVfPage);
        Test.startTest();     
        MDL_PayNowController cntrl2 = new MDL_PayNowController();  
        
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('errorResponseForAuthorization');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
         
        PageReference pg1 = cntrl2.getValues();
        
        payMeth.invoiceit_s__Card_Type__c = 'Master';
        payMeth.invoiceit_s__Card_Number__c = string.valueOf('5555555555554444');
        payMeth.invoiceit_s__Card_Expiration_Month__c = '08';
        payMeth.invoiceit_s__Card_Expiration_Year__c = '2020';
        update payMeth;
         MDL_PayNowController cntrl3 = new MDL_PayNowController();
         cntrl3.getvalues();
        
        delete payMeth;
        MDL_PayNowController cntrl4 = new MDL_PayNowController();
         cntrl4.getvalues();
        Test.stopTest();
        
    }
    static testMethod void testForSuccessMessage(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        acc.MH_Cust_Number__c = '12334';
        update acc;
        
        invoiceit_s__Currency__c currencyObj = util.getCurrencyObject();
        
        invoiceit_s__Job__c order = util.getOrder(acc.Id , currencyObj.Id);
            
        invoiceit_s__Invoice__c inv= util.getInvoice(acc.id);
        invoiceit_s__Invoice_Lines__c invLine = util.getInvoiceLines(inv.Id,order.Id);
        
        invoiceit_s__Payment_Method__c payMeth = util.getPaymentMethod(acc.Id); 
        /*payMeth.invoiceit_s__Card_Number__c = '5555555555554444';
        payMeth.invoiceit_s__Card_Expiration_Month__c = '08';
        payMeth.invoiceit_s__Card_Expiration_Year__c = '2020';
        payMeth.invoiceit_s__Card_Type__c = 'Master';
        update payMeth;*/ 
        invoiceit_s__Gateway__c gateway = util.getGateway();
        invoiceit_s__Transaction__c tran = util.getTransactionObj(payMeth.Id,inv.Id,currencyObj.Id,gateway.Id);     
        
        PageReference myVfPage = Page.MDL_PayNow;
        myVfPage.getParameters().put('sessionId', 'D843AEDFFAAC4D000C3F3CBE6293D82C');
        myVfPage.getParameters().put('Id', inv.Id);
        myVfPage.getHeaders().put('Authorization','bWFydGluZGFsZXNhbGVzZm9yY2Vjc2NpbnZvaWNlcGF5bWVudGludGVncmF0aW9u');
        myVfPage.getHeaders().put('UID','uid=acf+==ert=');
       
        //myVfPage.getParameters().put('toValidate','toValidate');
         myVfPage.getParameters().put('authorize-pay','0');
        /*myVfPage.getParameters().put('CardholderName','Test');
        myVfPage.getParameters().put('CardBillingStreet','Lark Street');
        myVfPage.getParameters().put('CardBillingCity','California');
        myVfPage.getParameters().put('CardBillingCountry','USA');
        myVfPage.getParameters().put('CardBillingState','CA');
        myVfPage.getParameters().put('Phone','1800');
        myVfPage.getParameters().put('Phone2','200');
        myVfPage.getParameters().put('Phone3','300');
        myVfPage.getParameters().put('Zip','12345');
        myVfPage.getParameters().put('CardType','Master');  
        myVfPage.getParameters().put('CardExpirationMonth','08');   
        myVfPage.getParameters().put('ActualCardNumber','5555555555554444');    
        myVfPage.getParameters().put('CardExpirationYear','2020');  
        myVfPage.getParameters().put('InvoiceId',inv.Id);   
        myVfPage.getParameters().put('defaultCard','on');*/ 
        myVfPage.getParameters().put('payMethId',payMeth.Id);
        myVfPage.getParameters().put('transactionId',tran.Id);     
        Test.setCurrentPage(myVfPage);
        Test.startTest();
        MDL_PayNowController cntrl2 = new MDL_PayNowController();
        cntrl2.getvalues();
       
        Test.stopTest();
        
    }
}
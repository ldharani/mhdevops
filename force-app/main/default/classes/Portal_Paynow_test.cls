@isTest(seealldata = true)
public class Portal_Paynow_test{
    static testMethod void testAuthorize(){
        
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc = util.getAccount();
        acc.MH_Cust_Number__c = '12334';
        update acc;
        Order order = util.getOrder(acc.Id);
        
        blng__Invoice__c inv= util.getInvoice(acc.id);
        blng__InvoiceLine__c invLine = util.getInvoiceLines(inv.Id,order.Id);
        
        blng__PaymentMethod__c payMeth = new blng__PaymentMethod__c();
        payMeth.blng__Account__c = acc.Id;
        payMeth.blng__PaymentType__c = 'Credit Card';
        payMeth.blng__Active__c = True;
        payMeth.blng__AutoPay__c = True;
        payMeth.Card_Number__c = '4111111111111111';
        payMeth.blng__Nameoncard__c = 'Jm';
        payMeth.blng__CVV__c = '22222';
        payMeth.blng__CardExpirationYear__c = '2030';
        payMeth.blng__CardExpirationMonth__c = '10'; 
        payMeth.blng__CardType__c = 'Visa';
        payMeth.blng__BillingStreet__c = 'test';
        payMeth.blng__BillingCity__c = 'Albany';
        payMeth.blng__BillingCountry__c = 'United States';
        payMeth.Payment_Profile_ID__c='23456789';
        insert payMeth;
        
        blng__PaymentGateway__c gateway = util.getGateway();
        payMeth.blng__PaymentGateway__c =gateway.id;
        update payMeth;
        
        blng__PaymentMethod__c payMeth2 = new blng__PaymentMethod__c();
        payMeth2.blng__Account__c = acc.Id;
        payMeth2.blng__PaymentType__c = 'Credit Card';
        payMeth2.blng__Active__c = True;
        payMeth2.blng__AutoPay__c = True;
        payMeth2.Card_Number__c = '4111111111111111';
        payMeth2.blng__Nameoncard__c = 'Jm';
        payMeth2.blng__CVV__c = '22222';
        payMeth2.blng__CardExpirationYear__c = '2030';
        payMeth2.blng__CardExpirationMonth__c = '10'; 
        payMeth2.blng__CardType__c = 'Visa';
        payMeth2.blng__BillingStreet__c = 'test';
        payMeth2.blng__BillingCity__c = 'Albany';
        payMeth2.blng__BillingCountry__c = 'United States';
        payMeth2.Payment_Profile_ID__c='23456789';
        insert payMeth2;
        
        PageReference myVfPage = Page.Portal_PayNow;
        myVfPage.getParameters().put('sessionId', 'D843AEDFFAAC4D000C3F3CBE6293D82C');
        myVfPage.getParameters().put('Id', inv.Id);
        myVfPage.getHeaders().put('Authorization','bWFydGluZGFsZXNhbGVzZm9yY2Vjc2NpbnZvaWNlcGF5bWVudGludGVncmF0aW9u');
        myVfPage.getHeaders().put('UID','uid=acf+==ert=');
        Test.setCurrentPage(myVfPage);      
        
        Portal_PayNowController cntrl = new Portal_PayNowController();
        cntrl.conid = payMeth.id;
        cntrl.index = '1';
        cntrl.selectcon();
        cntrl.getAllCreditCards();
        cntrl.reset();
        
        
        myVfPage.getParameters().put('authorize-pay','0');
        Test.setCurrentPage(myVfPage);
        
        Portal_PayNowController cntrl1 = new Portal_PayNowController();
        
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
        
        Portal_PayNowController cntrl2 = new Portal_PayNowController();
        cntrl2.acctObj = acc;
        cntrl2.Phone ='123';
        cntrl2.displayPage = false;
        cntrl2.transactionId = 'test';
        cntrl2.makePayment =false;
        cntrl2.Phone2 = '123';
        cntrl2.Phone3 = '123';
        cntrl2.accountName ='123';
        cntrl2.bankName = 'test';
        cntrl2.bankRouting ='test';
        cntrl2.accountType = 'test';
        cntrl2.accountNumber = 'test';
        
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
        
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc = util.getAccount();
        acc.MH_Cust_Number__c = '12334';
        update acc;
        
        
        Order order = util.getOrder(acc.Id );
        
        blng__Invoice__c inv= util.getInvoice(acc.id);
        blng__InvoiceLine__c invLine = util.getInvoiceLines(inv.Id,order.Id);
        
        blng__PaymentMethod__c payMeth = new blng__PaymentMethod__c();
        payMeth.blng__Account__c = acc.Id;
        payMeth.blng__PaymentType__c = 'Credit Card';
        payMeth.blng__Active__c = True;
        payMeth.blng__AutoPay__c = True;
        payMeth.Card_Number__c = '4111111111111111';
        payMeth.blng__Nameoncard__c = 'Jm';
        payMeth.blng__CVV__c = '22222';
        payMeth.blng__CardExpirationYear__c = '2030';
        payMeth.blng__CardExpirationMonth__c = '10'; 
        payMeth.blng__CardType__c = 'Visa';
        payMeth.Payment_Profile_ID__c='23456789';
        insert payMeth;
        
        
        PageReference myVfPage = Page.Portal_PayNow;
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
        Portal_PayNowController cntrl2 = new Portal_PayNowController();    
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
        
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc = util.getAccount();
        acc.MH_Cust_Number__c = '12334';
        update acc;
        
        Order order = util.getOrder(acc.Id);
        
        blng__Invoice__c inv= util.getInvoice(acc.id);
        blng__InvoiceLine__c invLine = util.getInvoiceLines(inv.Id,order.Id);
        
        blng__PaymentMethod__c payMeth = new blng__PaymentMethod__c();
        payMeth.blng__Account__c = acc.Id;
        payMeth.blng__PaymentType__c = 'Credit Card';
        payMeth.blng__Active__c = True;
        payMeth.blng__AutoPay__c = True;
        payMeth.Card_Number__c = '4111111111111111';
        payMeth.blng__Nameoncard__c = 'Jm';
        payMeth.blng__CVV__c = '22222';
        payMeth.blng__CardExpirationYear__c = '2030';
        payMeth.blng__CardExpirationMonth__c = '10'; 
        payMeth.blng__CardType__c = 'Visa';
        payMeth.Payment_Profile_ID__c='23456789';
        insert payMeth;
        
        
        PageReference myVfPage = Page.Portal_PayNow;
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
        Portal_PayNowController cntrl2 = new Portal_PayNowController();  
        
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('errorResponseForAuthorization');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        PageReference pg1 = cntrl2.getValues();
        
        payMeth.blng__CardType__c = 'Mastercard';
        payMeth.blng__CardNumber__c = string.valueOf('5555555555554444');
        payMeth.blng__CardExpirationMonth__c = '08';
        payMeth.blng__CardExpirationYear__c = '2020';
        update payMeth;
        Portal_PayNowController cntrl3 = new Portal_PayNowController();
        cntrl3.getvalues();
        
        delete payMeth;
        Portal_PayNowController cntrl4 = new Portal_PayNowController();
        cntrl4.getvalues();
        Test.stopTest();
        
    }
    static testMethod void testForSuccessMessage(){
        
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc = util.getAccount();
        acc.MH_Cust_Number__c = '12334';
        update acc;
        
        Order order = util.getOrder(acc.Id);
        
        blng__Invoice__c inv= util.getInvoice(acc.id);
        blng__InvoiceLine__c invLine = util.getInvoiceLines(inv.Id,order.Id);
        
        blng__PaymentMethod__c payMeth = new blng__PaymentMethod__c();
        payMeth.blng__Account__c = acc.Id;
        payMeth.blng__PaymentType__c = 'Credit Card';
        payMeth.blng__Active__c = True;
        payMeth.blng__AutoPay__c = True;
        payMeth.Card_Number__c = '4111111111111111';
        payMeth.blng__Nameoncard__c = 'Jm';
        payMeth.blng__CVV__c = '22222';
        payMeth.blng__CardExpirationYear__c = '2030';
        payMeth.blng__CardExpirationMonth__c = '10'; 
        payMeth.blng__CardType__c = 'Visa';
        payMeth.Payment_Profile_ID__c='23456789';
        insert payMeth;
        
        blng__PaymentGateway__c gateway = util.getGateway();
        payMeth.blng__PaymentGateway__c =gateway.id;
        update payMeth;
        blng__PaymentTransaction__c tran = util.getTransactionObj(payMeth.Id,inv.Id,gateway.Id);     
        
        PageReference myVfPage = Page.Portal_PayNow;
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
        Portal_PayNowController cntrl2 = new Portal_PayNowController();
        cntrl2.getvalues();
        cntrl2.showSuccessMessage = false;
        cntrl2.isValidPage = false;
        cntrl2.smbtoken ='test';
        
        Test.stopTest();
        
    }
    public static testmethod void helptest(){
        
        Test.startTest();
        String hresult = '{"transactionResponse":{"responseCode":"1","authCode":"9I56QW","avsResultCode":"Y","cvvResultCode":"P","cavvResultCode":"2","transId":"60167243790","refTransID":"","transHash":"","testRequest":"0","accountNumber":"XXXX3005","accountType":"AmericanExpress","messages":[{"code":"1","description":"This transaction has been approved."}],"transHashSha2":"","profile":{"customerProfileId":"1931411198","customerPaymentProfileId":"1843490035"},"SupplementalDataQualificationIndicator":0,"networkTransId":"ABRIHCKYWR90B0TJ992PAGS"},"refId":"INV-0284","messages":{"resultCode":"Ok","message":[{"code":"I00001","text":"Successful."}]}}';
        PayNowJson obj = PayNowJson.parse(hresult);
        Test.stopTest();
    }
}
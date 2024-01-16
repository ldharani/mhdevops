@isTest(seealldata = true)
public class Portal_CreditCardBankAccFormCntrlr_Test {
    
    public static testmethod void testMethodA(){
        
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('pendResponseFor400Response');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/xml');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.stopTest();
        
        ApexPages.currentPage().getHeaders().put('SMB_Authorization','SMB_Authorization');      
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        blng__PaymentMethod__c pmRec = new blng__PaymentMethod__c();
        pmRec.blng__Account__c = acc.Id;
        pmRec.blng__PaymentType__c = 'Credit Card';
        pmRec.blng__Active__c = True;
        pmRec.blng__AutoPay__c = True;
        pmRec.Card_Number__c = '1111111111111111';
        pmRec.blng__Nameoncard__c = 'Jm';
        pmRec.blng__CVV__c = '22222';
        pmRec.blng__CardExpirationYear__c = '2030';
        pmRec.blng__CardExpirationMonth__c = '10';
        pmRec.blng__CardType__c = 'Visa';
        insert pmRec;
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(pmRec);           
        Portal_CreditCardBankAccFormCntrlr credRec = new Portal_CreditCardBankAccFormCntrlr(sc);
        credRec.selectedValue = 'Yes';
        credRec.checkcreditorbank = 'true';
        credRec.save();
        credRec.checkcreditorbank = 'false';
        credRec.selectedValue = 'No';
        credRec.save();
        credRec.selectedValue = '';
        credRec.save();
        credRec.selectedValue = 'No';
        credRec.save();
        credRec.goToMainPage();
        credRec.cancel();
        credRec.getItems();
        credRec.idinv = acc.Id;
        credRec.updatepy();
    }
}
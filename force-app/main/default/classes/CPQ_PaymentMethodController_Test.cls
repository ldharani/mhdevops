@isTest
public class CPQ_PaymentMethodController_Test {
    
    public static testmethod void testCase1(){
        // Load Custom settings
        DataFactory.loadCustomSettings();

        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        List<blng__PaymentMethod__c> payNewMap = new List<blng__PaymentMethod__c>();
        blng__PaymentMethod__c pmRecA = new blng__PaymentMethod__c();
        pmRecA.blng__Account__c = lstAcc[0].Id;
        pmRecA.blng__PaymentType__c = 'Credit Card';
        pmRecA.blng__Active__c = True;
        pmRecA.blng__AutoPay__c = True;
        pmRecA.Card_Number__c = '4111111111111111';
        pmRecA.blng__Nameoncard__c = 'Jm';
        pmRecA.blng__CVV__c = '22222';
        pmRecA.blng__CardExpirationYear__c = '2030';
        pmRecA.blng__CardExpirationMonth__c = '10'; 
        pmRecA.blng__CardType__c = 'Visa';
        insert pmRecA;
        payNewMap.add(pmRecA);
        
        CPQ_PaymentMethodController.CPQ_PaymentMethodController(payNewMap);
    }
}
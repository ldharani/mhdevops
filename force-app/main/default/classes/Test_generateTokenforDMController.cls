@isTest
public class Test_generateTokenforDMController {
    
    @testSetup static void setup() {
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        blng__PaymentMethod__c pmRec = new blng__PaymentMethod__c();
        pmRec.blng__Account__c = lstAcc[0].Id;
        pmRec.blng__PaymentType__c = 'Credit Card';
        pmRec.blng__Active__c = True;
        pmRec.blng__AutoPay__c = True;
        pmRec.Card_Number__c = '4111111111111111';
        pmRec.blng__Nameoncard__c = 'Jm';
        pmRec.blng__CVV__c = '22222';
        pmRec.blng__CardExpirationYear__c = '2030';
        pmRec.blng__CardExpirationMonth__c = '10';
        pmRec.blng__CardType__c = 'Visa';
        insert pmRec;
        
    }
    public static testmethod void testMethodA() {
        
        List<Account> lstAcc = [SELECT ID,Order_Status__c FROM Account LIMIT 1];
        lstAcc[0].Order_Status__c = 'Evergreen'; 
        Update lstAcc;
        
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

        set<Id> sPaymentMethodId = new set<Id>();
         sPaymentMethodId.add(pmRecA.Id);
        generateTokenforDMController.generateToken(sPaymentMethodId);
        
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        
      //  generateTokenforDMController.splitFileToLines('ABC');
    }   
    

}
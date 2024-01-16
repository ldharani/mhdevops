/*
Test Class   : SchBatch_generateTokenforDMCtrlTest
Description  : This is test class for Apex Class- SchBatch_generateTokenforDMController
Created date : 05-12-2021
*/
@isTest
public class SchBatch_generateTokenforDMCtrlTest{
    @testSetup static void setUpTestdata() {
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        // Create Payment Gateway
        blng__PaymentGateway__c objPG = new blng__PaymentGateway__c();
        objPG.Name = 'Gateway for Legal Cases - Sandbox';
        objPG.blng__Active__c = true;
        objPG.blng__Default__c = true;
        objPG.blng__GatewayType__c = 'AuthorizeDotNet';
        objPG.TestMode__c = true;
        objPG.adnblng__APILoginId__c = 'Test';
        objPG.adnblng__APITransactionKey__c = 'Test';
        objPG.Endpoint_URL__c = 'https://apitest.authorize.net/xml/v1/request.api';
        insert objPG;
        
        
    }
    
    static testmethod void unitTestMethod1(){
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorNegative());
        
        List<Account> lstAcc = [SELECT Id FROM Account];
        
        List<blng__PaymentGateway__c> lstPG = [SELECT Id FROM blng__PaymentGateway__c LIMIT 1];
        blng__PaymentMethod__c pmRec = new blng__PaymentMethod__c();
        pmRec.blng__Account__c = lstAcc[0].Id;
        pmRec.blng__PaymentType__c = 'Credit Card';
        pmRec.blng__Active__c = True;
        pmRec.blng__AutoPay__c = True;
        pmRec.Card_Number__c = '5555555555554444';
        pmRec.blng__Nameoncard__c = 'Jm';
        pmRec.blng__CVV__c = '22222';
        pmRec.blng__CardExpirationYear__c = '2030';
        pmRec.blng__CardExpirationMonth__c = '10';
        pmRec.blng__CardType__c = 'MasterCard';
        pmRec.blng__PaymentGateway__c = lstPG[0].Id;
        insert pmRec;
        
        pmRec.Payment_Profile_ID__c = null;
        update pmRec;
        
        Test.startTest();
        SchBatch_generateTokenforDMController objSch = new SchBatch_generateTokenforDMController();
        String CRON_EXP = '0 0 23 * * ?';
        system.schedule('Test Tokenization', CRON_EXP, objSch);
        Test.stopTest();
    }
}
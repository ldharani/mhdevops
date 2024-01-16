/*
Test Class   : Batch_generateTokenforDMControllerTest
Description  : This is test class for Apex Class - Batch_generateTokenforDMController
Created date : 05-12-2021
*/
@isTest
public class Batch_generateTokenforDMControllerTest{
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
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
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
        
        update pmRec;
        
        Test.startTest();
        Set<Id> sPaymentMethodId = new Set<Id>();
        for(blng__PaymentMethod__c  ppp : [SELECT ID FROM blng__PaymentMethod__c WHERE Payment_Profile_ID__c = null]){
            sPaymentMethodId.add(ppp.Id);
        }
        Id batchJobId = Database.executeBatch(new Batch_generateTokenforDMController(sPaymentMethodId), 100);
        Test.stopTest();
        
        // Confirm tokenization processed successfully.
        blng__PaymentMethod__c  objPM = [SELECT Id, Payment_Profile_ID__c FROM blng__PaymentMethod__c LIMIT 1];
        system.assert(objPM.Payment_Profile_ID__c != null);
    }
    
    static testmethod void unitTestMethod2(){
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorNegative());
       
        Method_specific_Deactivate_trigger__c objDT = new Method_specific_Deactivate_trigger__c();
        objDT.Activate__c = true;
        insert objDT;
        
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
        
        update pmRec;
        
        Test.startTest();
        Set<Id> sPaymentMethodId = new Set<Id>();
        for(blng__PaymentMethod__c  ppp : [SELECT ID FROM blng__PaymentMethod__c WHERE Payment_Profile_ID__c = null]){
            sPaymentMethodId.add(ppp.Id);
        }
        Id batchJobId = Database.executeBatch(new Batch_generateTokenforDMController(sPaymentMethodId), 100);
        Test.stopTest();
        
    }
}
/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
private class TestPayMethodDisplayController {

    static testMethod void myUnitTest() {
    	
    	MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    	Account acc = testData.getAccount();
    	invoiceit_s__Payment_Method__c payMethod = testData.getPaymentMethod(acc.Id);
    	payMethod.invoiceit_s__Payment_Method__c = 'Credit Card';
    	payMethod.invoiceit_s__Card_Type__c = 'Master';
    	payMethod.invoiceit_s__Card_Number__c = '5105105105105100';
    	payMethod.invoiceit_s__Card_Expiration_Month__c = '10';
    	payMethod.invoiceit_s__Card_Expiration_Year__c = '2040';
    	payMethod.invoiceit_s__CVV__c = '123';
    	payMethod.invoiceit_s__Billing_Address__c = '7100 Athens Place';
    	payMethod.invoiceit_s__Billing_City__c = 'Washington';
    	payMethod.invoiceit_s__Billing_State_Province__c = 'DC';
    	payMethod.invoiceit_s__Billing_Zip_Postal__c = '20521-4150';
    	update payMethod;
    	ApexPAges.StandardController sc = new ApexPages.StandardController(payMethod);
        PaymentMethodDisplayController pmdc = new PaymentMethodDisplayController(sc);
        ApexPages.currentPage().getParameters().put('id',payMethod.Id);
        
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('AVSSuccessResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/xml');
		// Set the mock callout mode
		Test.setMock(HttpCalloutMock.class, mock);
        Pagereference pr1 = pmdc.updatePaymentMethod();
        Pagereference pr2 = pmdc.cancelPaymentMethod();
        Test.stopTest();
    }
    
    static testMethod void myUnitTestErrorResponse() {
    	
    	MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    	Account acc = testData.getAccount();
    	invoiceit_s__Payment_Method__c payMethod = testData.getPaymentMethod(acc.Id);
    	payMethod.invoiceit_s__Payment_Method__c = 'Credit Card';
    	payMethod.invoiceit_s__Card_Type__c = 'American Express';
    	payMethod.invoiceit_s__Card_Number__c = '378282246310005';
    	payMethod.invoiceit_s__Card_Expiration_Month__c = '10';
    	payMethod.invoiceit_s__Card_Expiration_Year__c = '2010';
    	payMethod.invoiceit_s__CVV__c = '123';
    	payMethod.invoiceit_s__Billing_Address__c = '7100 Athens Place';
    	payMethod.invoiceit_s__Billing_City__c = 'Washington';
    	payMethod.invoiceit_s__Billing_State_Province__c = 'DC';
    	payMethod.invoiceit_s__Billing_Zip_Postal__c = '20521-4150';
    	update payMethod;
    	ApexPAges.StandardController sc = new ApexPages.StandardController(payMethod);
        PaymentMethodDisplayController pmdc = new PaymentMethodDisplayController(sc);
        ApexPages.currentPage().getParameters().put('id',payMethod.Id);
        
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('AVSErrorResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/xml');
		// Set the mock callout mode
		Test.setMock(HttpCalloutMock.class, mock);
        Pagereference pr1 = pmdc.updatePaymentMethod();
        Pagereference pr2 = pmdc.cancelPaymentMethod();
        Test.stopTest();
    }
    static testMethod void myUnitTestErrorCreditCard() {
    	
    	MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    	Account acc = testData.getAccount();
    	invoiceit_s__Payment_Method__c payMethod = testData.getPaymentMethod(acc.Id);
    	payMethod.invoiceit_s__Payment_Method__c = 'Credit Card';
    	payMethod.invoiceit_s__Card_Type__c = 'Master';
    	payMethod.invoiceit_s__Card_Number__c = '123456789';
    	payMethod.invoiceit_s__Card_Expiration_Month__c = '10';
    	payMethod.invoiceit_s__Card_Expiration_Year__c = '2040';
    	payMethod.invoiceit_s__CVV__c = '123';
    	payMethod.invoiceit_s__Billing_Address__c = '7100 Athens Place';
    	payMethod.invoiceit_s__Billing_City__c = 'Washington';
    	payMethod.invoiceit_s__Billing_State_Province__c = 'DC';
    	payMethod.invoiceit_s__Billing_Zip_Postal__c = '20521-4150';
    	update payMethod;
    	ApexPAges.StandardController sc = new ApexPages.StandardController(payMethod);
        PaymentMethodDisplayController pmdc = new PaymentMethodDisplayController(sc);
        ApexPages.currentPage().getParameters().put('id',payMethod.Id);
        Test.startTest();
        Pagereference pr1 = pmdc.updatePaymentMethod();        
        Test.stopTest();
    }
    static testMethod void myUnitTestSuccessResponseWithWrongAddress() {
    	
    	MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    	Account acc = testData.getAccount();
    	invoiceit_s__Payment_Method__c payMethod = testData.getPaymentMethod(acc.Id);
    	payMethod.invoiceit_s__Payment_Method__c = 'Credit Card';
    	payMethod.invoiceit_s__Card_Type__c = 'American Express';
    	payMethod.invoiceit_s__Card_Number__c = '378282246310005';
    	payMethod.invoiceit_s__Card_Expiration_Month__c = '10';
    	payMethod.invoiceit_s__Card_Expiration_Year__c = '2040';
    	payMethod.invoiceit_s__CVV__c = '123';
    	payMethod.invoiceit_s__Billing_Address__c = '10 Athens Place';
    	payMethod.invoiceit_s__Billing_City__c = 'Washington';
    	payMethod.invoiceit_s__Billing_State_Province__c = 'DC';
    	payMethod.invoiceit_s__Billing_Zip_Postal__c = '20521';
    	update payMethod;
    	ApexPAges.StandardController sc = new ApexPages.StandardController(payMethod);
        PaymentMethodDisplayController pmdc = new PaymentMethodDisplayController(sc);
        ApexPages.currentPage().getParameters().put('id',payMethod.Id);
        
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('AVSSuccessResponseWithWrongAddress');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/xml');
		// Set the mock callout mode
		Test.setMock(HttpCalloutMock.class, mock);
        Pagereference pr1 = pmdc.updatePaymentMethod();
        Pagereference pr2 = pmdc.cancelPaymentMethod();
        Test.stopTest();
    }
    static testMethod void myUnitTestSuccessResponseWithError() {
    	
    	MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    	Account acc = testData.getAccount();
    	invoiceit_s__Payment_Method__c payMethod = testData.getPaymentMethod(acc.Id);
    	payMethod.invoiceit_s__Payment_Method__c = 'Credit Card';
    	payMethod.invoiceit_s__Card_Type__c = 'American Express';
    	payMethod.invoiceit_s__Card_Number__c = '378282246310005';
    	payMethod.invoiceit_s__Card_Expiration_Month__c = '10';
    	payMethod.invoiceit_s__Card_Expiration_Year__c = '2040';
    	payMethod.invoiceit_s__CVV__c = '123';
    	payMethod.invoiceit_s__Billing_Address__c = '10 Athens Place';
    	payMethod.invoiceit_s__Billing_City__c = 'Washington';
    	payMethod.invoiceit_s__Billing_State_Province__c = 'DC';
    	payMethod.invoiceit_s__Billing_Zip_Postal__c = '20521';
    	update payMethod;
    	ApexPAges.StandardController sc = new ApexPages.StandardController(payMethod);
        PaymentMethodDisplayController pmdc = new PaymentMethodDisplayController(sc);
        ApexPages.currentPage().getParameters().put('id',payMethod.Id);
        
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('AVSSuccessResponseWithError');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/xml');
		// Set the mock callout mode
		Test.setMock(HttpCalloutMock.class, mock);
        Pagereference pr1 = pmdc.updatePaymentMethod();
        Pagereference pr2 = pmdc.cancelPaymentMethod();
        Test.stopTest();
    }
    static testMethod void myUnitTestErrorCreditCardDetails() {
    	
    	MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    	Account acc = testData.getAccount();
    	invoiceit_s__Payment_Method__c payMethod = testData.getPaymentMethod(acc.Id);
    	payMethod.invoiceit_s__Payment_Method__c = 'Credit Card';
    	payMethod.invoiceit_s__Card_Type__c = 'Master';
    	payMethod.invoiceit_s__Card_Expiration_Month__c = '10';
    	payMethod.invoiceit_s__Card_Expiration_Year__c = '2040';
    	payMethod.invoiceit_s__CVV__c = '123';
    	payMethod.invoiceit_s__Billing_Address__c = '7100 Athens Place';
    	payMethod.invoiceit_s__Billing_City__c = 'Washington';
    	payMethod.invoiceit_s__Billing_State_Province__c = 'DC';
    	payMethod.invoiceit_s__Billing_Zip_Postal__c = '20521-4150';
    	update payMethod;
    	ApexPAges.StandardController sc = new ApexPages.StandardController(payMethod);
        PaymentMethodDisplayController pmdc = new PaymentMethodDisplayController(sc);
        ApexPages.currentPage().getParameters().put('id',payMethod.Id);
        Test.startTest();
        Pagereference pr1 = pmdc.updatePaymentMethod();        
        Test.stopTest();
    }
    static testMethod void myUnitTestNoCreditCardDetails() {
    	
    	MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    	Account acc = testData.getAccount();
    	invoiceit_s__Payment_Method__c payMethod = testData.getPaymentMethod(acc.Id);
    	payMethod.invoiceit_s__Payment_Method__c = 'Credit Card';
    	payMethod.invoiceit_s__Card_Type__c = 'Master';
    	payMethod.invoiceit_s__CVV__c = '123';
    	update payMethod;
    	ApexPAges.StandardController sc = new ApexPages.StandardController(payMethod);
        PaymentMethodDisplayController pmdc = new PaymentMethodDisplayController(sc);
        ApexPages.currentPage().getParameters().put('id',payMethod.Id);
        Test.startTest();
        Pagereference pr1 = pmdc.updatePaymentMethod();        
        Test.stopTest();
    }
}
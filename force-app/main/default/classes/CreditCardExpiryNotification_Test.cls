/***********************************************************************************************************************
* @author - VR
* @date - 
* @description - Test Class for Credit Card Expiry Notificaiton
* Ticket - MHBS-5416
* @test class of - CreditCardExpiryNotification

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************/

@isTest
public class CreditCardExpiryNotification_Test {
    static testMethod void testMethod1() {
        
        Test.startTest();
        // Load Custom settings
        DataFactory.loadCustomSettings();
        String currentMonth = String.valueOf(System.today().month());
        String currentYear = String.valueOf(System.today().year());
        
        if(currentMonth.length() == 1){
            currentMonth = '0' + currentMonth;
        }
        
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
                Test.stopTest();
        blng__PaymentMethod__c pm = new blng__PaymentMethod__c(blng__BillingEmail__c='person1@test.com',blng__Nameoncard__c='person',
                                                               blng__CardExpirationMonth__c=currentMonth,blng__CardExpirationYear__c=currentYear,blng__CardNumber__c='1234',Card_Number__c='1234',blng__PaymentType__c='Credit Card');
        pm.blng__Account__c=lstAcc[0].Id;
        insert pm;
        
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        CreditCardExpiryNotification obj = new CreditCardExpiryNotification();
        DataBase.executeBatch(obj); 
        

    }
}
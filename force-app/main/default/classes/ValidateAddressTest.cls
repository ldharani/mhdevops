/***********************************************************************************************************************
 * @author - VR
 * @date - 03 Feb 2022
 * @description - Api callout for Avalara Address Endpoint.
 * Ticket - MHBS-6251
 * @test class of - ValidateAddress

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************/

@isTest
public class ValidateAddressTest {
    static testMethod void testschedule(){
        
        AvalaraAddressValidationDataFix__c setting1 = new AvalaraAddressValidationDataFix__c();
        AvalaraAddressValidationDataFix__c setting2 = new AvalaraAddressValidationDataFix__c();
        AvalaraAddressValidationDataFix__c setting3 = new AvalaraAddressValidationDataFix__c();
        
		setting1.Name = 'BillingStreet';
		setting1.Field__c = '__________________________________________________%';
        setting2.Name = 'Customer_Status__c';
		setting2.Field__c = 'Former Sub';
        setting3.Name = 'RecordType.Name';
		setting3.Field__c = 'M-H Account';
        
		insert setting1; insert setting2 ;insert setting3; 
        

        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
         Id accRecordTypeIdMH = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        
        Account a = new Account(Name='Test',BillingStreet='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                               ,Customer_Status__c='',RecordTypeID=accRecordTypeIdMH);
        insert a;
        ValidateAddress.validateAddressOnAccount(); 
        //ValidateAddress.validateAddressOnLead();
        
    }
}
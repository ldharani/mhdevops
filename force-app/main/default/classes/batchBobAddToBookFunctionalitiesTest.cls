/**************************************************************
  
 * Description : MH AE adding lead/contact to book of business
 * Class Name  :   batchBobAddToBookFunctionalitiesTest
 * Test Class of : batchBobAddToBookFunctionalities 
 * Created Date : 19/12/2022 by Sachin
 * 
 * Change History
************************************************************************************************************************
Jira       ModifiedBy    Date         Requested By    Tag     Description
MHBS-8287  Sachin        25/11/2022                   T01     Open Items in MH book of business Additional requirement to MHBS 7870

************************************************************************************************************************/
// <T01>
@isTest()
public class batchBobAddToBookFunctionalitiesTest {
    static testMethod void testMethod1(){
        DataFactory.loadCustomSettings();
        Id leadRecordTypeIdParent = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Lead').getRecordTypeId();
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test MH Acc', accRecordTypeId, 1);
        List<Account> lstAcc2 = DataFactory.createAccount('Test MH Acc 2', accRecordTypeId, 1);
		Account acc = new Account(id=lstAcc[0].id,ParentId=lstAcc2[0].id);
        update acc;
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> lstCon =  DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        List<String> ldString = new List<String>();
        test.startTest();
        Lead ld = new Lead();
        ld.FirstName = 'Test';
        ld.LastName = 'Bob Lead';
        ld.Company = 'Test Company';
        ld.Email = 'test@test.com';
        ld.Street = '700 N. Fairfax Street, Suite 220	';
        ld.City = 'Alexandria';
        ld.State = 'VA';
        ld.Country = 'USA';
        ld.PostalCode = '22314';
        ld.Contact__c = lstCon[0].Id;
        ld.Add_to_Book__c = true;
        ld.Created_From_Contact__c = true;
        ld.RecordTypeId = leadRecordTypeIdParent;
        insert ld;
        ldString.add(ld.Id);
        
        batchBobAddToBookFunctionalities.updateContact(ldString);
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2()); 
        ld.Add_to_Book__c = false;
        update ld;
        batchBobAddToBookFunctionalities.updateContact(ldString);
        ld.status = 'Unqualified';
        update ld;
        batchBobAddToBookFunctionalities.updateContact(ldString);
       test.stopTest();
    }
}
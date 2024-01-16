@isTest()
public class batchUpdateAcc_MALead_AddtoBook_Test {
    static testMethod void testMethod1(){
        DataFactory.loadCustomSettings();
        Id leadRecordTypeIdParent = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Lead').getRecordTypeId();
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId();
        Id ibaccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        List<Account> lstAcc2 = DataFactory.createAccount('Test IB Acc', ibaccRecordTypeId, 1);
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> lstCon =  DataFactory.createContact('Test Con', lstAcc2[0], conRecordTypeId, 1);
        List<String> ldString = new List<String>();
        test.startTest();
        Account acc = new Account(id=lstAcc[0].id);
        acc.ParentId = lstAcc2[0].id;
        update acc;
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
        
        batchUpdateAcc_MALead_AddtoBook.updateAccounts(ldString);
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2()); 
        ld.Add_to_Book__c = false;
        update ld;
       	batchUpdateAcc_MALead_AddtoBook.updateAccounts(ldString);
       test.stopTest();
    }
}
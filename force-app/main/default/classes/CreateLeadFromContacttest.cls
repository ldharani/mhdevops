@isTest
private class CreateLeadFromContacttest{
    @testSetup static void setup() {
        // Create common test accounts
        DataFactory.loadCustomSettings();
        
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2()); 
        Id leadRecordTypeIdParent = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-H lead').getRecordTypeId();
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test MH Acc', accRecordTypeId, 1);
        lstAcc[0].name = 'Pablo Dupli';
        update lstAcc;
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> lstCon =  DataFactory.createContact('Test MH Con', lstAcc[0], conRecordTypeId, 1);
        lstCon[0].Email = 'test1323@fd.com';
        lstCon[0].FirstName ='Uni';
        lstCon[0].LastName ='Dup';
        lstCon[0].ISLN__c ='43488263';
        update lstCon;
        List<Contact> lstCon2 =  DataFactory.createContact('Test MH Con2', lstAcc[0], conRecordTypeId, 1);
        lstCon2[0].Email = 'BOBCon2406@fd.com';
        lstCon2[0].FirstName ='inU';
        lstCon2[0].LastName ='pud';
        lstCon2[0].ISLN__c ='9626433';
        update lstCon2;
    }
    
    static testmethod void createlead(){
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2()); 
        Id RecordT = Schema.SObjectType.Lead.getrecordtypeinfosbyname().get('M-N Leads').getrecordtypeId();
        Contact con = [Select Id From Contact Where Email ='test1323@fd.com' AND ISLN__c = '43488263' Limit 1];
        test.startTest();
        Contact con2 = [Select Id From Contact Where Email ='BOBCon2406@fd.com' AND ISLN__c = '9626433' Limit 1];
        User_Profile_Record_Type_Mapping__c up = new User_Profile_Record_Type_Mapping__c();
        up.User_Profile_Name__c = 'MAC Sales Rep';
		up.Record_Type_Dev_Name__c = 'M-A Lead';
        up.Name = 'MAC Sales Rep';
        insert up;
        CreateLeadFromContact.createLead(con.Id );  
        CreateLeadFromContact.createLeadDupx(con2.Id,RecordT ); 
        CreateLeadFromContact.createAvvoLead(con.id,'MAC Sales Rep');
        Test.stopTest();
        
    }
    
}
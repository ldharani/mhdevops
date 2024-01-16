/*****
Class Name: CreateMHAccSKUFirm
Created by: Bharath

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-9194    Bharath S     08/05/2023   Nama            <T01>   Create MH account from Avvo attorney account instead of Firm Account
************************************************************************************************************************/
@isTest
public class CreateMHAccSKUFirm_test {
    public static testMethod void testMethod1(){
       	//Parent IB Acc
        String IBAccRectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
		Account ibacc = new Account();
        ibacc.Name = 'Test Parent Account 8868';
        ibacc.RecordTypeId = IBAccRectypeId;
        insert ibacc;
        
        //Contact
		Contact con = new Contact();
        con.LastName = 'Test Contact 8868';
        con.AccountId = ibacc.id;
        insert con;
        
        //Avvo Firm Acc
        String AvvoFirmAccRectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId();
		Account avvofirmacc = new Account();
        avvofirmacc.Name = 'Test Avvo Firm Account 8868';
        avvofirmacc.RecordTypeId = AvvoFirmAccRectypeId;
        avvofirmacc.ParentId = ibacc.id;
        insert avvofirmacc;
        
        //Avvo Att Acc 
        //<T01> starts
        String AvvoAttAccRectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
		Account avvoattacc = new Account();
        avvoattacc.Name = 'Test Avvo Att Account 8868';
        avvoattacc.RecordTypeId = AvvoAttAccRectypeId;
        avvoattacc.ParentId = avvofirmacc.id;
        insert avvoattacc;
        //<T01> ends
        
        //Related Contact
        Account_Contact_Relation__c acr = new Account_Contact_Relation__c();
		acr.Account__c = avvoattacc.Id;
        acr.Contact__c = con.Id;
       	insert acr; 
        
        Map<Id,Account> newAccMap = new Map<Id,Account>();
        newAccMap.put(avvoattacc.id,avvoattacc); //<T01>
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        CreateMHAccSKUFirm.createAcc(newAccMap);
        test.stopTest();

    }
}
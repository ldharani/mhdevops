@isTest
public class CreateLead_Test {
    public Static testmethod void testCase(){
        Account accA = new Account();
        accA.name = 'test';
        accA.JV_Order_Status__c = 'Active';
        accA.Do_Not_Call__c = false;
        insert accA;
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId = accA.Id;
        insert con;
        
        Contact conList = [SELECT ID,AccountId,JV_Order_Status__c,Account.JV_Order_Status__c FROM Contact LIMIT 1];
        System.debug('AAAA ' + conList.JV_Order_Status__c);
        System.debug('BBBB ' + conList.Account.JV_Order_Status__c);
        test.startTest();
        CreateLead_AC acc = new CreateLead_AC();
        CreateLead_AC.getContact(conList.Id);
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        test.stopTest(); 
    }
    public Static testmethod void testCaseA(){
        Account accA = new Account();
        accA.name = 'test';
        accA.Do_Not_Call__c = true;
        insert accA;
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId = accA.Id;
        insert con;
        
        Contact conList = [SELECT ID,AccountId,JV_Order_Status__c,Account.JV_Order_Status__c FROM Contact LIMIT 1];
        System.debug('AAAA ' + conList.JV_Order_Status__c);
        System.debug('BBBB ' + conList.Account.JV_Order_Status__c);
        test.startTest();
        CreateLead_AC acc = new CreateLead_AC();
        CreateLead_AC.getContact(conList.Id);
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        test.stopTest(); 
    }
    public Static testmethod void testCaseC(){
        Account accA = new Account();
        accA.name = 'test';
        insert accA;
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId = accA.Id;
        con.HasOptedOutOfEmail = True;
        insert con;
        
        Contact conList = [SELECT ID,AccountId,JV_Order_Status__c,Account.JV_Order_Status__c FROM Contact LIMIT 1];
        System.debug('AAAA ' + conList.JV_Order_Status__c);
        System.debug('BBBB ' + conList.Account.JV_Order_Status__c);
        test.startTest();
        CreateLead_AC acc = new CreateLead_AC();
        CreateLead_AC.getContact(conList.Id);
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        test.stopTest(); 
    }
    public Static testmethod void testCaseD(){
        Id RecordT = Schema.SObjectType.Order.getRecordTypeInfosByName().get('MH Order').getRecordTypeId();
        Account accA = new Account();
        accA.name = 'test';
        insert accA;
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId = accA.Id;
        insert con;
        
        Contact conList = [SELECT ID,AccountId,JV_Order_Status__c,Account.JV_Order_Status__c FROM Contact LIMIT 1];
        System.debug('AAAA ' + conList.JV_Order_Status__c);
        System.debug('BBBB ' + conList.Account.JV_Order_Status__c);
        
        test.startTest();
        
        CreateLead_AC acc = new CreateLead_AC();
        CreateLead_AC.getContact(conList.Id);
        CreateLead_AC.getContactXX(conList.Id, RecordT);
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        test.stopTest(); 
    }
}
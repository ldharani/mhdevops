@isTest
public class AddressController_Test {
     static testMethod void UseCase(){
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        List<Account> acclist = new List<Account>();
        Set<Id> accId = new Set<Id>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        Account acc = new Account();
        acc.Name = 'TestRec';
        insert acc;
        AddressController.getObjectById(acc.Id);
      
          Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Lead).getRecordTypeId();
        Lead lead=new Lead(LastName='Doe11',
                           Company='Test',
                           Status='Inquiry', 
                           RecordTypeId = LeadRecordTypeId,
                           MH_Customer_Number__c = '1568462461',
                           Postalcode = '08820'
                          );
        insert lead;  
         AddressController.getObjectById(lead.Id);
         
         contact con = new contact(); 
        con.LastName = 'Test Contact' ;
        con.Email = 'test@salesforce.com';
        con.AccountId = acc.Id;
        insert con;
         
         AddressController.getObjectById(con.Id);
    }
}
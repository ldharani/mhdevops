@isTest
public class Test_MH_LeadReassignmentOnNoLSA {
    
    static testMethod void testbatch1(){
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        
        Contact c = new Contact(FirstName = 'Test Name',LastName = 'Test Last Name');
        insert c;
        
        Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Lead).getRecordTypeId();
        Lead lead=new Lead(LastName='Doe11',
                           Company='Test',
                           Status='Open', 
                           RecordTypeId = LeadRecordTypeId,
                           LeadSource = 'Self Source',
                           Add_To_Book__c = false,
                           Contact__c = c.Id
                          );
        insert lead; 
        
        Task tsk = new Task(Subject = 'Call',WhoId = lead.Id, Purpose__c = 'Quarterly Call',Type='Meeting');
        insert tsk;
        
        test.startTest();
        MH_LeadReassignmentOnNoLSA b = new MH_LeadReassignmentOnNoLSA();
        Database.executeBatch(b,1);
        test.stopTest();
    }    

}
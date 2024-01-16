@isTest
private class OutreachJSON_Test {
    
    @isTest Static Void methodA(){
        Lead newLead = new Lead() ;
        newLead.FirstName = 'Cole';
        newLead.LastName = 'Swain';
        newLead.Company = 'BlueWave';
        newLead.Status = 'contacted'; 
        newLead.Current_Sequence_Name__c = 'New Client';
        newLead.Current_Sequence_Step_Number__c = 4;
        newLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-NG Leads').getRecordTypeId();
        insert newLead;
        
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject='How is Ngage doing';
        t.Status='Not Started';
        t.Priority='Normal';
        t.whoid = newLead.id;
        insert t;
        
        t.Replied_At__c = '2020-11-17T13:49:18.000-05:03';
        update t;
    }
    
}
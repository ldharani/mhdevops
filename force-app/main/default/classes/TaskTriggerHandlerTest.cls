/******************************************************************************************************************************
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date          Requested By    Tag     Description
MHBS-8532    Chetna        02/03/2022    John Mattheson  T01     Track email and call activity/tasks on Lead records
************************************************************************************************************************/

@isTest
public class TaskTriggerHandlerTest {
    
    static testmethod void run2condtion(){
    
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Deactivate_Trigger_for_data_load__c dtc = new Deactivate_Trigger_for_data_load__c();
        dtc.Deactivate_trigger__c = false;
        dtc.name = 'Deactivate';
        insert dtc;
        
        //creating test data
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
        
        //creating account
        account acc = testData.getAccount();
        //insert acc;

        //creating task
        ID salesTaskRectypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task Type').getRecordTypeId();
        task t1   = testData.createTask(acc.id,salesTaskRectypeId);
        task t2   = testData.createTask(acc.id,salesTaskRectypeId);
        
        Test.startTest();
            insert t1;
            insert t2;
        Test.stopTest();
    }
    
    
    static testmethod void firstTaskCreatedonLeadTest(){
        
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Deactivate_Trigger_for_data_load__c dtc = new Deactivate_Trigger_for_data_load__c();
        dtc.Deactivate_trigger__c = false;
        dtc.name = 'Deactivate';
        insert dtc;
        
        //creating test data
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
          // create a Lead
       Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-N Leads').getRecordTypeId();
       Lead lead=new Lead(LastName='Doe11',
                          Company='Test',
                          Status='Inquiry',
                          RecordTypeId = LeadRecordTypeId,
                          MH_Customer_Number__c = '1568462461',
                          Postalcode = '08820'
                        //  Lead_Owner_Change_Date__c = DateTime.newInstance(date.today().year(), date.today().month(), date.today().day()-1)
                          );
       insert lead;
        
        Test.startTest();
         ID salesTaskRectypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task Type').getRecordTypeId();
        task t1   = testData.createTask(lead.id,salesTaskRectypeId);
        t1.WhatId = NULL;
        t1.WhoId = lead.id;
        t1.Description = 'Test abcd - <br/> asbdjasdadasd';
        insert t1;
        Test.stopTest();
        
        
    }
    
    
    static testmethod void updateRelToOnAvvoTask(){
    
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Deactivate_Trigger_for_data_load__c dtc = new Deactivate_Trigger_for_data_load__c();
        dtc.Deactivate_trigger__c = false;
        dtc.name = 'Deactivate';
        insert dtc;
        
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
        
        account acc = testData.getAccount();
        
        account acc2 = testData.getAccount();
        
        //creating contact
        contact con = testData.getContact(acc.Id);
        con.Related_To_Account__c = acc2.Id;
        update con;
        
        ID avvoTaskRectypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Avvo Acct Exec Task').getRecordTypeId();
        task t1   = new task(WhoId = con.Id,RecordTypeId= avvoTaskRectypeId,Subject = 'Test',Priority = 'Normal', Status = 'New'  );
        
        Test.startTest();
            insert t1;
            
        Test.stopTest();
        
    }
    
    
    static testmethod void updateSalesActivityROE(){
    
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        
        List<Task> taskList = new List<Task>();
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Deactivate_Trigger_for_data_load__c dtc = new Deactivate_Trigger_for_data_load__c();
        dtc.Deactivate_trigger__c = false;
        dtc.name = 'Deactivate';
        insert dtc;
        
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
        
        account acc = testData.getAccount();
        
        //creating contact
        contact con = testData.getContact(acc.Id);
        
        ID salesTaskRectypeId  = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task Type').getRecordTypeId();
        ID noloTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('MN Sales Task Type').getRecordTypeId();
        ID ngageTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('M-NG Sales Task').getRecordTypeId();

        
        task t1   = new task(WhoId = con.Id,RecordTypeId= salesTaskRectypeId  ,Subject = 'Test',Priority = 'Normal', Status = 'New', Purpose__c = 'Service'  );
        task t2   = new task(WhoId = con.Id,RecordTypeId= noloTaskRecordTypeId ,Subject = 'Test',Priority = 'Normal', Status = 'New', Purpose__c = 'Service'  );
        task t3   = new task(WhoId = con.Id,RecordTypeId= ngageTaskRecordTypeId ,Subject = 'Test',Priority = 'Normal', Status = 'New', Purpose__c = 'Service'  );
        taskList.add(t1);
        taskList.add(t2);
        taskList.add(t3);
        
        Test.startTest();
            insert taskList;
            
        Test.stopTest();
    }
    //<T01>
    static testmethod void testTaskSummaryFieldsUpdateOnLead(){
    
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        
        //creating test data
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
        
        //creating account
        account acc = testData.getAccount();
        //insert acc;
        //creating Contact
        Contact con = testData.getContact(acc.Id);
        //creating Lead
        Lead ld = testData.Createlead(con.Id);
        insert ld;

        //creating task
        ID salesTaskRectypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task Type').getRecordTypeId();
        List<task> taskList   = new List<task>();
        //task t2   = testData.createTask(acc.id,salesTaskRectypeId);
        
        task tsk1 = new task();
        tsk1.Subject  = 'Email';
        tsk1.Type = 'Email';
        tsk1.RecordTypeId = salesTaskRectypeId;
        tsk1.OwnerId    = UserInfo.getUserId();
        tsk1.Status='In Progress';
        tsk1.WhoId  = ld.Id;
        taskList.add(tsk1);
        
        task tsk2 = new task();
        tsk2.Subject  = 'Call';
        tsk2.Type = 'Call';
        tsk2.RecordTypeId = salesTaskRectypeId;
        tsk2.OwnerId    = UserInfo.getUserId();
        tsk2.Status='In Progress';
        tsk2.WhoId  = ld.Id;
        taskList.add(tsk2);
        
        Test.startTest();
        if(taskList!=null && !taskList.isEmpty()){
            insert taskList;
        }
        Test.stopTest();
    }//<T01>

}
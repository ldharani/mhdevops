@isTest
public class automateSEOStrategistAssignmentTest {
    public static testmethod void seoStrategyAssign(){
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        Milestone1_Project__c project = new Milestone1_Project__c (name ='Content (General)');
        project.Account__c = lstAcc[0].id;
        insert project;    
        
        String userName;
        String newUserId;
        test.startTest();
        List<GroupMember> u = [SELECT GroupId, UserOrGroupId from GroupMember where Group.Name = 'MS - SEO Strategist' Limit 2];
        
        List<Milestone1_Project__c> prjLst = new List<Milestone1_Project__c>();
        List<Milestone1_Task__c> tskLst = new List<Milestone1_Task__c>();
        Map<Id, Milestone1_Project__c> oldMap = new Map<id, Milestone1_Project__c>();
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('proj');
        proj.SEO_Strategist__c = NULL;
        insert proj;
        //proj.SEO_Strategist__c = NULL;
        //update proj;
        oldMap.put(proj.id, proj);
        
        system.debug('====old1'+oldMap);
        system.debug('====proj'+proj);
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(proj.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        //testMilestone.Project__c = proj.Id;
        insert testMilestone;
        
        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Started_date__c = system.now();
        testTask.Dued_date__c = system.now();
        testTask.assign_To_Type__c = 'Queue';
        testTask.Assigned_Onwer__c = u[0].GroupId;
        //testTask.Project_Milestone__c = testMilestone.Id;
        insert testTask;
        tskLst.add(testTask);
        
        
        proj.SEO_Strategist__c = '0050G00000CQ8qv';
        userName = 'Martha';
        //prjLst.add(proj);
        update proj; 
        prjLst.add(proj);
        automateSEOStrategistAssignment.changeTaskOwner(prjLst, oldMap);
        automateSEOStrategistAssignment classCQP = new automateSEOStrategistAssignment();
        classCQP.FkMethod();
        
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        
        Database.executeBatch(new Batch_automateSEOStrategistAssignment (), 10);
        Batch_automateSEOStrategistAssignment m = new Batch_automateSEOStrategistAssignment();
        Database.executeBatch(m);
        
        Schedule_automateSEOStrategistAssignment m1 = new  Schedule_automateSEOStrategistAssignment();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, m1);
        
        test.stopTest();    
    }
}
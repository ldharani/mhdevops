@isTest(seealldata = true)
public with sharing class MilestoneTaskHandlerTest{    
    @isTest static void testTaskListMethods() {        
        Milestone1_Project__c p = Milestone1_Test_Utility.sampleProjectActive('TaskCompProject');
        insert p;        
        Milestone1_Milestone__c m = Milestone1_Test_Utility.sampleMilestone(p);
        m.Deadline__c = Date.today()-1;
        insert m;        
        List<Milestone1_Task__c> testTasks = new List<Milestone1_Task__c>();
        
        // Incomplete task, not blocked, not late
        Milestone1_Task__c t0 = Milestone1_Test_Utility.sampleTask(
            m.Id, Date.today().addDays(-2), Date.today().addDays(1), false, false);
        testTasks.add(t0);
        
        // Incomplete task, late, not blocked
        Milestone1_Task__c t1 = Milestone1_Test_Utility.sampleTask(
            m.Id, Date.today().addDays(-2), Date.today().addDays(-1), false, false);
        t1.assign_To_Type__c = 'Queue';
        testTasks.add(t1);
        
        // Incomplete task, not late, blocked
        Milestone1_Task__c t2 = Milestone1_Test_Utility.sampleTask(
            m.Id, Date.today().addDays(-2), Date.today().addDays(1), false, true);
        t2.assign_To_Type__c = 'User'; 
        testTasks.add(t2);
        
        // Complete task
        Milestone1_Task__c t3 = Milestone1_Test_Utility.sampleTask(
            m.Id, Date.today().addDays(-2), Date.today().addDays(1), true, false);
        t3.assign_To_Type__c = 'User'; 
        testTasks.add(t3); 
        
        Milestone1_Task__c t4 = Milestone1_Test_Utility.sampleTask(
            m.Id, NULL, NULL, true, false);
        t4.assign_To_Type__c = 'User'; 
        t4.Task_Stage__c = 'Ready to Start';
        testTasks.add(t4);        
        
        insert testTasks;
        
        MilestoneTaskHandler ctrl = new MilestoneTaskHandler();        
    }
    public static testMethod void testUnitMethod1(){
        
        Milestone1_Project__c p = Milestone1_Test_Utility.sampleProjectActive('TaskCompProject');
        insert p;        
        Milestone1_Milestone__c m = Milestone1_Test_Utility.sampleMilestone(p);
        m.Deadline__c = Date.today()-1;
        insert m;        
        List<Milestone1_Task__c> testTasks = new List<Milestone1_Task__c>();
        Map<Id,Milestone1_Task__c> newTaskMap = new Map<Id,Milestone1_Task__c>();
        Map<Id,Milestone1_Task__c> oldTaskMap = new Map<Id,Milestone1_Task__c>();
        Milestone1_Task__c t1 = Milestone1_Test_Utility.sampleTask(m.Id, Date.today().addDays(-2), Date.today().addDays(-1), false, false);
        t1.assign_To_Type__c = 'Queue';
        t1.Task_Stage__c = 'Not Started';
        testTasks.add(t1);
        Insert testTasks;
        oldTaskMap.put(t1.Id, t1);
        
        t1.Task_Stage__c = 'Ready to Start';
        t1.Started_date__c = NULL;
        t1.Dued_date__c = NULL;
        Update testTasks;
        newTaskMap.put(t1.Id, t1);
        
        test.startTest();
        MilestoneTaskHandler.updateTaskDeadline(newTaskMap,oldTaskMap);
        test.stopTest();
    }
}
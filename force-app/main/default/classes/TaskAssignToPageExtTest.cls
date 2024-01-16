@isTest
public class TaskAssignToPageExtTest {
    
    
    static testmethod void run2condition(){
        //creating test data
        Milestone1_Project__c project = Milestone1_Test_Utility.sampleProject('project');
        insert project;
        
        Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(project);
        insert milestone;
        
        Milestone1_Task__c sampleTask = Milestone1_Test_Utility.sampleTask(milestone.id);
        insert sampleTask;	
        
        ApexPages.StandardController sc = new ApexPages.StandardController(sampleTask);
        TaskAssignToPageExt taskpagext = new TaskAssignToPageExt(sc);
        taskpagext.getownerTypes();
        taskpagext.Save();
    }
    
    
    
    

}
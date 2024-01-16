@isTest(seeAlldata = true)
private class MileStoneTriggerHandlerTest{
   static testMethod void handleProjectStatus() {
       
      //creating test data
        Milestone1_Project__c p = Milestone1_Test_Utility.sampleProjectActive('TaskCompProject');
        insert p;   
       
        List<Milestone1_Milestone__c> milestoneList = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c m = Milestone1_Test_Utility.sampleMilestone(p);
        m.Deadline__c = Date.today()-1;
        m.Status__c   = 'Not Needed';
       
        Milestone1_Milestone__c m1 = Milestone1_Test_Utility.sampleMilestone(p);
        m1.Deadline__c = Date.today()-1;
        m1.Status__c   = 'Not Needed';
        milestoneList.add(m1);
        insert milestoneList;
       
        Test.startTest();
         milestoneList[0].status__c = 'Completed';
         update milestoneList[0];
        Test.stopTest();
       
       
    // Create a poject
    //Test.startTest();
   // MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    
   /* Account a = testData.getAccount();
     
    Milestone1_Project__c  proj = testData.getProject(a.id );
    Milestone1_Milestone__c mstone = testData.getMilestone(proj);
    Milestone1_Task__c tsk1 = testData.getTask(mstone);*/
    
   //proj.Account__c = 'Test Project';
    /*
    proj.Status__c = 'complete';
    proj.Kickoff__c  =   Date.today().addDays(-14);
    proj.Deadline__c =   Date.today().addDays(14);
    update proj;
    
    Milestone1_Milestone__c mstone = testData.getMilestone(proj);
    mstone.Status__c = 'Not Needed';
    Update mstone ;
    
    Milestone1_Milestone__c mstone1 = testData.getMilestone(proj);
    mstone1.Status__c = 'Cancelled';
    Update mstone1 ;    
    
    Milestone1_Task__c tsk1 = testData.getTask(mstone);
    tsk1.Name = 'A - Intro';
    tsk1.Task_Stage__c = 'completed';
    tsk1.assign_To_Type__c= 'User' ;
    Update tsk1;
    Milestone1_Task__c tsk2 = testData.getTask(mstone1 );
    tsk2.Name = 'A - Intro';
    tsk2.Task_Stage__c = 'completed';
    tsk2.assign_To_Type__c= 'User' ;
    Update tsk2;
     
     Test.stopTest();
     */
     }
     
     
  
  }
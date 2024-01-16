/*
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
/**
* This Class test Task Trigger functionality  
*/

@isTest
private class Milestone1_Task_Trigger_Utility_Test {

	/**
	* Test exceeded chatter suscription
	*/
    static testMethod void chatterSubscriptionLimitExceeded() {
		// Create a poject
		Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Chatter Blow');
		insert proj;

		// Create a milestone
		Milestone1_Milestone__c mstone = Milestone1_Test_Utility.sampleMilestone(proj);
		insert mstone;

		// Add 600 tasks to the milestone to exceed chatter user subscription limit
		List<Milestone1_Task__c> lTask = new List<Milestone1_Task__c>();

		for(Integer j = 0; j < 6; j++){        	
			for(Integer i = 0; i < 100; i++){
				lTask.add( Milestone1_Test_Utility.sampleTask(mstone.Id) );
			}
			
			try{
				insert lTask;
			}
			catch(Exception e){
				if( e.getMessage().contains( Milestone1_Task_Trigger_Utility.SUBSCRIPTION_LIMIT_EXCEEDED )){
					system.assert(true);
				}
				else{
					system.assert(false, e.getMessage());
				}
			}

			lTask.clear();
		}
	}
    
    static testmethod void testcheckTaskProjectStatus(){
          Milestone1_Project__c p = Milestone1_Test_Utility.sampleProjectActive('TaskCompProject');
        p.Status__c = 'New';
        insert p;        
        Milestone1_Milestone__c m = Milestone1_Test_Utility.sampleMilestone(p);
        m.Deadline__c = Date.today()-1;
        insert m;        
        List<Milestone1_Task__c> testTasks = new List<Milestone1_Task__c>();
        
        // Incomplete task, not blocked, not late
        Milestone1_Task__c t0 = Milestone1_Test_Utility.sampleTask(
            m.Id, Date.today().addDays(-2), Date.today().addDays(1), false, false);
        t0.Task_Stage__c = 'Not Started';
        t0.Dued_date__c = system.now();
        insert t0;
        
         Milestone1_Task__c t1 = Milestone1_Test_Utility.sampleTask(
            m.Id, Date.today().addDays(-2), Date.today().addDays(1), false, false);
        t1.Predecessor_Task__c = t0.id;
        insert t1;
        
        t0.Dued_date__c = system.now() + 2;
        update t0;
        
        Test.startTest();
        try{
            MilestoneTaskHandler.TaskAfterUpdateRecurstion = true;
            t0.Task_Stage__c = 'In Progress';
            update t0;
        }
        catch(exception ex){
            system.debug('@@@@Exception');
                
        }
        Test.stopTest();
    }
    static testmethod void testcheckOWDPermissions(){
        //Milestone1_Task_Trigger_Utility tskTrgUtli = new Milestone1_Task_Trigger_Utility();
        Milestone1_Project__c p = Milestone1_Test_Utility.sampleProjectActive('TaskCompProject');
        p.Status__c = 'New';
        insert p;        
        Milestone1_Milestone__c m = Milestone1_Test_Utility.sampleMilestone(p);
        m.Deadline__c = Date.today()-1;
        insert m;        
        List<Milestone1_Task__c> testTasks = new List<Milestone1_Task__c>();
        
        // Incomplete task, not blocked, not late
        Milestone1_Task__c t0 = Milestone1_Test_Utility.sampleTask(
            m.Id, Date.today().addDays(-2), Date.today().addDays(1), false, false);
        t0.Task_Stage__c = 'Not Started';
        t0.Dued_date__c = system.now();
        insert t0;
        testTasks.add(t0);
        
         Milestone1_Task__c t1 = Milestone1_Test_Utility.sampleTask(
            m.Id, Date.today().addDays(-2), Date.today().addDays(1), false, false);
        t1.Predecessor_Task__c = t0.id;
        insert t1;
        testTasks.add(t1);
        t0.Dued_date__c = system.now() + 2;
        update t0;
        
        Milestone1_Task_Trigger_Utility.checkOWDPermissions(testTasks);
        Milestone1_Task_Trigger_Utility.ownerNamePopulataion(testTasks);
    }
}
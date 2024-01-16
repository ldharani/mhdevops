/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class MDL_TestEmailMessageTrigger {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Case c = new Case();
        c.Origin = 'Email';
        insert c;
        
        Task t = new Task(ActivityDate = Date.today().addDays(7),Subject='Sample Task',WhatId = c.Id,OwnerId = UserInfo.getUserId(),Status='In Progress',Historical_SFDC_ID__c = '1234');
        insert t;
        
        Task t1 = new Task(ActivityDate = Date.today().addDays(7),Subject='Sample Task',WhatId = c.Id,OwnerId = UserInfo.getUserId(),Status='In Progress',Historical_SFDC_ID__c = t.Id);
        insert t1;
        
        EmailMessage em = new EmailMessage();
        em.ParentId = c.Id;
        em.ActivityId = t.Id;
        em.FromAddress = 'abc@gmail.com';
        em.ToAddress = 'xyz@gmail.com';
        em.MessageDate = Datetime.now();
        em.Subject = 'Test subject';
        insert em;
        
    }
    static testMethod void myUnitTest1() {
    	Case c = new Case();
        c.Origin = 'Email';
        insert c;
        
        Task t = new Task(ActivityDate = Date.today().addDays(7),Subject='Sample Task',WhatId = c.Id,OwnerId = UserInfo.getUserId(),Status='In Progress',Historical_SFDC_ID__c = '1234');
        insert t;
        
        Task t1 = new Task(ActivityDate = Date.today().addDays(7),Subject='Sample Task',WhatId = c.Id,OwnerId = UserInfo.getUserId(),Status='In Progress',Historical_SFDC_ID__c = t.Id);
        insert t1;
        
        Blob b = Blob.valueOf('Test Data');  
      
	    Attachment attachment = new Attachment();  
	    attachment.ParentId = t.Id;  
	    attachment.Name = 'Test Attachment for Parent';  
	    attachment.Body = b;  
	      
	    insert attachment;  
    }
}
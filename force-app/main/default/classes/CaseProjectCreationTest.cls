@isTest(seealldata=true)
public class CaseProjectCreationTest {
    static testmethod void ProjectToCreateCases(){
         MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    
        Account acc = testData.getAccount();
        Case c = new Case();
        c.AccountId = acc.Id;
        c.Subject = 'Subscription Renewal for '+acc.Name;
        c.Description = 'Account is due for renewal within 120 days';
        c.Priority = 'Medium';
        c.Status = 'New';
        c.Area__c  = 'Create Project';
        c.Sub_Area__c  = 'Annual Custom Content';
        insert c;
        
       
        Test.startTest();
        caseTriggerHandler.caseRecursionBeforeUpdate = True;
        CaseProjectCreation.caseRecursionAfterUpdate  = True;
        c.Status ='Closed';
        update c;
        
       // CaseProjectCreation.getProjectToCreateCases(casetoProject,caseOldMap) ;
        
        Test.stopTest();
        
    }
    
    static testmethod void ProjectToCreateCases2(){
         MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    
        Account acc = testData.getAccount();
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
        Milestone1_Project__c project = new Milestone1_Project__c (name ='SEO_Platinum',Account__c = acc.Id, Status__c='Optimization' );
        insert project;  
        
        Task t = new Task();
        t.Subject='Testing';
        t.WhatId= acc.Id;
        t.Status = 'Open';
        t.Priority = 'Normal';
        insert t;
        
        //acc.Is_Account_At_Risk__c = True;
        //acc.At_Risk_reason__c = 'Testing';
        update acc;
        
        Case c = new Case();
        c.AccountId = acc.Id;
        c.Subject = 'SEO Account potentially at Risk';
        c.Description = 'Account is due for renewal within 120 days';
        c.Priority = 'Medium';
        c.Status = 'New';
        c.Area__c  = 'Create Milestone';
        c.Sub_Area__c  = 'SEO_Audit/Account Review At Risk';
        //c.Is_SEO_Related__c = 'In SEO Review';
        insert c;
        
        Milestone1_Milestone__c milestoneObj = new Milestone1_Milestone__c(Project__c = project.Id,Name ='SEO_Audit/Account Review At Risk');
       
        
        Test.startTest();
        caseTriggerHandler.caseRecursionBeforeUpdate = True;
        CaseProjectCreation.caseRecursionAfterUpdate  = True;
        c.Is_SEO_Related__c = 'In SEO Review';
        update c;
        
       // CaseProjectCreation.getProjectToCreateCases(casetoProject,caseOldMap) ;
        
        Test.stopTest();
        
    }
}
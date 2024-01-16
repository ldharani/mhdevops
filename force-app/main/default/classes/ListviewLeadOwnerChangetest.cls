@isTest
public class ListviewLeadOwnerChangetest{
    
   static testmethod void run2condition(){
        
        MDL_UtilClass_TestClass utilclass = new MDL_UtilClass_TestClass();
        //creating test users with lead owner number
         profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' Limit 1];  
        List<user> userlist = new List<user>();
        List<lead>Leadlist= new List<lead>();
        List<lead>Leadtoupdate= new List<lead>();
        user u1 =  new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newuser'+utilclass.randomise()+'@testorg.com', LeadOwner_Number__c = 1);
        user u2 =  new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newuser'+utilclass.randomise()+'@testorg.com', LeadOwner_Number__c= 2);
        
        userlist.add(u1);
        userlist.add(u2);
        insert u2;
        
        
        system.runAs(u1){
          // create a Lead
       Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-N Leads').getRecordTypeId();
       Lead lead=new Lead(LastName='Doe11',
                          Company='Test',
                          Status='Open',
                          MN_Lead_Source__c = 'Marketing',
                          RecordTypeId = LeadRecordTypeId,First_Activity_Created__c = TRUE,
                          MH_Customer_Number__c = '1568462461', OwnerId = u1.id,
                          Postalcode = '08820',
                          Lead_Owner_Change_Date__c = System.today()-1
                          );
       insert lead;
       
       //Leadlist.add(lead);
       
       
            lead.OwnerId  =u2.id;
            update lead;
            Leadlist.add(lead);
            Test.startTest();
           ApexPages.Standardsetcontroller stdobj1 =new ApexPages.Standardsetcontroller (Leadlist);           
           LeadOwnerChnageListPageExt ctrl = new LeadOwnerChnageListPageExt(stdobj1 );
           ctrl.SaveRecords();         
            Test.stopTest();
        }     
    }
    
    
    static testmethod void run3condition(){
        
        MDL_UtilClass_TestClass utilclass = new MDL_UtilClass_TestClass();
        //creating test users with lead owner number
         profile p = [SELECT Id FROM Profile WHERE Name='MN Sales Reps' Limit 1];  
        List<user> userlist = new List<user>();
        List<lead>Leadlist= new List<lead>();
         user u1 =  new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newuser'+utilclass.randomise()+'@testorg.com', LeadOwner_Number__c = 1);
         user u2 =  new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id ,
         TimeZoneSidKey='America/Los_Angeles', UserName='newuser'+utilclass.randomise()+'@testorg.com', LeadOwner_Number__c= 2);
         
      
        userlist.add(u1);
        userlist.add(u2);
        insert u2;
        
        
        system.runAs(u1){
          // create a Lead
       Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-H lead').getRecordTypeId();
       Lead lead=new Lead(LastName='Doe11',
                          Company='Test',
                          Status='Open',
                          MN_Lead_Source__c = 'Marketing',
                          RecordTypeId = LeadRecordTypeId,First_Activity_Created__c = TRUE,
                          MH_Customer_Number__c = '1568462461', OwnerId = u1.id,
                          Postalcode = '08820',
                          Lead_Owner_Change_Date__c = System.today()-1
                          );
       insert lead;
       
       
            lead.OwnerId  =u2.id;
            update lead;
            Leadlist.add(lead);
            Test.startTest();
           ApexPages.Standardsetcontroller stdobj1 =new ApexPages.Standardsetcontroller (Leadlist);           
           LeadOwnerChnageListPageExt ctrl = new LeadOwnerChnageListPageExt(stdobj1 );
           ctrl.SaveRecords();         
            Test.stopTest();
        }     
    }
    
    static testmethod void run4condition(){
        
        MDL_UtilClass_TestClass utilclass = new MDL_UtilClass_TestClass();
        //creating test users with lead owner number
         profile p = [SELECT Id FROM Profile WHERE Name='MH Sales Rep' Limit 1];  
        List<user> userlist = new List<user>();
        List<lead>Leadlist= new List<lead>();
        user u1 =  new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newuser'+utilclass.randomise()+'@testorg.com', LeadOwner_Number__c = 1);
        user u2 =  new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id ,
         TimeZoneSidKey='America/Los_Angeles', UserName='newuser'+utilclass.randomise()+'@testorg.com', LeadOwner_Number__c= 2);
         
      
        userlist.add(u1);
        userlist.add(u2);
        insert u2;
        
        
        system.runAs(u1){
          // create a Lead
       Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-N Leads').getRecordTypeId();
       Lead lead=new Lead(LastName='Doe11',
                          Company='Test',
                          Status='Open',
                          MN_Lead_Source__c = 'Marketing',
                          RecordTypeId = LeadRecordTypeId,First_Activity_Created__c = TRUE,
                          MH_Customer_Number__c = '1568462461', OwnerId = u1.id,
                          Postalcode = '08820',
                          Lead_Owner_Change_Date__c = System.today()-1
                          );
            insert lead;     
            lead.OwnerId  =u2.id;
           
           update lead;
           
          Id LeadRecordTypeId1 = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-H lead').getRecordTypeId();
       Lead lead1=new Lead(LastName='Doe11',
                          Company='Test',
                          Status='Open',
                          MN_Lead_Source__c = 'Marketing',
                          RecordTypeId = LeadRecordTypeId1,First_Activity_Created__c = TRUE,
                          MH_Customer_Number__c = '1568462461', OwnerId = u1.id,
                          Postalcode = '08820',
                          Lead_Owner_Change_Date__c = System.today()-1
                          );
       insert lead1;
       
       lead1.OwnerId  =u2.id;
           
           update lead1;
       
            Leadlist.add(lead);
            Leadlist.add(lead1);
            
            Test.startTest();
           ApexPages.Standardsetcontroller stdobj1 =new ApexPages.Standardsetcontroller (Leadlist);           
           LeadOwnerChnageListPageExt ctrl = new LeadOwnerChnageListPageExt(stdobj1 );
           ctrl.SaveRecords();         
            Test.stopTest();
        }     
    }
    
    static testmethod void run5condition(){
        
        MDL_UtilClass_TestClass utilclass = new MDL_UtilClass_TestClass();
        //creating test users with lead owner number
         profile p = [SELECT Id FROM Profile WHERE Name='Avvo Account Executive' Limit 1];  
        List<user> userlist = new List<user>();
        List<lead>Leadlist= new List<lead>();
        List<lead>updateLeadlist= new List<lead>();
        user u1 =  new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newuser'+utilclass.randomise()+'@testorg.com', LeadOwner_Number__c = 1);
        user u2 =  new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id ,
         TimeZoneSidKey='America/Los_Angeles', UserName='newuser'+utilclass.randomise()+'@testorg.com', LeadOwner_Number__c= 2);
         
      
        userlist.add(u1);
        userlist.add(u2);
        insert userlist;
        
       Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-H lead').getRecordTypeId();
       Lead lead=new Lead(LastName='Doe11',
                          Company='Test',
                          Status='Open',
                          MN_Lead_Source__c = 'Marketing',
                          RecordTypeId = LeadRecordTypeId,First_Activity_Created__c = TRUE,
                          MH_Customer_Number__c = '1568462461', OwnerId = u1.id,
                          Postalcode = '08820',
                          Lead_Owner_Change_Date__c = System.today()-1
                          );
             
        Leadlist.add(lead);
        insert LeadList;
        
        System.debug('@@@Lead List insert---------->'+LeadList);
           
        system.runAs(u1){
          // create a Lead
           Test.startTest();

        ApexPages.Standardsetcontroller stdobj1 =new ApexPages.Standardsetcontroller (Leadlist);           
        LeadOwnerChnageListPageExt ctrl = new LeadOwnerChnageListPageExt(stdobj1 );
        ctrl.leadsList = LeadList;
        
            lead.OwnerId  =u2.id;
           updateLeadlist.add(lead);
         
            
           
           
           
           update updateLeadlist;
           ctrl.FkMethod();
           ctrl.SaveRecords();         
            Test.stopTest();
        }     
    }
    
    
    /*static testmethod void run5condition(){
        
        MDL_UtilClass_TestClass utilclass = new MDL_UtilClass_TestClass();
        //creating test users with lead owner number
         profile p = [SELECT Id FROM Profile WHERE Name='Ngage Sales'];  
        List<user> userlist = new List<user>();
        List<lead>Leadlist= new List<lead>();
        user u1 =  new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newuser'+utilclass.randomise()+'@testorg.com', LeadOwner_Number__c = 1);
        user u2 =  new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id ,
         TimeZoneSidKey='America/Los_Angeles', UserName='newuser'+utilclass.randomise()+'@testorg.com', LeadOwner_Number__c= 2);
         
      
        userlist.add(u1);
        userlist.add(u2);
        insert u2;
        
        
        system.runAs(u1){
          // create a Lead
       Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-N Leads').getRecordTypeId();
       Lead lead=new Lead(LastName='Doe11',
                          Company='Test',
                          Status='Open',
                          MN_Lead_Source__c = 'Marketing',
                          RecordTypeId = LeadRecordTypeId,First_Activity_Created__c = TRUE,
                          MH_Customer_Number__c = '1568462461', OwnerId = u1.id,
                          Postalcode = '08820',
                          Lead_Owner_Change_Date__c = System.today()-1
                          );
       insert lead;
       
       
            lead.OwnerId  =u2.id;
            update lead;
            Test.startTest();
            
           ApexPages.StandardController stdobj1 =new ApexPages.StandardController(Leadlist);
           //lead l = (Lead)stdobj1.getRecord();
           LeadOwnerChnageListPageExt ctrl = new LeadOwnerChnageListPageExt(stdobj1);
           
           ctrl.SaveRecord();
         
            Test.stopTest();
        }    
    }*/

}
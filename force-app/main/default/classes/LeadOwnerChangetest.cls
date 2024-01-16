@isTest
public class LeadOwnerChangetest{
    
    static testmethod void run2condition(){
        
        MDL_UtilClass_TestClass utilclass = new MDL_UtilClass_TestClass();
        //creating test users with lead owner number
         profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];  
        List<user> userlist = new List<user>();
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
       
       
            lead.OwnerId  =u2.id;
            update lead;
            Test.startTest();
             //lead l = (Lead)ctrl.getRecord();
            // ApexPages.currentPage().getParameters().put('id',Lead.id);
           ApexPages.StandardController stdobj1 =new ApexPages.StandardController(Lead);
           lead l = (Lead)stdobj1.getRecord();
           LeadOwnerPageExt ctrl = new LeadOwnerPageExt (stdobj1);
           //UpdatNgagePrice ctrl = new UpdatNgagePrice(new apexPages.StandardController(childopp));
           ctrl.SaveRecord();
         
            Test.stopTest();
        }     
    }
    
    
    static testmethod void run3condition(){
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        MDL_UtilClass_TestClass utilclass = new MDL_UtilClass_TestClass();
        //creating test users with lead owner number
         profile p = [SELECT Id FROM Profile WHERE Name='MN Sales Reps'];  
        List<user> userlist = new List<user>();
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
            Test.startTest();
            
           ApexPages.StandardController stdobj1 =new ApexPages.StandardController(Lead);
           lead l = (Lead)stdobj1.getRecord();
           LeadOwnerPageExt ctrl = new LeadOwnerPageExt (stdobj1);
           
           ctrl.SaveRecord();
         
            Test.stopTest();
        }     
    }
    
    static testmethod void run4condition(){
        
        MDL_UtilClass_TestClass utilclass = new MDL_UtilClass_TestClass();
        //creating test users with lead owner number
         profile p = [SELECT Id FROM Profile WHERE Name='CPQ MH Sales Rep'];  
        List<user> userlist = new List<user>();
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
                          Lead_Owner_Change_Date__c = System.today()-1,
                          Areas_of_Practice__c = 'Accountants Liability'
                          );
       insert lead;
       
       
            lead.OwnerId  =u2.id;
            update lead;
            Test.startTest();
            
           ApexPages.StandardController stdobj1 =new ApexPages.StandardController(Lead);
           lead l = (Lead)stdobj1.getRecord();
           LeadOwnerPageExt ctrl = new LeadOwnerPageExt (stdobj1);
           
           ctrl.SaveRecord();
         
            Test.stopTest();
        }     
    }
    
    static testmethod void run5condition(){
        
        MDL_UtilClass_TestClass utilclass = new MDL_UtilClass_TestClass();
        //creating test users with lead owner number
         profile p = [SELECT Id FROM Profile WHERE Name='Ngage Sales'];  
        List<user> userlist = new List<user>();
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
                          Lead_Owner_Change_Date__c = System.today()-1,
                          Areas_of_Practice__c = 'Accountants Liability'
                          );
       insert lead;
       
       
            lead.OwnerId  =u2.id;
            update lead;
            Test.startTest();
            
           ApexPages.StandardController stdobj1 =new ApexPages.StandardController(Lead);
           lead l = (Lead)stdobj1.getRecord();
           LeadOwnerPageExt ctrl = new LeadOwnerPageExt (stdobj1);
           
           ctrl.SaveRecord();
         
            Test.stopTest();
        }     
    }

}
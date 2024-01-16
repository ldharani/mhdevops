@isTest
public class LeadAssignmentBatchTest {
    
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
                          MN_Lead_Source__c = 'Inbound Call',
                          RecordTypeId = LeadRecordTypeId,
                          MH_Customer_Number__c = '1568462461',
                          Postalcode = '08820'
                        //  Lead_Owner_Change_Date__c = DateTime.newInstance(date.today().year(), date.today().month(), date.today().day()-1)
                          );
       insert lead;
            lead.Lead_Owner_Change_Date__c = DateTime.newInstance(date.today().year(), date.today().month(), date.today().day()-10);
            update lead;
            Test.startTest();
             LeadAssinmentBatch sh1 = new LeadAssinmentBatch();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test lead Check', sch, sh1); 
         
            Test.stopTest();
        }     
    }

}
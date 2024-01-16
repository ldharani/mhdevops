// Author          : akash
// Description     : Test class for LeadTriggerHandler and LeadTrigger

//Done by Sai :Changes made for New Record type changes MHBS-995

@isTest(seeAllData = true)
public class LeadTriggerHandlerTest {
    
    static testmethod void run2condition(){
         Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        
        // create a Lead
        Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Lead).getRecordTypeId();
        Lead lead=new Lead(LastName='Doe11',
                           Company='Test',
                           Status='Inquiry', 
                           RecordTypeId = LeadRecordTypeId,
                           MH_Customer_Number__c = '1568462461',
                           Postalcode = '08820'
                          );
        insert lead;                
        
        test.startTest();
        Database.LeadConvert lc11 = new database.LeadConvert();
        lc11.setLeadId(lead.Id);
        
        //LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
        //lc.setConvertedStatus(convertStatus.MasterLabel);
        lc11.setConvertedStatus('Qualified');
        leadConvertController.ValidationFire = False;
        Database.LeadConvertResult lcr = Database.convertLead(lc11);
        System.assert(lcr.isSuccess());
        
        test.stopTest();
    }
    
    static testmethod void leadsquenceCheckTest(){
         Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        
        // create a Lead
        Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Lead).getRecordTypeId();
        
        List<lead> leadsList = new List<lead>();
        leadsList.add(new Lead(LastName='Doe11',
                               Company='Test',
                               Status='Inquiry', 
                               RecordTypeId = LeadRecordTypeId,
                               MH_Customer_Number__c = '1568462461',
                               Postalcode = '08820',
                               email = 'test@salesforce.com'
                              ));
        leadsList.add(new Lead(LastName='Doe12',
                               Company='Test',
                               Status='Inquiry', 
                               RecordTypeId = LeadRecordTypeId,
                               MH_Customer_Number__c = '1568362461',
                               Postalcode = '08820',
                               email = 'test@salesforce.com'
                              ));
        insert leadsList; 
        
        //creating util class instance
        MDL_UtilClass_TestClass utilclass = new MDL_UtilClass_TestClass();
        
        //creating single account 
        account acc = utilclass.getAccount();
        
        //creating single currency
        invoiceit_s__Currency__c singlecurrency = utilclass.getCurrencyObject();
        
        //creating contact
        contact con = new contact(); 
        con.LastName = 'Test Contact' ;
        con.Email = 'test@salesforce.com';
        con.AccountId = acc.Id;
        con.Actively_being_sequenced__c = true; //Added for coverage
        insert con;
        
        Test.startTest();
        leadsList[0].Actively_being_sequenced__c = True;
        update leadsList[0];
        Map<Id,Lead> oldMap = new Map<Id,Lead>();
        oldMap.put(leadsList[0].Id,leadsList[0]);
        LeadTriggerHandler.leadsequencheckoninsert(leadsList);
        LeadTriggerHandler.leadsquenceCheck(leadsList,oldMap);
        LeadTriggerHandler.testCoverMethod(leadsList);
        Test.stopTest();
    }
    
    static testMethod void testMethod1() {
         Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        
        Lead newLead = new Lead() ;
        newLead.FirstName = 'Cole';
        newLead.LastName = 'Swain';
        newLead.Company = 'BlueWave';
        newLead.Status = 'contacted';
        insert newLead;
        
        try {
            Delete  newLead;
        }
        catch(Exception ee)
        {}
    }
    
     static testMethod void testMethod_Avvo_Conversica_Process() {
          Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        
         Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Unclaimed Leads').getRecordTypeId();
        
        Lead newLead = new Lead() ;
        newLead.FirstName = 'Cole';
        newLead.LastName = 'Swain';
        newLead.Company = 'BlueWave';
        newLead.Status = 'contacted';
        newLead.Active_AI_Campaign__c = true;
        newLead.Avvo_AI_Sales_Assistant__c = 'Blaire Carson (Acquisition)';
        newLead.RecordTypeId = LeadRecordTypeId;
        newLead.City = 'New York'; //Added for coverage
        insert newLead;
        
        Campaign camp = new Campaign();
        camp.Name = 'Avvo - Conversica Hot Lead';
       // insert camp;
        
        newLead.Avvo_AI_Sales_Assistant_Hot_Lead__c = true;
        newLead.Avvo_AI_Sales_Assistant_Hot_Lead_Date__c = System.today();
        newLead.City = 'Mount Pearl'; //Added for coverage
        update newLead;
        
    }
    
    
      static testMethod void testMethod_PardotcloneLead() {
      Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        
       Auto_Evergreen_Process__c autoEvergreen = new Auto_Evergreen_Process__c();
        autoEvergreen.Pardot_Clone_Check__c=false;
        autoEvergreen.name='Auto Evergreen';
        insert autoEvergreen;
      
         Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-H lead').getRecordTypeId();
        
        Lead newLead = new Lead() ;
        newLead.FirstName = 'Cole';
        newLead.LastName = 'Swain';
        newLead.Company = 'BlueWave';
        
        newLead.Formfill_BU_Indicator__c = 'MH';
        newLead.RecordTypeId = LeadRecordTypeId;
        insert newLead;
    String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Pardot Processing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
         
        System.runAs(u) { 
         newLead.Formfill_BU_Indicator__c = 'MN';
        update newLead;
        
    }}

}
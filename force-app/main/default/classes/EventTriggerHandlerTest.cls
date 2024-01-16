@isTest
public class EventTriggerHandlerTest {
    
    static testmethod void run2condition(){
         //creating test data
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
          // create a Lead
       Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-N Leads').getRecordTypeId();
       Lead lead=new Lead(LastName='Doe11',
                          Company='Test',
                          Status='Inquiry', 
                          RecordTypeId = LeadRecordTypeId,
                          MH_Customer_Number__c = '1568462461',
                          Postalcode = '08820'
                        //  Lead_Owner_Change_Date__c = DateTime.newInstance(date.today().year(), date.today().month(), date.today().day()-1)
                          );
       insert lead;
        
        Test.startTest();
        Event ev   = testData.createEvent(lead.id);
        ev.WhatId = NULL;
        ev.WhoId = lead.id; 
        ev.EndDateTime = system.now();
        insert ev;
        ev.subject = 'Call';
        update ev;
        Test.stopTest();
    }

}
@isTest
private class CreateLeadFromLeadTest{
     
       static testmethod void createlead(){
        
        //creating test data
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
        
        //creating account
        account a= testData.getAccount();
        contact con = testData.getContact(a.id);
        
      //  Lead l1   = testData.createlead(con.id);

            lead l = new lead();
            l.email = 'random@gmail.com';
            l.LastName             ='random';
            l.Status               = 'Open';
            l.LeadSource           = 'Lead';
            l.Company              = 'test';
            l.Contact__c           = NULL; // company name TODO
            l.Pardot_Business_Unit__c  = '';

            l.Phone                = '12312313';
            //l.RecordTypeId         ='012F0000001clqC';
            
            insert l;
            
        Test.startTest();
         CreateLeadFromLead.createLead(l.id);  
           Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
          //  insert l1;
        Test.stopTest();
     
     
       
       }
       
       }
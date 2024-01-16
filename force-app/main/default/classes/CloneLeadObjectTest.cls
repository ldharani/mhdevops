@isTest(SeeAllData=true)
private class CloneLeadObjectTest{
       Public string leadlist {get;set;}
       
       static testmethod void cloneLeadObjecttest(){
       List<lead>leadstoCreate = new List<lead>();
        
        //creating test data
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
        
        //creating account
        account a= testData.getAccount();
        contact con = testData.getContact(a.id);
        
      
        Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Lead).getRecordTypeId();
        Id noloLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MN_Lead  ).getRecordTypeId();
        Id ngageLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MNG_Lead  ).getRecordTypeId();
         
         List<String> leadlist = new List<String>();
         system.debug('@@@@@@2LeadRecordTypeId '+LeadRecordTypeId );
         Lead LeadMH1 = new Lead(LastName='Doe11',
                          Company='Test',
                          Status='open',  
                          RecordTypeId = LeadRecordTypeId,
                          MH_Customer_Number__c = '1568462461',
                          Postalcode = '08820',
                          email = 'test@salesforce.com'
                          );
                          
            Insert LeadMH1;
           
        Lead MNnewLead = new Lead(LastName='Doe11',
                          Company='Test',
                          Status='Unqualified',  
                          RecordTypeId = noloLeadRecordTypeId ,
                          MH_Customer_Number__c = '1568462461',
                          Postalcode = '08820',
                          email = 'test@salesforce.com'
                          );
                          
            Insert MNnewLead ;   
           
            System.debug('@@@@@@LeadMH1'+LeadMH1);
            
            //newLead1.Pardot_Business_Unit__c = 'Martindale-Nolo';           
             LeadMH1.Business_Unit__c = 'Martindale-NGage';
             update LeadMH1;
             String leadId1 = LeadMH1.Id;
             String M_NleadId = MNnewLead.Id; 
                             
        
        //String leadId2 = newLead2.Id; */
        
        leadlist.add(leadId1 );
        leadlist.add(M_NleadId );
        
        System.debug('@@@@list of leads'+leadlist);
    
        Test.startTest();
         CloneLeadObject.cloneLeadObject(leadlist);  
         Lead newLeadMNG =new Lead(LastName='Doe12',
                          Company='Test',
                          Status='Open',
                          RecordTypeId = ngageLeadRecordTypeId ,
                          MH_Customer_Number__c = '1568362461',
                          Postalcode = '08820',
                          ownerId = '00G0G0000071yWZ',
                          email = 'test@salesforce.com'
                          );
       Insert newLeadMNG;
             
        Test.stopTest();
     
     
       
       }
       
       static testmethod void cloneLeadObjecttest2(){
       
       MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
       List<lead>leadstoCreate = new List<lead>(); 
        //creating account
        account a= testData.getAccount();
        contact con = testData.getContact(a.id);
        
      
        Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Lead).getRecordTypeId();
        Id noloLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MN_Lead  ).getRecordTypeId();
        Id ngageLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MNG_Lead  ).getRecordTypeId();
         
         List<String> leadlist = new List<String>();
         system.debug('@@@@@@2LeadRecordTypeId '+LeadRecordTypeId );
         Lead MHnewLead = new Lead(LastName='Doe11',
                          Company='Test',
                          Status='open',  
                          RecordTypeId = LeadRecordTypeId,
                          MH_Customer_Number__c = '1568462461',
                          Postalcode = '08820',
                          email = 'test@salesforce.com'
                          );
                          
            Insert MHnewLead;
            
            Lead MNGnewLead = new Lead(LastName='Doe11',
                          Company='Test',
                          Status='open',  
                          RecordTypeId = ngageLeadRecordTypeId ,
                          MH_Customer_Number__c = '1568462461',
                          Postalcode = '08820',
                          email = 'test@salesforce.com'
                          );
                          
            Insert MNGnewLead ;
             
             MHnewLead.Business_Unit__c = 'Martindale-Nolo';
             update MHnewLead;
             String MHleadId = MHnewLead.Id; 
             String MNGLead = MNGnewLead .Id; 
             
             leadlist.add(MHleadId );
             leadlist.add(MNGLead );
             
       Test.startTest();
          
       CloneLeadObject.cloneLeadObject(leadlist);                 
       Lead Nololead =new Lead(LastName='Doe12',
                          Company='Test',
                          Status='Open',
                          RecordTypeId = noloLeadRecordTypeId ,
                          MH_Customer_Number__c = '1568362461',
                          Postalcode = '08820',
                          ownerId = '00G0G0000071yWZ',
                          email = 'test@salesforce.com'
                          );
        
        leadstoCreate.add(Nololead); 
        Insert leadstoCreate;
        Test.stopTest();
       
       }
       
       static testmethod void cloneLeadObjecttest3(){
       
       MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
       List<lead>leadstoCreate = new List<lead>(); 
        //creating account
        account a= testData.getAccount();
        contact con = testData.getContact(a.id);
        
      
        Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Lead).getRecordTypeId();
        Id noloLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MN_Lead  ).getRecordTypeId();
        Id ngageLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MNG_Lead  ).getRecordTypeId();
         
         List<String> leadlist = new List<String>();
         system.debug('@@@@@@2LeadRecordTypeId '+LeadRecordTypeId );
         Lead newLeadMH = new Lead(LastName='Doe11',
                          Company='Test',
                          Status='open',  
                          RecordTypeId = noloLeadRecordTypeId ,
                          MH_Customer_Number__c = '1568462461',
                          Postalcode = '08820',
                          email = 'test@salesforce.com'
                          );
                          
            Insert newLeadMH;
            
            Lead MNGnewLead = new Lead(LastName='Doe11',
                          Company='Test',
                          Status='open',  
                          RecordTypeId = ngageLeadRecordTypeId ,
                          MH_Customer_Number__c = '1568462461',
                          Postalcode = '08820',
                          email = 'test@salesforce.com'
                          );
                          
            Insert MNGnewLead ;
             
             newLeadMH.Business_Unit__c = 'Martindale-Hubbell';
             update newLeadMH;
             String leadIdMH = newLeadMH.Id; 
             String leadIdMng = MNGnewLead .Id; 
             
             leadlist.add(leadIdMH );
             leadlist.add(leadIdMng );
             
       Test.startTest();
          
       CloneLeadObject.cloneLeadObject(leadlist);                 
       Lead MHlead =new Lead(LastName='Doe12',
                          Company='Test',
                          Status='Open',
                          RecordTypeId = LeadRecordTypeId,
                          MH_Customer_Number__c = '1568362461',
                          Postalcode = '08820',
                          ownerId = '00G0G0000071yWZ',
                          email = 'test@salesforce.com'
                          );
                          
        leadstoCreate.add(MHlead ); 
        Insert leadstoCreate;
        Test.stopTest();
       
       }
       
        static testmethod void cloneLeadObjecttest4(){
       
       MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
       List<lead>leadstoCreate = new List<lead>(); 
        //creating account
        account a= testData.getAccount();
        contact con = testData.getContact(a.id);
        
      
        Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Lead).getRecordTypeId();
        Id noloLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MN_Lead  ).getRecordTypeId();
         
         List<String> leadlist = new List<String>();
         system.debug('@@@@@@2LeadRecordTypeId '+LeadRecordTypeId );
         Lead newLeadMH = new Lead(LastName='Doe11',
                          Company='Test',
                          Status='Closed - Not Converted',  
                          RecordTypeId = LeadRecordTypeId,
                          MH_Customer_Number__c = '1568462461',
                          Postalcode = '08820',
                          email = 'test@salesforce.com'
                          );
                          
            Insert newLeadMH;
             
            newLeadMH.Business_Unit__c = 'Martindale-Hubbell';
            update newLeadMH;
             String leadIdMH = newLeadMH.Id; 
             
             leadlist.add(leadIdMH );
             
       Test.startTest();
          
       CloneLeadObject.cloneLeadObject(leadlist);                 
       Lead MHlead =new Lead(LastName='Doe12',
                          Company='Test',
                          Status='Open',
                          RecordTypeId = LeadRecordTypeId,
                          MH_Customer_Number__c = '1568362461',
                          Postalcode = '08820',
                          ownerId = '00G0G0000071yWZ',
                          email = 'test@salesforce.com'
                          );
        leadstoCreate.add(MHlead ); 
        Insert leadstoCreate;
        Test.stopTest();
       
       }
       
        static testmethod void cloneLeadObjecttest5(){
       
       MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
       List<lead>leadstoCreate = new List<lead>(); 
        //creating account
        account a= testData.getAccount();
        contact con = testData.getContact(a.id);
        
      
        Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Lead).getRecordTypeId();
        Id noloLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MN_Lead  ).getRecordTypeId();
         
         List<String> leadlist = new List<String>();
        
         Lead MHnewLead = new Lead(LastName='Doe11',
                          Company='Test',
                          Status='Unqualified',  
                          RecordTypeId = noloLeadRecordTypeId ,
                          MH_Customer_Number__c = '1568462461',
                          Postalcode = '08820',
                          email = 'test@salesforce.com'
                          );
                          
            Insert MHnewLead;
             
             MHnewLead.Business_Unit__c  = 'Martindale-Nolo';
             update MHnewLead;
             String MHleadId = MHnewLead.Id; 
             
             leadlist.add(MHleadId );
             
       Test.startTest();
          
       CloneLeadObject.cloneLeadObject(leadlist);                 
       Lead Nololead =new Lead(LastName='Doe12',
                          Company='Test',
                          Status='Open',
                          RecordTypeId = noloLeadRecordTypeId ,
                          MH_Customer_Number__c = '1568362461',
                          Postalcode = '08820',
                          ownerId = '00G0G0000071yWZ',
                          email = 'test@salesforce.com'
                          );
        leadstoCreate.add(Nololead ); 
        Insert leadstoCreate;
        Test.stopTest();
       
       }
       
        static testmethod void cloneLeadObjecttest6(){
       
       MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
        List<lead>leadstoCreate = new List<lead>();
        //creating account
        account a= testData.getAccount();
        contact con = testData.getContact(a.id);
        
      
        Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Lead).getRecordTypeId();
        Id ngageLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MNG_Lead  ).getRecordTypeId();
        Id noloLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MN_Lead  ).getRecordTypeId();
         
         List<String> leadlist = new List<String>();
        
         Lead MHnewLead = new Lead(LastName='Doe11',
                          Company='Test',
                          Status='unqualified',  
                          RecordTypeId = ngageLeadRecordTypeId ,
                          MH_Customer_Number__c = '1568462461',
                          Postalcode = '08820',
                          email = 'test@salesforce.com'
                          );
                          
            Insert MHnewLead;
            
            
             
             MHnewLead.Business_Unit__c= 'Martindale-NGage';
             update MHnewLead;
             String MHleadId = MHnewLead.Id; 
             //
             
             leadlist.add(MHleadId );
            // leadlist.add(M_NleadId );
             
       Test.startTest();
          
       CloneLeadObject.cloneLeadObject(leadlist);                 
       Lead Nololead =new Lead(LastName='Doe12',
                          Company='Test',
                          Status='Open',
                          RecordTypeId = ngageLeadRecordTypeId ,
                          MH_Customer_Number__c = '1568362461',
                          Postalcode = '08820',
                          ownerId = '00G0G0000071yWZ',
                          email = 'test@salesforce.com'
                          );
        leadstoCreate.add(Nololead ); 
        Insert leadstoCreate;
        
        Test.stopTest();
       
       }
       }
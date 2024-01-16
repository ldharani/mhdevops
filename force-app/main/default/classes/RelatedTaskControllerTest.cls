@isTest(seeAllData=true)
public class RelatedTaskControllerTest{
    
    static testmethod void firstTaskCreatedonLeadTest(){
        
        List<Task> taskksToInsert = new List<Task>();
        //creating test data
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
        User u = testData.getUser_admin();
        
          // create a Lead
       Id IbAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
       Id mhAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();

        Account parentAcc = new Account(Name='PArent Doe11',
                          Phone='1232332',
                          Primary_Contact__c ='asdasdsadad@test.com', 
                          RecordTypeId = IbAccountRecordTypeId,
                          Organization_Type__c = 'Corporation',
                          ShippingStreet = '111 Train Ave',
                          BillingStreet = '111 Train Ave',
                          BillingState = 'NY',
                          ShippingState = 'NY',
                          ShippingPostalCode = '12356-2343',
                          BillingPostalCode = '12356-2343',
                          BillingCountry = 'USA'
                          );
       insert parentAcc;
        
        Account acc = new Account(Name='Doe11',
                          Phone='1232332',
                          Primary_Contact__c ='asdasdsadad@test.com', 
                          RecordTypeId = MhAccountRecordTypeId,
                          Organization_Type__c = 'Corporation',
                          ShippingStreet = '111 Train Ave',
                          BillingStreet = '111 Train Ave',
                          BillingState = 'NY',
                          ShippingState = 'NY',
                          ShippingPostalCode = '12356-2343',
                          BillingPostalCode = '12356-2343',
                          BillingCountry = 'USA',
                          parentId = parentAcc.Id
                          );
       insert acc;
       
       Contact con = new Contact (LastName = 'Test Contact', Email = 'test122@gmail.com', AccountId= parentAcc.Id); 
       insert con;
       
       Opportunity opp = new Opportunity(AccountId = acc.Id, Name = 'Test opp', StageName ='Prospecting',CloseDate = System.Today());
       insert opp; 
       System.debug('@@@@@Account------>'+acc);
       
       
            Test.startTest();
            ID salesTaskRectypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task Type').getRecordTypeId();
            task t1   = testData.createTask(acc.id,salesTaskRectypeId);
            t1.WhatId = acc.Id;
            taskksToInsert.add(t1);
        
            String accId = acc.Id;
            
            task t2   = testData.createTask(acc.id,salesTaskRectypeId);        
            t2.WhoId = con.Id;
            taskksToInsert.add(t2);
            
            task t3   = testData.createTask(opp.id,salesTaskRectypeId);
            t3.WhatId = opp.Id;
            taskksToInsert.add(t3);
        
            ApexPages.currentPage().getParameters().put('id', accId );
            ApexPages.StandardController sc = new ApexPages.StandardController(acc);
            RelatedTaskController contoller = new RelatedTaskController(sc);
            contoller.toggleSort();
            contoller.gotoList();
            contoller.viewAllActivity();
            contoller.Cancel();
        
            try{
                insert taskksToInsert;
                
                System.debug('@@@@@@@@Tasks inserted -------->'+taskksToInsert);
            }
            catch(Exception e){
                System.debug('@@@@Error'+e);
            }
            
            Test.stopTest();
        
        
    }
}
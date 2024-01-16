@isTest
private class Test_AccountLogic {
    
    static testmethod void testDoAfterUpdate(){
        
        Deactivate_Trigger_for_data_load__c dtc = new Deactivate_Trigger_for_data_load__c();
        dtc.Deactivate_trigger__c = false;
        dtc.name = 'Deactivate';
        insert dtc;
        
        //creating test data
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
        
        //creating account
        account acc = testData.getAccount();
    
        acc.Name = acc.Name + 'testingUpdate';
        //acc.Advertising_Status__c = 'Waitlist';
        //acc.AM_Book__c = FALSE;
        //acc.Customer_No_Book__c = FALSE;
        
        
        Test.setMock(httpcalloutMock.class, new Test_MockSendToBananaStand());  
        Test.startTest();
            update acc;
        	
        Test.stopTest(); 
        
        List<Error_Log__c> integrationQueues = [Select id From Error_log__c];
        System.assertEquals(0, integrationQueues.size());
        
         
    }
    
     static testmethod void testDoAfterUpdate_change(){
        
        Deactivate_Trigger_for_data_load__c dtc = new Deactivate_Trigger_for_data_load__c();
        dtc.Deactivate_trigger__c = false;
        dtc.name = 'Deactivate';
        insert dtc;
        
        Id RecordTypeId_avvoAttrny = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId(); 
        
        //creating test data
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
        List<Account> accList = new List<Account>();
        
        //creating account
        account acc = testData.getAccount();
        
        acc.Name = acc.Name + 'testingUpdate';
        acc.BillingStreet = 'ABC Street, Hacjettt';
        acc.RecordTypeId = RecordTypeId_avvoAttrny;
        accList.add(acc);
        
        Test.setMock(httpcalloutMock.class, new Test_MockSendToBananaStand());  
        Test.startTest();
            update accList;
         	Map<Id,Account> oldMap = new Map<Id,Account>();
            oldMap.put(acc.ID, acc);
            AccountLogic.updateAvvoAccTypeOnContact(accList,oldMap);
         	AccountLogic.avvoWinbackProcess(accList,oldMap);
            new AccountLogic().DoAfterUpdate(accList);
        Test.stopTest(); 
        
        List<Error_Log__c> integrationQueues = [Select id From Error_log__c];
        System.assertEquals(0, integrationQueues.size());
        
         
    }
    
    
    static testmethod void testOwnerSyncWithContact(){
        
        Deactivate_Trigger_for_data_load__c dtc = new Deactivate_Trigger_for_data_load__c();
        dtc.Deactivate_trigger__c = false;
        dtc.name = 'Deactivate';
        insert dtc;
        
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
        
        List<Account> accList = new List<Account>();
         
        Account acc = testData.getAccount();
        accList.add(acc);
        Contact con = testData.getContact(acc.Id);
        
        User user1 = testData.getUser();
        
        Test.startTest();
            acc.OwnerId = user1.Id;
            update acc;
            
        Test.stopTest();
    }    
    
    static testmethod void  Test_IntegrationEngine_RetryRecords_Success() {
        Error_log__c queue = createIntegrationQueues(1,
                'Banana Stand', 'Error')[0];
        queue.Number_Of_Attempts__c = 1;
        insert queue;

        Test.setMock(HttpCalloutMock.class, new Test_MockSendToBananaStand());
        Test.startTest();
            new IntegrationEngine_RetryRecords(true,5).execute(null);
        Test.stopTest();

        List<Error_Log__c> integrationQueues = [SELECT Id
                                                        FROM Error_Log__c];

        // Integration Queue should delete without error
        system.assertEquals(0, integrationQueues.size());
    }
    
    static testmethod void Test_IntegrationEngine_RetryRecords_OverLimit() {
        Integration_Settings__c settings = Integration_Settings__c.getInstance();

        Error_log__c queue = createIntegrationQueues(1,
                'Banana Stand', 'Error')[0];
        queue.Number_Of_Attempts__c = settings.Max_Retries_Banana_Stand__c;
        insert queue;

        Test.setMock(HttpCalloutMock.class, new Test_MockSendToBananaStand());
        Test.startTest();
            new IntegrationEngine_RetryRecords(False,5).execute(null);
        Test.stopTest();

        List<Error_Log__c> integrationQueues = [SELECT Id, Number_Of_Attempts__c
                                                        FROM Error_Log__c];

        // Integration Queue should not delete or update
        system.assertEquals(1, integrationQueues.size());
        system.assertEquals(settings.Max_Retries_Banana_Stand__c, integrationQueues[0].Number_Of_Attempts__c);
        
        AccountLogic acctlogic = new AccountLogic (); 
            acctlogic.FkMethod();
    }
    
    static testmethod void Test_IntegrationEngine_RetryRecords_FullRetry_NoRecords() {
        Test.startTest();
            IntegrationEngine_RetryRecords.scheduleBatchJob(true);
        Test.stopTest();

        // Nothing to Assert
    }
    
    /*static testmethod void Test_IntegrationEngine_RetryRecords_NOFullRetry_NoRecords() {
   
        Deactivate_Trigger_for_data_load__c dtc = new Deactivate_Trigger_for_data_load__c();
        dtc.Deactivate_trigger__c = false;
        dtc.name = 'Deactivate';
        insert dtc;
        
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
        Account acc = testData.getAccount();
        Contact con = testData.getContact(acc.Id);
        
        Integration_Settings__c settings = Integration_Settings__c.getInstance();
        
        Error_log__c queue = createIntegrationQueues(1,
                'Banana Stand', 'Error')[0];
        queue.Number_Of_Attempts__c = settings.Max_Retries_Banana_Stand__c;
        queue.Date_Time_Submitted__c = System.now().addMinutes(-6);
        queue.Account_Name__c = acc.id;
        queue.Contact__c = con.id;
        queue.Professional_Id__c = '12121';
        queue.Find_Task_Play__c = True;
        queue.Number_of_Attempts__c = 1;
        insert queue;
        System.debug('@@@@@Integration Queue inserted------------->'+queue);
        Test.startTest();
            
            IntegrationEngine_RetryRecords.scheduleBatchJob(false);
        Test.stopTest();

    }*/
    
    static testmethod void accntContRelationshipInsert() {
        
        Deactivate_Trigger_for_data_load__c dtc = new Deactivate_Trigger_for_data_load__c();
        dtc.Deactivate_trigger__c = false;
        dtc.name = 'Deactivate';
        insert dtc;
        
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
        
        List<Account> accList = new List<Account>();
        //Map<Id,Account> oldMap = new Map<Id,Account>();
        
        //AccountLogic.avvoWinbackProcess(accList, oldMap);
        
        
        Account acc = testData.getAccount();
        
        Contact con = testData.getContact(acc.Id);
        
        Account_Contact_Relation__c accConRel = new Account_Contact_Relation__c();
        accConRel.Account__c = acc.id;
        accConRel.contact__c = con.id;
        accConRel.Roles__c = 'Lead/Paying Attorney';
        
        AccountLogic acctlogic = new AccountLogic (); 
            acctlogic.FkMethod();
            
        Test.startTest();
            insert accConRel;
        Test.stopTest();
        
        
    }
    
    static testmethod void accntContRelationshipDelete() {
        
        profile p = [SELECT Id FROM Profile where name= 'System Administrator' LIMIT 1];
        
        //creating a user with pc profile
         User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newuserss@test.com');
         insert u2;
        
        
        Deactivate_Trigger_for_data_load__c dtc = new Deactivate_Trigger_for_data_load__c();
        dtc.Deactivate_trigger__c = false;
        dtc.name = 'Deactivate';
        insert dtc;
        
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
        
        List<Account> accList = new List<Account>();
         
        Account acc = testData.getAccount();
        
        Contact con = testData.getContact(acc.Id);
        
        List<Account_Contact_Relation__c > accConRelList = new List<Account_Contact_Relation__c>();
        Account_Contact_Relation__c accConRel = new Account_Contact_Relation__c();
        accConRel.Account__c = acc.id;
        accConRel.contact__c = con.id;
        accConRel.Roles__c = 'Lead/Paying Attorney';
        accConRelList.add(accConRel);
        
        Account_Contact_Relation__c accConRel2 = new Account_Contact_Relation__c();
        accConRel2.Account__c = acc.id;
        accConRel2.contact__c = con.id;
        accConRel2.Roles__c = 'Lead/Paying Attorney';
        accConRelList.add(accConRel2);
        
        insert accConRelList;
        
        
        Test.startTest();
            system.runAs(u2){
                delete accConRelList;
            }
            
            
        
        
        Test.stopTest();
    }
    
    @isTest
    private static void Test_IntegrationEngine_InvalidIntegration() {
        Error_Log__c queue = createIntegrationQueues(1, 'Banana Stand', 'New')[0];
        insert queue;
        
        Integration_Settings__c integSet = new Integration_Settings__c();
        integSet.Account_Contact_Relation_Account_Id__c = '12131dsadsadsa';
        integSet.Account_Contact_Relation_Contact_Id__c = 'asdadasdda324232';
        integSet.Account_Contact_Relation_Prefix__c = 'asd';
        insert integSet;
        
        AccountLogic acctlogic = new AccountLogic (); 
            acctlogic.FkMethod();
            
        Test.startTest();
            IntegrationEngine_BatchProcessRecords.ScheduleBatchJob();
        Test.stopTest();

    }
    
    
    static testmethod void accntContRelationshipDeleteError() {
        
        profile p = [SELECT Id FROM Profile where name!= 'System Administrator' LIMIT 1];
        
        //creating a user with pc profile
         User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newusers12s@test.com');
         insert u2;
        
        
        Deactivate_Trigger_for_data_load__c dtc = new Deactivate_Trigger_for_data_load__c();
        dtc.Deactivate_trigger__c = false;
        dtc.name = 'Deactivate';
        insert dtc;
        
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
        
        List<Account> accList = new List<Account>();
         
        Account acc = testData.getAccount();
        
        Contact con = testData.getContact(acc.Id);
        
        List<Account_Contact_Relation__c > accConRelList = new List<Account_Contact_Relation__c>();
        Account_Contact_Relation__c accConRel = new Account_Contact_Relation__c();
        accConRel.Account__c = acc.id;
        accConRel.contact__c = con.id;
        accConRel.Roles__c = 'Lead/Paying Attorney';
        accConRelList.add(accConRel);
        
        Account_Contact_Relation__c accConRel2 = new Account_Contact_Relation__c();
        accConRel2.Account__c = acc.id;
        accConRel2.contact__c = con.id;
        accConRel2.Roles__c = 'Lead/Paying Attorney';
        accConRelList.add(accConRel2);
        
        insert accConRelList;
        
        AccountLogic acctlogic = new AccountLogic (); 
            acctlogic.FkMethod();
            
        try{
            Test.startTest();
                system.runAs(u2){
                    delete accConRelList;
                }
            Test.stopTest();
        }
            catch(Exception e)

            {

                Boolean expectedExceptionThrown =  e.getMessage().contains('You do not have permissions to remove the Account contact relationship') ? true : false;
                
               // System.AssertEquals(expectedExceptionThrown, true);
                
            } 
      }
    
    public static List<Error_Log__c> CreateIntegrationQueues(integer numQueues, string integration, string status) {
        List<Error_Log__c> queues = new List<Error_Log__c>();

        for (integer i = 0; i < numQueues; i++) {
            queues.add(new Error_Log__c(
                    Integration__c = integration,Order_Name__c= 'Test',Error_Reason__c = 'Banana Stand',
                    Status__c = status,
                    Number_of_Attempts__c = 0
            ));
        }

        return queues;
    }
    
    /*static testmethod void avvoWinbackProcess(){
        
        Deactivate_Trigger_for_data_load__c dtc = new Deactivate_Trigger_for_data_load__c();
        dtc.Deactivate_trigger__c = false;
        dtc.name = 'Deactivate';
        insert dtc;
        
        profile p = [SELECT Id FROM Profile where name!= 'System Administrator' LIMIT 1];
        profile p2 = [SELECT Id FROM Profile where name= 'System Integration' LIMIT 1];
        Id avvoRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        
        //creating a user with pc profile
         User u = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newusers12s@test.com');
         insert u;
        
         User u2 = new User(Alias = 'newUserIntegration', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Integration Test', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p2.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newusers12s@test.com');
         insert u2;
        
        //creating test data
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
        
        //creating account
        List<Account> accList = new List<Account>();
        Map<Id,Account> oldMap = new Map<Id,Account>();
        //account acc = testData.getAccount();
        Account a = new Account();
        a.Name = 'testAccAvvoWB'; 
        a.Phone='122-34345-654';
        a.RecordTypeId = avvoRecordTypeId;
        a.OwnerId = u.Id;
        a.Win_back__c = TRUE;
        a.Advertising_Status__c = 'Cancelled';
        a.AM_Book__c = FALSE;
        a.Assigned_to_an_AM__c = datetime.newInstance(2019,2,10,10,0,0);
        a.Full_Cancel_Count__c = 1;
        a.MRR_Baseline__c = 1;
        accList.add(a);
        Insert accList;
        oldMap.put(a.Id, a);

        List<Contact> conList = new List<Contact>();
        contact con = new contact ();
        con.LastName = 'testavvo';
        con.Email = 'test.avvo@gmail.com';
        con.Related_To_Account__c = a.Id;
        conList.add(con);
        insert conList;
        
        con.Onboarding_Completed__c = TRUE;
        con.Email_Suppression_Reason__c = 'Wrong Email';
        con.Scheduled_By__c = u.Id;
        con.Last_Activity_AM_CRM__c = date.today();
        con.Last_AM_Connected_Call__c = date.today();
        con.Last_AM_Email_sent__c = date.today();
        con.Last_AM_Left_Message__c = date.today();
        update conList;
        
        Test.startTest();
        a.Win_back__c = False;
        a.OwnerId = u2.Id;
        update accList;
        
        Test.stopTest();
    }*/
}
@isTest
public class RulesOfEngagementBatchTest {
    
    static testmethod void run2condition(){
        
         //creating test data
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
        
        //creating accounts
        String accIBrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        Id mhAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        Id noloaccRecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('M-N Account').getRecordTypeId();
        Id ngageaccRecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId();
        
        List<account> acclist = new list<account>();
        
         //creating parent account
        Account ac      = new account();
        ac.Name         = 'test IB';
        aC.Phone='122-34345-654';
        aC.ParentId    = null;
        aC.Credit_Status__c = '';
        aC.MH_Cust_Number__c    = '1243242233';
        aC.Sub_Type__c = 'Elite';
        aC.Acquisition_date__c = date.today();
        aC.Re_acquisition_date__c  = date.today();
        aC.RecordTypeId = accIBrectypeId;
        insert ac;
        
        Contact con = new Contact (LastName = 'Test Contact', Email = 'test122@gmail.com', AccountId= ac.Id ); 
        Contact con2 = new Contact (LastName = 'Test Contact2', Email = 'test12233@gmail.com', AccountId= ac.Id ); 
        Contact con3 = new Contact (LastName = 'Test Contact3', Email = 'test124442@gmail.com', AccountId= ac.Id ); 
        
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        contactList.add(con2); 
        contactList.add(con3);
        insert contactList;
        
        account a = new account();
        a.Name = 'testAcc'; 
        a.Phone='122-34345-654';
        a.ParentId    = ac.id;
        a.Credit_Status__c = 'Bad Debt';
        a.MH_Cust_Number__c    = '12432433';
        a.Sub_Type__c = 'Elite';
        a.Acquisition_date__c = date.today()-150;
        a.Re_acquisition_date__c  = date.today();
        a.RecordTypeId = MhAccountRecordTypeId;
        a.Least_Service_End_Date__c = Date.Today();
        
        account a1 = new account();
        a1.Name = 'testAcc'; 
        a1.ParentId    = ac.id;
        a1.Phone='122-34345-654';
        a1.Credit_Status__c = 'Bad Debt';
        a1.Sub_Type__c = 'Elite';
        a1.Acquisition_date__c = date.today();
        a.Re_acquisition_date__c  = NULL;
        a1.RecordTypeId = noloaccRecordTypeId;
       
        account a2 = new account();
        a2.Name = 'NgageAcc1';
        a2.ParentId    = ac.id;
        a2.Least_Service_End_Date__c= date.today();
        a2.Sub_Type__c = 'Elite';
        a2.Acquisition_date__c = NULL;
        a2.Re_acquisition_date__c  = date.today();
        a2.RecordTypeId = ngageaccRecordTypeId;
        
        
        acclist.add(a);
        acclist.add(a1);  
        acclist.add(a2);  
        
        insert acclist;
        System.debug('@@@@@@@@@@Accounts List to be inserted--------------->'+acclist);
        
        
        
        //creating task
        ID salesTaskRectypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task Type').getRecordTypeId();
        ID ngageTaskRectypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('M-NG Sales Task').getRecordTypeId();
        ID nolosalesTaskRectypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('MN Sales Task Type').getRecordTypeId();
        
        List<Task> tasList = new List<Task>();
        
        task t1   = testData.createTask(a.id,salesTaskRectypeId);
        t1.WhoId = con2.id;
        tasList.add(t1);
        
        task t2   = testData.createTask(a.id,ngageTaskRectypeId );
        t2.WhoId = con2.id;
        tasList.add(t2);
        
        task t3   = testData.createTask(a.id,nolosalesTaskRectypeId );
        t3.WhoId = con2.id;
        tasList.add(t3);
        
        insert tasList;
        
        con2.Last_MH_Sales_Activity_Date__c = Date.Today();
        con2.Last_Nolo_Sales_Activity_Date__c = Date.Today();
        con2.Last_Ngage_Sales_Activity_Date__c = Date.Today();
        update con2;
                
        
        
        test.startTest();
        database.executeBatch(new RulesOfEngagementBatch());
        
        con.ROE_Update_Date__c= System.now();
        con.Is_under_ROE__c = True;
        update con;
        
        test.stopTest();
        
        
        
    }
    
    static testmethod void run3condition(){
        
         //creating test data
        MDL_UtilClass_TestClass testData  = new MDL_UtilClass_TestClass();
        
        //creating accounts
        String accIBrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        Id mhAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        Id noloaccRecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('M-N Account').getRecordTypeId();
        Id ngageaccRecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId();
        Id avvoAccRecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
 		Id avvoFirmAccRecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId();       
        List<account> acclist = new list<account>();
        
         //creating parent account
        Account ac      = new account();
        ac.Name         = 'test IB';
        aC.Phone='122-34345-654';
        aC.ParentId    = null;
        aC.Credit_Status__c = '';
        aC.MH_Cust_Number__c    = '1243242233';
        aC.Sub_Type__c = 'Elite';
        aC.Acquisition_date__c = date.today();
        aC.Re_acquisition_date__c  = date.today();
        aC.RecordTypeId = accIBrectypeId;
        insert ac;
        
        Account firmac      = new account();
        firmac.Name         = 'Avvo Firm Account';
        firmac.Phone		='122-34345-654';
        firmac.ParentId    = ac.Id;
        firmac.Credit_Status__c = '';
        firmac.MH_Cust_Number__c    = '123242233';
        firmac.Sub_Type__c = 'Elite';
        firmac.Acquisition_date__c = date.today();
        firmac.Re_acquisition_date__c  = date.today();
        firmac.RecordTypeId = avvoFirmAccRecordTypeId;
        insert firmac;
        
        Contact con = new Contact (LastName = 'Test Contact', Email = 'test122@gmail.com', AccountId= ac.Id ); 
        Contact con2 = new Contact (LastName = 'Test Contact2', Email = 'test12233@gmail.com', AccountId= ac.Id ); 
        Contact con3 = new Contact (LastName = 'Test Contact3', Email = 'test124442@gmail.com', AccountId= ac.Id ); 
        
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        contactList.add(con2); 
        contactList.add(con3);
        insert contactList;
        
        account a = new account();
        a.Name = 'testAcc'; 
        a.Phone='122-34345-654';
        a.ParentId    = ac.id;
        a.Credit_Status__c = 'Bad Debt';
        a.MH_Cust_Number__c    = '12432433';
        a.Sub_Type__c = 'Elite';
        a.Acquisition_date__c = date.today();
        a.Re_acquisition_date__c  = date.today()-150;
        a.RecordTypeId = MhAccountRecordTypeId;
        a.Least_Service_End_Date__c = Date.Today();
        
        account a1 = new account();
        a1.Name = 'testAcc'; 
        a1.ParentId    = ac.id;
        a1.Phone='122-34345-654';
        a1.Credit_Status__c = 'Bad Debt';
        a1.Sub_Type__c = 'Elite';
        a1.Acquisition_date__c = NULL;
        a.Re_acquisition_date__c  = Date.Today();
        a1.RecordTypeId = noloaccRecordTypeId;
       
        account a2 = new account();
        a2.Name = 'NgageAcc1';
        a2.ParentId    = ac.id;
        a2.Least_Service_End_Date__c= date.today();
        a2.Sub_Type__c = 'Elite';
        a2.Acquisition_date__c = Date.Today();
        a2.Re_acquisition_date__c  = NULL;
        a2.RecordTypeId = ngageaccRecordTypeId;
        
		account a3 = new account();
        a3.Name = 'Avvo Account';
        a3.ParentId    = firmac.id;
        a3.Sub_Type__c = 'Elite';
        a3.Failed_CC_Amount_Owed__c = 2;
        a3.MAX_Opportunity_Date_non_AM__c = Date.Today();
        a3.RecordTypeId = avvoAccRecordTypeId;		
        
        acclist.add(a);
        acclist.add(a1);  
        acclist.add(a2); 
        acclist.add(a3);
        
        insert acclist;
        System.debug('@@@@@@@@@@Accounts List to be inserted--------------->'+acclist);
        
        
        
        //creating task
        ID salesTaskRectypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task Type').getRecordTypeId();
        ID ngageTaskRectypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('M-NG Sales Task').getRecordTypeId();
        ID nolosalesTaskRectypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('MN Sales Task Type').getRecordTypeId();
        
        List<Task> tasList = new List<Task>();
        
        task t1   = testData.createTask(a.id,salesTaskRectypeId);
        t1.WhoId = con2.id;
        tasList.add(t1);
        
        task t2   = testData.createTask(a.id,ngageTaskRectypeId );
        t2.WhoId = con2.id;
        tasList.add(t2);
        
        task t3   = testData.createTask(a.id,nolosalesTaskRectypeId );
        t3.WhoId = con2.id;
        tasList.add(t3);
        
        insert tasList;
        
        con2.Last_MH_Sales_Activity_Date__c = Date.Today()-90;
        con2.Last_Nolo_Sales_Activity_Date__c = Date.Today()-40;
        con2.Last_Ngage_Sales_Activity_Date__c = Date.Today();
        update con2;
                
        
        
        test.startTest();
        database.executeBatch(new RulesOfEngagementBatch());
        
        con.ROE_Update_Date__c= System.now();
        con.Is_under_ROE__c = True;
        update con;
        
        test.stopTest();
        
        
        
    }
    
}
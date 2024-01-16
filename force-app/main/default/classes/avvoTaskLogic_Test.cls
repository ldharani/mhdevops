@isTest
public class avvoTaskLogic_Test {
    static testmethod void avvoTaskFieldUpdates(){
        Deactivate_Trigger_for_data_load__c customSetting = new Deactivate_Trigger_for_data_load__c(Name='Deactivate1',Deactivate_trigger__c=false);
        insert customSetting;
        
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account acc = testData.getAccount();
        acc.AM_Book__c = true;
        update acc;
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.FirstName = 'avvo';
        con.Related_To_Account__c = acc.Id;
        insert con;
        
        //UserRole objUserRole = [SELECT Id FROM UserRole WHERE Name='Avvo Premier Acct Mgr'];
        UserRole objUserRole = [SELECT Id FROM UserRole WHERE Name='Avvo Senior Acct Mgr'];
        UserRole objUserRoleAE = [SELECT Id FROM UserRole WHERE Name='Avvo Acct Exec'];
        Profile objProfile = [SELECT Id FROM Profile WHERE Name='Avvo Account Manager'];
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
            User actMgrUser = new User();
            actMgrUser.Username = 'testActMgr@avvo.com';
            actMgrUser.Alias = 'tActMgr';
            actMgrUser.Email = 'testActMgr@testorg.com';
            actMgrUser.LastName = 'avvoTestActMgr';
            actMgrUser.ProfileId = objProfile.Id;
            actMgrUser.UserRoleId = objUserRole.Id;
            actMgrUser.LanguageLocaleKey= 'en_US';
            actMgrUser.LocaleSidKey = 'en_US';
            actMgrUser.TimeZoneSidKey = 'America/Los_Angeles';
            actMgrUser.EmailEncodingKey='UTF-8';
            insert actMgrUser;
        
            Avvo_Task_Rollup_Settings__c tskSettings = new Avvo_Task_Rollup_Settings__c();
            tskSettings.LastActivityAMCRMRoleId__c = objUserRole.Id;
            tskSettings.LastAMConnectedCallRoleId__c  = objUserRole.Id;
            tskSettings.LastAMEmailSentRoleId__c  = objUserRole.Id;
            tskSettings.LastAMLeftMessageRoleId__c  = objUserRole.Id;
            tskSettings.AELastActivityCompletedRoleId__c = objUserRoleAE.Id;
            tskSettings.LastActivityAERoleId__c = objUserRoleAE.Id;     
            tskSettings.LastAMConnectedCallSubject__c = 'Incoming';
            tskSettings.LastAMEmailSentSubject__c  = 'Email';
            tskSettings.LastAMLeftMessageSubject__c  = 'Left Message';
            insert tskSettings;
            
            Id avvoAcctMgrRecTypId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Avvo Acct Mgr Task').getRecordTypeId();
            //Id avvoAcctExecRecTypId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Avvo Acct Mgr Task').getRecordTypeId();
            //connectedcall task
            Task avvoTsk = new Task();
            avvoTsk.WhoId = con.Id;
            avvoTsk.ActivityDate = Date.today();
            avvoTsk.OwnerId = actMgrUser.Id;
            avvoTsk.Status = 'Completed';
            avvoTsk.Subject = 'Incoming';
            avvoTsk.RecordTypeID = avvoAcctMgrRecTypId;
            insert avvoTsk;
            
            con.Last_Activity_AM_CRM__c = avvoTsk.ActivityDate;
            con.Last_AM_Connected_Call__c = avvoTsk.ActivityDate;
            update con;
            //email task
            Task avvoTsk2 = new Task();
            avvoTsk2.WhoId = con.Id;
            avvoTsk2.ActivityDate = Date.today();
            avvoTsk2.OwnerId = actMgrUser.Id;
            avvoTsk2.Status = 'Completed';
            avvoTsk2.Subject = 'Email';
            avvoTsk2.RecordTypeID = avvoAcctMgrRecTypId;
            insert avvoTsk2;
            
            con.Last_Activity_AM_CRM__c = avvoTsk2.ActivityDate;
            con.Last_AM_Email_sent__c = avvoTsk.ActivityDate;
            update con;
            //leftmessage task
            Task avvoTsk3 = new Task();
            avvoTsk3.WhoId = con.Id;
            avvoTsk3.ActivityDate = Date.today();
            avvoTsk3.OwnerId = actMgrUser.Id;
            avvoTsk3.Status = 'Completed';
            avvoTsk3.Subject = 'Left Message';
            avvoTsk3.RecordTypeID = avvoAcctMgrRecTypId;
            insert avvoTsk3;
            
            con.Last_Activity_AM_CRM__c = avvoTsk2.ActivityDate;
            con.Last_AM_Left_Message__c = avvoTsk.ActivityDate;
            update con;
        }
    }
}
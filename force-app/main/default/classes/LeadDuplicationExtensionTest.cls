@isTest()
public class LeadDuplicationExtensionTest {
    
    static testmethod void testMHLeadDuplication(){
    
        String accIBrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        String accJVrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('JV Account').getRecordTypeId();
        String accMNrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-N Account').getRecordTypeId();
        
        MDL_UtilClass_TestClass utilClass = new MDL_UtilClass_TestClass();
        
        //creating parent account
        Account acc      = new account();
        acc.Name         = 'test IB'; 
        acc.RecordTypeId = accIBrectypeId;
        insert acc;
        
        //creating contact
        contact con = utilClass.getContact(acc.Id);   
        
        Account acc1     = new account();
        acc1.Name        = 'test JV';
        acc1.ParentId    = acc.id;
        acc1.RecordTypeId = accJVrectypeId;
        insert acc1;
        
        Account acc2     = new account();
        acc2.Name        = 'test MN';
        acc2.ParentId    = acc.id;
        acc2.RecordTypeId = accMNrectypeId;
        insert acc2;
        
        //creating lead
        String jvLeadRectypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-H lead').getRecordTypeId();
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',
                        Email = 'testabc@gmail.com',
                        RecordTypeId = jvLeadRectypeId,
                        LeadSource = 'Web',  
                        Status = 'Qualified');
        
        Insert newLead;
        
        
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(newLead);
        LeadDuplicationExtension leadController = new LeadDuplicationExtension(stdController);
        
        ApexPages.currentPage().getParameters().put('parentAccId', acc.id);
        ApexPages.currentPage().getParameters().put('contId', con.id);
        
        leadController.getSelected();
        leadController.customleadConversion();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        
        
    }
    
    static testmethod void testMNLeadDuplicationexist(){
        
        String accIBrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        String accJVrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('JV Account').getRecordTypeId();
        String accMNrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-N Account').getRecordTypeId();
        
        MDL_UtilClass_TestClass utilClass = new MDL_UtilClass_TestClass();
        
        //creating parent account
        Account acc      = new account();
        acc.Name         = 'test IB';
        acc.RecordTypeId = accIBrectypeId;
        insert acc;
        
        //creating contact
        contact con = utilClass.getContact(acc.Id);   
        
        Account acc1     = new account();
        acc1.Name        = 'test JV';
        acc1.ParentId    = acc.id;
        acc1.RecordTypeId = accJVrectypeId;
        insert acc1;
        
        Account acc2     = new account();
        acc2.Name        = 'test MN';
        acc2.ParentId    = acc.id;
        acc2.RecordTypeId = accMNrectypeId;
        insert acc2;
        
        //creating lead
        String MNLeadRectypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-N Leads').getRecordTypeId();
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',
                        Email = 'testabc@gmail.com',
                        RecordTypeId = MNLeadRectypeId,
                        LeadSource = 'Web',  
                        Status = 'Qualified');
        
        Insert newLead;
        
        
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(newLead);
        LeadDuplicationExtension leadController = new LeadDuplicationExtension(stdController);
        
        ApexPages.currentPage().getParameters().put('parentAccId', acc.id);
        ApexPages.currentPage().getParameters().put('contId', con.id);
        
        leadController.getSelected();
        leadController.customleadConversion();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        

        
        
    }
    
    static testmethod void testMNLeadDuplicationwithoutexist(){
        
        String accIBrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        String accJVrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('JV Account').getRecordTypeId();
       
        
        MDL_UtilClass_TestClass utilClass = new MDL_UtilClass_TestClass();
        
        //creating parent account
        Account acc      = new account();
        acc.Name         = 'test IB';
        acc.RecordTypeId = accIBrectypeId;
        insert acc;
        
        //creating contact
        contact con = utilClass.getContact(acc.Id);   
        
        Account acc1     = new account();
        acc1.Name        = 'test JV';
        acc1.ParentId    = acc.id;
        acc1.RecordTypeId = accJVrectypeId;
        insert acc1;
        
       
        
        //creating lead
        String MNLeadRectypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-N Leads').getRecordTypeId();
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',
                        Email = 'testabc@gmail.com',
                        RecordTypeId = MNLeadRectypeId,
                        LeadSource = 'Web',  
                        Status = 'Qualified');
        
        Insert newLead;
        
        
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(newLead);
        LeadDuplicationExtension leadController = new LeadDuplicationExtension(stdController);
        
        ApexPages.currentPage().getParameters().put('parentAccId', acc.id);
        ApexPages.currentPage().getParameters().put('contId', con.id);
        
        leadController.getSelected();
        leadController.customleadConversion();
        leadController.redirectToStandardPage();
        leadController.getchatOptions();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        
        
    }
    
    static testmethod void testMNGLeadDuplicationexist(){
        
        String accIBrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        String accJVrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('JV Account').getRecordTypeId();
        String accMNrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-N Account').getRecordTypeId();
        
        MDL_UtilClass_TestClass utilClass = new MDL_UtilClass_TestClass();
        
        //creating parent account
        Account acc      = new account();
        acc.Name         = 'test IB';
        acc.RecordTypeId = accIBrectypeId;
        insert acc;
        
        //creating contact
        contact con = utilClass.getContact(acc.Id);   
        
        Account acc1     = new account();
        acc1.Name        = 'test JV';
        acc1.ParentId    = acc.id;
        acc1.RecordTypeId = accJVrectypeId;
        insert acc1;
        
        Account acc2     = new account();
        acc2.Name        = 'test MN';
        acc2.ParentId    = acc.id;
        acc2.RecordTypeId = accMNrectypeId;
        insert acc2;
        
        //creating lead
        String MNLeadRectypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-NG Leads').getRecordTypeId();
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',
                        Email = 'testabc@gmail.com',
                        RecordTypeId = MNLeadRectypeId,
                        LeadSource = 'Web',  
                        Status = 'Qualified');
        
        Insert newLead;
        
        
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(newLead);
        LeadDuplicationExtension leadController = new LeadDuplicationExtension(stdController);
        
        ApexPages.currentPage().getParameters().put('parentAccId', acc.id);
        ApexPages.currentPage().getParameters().put('contId', con.id);
        
        leadController.getSelected();
        leadController.customleadConversion();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());

        
        
    }
    
    static testmethod void testAvvoLeadDuplicationexist(){
       
        
        String accIBrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        //String accJVrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('JV Account').getRecordTypeId();
        String accAvvorectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        
        MDL_UtilClass_TestClass utilClass = new MDL_UtilClass_TestClass();
    
        
        profile p = [SELECT Id FROM Profile WHERE Name='Avvo Sales Enablement'];  
        
        user u1 =  new User(Alias = 'newUser', Email='newuser@testorg.com', CompanyName= 'Avvo',
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newuser'+utilclass.randomise()+'@testorg.com');
        
        
         system.runAs(u1){
        //creating parent account
        Account acc      = new account();
        acc.Name         = 'test IB';
        acc.RecordTypeId = accIBrectypeId;
        insert acc;
        
        //creating contact
        contact con = utilClass.getContact(acc.Id);  
        
        Account acc1     = new account();
        acc1.Name        = 'test Avvo';
        acc1.ParentId    = acc.id;
        acc1.RecordTypeId = accAvvorectypeId ;
        insert acc1;
        
        //creating lead
        String MALeadRectypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Claimed Leads').getRecordTypeId();
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',FirstName = 'First',MiddleName = 'Middle',
                        Email = 'testabc@gmail.com',Claimed_Date__c = System.Today(),
                        RecordTypeId = MALeadRectypeId,
                        LeadSource = 'Web', Description='tetstst', 
                        Status = 'Qualified',Street = 'Test', City = 'Avenel', State = 'NJ', PostalCode = '12345',
                        Professional_Id__c = '1221675601',Avvo_com_Email__c = 'testabc@gmail.com',
                        Avvo_Rating__c = 1233, Client_Review_Rating__c = 2313,
                        Client_Reviews_All_Time__c = 2,  Client_Reviews_Calendar_Month__c=4,Guides_All_Time__c=2,
                        Guides_Calendar_Month__c=121, Headshot_URL__c='www.test.com', 
                        Last_Login_Date__c=System.Today(), Peer_Endorsements_Received_All_Time__c=22,
                        Peer_Endorsements_Received_Calendar_Mon__c=123, Phone_2__c='9802221234', Phone_3__c='9802229899',
                        Questions_Answered_All_Time__c=123123, Questions_Answered_Calendar_Month__c=8,
                        State_ID__c=12323,Last_Profile_Update__c=System.Today(),
                        Do_Not_Call_Date_Time__c=System.Today(), 
                        Phone='9089878888');
        
        Insert newLead;
        
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());

        
        ApexPages.StandardController stdController = new ApexPages.StandardController(newLead);
        LeadDuplicationExtension leadController = new LeadDuplicationExtension(stdController);
        
        ApexPages.currentPage().getParameters().put('parentAccId', acc.id);
        ApexPages.currentPage().getParameters().put('contId', con.id);
        
        leadController.getSelected();
        leadController.customleadConversion();
        
       }
      
    }

}
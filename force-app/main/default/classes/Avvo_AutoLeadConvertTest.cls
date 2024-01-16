//Sai
//This class will cover 2 classes
//1.Avvo_AutoLeadConvert,  2.avvoLeadBatchHandler


@isTest()
public class Avvo_AutoLeadConvertTest {
    
    static testmethod void newLeadconversion(){
        
        profile p = [SELECT Id FROM Profile where name= 'Avvo Sales Enablement' LIMIT 1]; 

        //creating a user with pc profile
         User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', CompanyName= 'Avvo',
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newuser'+randomise()+'@testorg.com');
         insert u2;
        
        Id maclaimrecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('M_A_Claimed_Leads').getRecordTypeId();
         Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',
                        Email = 'testmaclaim@gmail.com',
                        RecordTypeId = maclaimrecordTypeId,
                        LeadSource = 'Web',  
                        Status = 'Qualified',
                        Claimed_Date__c = Date.today() - 31,
                        Claimed_Method__c = 'Admin');
        
        system.runAs(u2){
             Insert newLead;
        }
       
        
        Test.startTest();
           Avvo_AutoLeadConvert ctrl = new Avvo_AutoLeadConvert();
           Id batchid = Database.executeBatch(ctrl,10);
        Test.stopTest();
    }
    
    
    
    static testmethod void leadduplicationTest(){
         profile p = [SELECT Id FROM Profile where name= 'Avvo Sales Enablement' LIMIT 1];
        
        //creating a user with pc profile
         User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', CompanyName= 'Avvo',
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newuser'+randomise()+'@testorg.com');
         insert u2;
        
       
       
        
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
        
         Id maclaimrecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('M_A_Claimed_Leads').getRecordTypeId();
         Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',
                        Email = 'testabc@gmail.com',
                        RecordTypeId = maclaimrecordTypeId,
                        LeadSource = 'Web',  
                        Status = 'Qualified',
                        Claimed_Date__c = Date.today() - 31,
                        Claimed_Method__c = 'Admin');
        
        system.runAs(u2){
             Insert newLead;
        }
        
         Test.startTest();
           Avvo_AutoLeadConvert ctrl = new Avvo_AutoLeadConvert();
           Id batchid = Database.executeBatch(ctrl,10);
        Test.stopTest();
        
        
    }
    
    
    
    
    
    public static String randomise(){
        String append = '';
        Integer i = 6;
        while(i > 0){
            append += string.valueOf((Integer)Math.ceil(Math.random()*10));
            i--; 
        }
        return append;
    }

}
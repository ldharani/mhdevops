@isTest
public class Test_OpportunityLogic {
    
    
    public static testMethod  void doBeforeUpdate_Test(){
        List<Opportunity> newOpportunities = new List<Opportunity>(); 
        Opportunity op1 = new Opportunity(name='Test OPP',Sales_Person_Email__c='person@test.com',StageName='open',CloseDate=date.parse('05/11/2022'));
        insert op1;
        Profile p_admin;
        p_admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User us1 = new User(Username='person@test.com',Alias='alias',TimeZoneSidKey='America/New_York',
                            LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',
            ProfileId=p_admin.ID,LanguageLocaleKey='en_US');
        us1.Email='person@test.com';
        us1.LastName='lname';
        insert us1;
       
        List<Opportunity> ownerids1 = [select OwnerId from Opportunity where id=:op1.id];
        
        User us2 = new User(Username='person3@test.com',Alias='alias',TimeZoneSidKey='America/New_York',
                            LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',
            ProfileId='00e3w000001uJaYAAU',LanguageLocaleKey='en_US');
        us2.Email='person3@test.com';us2.LastName='lname';
        insert us2;
        
        op1.name='test opp2';
        update op1;
        List<Opportunity> ownerids2 = [select OwnerId from Opportunity where id=:op1.id];
        
        
        op1.name='test opp2';
        op1.Sales_Person_Email__c='person3@test.com';
        update op1;
        List<Opportunity> ownerids3 = [select OwnerId from Opportunity where id=:op1.id];
        System.debug(ownerids1+' '+ownerids2+' '+ownerids3);
        
        System.assert((ownerids1==ownerids2) && (ownerids2!=ownerids3));
    }
    
    public static testmethod void  preventStageOrReasonChange_Test()
    {
        List<Opportunity> newOpportunities = new List<Opportunity>(); 
        Opportunity op1 = new Opportunity(name='Test OPP',Sales_Person_Email__c='person4@test.com',StageName='open',CloseDate=date.parse('05/11/2022'));
        insert op1;
        
        User us1 = new User(Username='person4@test.com',Alias='alias',TimeZoneSidKey='America/New_York',
                            LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',
            ProfileId='00e3w000001uJaYAAU',LanguageLocaleKey='en_US');
        us1.Email='person4@test.com';
        us1.LastName='lname';
        insert us1;
        
        op1.name='test opp2';
        update op1;
        
        SBQQ__Quote__c sbq = new SBQQ__Quote__c();
    }
}
/*Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHMAC-44    CK            			    Jeevan Babu     <T01>   Case creation for cancel unifying Full & Partial cancel: Removed method callout of CPQ_MilestoneHandler_AvvoOptys_Test
************************************************************************************************************************/
@isTest
public class CPQ_MilestoneHandler_AvvoOptys_Test {
    Public static testmethod void CPQ_createProjects(){
        // Load Custom settings
        DataFactory.loadCustomSettings();
        Product_code_to_Project_Mapping__c aaaa = new Product_code_to_Project_Mapping__c();
        aaaa.Name = '01502';
        aaaa.Project_Record_ID__c = 'm010G000000blSb';
        aaaa.Project_Name__c = 'Website_Redesign';
        insert aaaa;
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
        // Create Test Opportunity
        List<Opportunity> newOpportunities = new List<Opportunity>(); 
        Map<Id,Opportunity> oldOpty = new Map<Id,Opportunity>();
        Id MAOptyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Opportunity').getRecordTypeId();
        Opportunity op1 = new Opportunity(name='Test OPP14',AccountId=lstAcc[0].Id,
                                          Sales_Person_Email__c='person4@test.com',
                                          StageName='receipt',CloseDate=date.today(),
                                          Firm_Name__c = 'test',
                                          Avvo_Website_Redesign_Request__c = false,RecordTypeId=MAOptyRecTypeId
                                         );
        Insert op1;
        Subscription__c sub = new Subscription__c(name='Test OPP sub3',Account__c=lstAcc[0].Id,
                                                  Opportunity__c=op1.Id,External_Id__c='11111113-111111',
                                                  Inventory_Type__c='WebsiteInventory',Subscription_Id__c='11111112'
                                                );
        Insert sub;
        
        test.startTest();
        oldOpty.put(op1.Id, op1);
        system.debug('==1old==='+oldOpty);
        Opportunity op2 = [select id, name, Avvo_Website_Redesign_Request__c,Firm_Name__c,num_of_Active_Advanced_360_Subscriptions__c,numofActiveMartindaleBaseProfileSub__c,numofCancelledMartindaleBaseProfileSub__c,num_of_Cancelled_Advanced_360_Subs__c,
                            num_of_Active_Base_Profile_Subscriptions__c,AvvoProductCodeForProject__c,AccountId,StageName from opportunity where Id=:op1.Id];
        op2.Avvo_Website_Redesign_Request__c = TRUE;
        update op2;
        system.debug('==1op2'+op2);
        
        newOpportunities = [select id, name, Avvo_Website_Redesign_Request__c,Firm_Name__c,num_of_Active_Advanced_360_Subscriptions__c,numofActiveMartindaleBaseProfileSub__c,numofCancelledMartindaleBaseProfileSub__c,num_of_Cancelled_Advanced_360_Subs__c,
                            num_of_Active_Base_Profile_Subscriptions__c,AvvoProductCodeForProject__c,AccountId,StageName from opportunity where Id=:op1.Id];
        newOpportunities[0].Avvo_Website_Redesign_Request__c = TRUE;
        update newOpportunities;
        system.debug('==1old2==='+newOpportunities);
        //If(){
        CPQ_MilestoneHandler_AvvoOptys.CPQ_createProjectsForAvvoOptys(newOpportunities, oldOpty);
        //CPQ_MilestoneHandler_AvvoOptys.caseCreationOnInsert(newOpportunities, oldOpty);
        //}
        test.stopTest();
    }
    
}
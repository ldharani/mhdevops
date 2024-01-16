@isTest
public class BatchCreateLeadFromContactTest {
    
    @testSetup static void setup(){
       
        DataFactory.loadCustomSettings();
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        

        List<Account> lstAcc1 = DataFactory.createAccount('Test Acc1', accRecordTypeId, 1);
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
       
    }
    
    static testmethod void testMethod1() 
    {
        List<Contact> newContact = new List<Contact>();
        Map<Id,Contact> oldConMap = new Map<Id,Contact>();
       Test.startTest();
        Account objAcc = [SELECT Id FROM Account order by createdDate asc LIMIT 1];
        objAcc.Active_campaign__c = true;
        update objAcc;
        
        Account objAcc1 = [SELECT Id FROM Account order by createdDate desc LIMIT 1];
        
        Contact objCon = [Select Id,Actively_being_sequenced__c,Claimed_Method__c,Avvo_AI_Sales_Assistant__c,Avvo_AI_Sales_Assistant_Hot_Lead__c,related_to_account__c from contact limit 1];
        oldConMap.put(objCon.Id,objCon);
       objCon.Avvo_AI_Sales_Assistant__c = 'Blaire Carson (Acquisition)';
        objCon.Avvo_AI_Sales_Assistant_Hot_Lead__c = true;
        objCon.related_to_account__c = objAcc.Id;
        objCon.mailingpostalcode = '90245';
        objCon.Actively_being_sequenced__c = true;
        objCon.Email ='test@con.com';
        objCon.Claimed_Method__c = 'Admin';
         objCon.Related_To_Account__c = objAcc1.Id;
        newContact.add(objCon);
        
        
        
        objCon.Avvo_AI_Sales_Assistant_Date_Added__c = Date.Today();
        objCon.Avvo_AI_Sales_Assistant_Hot_Lead_Date__c = Date.Today();
        update objCon;
        newContact.add(objCon);
         Set<Id> conIds = new Set<Id>();
        conIds.add(objCon.Id);
         Database.executeBatch(new BatchCreateLeadFromContact(conIds));
        
        

            Test.stopTest();
            
    }
}
@istest
public class ContactTestClss {
    public static testmethod void testCaseA(){
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> conLst = new List<Contact>();
        Map<Id,Contact> oldMap = new Map<Id,Contact>();
        
        Contact con = new Contact(FirstName= 'test', LastName = 'conLastName');
        con.AccountId = lstAcc[0].Id;
        con.Email = 'test@abc.com';
        con.Phone = '123456789';
        con.RecordTypeId = conRecordTypeId;
        con.Avvo_AI_Sales_Assistant__c = 'Blaire Carson (Acquisition)';
        con.Avvo_AI_Sales_Assistant_Hot_Lead__c = false;
        insert con;
        
        conLst.add(con);
        oldMap.put(con.Id, con);
        
        Contact conA = new Contact(FirstName= 'test', LastName = 'conLastNameAS');
        conA.AccountId = lstAcc[0].Id;
        conA.Email = 'test@abc.com';
        conA.Phone = '123456789';
        conA.RecordTypeId = conRecordTypeId;
        insert conA;
        
        conLst.add(conA);
        oldMap.put(conA.Id, conA);
        
        Contact conB = new Contact(FirstName= 'test', LastName = 'conLastNam');
        conB.AccountId = lstAcc[0].Id;
        conB.Email = 'test@abc.com';
        conB.Phone = '123456789';
        conB.RecordTypeId = conRecordTypeId;
        insert conB;
        
        conLst.add(conB);
        oldMap.put(conB.Id, conB);
        
        MDL_triggerOnContactHandler conClass = new MDL_triggerOnContactHandler();
        MDL_triggerOnContactHandler.populateBeforeHotlead(conLst,oldMap,True);
        MDL_triggerOnContactHandler.populateBeforeHotlead(conLst,oldMap,False);
    }
    public static testmethod void testCaseB(){
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Active_campaign__c = false;
        update lstAcc;
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> conLst = new List<Contact>();
        Map<Id,Contact> oldMap = new Map<Id,Contact>();
        
        Contact con = new Contact(FirstName= 'test', LastName = 'conLastName');
        con.AccountId = lstAcc[0].Id;
        con.Email = 'test@abc.com';
        con.Phone = '123456789';
        con.RecordTypeId = conRecordTypeId;
        con.Avvo_AI_Sales_Assistant__c = 'Blaire Carson (Acquisition)';
        con.related_to_account__c = lstAcc[0].Id;
        insert con;
        
        conLst.add(con); 
        oldMap.put(con.Id, con);
        
        Contact conA = new Contact(FirstName= 'test', LastName = 'conLastNameAS');
        conA.AccountId = lstAcc[0].Id;
        conA.Email = 'testsss@abc.com';
        conA.Phone = '123456789';
        conA.RecordTypeId = conRecordTypeId;
        conA.Avvo_AI_Sales_Assistant__c = 'Blaire Carson (Acquisition)';
        conA.Avvo_AI_Sales_Assistant_Hot_Lead__c = true;
        conA.related_to_account__c = lstAcc[0].Id;
        insert conA;
        
        conLst.add(conA); 
        oldMap.put(conA.Id, conA); 
        
        Contact conB = new Contact(FirstName= 'test', LastName = 'conLastNam');
        conB.AccountId = lstAcc[0].Id;
        conB.Email = 'testsss@abc.com';
        conB.Phone = '123456789';
        conB.RecordTypeId = conRecordTypeId;
        conB.Avvo_AI_Sales_Assistant__c = 'Blaire Carson (Acquisition)';
        conB.Avvo_AI_Sales_Assistant_Hot_Lead__c = true;
        conB.related_to_account__c = lstAcc[0].Id;
        insert conB;
        
        conLst.add(conB); 
        oldMap.put(conB.Id, conB); 
        
        MDL_triggerOnContactHandler conClass = new MDL_triggerOnContactHandler();
        MDL_triggerOnContactHandler.populateAfterHotlead(conLst,oldMap,True);
        MDL_triggerOnContactHandler.populateAfterHotlead(conLst,oldMap,False); 
    }
}
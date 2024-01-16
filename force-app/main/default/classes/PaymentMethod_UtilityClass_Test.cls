@isTest
public class PaymentMethod_UtilityClass_Test {
    
    public static testmethod void testCaseA(){
        
        Set<Id> accId = new Set<Id>();
        Set<Id> conId = new Set<Id>(); 
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        accId.add(lstAcc[0].Id);
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> lstCon = DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        conId.add(lstCon[0].Id);
        
        blng__PaymentMethod__c pmRec = new blng__PaymentMethod__c();
        pmRec.blng__Account__c = lstAcc[0].Id;
        pmRec.blng__PaymentType__c = 'Credit Card';
        pmRec.blng__Active__c = True;
        pmRec.blng__AutoPay__c = True;
        pmRec.Card_Number__c = '4111111111111111';
        pmRec.blng__Nameoncard__c = 'Jm';
        pmRec.blng__CVV__c = '22222'; 
        pmRec.blng__CardExpirationYear__c = '2030';
        pmRec.blng__CardExpirationMonth__c = '10';
        pmRec.blng__CardType__c = 'Visa';
        insert pmRec;
        
        MDL_UtilClass_TestClass utilclass = new MDL_UtilClass_TestClass();
        Set<Id> userlist = new Set<Id>();
        profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' Limit 1];  
        user u1 =  new User(Alias = 'newUser', Email='newuser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='newuser'+utilclass.randomise()+'@testorg.com', LeadOwner_Number__c = 1);
        userlist.add(u1.Id);
        
        PaymentMethod_UtilityClass.updatePMOrderStatusOnAccountMeth(accId);
        PaymentMethod_UtilityClass.updatePMOrderStatusOnAccountPAYmeth(accId);
        PaymentMethod_UtilityClass.updatePMBillingEmailMeth(accId);
        PaymentMethod_UtilityClass.updatePMBillingEmailMethAA(conId);
        PaymentMethod_UtilityClass.userListsMeth(conId);
    }
}
@isTest(seealldata = true)
public with sharing class MDL_Test_DunningEmailPageTest {
	static testMethod void testDunningInitialization(){
		MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
		Account a = util.getAccount();
	    
	    Dunning_Account_ids__c dAccId1 = new Dunning_Account_ids__c();
	    dAccId1.Name = '	01-30;20';
	    dAccId1.Account_Ids__c = a.Id;
	    dAccId1.Starting_Sequence_Number__c = 1;
	    dAccId1.Ending_Sequence_Number__c = 20;
	    insert dAccId1;
	    
	    Dunning_Account_ids__c dAccId2 = new Dunning_Account_ids__c();
	    dAccId2.Name = '30-60;20';
	    dAccId2.Account_Ids__c = a.Id;
	    dAccId2.Starting_Sequence_Number__c = 21;
	    dAccId2.Ending_Sequence_Number__c = 40;
	    insert dAccId2;
	    
	    Dunning_Account_ids__c dAccId3 = new Dunning_Account_ids__c();
	    dAccId3.Name = '60-120;20';
	    dAccId3.Account_Ids__c = a.Id;
	    dAccId3.Starting_Sequence_Number__c = 41;
	    dAccId3.Ending_Sequence_Number__c = 60;
	    insert dAccId3;
	    
	    Dunning_Account_ids__c dAccId4 = new Dunning_Account_ids__c();
	    dAccId4.Name = '>120;20';
	    dAccId4.Account_Ids__c = a.Id;
	    dAccId4.Starting_Sequence_Number__c = 61;
	    dAccId4.Ending_Sequence_Number__c = 80;
	    insert dAccId4;
	    
		MDL_DunningEmailPageTest ctrl = new MDL_DunningEmailPageTest();
		PageReference pg = ctrl.downloadDoc();
		PageReference pg1 = ctrl.viewDunningLetters();
		PageReference pg2 = ctrl.showDocs();
	}
}
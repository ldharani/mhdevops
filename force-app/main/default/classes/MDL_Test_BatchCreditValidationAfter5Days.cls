@isTest(seealldata = true)
public with sharing class MDL_Test_BatchCreditValidationAfter5Days {
	static testMethod void testCreditEscalation(){
		MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
		//create required objects
		Account account1 = util.getAccount();
        invoiceit_s__Currency__c currency1 = util.getCurrencyObject();
        
         Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
         User manager = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newuserManager@testorg.com');
         insert manager;  
         
         User rep = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id,ManagerId = manager.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newuserRep@testorg.com');
         insert rep;  
         
         System.debug('Rep' + rep); 
         System.debug('Manager' + manager); 
        
        System.runAs(rep){        
			invoiceit_s__Payment__c pay = new invoiceit_s__Payment__c();
			pay.invoiceit_s__Account__c = account1.Id;
			pay.invoiceit_s__Currency__c = currency1.Id;
			pay.invoiceit_s__Amount__c = 2000.00;
			pay.invoiceit_s__Payment_Date__c = Date.today();
			pay.invoiceit_s__Payment_Type__c = 'Adujustment';
			pay.Applied_Type__c = 'Credit';
			pay.Adjustment_Reason__c='PH(Renewal save)';
			pay.invoiceit_s__Status__c = 'Completed';
			insert pay;
			
			invoiceit_s__Payment__c pay1 = new invoiceit_s__Payment__c();
			pay1.invoiceit_s__Account__c = account1.Id;
			pay1.invoiceit_s__Currency__c = currency1.Id;
			pay1.invoiceit_s__Amount__c = 7000.00;
			pay1.invoiceit_s__Payment_Date__c = Date.today();
			pay1.invoiceit_s__Payment_Type__c = 'Adujustment';
			pay1.Applied_Type__c = 'Credit';
			pay1.Adjustment_Reason__c='PM(Unauthorized Order)';
			pay1.invoiceit_s__Status__c = 'Completed';
			insert pay1;
			
			invoiceit_s__Payment__c pay2 = new invoiceit_s__Payment__c();
			pay2.invoiceit_s__Account__c = account1.Id;
			pay2.invoiceit_s__Currency__c = currency1.Id;
			pay2.invoiceit_s__Amount__c = 3000.00;
			pay2.Escalate_to__c='Director';
			pay2.invoiceit_s__Payment_Date__c = Date.today();
			pay2.invoiceit_s__Payment_Type__c = 'Adujustment';
			pay2.Applied_Type__c = 'Credit';
			pay2.Adjustment_Reason__c='BL(Billing Incorrect)';
			pay2.invoiceit_s__Status__c = 'Completed';
			insert pay2;
			
			Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
	        //req1.setComments('Submitting request for approval.');
	        req1.setObjectId(pay.Id);
	        Approval.ProcessResult result1 = Approval.process(req1);
	        
	        Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
	        req2.setObjectId(pay1.Id);
	        Approval.ProcessResult result2 = Approval.process(req2);
	        
	        Approval.ProcessSubmitRequest req3 = new Approval.ProcessSubmitRequest();
	        req3.setObjectId(pay2.Id);
	        Approval.ProcessResult result3 = Approval.process(req3);
        }		
        
        Test.startTest();
        MDL_BatchCreditValidationAfter5Days b = new MDL_BatchCreditValidationAfter5Days();
        Database.executeBatch(b);
        Test.stopTest();
	}
}
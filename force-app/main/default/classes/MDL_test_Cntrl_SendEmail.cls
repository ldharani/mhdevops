@isTest(SeeAllData=true)
public with sharing class MDL_test_Cntrl_SendEmail {
		static testMethod void Test_Email() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    	Account acc = testData.getAccount();
        List<Account> acc1 = new List<Account>();
        List<Id> acc2=new List<Id>();
        //List<Account> list_acct ;
        for (Account a : [Select a.Id From Account a limit 20]) 
          	{
    			acc2.add(a.Id);
				}    
    	MDL_Ctrl_SendEmail.generateAttachment(acc.id, 90);
           
        MDL_Ctrl_SendEmail.generateAttachment(acc2, '60-90');
            
       }
    static testMethod void Test_Email1() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    	Account acc = testData.getAccount();
        List<Account> acc1 = new List<Account>();
        List<Id> acc2=new List<Id>();
        for (Account a : [Select a.Id From Account a limit 20]) 
          	{	acc2.add(a.Id);				}    
        MDL_Ctrl_SendEmail.generateAttachment(acc.id, 45);
    	MDL_Ctrl_SendEmail.generateAttachment(acc2, '90-120');
       }
    static testMethod void Test_Email2() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    	Account acc = testData.getAccount();
        List<Id> acc2=new List<Id>();
        for (Account a : [Select a.Id From Account a limit 20]) 
          	{	acc2.add(a.Id);				}
        List<Account> acc1 = new List<Account>();
         MDL_Ctrl_SendEmail.generateAttachment(acc.id, 130);
    	MDL_Ctrl_SendEmail.generateAttachment(acc2, '>120');
       }
}
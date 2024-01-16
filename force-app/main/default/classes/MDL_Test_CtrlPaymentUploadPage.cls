/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
private class MDL_Test_CtrlPaymentUploadPage {

    static testMethod void myUnitTest() {
    	MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();		
		Account a = testData.getAccount();
		a.MH_Cust_Number__c = '105010501050';
		update a;
		invoiceit_s__Invoice__c invoicenew = new invoiceit_s__Invoice__c();
		invoicenew.invoiceit_s__Account__c = a.Id;	
		insert invoicenew;		
		
		invoiceit_s__Invoice__c invoicenew2 = new invoiceit_s__Invoice__c();
		invoicenew2.invoiceit_s__Account__c = a.Id;
		invoicenew2.invoiceit_s__Invoice_Reference__c = '12345';
		insert invoicenew2;
		
		Account acc = [select Id,Name,MH_Cust_Number__c from Account where Id=:a.Id];
		invoiceit_s__Invoice__c invoice1 = [select Id,Name from invoiceit_s__Invoice__c where Id=:invoicenew.Id];
		invoiceit_s__Invoice__c invoice2 = [select Id,Name,invoiceit_s__Invoice_Reference__c from invoiceit_s__Invoice__c where Id=:invoicenew2.Id];
		
		Test.startTest();
		MDL_CtrlPaymentUploadPage m = new MDL_CtrlPaymentUploadPage();
		Pagereference pr1 = m.insertFile();
		m.FileSource = 'Bank Of America';
		m.contentFile = Blob.valueOf('Cust_Nbr,PS_MH_Pay_Amt,Pay_Id,Total_Pay_Amt,Pay_Method,Bank Deposit Date,Payment Ref Item \r "875.97",5002837400,290866,3169.63,Cheque,1/6/2014,'+invoice1.Name);
		Pagereference pr2 = m.insertFile();
		m.FileSource = 'CitiBank';
		m.contentFile = Blob.valueOf('Cust_Nbr,PS_MH_Pay_Amt,Pay_Id,Total_Pay_Amt,Pay_Method,Bank Deposit Date,Payment Ref Item \r '+acc.MH_Cust_Number__c+',8/6/2014,500,6777,678,Cheque,8/6/2014,'+invoice2.invoiceit_s__Invoice_Reference__c);
		Pagereference pr3 = m.insertFile();
		Pagereference pr4 = m.goToEditPaymentPage();
		m.contentFile = Blob.valueOf('Cust_Nbr,PS_MH_Pay_Amt,Pay_Id,Total_Pay_Amt,Pay_Method,Bank Deposit Date,Payment Ref Item \r 50000122000,8/16/2014,500,6777,678,Cheque,8/16/2014,123"456');
 		Pagereference pr5 = m.insertFile();
 		Test.stopTest();
    }
}
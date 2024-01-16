@isTest
public with sharing class MDL_Test_TriggerOnAttachment {
	static testMethod void createAttachment(){
		Aging_Report_MailIds__c mailID = new Aging_Report_MailIds__c();
		mailID.Name = 'Sample Email Address For Aging Report';
		mailID.Email__c = 'test@testOrg.com';
		insert mailID;
		Aging_Report_File__c agingReport = new Aging_Report_File__c(Name='Sample Aging Report');
		insert agingReport;		
		Attachment a = new Attachment();
		a.Name = 'Aging Report For Test Class';
		a.ParentID = agingReport.Id;
		a.Body = Blob.valueOf('Report that displays all unpaid invoices and unallocated payments for accounts');
		insert a;
	}
}
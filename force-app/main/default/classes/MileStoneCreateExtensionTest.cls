@isTest
public class MileStoneCreateExtensionTest {
     static testmethod void scenario1(){
         Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
         MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();        
         Account a = testData.getAccount();    
         Contact c = testData.getContact(a.Id);
         Milestone1_Project__c project = new Milestone1_Project__c (name ='Content (General)');
         insert project;    
         invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
         Milestone1_Milestone__c milestoneObj = new Milestone1_Milestone__c(Project__c = project.Id,Name ='SEO_Renewal');
         MileStoneCreateExtension extn = new MileStoneCreateExtension(new ApexPages.StandardController(milestoneObj));
         extn.selectedMilestoneName = 'SEO_Renewal';
         extn.saveMilestone();
     }
     static testmethod void scenario2(){
         Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
         MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();        
         Account a = testData.getAccount();    
         Contact c = testData.getContact(a.Id);
         Milestone1_Project__c project = new Milestone1_Project__c (name ='SEO_Gold');
         insert project;    
         invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
         Milestone1_Milestone__c milestoneObj = new Milestone1_Milestone__c(Project__c = project.Id,Name ='Content_w_SEO_PostLaunch_w_Order');
         MileStoneCreateExtension extn = new MileStoneCreateExtension(new ApexPages.StandardController(milestoneObj));
                  
         extn.selectedMilestoneName = 'Content_w_SEO_PostLaunch_w_Order';
         extn.saveMilestone();
     }
     static testmethod void scenario3(){
         Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
         MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();        
         Account a = testData.getAccount();    
         Contact c = testData.getContact(a.Id);
         Milestone1_Project__c project = new Milestone1_Project__c (name ='Content (General)');
         insert project;    
         invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
         Milestone1_Milestone__c milestoneObj = new Milestone1_Milestone__c(Project__c = project.Id,Name ='Content_w_SEO_PostLaunch_w_Order');
         MileStoneCreateExtension extn = new MileStoneCreateExtension(new ApexPages.StandardController(milestoneObj));
                  
         extn.selectedMilestoneName = 'Content_w_SEO_PostLaunch_w_Order';
         extn.saveMilestone();
     }
}
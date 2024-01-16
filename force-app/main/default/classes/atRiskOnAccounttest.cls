@isTest(seeAllData=true)
public class atRiskOnAccounttest {

    static testMethod void myUnitTest() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        
        User u = testData.getUser_admin();
        List<GroupMember> GroupMemberList = new List<GroupMember>();
        
        Account a = testData.getAccount();    
        Contact c = testData.getContact(a.Id);      
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject(); 
        a.BillingStreet = '1115 Avenue';
        a.BillingState = 'CA';
        a.BillingPostalCode = '12356';
        a.ShippingState = 'CA';  
        a.ShippingPostalCode = '12356';            
       //update a;  
  
        Milestone1_Project__c project = new Milestone1_Project__c (name ='SEO_Local_Boost',Account__c = a.Id, Status__c='Optimization' );
        insert project;   
        
         system.runAs(u){
             Group Managerqueue = [select Id, Name from Group where
                                                       id = '00G0G0000077HB8' LIMIT 1];
          //GroupMember gm    = new GroupMember(GroupId =Managerqueue.id, UserOrGroupId=u.id );
         // insert gm;
          
          GroupMemberList.add(new GroupMember(GroupId =Managerqueue.id, UserOrGroupId=u.id ) );
          
          insert GroupMemberList;
           
          Task t = new Task(subject = 'test', whatid= a.id);
          
          insert t;
        }
        
        a.is_account_at_risk__c = true;
        a.at_risk_reason__c = 'Test reason';
        update a;
        //Milestone1_Milestone__c milestoneObj = new Milestone1_Milestone__c(Project__c = project.Id,Name ='SEO_Audit/Account Review At Risk');

        }
}
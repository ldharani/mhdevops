@isTest
//(seealldata=true)
public class SubscriptionProjectCreationTest {
    @testSetup static void setup() {
    //static testmethod void ProjectCreationforSub(){
        
        Deactivate_Trigger_for_data_load__c customSetting = new Deactivate_Trigger_for_data_load__c(Name='Deactivate1',Deactivate_trigger__c=false);
        insert customSetting;
        
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
          List<Subscription__c > Subs= new List<Subscription__c >();
          Map<Id,Subscription__c > mapSub = new Map<Id,Subscription__c >();
        Account acc = testData.getAccount();
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.StageName = 'Receipt';
        opp.Name = 'test opportunity';
        opp.CloseDate = system.today();
        opp.Type = 'Website';
        opp.Sales_Person_Email__c = 'testuser@mh.com';
        insert opp;
        
        Subscription__c s = new Subscription__c();
        s.Account__c = acc.Id;
        s.Opportunity__c = opp.Id;
        s.Subscription_Id__c = '11111111';
        //s.Description = 'Account is due for renewal within 120 days';
        //s.Priority = 'Medium';
        s.External_Id__c = '00000000';
        s.Name  = 'test Subscription';
        s.Inventory_Type__c  = 'WebsiteInventory';
        //insert s;
        Subs.add(s);
        mapSub.put(s.id,s);
        
        Subscription__c sub = new Subscription__c();
        sub .Account__c = acc.Id;
        sub .Opportunity__c = opp.Id;
        sub .Subscription_Id__c = '111111221';
        //s.Description = 'Account is due for renewal within 120 days';
        sub .Cancelled__c = false;
        //s.Priority = 'Medium';
        sub .External_Id__c = '00000010';
        sub .Name  = 'test Subscription2';
        sub .Inventory_Type__c  = 'Advanced360Inventory';
        //insert sub ;
        subs.add(sub);
        
        
        Subscription__c sub2 = new Subscription__c();
        sub2.Account__c = acc.Id;
        sub2.Opportunity__c = opp.Id;
        sub2.Subscription_Id__c = '111111231';
        sub2.Cancelled__c = false;
        sub2.External_Id__c = '00000020';
        sub2.Name  = 'test Subscription3';
        sub2.Inventory_Type__c  = 'MartindaleBaseProfileInventory';
        //insert sub2;
        subs.add(sub2);
        
        insert subs;
        
        Case c = new Case();
        c.AccountId = acc.Id;
        c.Subject = 'Advanced 360 Order';
        c.Description = 'Advanced 360 Order';
        c.Priority = 'Medium';
        c.Status = 'New';
        c.Area__c  = 'Advanced 360 New ';
        //c.Sub_Area__c  = 'Annual Custom Content';
        insert c;
                
          
        Case c1 = new Case();
        c1.AccountId = acc.Id;
        c1.Subject = 'Advanced 360 Cancelation';
        c1.Subscription__c= sub.id;
        c1.Description = 'Advanced 360 Cancelation';
        c1.Priority = 'Medium';
        c1.Status = 'New';
        c1.Area__c  = 'Advanced 360 Cancelation ';
        c1.Cancellation_Date__c = Date.Today();
        //c.Sub_Area__c  = 'Annual Custom Content';
        insert c1;       
    }
    static testmethod void ProjectCreationforSub(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Milestone1_Project__c project = new Milestone1_Project__c (name ='Avvo_Bronze',Account__c = acc.Id, Status__c='Optimization');
        insert project;
        SubscriptionProjectCreation classinstance = new SubscriptionProjectCreation();
        classinstance.FkMethod();
        test.stopTest();

    }
    static testmethod void caseCreationforSubCancel(){
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Subscription__c sub = [SELECT Id,Cancelled__c FROM Subscription__c WHERE Subscription_Id__c = '111111231' limit 1];
        test.startTest();
        sub.Cancelled__c = true;
        update sub;
        test.stopTest();
        system.debug('test');
    }
}
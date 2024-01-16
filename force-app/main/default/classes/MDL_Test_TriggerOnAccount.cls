@isTest(seealldata=true)
public with sharing class MDL_Test_TriggerOnAccount {
    static testMethod void createCase(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Account acc = util.getAccount();            
        System.debug('Beforee update::'+acc); 
        acc.BillingStreet = '1115 Avenue';
        acc.BillingState = 'CA';
        acc.BillingPostalCode = '12356';
        acc.ShippingState = 'CA';  
        acc.ShippingPostalCode = '12356';            
        update acc; 
        System.debug('After update::'+acc);    
    }
    
    static testMethod void UpdateorderStatus()
    {
        MDL_UtilClass_TestClass mdlutil = new MDL_UtilClass_TestClass();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        account a = mdlutil.getAccount();
        contact c = mdlutil.getcontact(a.id);
        contact c1 = mdlutil.getcontact(a.id);
        invoiceit_s__Currency__c cur =  mdlutil.getCurrencyObject();
        invoiceit_s__Job__c ord = mdlutil.getOrder(a.id, cur.id);
        ord.invoiceit_s__Billing_Contact__c = c.id;
        update ord;
        Opportunity opp = mdlutil.getOpportunity(a.id , c.id , cur.id);
        invoiceit_s__Product__c prod = mdlutil.getProduct('Yes');
        invoiceit_s__Job_Product__c ordprod = mdlutil.getOrderProduct(ord.id, prod.id);
        invoiceit_s__Payment_Method__c pay = mdlutil.getPaymentMethod(a.id);
        pay.invoiceit_s__Active__c  = true;
        pay.invoiceit_s__Payment_Method__c = 'Credit Card';
        update pay;
        a.Order_Status__c = 'Active';
        update a; 
    }
    
    static testmethod void atRiskTest(){
    
        List<GroupMember> GroupMemberList = new List<GroupMember>();
        List<Account> accList = new List<Account>();

        MDL_UtilClass_TestClass mdlutil = new MDL_UtilClass_TestClass();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u = new User(Alias = 'standt', Email='testcasemanager@bcinsourcing.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testcasemanager@bcinsourcing.com');
                
        Account a = new Account();
        a.Name = 'testAcc'; 
        a.Phone='122-34345-654';
        a.invoiceit_s__Preferred_Billing_Day__c = '1';
        a.Type = 'Customer';
        a.invoiceit_s__Invoice_Delivery_Type__c = 'Email';
        a.ShippingStreet = '111 Train Ave';
        a.BillingStreet = '111 Train Ave';
        a.BillingState = 'NY';
        a.ShippingState = 'NY';
        a.ShippingPostalCode = '12356-2343'; a.BillingPostalCode = '12356-2343';
        a.ShippingLongitude = 12;a.BillingLongitude = 12;
        a.ShippingLatitude = 10 ;a.BillingLatitude = 10;
        a.ShippingCountry = 'USA';a.BillingCountry = 'USA';
        a.ShippingCity = 'California';a.BillingCity = 'California';
        a.Primary_Contact__c = 'venkatesan.mu@listertechnologies.com';
        a.Organization_Type__c = 'Corporation';
        a.Firm_Email__c = 'sbender@brirllp.com';
        a.Evergreen_Contract_Status__c = 'NA';
        a.Collector__c = u.Id;
        accList.add(a);
        insert accList;
        
        system.runAs(u){
        
        
                
        List<String> queueName = new List<String>();
         queueName.add('SEO Sales Engineer');
             
        List<Group> testGroup = [Select id, name From Group Where Name in: queueName AND Type ='Queue'];
        String queueId;
        queueId = testGroup[0].id; 
        
       
        a.At_Risk_Reason__c = 'test';
        update accList;
        
         Case c = new Case(Subject = 'SEO Account potentially at Risk', AccountId = accList[0].Id, ownerId = queueId,
                            Status = 'New', Origin = 'SEOMail', Description = a.At_Risk_Reason__c,
                            Area__c = 'Create Milestone', Sub_Area__c = 'SEO_Audit/Account Review At Risk');
         insert c;
        }
    }
    
    
     static testMethod void UpdatacctOwnerEmailOnProj()
    {
        MDL_UtilClass_TestClass mdlutil = new MDL_UtilClass_TestClass();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        List<Account> accList = new List<Account>();


        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        List<Milestone1_Project__c> projList = new List<Milestone1_Project__c>();


        User u = new User(Alias = 'standt', Email='testcasemanager@bcinsourcing.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testcasemanager@bcinsourcing.com');
            
        User u2 = new User(Alias = 'standdt', Email='testcasemaasdanager@bcinsourcing.com', 
            EmailEncodingKey='UTF-8', LastName='Testaing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testcasemaasdanager@bcinsourcing.com');
            

        Account a = new Account();
        a.Name = 'testAcc'; 
        a.Phone='122-34345-654';
        a.invoiceit_s__Preferred_Billing_Day__c = '1';
        a.Type = 'Customer';
        a.invoiceit_s__Invoice_Delivery_Type__c = 'Email';
        a.ShippingStreet = '111 Train Ave';
        a.BillingStreet = '111 Train Ave';
        accList.add(a);
        
        insert accList;
        
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProjectActive('TaskCompProject');
        proj.Account__c = a.Id;
        projList.add(proj);
        
        insert projList ; 
       
        
        system.runAs(u2){
        
        a.Owner = u2;
        update accList[0];
        
        proj.Account_Owner_Email__c = a.Account_Owner_Email__c;
        update proj;
        
        }
        
        
    }
    static testMethod void updateParentAccWChildAccFields(){
        
        //List<Account> accList = new List<Account>();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Id IBAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        Id MHAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        Id MNGAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId();
        Id MNAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-N Account').getRecordTypeId();
        
        Account a = new Account();
        a.Name = 'testIBAcc'; 
        a.Phone='122-34345-654';
        a.invoiceit_s__Preferred_Billing_Day__c = '1';
        a.Type = 'Customer';
        a.invoiceit_s__Invoice_Delivery_Type__c = 'Email';
        a.ShippingStreet = '111 Train Ave';
        a.BillingStreet = '111 Train Ave';
        a.RecordTypeId = IBAccRecordTypeId;
        Insert a;
        //accList.add(a);
        
        Account a2 = new Account();
        a2.Name = 'testMHAcc'; 
        a2.Phone='122-34345-654';
        a2.invoiceit_s__Preferred_Billing_Day__c = '1';
        a2.Type = 'Customer';
        a2.invoiceit_s__Invoice_Delivery_Type__c = 'Email';
        a2.ShippingStreet = '111 Train Ave';
        a2.BillingStreet = '111 Train Ave';
        a2.ParentId = a.Id;
        a2.RecordTypeId = MHAccRecordTypeId;
        a2.Order_Status__c = '';
        a2.Customer_Status__c = '';
        a2.Organization_Type__c = '';
        a2.Classification__c = '';
        a2.Sub_Type__c = '';
        Insert a2;
        
        Account a3 = new Account();
        a3.Name = 'testMNAcc'; 
        a3.Phone='122-34345-654';
        a3.invoiceit_s__Preferred_Billing_Day__c = '1';
        a3.Type = 'Customer';
        a3.invoiceit_s__Invoice_Delivery_Type__c = 'Email';
        a3.ShippingStreet = '111 Train Ave';
        a3.BillingStreet = '111 Train Ave';
        a3.ParentId = a.Id;
        a3.RecordTypeId = MNAccRecordTypeId;
        a3.Order_Status__c = '';
        a3.Customer_Status__c = '';
        a3.Organization_Type__c = '';
        a3.Classification__c = '';
        a3.Sub_Type__c = '';
        Insert a3;
        
        Account a4 = new Account();
        a4.Name = 'testMNGAcc'; 
        a4.Phone='122-34345-654';
        a4.invoiceit_s__Preferred_Billing_Day__c = '1';
        a4.Type = 'Customer';
        a4.invoiceit_s__Invoice_Delivery_Type__c = 'Email';
        a4.ShippingStreet = '111 Train Ave';
        a4.BillingStreet = '111 Train Ave';
        a4.ParentId = a.Id;
        a4.RecordTypeId = MNGAccRecordTypeId;
        a4.Order_Status__c = '';
        a4.Customer_Status__c = '';
        a4.Organization_Type__c = '';
        a4.Classification__c = '';
        a4.Sub_Type__c = '';
        Insert a4;
        //accList.add(a2);
        
        //Insert accList;
        
        Test.startTest();
        a2.Order_Status__c = 'Active';
        a2.Organization_Type__c = 'Law Firm';
        a2.Sub_Type__c = 'Small Law';
        a2.Customer_Status__c = 'New';
        a2.Classification__c = 'Legal';
        update a2;
        a3.Order_Status__c = 'Evergreen';
        a3.Organization_Type__c = 'Law Firm';
        a3.Sub_Type__c = 'Small Law';
        a3.Customer_Status__c = 'New';
        a3.Classification__c = 'Legal';
        update a3;
        a4.Order_Status__c = 'Active';
        a4.Organization_Type__c = 'Law Firm';
        a4.Sub_Type__c = 'Small Law';
        a4.Customer_Status__c = 'New';
        a4.Classification__c = 'Legal';
        update a4;
        Test.stopTest();
        
    }
    
    static testMethod void updateOrderStatusOnPaymentMethod(){
        
        Id MHAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Account a = new Account();
        a.Name = 'testIBAcc'; 
        a.Phone='122-34345-654';
        a.invoiceit_s__Preferred_Billing_Day__c = '1';
        a.Type = 'Customer';
        a.invoiceit_s__Invoice_Delivery_Type__c = 'Email';
        a.ShippingStreet = '111 Train Ave';
        a.BillingStreet = '111 Train Ave';
        a.RecordTypeId = MHAccRecordTypeId;
        Insert a;
        MDL_UtilClass_TestClass mdlutil = new MDL_UtilClass_TestClass();
        invoiceit_s__Payment_Method__c pay = mdlutil.getPaymentMethod(a.id);
        pay.invoiceit_s__Active__c  = true;
        pay.invoiceit_s__Default__c = true;
        pay.invoiceit_s__Payment_Method__c = 'Credit Card';
        update pay;
        
        Test.startTest();
        a.Order_Status__c = 'Active';
        update a;
        Test.stopTest();
        
    }
    
}
@IsTest
public class TestBatchCascadingOrgId {
static testMethod void testMethod1(){
		Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
	    Id AvvoAttyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        Id IBAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        Id AvvoFirmRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId();
        
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
        Account acc = util.getAccount(); 
        acc.RecordtypeId = IBAccRecordTypeId;
        acc.BillingStreet = '1115 Avenue';
        acc.BillingState = 'CA';
        acc.BillingPostalCode = '12356';
        acc.ShippingState = 'CA';  
        acc.ShippingPostalCode = '12356'; 
        acc.Active_Ad_Subscriptions__c = 2;
        acc.Contact_Email__c= 'abc@gmail.com';
        update acc;
        
        Account acc1 = util.getAccount(); 
        acc1.RecordtypeId = AvvoFirmRecordTypeId;
        acc1.BillingStreet = '1115 Avenue';
        acc1.ParentId=acc.Id;
        acc1.BillingState = 'CA';
        acc1.BillingPostalCode = '12356';
        acc1.ShippingState = 'CA';  
        acc1.ShippingPostalCode = '12356'; 
        acc1.Active_Ad_Subscriptions__c = 2;
        acc1.Contact_Email__c= 'abc@gmail.com';
    	acc1.Org_Id__c='';
        update acc1;
        
        Account acc2 = util.getAccount(); 
        acc2.RecordtypeId = AvvoAttyRecordTypeId;
        acc2.ParentId=acc1.Id;
        acc2.BillingStreet = '1115 Avenue';
        acc2.BillingState = 'CA';
        acc2.BillingPostalCode = '12356';
        acc2.ShippingState = 'CA';  
        acc2.ShippingPostalCode = '12356'; 
        acc2.Active_Ad_Subscriptions__c = 2;
        acc2.Contact_Email__c= 'abc@gmail.com';
        update acc2;
    
    Contact c = new Contact();
        c.LastName = 'Test Contact1';
        c.Email = 'testabc@gmail.com';
        c.AccountId = acc1.Id;
        c.related_to_account__c=acc1.Id;
        insert c;
    	test.starttest();
    	acc2.Org_Id__c = '12345';
    	update acc2;
        test.stoptest();
}
}
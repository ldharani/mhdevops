@isTest
public class Test_AvvoTotalSpendUpdate_Cls {
    static testMethod void testUpdateAccSpend(){
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
        acc2.Active_Opportunities_Amount__c = 100;
        update acc2;
        
        test.starttest();
        Batch_AvvoTotalSpendUpdate_Cls btc=new Batch_AvvoTotalSpendUpdate_Cls();
        database.executebatch(btc,2);
        Batch_AvvoTotalSpendUpdate_schedular sch1= new Batch_AvvoTotalSpendUpdate_schedular();
         String sch = '0 0 23 * * ?'; 
         system.schedule('Test sch', sch, sch1);
        test.stoptest();
        
    }
}
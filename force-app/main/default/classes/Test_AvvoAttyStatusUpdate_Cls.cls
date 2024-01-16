/***************
* Class Name: Test_AvvoAttyStatusUpdate_cls
* Test Class for: AvvoAttyStatusUpdate_cls
* Description: This class updates the customer status and order status 
*              on the Avvo Atty accounts based on the Advertising status field.
* Developed By: Ieswarya J
* Modification History : Created on July 22,2020
* 
* 
* Change History
************************************************************************************************************************
Jira       ModifiedBy    Date         Requested By    Tag     Description
MHBS-7530  Sachin        10/1/2023                    T01     Avvo Attorney account and firm account not updating the BU Icon as expected

************************************************************************************************************************/

@isTest
public class Test_AvvoAttyStatusUpdate_Cls {
    
    static testMethod void testUpdateAccStatus(){
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
        
        Account acc3 = util.getAccount(); 
        acc3.RecordtypeId = AvvoAttyRecordTypeId;
        acc3.ParentId=acc1.Id;
        acc3.BillingStreet = '1115 Avenue';
        acc3.BillingState = 'CA';
        acc3.BillingPostalCode = '12356';
        acc3.ShippingState = 'CA';  
        acc3.ShippingPostalCode = '12356'; 
        acc3.Active_Backorders__c = 1;
        acc3.Contact_Email__c= 'abc@gmail.com';
        update acc3;
        
        Account acc4 = util.getAccount(); 
        acc4.RecordtypeId = AvvoAttyRecordTypeId;
        acc4.ParentId=acc1.Id;
        acc4.BillingStreet = '1115 Avenue';
        acc4.BillingState = 'CA';
        acc4.BillingPostalCode = '12356';
        acc4.ShippingState = 'CA';  
        acc4.ShippingPostalCode = '12356'; 
        acc4.AE_Book__c = true;
        acc4.Waitlist__c = true;
        acc4.Contact_Email__c= 'abc@gmail.com';
        update acc4;          
        
        test.starttest();
        Batch_AvvoAttyStatusUpdate_Cls btc=new Batch_AvvoAttyStatusUpdate_Cls();
        database.executebatch(btc,200);
        /*
Batch_AvvoIBFirmAccUpdate_Cls btc1=new Batch_AvvoIBFirmAccUpdate_Cls();
database.executebatch(btc1,1);

Batch_AvvoFirmSingleRunUpdate_Cls btc2=new Batch_AvvoFirmSingleRunUpdate_Cls();
database.executebatch(btc2,1);

Batch_AvvoAttyStatusUpdate_schedular sch1= new Batch_AvvoAttyStatusUpdate_schedular();
String sch = '0 0 23 * * ?'; 
system.schedule('Test sch', sch, sch1); 
Batch_AvvoIBFirmAccUpdate_schedular sch2= new Batch_AvvoIBFirmAccUpdate_schedular();
String schw = '0 0 23 * * ?'; 
system.schedule('Test sch1', schw, sch2); 
Batch_AvvoFirmSingleRunUpd_schedular sch3= new Batch_AvvoFirmSingleRunUpd_schedular();
String schd = '0 0 23 * * ?'; 
system.schedule('Test sch2', schd, sch3); 
*/
        // <T01>
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        test.stoptest();
    }
    
    static testMethod void testUpdateAccStatusMock1(){
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
        
        Account acc3 = util.getAccount(); 
        acc3.RecordtypeId = AvvoAttyRecordTypeId;
        acc3.ParentId=acc1.Id;
        acc3.BillingStreet = '1115 Avenue';
        acc3.BillingState = 'CA';
        acc3.BillingPostalCode = '12356';
        acc3.ShippingState = 'CA';  
        acc3.ShippingPostalCode = '12356'; 
        acc3.Active_Backorders__c = 1;
        acc3.Contact_Email__c= 'abc@gmail.com';
        update acc3;
        
        Account acc4 = util.getAccount(); 
        acc4.RecordtypeId = AvvoAttyRecordTypeId;
        acc4.ParentId=acc1.Id;
        acc4.BillingStreet = '1115 Avenue';
        acc4.BillingState = 'CA';
        acc4.BillingPostalCode = '12356';
        acc4.ShippingState = 'CA';  
        acc4.ShippingPostalCode = '12356'; 
        acc4.AE_Book__c = true;
        acc4.Waitlist__c = true;
        acc4.Contact_Email__c= 'abc@gmail.com';
        update acc4;          
        
        test.starttest();
        //Batch_AvvoAttyStatusUpdate_Cls btc=new Batch_AvvoAttyStatusUpdate_Cls();
        //database.executebatch(btc,1);
        
        Batch_AvvoIBFirmAccUpdate_Cls btc1=new Batch_AvvoIBFirmAccUpdate_Cls();
        database.executebatch(btc1,1);
        /*
Batch_AvvoFirmSingleRunUpdate_Cls btc2=new Batch_AvvoFirmSingleRunUpdate_Cls();
database.executebatch(btc2,1);

Batch_AvvoAttyStatusUpdate_schedular sch1= new Batch_AvvoAttyStatusUpdate_schedular();
String sch = '0 0 23 * * ?'; 
system.schedule('Test sch', sch, sch1); 
Batch_AvvoIBFirmAccUpdate_schedular sch2= new Batch_AvvoIBFirmAccUpdate_schedular();
String schw = '0 0 23 * * ?'; 
system.schedule('Test sch1', schw, sch2); 
Batch_AvvoFirmSingleRunUpd_schedular sch3= new Batch_AvvoFirmSingleRunUpd_schedular();
String schd = '0 0 23 * * ?'; 
system.schedule('Test sch2', schd, sch3); 
*/
        // <T01>
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        test.stoptest();
    }
    
    static testMethod void testUpdateAccStatusMock2(){
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
        
        Account acc3 = util.getAccount(); 
        acc3.RecordtypeId = AvvoAttyRecordTypeId;
        acc3.ParentId=acc1.Id;
        acc3.BillingStreet = '1115 Avenue';
        acc3.BillingState = 'CA';
        acc3.BillingPostalCode = '12356';
        acc3.ShippingState = 'CA';  
        acc3.ShippingPostalCode = '12356'; 
        acc3.Active_Backorders__c = 1;
        acc3.Contact_Email__c= 'abc@gmail.com';
        update acc3;
        
        Account acc4 = util.getAccount(); 
        acc4.RecordtypeId = AvvoAttyRecordTypeId;
        acc4.ParentId=acc1.Id;
        acc4.BillingStreet = '1115 Avenue';
        acc4.BillingState = 'CA';
        acc4.BillingPostalCode = '12356';
        acc4.ShippingState = 'CA';  
        acc4.ShippingPostalCode = '12356'; 
        acc4.AE_Book__c = true;
        acc4.Waitlist__c = true;
        acc4.Contact_Email__c= 'abc@gmail.com';
        update acc4;          
        
        test.starttest();
        /*
Batch_AvvoAttyStatusUpdate_Cls btc=new Batch_AvvoAttyStatusUpdate_Cls();
database.executebatch(btc,1);

Batch_AvvoIBFirmAccUpdate_Cls btc1=new Batch_AvvoIBFirmAccUpdate_Cls();
database.executebatch(btc1,1);
*/
        Batch_AvvoFirmSingleRunUpdate_Cls btc2=new Batch_AvvoFirmSingleRunUpdate_Cls();
        database.executebatch(btc2,1);
        /*
Batch_AvvoAttyStatusUpdate_schedular sch1= new Batch_AvvoAttyStatusUpdate_schedular();
String sch = '0 0 23 * * ?'; 
system.schedule('Test sch', sch, sch1); 
Batch_AvvoIBFirmAccUpdate_schedular sch2= new Batch_AvvoIBFirmAccUpdate_schedular();
String schw = '0 0 23 * * ?'; 
system.schedule('Test sch1', schw, sch2); 
Batch_AvvoFirmSingleRunUpd_schedular sch3= new Batch_AvvoFirmSingleRunUpd_schedular();
String schd = '0 0 23 * * ?'; 
system.schedule('Test sch2', schd, sch3); 
*/
        // <T01>
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        test.stoptest();
    }
    
    static testMethod void testUpdateAccStatusMock(){
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
        
        Account acc3 = util.getAccount(); 
        acc3.RecordtypeId = AvvoAttyRecordTypeId;
        acc3.ParentId=acc1.Id;
        acc3.BillingStreet = '1115 Avenue';
        acc3.BillingState = 'CA';
        acc3.BillingPostalCode = '12356';
        acc3.ShippingState = 'CA';  
        acc3.ShippingPostalCode = '12356'; 
        acc3.Active_Backorders__c = 1;
        acc3.Contact_Email__c= 'abc@gmail.com';
        update acc3;
        
        Account acc4 = util.getAccount(); 
        acc4.RecordtypeId = AvvoAttyRecordTypeId;
        acc4.ParentId=acc1.Id;
        acc4.BillingStreet = '1115 Avenue';
        acc4.BillingState = 'CA';
        acc4.BillingPostalCode = '12356';
        acc4.ShippingState = 'CA';  
        acc4.ShippingPostalCode = '12356'; 
        acc4.AE_Book__c = true;
        acc4.Waitlist__c = true;
        acc4.Contact_Email__c= 'abc@gmail.com';
        update acc4;          
        
        test.starttest();
        /*
Batch_AvvoAttyStatusUpdate_Cls btc=new Batch_AvvoAttyStatusUpdate_Cls();
database.executebatch(btc,1);

Batch_AvvoIBFirmAccUpdate_Cls btc1=new Batch_AvvoIBFirmAccUpdate_Cls();
database.executebatch(btc1,1);

Batch_AvvoFirmSingleRunUpdate_Cls btc2=new Batch_AvvoFirmSingleRunUpdate_Cls();
database.executebatch(btc2,1);
*/
        Batch_AvvoAttyStatusUpdate_schedular sch1= new Batch_AvvoAttyStatusUpdate_schedular();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test sch', sch, sch1); 
        Batch_AvvoIBFirmAccUpdate_schedular sch2= new Batch_AvvoIBFirmAccUpdate_schedular();
        String schw = '0 0 23 * * ?'; 
        system.schedule('Test sch1', schw, sch2); 
        Batch_AvvoFirmSingleRunUpd_schedular sch3= new Batch_AvvoFirmSingleRunUpd_schedular();
        String schd = '0 0 23 * * ?'; 
        system.schedule('Test sch2', schd, sch3); 
        // <T01>
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        test.stoptest();
    }
    
    static testMethod void testUpdateCrossSell(){
        Id AvvoAttyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        Id IBAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        Id AvvoFirmRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId();
        Id NoloRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get('Nolo_Account').getRecordTypeId();
        Id MNRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get('M_N_Account').getRecordTypeId();
        
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
        Account acc3 = util.getAccount(); 
        acc3.RecordtypeId = IBAccRecordTypeId;
        acc3.BillingStreet = '1115 Avenue';
        acc3.BillingState = 'CA';
        acc3.BillingPostalCode = '12356';
        acc3.ShippingState = 'CA';  
        acc3.ShippingPostalCode = '12356'; 
        acc3.Active_Ad_Subscriptions__c = 2;
        acc3.Order_Status__c = 'Active';
        acc3.Contact_Email__c= 'abc@gmail.com';
        update acc3;
        
        Account acc = util.getAccount(); 
        acc.RecordtypeId = IBAccRecordTypeId;
        acc.BillingStreet = '1115 Avenue';
        acc.BillingState = 'CA';
        acc.ParentId=acc3.Id;
        acc.BillingPostalCode = '12356';
        acc.ShippingState = 'CA';  
        acc.ShippingPostalCode = '12356'; 
        acc.Active_Ad_Subscriptions__c = 2;
        acc.Order_Status__c = 'Active';
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
        acc1.Order_Status__c = 'Active';
        acc1.Contact_Email__c= 'abc@gmail.com';
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
        acc2.Order_Status__c = 'Active';
        acc2.Contact_Email__c= 'abc@gmail.com';
        update acc2;
        
        Account acc5 = util.getAccount(); 
        acc5.RecordtypeId = NoloRecordTypeId;
        acc5.ParentId=acc1.Id;
        acc5.BillingStreet = '1115 Avenue';
        acc5.BillingState = 'CA';
        acc5.BillingPostalCode = '12356';
        acc5.ShippingState = 'CA';  
        acc5.ShippingPostalCode = '12356'; 
        acc5.Active_Backorders__c = 1;
        acc5.Contact_Email__c= 'abc@gmail.com';
        update acc5;
        
        Account acc4 = util.getAccount(); 
        acc4.RecordtypeId = MNRecordTypeId;
        acc4.ParentId=acc1.Id;
        acc4.BillingStreet = '1115 Avenue';
        acc4.BillingState = 'CA';
        acc4.BillingPostalCode = '12356';
        acc4.ShippingState = 'CA';  
        acc4.ShippingPostalCode = '12356'; 
        acc4.AE_Book__c = true;
        acc4.Waitlist__c = true;
        acc4.Contact_Email__c= 'abc@gmail.com';
        update acc4;      
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(acc1.Id));        
        Apexpages.StandardController sc = new Apexpages.StandardController(acc1);
        CrossSellBanner_cls ext = new  CrossSellBanner_cls(sc);
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(acc.Id));        
        Apexpages.StandardController sc2 = new Apexpages.StandardController(acc);
        CrossSellBanner_cls ext2 = new  CrossSellBanner_cls(sc2);
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(acc5.Id));        
        Apexpages.StandardController sc3 = new Apexpages.StandardController(acc5);
        CrossSellBanner_cls ext3 = new  CrossSellBanner_cls(sc3);
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(acc4.Id));        
        Apexpages.StandardController sc4 = new Apexpages.StandardController(acc4);
        CrossSellBanner_cls ext4 = new  CrossSellBanner_cls(sc4);
        
        test.starttest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(acc2.Id));        
        Apexpages.StandardController sc1 = new Apexpages.StandardController(acc2);
        CrossSellBanner_cls ext1 = new  CrossSellBanner_cls(sc1); 
        // <T01>
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        test.stoptest();
    }
    
    
    
    static testMethod void testAvvoContactCrossSell(){
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
        c.AccountId = acc.Id;
        c.related_to_account__c=acc2.Id;
        insert c;
        
        test.starttest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(c.Id));        
        Apexpages.StandardController sc = new Apexpages.StandardController(c);
        AvvoContactCrossBanner_Cls ext = new  AvvoContactCrossBanner_Cls(sc);
        // <T01>
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        test.stoptest();
        
    }
    
}
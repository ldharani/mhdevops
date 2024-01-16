/***************
* Class Name: Batch_DunningUpdateOnAccount_Test
* Test Class for: Batch_DunningUpdateOnAccount
* Description: This class updates the customer status and order status 
*              on the Avvo Atty accounts based on the Advertising status field.
* Developed By: Jeyamugundan
* Modification History : Created on May 27,2022
* 
* 
* ******/
@isTest
public class Batch_DunningUpdateOnAccount_Test {
    static testMethod void testUpdateAccStatus(){
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
        Account acc = util.getAccount();
        
        Id MHRecordTypeId = Schema.SObjectType.blng__Invoice__c.getRecordTypeInfosByDeveloperName().get('MH_Invoice').getRecordTypeId();
        
        //creating invoice
        blng__Invoice__c  singleInv = new blng__Invoice__c ();
        singleInv.blng__Account__c= acc.id;    
        singleInv.blng__DueDate__c = System.today().adddays(-10);
        singleInv.RecordtypeId = MHRecordTypeId ;
        singleInv.blng__InvoiceDate__c = date.Today().addDays(-10);
        singleInv.blng__InvoiceStatus__c = 'Draft';
        insert singleInv ;
        singleInv.blng__DueDate__c = System.today().adddays(-11);
        Update singleInv;
        
        //creating invoice line
        Id InvlineRecordTypeId = Schema.SObjectType.blng__InvoiceLine__c.getRecordTypeInfosByName().get('M-A Intake Invoice Line').getRecordTypeId();
        blng__InvoiceLine__c singleinvline = new blng__InvoiceLine__c ();
        
        singleinvline.blng__Invoice__c = singleInv.id;
        //singleinvline.blng__OrderProduct__c = objOI.id;
        singleinvline.RecordtypeId = InvlineRecordTypeId ;
        singleinvline.blng__StartDate__c = date.today().addDays(-90);
        singleinvline.blng__EndDate__c = date.Today().addDays(+90);
        singleinvline.blng__UnitPrice__c = 100.00;
        singleinvline.blng__Quantity__c = 1;
        singleinvline.blng__TotalAmount__c = 100.00;
        singleinvline.blng__InvoiceLineStatus__c = 'Draft';
        //singleinvline.blng__OrderProduct__r.Usage_List_Price__c = 12;
        insert singleinvline;
        singleinvline.blng__TotalAmount__c = 200.00;
        Update singleinvline;
        acc.Contact_Email__c= 'abc@gmail.com';
        update acc;
        
        
        System.debug('SSSSSS ' + acc.Past_Due_Date__c +' DDDD ' + singleInv.blng__Balance__c + ' ss ' + singleInv.blng__DueDate__c );
        Test.startTest();
        Batch_DunningUpdateOnAccount btc=new Batch_DunningUpdateOnAccount();
        database.executebatch(btc,200);
        Batch_ToUpdatePastDueAmount bt=new Batch_ToUpdatePastDueAmount();
        database.executebatch(bt,200);
        Test.stopTest();
    }
}
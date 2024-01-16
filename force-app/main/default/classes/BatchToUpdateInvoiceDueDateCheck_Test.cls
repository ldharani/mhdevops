/***************
* Class Name: BatchToUpdateInvoiceDueDateCheck_Test
* Description: MHBS-9265 Customers with a past due balance but Past Due Balance Field = 0
* Developed By: Jeyamugundan
* Modification History : Created on May 25,2023* 
* ******/
@istest
public class BatchToUpdateInvoiceDueDateCheck_Test {
    static testMethod void testmethodA(){
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
        
        Test.startTest();
        BatchToUpdateInvoiceDueDateCheck btc=new BatchToUpdateInvoiceDueDateCheck();
        database.executebatch(btc,1);
        ScheduleBatchToUpdateInvoiceDueDateCheck obj=new ScheduleBatchToUpdateInvoiceDueDateCheck();
        System.schedule('ScheduleBatchToUpdateInvoiceDueDateCheck','0 0 8 13 2 ?', obj);
        Test.stopTest();
    }
}
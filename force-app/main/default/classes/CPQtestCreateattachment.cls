//class name   : creatingAttachmentsBatchTest
// author      : akash
// description : this class responsible for test coverage of batch class 
//               creatingAttachmentsBatch and its handler

@isTest(seeAllData = true)
public class CPQtestCreateattachment {
    
    static testmethod void run2condition(){
         MDL_UtilClass_TestClass util= new MDL_UtilClass_TestClass();
        
        //creating account
        account acc = new account();
        acc = util.getAccount();
        
        //creating single contact
        contact con = new contact();
        con = util.getContact(acc.Id);
        Id InvRecordTypeId = Schema.SObjectType.blng__Invoice__c.getRecordTypeInfosByName().get('M-A Intake Invoice').getRecordTypeId();
        
        //Create Invoice Run
        blng__InvoiceRun__c invoicerun = new blng__InvoiceRun__c ();
        invoicerun.Name ='Test';
        invoicerun.blng__Status__c = 'Started';
		invoicerun.blng__TargetDate__c = System.today();
        invoicerun.blng__StartTime__c =  System.now();
        insert   invoicerun;  
       
        //creating invoice
        blng__Invoice__c  singleInv = new blng__Invoice__c ();
        
        singleInv.blng__Account__c= acc.id;    
        singleInv.blng__DueDate__c = date.Today().addDays(-90);
        singleInv.RecordtypeId = InvRecordTypeId ;
        singleInv.blng__InvoiceDate__c = date.Today().addDays(-10);
        singleInv.blng__InvoiceRunCreatedBy__c = invoicerun.id;
        insert singleInv ;
        
        //singleInv = util.getInvoice(acc.Id);
        singleInv.blng__BillToContact__c    = con.id;
        singleInv.blng__TargetDate__c= date.today();
        singleInv.Delivery_Type__c= 'Email';
        singleInv.blng__InvoiceDate__c = date.newInstance(2016, 01, 01);
        update singleInv; 
        
        Attachment attach=new Attachment();    
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=singleInv.id;
        insert attach;

        
        List<blng__Invoice__c  > invlist = new List<blng__Invoice__c>();
        invlist.add(singleInv);
        
        CPQcreatingAttachmentsBatch classinstance = new CPQcreatingAttachmentsBatch(true,2016,01);
         CPQcreatingAttachmentsBatch classinstance1 = new CPQcreatingAttachmentsBatch(false,singleInv.Id);
        CPQcreatingAttachmentsBatch classinstance2 = new CPQcreatingAttachmentsBatch(false,2021,12);
        test.startTest();
         //testing for insert attachment operation
         Database.executeBatch(classinstance, 1);
        CPQcreateAttachmentsButton.CPQcreateAttachments(invoiceRun.Id, true) ;
        //Delete Attachments
        CPQcreateAttachmentsButton.CPQDeleteAttachements(invoiceRun.id);
        Database.executeBatch(classinstance2, 1);
        
        test.stopTest();       
        
    }
    
    
    

}
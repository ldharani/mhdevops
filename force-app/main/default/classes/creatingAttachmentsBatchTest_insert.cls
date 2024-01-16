//class name   : creatingAttachmentsBatchTest
// author      : akash
// description : this class responsible for test coverage of batch class 
//               creatingAttachmentsBatch and its handler

@isTest(seeAllData = true)
public class creatingAttachmentsBatchTest_insert {
    
    static testmethod void run2condition(){
         MDL_UtilClass_TestClass util= new MDL_UtilClass_TestClass();
        
        //creating account
        account acc = new account();
        acc = util.getAccount();
        
        //creating single contact
        contact con = new contact();
        con = util.getContact(acc.Id);
        
       
        //creating invoice
        invoiceit_s__Invoice__c singleInv = new invoiceit_s__Invoice__c();
        singleInv = util.getInvoice(acc.Id);
        singleInv.invoiceit_s__Billing_Contact__c = con.id;
        singleInv.invoiceit_s__Target_Date__c = date.today();
        singleInv.invoiceit_s__Delivery_Type__c = 'Email & Print';
        singleInv.invoiceit_s__Invoice_Date__c = date.newInstance(2016, 01, 01);
        update singleInv; 
        
        Attachment attach=new Attachment();    
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=singleInv.id;
        insert attach;

        
        List<invoiceit_s__Invoice__c> invlist = new List<invoiceit_s__Invoice__c>();
        invlist.add(singleInv);
        
        creatingAttachmentsBatch classinstance = new creatingAttachmentsBatch(true,2016,01);
        
        test.startTest();
         //testing for insert attachment operation
         Database.executeBatch(classinstance, 1);                
        test.stopTest();       
        
    }
    
/*    static testmethod void run3condition_runid() {
		MDL_UtilClass_TestClass util= new MDL_UtilClass_TestClass();
        
        //creating account
        account acc = new account();
        acc = util.getAccount();
        
        //creating single contact
        contact con = new contact();
        con = util.getContact(acc.Id);
        
        invoiceit_s__Invoice_Run__c invrun = new invoiceit_s__Invoice_Run__c();
        invrun.name = 'Test';
        insert invrun;
       
        system.debug('Invrun: ' + invrun.id);
        //creating invoice
        invoiceit_s__Invoice__c singleInv = new invoiceit_s__Invoice__c();
        singleInv = util.getInvoice(acc.Id);
        singleInv.invoiceit_s__Billing_Contact__c = con.id;
        singleInv.invoiceit_s__Target_Date__c = date.today();
        singleInv.invoiceit_s__Delivery_Type__c = 'Email & Print';
        singleInv.invoiceit_s__Invoice_Date__c = date.newInstance(2016, 01, 01);
        singleInv.invoiceit_s__Invoice_Run_Created_By__c = invrun.id;
        update singleInv; 
        
        Attachment attach=new Attachment();    
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=singleInv.id;
        insert attach;
        
        system.debug('Invrun: ' + invrun.id);
        creatingAttachmentsBatch classinstance = new creatingAttachmentsBatch(true, invrun.id);
		Test.startTest();
        Database.executeBatch(classinstance, 1);
		Test.stopTest();
        
        classinstance = new creatingAttachmentsBatch(false,invrun.id);
		Test.startTest();
        Database.executeBatch(classinstance, 1);
		Test.stopTest();
        
    }
*/    
    static testmethod void run2condition_delete(){
         MDL_UtilClass_TestClass util= new MDL_UtilClass_TestClass();
        
        //creating account
        account acc = new account();
        acc = util.getAccount();
        
        //creating single contact
        contact con = new contact();
        con = util.getContact(acc.Id);
        
        //creating invoice
        invoiceit_s__Invoice__c singleInv = new invoiceit_s__Invoice__c();
        singleInv = util.getInvoice(acc.Id);
        singleInv.invoiceit_s__Billing_Contact__c = con.id;
        singleInv.invoiceit_s__Target_Date__c = date.today();
        singleInv.invoiceit_s__Delivery_Type__c = 'Email & Print';
        singleInv.invoiceit_s__Invoice_Date__c = date.newInstance(2016, 01, 01);
        update singleInv; 
        
        Attachment attach=new Attachment();    
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=singleInv.id;
        insert attach;

        
        List<invoiceit_s__Invoice__c> invlist = new List<invoiceit_s__Invoice__c>();
        invlist.add(singleInv);
        
        creatingAttachmentsBatch classinstance_delete = new creatingAttachmentsBatch(false,2016,01);
        
        test.startTest();
        
        
         //testing for delete attachment operation
        
         Database.executeBatch(classinstance_delete, 1);
        test.stopTest();
    }

}
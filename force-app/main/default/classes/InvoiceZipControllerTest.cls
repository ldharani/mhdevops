// Author        : akash
// Description   : Test class for InvoiceZipController


@isTest(seealldata=true)
public class InvoiceZipControllerTest {
    
    static testmethod void run2condition(){
        
        MDL_UtilClass_TestClass testutil = new MDL_UtilClass_TestClass();
        
        //creating singe account
        account acc = testutil.getAccount();
        
        //creating single Invoice
        invoiceit_s__Invoice__c singleInv = testutil.getInvoice(acc.Id);
                
        List<attachment> attlist = new List<attachment>();        
        Attachment attach1       =new Attachment();      
        attach1.Name             ='Unit Test Attachment'; 
        Blob bodyBlob1           =Blob.valueOf('Unit Test Attachment Body'); 
        attach1.body             =bodyBlob1; 
        attach1.parentId         = singleInv.id;
        attlist.add(attach1);
        
        Attachment attach2       =new Attachment();      
        attach2.Name             ='Unit Test Attachment'; 
        Blob bodyBlob2           =Blob.valueOf('Unit Test Attachment Body'); 
        attach2.body             =bodyBlob2; 
        attach2.parentId         = singleInv.id;
        attlist.add(attach2);
        
        insert attlist;
        
        set<String>attIdset = new Set<String>(new Map<String, attachment>(attlist).keySet());
        String attId = '';
        for(String ids : attIdset){
            attId = attId + ','+ ids;  
        }
        
        //creating attachment History
        Attachments_History__c atthistory = new Attachments_History__c();
        atthistory.Name                   = attlist[0].Name;
        atthistory.Attachment_ID__c       = attlist[0].id;
        insert atthistory;
         
        InvoiceZipController invzip = new InvoiceZipController();
                
        List<SelectOption> opttest = invzip.getInvoicetypes();
        //invzip.getAttachments();
        InvoiceZipController.getAttachment(attId);
        
//        invzip.setRecordType('Nolo Invoice');
//        String rectype = invzip.getRecordType();
        invzip.uploadZip();
        invzip.FirstPage();
        invzip.next();
        invzip.previous();
        invzip.LastPage();
        invzip.getprev();
        invzip.getnxt();
        system.debug(Limits.getDMLStatements() +', '+ Limits.getLimitDMLStatements());

    }

}
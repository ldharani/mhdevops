//test class for class documentWebserviceLogicaldocCom: sai
  @isTest(SeeAllData=true)
public class documentWebservcLogicalDocTest {
    
 

    static testmethod void run2condition(){
        
        string sid;
        long folderid;
        string filename;
        //creating an single account
        account acc = new account(Name='test_123', MH_Cust_Number__c = '234567890',
                                   Logical_Doc__c = 'http://mhlogicdoc.martindale.com/?folderId=1234567');
        insert acc;
        
        //invoiceit_s__Currency__c singlecurrency = new invoiceit_s__Currency__c(Name = 'USD', invoiceit_s__Currency_Symbol__c = 'd');
        //insert singlecurrency;
        
        //invoiceit_s__Job__c singlejob = new invoiceit_s__Job__c(invoiceit_s__Account__c = acc.id, invoiceit_s__CurrencyL__c = singlecurrency.id,
                                                        //       Purchase_Order_Number__c = '12345');
        
        //inserting single invoice
        //
        //
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.invoiceit_s__Invoice__c; 
         Map<String,Schema.RecordTypeInfo> invoiceRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
          Id rtId = invoiceRecordTypeInfo.get(RecordTypesFinalStringsClass.RecTypeName_JV_Invoice).getRecordTypeId();


        LogicalDoc_Session__c singlesession = new LogicalDoc_Session__c(sid__c = '123456', User_Name__c = 'admin');
        insert singlesession;
        
        invoiceit_s__Invoice__c singleinv = new invoiceit_s__Invoice__c(invoiceit_s__Account__c = acc.Id, recordtypeid=rtId); 
        insert singleinv;                         
        
        test.startTest();
        NewdocumentWebserviceLogicaldocCom.DocumentServiceImplPort docservport = new NewdocumentWebserviceLogicaldocCom.DocumentServiceImplPort();
        Test.setMock(WebServiceMock.class, new webserviceMockImplListDocuments ());
        
        string folderurl = MDL_TriggerOnInvoice.createInvoiceFolderPath(singleinv.id);
        
        
        test.stopTest();
        
        
        //calling innerclasses
        NewdocumentWebserviceLogicaldocCom.wsLink docservport1 = new NewdocumentWebserviceLogicaldocCom.wsLink();
        NewdocumentWebserviceLogicaldocCom.createPdf docservport2 = new NewdocumentWebserviceLogicaldocCom.createPdf();
        NewdocumentWebserviceLogicaldocCom.rename docservport3 = new NewdocumentWebserviceLogicaldocCom.rename();
        NewdocumentWebserviceLogicaldocCom.getExtractedText docservport4 = new NewdocumentWebserviceLogicaldocCom.getExtractedText();
        NewdocumentWebserviceLogicaldocCom.getRecentDocuments docservport5 = new NewdocumentWebserviceLogicaldocCom.getRecentDocuments();
        NewdocumentWebserviceLogicaldocCom.unlockResponse docservport6 = new NewdocumentWebserviceLogicaldocCom.unlockResponse();
        NewdocumentWebserviceLogicaldocCom.getDocumentResponse docservport7 = new NewdocumentWebserviceLogicaldocCom.getDocumentResponse();
        NewdocumentWebserviceLogicaldocCom.Exception_x docservport8 = new NewdocumentWebserviceLogicaldocCom.Exception_x();
        NewdocumentWebserviceLogicaldocCom.deleteLink docservport9 = new NewdocumentWebserviceLogicaldocCom.deleteLink();
        NewdocumentWebserviceLogicaldocCom.createResponse docservport10 = new NewdocumentWebserviceLogicaldocCom.createResponse();
        NewdocumentWebserviceLogicaldocCom.restore docservport11 = new NewdocumentWebserviceLogicaldocCom.restore();
        NewdocumentWebserviceLogicaldocCom.getDocumentByCustomIdResponse docservport12 = new NewdocumentWebserviceLogicaldocCom.getDocumentByCustomIdResponse();
        NewdocumentWebserviceLogicaldocCom.renameFileResponse docservport13 = new NewdocumentWebserviceLogicaldocCom.renameFileResponse();
        NewdocumentWebserviceLogicaldocCom.move docservport14 = new NewdocumentWebserviceLogicaldocCom.move();
        NewdocumentWebserviceLogicaldocCom.checkoutResponse docservport15 = new  NewdocumentWebserviceLogicaldocCom.checkoutResponse();
        NewdocumentWebserviceLogicaldocCom.getDocumentByCustomId docservport16 = new NewdocumentWebserviceLogicaldocCom.getDocumentByCustomId();
        NewdocumentWebserviceLogicaldocCom.createAlias docservport17 = new NewdocumentWebserviceLogicaldocCom.createAlias();
        NewdocumentWebserviceLogicaldocCom.reindexResponse docservport18 = new NewdocumentWebserviceLogicaldocCom.reindexResponse();
        NewdocumentWebserviceLogicaldocCom.checkout docservport19 = new NewdocumentWebserviceLogicaldocCom.checkout();
        NewdocumentWebserviceLogicaldocCom.getVersionsResponse docservport20 = new NewdocumentWebserviceLogicaldocCom.getVersionsResponse();
        NewdocumentWebserviceLogicaldocCom.renameResponse docservport21 = new NewdocumentWebserviceLogicaldocCom.renameResponse();
        NewdocumentWebserviceLogicaldocCom.deleteResponse docservport22 = new NewdocumentWebserviceLogicaldocCom.deleteResponse();
        NewdocumentWebserviceLogicaldocCom.sendEmail docservport23 = new NewdocumentWebserviceLogicaldocCom.sendEmail();
        NewdocumentWebserviceLogicaldocCom.uploadResource docservport24 = new NewdocumentWebserviceLogicaldocCom.uploadResource();
        NewdocumentWebserviceLogicaldocCom.delete_x docservport25 = new NewdocumentWebserviceLogicaldocCom.delete_x();
        NewdocumentWebserviceLogicaldocCom.update_x docservport26 = new NewdocumentWebserviceLogicaldocCom.update_x();
        NewdocumentWebserviceLogicaldocCom.link docservport27 = new NewdocumentWebserviceLogicaldocCom.link();
        NewdocumentWebserviceLogicaldocCom.getContent docservport28 = new NewdocumentWebserviceLogicaldocCom.getContent();
        NewdocumentWebserviceLogicaldocCom.getLinks docservport29 = new NewdocumentWebserviceLogicaldocCom.getLinks();
        NewdocumentWebserviceLogicaldocCom.updateResponse docservport30 = new NewdocumentWebserviceLogicaldocCom.updateResponse();
        NewdocumentWebserviceLogicaldocCom.isReadable docservport31 = new NewdocumentWebserviceLogicaldocCom.isReadable();
        NewdocumentWebserviceLogicaldocCom.renameFile docservport32 = new NewdocumentWebserviceLogicaldocCom.renameFile();
        NewdocumentWebserviceLogicaldocCom.deleteLinkResponse docservport33 = new NewdocumentWebserviceLogicaldocCom.deleteLinkResponse();
        NewdocumentWebserviceLogicaldocCom.getRecentDocumentsResponse docservport34 = new NewdocumentWebserviceLogicaldocCom.getRecentDocumentsResponse();
        NewdocumentWebserviceLogicaldocCom.listResponse docservport35 = new NewdocumentWebserviceLogicaldocCom.listResponse();
        NewdocumentWebserviceLogicaldocCom.getVersionContent docservport36 = new NewdocumentWebserviceLogicaldocCom.getVersionContent();
        NewdocumentWebserviceLogicaldocCom.getLinksResponse docservport37 = new NewdocumentWebserviceLogicaldocCom.getLinksResponse();
        NewdocumentWebserviceLogicaldocCom.list_x docservport38 = new NewdocumentWebserviceLogicaldocCom.list_x();
        NewdocumentWebserviceLogicaldocCom.getExtractedTextResponse docservport39 = new NewdocumentWebserviceLogicaldocCom.getExtractedTextResponse();
        NewdocumentWebserviceLogicaldocCom.getResourceResponse docservport40 = new NewdocumentWebserviceLogicaldocCom.getResourceResponse();
        NewdocumentWebserviceLogicaldocCom.getContentResponse docservport41 = new NewdocumentWebserviceLogicaldocCom.getContentResponse();
        NewdocumentWebserviceLogicaldocCom.getDocuments docservport42 = new NewdocumentWebserviceLogicaldocCom.getDocuments();
        NewdocumentWebserviceLogicaldocCom.getDocument docservport43 = new NewdocumentWebserviceLogicaldocCom.getDocument();
        NewdocumentWebserviceLogicaldocCom.wsAttribute docservport44 = new NewdocumentWebserviceLogicaldocCom.wsAttribute();
        NewdocumentWebserviceLogicaldocCom.wsDocument docservport45 = new NewdocumentWebserviceLogicaldocCom.wsDocument();
        
        
        
        
        
    }

}
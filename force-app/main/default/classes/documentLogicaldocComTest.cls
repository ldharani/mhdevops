//test class for class documentWebserviceLogicaldocCom: sai
  @isTest(SeeAllData=true)
public class documentLogicaldocComTest {
    
 

    static testmethod void run2condition(){
        
        string sid;
        long folderid;
        string filename;
        //creating an single account
        account acc = new account(Name='test_123', MH_Cust_Number__c = '234567890',
                                   //Logical_Doc__c = 'http://mhlogicdoc.martindale.com/?folderId=1234567');
                                   Logical_Doc__c = system.label.logicaldoc_url+ '/display?folderId=1234567');
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
        
        AuthLogicaldocCom.SoapAuthServicePort authSrvpt = new AuthLogicaldocCom.SoapAuthServicePort();
        Test.setMock(WebServiceMock.class, new webServiceImplvalid());
        
        
        test.startTest();
        authSrvpt.valid(singlesession.sid__c );
        DocumentLogicaldoc.SoapDocumentServicePort docservport = new DocumentLogicaldoc.SoapDocumentServicePort();
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments ());
        
        string folderurl = MDL_TriggerOnInvoice.createInvoiceFolderPath(singleinv.id);
        
        
        test.stopTest();
        
        
        //calling innerclasses
        DocumentLogicaldoc.wsLink docservport1 = new DocumentLogicaldoc.wsLink();
        DocumentLogicaldoc.createPdf docservport2 = new DocumentLogicaldoc.createPdf();
        DocumentLogicaldoc.rename docservport3 = new DocumentLogicaldoc.rename();
        DocumentLogicaldoc.getExtractedText docservport4 = new DocumentLogicaldoc.getExtractedText();
        DocumentLogicaldoc.getRecentDocuments docservport5 = new DocumentLogicaldoc.getRecentDocuments();
        DocumentLogicaldoc.unlockResponse docservport6 = new DocumentLogicaldoc.unlockResponse();
        DocumentLogicaldoc.getDocumentResponse docservport7 = new DocumentLogicaldoc.getDocumentResponse();
        DocumentLogicaldoc.Exception_x docservport8 = new DocumentLogicaldoc.Exception_x();
        DocumentLogicaldoc.deleteLink docservport9 = new DocumentLogicaldoc.deleteLink();
        DocumentLogicaldoc.createResponse docservport10 = new DocumentLogicaldoc.createResponse();
        DocumentLogicaldoc.restore docservport11 = new DocumentLogicaldoc.restore();
        DocumentLogicaldoc.getDocumentByCustomIdResponse docservport12 = new DocumentLogicaldoc.getDocumentByCustomIdResponse();
        //documentLogicaldocCom.renameFileResponse docservport13 = new documentLogicaldocCom.renameFileResponse();
        DocumentLogicaldoc.move docservport14 = new DocumentLogicaldoc.move();
        DocumentLogicaldoc.checkoutResponse docservport15 = new  DocumentLogicaldoc.checkoutResponse();
        DocumentLogicaldoc.getDocumentByCustomId docservport16 = new DocumentLogicaldoc.getDocumentByCustomId();
        DocumentLogicaldoc.createAlias docservport17 = new DocumentLogicaldoc.createAlias();
        DocumentLogicaldoc.reindexResponse docservport18 = new DocumentLogicaldoc.reindexResponse();
        DocumentLogicaldoc.checkout docservport19 = new DocumentLogicaldoc.checkout();
        DocumentLogicaldoc.getVersionsResponse docservport20 = new DocumentLogicaldoc.getVersionsResponse();
        DocumentLogicaldoc.renameResponse docservport21 = new DocumentLogicaldoc.renameResponse();
        DocumentLogicaldoc.deleteResponse docservport22 = new DocumentLogicaldoc.deleteResponse();
        DocumentLogicaldoc.sendEmail docservport23 = new DocumentLogicaldoc.sendEmail();
        DocumentLogicaldoc.uploadResource docservport24 = new DocumentLogicaldoc.uploadResource();
        DocumentLogicaldoc.delete_x docservport25 = new DocumentLogicaldoc.delete_x();
        DocumentLogicaldoc.update_x docservport26 = new DocumentLogicaldoc.update_x();
        DocumentLogicaldoc.link docservport27 = new DocumentLogicaldoc.link();
        DocumentLogicaldoc.getContent docservport28 = new DocumentLogicaldoc.getContent();
        DocumentLogicaldoc.getLinks docservport29 = new DocumentLogicaldoc.getLinks();
        DocumentLogicaldoc.updateResponse docservport30 = new DocumentLogicaldoc.updateResponse();
        DocumentLogicaldoc.isReadable docservport31 = new DocumentLogicaldoc.isReadable();
        //documentLogicaldocCom.renameFile docservport32 = new documentLogicaldocCom.renameFile();
        DocumentLogicaldoc.deleteLinkResponse docservport33 = new DocumentLogicaldoc.deleteLinkResponse();
        DocumentLogicaldoc.getRecentDocumentsResponse docservport34 = new DocumentLogicaldoc.getRecentDocumentsResponse();
        //documentLogicaldocCom.listResponse docservport35 = new documentLogicaldocCom.listResponse();
        DocumentLogicaldoc.getVersionContent docservport36 = new DocumentLogicaldoc.getVersionContent();
        DocumentLogicaldoc.getLinksResponse docservport37 = new DocumentLogicaldoc.getLinksResponse();
        //documentLogicaldocCom.list_x docservport38 = new documentLogicaldocCom.list_x();
        DocumentLogicaldoc.getExtractedTextResponse docservport39 = new DocumentLogicaldoc.getExtractedTextResponse();
        DocumentLogicaldoc.getResourceResponse docservport40 = new DocumentLogicaldoc.getResourceResponse();
        DocumentLogicaldoc.getContentResponse docservport41 = new DocumentLogicaldoc.getContentResponse();
        DocumentLogicaldoc.getDocuments docservport42 = new DocumentLogicaldoc.getDocuments();
        DocumentLogicaldoc.getDocument docservport43 = new DocumentLogicaldoc.getDocument();
        DocumentLogicaldoc.wsAttribute docservport44 = new DocumentLogicaldoc.wsAttribute();
        DocumentLogicaldoc.wsDocument docservport45 = new DocumentLogicaldoc.wsDocument();
        
        
        
        
        
    }

    
    @isTest static void coverGeneratedCodeTypes() {
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc parentObject = new DocumentLogicaldoc();
        new DocumentLogicaldoc.addNote();
        new DocumentLogicaldoc.addNoteResponse();
        new DocumentLogicaldoc.checkin();
        new DocumentLogicaldoc.checkinResponse();
        new DocumentLogicaldoc.checkout();
        new DocumentLogicaldoc.checkoutResponse();
        new DocumentLogicaldoc.create();
        new DocumentLogicaldoc.createAlias();
        new DocumentLogicaldoc.createAliasResponse();
        new DocumentLogicaldoc.createDownloadTicket();
        new DocumentLogicaldoc.createDownloadTicketResponse();
        new DocumentLogicaldoc.createPdf();
        new DocumentLogicaldoc.createPdfResponse();
        new DocumentLogicaldoc.createResponse();
        new DocumentLogicaldoc.createThumbnail();
        new DocumentLogicaldoc.createThumbnailResponse();
        new DocumentLogicaldoc.delete_x();
        new DocumentLogicaldoc.deleteLink();
        new DocumentLogicaldoc.deleteLinkResponse();
        new DocumentLogicaldoc.deleteNote();
        new DocumentLogicaldoc.deleteNoteResponse();
        new DocumentLogicaldoc.deleteResponse();
        new DocumentLogicaldoc.deleteVersion();
        new DocumentLogicaldoc.deleteVersionResponse();
        new DocumentLogicaldoc.Exception_x();
        new DocumentLogicaldoc.getAliases();
        new DocumentLogicaldoc.getAliasesResponse();
        new DocumentLogicaldoc.getContent();
        new DocumentLogicaldoc.getContentResponse();
        new DocumentLogicaldoc.getDocument();
        new DocumentLogicaldoc.getDocumentByCustomId();
        new DocumentLogicaldoc.getDocumentByCustomIdResponse();
        new DocumentLogicaldoc.getDocumentResponse();
        new DocumentLogicaldoc.getDocuments();
        new DocumentLogicaldoc.getDocumentsResponse();
        new DocumentLogicaldoc.getExtractedText();
        new DocumentLogicaldoc.getExtractedTextResponse();
        new DocumentLogicaldoc.getLinks();
        new DocumentLogicaldoc.getLinksResponse();
        new DocumentLogicaldoc.getNotes();
        new DocumentLogicaldoc.getNotesResponse();
        new DocumentLogicaldoc.getRatings();
        new DocumentLogicaldoc.getRatingsResponse();
        new DocumentLogicaldoc.getRecentDocuments();
        new DocumentLogicaldoc.getRecentDocumentsResponse();
        new DocumentLogicaldoc.getResource();
        new DocumentLogicaldoc.getResourceResponse();
        new DocumentLogicaldoc.getVersionContent();
        new DocumentLogicaldoc.getVersionContentResponse();
        new DocumentLogicaldoc.getVersions();
        new DocumentLogicaldoc.getVersionsResponse();
        new DocumentLogicaldoc.isReadable();
        new DocumentLogicaldoc.isReadableResponse();
        new DocumentLogicaldoc.link();
        new DocumentLogicaldoc.linkResponse();
        new DocumentLogicaldoc.listDocuments();
        new DocumentLogicaldoc.listDocumentsResponse();
        new DocumentLogicaldoc.lock();
        new DocumentLogicaldoc.lockResponse();
        new DocumentLogicaldoc.move();
        new DocumentLogicaldoc.moveResponse();
        new DocumentLogicaldoc.rateDocument();
        new DocumentLogicaldoc.rateDocumentResponse();
        new DocumentLogicaldoc.reindex();
        new DocumentLogicaldoc.reindexResponse();
        new DocumentLogicaldoc.rename();
        new DocumentLogicaldoc.renameResponse();
        new DocumentLogicaldoc.restore();
        new DocumentLogicaldoc.restoreResponse();
        new DocumentLogicaldoc.sendEmail();
        new DocumentLogicaldoc.sendEmailResponse();
        new DocumentLogicaldoc.setPassword();
        new DocumentLogicaldoc.setPasswordResponse();
        new DocumentLogicaldoc.unlock();
        new DocumentLogicaldoc.unlockResponse();
        new DocumentLogicaldoc.unprotect();
        new DocumentLogicaldoc.unprotectResponse();
        new DocumentLogicaldoc.unsetPassword();
        new DocumentLogicaldoc.unsetPasswordResponse();
        new DocumentLogicaldoc.update_x();
        new DocumentLogicaldoc.updateResponse();
        new DocumentLogicaldoc.upload();
        new DocumentLogicaldoc.uploadResource();
        new DocumentLogicaldoc.uploadResourceResponse();
        new DocumentLogicaldoc.uploadResponse();
        new DocumentLogicaldoc.WSAttribute();
        new DocumentLogicaldoc.WSDocument();
        new DocumentLogicaldoc.WSLink();
        new DocumentLogicaldoc.WSNote();
        new DocumentLogicaldoc.WSRating();
    }
    @isTest static void coverCodeForaddNote(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.addNote(null, null, null));
    }
    @isTest static void coverCodeForcheckin(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        testObject.checkin(null, null, null, null, null, null);
    }
    @isTest static void coverCodeForcheckout(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        testObject.checkout(null, null);
    }
    @isTest static void coverCodeForcreate(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.create(null, null, null));
    }
    @isTest static void coverCodeForcreateAlias(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.createAlias(null, null, null, null));
    }
    @isTest static void coverCodeForcreateDownloadTicket(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.createDownloadTicket(null, null, null, null, null));
    }
    @isTest static void coverCodeForcreatePdf(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        testObject.createPdf(null, null, null);
    }
    @isTest static void coverCodeForcreateThumbnail(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        testObject.createThumbnail(null, null, null);
    }
    @isTest static void coverCodeFordelete_x(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        testObject.delete_x(null, null);
    }
    @isTest static void coverCodeFordeleteLink(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        testObject.deleteLink(null, null);
    }
    @isTest static void coverCodeFordeleteNote(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        testObject.deleteNote(null, null);
    }
    @isTest static void coverCodeFordeleteVersion(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.deleteVersion(null, null, null));
    }
    @isTest static void coverCodeForgetAliases(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.getAliases(null, null));
    }
    @isTest static void coverCodeForgetContent(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.getContent(null, null));
    }
    @isTest static void coverCodeForgetDocument(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.getDocument(null, null));
    }
    @isTest static void coverCodeForgetDocumentByCustomId(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.getDocumentByCustomId(null, null));
    }
    @isTest static void coverCodeForgetDocuments(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.getDocuments(null, null));
    }
    @isTest static void coverCodeForgetExtractedText(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.getExtractedText(null, null));
    }
    @isTest static void coverCodeForgetLinks(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.getLinks(null, null));
    }
    @isTest static void coverCodeForgetNotes(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.getNotes(null, null));
    }
    @isTest static void coverCodeForgetRatings(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.getRatings(null, null));
    }
    @isTest static void coverCodeForgetRecentDocuments(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.getRecentDocuments(null, null));
    }
    @isTest static void coverCodeForgetResource(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.getResource(null, null, null, null));
    }
    @isTest static void coverCodeForgetVersionContent(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.getVersionContent(null, null, null));
    }
    @isTest static void coverCodeForgetVersions(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.getVersions(null, null));
    }
    @isTest static void coverCodeForisReadable(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.isReadable(null, null));
    }
    @isTest static void coverCodeForlink(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.link(null, null, null, null));
    }
    @isTest static void coverCodeForlistDocuments(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.listDocuments(null, null, null));
    }
    @isTest static void coverCodeForlock(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        testObject.lock(null, null);
    }
    @isTest static void coverCodeFormove(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        testObject.move(null, null, null);
    }
    @isTest static void coverCodeForrateDocument(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.rateDocument(null, null, null));
    }
    @isTest static void coverCodeForreindex(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        testObject.reindex(null, null, null);
    }
    @isTest static void coverCodeForrename(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        testObject.rename(null, null, null);
    }
    @isTest static void coverCodeForrestore(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        testObject.restore(null, null, null);
    }
    @isTest static void coverCodeForsendEmail(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        testObject.sendEmail(null, null, null, null, null);
    }
    @isTest static void coverCodeForsetPassword(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        testObject.setPassword(null, null, null);
    }
    @isTest static void coverCodeForunlock(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        testObject.unlock(null, null);
    }
    @isTest static void coverCodeForunprotect(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.unprotect(null, null, null));
    }
    @isTest static void coverCodeForunsetPassword(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        testObject.unsetPassword(null, null, null);
    }
    @isTest static void coverCodeForupdate_x(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        testObject.update_x(null, null);
    }
    @isTest static void coverCodeForupload(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        System.assertEquals(null, testObject.upload(null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForuploadResource(){
        Test.setMock(WebServiceMock.class, new webserviceImplListDocuments());
        DocumentLogicaldoc.SoapDocumentServicePort testObject = new DocumentLogicaldoc.SoapDocumentServicePort();
        testObject.uploadResource(null, null, null, null, null);
    }
}
//list documents call out mock reponse class: sai
@isTest  
global class webserviceImplListDocuments implements WebServiceMock {  
   global void doInvoke(  
           Object stub,  
           Object request,  
           Map<string, object> response,  
           String endpoint,  
           String soapAction,  
           String requestName,  
           String responseNS,  
           String responseName,  
           String responseType) {  
      /* documentLogicaldocCom.listDocumentsResponse respElement = new documentLogicaldocCom.listDocumentsResponse();  
       respElement.document = null;  
       response.put('response_x', respElement); */
               
       if(request instanceOf DocumentLogicaldoc.addNote) {
            response.put( 'response_x', new DocumentLogicaldoc.addNoteResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.checkin) {
            response.put( 'response_x', new DocumentLogicaldoc.checkinResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.checkout) {
            response.put( 'response_x', new DocumentLogicaldoc.checkoutResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.create) {
            response.put( 'response_x', new DocumentLogicaldoc.createResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.createAlias) {
            response.put( 'response_x', new DocumentLogicaldoc.createAliasResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.createDownloadTicket) {
            response.put( 'response_x', new DocumentLogicaldoc.createDownloadTicketResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.createPdf) {
            response.put( 'response_x', new DocumentLogicaldoc.createPdfResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.createThumbnail) {
            response.put( 'response_x', new DocumentLogicaldoc.createThumbnailResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.delete_x) {
            response.put( 'response_x', new DocumentLogicaldoc.deleteResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.deleteLink) {
            response.put( 'response_x', new DocumentLogicaldoc.deleteLinkResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.deleteNote) {
            response.put( 'response_x', new DocumentLogicaldoc.deleteNoteResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.deleteVersion) {
            response.put( 'response_x', new DocumentLogicaldoc.deleteVersionResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.getAliases) {
            response.put( 'response_x', new DocumentLogicaldoc.getAliasesResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.getContent) {
            response.put( 'response_x', new DocumentLogicaldoc.getContentResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.getDocument) {
            response.put( 'response_x', new DocumentLogicaldoc.getDocumentResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.getDocumentByCustomId) {
            response.put( 'response_x', new DocumentLogicaldoc.getDocumentByCustomIdResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.getDocuments) {
            response.put( 'response_x', new DocumentLogicaldoc.getDocumentsResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.getExtractedText) {
            response.put( 'response_x', new DocumentLogicaldoc.getExtractedTextResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.getLinks) {
            response.put( 'response_x', new DocumentLogicaldoc.getLinksResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.getNotes) {
            response.put( 'response_x', new DocumentLogicaldoc.getNotesResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.getRatings) {
            response.put( 'response_x', new DocumentLogicaldoc.getRatingsResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.getRecentDocuments) {
            response.put( 'response_x', new DocumentLogicaldoc.getRecentDocumentsResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.getResource) {
            response.put( 'response_x', new DocumentLogicaldoc.getResourceResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.getVersionContent) {
            response.put( 'response_x', new DocumentLogicaldoc.getVersionContentResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.getVersions) {
            response.put( 'response_x', new DocumentLogicaldoc.getVersionsResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.isReadable) {
            response.put( 'response_x', new DocumentLogicaldoc.isReadableResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.link) {
            response.put( 'response_x', new DocumentLogicaldoc.linkResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.listDocuments) {
            response.put( 'response_x', new DocumentLogicaldoc.listDocumentsResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.lock) {
            response.put( 'response_x', new DocumentLogicaldoc.lockResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.move) {
            response.put( 'response_x', new DocumentLogicaldoc.moveResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.rateDocument) {
            response.put( 'response_x', new DocumentLogicaldoc.rateDocumentResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.reindex) {
            response.put( 'response_x', new DocumentLogicaldoc.reindexResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.rename) {
            response.put( 'response_x', new DocumentLogicaldoc.renameResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.restore) {
            response.put( 'response_x', new DocumentLogicaldoc.restoreResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.sendEmail) {
            response.put( 'response_x', new DocumentLogicaldoc.sendEmailResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.setPassword) {
            response.put( 'response_x', new DocumentLogicaldoc.setPasswordResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.unlock) {
            response.put( 'response_x', new DocumentLogicaldoc.unlockResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.unprotect) {
            response.put( 'response_x', new DocumentLogicaldoc.unprotectResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.unsetPassword) {
            response.put( 'response_x', new DocumentLogicaldoc.unsetPasswordResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.update_x) {
            response.put( 'response_x', new DocumentLogicaldoc.updateResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.upload) {
            response.put( 'response_x', new DocumentLogicaldoc.uploadResponse());
        }
        else if(request instanceOf DocumentLogicaldoc.uploadResource) {
            response.put( 'response_x', new DocumentLogicaldoc.uploadResourceResponse());
        }        
               
   }  
}
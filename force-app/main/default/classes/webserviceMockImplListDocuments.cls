//list documents call out mock reponse class: sai
@isTest  
global class webserviceMockImplListDocuments implements WebServiceMock {  
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
       NewdocumentWebserviceLogicaldocCom.listDocumentsResponse respElement = new NewdocumentWebserviceLogicaldocCom.listDocumentsResponse();  
       respElement.document = null;  
       response.put('response_x', respElement);   
   }  
}
//list children call out mock reponse class: sai
@isTest  
global class WebServiceMockImplwsfolder implements WebServiceMock {  
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
       NewfolderWebserviceLogicaldocCom.listChildrenResponse respElement = new NewfolderWebserviceLogicaldocCom.listChildrenResponse();  
       respElement.folder = null;  
       response.put('response_x', respElement);   
   }  
}
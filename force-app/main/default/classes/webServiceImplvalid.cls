//valid callout mock reponse class : sai
@isTest  
global class webServiceImplvalid implements WebServiceMock {  
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
       AuthLogicaldocCom.validResponse respElement = new AuthLogicaldocCom.validResponse();  
       respElement.return_x = null;  
       response.put('response_x', respElement);    
   }  
}
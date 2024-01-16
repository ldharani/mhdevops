//renew callout mock reponse class : sai
@isTest  
global class webServiceImplrenew implements WebServiceMock {  
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
       AuthLogicaldocCom.renewResponse respElement = new AuthLogicaldocCom.renewResponse();  
       //respElement.return_x = null;  
       response.put('response_x', respElement);    
   }  
}
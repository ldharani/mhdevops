//Login callout mock reponse class : sai
@isTest  
global class webServiceMockImplLogin implements WebServiceMock {  
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
       authWebserviceLogicaldocCom.loginResponse respElement = new authWebserviceLogicaldocCom.loginResponse();  
       respElement.return_x = null;  
       response.put('response_x', respElement);   
   }  
}
//Logout callout mock reponse class : sai
@isTest  
global class webServiceImplLogout implements WebServiceMock {  
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
       AuthLogicaldocCom.logoutResponse respElement = new AuthLogicaldocCom.logoutResponse();  
       //respElement.return_x = null;  
       response.put('response_x', respElement);    
   }  
}
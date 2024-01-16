//Logout callout mock reponse class : sai
@isTest  
global class webServiceMockImplLogout implements WebServiceMock {  
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
       authWebserviceLogicaldocCom.logoutResponse respElement = new authWebserviceLogicaldocCom.logoutResponse();  
       //respElement.return_x = null;  
       response.put('response_x', respElement);    
   }  
}
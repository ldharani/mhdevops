//findby path callout mock reponse class : sai
@isTest  
global class WebServiceImplwsfind implements WebServiceMock {  
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
       folderLogicaldocCom.findByPathResponse respElement = new folderLogicaldocCom.findByPathResponse();  
       respElement.folder = null;  
       response.put('response_x', respElement);   
   }  
}
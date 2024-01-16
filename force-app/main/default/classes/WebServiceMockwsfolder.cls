//list children call out mock reponse class: sai
@isTest  
global class WebServiceMockwsfolder implements WebServiceMock {  
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
       /* Commented on 3-12-2019
        folderLogicaldocCom.listChildrenResponse respElement = new folderLogicaldocCom.listChildrenResponse();  
       respElement.folder = null;  
       response.put('response_x', respElement); 
*/
    if(request instanceOf folderLogicaldocCom.copy) {
            response.put( 'response_x', new folderLogicaldocCom.copyResponse());
        }
        else if(request instanceOf folderLogicaldocCom.create) {
            response.put( 'response_x', new folderLogicaldocCom.createResponse());
        }
        else if(request instanceOf folderLogicaldocCom.createAlias) {
            response.put( 'response_x', new folderLogicaldocCom.createAliasResponse());
        }
        else if(request instanceOf folderLogicaldocCom.createFolder) {
            response.put( 'response_x', new folderLogicaldocCom.createFolderResponse());
        }
        else if(request instanceOf folderLogicaldocCom.createPath) {
            response.put( 'response_x', new folderLogicaldocCom.createPathResponse());
        }
        else if(request instanceOf folderLogicaldocCom.delete_x) {
            response.put( 'response_x', new folderLogicaldocCom.deleteResponse());
        }
        else if(request instanceOf folderLogicaldocCom.findByPath) {
            response.put( 'response_x', new folderLogicaldocCom.findByPathResponse());
        }
        else if(request instanceOf folderLogicaldocCom.getDefaultWorkspace) {
            response.put( 'response_x', new folderLogicaldocCom.getDefaultWorkspaceResponse());
        }
        else if(request instanceOf folderLogicaldocCom.getFolder) {
            response.put( 'response_x', new folderLogicaldocCom.getFolderResponse());
        }
        else if(request instanceOf folderLogicaldocCom.getGrantedGroups) {
            response.put( 'response_x', new folderLogicaldocCom.getGrantedGroupsResponse());
        }
        else if(request instanceOf folderLogicaldocCom.getGrantedUsers) {
            response.put( 'response_x', new folderLogicaldocCom.getGrantedUsersResponse());
        }
        else if(request instanceOf folderLogicaldocCom.getPath) {
            response.put( 'response_x', new folderLogicaldocCom.getPathResponse());
        }
        else if(request instanceOf folderLogicaldocCom.getRootFolder) {
            response.put( 'response_x', new folderLogicaldocCom.getRootFolderResponse());
        }
        else if(request instanceOf folderLogicaldocCom.grantGroup) {
            response.put( 'response_x', new folderLogicaldocCom.grantGroupResponse());
        }
        else if(request instanceOf folderLogicaldocCom.grantUser) {
            response.put( 'response_x', new folderLogicaldocCom.grantUserResponse());
        }
        else if(request instanceOf folderLogicaldocCom.isGranted) {
            response.put( 'response_x', new folderLogicaldocCom.isGrantedResponse());
        }
        else if(request instanceOf folderLogicaldocCom.isReadable) {
            response.put( 'response_x', new folderLogicaldocCom.isReadableResponse());
        }
        else if(request instanceOf folderLogicaldocCom.isWriteable) {
            response.put( 'response_x', new folderLogicaldocCom.isWriteableResponse());
        }
        else if(request instanceOf folderLogicaldocCom.listChildren) {
            response.put( 'response_x', new folderLogicaldocCom.listChildrenResponse());
        }
        else if(request instanceOf folderLogicaldocCom.listWorkspaces) {
            response.put( 'response_x', new folderLogicaldocCom.listWorkspacesResponse());
        }
        else if(request instanceOf folderLogicaldocCom.move) {
            response.put( 'response_x', new folderLogicaldocCom.moveResponse());
        }
        else if(request instanceOf folderLogicaldocCom.rename) {
            response.put( 'response_x', new folderLogicaldocCom.renameResponse());
        }
        else if(request instanceOf folderLogicaldocCom.update_x) {
            response.put( 'response_x', new folderLogicaldocCom.updateResponse());
        }           
               
   }  
}
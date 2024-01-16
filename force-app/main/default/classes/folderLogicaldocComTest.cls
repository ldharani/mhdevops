// test class for NewfolderWebserviceLogicaldocCom class : sai
@isTest
public class folderLogicaldocComTest {
    
    //testing list children call out
    /*static testmethod void run2condition(){
        
          id newId;
        Long templong;
        
        folderLogicaldocCom.SoapFolderServicePort websrvcCls = new folderLogicaldocCom.SoapFolderServicePort();
        Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
        
        // it needs WebServiceMockImplwsfolder class for fake response
        folderLogicaldocCom.wsFolder[] resp = websrvcCls.listChildren(newId, templong);

        
       
         
        
       
        
        folderLogicaldocCom.findByPath websrvcCls1 = new folderLogicaldocCom.findByPath();
        folderLogicaldocCom.findByPathResponse websrvcCls2 = new folderLogicaldocCom.findByPathResponse();
        folderLogicaldocCom.getRootFolderResponse websrvcCls3 = new folderLogicaldocCom.getRootFolderResponse();
        folderLogicaldocCom.wsAttribute websrvcCls4 = new folderLogicaldocCom.wsAttribute();
        folderLogicaldocCom.wsFolder websrvcCls6 = new folderLogicaldocCom.wsFolder();
        folderLogicaldocCom.listChildrenResponse websrvcCls5 = new folderLogicaldocCom.listChildrenResponse();
        
    }
    
    // testing find by path callout
    static testmethod void run2condition1(){
        string sid;
        string path;
         folderLogicaldocCom.SoapFolderServicePort websrvcCls = new folderLogicaldocCom.SoapFolderServicePort();
       
        Test.setMock(WebServiceMock.class, new WebServiceImplwsfind ());
       // it needs WebServiceMockImplwsfind class for fake response
        folderLogicaldocCom.wsFolder resp1 = websrvcCls.findByPath(sid, path);
        
    }
*/

    
    @isTest static void coverGeneratedCodeTypes() {
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom parentObject = new folderLogicaldocCom();
		new folderLogicaldocCom.copy();
		new folderLogicaldocCom.copyResponse();
		new folderLogicaldocCom.create();
		new folderLogicaldocCom.createAlias();
		new folderLogicaldocCom.createAliasResponse();
		new folderLogicaldocCom.createFolder();
		new folderLogicaldocCom.createFolderResponse();
		new folderLogicaldocCom.createPath();
		new folderLogicaldocCom.createPathResponse();
		new folderLogicaldocCom.createResponse();
		new folderLogicaldocCom.delete_x();
		new folderLogicaldocCom.deleteResponse();
		new folderLogicaldocCom.Exception_x();
		new folderLogicaldocCom.findByPath();
		new folderLogicaldocCom.findByPathResponse();
		new folderLogicaldocCom.getDefaultWorkspace();
		new folderLogicaldocCom.getDefaultWorkspaceResponse();
		new folderLogicaldocCom.getFolder();
		new folderLogicaldocCom.getFolderResponse();
		new folderLogicaldocCom.getGrantedGroups();
		new folderLogicaldocCom.getGrantedGroupsResponse();
		new folderLogicaldocCom.getGrantedUsers();
		new folderLogicaldocCom.getGrantedUsersResponse();
		new folderLogicaldocCom.getPath();
		new folderLogicaldocCom.getPathResponse();
		new folderLogicaldocCom.getRootFolder();
		new folderLogicaldocCom.getRootFolderResponse();
		new folderLogicaldocCom.grantGroup();
		new folderLogicaldocCom.grantGroupResponse();
		new folderLogicaldocCom.grantUser();
		new folderLogicaldocCom.grantUserResponse();
		new folderLogicaldocCom.isGranted();
		new folderLogicaldocCom.isGrantedResponse();
		new folderLogicaldocCom.isReadable();
		new folderLogicaldocCom.isReadableResponse();
		new folderLogicaldocCom.isWriteable();
		new folderLogicaldocCom.isWriteableResponse();
		new folderLogicaldocCom.listChildren();
		new folderLogicaldocCom.listChildrenResponse();
		new folderLogicaldocCom.listWorkspaces();
		new folderLogicaldocCom.listWorkspacesResponse();
		new folderLogicaldocCom.move();
		new folderLogicaldocCom.moveResponse();
		new folderLogicaldocCom.rename();
		new folderLogicaldocCom.renameResponse();
		new folderLogicaldocCom.update_x();
		new folderLogicaldocCom.updateResponse();
		new folderLogicaldocCom.WSAttribute();
		new folderLogicaldocCom.WSFolder();
		new folderLogicaldocCom.WSRight();
	}
	@isTest static void coverCodeForcopy(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		testObject.copy(null, null, null, null, null);
	}
	@isTest static void coverCodeForcreate(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		System.assertEquals(null, testObject.create(null, null));
	}
	@isTest static void coverCodeForcreateAlias(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		System.assertEquals(null, testObject.createAlias(null, null, null));
	}
	@isTest static void coverCodeForcreateFolder(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		System.assertEquals(null, testObject.createFolder(null, null, null));
	}
	@isTest static void coverCodeForcreatePath(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		System.assertEquals(null, testObject.createPath(null, null, null));
	}
	@isTest static void coverCodeFordelete_x(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		testObject.delete_x(null, null);
	}
	@isTest static void coverCodeForfindByPath(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		System.assertEquals(null, testObject.findByPath(null, null));
	}
	@isTest static void coverCodeForgetDefaultWorkspace(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		System.assertEquals(null, testObject.getDefaultWorkspace(null));
	}
	@isTest static void coverCodeForgetFolder(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		System.assertEquals(null, testObject.getFolder(null, null));
	}
	@isTest static void coverCodeForgetGrantedGroups(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		System.assertEquals(null, testObject.getGrantedGroups(null, null));
	}
	@isTest static void coverCodeForgetGrantedUsers(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		System.assertEquals(null, testObject.getGrantedUsers(null, null));
	}
	@isTest static void coverCodeForgetPath(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		System.assertEquals(null, testObject.getPath(null, null));
	}
	@isTest static void coverCodeForgetRootFolder(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		System.assertEquals(null, testObject.getRootFolder(null));
	}
	@isTest static void coverCodeForgrantGroup(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		testObject.grantGroup(null, null, null, null, null);
	}
	@isTest static void coverCodeForgrantUser(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		testObject.grantUser(null, null, null, null, null);
	}
	@isTest static void coverCodeForisGranted(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		System.assertEquals(null, testObject.isGranted(null, null, null));
	}
	@isTest static void coverCodeForisReadable(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		System.assertEquals(null, testObject.isReadable(null, null));
	}
	@isTest static void coverCodeForisWriteable(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		System.assertEquals(null, testObject.isWriteable(null, null));
	}
	@isTest static void coverCodeForlistChildren(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		System.assertEquals(null, testObject.listChildren(null, null));
	}
	@isTest static void coverCodeForlistWorkspaces(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		System.assertEquals(null, testObject.listWorkspaces(null));
	}
	@isTest static void coverCodeFormove(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		testObject.move(null, null, null);
	}
	@isTest static void coverCodeForrename(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		testObject.rename(null, null, null);
	}
	@isTest static void coverCodeForupdate_x(){
		Test.setMock(WebServiceMock.class, new WebServiceMockwsfolder());
		folderLogicaldocCom.SoapFolderServicePort testObject = new folderLogicaldocCom.SoapFolderServicePort();
		testObject.update_x(null, null);
	}
    
}
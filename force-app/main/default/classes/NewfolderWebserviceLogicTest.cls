// test class for NewfolderWebserviceLogicaldocCom class : sai
@isTest
public class NewfolderWebserviceLogicTest {
    
    //testing list children call out
    static testmethod void run2condition(){
        
          id newId;
        Long templong;
        
        NewfolderWebserviceLogicaldocCom.FolderServiceImplPort websrvcCls = new NewfolderWebserviceLogicaldocCom.FolderServiceImplPort();
        Test.setMock(WebServiceMock.class, new WebServiceMockImplwsfolder ());
        
        // it needs WebServiceMockImplwsfolder class for fake response
        NewfolderWebserviceLogicaldocCom.wsFolder[] resp = websrvcCls.listChildren(newId, templong);

        
       
         
        
       
        
        NewfolderWebserviceLogicaldocCom.findByPath websrvcCls1 = new NewfolderWebserviceLogicaldocCom.findByPath();
        NewfolderWebserviceLogicaldocCom.findByPathResponse websrvcCls2 = new NewfolderWebserviceLogicaldocCom.findByPathResponse();
        NewfolderWebserviceLogicaldocCom.getRootFolderResponse websrvcCls3 = new NewfolderWebserviceLogicaldocCom.getRootFolderResponse();
        NewfolderWebserviceLogicaldocCom.wsAttribute websrvcCls4 = new NewfolderWebserviceLogicaldocCom.wsAttribute();
        NewfolderWebserviceLogicaldocCom.wsFolder websrvcCls6 = new NewfolderWebserviceLogicaldocCom.wsFolder();
        NewfolderWebserviceLogicaldocCom.listChildrenResponse websrvcCls5 = new NewfolderWebserviceLogicaldocCom.listChildrenResponse();
        
    }
    
    // testing find by path callout
    static testmethod void run2condition1(){
        string sid;
        string path;
         NewfolderWebserviceLogicaldocCom.FolderServiceImplPort websrvcCls = new NewfolderWebserviceLogicaldocCom.FolderServiceImplPort();
       
        Test.setMock(WebServiceMock.class, new WebServiceMockImplwsfind ());
       // it needs WebServiceMockImplwsfind class for fake response
        NewfolderWebserviceLogicaldocCom.wsFolder resp1 = websrvcCls.findByPath(sid, path);
        
    }

}
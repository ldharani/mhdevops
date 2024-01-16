//test class for authwebserviceLogicaldocCom class : sai
@isTest
public class authWebserviceLogicaldocTest {
    
    //testing login callout
    static testmethod void run2condition(){
        
        string uid;
        string pwd;
        authWebserviceLogicaldocCom.AuthServiceImplPort authSrvptl = new authWebserviceLogicaldocCom.AuthServiceImplPort();
        Test.setMock(WebServiceMock.class, new webServiceMockImplLogin ());
        authSrvptl.login(uid,pwd);
            
    }
    
    
    //testing logout call out
    static testmethod void run2condition1(){
        
        string sid;
      
        authWebserviceLogicaldocCom.AuthServiceImplPort authSrvptl = new authWebserviceLogicaldocCom.AuthServiceImplPort();
        Test.setMock(WebServiceMock.class, new webServiceMockImplLogout ());
        authSrvptl.logout(sid);
            
    }
    
    //testing valid call out
    static testmethod void run2condition2(){
        
        string sid;
      
        authWebserviceLogicaldocCom.AuthServiceImplPort authSrvptl = new authWebserviceLogicaldocCom.AuthServiceImplPort();
        Test.setMock(WebServiceMock.class, new webServiceMockImplvalid ());
        authSrvptl.valid(sid);
            
    }
    
    //testing valid call out
    static testmethod void run2condition3(){
        
        string sid;
      
        authWebserviceLogicaldocCom.AuthServiceImplPort authSrvptl = new authWebserviceLogicaldocCom.AuthServiceImplPort();
        Test.setMock(WebServiceMock.class, new webServiceMockImplrenew ());
        authSrvptl.renew(sid);
            
    }
}
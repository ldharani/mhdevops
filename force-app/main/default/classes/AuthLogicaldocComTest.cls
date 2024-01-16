//test class for authwebserviceLogicaldocCom class : sai
@isTest
public class AuthLogicaldocComTest {
    
    //testing login callout
    static testmethod void run2condition(){
        
        string uid;
        string pwd;
        /*
        Set<Id> acctids= new Set<Id>();
        //creating an single account
        id rectypeforNolo = Schema.SObjectType.account.RecordTypeInfosByName.get(RecordTypesFinalStringsClass.RecTypeName_MH_Account ).RecordTypeId;
        account acc = new account(Name='test_123', MH_Cust_Number__c = '234567890',
                                   RecordTypeId = rectypeforNolo, Logical_Doc__c = '');
        insert acc;
        
        acctids.add(acc.id);*/
        
        AuthLogicaldocCom.SoapAuthServicePort authSrvptl = new AuthLogicaldocCom.SoapAuthServicePort ();
        Test.setMock(WebServiceMock.class, new webServiceImplLogin());
        authSrvptl.login(uid,pwd);
        
       // MDL_TriggerHandlerForAccount.createInvoiceFolderPath(acctids);   
       
    }
    
    
    //testing logout call out
    static testmethod void run2condition1(){
        
        string sid;
      
        AuthLogicaldocCom.SoapAuthServicePort authSrvptl = new AuthLogicaldocCom.SoapAuthServicePort();
        Test.setMock(WebServiceMock.class, new webServiceImplLogout());
        authSrvptl.logout(sid);
            
    }
    
    //testing valid call out
    static testmethod void run2condition2(){
        
        string sid;
      
        AuthLogicaldocCom.SoapAuthServicePort authSrvptl = new AuthLogicaldocCom.SoapAuthServicePort();
        Test.setMock(WebServiceMock.class, new webServiceImplvalid());
        authSrvptl.valid(sid);
            
    }
    
    //testing valid call out
    static testmethod void run2condition3(){
        
        string sid;
      
        AuthLogicaldocCom.SoapAuthServicePort authSrvptl = new AuthLogicaldocCom.SoapAuthServicePort();
        Test.setMock(WebServiceMock.class, new webServiceImplrenew());
        authSrvptl.renew(sid);
            
    }
    
    
}
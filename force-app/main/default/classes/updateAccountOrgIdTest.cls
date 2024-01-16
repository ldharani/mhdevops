//Author        : akash
//Description   : test class for webservice class updateAccountOrgId

@isTest
public class updateAccountOrgIdTest {
    
      
    
     static testmethod void run2condtion200Response(){
       
        MDL_UtilClass_TestClass testutil = new MDL_UtilClass_TestClass();
        
        //creating single account
        Account acc = testutil.getAccount();
        acc.MH_Cust_Number__c = '1010101010' ;
        update acc;
         
         acc = [select id, Name,
                          Org_Id__c,MH_Cust_Number__c
                          from account  
                           where MH_Cust_Number__c ='1010101010' 
                           LIMIT 1];
        
        system.debug('@@@acc in test class'+ acc.Org_Id__c); 
        String reqXML =  getRequestXML('200', 'success');
         
          Test.startTest();
   
   			//As Per Best Practice it is important to instantiate the Rest Context 
   
   			RestRequest req = new RestRequest(); 
   			RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/updateAccountwithOrgId';  //Request URL
            req.httpMethod = 'POST'; //HTTP Request Type
            req.requestBody = Blob.valueof(reqXML);
            RestContext.request = req;
            RestContext.response= res;
         
         

           updateAccountOrgId.doPatch(); //Call the Method of the Class 
          
           Test.stopTest();
           
       // http://cloudyworlds.blogspot.in/2012/12/writing-test-classes-for-apex-rest.html
        
    }
    
    static testmethod void run2condtion502Response(){
       
        MDL_UtilClass_TestClass testutil = new MDL_UtilClass_TestClass();
        
        //creating single account
        Account acc = testutil.getAccount();
        acc.MH_Cust_Number__c = '1010101010' ;
        update acc;
         
         acc = [select id, Name,
                          Org_Id__c,MH_Cust_Number__c
                          from account  
                           where MH_Cust_Number__c ='1010101010' 
                           LIMIT 1];
        
        system.debug('@@@acc in test class'+ acc.Org_Id__c); 
        String reqXML =  getRequestXML('502', 'STUB_ERR_004');
         
          Test.startTest();
   
   			//As Per Best Practice it is important to instantiate the Rest Context 
   
   			RestRequest req = new RestRequest(); 
   			RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/updateAccountwithOrgId';  //Request URL
            req.httpMethod = 'PATCH'; //HTTP Request Type
            req.requestBody = Blob.valueof(reqXML);
            RestContext.request = req;
            RestContext.response= res;
         
         

           updateAccountOrgId.doPatch(); //Call the Method of the Class 
          
           Test.stopTest();
           
       // http://cloudyworlds.blogspot.in/2012/12/writing-test-classes-for-apex-rest.html
        
    }
    
    
    static testmethod void run2condtion500Response(){
       
        MDL_UtilClass_TestClass testutil = new MDL_UtilClass_TestClass();
        
        //creating single account
        Account acc = testutil.getAccount();
        acc.MH_Cust_Number__c = '1010101010' ;
        update acc;
         
         acc = [select id, Name,
                          Org_Id__c,MH_Cust_Number__c
                          from account  
                           where MH_Cust_Number__c ='1010101010' 
                           LIMIT 1];
        
        system.debug('@@@acc in test class'+ acc.Org_Id__c); 
        String reqXML =  getRequestXML('500', 'STUB_ERR_004');
        
         
          Test.startTest();
   
   			//As Per Best Practice it is important to instantiate the Rest Context 
   
   			RestRequest req = new RestRequest(); 
   			RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/updateAccountwithOrgId';  //Request URL
            req.httpMethod = 'PATCH'; //HTTP Request Type
            req.requestBody = Blob.valueof(reqXML);
            RestContext.request = req;
            RestContext.response= res;
         
         

           updateAccountOrgId.doPatch(); //Call the Method of the Class 
          
           Test.stopTest();
           
       // http://cloudyworlds.blogspot.in/2012/12/writing-test-classes-for-apex-rest.html
        
    }
    
     static testmethod void run2condtion502ResponseSTUB_ERR_001(){
       
        MDL_UtilClass_TestClass testutil = new MDL_UtilClass_TestClass();
        
        //creating single account
        Account acc = testutil.getAccount();
        acc.MH_Cust_Number__c = '1010101010' ;
        update acc;
         
         acc = [select id, Name,
                          Org_Id__c,MH_Cust_Number__c
                          from account  
                           where MH_Cust_Number__c ='1010101010' 
                           LIMIT 1];
        
        system.debug('@@@acc in test class'+ acc.Org_Id__c); 
        String reqXML =  getRequestXML('502', 'STUB_ERR_001');
         
          Test.startTest();
   
   			//As Per Best Practice it is important to instantiate the Rest Context 
   
   			RestRequest req = new RestRequest(); 
   			RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/updateAccountwithOrgId';  //Request URL
            req.httpMethod = 'POST'; //HTTP Request Type
            req.requestBody = Blob.valueof(reqXML);
            RestContext.request = req;
            RestContext.response= res;
         
         

           updateAccountOrgId.doPatch(); //Call the Method of the Class 
          
           Test.stopTest();
           
       // http://cloudyworlds.blogspot.in/2012/12/writing-test-classes-for-apex-rest.html
        
    }
    
     static testmethod void run2condtion502ResponseSTUB_ERR_002(){
       
        MDL_UtilClass_TestClass testutil = new MDL_UtilClass_TestClass();
        
        //creating single account
        Account acc = testutil.getAccount();
        acc.MH_Cust_Number__c = '1010101010' ;
        update acc;
         
         acc = [select id, Name,
                          Org_Id__c,MH_Cust_Number__c
                          from account  
                           where MH_Cust_Number__c ='1010101010' 
                           LIMIT 1];
        
        system.debug('@@@acc in test class'+ acc.Org_Id__c); 
        String reqXML =  getRequestXML('502', 'STUB_ERR_002');
         
          Test.startTest();
   
   			//As Per Best Practice it is important to instantiate the Rest Context 
   
   			RestRequest req = new RestRequest(); 
   			RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/updateAccountwithOrgId';  //Request URL
            req.httpMethod = 'POST'; //HTTP Request Type
            req.requestBody = Blob.valueof(reqXML);
            RestContext.request = req;
            RestContext.response= res;
         
         

           updateAccountOrgId.doPatch(); //Call the Method of the Class 
          
           Test.stopTest();
           
       // http://cloudyworlds.blogspot.in/2012/12/writing-test-classes-for-apex-rest.html
        
    }
    
    public static String getRequestXML(String HttpRespCode, String Code){
         String reqXML = '';
         String xmlns = '';
         String reqID = '';
         //String HttpRespCode = '';
         String RespOrigin = '';
         String CustNo = '1010101010';
         String OrgId = '12345';
         //String Code = '';
         String text = '';
         String orderNo = '301234';
        //constructing XML
        Xmlstreamwriter xmlW = new Xmlstreamwriter();
        xmlW.writeStartElement(null,'StubResponse', null); 
        xmlW.writeAttribute(null,null,'xmlns',xmlns);
        
        //Beginning of requestId tag
        xmlW.writeStartElement(null,'RequestId',null);
        xmlW.writeCharacters(reqID);
        xmlW.writeEndElement();

        //Beginning of HttpResponseCode tag
        xmlW.writeStartElement(null,'HttpResponseCode',null);
        xmlW.writeCharacters(HttpRespCode);
        xmlW.writeEndElement();
       
        
        //Beginning of ResponseOrigin tag
        xmlW.writeStartElement(null,'ResponseOrigin',null);
        xmlW.writeCharacters(RespOrigin);
        xmlW.writeEndElement();
        
         
        
        //Beginning of CustomerNumber tag
        xmlW.writeStartElement(null,'CustomerNumber',null);
        xmlW.writeCharacters(CustNo);
        xmlW.writeEndElement(); 
        
        //Beginning of CustomerNumber tag
        xmlW.writeStartElement(null,'OrderNumber',null);
        xmlW.writeCharacters(orderNo);
        xmlW.writeEndElement(); 
        
        
        //Beginning of OrgID tag
        xmlW.writeStartElement(null,'OrgID',null);
        xmlW.writeCharacters(OrgID);
        xmlW.writeEndElement();  
        
        //Beginning of Message tag
        xmlW.writeStartElement(null,'Message',null);
        	 
        	//Beginning of Code tag
        	xmlW.writeStartElement(null,'Code',null);
        	xmlW.writeCharacters(Code);
        	xmlW.writeEndElement();  
        	
        	//Beginning of Text tag
        	xmlW.writeStartElement(null,'Text',null);
        	xmlW.writeCharacters(text);
        	xmlW.writeEndElement();  
        
        xmlW.writeEndElement();
        xmlW.writeEndElement();
        
        reqXML = xmlW.getXmlString();
         System.debug('@@@Order Request :'+reqXML);
        return reqXML;
       
    }

}
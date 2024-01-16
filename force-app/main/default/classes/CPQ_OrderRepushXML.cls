public with sharing class CPQ_OrderRepushXML {
  public invoiceit_s__Job__c orderObj{get;set;}
  public invoiceit_s__Job__c job;
  ID userid;
  User u;
  List<invoiceit_s__Job_Rate_Plan_Charge__c> lstCharges;
  List<PermissionSetAssignment> listperassign;
  Map<id,Chat_Product_Order_Charge__c> orpcIdVschatOrpc;  
  String reqXML;
  Integration_Endpoints__c endPts;
    String endPoint;
    String methodType;
    List<String> lstResponseBody;
    public Boolean accessRights{get;set;}
    public Boolean error{get;set;}
    public String AccName{get;set;}
    public Boolean showXMLButton{get;set;}
    public Boolean genAnotherOrder{get;set;}
   
  public CPQ_OrderRepushXML() {
    orderObj = new invoiceit_s__Job__c();
    //u = new User();
    //    u = [select Id, username from User where Id = :UserInfo.getUserId()];
    u = new user();
    u.id = UserInfo.getUserId();
    u.username = UserInfo.getUserName();
    lstCharges = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
    endPts = Integration_Endpoints__c.getValues('OrderRequest');
    endPoint = String.valueOf(endPts.Endpoint_URL__c);
    methodType = endPts.MethodType__c;
    AccName = '';
    lstResponseBody = new List<String>();
    error = false;
    showXMLButton = false;
    genAnotherOrder = false;
    listperassign = [select Assignee.Id, PermissionSet.Name, Assignee.Name, PermissionSet.Id from PermissionSetAssignment where PermissionSet.Label like '%order%repush'];
    System.debug('userID'+UserInfo.getUserId());
    userid = u.Id;
    for(PermissionSetAssignment psa : listperassign){
         if(psa.Assignee.Id==userid){
           accessRights = true;           
           break;
         }
         else{
            accessRights = false;          
         }
      }    
  }
  public PageReference validateAcc() {
    job = new invoiceit_s__Job__c();
    if(orderObj.Name == '' || orderObj.Name == null) {
          apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Please enter order name before you intend to generate the XML');
          apexpages.addMessage(am);  
          error = true;
          return null;
        }
    for(invoiceit_s__Job__c j : [Select i.invoiceit_s__Account__r.MH_Cust_Number__c, i.invoiceit_s__Account__c,RecordType.developerName, i.invoiceit_s__Account__r.Name ,
                                            i.invoiceit_s__Account__r.Org_Id__c, 
                          (Select Id, Name, invoiceit_s__Job__c, invoiceit_s__Description__c,RecordType.developerName, invoiceit_s__Product_Code__c, 
                               invoiceit_s__Product_Family__c, invoiceit_s__Product__c, invoiceit_s__SequenceNumber__c, Tracking_Number__c, 
                               Inventory_Id__c, Customer_Number__c, Sin_Number__c From invoiceit_s__Job_Product__r),
                           i.OrderNumber__c, i.Name, i.Id, i.Fulfillment_Date__c From invoiceit_s__Job__c i where i.Name =: orderObj.Name 
                           AND (RecordType.DeveloperName = 'MH_Orders' OR RecordType.DeveloperName = 'Nolo_Order' OR RecordType.DeveloperName = 'M_NG_Order') 
                             LIMIT 1] ) {
          job = j;                     
        }
        System.debug('job details:::'+job+'Job Prod***'+job.invoiceit_s__Job_Product__r);
        if(job.Id != null) {
          AccName = 'Order exists and it belongs to the following account :' + job.invoiceit_s__Account__r.Name+'.Proceed to generate XML by clicking on Generate XML button' ;
          showXMLButton = true;
        }
        else {
          apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Order Name does not exist.Kindly enter a correct name for generating the Order XML');
          apexpages.addMessage(am);
          error = true;  
          return null;
        }
    return null; 
  }
  public PageReference refreshPage() {
    Pagereference p = new Pagereference('/apex/MDL_OnDemandOrderXMLPage');
    p.setRedirect(true);
    return p;
  }
  public PageReference generateXML() {
    System.debug('**Job ID is**'+job);
    lstCharges = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
     orpcIdVschatOrpc = new Map<id,Chat_Product_Order_Charge__c>();
    for(invoiceit_s__Job_Rate_Plan_Charge__c  orderCharge : [Select i.invoiceit_s__Status__c,i.invoiceit_s__Price_Type__c, i.invoiceit_s__Job_Rate_Plan__c, i.Cancel_Date__c , i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c,i.invoiceit_s__Order__c,
                                                                          i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c,
                                                                          i.invoiceit_s__Order__r.Parent_Order__r.name,i.invoiceit_s__Order__r.RecordType.developername, i.RecordType.developername,
                                                                          i.Chat_Parent_Order_Rate_Plan_Charge__c, i.Chat_Parent_Order_Rate_Plan_Charge__r.name,
                                                                          i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Sin_Number__c,i.Chat_Parent_Order_Rate_Plan_Charge__r.SIN__c,
                                                                          i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name,i.Sin__c,
                                                                          i.invoiceit_s__Accounting_Code__c , i.Name, i.invoiceit_s__Service_End_Date__c,i.invoiceit_s__Service_Activation_Date__c, 
                                                                          i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c,
                                                                          i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id,i.Fulfilment_Start_Date__c,
                                                                          i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.CreatedDate,
                                                                          i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Shippable__c,
                                                                          i.Renew_Rebase_Truncate_Date__c,Live_Date__c,
                                                                          (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                                                                          LastModifiedById, SystemModstamp, LastActivityDate, Attribute_Name__c, 
                                                                          Attribute_Order__c, Attribute_Picklist_Values__c, Attribute_Type__c, Boolean_Value__c, 
                                                                          Date_Value__c, Maximum_No_Of_Characters_In_Text__c, Minimum_No_Of_Characters_In_Text__c, 
                                                                          Number_Value__c, Order_Rate_Plan_Charge__c, Phone_Value__c, Picklist_Value__c, String_Value__c,
                                                                          Value_ID__c 
                                                                          From Order_Charge_Attributes__r where (RecordType.DeveloperName = 'MDL_Order_Charge_Attribute' or RecordType.DeveloperName = 'Nolo_Order_Charge_Attribute' or RecordType.DeveloperName = 'M_NG_Order_Charge_Attribute')
                                                                          order by Attribute_Order__c), 
                                                                          i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Customer_Number__c,
                                                                          i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c,
                                                                          i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__c,
                                                                          i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.IsInventoried__c,i.Shippable__c,
                                                                          i.Chat_ID__c
                                                                          From invoiceit_s__Job_Rate_Plan_Charge__c i 
                                                                          where i.invoiceit_s__Order__c =: job.Id
                                                                          and (RecordType.DeveloperName = 'MDL_Order_Rate_Plan_Charge' or RecordType.DeveloperName = 'Nolo_Order_Rate_Plan_Charge'or RecordType.DeveloperName = 'M_NG_Order_Rate_Plan_Charge')]) {
              //added by sai 
              if(!((orderCharge.invoiceit_s__Status__c=='Expired' || orderCharge.invoiceit_s__Status__c=='Truncated'  )
              && (orderCharge.invoiceit_s__Price_Type__c == 'One Time' || orderCharge.invoiceit_s__Price_Type__c == 'Monthly'|| orderCharge.invoiceit_s__Price_Type__c == 'Usage')
              && orderCharge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Shippable__c == 'Yes') ){
               lstCharges.add(orderCharge); 
              }                                                            
          }
          System.debug('charges are ***'+lstCharges);
          //Sending HTTP Callouts - Begin 
          if(lstCharges.size()>0){
              
              orpcIdVschatOrpc = getchatproductsMap(lstCharges);
              system.debug('@@@@@@orpcIdVschatOrpc'+orpcIdVschatOrpc);
              
            //code for authentication
            Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('OrderRequest');
             system.debug('@@@@endPts'+endPts); 
              
            String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)
          /*String endPoint1 = 'cert3-svcs.martindale.com/mhintegration/order';
            String privateKey = 'F2DCA2AD71561755E0433454B60AF99D';
            String apiKey = '76F1CF765AA41A8E695F66A815B7D345';*/
            
            String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
            String privateKey = endPts.Private_Key__c;
            //String privateKey = 'd648ba5f898562cff2ad3e5fabd7127b5b2b48bbab93d05eeaec1e575e8e2fd6';
            //String privateKey = '1234567';
            
            String publicKey  =   endPts.Public_Key__c;
            //String publicKey  = 'ce7b3a2fc28a9524685d1691d9a44d484245343af255c9aef91a674cc0e6cdd1';  
            String apiKey = endPts.API_key__c;
            
            //de-commented 
           /* String httpVerb = 'POST';
            string textToBe
            ed = timeDifferenceInSeconds + ':' + endPoint1 + ':' + httpVerb + ':' + privateKey;
            System.debug('textToBeHashed'+textToBeHashed);
            Blob textToBeHashedInBytes = Blob.valueOf(textToBeHashed);
            System.debug('text to be hashed to blob'+textToBeHashedInBytes);
            String algorithmName = 'SHA-256';
            Blob mac = Crypto.generateDigest(algorithmName, textToBeHashedInBytes);
            System.debug('SHA256 algo'+mac);
            String encodedText  = EncodingUtil.base64Encode(mac);
            System.debug('Base 64 string'+encodedText);
            String aToken = timeDifferenceInSeconds + ':' + apikey + ':' + encodedText;
            //aToken will be added in HTTP Request Header as Authorization
            System.debug('authorization token is '+aToken);
            //end of authentication
            */
              
            try {
              //reqXML=MDL_Integration_Vim_Efs.constructXML_OrderRequest(u.UserName,lstCharges,job);
                system.debug('@@@@u userName'+u);
                system.debug('@@@@@job'+job);
                system.debug('@@@@@orpcIdVschatOrpc'+orpcIdVschatOrpc);
              reqXML=MDL_Integration_Vim_Efs.constructXML_OrderRequestfrompage(u.UserName,lstCharges,job,orpcIdVschatOrpc);
              system.debug('@@@@reqXML'+ reqXML);
              
                
             //iPayload := Timestamp=iEpochTime&XML=<iOrderXML>   
              //string ipayload =   timeDifferenceInSeconds + '&'+ 'XML='+ reqXML;
              //publicKey=adf1b0a349319c6b1396cc1f24f840f44f2a05ba61b5dd5bf13373ca6f3d92bb&timestamp=1464203019&xml=<xml></xml>
              
              string ipayload   = 'publicKey='+ publicKey + '&' + 'timestamp=' + timeDifferenceInSeconds + '&' + 'xml=' + reqXML;
              //string ipayload   = 'hello';
              system.debug('@@@@ipayload'+ ipayload);  
                
            /*  //generating hmac  
              Blob data = crypto.generateMac('HmacSHA256',Blob.valueOf(ipayload), Blob.valueOf(privateKey));
              system.debug('@@@data'+ data);
                
              //final result in the form of  Base_64(HMAC(SHA256(iPayload),iPrivateKey))|iPublicKey
              String encodedText  = EncodingUtil.base64Encode(data)+ '|'+ publicKey;
              system.debug('@@@encodedText'+ encodedText);              
                
              //in the reference url given as
              //Authorization = "AWS" + " " + AWSAccessKeyId + ":" + Signature;
              //assuming privateKey as access key here  
              String aToken = 'MH-HMAC' + ' ' + privateKey + ':' + encodedText;  
              system.debug('@@@aToken'+ aToken); 
              */
                
                
              Blob textToBeHashedInBytes = Blob.valueOf(ipayload);
              //Blob textToBeHashedInBytes = Hello;
              String algorithmName = 'SHA-256';
              Blob mac = Crypto.generateMac('HmacSHA256',Blob.valueOf(ipayload), Blob.valueOf(privateKey));
             //Blob mac = Crypto.generateDigest(algorithmName, textToBeHashedInBytes);
             System.debug('SHA256 algo'+mac);
             //String encodedText  = EncodingUtil.base64Encode(mac);
             String encodedText  = EncodingUtil.base64Encode(mac);
             system.debug('@@@encodedText-'+encodedText);
             system.debug('@@@mac'+mac);
             
             String Header      =  encodedText + '|'+  timeDifferenceInSeconds;
               
              //added 4/3/16 by akash   
               // Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('OrderRequest');
               //String givenEndpoint = 'https://stg-back-office-services.lawyers.com/services/efs/v1/handleSalesForceXml';
               //String givenEndpoint = 'https://back-office-services.lawyers.com/services/efs/v1/handleSalesForceXml';
               String givenEndpoint   = endPts.Endpoint_URL__c;
              //String givenEndpoint = 'http://stg-ibmhbows1.internetbrands.com/services/efs/v1/handleSalesForceXml?xml='+ reqXML;
              
              //encoding url with x-www-form-urlencoded format with scheme UTF-8
              String encodedurl = EncodingUtil.urlEncode(givenEndpoint, 'UTF-8');
  
                
              Http http = new Http(); //global class which is used in both request & response
              HttpRequest req = new HttpRequest(); //initiate HTTP request
             // req.setEndpoint(endPoint);
             
              //added 4/3/16 by akash     
              req.setEndpoint(givenEndpoint);   
                
              req.setMethod(methodType);
              req.setTimeout(20000);
              //req.setBody('xml='+reqXML); 
              req.setBody(ipayload);
              req.setHeader('Accept', 'application/xml');
              
                
              //added 4/3/16 by akash setheader  
              req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                
              req.setHeader('Authorization', Header);
              HTTPResponse res = http.send(req);
              System.debug('Response Body in On Demand - order Message is ::::: '+res.getBody());
              system.debug('@@res status code'+res.getStatusCode());  
              Error_Log__c error_log; 
              Dom.Document response = new Dom.Document();
              dom.Xmlnode responseBody;
              if(res.getStatusCode() != 502){
                  response.load(res.getBody());
                  responseBody = response.getRootElement();

              }            
                            /* to capture the 200/400 response*/
              if(res.getStatusCode() == 200){
                      error_log = MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody() , reqXML);    
                      if(error_log == null)
                        lstResponseBody.add(res.getBody());   
                      else{                      
                error = true;
                error_log.XML_Mesaage_Type__c = 'OrderRequest';
                insert error_log;              
                apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'There is a Data issue. An error log has been created');
                apexpages.addMessage(am);
                return null;  
                      }                   
                  }                
                  /*  
              if(res.getStatusCode() != 500 && res.getStatusCode() != 501 && res.getStatusCode()!= 502 && res.getStatusCode() != 503 && res.getStatusCode() != 400 && res.getStatusCode() != 401 && res.getStatusCode() != 404) { 
                  lstResponseBody.add(res.getBody());
            }*/
            else {
              boolean errorlogCreated = false;  
              String txtmsg = '';
              try{
                if((res.getStatusCode() == 400 || res.getStatusCode() == 401) && responseBody.getChildElement('Messages',null) != null && responseBody.getChildElement('Messages',null).getChildElement('Message',null) != null)
                  txtmsg = responseBody.getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null).getText();
              }
              catch(Exception e){
                
              } 
                system.debug('@@@in else'+res.getStatusCode());
                if(res.getStatusCode() == 502){
                    List<Error_Log__c> existingerrorLog = new List<Error_Log__c>();
                     existingerrorLog = [select id,Order_Name__c,Case__c,
                                               XML_Mesaage_Type__c,XML_Body__c
                                               From Error_Log__c
                                               where Order_Name__c =:job.Name];
                    if(!existingerrorLog.isEmpty() && existingerrorLog.size() > 0){
                        existingerrorLog[0].Re_process_date_time__c = system.now(); 
                    }
                    else{
                         error_log = new Error_Log__c();
                        error_log.XML_Mesaage_Type__c = 'OrderRequest';
                        error_log.XML_Body__c = reqXML;
                       if(txtmsg != null || txtmsg != '')
                            error_log.Error_Reason__c = res.getStatusCode() + ' : ' + txtmsg;
                        else
                            error_log.Error_Reason__c = res.getStatusCode() + ' : ' + res.getStatus();  
                
                        error_log.Order_Name__c = job.Name;
                        error_log.Re_process_date_time__c =system.now();
                        existingerrorLog.add(error_log);
                        
                        
                    }
                    upsert existingerrorLog;
                }
                    
                  
                       
              
              error = true;
              apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'There is a network issue (or) authentication issue.Please try generating XML sometime later');
              apexpages.addMessage(am);              
              return null;
            }
            if(lstResponseBody.size() > 0) {
              MDL_Integration_Vim_Efs.parseResponseXML_OrderResponse(lstResponseBody);
              apexpages.Message am1=new apexpages.Message(ApexPages.Severity.Info, 'Order XML has been generated successfully');
              apexpages.addMessage(am1);
              error = true;
              genAnotherOrder = true;
              return null;
            }
            
            if(error_log != null)
              insert error_log;
              
            }
            catch(Exception e) {
                
                system.debug('@@@@e message'+ e.getMessage());
                //creating error in case of Unexpected end of file from server error 
                //added by sai:20/4/2016
                if(e.getMessage().contains('Unexpected end of file from server') || (test.isRunningTest() && e.getMessage().contains('Attempt to de-reference a null object'))){
                    List<Error_Log__c> existingerrorLog = new List<Error_Log__c>();
                     existingerrorLog = [select id,Order_Name__c,Case__c,
                                               XML_Mesaage_Type__c,XML_Body__c
                                               From Error_Log__c
                                               where Order_Name__c =:job.Name];
                    if(!existingerrorLog.isEmpty() && existingerrorLog.size() > 0){
                        existingerrorLog[0].Re_process_date_time__c = system.now(); 
                    }
                    else{
                        Error_Log__c error_log = new Error_Log__c();
                        error_log.XML_Mesaage_Type__c = 'OrderRequest';
                        error_log.XML_Body__c = reqXML;
                       
                            error_log.Error_Reason__c = e.getMessage();
                        
                
                        error_log.Order_Name__c = job.Name;
                        error_log.Re_process_date_time__c =system.now();
                        existingerrorLog.add(error_log);
                        
                        
                    }
                    upsert existingerrorLog;
                }
                
              apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, e.getMessage() + '.Please try again after sometime');
              apexpages.addMessage(am);  
              error = true;
              genAnotherOrder = true;
            return null;
            }
              //Sending HTTP Callouts - End
       }
       else{
         apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info,'There are no products for this order for which an Order XML can be generated');
        apexpages.addMessage(am);
        error = true;
         return null;
       }
     return null;
  }
    
    
    public static Map<id,Chat_Product_Order_Charge__c> getchatproductsMap(List<invoiceit_s__Job_Rate_Plan_Charge__c> orpcList){
        
        system.debug('@@@@@orpcList'+orpcList);
        Map<id,Chat_Product_Order_Charge__c> orpcIdVschatOrpctemp = new Map<id,Chat_Product_Order_Charge__c>();
        List<Chat_Product_Order_Charge__c> chatorpcList = new List<Chat_Product_Order_Charge__c>();
        chatorpcList            =   [select id,Name,
                                            Chat_Product_Order_Rate_Plan_Charge__c,
                                         Chat_Product_Order_Rate_Plan_Charge__r.SIN__c,
                                            Chat_Usage_Order_Rate_Plan_Charge__c,
                                            Chat_Usage_Order_Rate_Plan_Charge__r.Name,
                                            Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c,
                                            Chat_Usage_Order_Rate_Plan_Charge__r.SIN__c
                                            From Chat_Product_Order_Charge__c
                                            where Chat_Product_Order_Rate_Plan_Charge__c IN:orpcList];
        
        for(Chat_Product_Order_Charge__c chatOrpc : chatorpcList){
            orpcIdVschatOrpctemp.put(chatOrpc.Chat_Product_Order_Rate_Plan_Charge__c, chatOrpc);
        }
        
        system.debug('@@@@@orpcIdVschatOrpctemp'+orpcIdVschatOrpctemp);
        return orpcIdVschatOrpctemp;
        
    }
    
    public static Map<id,Chat_Product_Order_Charge__c> getchatproductsChildMap(List<invoiceit_s__Job_Rate_Plan_Charge__c> orpcList){
        
        system.debug('@@@@@orpcList'+orpcList);
        Map<id,Chat_Product_Order_Charge__c> orpcIdVschatOrpctemp = new Map<id,Chat_Product_Order_Charge__c>();
        List<Chat_Product_Order_Charge__c> chatorpcList = new List<Chat_Product_Order_Charge__c>();
        chatorpcList            =   [select id,Name,
                                            Chat_Product_Order_Rate_Plan_Charge__c,
                                         Chat_Product_Order_Rate_Plan_Charge__r.SIN__c,
                                         Chat_Product_Order_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c,
                                            Chat_Usage_Order_Rate_Plan_Charge__c,
                                            Chat_Usage_Order_Rate_Plan_Charge__r.Name,
                                            Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c,
                                            Chat_Usage_Order_Rate_Plan_Charge__r.SIN__c
                                            From Chat_Product_Order_Charge__c
                                            where Chat_Usage_Order_Rate_Plan_Charge__c IN:orpcList];
        
        for(Chat_Product_Order_Charge__c chatOrpc : chatorpcList){
            orpcIdVschatOrpctemp.put(chatOrpc.Chat_Usage_Order_Rate_Plan_Charge__c, chatOrpc);
        }
        
        system.debug('@@@@@orpcIdVschatOrpctemp'+orpcIdVschatOrpctemp);
        return orpcIdVschatOrpctemp;
        
    }
    
    
    
    
}
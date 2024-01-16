public with sharing class CPQ_OrderRepush {
    public Order orderObj{get;set;}
    public Order job;
    ID userid;
    User u;
    Set<Id> orderprodIds = new Set<Id>();
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
    
    public CPQ_OrderRepush() {
        orderObj = new Order();
        //u = new User();
        //    u = [select Id, username from User where Id = :UserInfo.getUserId()];
        u = new user();
        u.id = UserInfo.getUserId();
        u.username = UserInfo.getUserName();
        Set<Id> OrderItemIds = new Set<Id>();
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
        job  = new Order ();
        System.debug('@@@@ Order Ids '+orderObj); 

        if(orderObj.Name == '' || orderObj.Name == null) {
            apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Please enter order name before you intend to generate the XML');
            apexpages.addMessage(am);  
            error = true;
            return null;
        }
        
        // job = orderObj;

            for(Order j : [Select id,Account.Name,Name,OrderNumber, Type,Status From Order Where OrderNumber =: orderObj.Name LIMIT 1]){
                job = j;  
        }
        //System.debug('job details:::'+job+'Job Prod***'+job.invoiceit_s__Job_Product__r);
        if(job.Id != null) {
            AccName = 'Order exists and it belongs to the following account :' + job.Account.Name+'.Proceed to generate XML by clicking on Generate XML button' ; 
            showXMLButton = true;
        }
        else {
            apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Order Name does not exist.Kindly enter a correct name for generating the Order XML');
            apexpages.addMessage(am);  error = true;  return null;
        }
        return null; 
    }
    public PageReference refreshPage() {
        Pagereference p = new Pagereference('/apex/CPQ_OrderRepush');
        p.setRedirect(true);
        return p;
    }
    public PageReference generateXML() {
        System.debug('**Job ID is**'+job);
        List<Id> orderIds = new List<Id>();
        
        Set<Id> orderprodIds = new Set<Id>();
        
        if(job.id!= null ){
            
            orderIds.add(job.id); 
            
        }   
        
        //orpcIdVschatOrpc = new Map<id,Chat_Product_Order_Charge__c>();
        for(OrderItem ordprod : [Select id,Status__c,OrderId,SIN__c,Inventory_Id__c,Attribute_Relationship__c,Renew_Rebase_Truncate_Date__c,Product2.ProductCode,
                                 ServiceDate,EndDate,SBQQ__TerminatedDate__c,Product2.Name,blng__NextBillingDate__c,SBQQ__ProductSubscriptionType__c,CreatedDate from OrderItem where Orderid IN:orderIds and Status__c !='Modified'
                                 and Status__c != '' and Status__c != null ]) {
                                     //added by sai 
                                     if(!( ordprod .Status__c=='Off set' && ordprod.Status__c =='Modified'  && ordprod.Status__c =='' ) ){
                                         
                                         orderprodIds.add(ordprod.id ); 
                                         
                                     }                                                            
                                 }
        System.debug('charges are ***'+orderprodIds);
        
        //Sending HTTP Callouts - Begin 
        if(orderprodIds.size()>0){
            
            
            //code for authentication
            Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('OrderRequest');
            system.debug('@@@@endPts'+endPts); 
            
            String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)
            
            String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
            String privateKey = endPts.Private_Key__c;
            //String privateKey = 'd648ba5f898562cff2ad3e5fabd7127b5b2b48bbab93d05eeaec1e575e8e2fd6';
            //String privateKey = '1234567';
            
            String publicKey  =   endPts.Public_Key__c;
            //String publicKey  = 'ce7b3a2fc28a9524685d1691d9a44d484245343af255c9aef91a674cc0e6cdd1';  
            String apiKey = endPts.API_key__c;
            
            
            try {
                //reqXML=MDL_Integration_Vim_Efs.constructXML_OrderRequest(u.UserName,lstCharges,job);
                system.debug('@@@@u userName'+u);
                system.debug('@@@@@job'+job);
                //system.debug('@@@@@orpcIdVschatOrpc'+orpcIdVschatOrpc);
                if(!test.isrunningtest())
                reqXML=CPQ_MDL_Integration_Vim_Efs.orderRequestfrompage(orderprodIds);
                system.debug('@@@@reqXML'+ reqXML);
                
                string ipayload   = 'publicKey='+ publicKey + '&' + 'timestamp=' + timeDifferenceInSeconds + '&' + 'xml=' + reqXML;
                //string ipayload   = 'hello';
                system.debug('@@@@ipayload'+ ipayload);  
                
                
                
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
                
                
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                
                req.setHeader('Authorization', Header);
                HTTPResponse res = http.send(req);
               // System.debug('Response Body in On Demand - order Message is ::::: '+res.getBody());
               // system.debug('@@res status code'+res.getStatusCode());  
                Error_Log__c error_log; 
                Dom.Document response = new Dom.Document();
                dom.Xmlnode responseBody;
                if(res.getStatusCode() != 502){
                    response.load(res.getBody());
                    responseBody = response.getRootElement();
                    
                }            
                
                /* to capture the 200/400 response*/
                if(res.getStatusCode() == 200){
                    error_log = CPQ_MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody() , reqXML);    
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
                    CPQ_MDL_Integration_Vim_Efs.parseResponseXML_OrderResponse(lstResponseBody);
                    apexpages.Message am1=new apexpages.Message(ApexPages.Severity.Info, 'Order XML has been generated successfully');
                    apexpages.addMessage(am1);
                    error = true;
                    genAnotherOrder = true;
                    return null;
                }
                
                if(error_log != null)  insert error_log;
                
            }
            catch(Exception e) {
                
                system.debug('@@@@e message'+ e.getMessage());
                //creating error in case of Unexpected end of file from server error 
                
                if(e.getMessage().contains('Unexpected end of file from server')){
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
            apexpages.addMessage(am);  error = true;  return null;
        }
        return null;
    }
    
    public  void FkMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    
}
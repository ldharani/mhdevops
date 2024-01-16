/*
 * Created By : Lister Technologies
 * Created Date : 18-April-2014
 * Created Purpose : Class which will be constructing XML Request and Parsing XML Response
 * Test Class : 
 */
public with sharing class MDL_Integration_Vim_Efs {
    public static boolean MDL_trg_OrderRequestInCaseOfAttributeChangesRecursion = true;
    
   public static void pendInventoryRequest(Set<Id> setOppProductIds,String customerNumber,String userName,String acc) {
        List<String> lstResponseBody = new List<String>();
        Map<Id,String> mapOppProdIdNErrResponseBody = new Map<Id,String>();
        Map<Id,invoiceit_crmx__Opportunity_Product__c> mapOppProdIdNOppProd = new Map<Id,invoiceit_crmx__Opportunity_Product__c>();
        Map<Id,Boolean> mapOppProdIdNResponseIsXML = new Map<Id,Boolean>();
        //end points is stored in a custom setting - get values from there and use it heres
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('PendInventory');
        String endPoint = String.valueOf(endPts.Endpoint_URL__c);
        System.debug('**'+endPoint);
        String methodType = endPts.MethodType__c;
        String reqXML;
        String cusNumb = '';
        String uName = userName;
        //code for authentication
       String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)
        /*String endPoint1 = 'cert3-svcs.martindale.com/mhintegration/inventory';
        String privateKey = 'F2DCA2AD71561755E0433454B60AF99D';
        String apiKey = '76F1CF765AA41A8E695F66A815B7D345';*/
        
        String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
        String privateKey = endPts.Private_Key__c;
        String apiKey = endPts.API_key__c;
        
        String httpVerb = 'POST'; 
        System.debug('httpVerb'+httpVerb);
        string textToBeHashed = 'Hello';
        //string textToBeHashed = timeDifferenceInSeconds + ':' + endPoint1 + ':' + httpVerb + ':' + privateKey;
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
        if(customerNumber!=null) {
            cusNumb = customerNumber;
        }
        System.debug('set passed is : '+setOppProductIds);
        for(invoiceit_crmx__Opportunity_Product__c oppProd : [Select i.invoiceit_crmx__Product__c, i.invoiceit_crmx__Product_Code__c, 
                                                                     i.invoiceit_crmx__Opportunity__c, i.Name, i.IsInventoried__c,i.Error_Text__c, 
                                                                     i.InventoryId__c, i.Id From invoiceit_crmx__Opportunity_Product__c i
                                                               where i.Id in : setOppProductIds
                                                               and (RecordType.DeveloperName = 'MDL_Opportunity_Product' or RecordType.DeveloperName = 'Nolo_Opportunity_Product')]) {
            reqXML = MDL_Integration_Vim_Efs.constructXML_PendInventory(oppProd,cusNumb,uName); //get request XML from the static method
            try {
                Http http = new Http(); //global class which is used in both request & response
                HttpRequest req = new HttpRequest(); //initiate HTTP request
                req.setEndpoint(endPoint);
                req.setMethod(methodType);
                req.setTimeout(20000);
                req.setBody(reqXML); 
                req.setHeader('Content-Type', 'text/xml');
                req.setHeader('Authorization', aToken);
                HTTPResponse res = http.send(req);
                System.debug('Response Body : '+res.getBody()); 
                if(res.getStatusCode() != 500 && res.getStatusCode() != 400 && res.getStatusCode() != 404 && res.getStatusCode() != 401 && res.getStatusCode() != 502) { 
                    lstResponseBody.add(res.getBody());
                }
                if(res.getStatusCode() == 400 || res.getStatusCode() == 401) {
                    mapOppProdIdNErrResponseBody.put(oppProd.Id,res.getBody()); 
                    mapOppProdIdNOppProd.put(oppProd.Id,oppProd);
                    mapOppProdIdNResponseIsXML.put(oppProd.Id,true);                
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Authentication issue . Kindly inform the system administrator regarding the same.');
                    apexpages.addMessage(am);   
                }
                if(res.getStatusCode() == 404) {
                    mapOppProdIdNErrResponseBody.put(oppProd.Id,'404 : The specified resource was not found, or the resource has been deleted. Please contact MHI system administrator.'); 
                    mapOppProdIdNOppProd.put(oppProd.Id,oppProd);
                    mapOppProdIdNResponseIsXML.put(oppProd.Id,false);                
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Response Status Code : 404. The specified resource was not found, or the resource has been deleted . Please contact MHI system administrator .');
                    apexpages.addMessage(am);   
                }
                if(res.getStatusCode() == 500) {
                    mapOppProdIdNErrResponseBody.put(oppProd.Id,'500 : Internal Server Error . Please contact MHI system administrator .' ); 
                    mapOppProdIdNOppProd.put(oppProd.Id,oppProd);  
                    mapOppProdIdNResponseIsXML.put(oppProd.Id,false);               
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'There is a network issue . Please contact MHI system administrator .');
                    apexpages.addMessage(am);  
                }      
                if(res.getStatusCode() == 502) {
                    mapOppProdIdNErrResponseBody.put(oppProd.Id,'502 : Bad Gateway issue . Please contact MHI system administrator .'); 
                    mapOppProdIdNOppProd.put(oppProd.Id,oppProd);
                    mapOppProdIdNResponseIsXML.put(oppProd.Id,false);
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Bad Gateway issue . Please contact MHI system administrator');
                    apexpages.addMessage(am);  
                }
            }catch(System.CalloutException ce) {
                mapOppProdIdNErrResponseBody.put(oppProd.Id,ce.getMessage()); 
                mapOppProdIdNOppProd.put(oppProd.Id,oppProd);
                mapOppProdIdNResponseIsXML.put(oppProd.Id,false);
                apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Callout exception , kindly try to pend inventory after again');
                apexpages.addMessage(am);   
            }
            catch(System.Exception e) {
                mapOppProdIdNErrResponseBody.put(oppProd.Id,e.getMessage()); 
                mapOppProdIdNOppProd.put(oppProd.Id,oppProd);
                mapOppProdIdNResponseIsXML.put(oppProd.Id,false);
                apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Some Exception occurred , please try again after sometime.'+e.getMessage());
                apexpages.addMessage(am);
            }                                              
        }
        if(!mapOppProdIdNErrResponseBody.isEmpty() && !mapOppProdIdNOppProd.isEmpty() && !mapOppProdIdNResponseIsXML.isEmpty()){
            MDL_Integration_Vim_Efs.parseErrorResponsePendInventory(mapOppProdIdNErrResponseBody,mapOppProdIdNOppProd,mapOppProdIdNResponseIsXML);
        }
        MDL_Integration_Vim_Efs.parseResponseXML_PendInventoryResponse(lstResponseBody,acc);
    }
    
    
    public static String constructXML_PendInventory(invoiceit_crmx__Opportunity_Product__c oppProd,String customerNumber,String userName) {
        String requestXMLString = '';
        String xmlns='';
        //get xmlns value from custom setting
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('PendInventory');
        xmlns = endPts.xmlns__c;
        
        //get server timestamp to send it in requestid
        DateTime result = DateTime.now();
        String timeStampString = result.format();//to convert datetime into string
        String reqID = oppProd.Id + '-' + timeStampString ;
        System.debug('RequestId PendInventory Request :' + reqID);
        
        //getting attributes values
        List<Opportunity_Charge_Attribute__c> lstAttributes = new List<Opportunity_Charge_Attribute__c>();
        Map<String,String> mapAttributeNameAndValue = new Map<String,String>();
        Map<String,String> mapModifiedNameAndValue = new Map<String,String>();
        String aopVal;
        List<Id> lstRatePlanIDs = new List<Id>();
        List<Id> lstRatePlanChargeIDs = new List<Id>();
        List<invoiceit_crmx__Opportunity_Rate_Plan__c> lstOppRatePlans = [Select i.invoiceit_crmx__Opportunity_Product__c, i.Name, i.Id 
                                                                            From invoiceit_crmx__Opportunity_Rate_Plan__c i 
                                                                            where i.invoiceit_crmx__Opportunity_Product__c =: oppProd.Id
                                                                            and (RecordType.DeveloperName = 'MDL_Opportunity_Rate_Plan' or RecordType.DeveloperName = 'Nolo_Opportunity_Rate_Plan')];
        System.debug('Opportunity Rate plan query:'+lstOppRatePlans);
        
        for(invoiceit_crmx__Opportunity_Rate_Plan__c rp : lstOppRatePlans) {
            lstRatePlanIDs.add(rp.Id);
        }
        
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> lstOppRatePlanCharges = [Select i.invoiceit_crmx__Opportunity_Rate_Plan__c, i.Name, i.Id 
                                                                                        From invoiceit_crmx__Opportunity_Rate_Plan_Charge__c i 
                                                                                        where i.invoiceit_crmx__Opportunity_Rate_Plan__c in : lstRatePlanIDs
                                                                                        and (RecordType.DeveloperName = 'MDL_Opportunity_Rate_Plan_Charge' or RecordType.DeveloperName = 'Nolo_Opportunity_Rate_Plan_Charge')];
        System.debug('Opportunity Rate plan charge query:'+lstOppRatePlanCharges);
        
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c ch : lstOppRatePlanCharges) {
            lstRatePlanChargeIDs.add(ch.Id);
        }
        
        for(Opportunity_Charge_Attribute__c oppAttributes : [Select o.String_Value__c, o.Picklist_Value__c, o.Opportunity_Rate_Plan_Charge__c, o.Name, o.Id, o.Attribute_Name__c 
                                                             From Opportunity_Charge_Attribute__c o 
                                                             where o.Opportunity_Rate_Plan_Charge__c in : lstRatePlanChargeIDs
                                                             and (RecordType.DeveloperName = 'MDL_Opportunity_Charge_Attribute' or RecordType.DeveloperName = 'Nolo_Opportunity_Charge_Attribute')]) {
            lstAttributes.add(oppAttributes);
        }
        System.debug('Opportunity Charge Attributes:'+lstAttributes);
        for(Opportunity_Charge_Attribute__c att: lstAttributes) {
            if(att.String_Value__c != null)
                mapAttributeNameAndValue.put(att.Attribute_Name__c,att.String_Value__c);
            if(att.Picklist_Value__c != null)
                mapAttributeNameAndValue.put(att.Attribute_Name__c,att.Picklist_Value__c);
        }
        System.debug('MapAttributes&&&'+mapAttributeNameAndValue);
        for(String newAttValue : mapAttributeNameAndValue.keySet()) {
            if(newAttValue.endsWith('AOP') || newAttValue.contains('AOP')) {
                aopVal = 'AOP';
            }
            else {
                aopVal = newAttValue;
            }
            mapModifiedNameAndValue.put(aopVal,mapAttributeNameAndValue.get(newAttValue));
        }
        
        System.debug('Modifed Attribute Map***'+mapModifiedNameAndValue);
        //construct the XML here
        Xmlstreamwriter xmlW = new Xmlstreamwriter();
        
        //Beginning of PendInventoryRequest tag
        xmlW.writeStartElement(null,'PendInventoryRequest', null); 
        xmlW.writeAttribute(null,null,'xmlns',xmlns);
        
        //Beginning of requestId tag
        xmlW.writeStartElement(null,'RequestId',null);
        xmlW.writeCharacters(reqID);
        xmlW.writeEndElement();
        //end of Request Id Tag
        
        //Beginning of Username tag
        xmlW.writeStartElement(null, 'UserName', null);
        xmlW.writeCharacters(userName);
        xmlW.writeEndElement();
        //End of Username tag
        
        //Beginning of ProductCode tag
        xmlW.writeStartElement(null,'ProductCode',null);
        xmlW.writeCharacters(oppProd.invoiceit_crmx__Product_Code__c);
        xmlW.writeEndElement();
        //End of ProductCode tag
        
        //Beginning of ProductName tag
        xmlW.writeStartElement(null,'ProductName',null);
        xmlW.writeCharacters(oppProd.Name);
        xmlW.writeEndElement();
        //End of ProductName tag
        
        String SAN = '' ;
        
        //Beginning of ServiceAccountName tag
        xmlW.writeStartElement(null,'ServiceAccountName',null);
        if(mapModifiedNameAndValue.containsKey('Service Account Name')) {
            SAN = mapModifiedNameAndValue.get('Service Account Name');
            //SAN=SAN.escapeHTML4();
            xmlw.writeCharacters(SAN);
        }        
        xmlW.writeEndElement();
        //End of ServiceAccountName tag
        
        //Beginning of CustomerNumber tag
        if(customerNumber != null) {
            xmlW.writeStartElement(null,'CustomerNumber',null);
                xmlW.writeCharacters(customerNumber);
            xmlW.writeEndElement();
        }
        else {
            xmlW.writeEmptyElement(null,'CustomerNumber',null);
        }
        //End of CustomerNumber tag
        
        //Beginning of AOP tag
        xmlW.writeStartElement(null,'AOP',null);
        if(mapModifiedNameAndValue.containsKey('AOP'))
            xmlw.writeCharacters(mapModifiedNameAndValue.get('AOP'));
        xmlW.writeEndElement();
        //End of AOP tag
        
        //Beginning of ProductDeliveryAddress tag
        xmlW.writeStartElement(null,'ProductDeliveryAddress',null);
        
        //Beginning of city tag
        xmlW.writeStartElement(null, 'City', null);
        if(mapModifiedNameAndValue.containsKey('City'))
            if(mapModifiedNameAndValue.get('City')!=null)
            xmlw.writeCharacters(mapModifiedNameAndValue.get('City'));
        xmlW.writeEndElement();
        //End of city tag
        
        //Beginning of county tag
        xmlW.writeStartElement(null, 'County', null);
        if(mapModifiedNameAndValue.containsKey('County'))
            if(mapModifiedNameAndValue.get('County')!=null)
                xmlw.writeCharacters(mapModifiedNameAndValue.get('County'));
        xmlW.writeEndElement();
        //End of county tag
        
        //Beginning of State tag
        xmlW.writeStartElement(null, 'State', null);
        if(mapModifiedNameAndValue.containsKey('State'))
            if(mapModifiedNameAndValue.get('State')!=null)
                xmlw.writeCharacters(mapModifiedNameAndValue.get('State'));
        xmlW.writeEndElement();
        //End of State tag
        
        //Beginning of Country tag
        xmlW.writeStartElement(null, 'Country', null);
        if(mapModifiedNameAndValue.containsKey('Country'))
            if(mapModifiedNameAndValue.get('Country')!=null)
                xmlw.writeCharacters(mapModifiedNameAndValue.get('Country'));
            //xmlW.writeCharacters(a.ShippingCountry);
        xmlW.writeEndElement();
        //End of Country tag
        
        xmlW.writeEndElement();
        //End of ProductDeliveryAddress tag
        
        xmlW.writeEndElement();
        //End of PendInventoryRequest tag
        
        requestXMLString = xmlW.getXmlString();
        System.debug('PendInventory Request :'+requestXMLString);
        
        return requestXMLString;
    }
    
    
    public static void parseResponseXML_PendInventoryResponse(List<String> lstResponseStrings,String accId) {
        String txtmsg;
        Map<String,String> mapRequestIdAndInventoryIds = new Map<String,String>(); //used for positive responses to update inventory id
        Map<String,String> mapRequestIdAndErrorText = new Map<String,String>();
        Map<String,String> mapRequestIdAndOpportunityId = new Map<String,String>();
        List<invoiceit_crmx__Opportunity_Product__c> lstOppProducts = new List<invoiceit_crmx__Opportunity_Product__c>();
        List<Case> lstCases = new List<Case>();
        AssignmentRule AR;
        Database.DMLOptions dmlOpts;
        try {
            for(String resp : lstResponseStrings) {
                if(resp.contains('RequestId')) {
                    Dom.Document response = new Dom.Document();
                    response.load(resp);
                    dom.Xmlnode res = response.getRootElement();
                    String uniqueId = res.getChildElement('RequestId', null).getText();
                    String []splitRequest = uniqueId.split('-');
                    String toUpdateId = splitRequest[0];
                    String respCode = res.getChildElement('HttpResponseCode', null).getText();
                    String isInventoryAvailable = res.getChildElement('IsInventoryAvailable', null).getText();
                    dom.Xmlnode res1 = res.getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null);
                    txtmsg = res1.getText();
                    System.debug('text message received is :'+txtmsg);
                    if(respCode == '200') {
                        String invId = res.getChildElement('InventoryId', null).getText();
                        System.debug('Inventory Id obtained is:'+invId);
                        mapRequestIdAndInventoryIds.put(toUpdateId,invId);
                        mapRequestIdAndErrorText.put(toUpdateId,txtmsg);
                    }
                    else {
                        String textNcode = respCode + '*' + txtmsg;
                        mapRequestIdAndErrorText.put(toUpdateId,textNcode);
                    }
                }
            }
            System.debug('mapRequestIdAndInventoryIds'+mapRequestIdAndInventoryIds.size()+'^^'+mapRequestIdAndInventoryIds);
            System.debug('mapRequestIdAndErrorText'+mapRequestIdAndErrorText.size()+'&&'+mapRequestIdAndErrorText);
            if(mapRequestIdAndInventoryIds.keyset() != null) {
                for(invoiceit_crmx__Opportunity_Product__c oppProd : [Select i.Name, i.InventoryId__c,Pend_Date__c , i.Id,i.Error_Text__c,i.invoiceit_crmx__Opportunity__c From invoiceit_crmx__Opportunity_Product__c i
                                                                      where i.Id in : mapRequestIdAndErrorText.keyset()]) {
                    mapRequestIdAndOpportunityId.put(oppProd.Id,oppProd.invoiceit_crmx__Opportunity__c);
                    if(mapRequestIdAndInventoryIds.containsKey(oppProd.Id) && mapRequestIdAndErrorText.containsKey(oppProd.Id)) {
                        oppProd.InventoryId__c = mapRequestIdAndInventoryIds.get(oppProd.Id);
                        if(oppProd.InventoryId__c != '' && oppProd.InventoryId__c != null){
                            oppProd.Pend_Date__c = Date.today();
                        }
                        oppProd.Error_Text__c = mapRequestIdAndErrorText.get(oppProd.Id);
                        lstOppProducts.add(oppProd);
                    }                                                       
                }
            }
            if(mapRequestIdAndErrorText.size()>0){
                //Fetching the assignment rules on case
                for(AssignmentRule assignRule : [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1]){
                    AR = assignRule;
                }
                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                dmlOpts = new Database.DMLOptions();
                if(AR!=null)
                    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            }
            /*for(String reqId : mapRequestIdAndErrorText.keyset()) {
                if(mapRequestIdAndErrorText.get(reqId) != '') {
                    Case c = new Case();
                    c.Status = 'New';
                    c.Priority = 'High';
                    c.Subject = 'PendInventory Request Error';
                    c.Description = mapRequestIdAndErrorText.get(reqId);
                    if(mapRequestIdAndOpportunityId.containsKey(reqId))
                        c.Parent_Opportunity__c = mapRequestIdAndOpportunityId.get(reqId);
                    c.AccountId = accId;
                    c.setOptions(dmlOpts);
                    lstCases.add(c);
                }    
            }*/
            if(lstOppProducts.size() > 0)
                Database.update(lstOppProducts);
            if(lstCases.size() > 0)
                Database.insert(lstCases);
        }
        catch(System.Exception e) {
            apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Issue in parsing :'+e.getMessage());
            apexpages.addMessage(am);
        }
    }
    
    
    
    @Future(callout = true)
    public static void releaseInventoryRequest(Set<Id> setOppProdIds,String userName) {
        String reqXML ='';
        String uName;
        uName = userName;
        List<String> lstResponseBody = new List<String>();
        List<Error_Log__c> lstErrLogs = new List<Error_Log__c>();
        //end points is stored in a custom setting - get values from there and use it here
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('ReleaseInventory');
        String endPoint = String.valueOf(endPts.Endpoint_URL__c);
        System.debug('**'+endPoint);
        String methodType = endPts.MethodType__c;
        System.debug('set passed is %% : '+setOppProdIds);
        //get custom setting value for restricting Integration calls //if true , do not send in calls // if false send in calls normally
        
        Restrict_Integration_Calls__c rCalls = Restrict_Integration_Calls__c.getValues('Restrict');
        System.debug('**'+rCalls);
        Boolean restrictCalls = Boolean.valueOf(rCalls.Restrict_Callouts__c);
        System.debug('a values is **'+restrictCalls);
        
        //code for authentication
        String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)     
        String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
        String privateKey = endPts.Private_Key__c;
        String publicKey  = endPts.Public_Key__c;  
        String apiKey = endPts.API_key__c;
       
        
        for(invoiceit_crmx__Opportunity_Product__c oppProd : [Select i.invoiceit_crmx__Product__c, i.invoiceit_crmx__Product_Code__c, 
                                                                     i.invoiceit_crmx__Opportunity__c, i.Name, i.IsInventoried__c, 
                                                                     i.InventoryId__c, i.customerNumber__c, i.Id From invoiceit_crmx__Opportunity_Product__c i
                                                               where i.Id in : setOppProdIds 
                                                               and (RecordType.DeveloperName = 'MDL_Opportunity_Product' or RecordType.DeveloperName = 'Nolo_Opportunity_Product') ALL ROWS]) {
            reqXML = MDL_Integration_Vim_Efs.constructXML_ReleaseInventory(oppProd,uName);  //get request XML from the static method
           //Added by Sai C
           // reqxml='xml='+ reqXML;
            system.debug('Reponse XML value '+reqxml);
                string ipayload   = 'publicKey='+ publicKey + '&' + 'timestamp=' + timeDifferenceInSeconds + '&' + 'xml=' + reqXML;
               // string ipayload   = 'Hello';
                System.debug ('ipayload'+ipayload);
                Blob textToBeHashedInBytes = Blob.valueOf(ipayload);
                Blob mac = Crypto.generateMac('HmacSHA256',Blob.valueOf(ipayload), Blob.valueOf(privateKey));
                String encodedText  = EncodingUtil.base64Encode(mac);
                String Header      =  encodedText + '|'+  timeDifferenceInSeconds;
                System.Debug('encodedText'+encodedText);
                String givenEndpoint   = endPts.Endpoint_URL__c;
                String encodedurl = EncodingUtil.urlEncode(givenEndpoint, 'UTF-8');
                system.debug(reqxml);
        try {
                            Http http = new Http(); //global class which is used in both request & response
                            HttpRequest req = new HttpRequest(); //initiate HTTP request
                            req.setEndpoint(givenEndpoint);
                            req.setMethod(methodType);
                            req.setTimeout(20000);
                            //req.setBody(reqXML); 
                            req.setBody(ipayload);
                            req.setHeader('Accept', 'application/xml');
                            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                            req.setHeader('Authorization', Header);
                            HTTPResponse res = http.send(req);
                    System.debug('Response Body : '+res.getBody()); 
                    if(res.getStatusCode() == 200){
                        Error_Log__c temp_error = MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody() , reqXML);
                        if(temp_error != null){
                            temp_error.XML_Mesaage_Type__c = 'ReleaseInventory';
                            lstErrLogs.add(temp_error);
                        }
                            
                    }   
                    
                    if(res.getStatusCode() == 400 || res.getStatusCode() == 401){
                        MDL_Integration_Vim_Efs.parseResponse400Error(res.getBody(),'ReleaseInventory',reqXML,oppProd.Id,'');
                    } 
                    else{
                        if(res.getStatusCode() != 500 && res.getStatusCode() != 502 && res.getStatusCode() != 404) { 
                            lstResponseBody.add(res.getBody());
                        }
                        else {
                            Error_Log__c err = new Error_Log__c();
                            err.XML_Mesaage_Type__c = 'ReleaseInventory';
                            err.XML_Body__c = reqXML;
                            err.Release_inventory_id__c = oppProd.Id;
                            err.Error_Reason__c = res.getStatusCode()+' : '+res.getStatus();
                            lstErrLogs.add(err);    
                     
                        } 
                    } 
                
               // else {
                 if(restrictCalls == true){
                    System.debug('No calls will be sent since custom setting is activated');
                } 
               //}  
             }                
            catch(System.CalloutException ce) {
                Error_Log__c err = new Error_Log__c();
                err.XML_Mesaage_Type__c = 'ReleaseInventory';
                err.XML_Body__c = reqXML;
                err.Release_inventory_id__c = oppProd.Id;
                err.Error_Reason__c = 'Problem with web service operation. Failed to make a callout to an external system.';
                lstErrLogs.add(err);    
            }
            catch(System.Exception e) {
                MDL_Integration_Vim_Efs.sendEmailInCaseOfException('Release Inventory',oppProd.Id,e.getMessage()); 
            }                                                            
        }
        
        if(lstErrLogs.size() > 0) {
            Database.insert(lstErrLogs);
        }
        MDL_Integration_Vim_Efs.parseResponseXML_ReleaseInventoryResponse(lstResponseBody);
    }
    
    //Method overloading to call release inventory when some service address attributes are changed
    @Future(callout = true)
    public static void releaseInventoryRequest(Set<Id> setOppProdIds,String userName,Map<Id,String> mapOpptyProdNInventoryId) {
        String reqXML ='';
        String uName;
        uName = userName;
        List<String> lstResponseBody = new List<String>();
        List<Error_Log__c> lstErrLogs = new List<Error_Log__c>();
        //end points is stored in a custom setting - get values from there and use it here
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('ReleaseInventory');
        String endPoint = String.valueOf(endPts.Endpoint_URL__c);
        System.debug('**'+endPoint);
        String methodType = endPts.MethodType__c;
        System.debug('set passed is %% : '+setOppProdIds);
        //get custom setting value for restricting Integration calls //if true , do not send in calls // if false send in calls normally
        
        Restrict_Integration_Calls__c rCalls = Restrict_Integration_Calls__c.getValues('Restrict');
        System.debug('**'+rCalls);
        Boolean restrictCalls = Boolean.valueOf(rCalls.Restrict_Callouts__c);
        System.debug('a values is **'+restrictCalls);
        
        //code for authentication
        String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)        
        String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
        String privateKey = endPts.Private_Key__c;
        String publicKey  =   endPts.Public_Key__c;  
        String apiKey = endPts.API_key__c;
      
        for(invoiceit_crmx__Opportunity_Product__c oppProd : [Select i.invoiceit_crmx__Product__c, i.invoiceit_crmx__Product_Code__c, 
                                                                     i.invoiceit_crmx__Opportunity__c, i.Name, i.IsInventoried__c, 
                                                                     i.InventoryId__c, i.customerNumber__c, i.Id From invoiceit_crmx__Opportunity_Product__c i
                                                               where i.Id in : setOppProdIds 
                                                               and (RecordType.DeveloperName = 'MDL_Opportunity_Product' or RecordType.DeveloperName = 'Nolo_Opportunity_Product') ALL ROWS]) {
            reqXML = MDL_Integration_Vim_Efs.constructXML_ReleaseInventory(oppProd,uName,mapOpptyProdNInventoryId.get(oppProd.Id));  //get request XML from the static method
           // reqxml='xml='+ reqXML;
            system.debug('Reponse XML value '+reqxml);
                string ipayload   = 'publicKey='+ publicKey + '&' + 'timestamp=' + timeDifferenceInSeconds + '&' + 'xml=' + reqXML;
               // string ipayload   = 'Hello';
                System.debug ('ipayload'+ipayload);
                Blob textToBeHashedInBytes = Blob.valueOf(ipayload);
                Blob mac = Crypto.generateMac('HmacSHA256',Blob.valueOf(ipayload), Blob.valueOf(privateKey));
                String encodedText  = EncodingUtil.base64Encode(mac);
                String Header      =  encodedText + '|'+  timeDifferenceInSeconds;
                System.Debug('encodedText'+encodedText);
                String givenEndpoint   = endPts.Endpoint_URL__c;
                String encodedurl = EncodingUtil.urlEncode(givenEndpoint, 'UTF-8');                                                       
            try {
                if(restrictCalls == false) {    
                    Http http = new Http(); //global class which is used in both request & response
                    HttpRequest req = new HttpRequest(); //initiate HTTP request
                    req.setEndpoint(givenEndpoint);
                    req.setMethod(methodType);
                    req.setTimeout(20000);
                    req.setBody(ipayload); 
                    req.setHeader('Accept', 'application/xml');
                    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    req.setHeader('Authorization', Header);
                    HTTPResponse res = http.send(req);
                    System.debug('Response Body : '+res.getBody()); 
                    if(res.getStatusCode() == 200){
                        Error_Log__c temp_error = MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody() , reqXML);
                        if(temp_error != null){
                            temp_error.XML_Mesaage_Type__c = 'ReleaseInventory';
                            lstErrLogs.add(temp_error);
                        }   
                    }
                    if(res.getStatusCode() == 400 || res.getStatusCode() == 401){
                        MDL_Integration_Vim_Efs.parseResponse400Error(res.getBody(),'ReleaseInventory',reqXML,oppProd.Id,'');
                    } 
                    else{  
                        if(res.getStatusCode() != 500 && res.getStatusCode() != 502 && res.getStatusCode() != 404) { 
                            lstResponseBody.add(res.getBody());
                        }
                        else {
                            Error_Log__c err = new Error_Log__c();
                            err.XML_Mesaage_Type__c = 'ReleaseInventory';
                            err.XML_Body__c = reqXML;
                            err.Release_inventory_id__c = oppProd.Id;
                            err.Error_Reason__c = res.getStatusCode()+' : '+res.getStatus();
                            lstErrLogs.add(err);    
                        } 
                    }
                }
                else if(restrictCalls == true){
                    System.debug('No calls will be sent since custom setting is activated');
                }                   
            }catch(System.CalloutException ce) {
                Error_Log__c err = new Error_Log__c();
                err.XML_Mesaage_Type__c = 'ReleaseInventory';
                err.XML_Body__c = reqXML;
                err.Release_inventory_id__c = oppProd.Id;
                err.Error_Reason__c = 'Problem with web service operation. Failed to make a callout to an external system.';
                lstErrLogs.add(err);    
            }
            catch(System.Exception e) {
                MDL_Integration_Vim_Efs.sendEmailInCaseOfException('Release Inventory',oppProd.Id,e.getMessage()); 
            }                                                            
        }
        if(lstErrLogs.size() > 0) {
            Database.insert(lstErrLogs);
        }
        system.debug('@@@@lstResponseBody '+lstResponseBody);
      
        MDL_Integration_Vim_Efs.parseResponseXML_ReleaseInventoryResponse(lstResponseBody);
    }
     
    public static String constructXML_ReleaseInventory(invoiceit_crmx__Opportunity_Product__c oppProd,String uName) {
        String requestXMLString = '';
        String xmlns = '';
        String cusNumber = '';
        //get xmlns value from custom setting
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('ReleaseInventory');
        xmlns = endPts.xmlns__c;
        
        //get server timestamp to send it in requestid
        DateTime result = DateTime.now();
        String timeStampString = result.format();//to convert datetime into string
        String reqID = oppProd.Id + '-' + timeStampString ;
        System.debug('RequestId ReleaseInventory Request :' + reqID);
        
        //get inventory id for the product
        String invID = ''+oppProd.InventoryId__c;
        
        //get customerNumber for the product
        if(oppProd.customerNumber__c != null)
            cusNumber = oppProd.customerNumber__c;
        
        //get serviceAccountName attribute value
        Map<String,String> mapAttributeNameAndValue = new Map<String,String>();
        list<Opportunity_Charge_Attribute__c> listOfOpptAttributes = new list<Opportunity_Charge_Attribute__c>();
        listOfOpptAttributes = [SELECT Attribute_Order__c,Picklist_Value__c,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c,Attribute_Picklist_Values__c,Phone_Value__c, Name,Attribute_Name__c,Attribute_Type__c,Boolean_Value__c,Date_Value__c,Number_Value__c,Opportunity_Rate_Plan_Charge__c,String_Value__c
                                    FROM Opportunity_Charge_Attribute__c
                                    WHERE Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c = : oppProd.invoiceit_crmx__Opportunity__c
                                    and (RecordType.DeveloperName = 'MDL_Opportunity_Charge_Attribute' or RecordType.DeveloperName = 'Nolo_Opportunity_Charge_Attribute')];
        for(Opportunity_Charge_Attribute__c att: listOfOpptAttributes) {
            if(att.String_Value__c != null)
                mapAttributeNameAndValue.put(att.Attribute_Name__c,att.String_Value__c);
            if(att.Picklist_Value__c != null)
                mapAttributeNameAndValue.put(att.Attribute_Name__c,att.Picklist_Value__c);
        }
        //construction of XML for release inventory
        Xmlstreamwriter xmlW = new Xmlstreamwriter();
        
        //Beginning of PendInventoryRequest tag
        xmlW.writeStartElement(null,'ReleaseInventoryRequest', null); 
        xmlW.writeAttribute(null,null,'xmlns',xmlns);
        
        //Beginning of requestId tag
        xmlW.writeStartElement(null,'RequestId',null);
        xmlW.writeCharacters(reqID);
        xmlW.writeEndElement();
        //end of Request Id Tag
        
        //Beginning of Username tag
        xmlW.writeStartElement(null, 'UserName', null);
        xmlW.writeCharacters(uName);
        xmlW.writeEndElement();
        //End of Username tag
        
        //Beginning of InventoryId tag
        xmlW.writeStartElement(null, 'InventoryId', null);
        xmlW.writeCharacters(invId);
        xmlW.writeEndElement();
        //End of InventoryID tag
        
        //Beginning of CustomerNumber tag
        if(cusNumber != null) {
            xmlW.writeStartElement(null, 'CustomerNumber', null);
                xmlW.writeCharacters(cusNumber);
            xmlW.writeEndElement();
        }
        else{
            xmlW.writeEmptyElement(null, 'CustomerNumber', null);
        }
        //End of CustomerNumber tag
        
        //Beginning of ServiceAccountName tag
        xmlW.writeStartElement(null, 'ServiceAccountName', null);
        if(mapAttributeNameAndValue.containsKey('Service Account Name'))
            xmlW.writeCharacters(mapAttributeNameAndValue.get('Service Account Name'));
        xmlW.writeEndElement();
        //End of ServiceAccountName tag
        
         xmlW.writeEndElement();
        //End of ReleaseInventoryRequest tag
        
        requestXMLString = xmlW.getXmlString();
        requestXMLString = xmlW.getXmlString();
        String reqXmlupdted = requestXMLString .replace('&','%26');
        String reqXmlupdted1 = reqXmlupdted.replace('+','%2B');
        System.debug('@@@@@reqXmlupdted1 :'+reqXmlupdted1); 
        return reqXmlupdted1 ;     
        
        System.debug('ReleaseInventory Request :'+requestXMLString);
        
        return requestXMLString;
    }
    
    public static String constructXML_ReleaseInventory(invoiceit_crmx__Opportunity_Product__c oppProd,String uName,String inventoryId) {
        String requestXMLString = '';
        String xmlns = '';
        String cusNumber = '';
        //get xmlns value from custom setting
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('ReleaseInventory');
        xmlns = endPts.xmlns__c;
        
        //get server timestamp to send it in requestid
        DateTime result = DateTime.now();
        String timeStampString = result.format();//to convert datetime into string
        String reqID = oppProd.Id + '-' + timeStampString ;
        System.debug('RequestId ReleaseInventory Request :' + reqID);
        
        //get inventory id for the product
        String invID = ''+inventoryId;
        
        //get customerNumber for the product
        if(oppProd.customerNumber__c != null)
            cusNumber = oppProd.customerNumber__c;
        
        //get serviceAccountName attribute value
        Map<String,String> mapAttributeNameAndValue = new Map<String,String>();
        list<Opportunity_Charge_Attribute__c> listOfOpptAttributes = new list<Opportunity_Charge_Attribute__c>();
        listOfOpptAttributes = [SELECT Attribute_Order__c,Picklist_Value__c,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c,Attribute_Picklist_Values__c,Phone_Value__c, Name,Attribute_Name__c,Attribute_Type__c,Boolean_Value__c,Date_Value__c,Number_Value__c,Opportunity_Rate_Plan_Charge__c,String_Value__c
                                    FROM Opportunity_Charge_Attribute__c
                                    WHERE Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c = : oppProd.invoiceit_crmx__Opportunity__c
                                    and (RecordType.DeveloperName = 'MDL_Opportunity_Charge_Attribute' or RecordType.DeveloperName = 'Nolo_Opportunity_Charge_Attribute')];
        for(Opportunity_Charge_Attribute__c att: listOfOpptAttributes) {
            if(att.String_Value__c != null)
                mapAttributeNameAndValue.put(att.Attribute_Name__c,att.String_Value__c);
            if(att.Picklist_Value__c != null)
                mapAttributeNameAndValue.put(att.Attribute_Name__c,att.Picklist_Value__c);
        }
        //construction of XML for release inventory
        Xmlstreamwriter xmlW = new Xmlstreamwriter();
        
        //Beginning of PendInventoryRequest tag
        xmlW.writeStartElement(null,'ReleaseInventoryRequest', null); 
        xmlW.writeAttribute(null,null,'xmlns',xmlns);
        
        //Beginning of requestId tag
        xmlW.writeStartElement(null,'RequestId',null);
        xmlW.writeCharacters(reqID);
        xmlW.writeEndElement();
        //end of Request Id Tag
        
        //Beginning of Username tag
        xmlW.writeStartElement(null, 'UserName', null);
        xmlW.writeCharacters(uName);
        xmlW.writeEndElement();
        //End of Username tag
        
        //Beginning of InventoryId tag
        xmlW.writeStartElement(null, 'InventoryId', null);
        xmlW.writeCharacters(invId);
        xmlW.writeEndElement();
        //End of InventoryID tag
        
        //Beginning of CustomerNumber tag
        if(cusNumber != null) {
            xmlW.writeStartElement(null, 'CustomerNumber', null);
                xmlW.writeCharacters(cusNumber);
            xmlW.writeEndElement();
        }
        else{
            xmlW.writeEmptyElement(null, 'CustomerNumber', null);
        }
        //End of CustomerNumber tag
        
        //Beginning of ServiceAccountName tag
        xmlW.writeStartElement(null, 'ServiceAccountName', null);
        if(mapAttributeNameAndValue.containsKey('Service Account Name'))
            xmlW.writeCharacters(mapAttributeNameAndValue.get('Service Account Name'));
        xmlW.writeEndElement();
        //End of ServiceAccountName tag
        
         xmlW.writeEndElement();
        //End of ReleaseInventoryRequest tag
        
        requestXMLString = xmlW.getXmlString();
        String reqXmlupdted = requestXMLString .replace('&','%26');
        String reqXmlupdted1 = reqXmlupdted.replace('+','%2B');
        System.debug('@@@@@reqXmlupdted1 :'+reqXmlupdted1); 
        return reqXmlupdted1 ;     
        System.debug('ReleaseInventory Request :'+requestXMLString);
        
        return requestXMLString;
    }
    
    public static void parseResponseXML_ReleaseInventoryResponse(List<String> lstResponses) {
        String txtmsg;
        Map<String,String> mapRequestIdAndErrorText = new Map<String,String>();
        Map<String,String> mapRequestIdAndAccountId = new Map<String,String>(); 
        Map<String,String> mapRequestIdAndOpportunityId = new Map<String,String>();
        Map<String,String> mapRequestIdAndOrderId = new Map<String,String>();
        List<invoiceit_s__Job_Product__c> lstOrderProdToUpdate = new List<invoiceit_s__Job_Product__c>();
        List<invoiceit_crmx__Opportunity_Product__c> lstOppProdToUpdate = new List<invoiceit_crmx__Opportunity_Product__c>();
        Set<String> setIdInvToBeBlanked = new Set<String>();                
        Set<String> setOrderProdIdToBeBlanked = new Set<String>();
        Set<String> setInventoryIds = new Set<String>();
        List<Case> lstCases = new List<Case>();
        String objectType = '';
        AssignmentRule AR;
        Database.DMLOptions dmlOpts;
        Schema.DescribeSObjectResult orderProduct = invoiceit_s__Job_Product__c.sObjectType.getDescribe();
        String keyPrefixOrderProduct = orderProduct.getKeyPrefix();
        Schema.DescribeSObjectResult oppProduct = invoiceit_crmx__Opportunity_Product__c.sObjectType.getDescribe();
        String keyPrefixOppProduct = oppProduct.getKeyPrefix();
        System.debug('keyPrefixOrderProduct'+keyPrefixOrderProduct+'keyPrefixOppProduct'+keyPrefixOppProduct);
        for(String resp : lstResponses) {
            Dom.Document response = new Dom.Document();
            response.load(resp);
            dom.Xmlnode res = response.getRootElement();
            String uniqueId = res.getChildElement('RequestId', null).getText();
            String []splitRequest = uniqueId.split('-');
            String toUpdateId = splitRequest[0];
            if(objectType==''){
                if(toUpdateId!='null' && toUpdateId!=''){
                    String prefix = toUpdateId.subString(0,3);
                    System.debug('prefix'+prefix);
                    if(prefix==keyPrefixOrderProduct){
                        objectType = 'OrderProduct';
                    }
                    else if(prefix==keyPrefixOppProduct){
                        objectType = 'OpportunityProduct';
                    }
                }
            }
            String respCode = res.getChildElement('HttpResponseCode', null).getText();
            String isCancelled = res.getChildElement('IsCancelled', null).getText();
            String inventoryId = res.getChildElement('InventoryId', null).getText();
            dom.Xmlnode res1 = res.getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null);
            txtmsg = res1.getText();
            System.debug('text message received is :'+txtmsg);
            if(isCancelled=='true') {                
                setIdInvToBeBlanked.add(toUpdateId);
                if(objectType == 'OrderProduct'){ 
                    setOrderProdIdToBeBlanked.add(toUpdateId);
                    setInventoryIds.add(inventoryId);
                }              
            }
            else {
                String textNcode = respCode + '*' + txtmsg;
                mapRequestIdAndErrorText.put(toUpdateId,textNcode);                
            }
        }
        System.debug('<><>objectType<><>'+objectType);
        if(objectType=='OrderProduct'){
            if(setIdInvToBeBlanked.size() > 0){
                for(invoiceit_s__Job_Rate_Plan_Charge__c jobRPC : [Select Id,Created_From_Charge__c,Created_From_Charge__r.invoiceit_s__Status__c,Created_From_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c from invoiceit_s__Job_Rate_Plan_Charge__c where invoiceit_s__Status__c = 'Cancelled' and invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c in :setInventoryIds]){
                    if(!setOrderProdIdToBeBlanked.contains(jobRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c)){
                        setOrderProdIdToBeBlanked.add(jobRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c);
                    }
                }
                for(invoiceit_s__Job_Product__c orderProd : [Select Id,Inventory_Id__c from invoiceit_s__Job_Product__c where Id in :setOrderProdIdToBeBlanked]){
                    orderProd.Inventory_Id__c = '';
                    lstOrderProdToUpdate.add(orderProd);
                }                
            }
            for(invoiceit_s__Job_Product__c orderProd : [Select Id,invoiceit_s__Job__r.invoiceit_s__Account__c,invoiceit_s__Job__c from invoiceit_s__Job_Product__c where Id in :mapRequestIdAndErrorText.keyset()]){
                mapRequestIdAndAccountId.put(orderProd.Id,orderProd.invoiceit_s__Job__r.invoiceit_s__Account__c);
                mapRequestIdAndOrderId.put(orderProd.Id,orderProd.invoiceit_s__Job__c);
            }           
        }
        else if(objectType=='OpportunityProduct'){
            if(setIdInvToBeBlanked.size() > 0){
                for(invoiceit_crmx__Opportunity_Product__c oppProd : [Select Id,InventoryId__c from invoiceit_crmx__Opportunity_Product__c where Id in :setIdInvToBeBlanked]){
                    oppProd.InventoryId__c = '';
                    //oppProd.Pend_Date__c = null;
                    lstOppProdToUpdate.add(oppProd);
                }
            }
            for(invoiceit_crmx__Opportunity_Product__c oppProd : [select Id,invoiceit_crmx__Opportunity__r.AccountId,invoiceit_crmx__Opportunity__c from invoiceit_crmx__Opportunity_Product__c where Id in :mapRequestIdAndErrorText.keyset() ALL ROWS]){
                mapRequestIdAndAccountId.put(oppProd.Id,oppProd.invoiceit_crmx__Opportunity__r.AccountId);
                mapRequestIdAndOpportunityId.put(oppProd.Id,oppProd.invoiceit_crmx__Opportunity__c);
           }
        }
                

        if(mapRequestIdAndErrorText.size()>0){
            //Fetching the assignment rules on case
                for(AssignmentRule assignRule : [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1]){
                    AR = assignRule;
                }
                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                dmlOpts = new Database.DMLOptions();
                if(AR!=null)
                    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        }
        for(String reqId : mapRequestIdAndErrorText.keyset()) {
            if(mapRequestIdAndAccountId.containsKey(reqId)){
                Case c = new Case();
                c.Status = 'New';
                c.Priority = 'High';
                c.Subject = 'ReleaseInventory Request Error';
                c.Description = mapRequestIdAndErrorText.get(reqId);            
                c.AccountId = mapRequestIdAndAccountId.get(reqId);
                c.setOptions(dmlOpts);
                if(mapRequestIdAndOpportunityId.containsKey(reqId))
                    c.Parent_Opportunity__c = mapRequestIdAndOpportunityId.get(reqId);
                if(mapRequestIdAndOrderId.containsKey(reqId))
                    c.Parent_Order__c = mapRequestIdAndOrderId.get(reqId);
                lstCases.add(c);
            }
        }
        if(lstCases.size() > 0)
            Database.insert(lstCases);
        if(lstOppProdToUpdate.size() > 0){
            Database.update(lstOppProdToUpdate);
        }
        if(lstOrderProdToUpdate.size() > 0){
            Database.update(lstOrderProdToUpdate);
        }
    }
    
    
    public static void releaseInventoryRequestFromBatch(Set<Id> setOppProdIds,String userName) {
        String reqXML ='';
        String uName;
        uName = userName;
        List<String> lstResponseBody = new List<String>();
        List<Error_Log__c> lstErrLogs = new List<Error_Log__c>();
        //end points is stored in a custom setting - get values from there and use it here
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('ReleaseInventory');
        String endPoint = String.valueOf(endPts.Endpoint_URL__c);
        System.debug('**'+endPoint);
        String methodType = endPts.MethodType__c;
        System.debug('set passed is %% : '+setOppProdIds);
        //code for authentication
        String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)
        String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
        String privateKey = endPts.Private_Key__c;
        String publicKey  =   endPts.Public_Key__c;  
        String apiKey = endPts.API_key__c;
        
        //get custom setting value for restricting Integration calls //if true , do not send in calls // if false send in calls normally
        
        Restrict_Integration_Calls__c rCalls = Restrict_Integration_Calls__c.getValues('Restrict');
        System.debug('**'+rCalls);
        Boolean restrictCalls = Boolean.valueOf(rCalls.Restrict_Callouts__c);
        System.debug('a values is **'+restrictCalls);
        
        for(invoiceit_crmx__Opportunity_Product__c oppProd : [Select i.invoiceit_crmx__Product__c, i.invoiceit_crmx__Product_Code__c, 
                                                                     i.invoiceit_crmx__Opportunity__c, i.Name, i.IsInventoried__c, 
                                                                     i.InventoryId__c, i.customerNumber__c, i.Id From invoiceit_crmx__Opportunity_Product__c i
                                                               where i.Id in : setOppProdIds 
                                                               and (RecordType.DeveloperName = 'MDL_Opportunity_Product' or RecordType.DeveloperName = 'Nolo_Opportunity_Product') ALL ROWS]) {
            reqXML = MDL_Integration_Vim_Efs.constructXML_ReleaseInventory(oppProd,uName);  //get request XML from the static method
             string ipayload   = 'publicKey='+ publicKey + '&' + 'timestamp=' + timeDifferenceInSeconds + '&' + 'xml=' + reqXML;
               // string ipayload   = 'Hello';
                System.debug ('ipayload'+ipayload);
                Blob textToBeHashedInBytes = Blob.valueOf(ipayload);
                Blob mac = Crypto.generateMac('HmacSHA256',Blob.valueOf(ipayload), Blob.valueOf(privateKey));
                String encodedText  = EncodingUtil.base64Encode(mac);
                String Header      =  encodedText + '|'+  timeDifferenceInSeconds;
                System.Debug('encodedText'+encodedText);
                String givenEndpoint   = endPts.Endpoint_URL__c;
                String encodedurl = EncodingUtil.urlEncode(givenEndpoint, 'UTF-8');                                                       
            try {
                if(restrictCalls == false) {    
                    Http http = new Http(); //global class which is used in both request & response
                    HttpRequest req = new HttpRequest(); //initiate HTTP request
                    req.setEndpoint(givenEndpoint);
                    req.setMethod(methodType);
                    req.setTimeout(20000);
                    req.setBody(ipayload); 
                    req.setHeader('Accept', 'application/xml');
                    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    req.setHeader('Authorization', Header);
                    HTTPResponse res = http.send(req);
                    if(res.getStatusCode() == 200){
                        Error_Log__c temp_error = MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody() , reqXML);
                        if(temp_error != null){
                            temp_error.XML_Mesaage_Type__c = 'ReleaseInventory';
                            lstErrLogs.add(temp_error);
                        }   
                    }
                    
                    System.debug('Response Body in releaseinventory is : '+res.getBody());
                    if(res.getStatusCode() == 400 || res.getStatusCode() == 401){
                        MDL_Integration_Vim_Efs.parseResponse400Error(res.getBody(),'ReleaseInventory',reqXML,oppProd.Id,'');
                    } 
                    else{
                        if(res.getStatusCode() != 500 && res.getStatusCode() != 404 && res.getStatusCode() != 502) { 
                            lstResponseBody.add(res.getBody());
                        }
                        else {
                            Error_Log__c err = new Error_Log__c();
                            err.XML_Mesaage_Type__c = 'ReleaseInventory';
                            err.XML_Body__c = reqXML;
                            err.Release_inventory_id__c = oppProd.Id;
                            err.Error_Reason__c = res.getStatusCode()+' : '+res.getStatus();
                            lstErrLogs.add(err);    
                        }
                    }
                }
                else if(restrictCalls == true) {
                    System.debug('No calls will be sent since custom setting is activated');
                }
            }catch(System.CalloutException ce) {
                Error_Log__c err = new Error_Log__c();
                err.XML_Mesaage_Type__c = 'ReleaseInventory';
                err.XML_Body__c = reqXML;
                err.Release_inventory_id__c = oppProd.Id;
                err.Error_Reason__c = 'Problem with web service operation. Failed to make a callout to an external system.';
                lstErrLogs.add(err);    
            }
            catch(System.Exception e) {
                MDL_Integration_Vim_Efs.sendEmailInCaseOfException('Release Inventory',oppProd.Id,e.getMessage());
            }         
        }
        if(lstErrLogs.size() > 0) {
            Database.insert(lstErrLogs);
        }
        MDL_Integration_Vim_Efs.parseResponseXML_ReleaseInventoryResponse(lstResponseBody);
    }
    
    
    @Future(callout = true)
    public static void releaseInventoryRequestForOrderCancellation(List<Id> lstOrderProds,String userName,Map<Id,String> mapOrderProdNInventoryId) {
        String reqXML ='';
        String uName;
        uName = userName;
        List<String> lstResponseBody = new List<String>();
        List<Error_Log__c> lstErrLogs = new List<Error_Log__c>();
        //end points is stored in a custom setting - get values from there and use it here
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('ReleaseInventory');
        String endPoint = String.valueOf(endPts.Endpoint_URL__c);
        System.debug('**'+endPoint); 
        String methodType = endPts.MethodType__c;
        System.debug('set passed is %% : '+lstOrderProds);
        //code for authentication
        String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)
       
        String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
        String privateKey = endPts.Private_Key__c;
        String publicKey  =   endPts.Public_Key__c;
        String apiKey = endPts.API_key__c;
        
        Restrict_Integration_Calls__c rCalls = Restrict_Integration_Calls__c.getValues('Restrict');
        System.debug('**'+rCalls);
        Boolean restrictCalls = Boolean.valueOf(rCalls.Restrict_Callouts__c);
        System.debug('a values is **'+restrictCalls);
        
        for(invoiceit_s__Job_Product__c orderProd : [Select i.invoiceit_s__Product__c, i.invoiceit_s__Product_Code__c, 
                                                                     i.Name,i.Customer_Number__c,i.invoiceit_s__Job__c,
                                                                     i.Inventory_Id__c, i.Tracking_Number__c, i.Id 
                                                                     From invoiceit_s__Job_Product__c i
                                                                     where i.Id in : lstOrderProds 
                                                                     and (RecordType.DeveloperName = 'MDL_Order_Product' or RecordType.DeveloperName = 'Nolo_Order_Product') ALL ROWS]) {
            System.debug('*****'+orderProd.Inventory_Id__c);
            reqXML = MDL_Integration_Vim_Efs.constructXML_ReleaseInventoryForOrderCancellation(orderProd,uName,mapOrderProdNInventoryId.get(orderProd.Id));    //get request XML from the static method
                string ipayload   = 'publicKey='+ publicKey + '&' + 'timestamp=' + timeDifferenceInSeconds + '&' + 'xml=' + reqXML;
                System.debug ('ipayload'+ipayload);
                Blob textToBeHashedInBytes = Blob.valueOf(ipayload);
                Blob mac = Crypto.generateMac('HmacSHA256',Blob.valueOf(ipayload), Blob.valueOf(privateKey));
                String encodedText  = EncodingUtil.base64Encode(mac);
                String Header      =  encodedText + '|'+  timeDifferenceInSeconds;
                System.Debug('encodedText'+encodedText);
                String givenEndpoint   = endPts.Endpoint_URL__c;
                String encodedurl = EncodingUtil.urlEncode(givenEndpoint, 'UTF-8');                                                       
            try {
                if(restrictCalls == false) {    
                    Http http = new Http(); //global class which is used in both request & response
                    HttpRequest req = new HttpRequest(); //initiate HTTP request
                    req.setEndpoint(givenEndpoint);
                    req.setMethod(methodType);
                    req.setTimeout(20000);
                    req.setBody(ipayload); 
                    req.setHeader('Accept', 'application/xml');
                    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    req.setHeader('Authorization', Header);
                    HTTPResponse res = http.send(req);
                    if(res.getStatusCode() == 200){
                        Error_Log__c temp_error = MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody() , reqXML);
                        if(temp_error != null)
                            lstErrLogs.add(temp_error);
                    }
                    if(res.getStatusCode() == 400 || res.getStatusCode() == 401){
                        MDL_Integration_Vim_Efs.parseResponse400Error(res.getBody(),'ReleaseInventory',reqXML,orderProd.Id,'');
                    } 
                    else{  
                        if(res.getStatusCode() != 500 && res.getStatusCode() != 404 && res.getStatusCode() != 502) { 
                            lstResponseBody.add(res.getBody());
                        }
                        else {
                            Error_Log__c err = new Error_Log__c();
                            err.XML_Mesaage_Type__c = 'ReleaseInventory';
                            err.XML_Body__c = reqXML;
                            err.Release_inventory_id__c = orderProd.Id;
                            err.Error_Reason__c = res.getStatusCode()+' : '+res.getStatus();
                            lstErrLogs.add(err);    
                        }
                    }
                }
                else if(restrictCalls == true) {
                    System.debug('No calls will be sent since custom setting is activated');
                }
            }catch(System.CalloutException ce) {
                Error_Log__c err = new Error_Log__c();
                err.XML_Mesaage_Type__c = 'ReleaseInventory';
                err.XML_Body__c = reqXML;
                err.Release_inventory_id__c = orderProd.Id;
                err.Error_Reason__c = 'Problem with web service operation. Failed to make a callout to an external system.';
                lstErrLogs.add(err);    
            }
            catch(System.Exception e) {
                MDL_Integration_Vim_Efs.sendEmailInCaseOfException('Release Inventory',orderProd.Id,e.getMessage());
            }     
        }
        if(lstErrLogs.size() > 0) {
            Database.insert(lstErrLogs);
        }
        MDL_Integration_Vim_Efs.parseResponseXML_ReleaseInventoryResponse(lstResponseBody);
    }
    
    
    
    public static void releaseInventoryRequestForOrderCancellationFromBatch(List<Id> lstOrderProds,String userName) {
        String reqXML ='';
        String uName;
        uName = userName;
        List<String> lstResponseBody = new List<String>();
        List<Error_Log__c> lstErrLogs = new List<Error_Log__c>();
        //end points is stored in a custom setting - get values from there and use it here
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('ReleaseInventory');
        String endPoint = String.valueOf(endPts.Endpoint_URL__c);
        System.debug('**'+endPoint); 
        String methodType = endPts.MethodType__c;
        System.debug('set passed is %% : '+lstOrderProds);
        //code for authentication
        String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)
        
        String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
        String privateKey = endPts.Private_Key__c;
        String publicKey  =   endPts.Public_Key__c;  
        String apiKey = endPts.API_key__c;
        
        Restrict_Integration_Calls__c rCalls = Restrict_Integration_Calls__c.getValues('Restrict');
        System.debug('**'+rCalls);
        Boolean restrictCalls = Boolean.valueOf(rCalls.Restrict_Callouts__c);
        System.debug('a values is **'+restrictCalls);
        
        for(invoiceit_s__Job_Product__c orderProd : [Select i.invoiceit_s__Product__c, i.invoiceit_s__Product_Code__c, 
                                                                     i.Name,i.Customer_Number__c,i.invoiceit_s__Job__c,
                                                                     i.Inventory_Id__c, i.Tracking_Number__c, i.Id 
                                                                     From invoiceit_s__Job_Product__c i
                                                                     where i.Id in : lstOrderProds 
                                                                     and (RecordType.DeveloperName = 'MDL_Order_Product' or RecordType.DeveloperName = 'Nolo_Order_Product') ALL ROWS]) {
            System.debug('*****'+orderProd.Inventory_Id__c);
            reqXML = MDL_Integration_Vim_Efs.constructXML_ReleaseInventoryForOrderCancellation(orderProd,uName,'');    //get request XML from the static method
             string ipayload   = 'publicKey='+ publicKey + '&' + 'timestamp=' + timeDifferenceInSeconds + '&' + 'xml=' + reqXML;
               // string ipayload   = 'Hello';
                System.debug ('ipayload'+ipayload);
                Blob textToBeHashedInBytes = Blob.valueOf(ipayload);
                Blob mac = Crypto.generateMac('HmacSHA256',Blob.valueOf(ipayload), Blob.valueOf(privateKey));
                String encodedText  = EncodingUtil.base64Encode(mac);
                String Header      =  encodedText + '|'+  timeDifferenceInSeconds;
                System.Debug('encodedText'+encodedText);
                String givenEndpoint   = endPts.Endpoint_URL__c;
                String encodedurl = EncodingUtil.urlEncode(givenEndpoint, 'UTF-8');                                                       
            try {
                if(restrictCalls == false) {    
                    Http http = new Http(); //global class which is used in both request & response
                    HttpRequest req = new HttpRequest(); //initiate HTTP request
                    req.setEndpoint(givenEndpoint);
                    req.setMethod(methodType);
                    req.setTimeout(20000);
                    req.setBody(ipayload); 
                    req.setHeader('Accept', 'application/xml');
                    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    req.setHeader('Authorization', Header);
                    HTTPResponse res = http.send(req);
                    System.debug('Response Body in releaseinventory is : '+res.getBody());
                    if(res.getStatusCode() == 200){
                        Error_Log__c temp_error = MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody() , reqXML);
                        if(temp_error != null)
                            lstErrLogs.add(temp_error);
                    }
                    if(res.getStatusCode() == 400 || res.getStatusCode() == 401){
                        MDL_Integration_Vim_Efs.parseResponse400Error(res.getBody(),'ReleaseInventory',reqXML,orderProd.Id,'');
                    } 
                    else{  
                        if(res.getStatusCode() != 500 && res.getStatusCode() != 404 && res.getStatusCode() != 502) { 
                            lstResponseBody.add(res.getBody());
                        }
                        else {
                            Error_Log__c err = new Error_Log__c();
                            err.XML_Mesaage_Type__c = 'ReleaseInventory';
                            err.XML_Body__c = reqXML;
                            err.Release_inventory_id__c = orderProd.Id;
                            err.Error_Reason__c = res.getStatusCode()+' : '+res.getStatus();
                            lstErrLogs.add(err);    
                        }
                    }
                }
                else if(restrictCalls == true) {
                    System.debug('No calls will be sent since custom setting is activated');
                }
            }catch(System.CalloutException ce) {
                Error_Log__c err = new Error_Log__c();
                err.XML_Mesaage_Type__c = 'ReleaseInventory';
                err.XML_Body__c = reqXML;
                err.Release_inventory_id__c = orderProd.Id;
                err.Error_Reason__c = 'Problem with web service operation. Failed to make a callout to an external system.';
                lstErrLogs.add(err);    
            }
            catch(System.Exception e) {
                MDL_Integration_Vim_Efs.sendEmailInCaseOfException('Release Inventory',orderProd.Id,e.getMessage());
            }     
        }
        if(lstErrLogs.size() > 0) {
            Database.insert(lstErrLogs);
        }
        MDL_Integration_Vim_Efs.parseResponseXML_ReleaseInventoryResponse(lstResponseBody);
    } 
    
    
    public static String constructXML_ReleaseInventoryForOrderCancellation(invoiceit_s__Job_Product__c orderProd,String uName,String inventoryId) {
        String requestXMLString = '';
        String xmlns = '';
        String cusNumber = '';
        //get xmlns value from custom setting
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('ReleaseInventory');
        xmlns = endPts.xmlns__c;
        
        //get server timestamp to send it in requestid
        DateTime result = DateTime.now();
        String timeStampString = result.format();//to convert datetime into string
        String reqID = orderProd.Id + '-' + timeStampString ;
        System.debug('RequestId ReleaseInventory Request :' + reqID);
        String invId = '';
        //get inventory id for the product
        if(inventoryId==''){
            invId = orderProd.Inventory_Id__c;
        }
        else{
            invId = inventoryId;
        }
        
        
        //get customerNumber for the product
        if(orderProd.Customer_Number__c != null)
            cusNumber = orderProd.Customer_Number__c;
        
        //get serviceAccountName attribute value
        Map<String,String> mapAttributeNameAndValue = new Map<String,String>();
        list<Order_Charge_Attribute__c> listOforderAttributes = new list<Order_Charge_Attribute__c>();
        listOfOrderAttributes = [SELECT Attribute_Order__c,Picklist_Value__c,
                                    Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c,
                                    Attribute_Picklist_Values__c,Phone_Value__c, Name,Attribute_Name__c,Attribute_Type__c,
                                    Boolean_Value__c,Date_Value__c,Number_Value__c,Order_Rate_Plan_Charge__c,String_Value__c
                                    FROM Order_Charge_Attribute__c
                                    WHERE Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c = : orderProd.invoiceit_s__Job__c
                                    and (RecordType.DeveloperName = 'MDL_Order_Charge_Attribute' or RecordType.DeveloperName = 'Nolo_Order_Charge_Attribute')];
        
        for(Order_Charge_Attribute__c att: listOfOrderAttributes) {
            if(att.String_Value__c != null)
                mapAttributeNameAndValue.put(att.Attribute_Name__c,att.String_Value__c);
            if(att.Picklist_Value__c != null)
                mapAttributeNameAndValue.put(att.Attribute_Name__c,att.Picklist_Value__c);
        }
        //construction of XML for release inventory
        Xmlstreamwriter xmlW = new Xmlstreamwriter();
        
        //Beginning of PendInventoryRequest tag
        xmlW.writeStartElement(null,'ReleaseInventoryRequest', null); 
        xmlW.writeAttribute(null,null,'xmlns',xmlns);
        
        //Beginning of requestId tag
        xmlW.writeStartElement(null,'RequestId',null);
        xmlW.writeCharacters(reqID);
        xmlW.writeEndElement();
        //end of Request Id Tag
        
        //Beginning of Username tag
        xmlW.writeStartElement(null, 'UserName', null);
        xmlW.writeCharacters(uName);
        xmlW.writeEndElement();
        //End of Username tag
        
        //Beginning of InventoryId tag
        xmlW.writeStartElement(null, 'InventoryId', null);
        xmlW.writeCharacters(invId);
        xmlW.writeEndElement();
        //End of InventoryID tag
        
        //Beginning of CustomerNumber tag
        if(cusNumber != null) {
            xmlW.writeStartElement(null, 'CustomerNumber', null);
                xmlW.writeCharacters(cusNumber);
            xmlW.writeEndElement();
        }
        else{
            xmlW.writeEmptyElement(null, 'CustomerNumber', null);
        }
        //End of CustomerNumber tag
        
        //Beginning of ServiceAccountName tag
        xmlW.writeStartElement(null, 'ServiceAccountName', null);
        if(mapAttributeNameAndValue.containsKey('Service Account Name'))
            xmlW.writeCharacters(mapAttributeNameAndValue.get('Service Account Name'));
        xmlW.writeEndElement();
        //End of ServiceAccountName tag
        
         xmlW.writeEndElement();
        //End of ReleaseInventoryRequest tag
        
        requestXMLString = xmlW.getXmlString();
        System.debug('ReleaseInventory Request :'+requestXMLString);
        
        return requestXMLString;
    }
    
    
    //Beginning of order Request Function 
    public static void orderRequestFromBatch(Set<Id>orderIds,String userName,Set<Id>orderRPCIds) {
        String reqXML;
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        List<String> lstResponseBody = new List<String>();
        List<Error_Log__c> lstErrLogs = new List<Error_Log__c>();
        List<invoiceit_crmx__Opportunity_Product__c> lstOppProdsFromOpp = new List<invoiceit_crmx__Opportunity_Product__c>();
        List<invoiceit_crmx__Opportunity_Product__c> lstOppProdToUpdate = new List<invoiceit_crmx__Opportunity_Product__c>();
        Map<Id,Error_Log__c> mapIdNExistingErrLogs = new Map<Id,Error_Log__c>();
        List<Error_Log__c> lstExistingErrLogs = new List<Error_Log__c>();
        Set<Id> setOrderIds = new Set<Id>();
        
        /**************release inventory logic ********************/
          //Map<Order Id, Set<Order Product Id>> --> this map is used to release inventories
        Map<Id,Set<Id>> orderIdVsOrderProducts = new Map<Id,Set<Id>>();
        List<invoiceit_s__Job_Product__c> orderProdstoRelease = new List<invoiceit_s__Job_Product__c>();
        //Map<orderId, list of opportunities>
        Map<Id,List<Opportunity>> orderIdVsOpportunites      =  new Map<Id,List<Opportunity>>();
        Map<Id,List<Opportunity>> MHorderIdVsOpportunites      =  new Map<Id,List<Opportunity>>();
        List<Opportunity> oppstoClosedLost                   = new List<Opportunity>();
        Set<Id> oppIds        = new Set<Id>();
        List<invoiceit_crmx__Opportunity_Product__c> oppProdstoRelease = new List<invoiceit_crmx__Opportunity_Product__c>();
        //End for Release Inventory Logic 
        
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('OrderRequest');
        String endPoint = String.valueOf(endPts.Endpoint_URL__c);
        String methodType = endPts.MethodType__c;
        
         /****************added by akash ***************************/
        List<invoiceit_s__Job_Rate_Plan_Charge__c>orpcList             = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        
        
        
        //code for authentication
        String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)        
        String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
        String privateKey = endPts.Private_Key__c;
        String publicKey  =   endPts.Public_Key__c;
        String apiKey = endPts.API_key__c;
        
        Restrict_Integration_Calls__c rCalls = Restrict_Integration_Calls__c.getValues('Restrict');
        System.debug('**'+rCalls);
        Boolean restrictCalls = Boolean.valueOf(rCalls.Restrict_Callouts__c);
        System.debug('a values is **'+restrictCalls);
        
        
        //Checking if Order XML already exists in Error Log, if exists do not send that order , queue it along with the existing order
        for(Error_Log__c err : [Select e.XML_Mesaage_Type__c, e.XML_Body__c, e.Sent_Successfully__c, e.Order_Number__c,e.Order_Name__c,e.Error_Reason__c, e.Name, e.Id,e.Re_process_date_time__c 
                                From Error_Log__c e
                                Where e.XML_Mesaage_Type__c = 'OrderRequest' AND e.Order_Number__c in :orderIds] ) {
                mapIdNExistingErrLogs.put(err.Id,err);                  
        }
        
        Map<Id,invoiceit_s__Job__c> mapOrderIdNOrder = new Map<Id,invoiceit_s__Job__c>();
        Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>>mapOrderIdNLstOrderProds = new Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>>();
        Map<Id,List<invoiceit_s__Job_Product__c>>mapOrderIdNOrderProducts = new Map<Id,List<invoiceit_s__Job_Product__c>>();
        Map<Id,List<Order_Charge_Attribute__c>> mapOrderIdNLstOrderCharges = new Map<Id,List<Order_Charge_Attribute__c>>();
        for(invoiceit_s__Job__c orderObj : [Select i.invoiceit_s__Account__r.MH_Cust_Number__c, 
                                                   i.invoiceit_s__Account__c, i.OrderNumber__c,
                                                   i.invoiceit_s__Account__r.Org_Id__c,i.RecordType.DeveloperName,
                                                   i.Name, i.Id,i.Fulfillment_Date__c 
                                                   From invoiceit_s__Job__c i where i.Id in : orderIds
                                                   and (RecordType.DeveloperName = 'MH_Orders' or RecordType.DeveloperName = 'Nolo_Order' or RecordType.DeveloperName = 'M_NG_Order')]) {
            setOrderIds.add(orderObj.Id);
            mapOrderIdNOrder.put(orderObj.Id,orderObj);
        }
        System.debug('orderIds'+orderIds);
        System.debug('mapOrderIdNOrder'+mapOrderIdNOrder);
        for(invoiceit_s__Job_Product__c orderProduct : [Select Id, Name, invoiceit_s__Job__c, invoiceit_s__Description__c, invoiceit_s__Product_Code__c, 
                                                   invoiceit_s__Product_Family__c, invoiceit_s__Product__c, invoiceit_s__SequenceNumber__c, Tracking_Number__c, 
                                                   Inventory_Id__c, Customer_Number__c, Sin_Number__c From invoiceit_s__Job_Product__c where invoiceit_s__Job__c in :setOrderIds]){
            if(mapOrderIdNOrderProducts.containsKey(orderProduct.invoiceit_s__Job__c)){
                mapOrderIdNOrderProducts.get(orderProduct.invoiceit_s__Job__c).add(orderProduct);
            }
            else{
                mapOrderIdNOrderProducts.put(orderProduct.invoiceit_s__Job__c,new List<invoiceit_s__Job_Product__c>{orderProduct});
            }
            
        }
        
        
        //get Orderproducts for an order
        for(invoiceit_s__Job_Rate_Plan_Charge__c  orderProd : [Select   i.Name,i.invoiceit_s__Status__c, i.invoiceit_s__Job_Rate_Plan__c, i.Cancel_Date__c , i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Sin_Number__c,i.Chat_Parent_Order_Rate_Plan_Charge__r.SIN__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name,i.Chat_Parent_Order_Rate_Plan_Charge__r.name,
                                                                        i.SIN__c,i.invoiceit_s__Accounting_Code__c ,i.Live_Date__c,i.invoiceit_s__Order__r.Parent_Order__r.name,i.invoiceit_s__Order__r.RecordType.DeveloperName,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c,i.RecordType.DeveloperName,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id,i.Fulfilment_Start_Date__c,i.Chat_ID__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.CreatedDate,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Customer_Number__c,
                                                                        (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                                                                        SystemModstamp, LastActivityDate, Attribute_Name__c, Attribute_Order__c, Attribute_Picklist_Values__c, 
                                                                        Attribute_Type__c, Boolean_Value__c, Date_Value__c, Maximum_No_Of_Characters_In_Text__c, 
                                                                        Minimum_No_Of_Characters_In_Text__c, Number_Value__c, Order_Rate_Plan_Charge__c, Phone_Value__c, 
                                                                        Picklist_Value__c, String_Value__c,Value_Id__c From Order_Charge_Attributes__r),
                                                                        
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.IsInventoried__c,
                                                                        i.invoiceit_s__Service_End_Date__c,i.invoiceit_s__Service_Activation_Date__c, i.Renew_Rebase_Truncate_Date__c,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,invoiceit_s__Job_Rate_Plan_Charge__c.invoiceit_s__Order__c
                                                                        From invoiceit_s__Job_Rate_Plan_Charge__c i 
                                                                        where Id in :orderRPCIds]) {
            if(mapOrderIdNLstOrderProds.containsKey(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c)){
                mapOrderIdNLstOrderProds.get(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c).add(orderProd);
            }
            else{
                mapOrderIdNLstOrderProds.put(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c,new List<invoiceit_s__Job_Rate_Plan_Charge__c>{orderProd});
            } 
            
            
            /***************to release inventories logic************************************************/
            if(orderIdVsOrderProducts.containsKey(orderProd.invoiceit_s__Order__c)){
                    orderIdVsOrderProducts.get(orderProd.invoiceit_s__Order__c).add(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c);                                                            
             }
             else{
                 orderIdVsOrderProducts.put(orderProd.invoiceit_s__Order__c, new Set<Id>{orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c});
             }                                                                    
            //End For Release Inventory 
            /*************************added by akash****************************/                                                                 
           orpcList.add(orderProd);  
                              
        }
        
        // Release Inv. Logic
        
         for(opportunity opp : [select id, Name ,StageName,Created_From_Order__c,Closed_lost_from_Order__c,
                                      Reason_Won_Lost__c,Ngage_Upsell_Order__c ,                                                                          
                                      (select id,Name,IsInventoried__c,InventoryId__c
                                                                 From invoiceit_crmx__Opportunity_Products__r
                                                                 where IsInventoried__c = 'TRUE' and 
                                                                       InventoryId__c != NULL)
                                      From opportunity
                               where (StageName != 'Closed won'  AND  StageName != 'Closed Lost') AND (Created_From_Order__c IN:mapOrderIdNLstOrderProds.keySet() OR Ngage_Upsell_Order__c IN:mapOrderIdNLstOrderProds.keySet()) ]){
                if(orderIdVsOpportunites.containsKey(opp.Created_From_Order__c)){
                    orderIdVsOpportunites.get(opp.Created_From_Order__c).add(opp);                   
                }
                else{
                    orderIdVsOpportunites.put(opp.Created_From_Order__c,new List<Opportunity>{opp});                   
               } 
               
                //Sai : 12/07/2018
              //added New logic to closed MH Order related Opportunities when order Expired
                                  system.debug('@@@@@ Expired MH order on Opty '+opp.Ngage_Upsell_Order__c);
                                   if (opp.Ngage_Upsell_Order__c != NULL) {
                                       if(MHorderIdVsOpportunites.containsKey(opp.Ngage_Upsell_Order__c)){
                                            MHorderIdVsOpportunites.get(opp.Ngage_Upsell_Order__c).add(opp);                   
                                        }
                                    else{
                                            MHorderIdVsOpportunites.put(opp.Ngage_Upsell_Order__c,new List<Opportunity>{opp});                   
                                        } 
                                   }                 
        }
        // End of Release Inv. Logic
        
         /*************added by akash ******************/
        Map<id,Chat_Product_Order_Charge__c> orpcIdVschatOrpc = new Map<id,Chat_Product_Order_Charge__c>();
        if(!mapOrderIdNLstOrderProds.isEmpty()){
            orpcIdVschatOrpc = MDL_OnDemandOrderXML.getchatproductsMap(orpcList);
        }
        //get OrderRatePlanCharges For a Particular Order
        //for(invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge : [])
        //get Order Charge Attributes for an order
        /*for(Order_Charge_Attribute__c orderCharges : [SELECT Attribute_Order__c,Picklist_Value__c,
                                    Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c,
                                    Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,
                                    Attribute_Picklist_Values__c,Phone_Value__c, Name,Attribute_Name__c,Attribute_Type__c,
                                    Boolean_Value__c,Date_Value__c,Number_Value__c,Order_Rate_Plan_Charge__c,String_Value__c
                                    FROM Order_Charge_Attribute__c
                                    WHERE Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c in : orderIds
                                    AND Order_Rate_Plan_Charge__r.invoiceit_s__Service_End_Date__c = YESTERDAY]) {
            if(mapOrderIdNLstOrderCharges.containsKey(orderCharges.Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c)){
                mapOrderIdNLstOrderCharges.get(orderCharges.Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c).add(orderCharges);
            }
            else{
                mapOrderIdNLstOrderCharges.put(orderCharges.Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c,new List<Order_Charge_Attribute__c>{orderCharges});
            } 
        }*/
        System.debug('OrderIds$$$'+orderIds);
        System.debug('mapOrderIdNLstOrderProds:::'+mapOrderIdNLstOrderProds);
        //System.debug('mapOrderIdNLstOrderCharges&&&'+mapOrderIdNLstOrderCharges);
        System.debug('mapOrderIdNOrder***'+mapOrderIdNOrder);
        for(Id orderId : orderIds) {
            if(mapOrderIdNLstOrderProds.containsKey(orderId) && mapOrderIdNOrder.containsKey(orderId)) { 
                System.debug('before method call');
               // reqXML = 'Hello';
                reqXML=MDL_Integration_Vim_Efs.constructXML_OrderRequestFromBatch(userName,mapOrderIdNLstOrderProds.get(orderId),mapOrderIdNOrder.get(orderId),mapOrderIdNOrderProducts.get(orderId),orpcIdVschatOrpc);
                system.debug('reqxml'+reqxml);
                string ipayload   = 'publicKey='+ publicKey + '&' + 'timestamp=' + timeDifferenceInSeconds + '&' + 'xml=' + reqXML;
               // string ipayload   = 'Hello';
                System.debug ('ipayload'+ipayload);
                Blob textToBeHashedInBytes = Blob.valueOf(ipayload);
                Blob mac = Crypto.generateMac('HmacSHA256',Blob.valueOf(ipayload), Blob.valueOf(privateKey));
                String encodedText  = EncodingUtil.base64Encode(mac);
                String Header      =  encodedText + '|'+  timeDifferenceInSeconds;
                System.Debug('encodedText'+encodedText);
                String givenEndpoint   = endPts.Endpoint_URL__c;
                String encodedurl = EncodingUtil.urlEncode(givenEndpoint, 'UTF-8');
                
                
                if(restrictCalls == false) {
                    if(mapIdNExistingErrLogs.containsKey(orderId)) {
                        Error_Log__c err = new Error_Log__c();
                        err.XML_Mesaage_Type__c = 'OrderRequest';
                        err.XML_Body__c = reqXML;
                        err.Order_Number__c = orderId;
                        err.Error_Reason__c = 'Previous instance of the same order exists in the Error log';
                        err.Order_Name__c = mapOrderIdNOrder.get(orderId).Name;
                        lstExistingErrLogs.add(err);
                    }
                    else {
                        try{
                            Http http = new Http(); //global class which is used in both request & response
                            HttpRequest req = new HttpRequest(); //initiate HTTP request
                            req.setEndpoint(givenEndpoint);
                            req.setMethod(methodType);
                            req.setTimeout(20000);
                            //req.setBody(reqXML); 
                            req.setBody(ipayload);
                            req.setHeader('Accept', 'application/xml');
                            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                
                            //req.setHeader('Authorization', aToken);
                            //req.setHeader('Content-Type', 'text/xml');
                            //req.setHeader('Authorization', aToken);
                            req.setHeader('Authorization', Header);
                            HTTPResponse res = http.send(req);
                            if(res.getStatusCode() == 200){
                                Error_Log__c temp_error = MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody() , reqXML);
                                
                                /************logic to release inventory ******************************************/
                                if(!orderIdVsOrderProducts.isEmpty() && orderIdVsOrderProducts.containsKey(orderId)){
                                    for(Id orderProdId : orderIdVsOrderProducts.get(orderId)){
                                        invoiceit_s__Job_Product__c orderprod = new invoiceit_s__Job_Product__c(Id =orderProdId, Inventory_Id__c='' );
                                        orderProdstoRelease.add(orderprod);
                                    }
                                }
                                if(!orderIdVsOpportunites.isEmpty() && orderIdVsOpportunites.containsKey(orderId)){
                                    for(Opportunity opp :orderIdVsOpportunites.get(orderId) ){
                                        opp.StageName = 'Closed Lost';
                                        opp.Reason_Won_Lost__c = 'Administrative';
                                        opp.Closed_lost_from_Order__c= True;
                                        oppstoClosedLost.add(opp);
                                        oppIds.add(opp.id);
                                        for(invoiceit_crmx__Opportunity_Product__c oppProd : opp.invoiceit_crmx__Opportunity_Products__r){
                                            oppProd.InventoryId__c = '';
                                            oppProdstoRelease.add(oppProd);
                                            
                                        }
                                    }
                                }
                                
                                 //Sai : 12/07/2018
                               //added New logic to closed MH Order related Opportunities when order Expired
                                 if(!MHorderIdVsOpportunites.isEmpty() && MHorderIdVsOpportunites.containsKey(orderId)){
                                    for(Opportunity opp :MHorderIdVsOpportunites.get(orderId) ){
                                        opp.StageName = 'Closed Lost';
                                        opp.Reason_Won_Lost__c = 'Administrative';
                                        opp.Closed_lost_from_Order__c= True;
                                        oppstoClosedLost.add(opp);
                                        oppIds.add(opp.id);
                                        for(invoiceit_crmx__Opportunity_Product__c oppProd : opp.invoiceit_crmx__Opportunity_Products__r){
                                            oppProd.InventoryId__c = '';
                                            oppProdstoRelease.add(oppProd);
                                            
                                        }
                                    }
                                }
                                //End For Release Inv. Logic 
                                
                                if(temp_error != null){
                                    temp_error.XML_Mesaage_Type__c = 'OrderRequest';
                                    lstErrLogs.add(temp_error);
                                }   
                            }
                            System.debug('Response Body in order Message is : '+res.getBody());
                            if(res.getStatusCode() == 400 || res.getStatusCode() == 401){                               
                                MDL_Integration_Vim_Efs.parseResponse400Error(res.getBody(),'OrderRequest',reqXML,orderId,mapOrderIdNOrder.get(orderId).Name);                              
                            }
                            else{
                                if(res.getStatusCode() != 500 && res.getStatusCode() != 404 && res.getStatusCode() != 502) { 
                                    lstResponseBody.add(res.getBody());
                                }
                                else {
                                    Error_Log__c err = new Error_Log__c();
                                    err.XML_Mesaage_Type__c = 'OrderRequest';
                                    err.XML_Body__c = reqXML;
                                    err.Order_Number__c = orderId;
                                    err.Error_Reason__c = res.getStatusCode()+' : '+res.getStatus();
                                    err.Order_Name__c = mapOrderIdNOrder.get(orderId).Name;
                                    lstErrLogs.add(err);    
                                }
                            }
                        }catch(System.CalloutException ce) {
                            Error_Log__c err = new Error_Log__c();
                            err.XML_Mesaage_Type__c = 'OrderRequest';
                            err.XML_Body__c = reqXML;
                            err.Order_Number__c = orderId;
                            err.Order_Name__c = mapOrderIdNOrder.get(orderId).Name;
                            err.Error_Reason__c = 'Problem with web service operation. Failed to make a callout to an external system.';
                            lstErrLogs.add(err);
                        }
                        catch(System.Exception e) {
                            MDL_Integration_Vim_Efs.sendEmailInCaseOfException('Order XML Request',orderId,e.getMessage());
                        }
                    }
                }
                else if(restrictCalls == true) {
                    System.debug('No calls will be sent since custom setting is activated');
                }                     
            }
        }
          if(!oppIds.isEmpty()){
                  
                  voidenvelope(oppIds);
              }
              
            if(lstExistingErrLogs.size() > 0)
                Database.upsert(lstExistingErrLogs);
            if(lstErrLogs.size() > 0)
                Database.upsert(lstErrLogs);
                
            //Added For Release Inv Logic
             if(!orderProdstoRelease.isEmpty()){
              database.update(orderProdstoRelease);
          }
          if(!oppstoClosedLost.isEmpty()){
              database.update(oppstoClosedLost);
                MDL_BatchAutoEvergreenHandler.releaseOrderProductInventoriesBatch(oppIds);
              //MDL_trgHandlerforOppRenew_Rebase.voidingenvelopefrombatch(oppstoClosedLost);
          }
          if(!oppProdstoRelease.isEmpty()){
              //database.update(oppProdstoRelease);
          }
          //End for Release Inv.    
            //MDL_Integration_Vim_Efs.insertLogs(lstExistingErrLogs,lstErrLogs);
        
        MDL_Integration_Vim_Efs.parseResponseXML_OrderResponse(lstResponseBody);
        //updating opp statuses 
        /*for(Opportunity opp : mapOrderIdNOpp.values()) {
            opp.StageName ='Closed Lost';
            opp.Reason_Won_Lost__c = 'Auto Renew';
            lstOppToUpdate.add(opp);
            lstOppProdsFromOpp = opp.getSObjects('invoiceit_crmx__Opportunity_Products__r');
            if(lstOppProdsFromOpp != null) {
                for(invoiceit_crmx__Opportunity_Product__c oppProd : lstOppProdsFromOpp) {
                    oppProd.InventoryId__c = null;
                    lstOppProdToUpdate.add(oppProd);
                }
            }
        }*/
        /*if(lstOppToUpdate.size()>0)
            Database.update(lstOppToUpdate);
        if(lstOppProdToUpdate.size()>0)
            Database.update(lstOppProdToUpdate);*/
    }
    /*@future
    public static void insertLogs(List<Error_Log__c> lstExistingErrLogs,List<Error_Log__c> lstErrLogs){
        if(lstExistingErrLogs.size() > 0)
                Database.insert(lstExistingErrLogs);
        if(lstErrLogs.size() > 0)
                Database.insert(lstErrLogs);
    }*/
    public static String constructXML_OrderRequest(String uName,List<invoiceit_s__Job_Rate_Plan_Charge__c> lstOrderProds,invoiceit_s__Job__c orderObj,Map<id,Chat_Product_Order_Charge__c> orpcIdVschatOrpc) {
        String reqXML = '';
        String xmlns = '';
        //Logic for generating line item id
        DateTime result1 = DateTime.now();
        String timeStamp = result1.format('yyyy/MM/dd HH:mm:ss');//to convert datetime into string
        System.debug('timeStamp'+timeStamp);
        String[] str1 = timeStamp.split(' ');
        String[] str2 = str1[0].split('/');
        String[] str3 = str1[1].split(':');
        String lineItemId = str2[0]+str2[1]+str2[2]+str3[0]+str3[1]+str3[2];
        System.debug('Id is:'+lineItemId);
        //end of logic - line itemid
        String postDate = '';
        String []validatedDateValue;
        Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>> mapOrderProdIdNLstOrderChargesForOrderProduct = new Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>>();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> lstOrderRPCForAProduct = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();

        //lstOrderCharges contains all charges present under an order, so split it to have values like charges under each orderproduct
        for(invoiceit_s__Job_Rate_Plan_Charge__c orderCharges : lstOrderProds) {
            if(mapOrderProdIdNLstOrderChargesForOrderProduct.containsKey(orderCharges.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c)){
                mapOrderProdIdNLstOrderChargesForOrderProduct.get(orderCharges.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c).add(orderCharges);
            }
            else{
                mapOrderProdIdNLstOrderChargesForOrderProduct.put(orderCharges.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,new List<invoiceit_s__Job_Rate_Plan_Charge__c>{orderCharges});
            }
        }
        System.debug('map order products N List Order Charges&&&'+mapOrderProdIdNLstOrderChargesForOrderProduct);
        //get xmlns value from custom setting
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('OrderRequest');
        xmlns = endPts.xmlns__c;
        
        //get server timestamp to send it in requestid
        DateTime result = DateTime.now();
        String timeStampString = result.format();//to convert datetime into string
        String reqID = orderObj.Id + '-' + timeStampString ;
        System.debug('RequestId Order Request :' + reqID);
        
        //construction of XML for release inventory
        Xmlstreamwriter xmlW = new Xmlstreamwriter();
        
        //Beginning of OrderRequest tag
        xmlW.writeStartElement(null,'OrderRequest', null); 
        xmlW.writeAttribute(null,null,'xmlns',xmlns);
        
        //Beginning of requestId tag
        xmlW.writeStartElement(null,'RequestId',null);
        xmlW.writeCharacters(reqID);
        xmlW.writeEndElement();
        //end of Request Id Tag
        
        //Beginning of Order tag
        xmlW.writeStartElement(null,'Order', null); 

        //Beginning of Username tag
        xmlW.writeStartElement(null, 'UserName', null);
        xmlW.writeCharacters(uName);
        xmlW.writeEndElement();
        //End of Username tag
        
        //Beginning of CustomerNumber tag
        if(orderObj.invoiceit_s__Account__r.MH_Cust_Number__c != null) {
            xmlW.writeStartElement(null, 'CustomerNumber', null);
                xmlW.writeCharacters(orderObj.invoiceit_s__Account__r.MH_Cust_Number__c);
            xmlW.writeEndElement();
        }
        else {
            xmlW.writeEmptyElement(null, 'CustomerNumber', null);
        }
        //End of CustomerNumber tag
        
        
         //Beginning of OrgID tag: added on 05/01/2016 by akash
        if(orderObj.invoiceit_s__Account__r.Org_Id__c != null){
             xmlW.writeStartElement(null, 'OrgId', null);
             xmlW.writeCharacters(orderObj.invoiceit_s__Account__r.Org_Id__c);
            xmlW.writeEndElement();
            //End of OrgId tag
        }
       
        
        
        
        //Beginning of OrderNumber tag
        xmlW.writeStartElement(null, 'OrderNumber', null);
            xmlW.writeCharacters(orderObj.Name);
        xmlW.writeEndElement();
        //End of OrderNumber tag
        
        //beginning of Products tag
        xmlW.writeStartElement(null,'Products',null);
        System.debug('Order Id is'+orderObj.Id+'Order Products Number&&'+orderObj.invoiceit_s__Job_Product__r.size());
        
        //getting products for charges sent in the Order Req
        
        for(invoiceit_s__Job_Product__c jobProds : orderObj.invoiceit_s__Job_Product__r) {
            
            if(mapOrderProdIdNLstOrderChargesForOrderProduct.containsKey(jobProds.Id)) {
            
                //Beginning of Product tag
                xmlW.writeStartElement(null,'Product', null); 
                
                //Beginning of ProductId tag
                xmlW.writeStartElement(null,'ProductId',null);
                    xmlW.writeCharacters(jobProds.Id);
                xmlW.writeEndElement();
                //End of ProductId tag
                
                //Beginning of SubscriptionIdentificationNumber tag
                xmlW.writeStartElement(null,'SubscriptionIdentificationNumber',null);
                    if(jobProds.Sin_Number__c != null)
                        xmlW.writeCharacters(jobProds.Sin_Number__c);
                xmlW.writeEndElement();
                //End of SubscriptionIdentificationNumber tag
                
                //Beginning of ProductCode tag
                xmlW.writeStartElement(null,'ProductCode',null);
                    xmlW.writeCharacters(jobProds.invoiceit_s__Product_Code__c);
                xmlW.writeEndElement();
                //End of ProductCode tag
                
                //Beginning of LineItems tag
                xmlW.writeStartElement(null,'LineItems', null); 
                
                //filtering order charges based on a product
                lstOrderRPCForAProduct = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
               
                for(invoiceit_s__Job_Rate_Plan_Charge__c oRpc : lstOrderProds) {
                    
                    if(oRpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id == jobProds.Id) {
                        lstOrderRPCForAProduct.add(oRpc);
                    }
                }
                
                
                Map<id,Chat_Product_Order_Charge__c> orderChildToChatProductMap = MDL_OnDemandOrderXML.getchatproductsChildMap(lstOrderRPCForAProduct);
                System.debug('Order Charges Number=='+lstOrderRPCForAProduct.size());
                for(invoiceit_s__Job_Rate_Plan_Charge__c orderProd : lstOrderRPCForAProduct) {
                    Chat_Product_Order_Charge__c junctionObj = orderChildToChatProductMap.get(orderProd.Id);
                    System.debug('&&orderProducts Details&&'+orderProd);
                    //Beginning of LineItem tag
                    xmlW.writeStartElement(null,'LineItem', null);
                    
                    //Beginning of LineItemId tag
                    xmlW.writeStartElement(null, 'LineItemId', null);
                    xmlW.writeCharacters(orderProd.Id+lineItemId);
                    xmlW.writeEndElement();
                    //End of LineItemId tag
                    
                    //Beginning of SubscriptionIdentificationNumber tag
                    if(orderProd.Sin__c != null) {
                        xmlW.writeStartElement(null, 'SubscriptionIdentificationNumber', null);
                            xmlW.writeCharacters(orderProd.SIN__c);
                        xmlW.writeEndElement();
                    }
                    else {
                        xmlW.writeEmptyElement(null, 'SubscriptionIdentificationNumber', null);
                    }
                    //End of SubscriptionIdentificationNumber tag
                    
                    //Beginning of ProductCode tag
                    if(orderProd.invoiceit_s__Accounting_Code__c  != null) {
                        xmlW.writeStartElement(null, 'ProductCode', null);
                            xmlW.writeCharacters(orderProd.invoiceit_s__Accounting_Code__c);
                        xmlW.writeEndElement();
                    }
                    else {
                        xmlW.writeEmptyElement(null,'ProductCode', null);
                    }
                    //End of ProductCode tag
                    
                    //Beginning of ProductName tag
                    if(orderProd.Name != null) {
                        xmlW.writeStartElement(null, 'ProductName', null);
                            xmlW.writeCharacters(orderProd.Name);
                        xmlW.writeEndElement();
                    }
                    else {
                        xmlW.writeEmptyElement(null, 'ProductName', null);
                    }
                    //End of ProductName tag
                    
                    
                    
                     boolean toCreateCancelDateXml = false;
                    
                    //Beginning of Status tag
                    xmlW.writeStartElement(null, 'Status', null);
                    if(orderProd.invoiceit_s__Status__c != null) {
                        string status = '';
                        if(orderProd.invoiceit_s__Status__c == 'Active' || orderProd.invoiceit_s__Status__c == 'Renewed' || orderProd.invoiceit_s__Status__c == 'Rebased' )
                        //commented by Sai C
                        //|| (orderProd.invoiceit_s__Status__c == 'Truncated' && orderProd.invoiceit_s__Service_End_Date__c > Date.today()))
                            //xmlW.writeCharacters('Active'); 
                          status ='Active';
                        if(orderProd.invoiceit_s__Status__c == 'Cancelled' || orderProd.invoiceit_s__Status__c == 'Expired' || (orderProd.invoiceit_s__Status__c == 'Truncated' && orderProd.invoiceit_s__Service_End_Date__c < Date.today())){
                            //xmlW.writeCharacters('Cancel'); 
                           status = 'Cancel';
                            
                        }
                           //Commented by Sai C
                          If(((orderProd.invoiceit_s__Price_Type__c == 'One Time' && orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Shippable__c == 'Yes' && orderProd.Fulfilment_Start_Date__c== null)|| (orderProd.invoiceit_s__Price_Type__c == 'Monthly'|| orderProd.invoiceit_s__Price_Type__c == 'Annual' )) && orderProd.invoiceit_s__Status__c == 'Truncated' ) 
                          //((orderProd.invoiceit_s__Price_Type__c == 'One Time'|| orderProd.invoiceit_s__Price_Type__c == 'Monthly' ) && orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Shippable__c == 'Yes'&& orderProd.invoiceit_s__Status__c == 'Truncated' && orderProd.Fulfilment_Start_Date__c== null) 
                         /*if((orderProd.Name.contains('Law Directory - Full Set')
                           || orderProd.Name.contains('MH Bar Register Set')
                           || orderProd.Name.contains('Law Directory - Individual Volume')
                           || orderProd.Name.contains('Law Directory DVD')) 
                            && orderProd.invoiceit_s__Status__c == 'Truncated'*/
                            //commented for one time shippable
                      // /*&& orderProd.invoiceit_s__Price_Type__c == 'One Time'*/)
                     {
                           //xmlW.writeCharacters('Cancel'); 
                           status = 'Cancel';
                           toCreateCancelDateXml = true;
                       }  
                        if(status!= null && status!= ''){
                            xmlW.writeCharacters(status);
                        } 
                    }           
                    xmlW.writeEndElement();
                    //End of Status tag
                    
                    
                    
                    
                    //Beginning of PostDate tag
                    xmlW.writeStartElement(null, 'PostDate', null);
                    postDate = String.valueOf(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.CreatedDate);
                    validatedDateValue = postDate.split(' ');
                    xmlW.writeCharacters(validatedDateValue[0]);
                    xmlW.writeEndElement();
                    //End of PostDate tag
                                                
                    //Beginning of FulfillmentDate tag
                    if(orderProd.Fulfilment_Start_Date__c != null) {
                        if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != 'System Fulfillment' && (orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != null || orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != '')) { 
                            xmlW.writeStartElement(null, 'FulfillmentDate', null);
                            xmlW.writeCharacters(String.valueOf(orderProd.Fulfilment_Start_Date__c));
                            xmlW.writeEndElement();
                        }
                    }
                    //commenting the else part so as to not send in the fulfillment date in case value is not there
                    /*else {
                        xmlW.writeEmptyElement(null, 'FulfillmentDate', null);
                    }*/
                    //End of FulfillmentDate tag
                    
                    //Beginning of CancelDate tag
                    /*if(orderProd.invoiceit_s__Price_Type__c == 'One Time' && orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Shippable__c == 'Yes') {
                        System.debug('cancel date will not be set for one time shippable product');
                    }*/
                    if(orderProd.invoiceit_s__Status__c == 'Cancelled') { 
                        if(orderProd.Cancel_Date__c != null) {
                            xmlW.writeStartElement(null, 'CancelDate', null);
                                xmlW.writeCharacters(String.valueOf(orderProd.Cancel_Date__c));  
                            xmlW.writeEndElement();
                        }
                    }
                    else if(orderProd.invoiceit_s__Status__c == 'Expired' || (orderProd.invoiceit_s__Status__c == 'Truncated' && orderProd.invoiceit_s__Service_End_Date__c < Date.today())) {
                        if(orderProd.invoiceit_s__Service_End_Date__c != null) {
                            xmlW.writeStartElement(null, 'CancelDate', null);
                                System.debug('service end of charge past its service end date is::'+String.valueOf(orderProd.invoiceit_s__Service_End_Date__c));
                                xmlW.writeCharacters(String.valueOf(orderProd.invoiceit_s__Service_End_Date__c));  
                            xmlW.writeEndElement();
                        }
                    }
                    //added by sai
                    //creating cancel date xml tag only in case of trucated status scenario
                    else if(toCreateCancelDateXml){
                        if(orderProd.Renew_Rebase_Truncate_Date__c != null){
                            xmlW.writeStartElement(null, 'CancelDate', null);
                            xmlW.writeCharacters(string.valueOf(orderProd.Renew_Rebase_Truncate_Date__c));
                            xmlW.writeEndElement();
                        }
                        
                    }
                    //commenting the else part so as to not send in the cancel date in case value is not there
                    /*else {
                        xmlW.writeEmptyElement(null, 'CancelDate', null);
                    }*/
                    //End of CancelDate tag
                    
                    //Beginning of IsProductInventoried tag
                    xmlW.writeStartElement(null, 'IsProductInventoried', null);
                    if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.IsInventoried__c != null)
                        xmlW.writeCharacters(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.IsInventoried__c);
                    xmlW.writeEndElement();
                    //End of IsProductInventoried tag
                    
                    
                     /*//Beginning of HasChildProducts tag*************************added by akash
                    xmlW.writeStartElement(null, 'HasChildProducts', null);
                    if(!orpcIdVschatOrpc.isEmpty() && orpcIdVschatOrpc.containsKey(orderProd.id)){
                        xmlW.writeCharacters('Y');
                    }
                    else{
                        xmlW.writeCharacters('N');
                    }
                    xmlW.writeEndElement();
                   */ //End of HasChildProducts tag
                   
                    //Beginning of HasparentProducts tag*************************added by akash
                    xmlW.writeStartElement(null, 'HasParentProducts', null);
                    System.debug('@@@@orderProd.invoiceit_s__Order__r.Parent_Order__c'+orderProd.invoiceit_s__Order__r.Parent_Order__c);
                    System.debug('@@@orderProd.Chat_Parent_Order_Rate_Plan_Charge__c'+orderProd.Chat_Parent_Order_Rate_Plan_Charge__c);
                    System.debug('@@@@orderProd.invoiceit_s__Order__r.RecordType.developername'+orderProd.invoiceit_s__Order__r.RecordType.developername);
                    
                    if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name == 'Ngage Live Chat - External Website'){
                        xmlW.writeCharacters('N');
                    }
                    
                    else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name == NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name == '')&& orderProd.invoiceit_s__Order__r.RecordType.developername == 'Nolo_Order'){
                        xmlW.writeCharacters('N');
                    }
                      else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name == NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name == '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == '')){
                        xmlW.writeCharacters('N');
                    }
                      else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name != NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name != '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == '')){
                        xmlW.writeCharacters('Y');                        
                    }
                    else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name != NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name != '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name != NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name != '')){
                        xmlW.writeCharacters('Y');
                    }   
                    xmlW.writeEndElement();
                    //End of HasparentProducts tag
                    
                    //Beginning of ParentProductSIN tag***********added by akash
                    xmlW.writeStartElement(null, 'ParentProductSIN', null);
                     
                    if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name == 'Ngage Live Chat - External Website'){
                        xmlW.writeCharacters('');
                    }
                    else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name == NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name == '')&& orderProd.invoiceit_s__Order__r.RecordType.developername == 'Nolo_Order'){
                        xmlW.writeCharacters('');
                    }
                      else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name == NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name == '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == '')){
                        xmlW.writeCharacters('');
                    }
                      else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name != NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name != '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == '')){
                        xmlW.writeCharacters(junctionObj.Chat_Product_Order_Rate_Plan_Charge__r.SIN__c);                        
                    }
                    else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name != NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name != '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name != NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name != '')){
                        xmlW.writeCharacters(orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.SIN__c);
                    }   
                    xmlW.writeEndElement();
                    //End of HasparentProducts tag 
                    
                    // if(orderProd.invoiceit_s__Accounting_Code__c == '01510'){
                        //Need to create these two fields :Akash
                        //Begin of FulfilledBy Tag
                        xmlW.writeStartElement(null, 'FulfilledBy', null);
                           
                        xmlW.writeEndElement();
                        //End of FulfilledBy tag
                    
                        //Begin of FulfillmentID Tag
                        xmlW.writeStartElement(null, 'FulfillmentID', null);
                             if(orderProd.Chat_ID__c != null){
                                xmlW.writeCharacters(orderProd.Chat_ID__c);
                             }
                            else{
                                xmlW.writeCharacters(' ');
                            }
                        xmlW.writeEndElement();
                        //End of FulfillmentID tag
                    //}
                    
                    // Adding Service Start Date Tag for Charges by Sai C
                        xmlW.writeStartElement(null, 'ServiceStartDate', null);
                        if(orderProd.invoiceit_s__Service_Activation_Date__c != null){
                        xmlW.writeCharacters(String.valueOf(orderProd.invoiceit_s__Service_Activation_Date__c));  
                        }
                        else{
                            xmlW.writeCharacters('');
                        }
                        xmlW.writeEndElement();
                     // End of Service Start date Tag for charges 
                     // 
                     // Adding Service End Date Tag for Charges by Sai C
                        xmlW.writeStartElement(null, 'ServiceEndDate', null);
                        if(orderProd.invoiceit_s__Service_End_Date__c != null){
                        xmlW.writeCharacters(String.valueOf(orderProd.invoiceit_s__Service_End_Date__c));  
                        }
                        else{
                            xmlW.writeCharacters('');
                        }
                        xmlW.writeEndElement();
                     // End of Service End date Tag for charges 
                     
                     // Adding Service End Date Tag for Charges 
                        xmlW.writeStartElement(null, 'LiveDate', null);
                        if(orderProd.Live_Date__c != null){
                        xmlW.writeCharacters(String.valueOf(orderProd.Live_Date__c));  
                        }
                        else{
                            xmlW.writeCharacters('');
                        }
                        xmlW.writeEndElement();
                     // End of Service End date Tag for charges
                    
                    
                    
                    //beginning of Attributes tag
                    xmlW.writeStartElement(null, 'Attributes', null);
                    
                    //beginning of Attribute tag
                    xmlW.writeStartElement(null, 'Attribute', null);
                    
                    //Beginning of Inventory Id Attribute Name tag
                    xmlW.writeStartElement(null, 'Name', null);
                    xmlW.writeCharacters('InventoryId');
                    xmlW.writeEndElement();
                    //End of Inventory Id Attribute Name tag
                    
                    //Beginning of Inventory Id Attribute Value tag
                    xmlW.writeStartElement(null, 'Value', null);
                    if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c != null)
                        xmlW.writeCharacters(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c);
                    xmlW.writeEndElement();
                    //End of Inventory Id Attribute Value tag
                                
                    xmlW.writeEndElement();
                    //End of Attribute tag
                    
                    //Inclusion of Other Attributes
                    for(Order_Charge_Attribute__c orderCharges : orderProd.Order_Charge_Attributes__r) {
                        System.debug('Attributesssss'+orderCharges);
                        //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        //Beginning of Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        if(orderCharges.Attribute_Name__c != null && orderCharges.Attribute_Name__c != '')
                            xmlW.writeCharacters(orderCharges.Attribute_Name__c);
                        xmlW.writeEndElement();
                        //End of Name tag
                        
                        //Beginning of Value Tag
                        xmlW.writeStartElement(null, 'Value', null);
                        if(orderCharges.Attribute_Type__c != null) {
                            if(orderCharges.Attribute_Type__c == 'Text') {
                                if(orderCharges.String_Value__c != null && orderCharges.String_Value__c !='')
                                    xmlW.writeCharacters(orderCharges.String_Value__c);
                            }
                            else if(orderCharges.Attribute_Type__c == 'Number') {
                                if(orderCharges.Number_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(orderCharges.Number_Value__c));
                            }
                            else if(orderCharges.Attribute_Type__c == 'Boolean') {
                                    xmlW.writeCharacters(String.valueOf(orderCharges.Boolean_Value__c));
                            }
                            else if(orderCharges.Attribute_Type__c == 'Picklist') {
                                if(orderCharges.Picklist_Value__c != null && orderCharges.Picklist_Value__c !='')
                                    xmlW.writeCharacters(orderCharges.Picklist_Value__c);
                            }
                            else if(orderCharges.Attribute_Type__c == 'Date') {
                                if(orderCharges.Date_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(orderCharges.Date_Value__c));
                            }
                            else if(orderCharges.Attribute_Type__c == 'Phone') {
                                if(orderCharges.Phone_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(orderCharges.Phone_Value__c));
                            }
                            else {
                                
                            }
                        }
                        xmlW.writeEndElement();
                        //End of Value tag
                        
                        // Added By Sai C for Attribute Value Id Tag
                        //forming value ID tag from here
                       /* xmlW.writeStartElement(null, 'ID', null);
                        if((orderCharges.Attribute_Name__c.contains('Country') || 
                             orderCharges.Attribute_Name__c.contains('State')
                            || orderCharges.Attribute_Name__c.contains('County')
                           || orderCharges.Attribute_Name__c.contains('City')) && orderCharges.Value_ID__c != null){
                                //Beginning of Value ID Tag i.e ID
                                   
                                    xmlW.writeCharacters(orderCharges.Value_ID__c);
                               
                                //End of Value ID tag
                           }
                            else{
                                xmlW.writeCharacters(' ');
                            }
                            xmlW.writeEndElement();*/
                           //End of Value  ID tag
                           
                         //adding ID tag for all attributes here
                        xmlW.writeStartElement(null, 'ID', null);
                        if(orderCharges.Value_ID__c != null){
                            xmlW.writeCharacters(orderCharges.Value_ID__c);
                        }
                        else{
                            xmlW.writeCharacters(' ');
                        }
                        xmlW.writeEndElement(); 
                        
                        
                        xmlW.writeEndElement();
                        //End of Attribute tag
                    }
                    
                    xmlW.writeEndElement();
                    //End of Attributes Tag
                    
                     //Begin of ChildProducts tag ******************************akash
                  /*  xmlW.writeStartElement(null, 'ChildProducts', null);
                        
                        if(!orpcIdVschatOrpc.isEmpty() && orpcIdVschatOrpc.containsKey(orderProd.id)){
                            //Begin of ChildProduct tag
                            xmlW.writeStartElement(null, 'ChildProduct', null);
                            
                                //Begin of ChildProductName tag
                                xmlW.writeStartElement(null, 'ChildProductName', null);
                                xmlW.writeCharacters(orpcIdVschatOrpc.get(orderProd.id).Chat_Usage_Order_Rate_Plan_Charge__r.Name);
                                xmlW.writeEndElement();
                                //End of ChildProductName Tag
                                
                                //Begin of ChildProductCode tag
                                xmlW.writeStartElement(null, 'ChildProductCode', null);
                                xmlW.writeCharacters(orpcIdVschatOrpc.get(orderProd.id).Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c);
                                xmlW.writeEndElement();
                                //End of ChildProductCode Tag
                                
                                //Begin of ChildProductSIN tag
                                xmlW.writeStartElement(null, 'ChildProductSIN', null);
                                xmlW.writeCharacters(orpcIdVschatOrpc.get(orderProd.id).Chat_Usage_Order_Rate_Plan_Charge__r.SIN__c);
                                xmlW.writeEndElement();
                                //End of ChildProductSIN Tag
                            
                            
                            xmlW.writeEndElement();
                           //End of ChildProduct Tag
                        
                        }
                        else{ 
                            xmlW.writeCharacters(' ');
                        }
                    
                    xmlW.writeEndElement();
                   */ //End of ChildProducts Tag
                    
                    
                    xmlW.writeEndElement();
                    //End of LineItem Tag
                    
                }
                
                xmlW.writeEndElement();
                //End of LineItems tag
                
                xmlW.writeEndElement();
                //End of Product tag
            }   
        }
        xmlW.writeEndElement();
        //End of Products Tag
        
        xmlW.writeEndElement();
        //End of Order tag
        
        xmlW.writeEndElement();
        //End of OrderRequest tag
        
        reqXML = xmlW.getXmlString();
        System.debug('Order Request :'+reqXML);
        return reqXML;
    }
    
    //Added by Sai C for Cancellation process
    public static String constructXML_OrderCancel(String uName,List<invoiceit_s__Job_Rate_Plan_Charge__c> lstOrderProds,invoiceit_s__Job__c orderObj,Map<id,Chat_Product_Order_Charge__c> orpcIdVschatOrpc) {
        String reqXML = '';
        String xmlns = '';
        //Logic for generating line item id
        DateTime result1 = DateTime.now();
        String timeStamp = result1.format('yyyy/MM/dd HH:mm:ss');//to convert datetime into string
        System.debug('timeStamp'+timeStamp);
        String[] str1 = timeStamp.split(' ');
        String[] str2 = str1[0].split('/');
        String[] str3 = str1[1].split(':');
        String lineItemId = str2[0]+str2[1]+str2[2]+str3[0]+str3[1]+str3[2];
        System.debug('Id is:'+lineItemId);
        //end of logic - line itemid
        String postDate = '';
        String []validatedDateValue;
        Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>> mapOrderProdIdNLstOrderChargesForOrderProduct = new Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>>();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> lstOrderRPCForAProduct = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();

        //lstOrderCharges contains all charges present under an order, so split it to have values like charges under each orderproduct
        for(invoiceit_s__Job_Rate_Plan_Charge__c orderCharges : lstOrderProds) {
            if(mapOrderProdIdNLstOrderChargesForOrderProduct.containsKey(orderCharges.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c)){
                mapOrderProdIdNLstOrderChargesForOrderProduct.get(orderCharges.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c).add(orderCharges);
            }
            else{
                mapOrderProdIdNLstOrderChargesForOrderProduct.put(orderCharges.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,new List<invoiceit_s__Job_Rate_Plan_Charge__c>{orderCharges});
            }
        }
        System.debug('map order products N List Order Charges&&&'+mapOrderProdIdNLstOrderChargesForOrderProduct);
        //get xmlns value from custom setting
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('OrderRequest');
        xmlns = endPts.xmlns__c;
        
        //get server timestamp to send it in requestid
        DateTime result = DateTime.now();
        String timeStampString = result.format();//to convert datetime into string
        String reqID = orderObj.Id + '-' + timeStampString ;
        System.debug('RequestId Order Request :' + reqID);
        
        //construction of XML for release inventory
        Xmlstreamwriter xmlW = new Xmlstreamwriter();
        
        //Beginning of OrderRequest tag
        xmlW.writeStartElement(null,'OrderRequest', null); 
        xmlW.writeAttribute(null,null,'xmlns',xmlns);
        
        //Beginning of requestId tag
        xmlW.writeStartElement(null,'RequestId',null);
        xmlW.writeCharacters(reqID);
        xmlW.writeEndElement();
        //end of Request Id Tag
        
        //Beginning of Order tag
        xmlW.writeStartElement(null,'Order', null); 

        //Beginning of Username tag
        xmlW.writeStartElement(null, 'UserName', null);
        xmlW.writeCharacters(uName);
        xmlW.writeEndElement();
        //End of Username tag
        
        //Beginning of CustomerNumber tag
        if(orderObj.invoiceit_s__Account__r.MH_Cust_Number__c != null) {
            xmlW.writeStartElement(null, 'CustomerNumber', null);
                xmlW.writeCharacters(orderObj.invoiceit_s__Account__r.MH_Cust_Number__c);
            xmlW.writeEndElement();
        }
        else {
            xmlW.writeEmptyElement(null, 'CustomerNumber', null);
        }
        //End of CustomerNumber tag
        
        
         //Beginning of OrgID tag: added on 05/01/2016 by akash
        if(orderObj.invoiceit_s__Account__r.Org_Id__c != null){
             xmlW.writeStartElement(null, 'OrgId', null);
             xmlW.writeCharacters(orderObj.invoiceit_s__Account__r.Org_Id__c);
            xmlW.writeEndElement();
            //End of OrgId tag
        }
       
        
        
        
        //Beginning of OrderNumber tag
        xmlW.writeStartElement(null, 'OrderNumber', null);
            xmlW.writeCharacters(orderObj.Name);
        xmlW.writeEndElement();
        //End of OrderNumber tag
        
        //beginning of Products tag
        xmlW.writeStartElement(null,'Products',null);
        System.debug('Order Id is'+orderObj.Id+'Order Products Number&&'+orderObj.invoiceit_s__Job_Product__r.size());
        
        //getting products for charges sent in the Order Req
        
        for(invoiceit_s__Job_Product__c jobProds : orderObj.invoiceit_s__Job_Product__r) {
            
            if(mapOrderProdIdNLstOrderChargesForOrderProduct.containsKey(jobProds.Id)) {
            
                //Beginning of Product tag
                xmlW.writeStartElement(null,'Product', null); 
                
                //Beginning of ProductId tag
                xmlW.writeStartElement(null,'ProductId',null);
                    xmlW.writeCharacters(jobProds.Id);
                xmlW.writeEndElement();
                //End of ProductId tag
                
                //Beginning of SubscriptionIdentificationNumber tag
                xmlW.writeStartElement(null,'SubscriptionIdentificationNumber',null);
                    if(jobProds.Sin_Number__c != null)
                        xmlW.writeCharacters(jobProds.Sin_Number__c);
                xmlW.writeEndElement();
                //End of SubscriptionIdentificationNumber tag
                
                //Beginning of ProductCode tag
                xmlW.writeStartElement(null,'ProductCode',null);
                    xmlW.writeCharacters(jobProds.invoiceit_s__Product_Code__c);
                xmlW.writeEndElement();
                //End of ProductCode tag
                
                //Beginning of LineItems tag
                xmlW.writeStartElement(null,'LineItems', null); 
                
                //filtering order charges based on a product
                lstOrderRPCForAProduct = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
               
                for(invoiceit_s__Job_Rate_Plan_Charge__c oRpc : lstOrderProds) {
                    
                    if(oRpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id == jobProds.Id) {
                        lstOrderRPCForAProduct.add(oRpc);
                    }
                }
                        
                Map<id,Chat_Product_Order_Charge__c> orderChildToChatProductMap = MDL_OnDemandOrderXML.getchatproductsChildMap(lstOrderRPCForAProduct);
                System.debug('Order Charges Number=='+lstOrderRPCForAProduct.size());
                for(invoiceit_s__Job_Rate_Plan_Charge__c orderProd : lstOrderRPCForAProduct) {
                    Chat_Product_Order_Charge__c junctionObj = orderChildToChatProductMap.get(orderProd.Id);
                    System.debug('&&orderProducts Details&&'+orderProd);
                    //Beginning of LineItem tag
                    xmlW.writeStartElement(null,'LineItem', null);
                    
                    //Beginning of LineItemId tag
                    xmlW.writeStartElement(null, 'LineItemId', null);
                    xmlW.writeCharacters(orderProd.Id+lineItemId);
                    xmlW.writeEndElement();
                    //End of LineItemId tag
                    
                    //Beginning of SubscriptionIdentificationNumber tag
                    if(orderProd.Sin__c != null) {
                        xmlW.writeStartElement(null, 'SubscriptionIdentificationNumber', null);
                            xmlW.writeCharacters(orderProd.SIN__c);
                        xmlW.writeEndElement();
                    }
                    else {
                        xmlW.writeEmptyElement(null, 'SubscriptionIdentificationNumber', null);
                    }
                    //End of SubscriptionIdentificationNumber tag
                    
                    //Beginning of ProductCode tag
                    if(orderProd.invoiceit_s__Accounting_Code__c  != null) {
                        xmlW.writeStartElement(null, 'ProductCode', null);
                            xmlW.writeCharacters(orderProd.invoiceit_s__Accounting_Code__c);
                        xmlW.writeEndElement();
                    }
                    else {
                        xmlW.writeEmptyElement(null,'ProductCode', null);
                    }
                    //End of ProductCode tag
                    
                    //Beginning of ProductName tag
                    if(orderProd.Name != null) {
                        xmlW.writeStartElement(null, 'ProductName', null);
                            xmlW.writeCharacters(orderProd.Name);
                        xmlW.writeEndElement();
                    }
                    else {
                        xmlW.writeEmptyElement(null, 'ProductName', null);
                    }
                    //End of ProductName tag
                    
                    
                    
                     boolean toCreateCancelDateXml = false;
                    
                    //Beginning of Status tag
                    xmlW.writeStartElement(null, 'Status', null);
                    if(orderProd.invoiceit_s__Status__c != null) {
                        string status = '';
                        if(orderProd.invoiceit_s__Status__c == 'Active' || orderProd.invoiceit_s__Status__c == 'Renewed' || orderProd.invoiceit_s__Status__c == 'Rebased' )
                        //commented by Sai C
                        //|| (orderProd.invoiceit_s__Status__c == 'Truncated' && orderProd.invoiceit_s__Service_End_Date__c > Date.today()))
                            //xmlW.writeCharacters('Active'); 
                          status ='Active';
                        if(orderProd.invoiceit_s__Status__c == 'Cancelled' || orderProd.invoiceit_s__Status__c == 'Expired' || (orderProd.invoiceit_s__Status__c == 'Truncated' && orderProd.invoiceit_s__Service_End_Date__c < Date.today())){
                            //xmlW.writeCharacters('Cancel'); 
                           status = 'Cancel';
                            
                        }
                           //Commented by Sai C
                          If(((orderProd.invoiceit_s__Price_Type__c == 'One Time' && orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Shippable__c == 'Yes' && orderProd.Fulfilment_Start_Date__c== null)|| (orderProd.invoiceit_s__Price_Type__c == 'Monthly'|| orderProd.invoiceit_s__Price_Type__c == 'Annual' || orderProd.invoiceit_s__Price_Type__c == 'Usage' )) && orderProd.invoiceit_s__Status__c == 'Truncated' ) 
                          //((orderProd.invoiceit_s__Price_Type__c == 'One Time'|| orderProd.invoiceit_s__Price_Type__c == 'Monthly' ) && orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Shippable__c == 'Yes'&& orderProd.invoiceit_s__Status__c == 'Truncated' && orderProd.Fulfilment_Start_Date__c== null) 
                         /*if((orderProd.Name.contains('Law Directory - Full Set')
                           || orderProd.Name.contains('MH Bar Register Set')
                           || orderProd.Name.contains('Law Directory - Individual Volume')
                           || orderProd.Name.contains('Law Directory DVD')) 
                            && orderProd.invoiceit_s__Status__c == 'Truncated'*/
                            //commented for one time shippable
                      // /*&& orderProd.invoiceit_s__Price_Type__c == 'One Time'*/)
                     {
                           //xmlW.writeCharacters('Cancel'); 
                           status = 'Cancel';
                           toCreateCancelDateXml = true;
                       }  
                        if(status!= null && status!= ''){
                            xmlW.writeCharacters(status);
                        } 
                    }           
                    xmlW.writeEndElement();
                    //End of Status tag
                    
                    
                    //Beginning of PostDate tag
                    xmlW.writeStartElement(null, 'PostDate', null);
                    postDate = String.valueOf(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.CreatedDate);
                    validatedDateValue = postDate.split(' ');
                    xmlW.writeCharacters(validatedDateValue[0]);
                    xmlW.writeEndElement();
                    //End of PostDate tag
                                                
                    //Beginning of FulfillmentDate tag
                    if(orderProd.Fulfilment_Start_Date__c != null) {
                        if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != 'System Fulfillment' && (orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != null || orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != '')) { 
                            xmlW.writeStartElement(null, 'FulfillmentDate', null);
                            xmlW.writeCharacters(String.valueOf(orderProd.Fulfilment_Start_Date__c));
                            xmlW.writeEndElement();
                        }
                    }
                    //commenting the else part so as to not send in the fulfillment date in case value is not there
                    /*else {
                        xmlW.writeEmptyElement(null, 'FulfillmentDate', null);
                    }*/
                    //End of FulfillmentDate tag
                    
                    //Beginning of CancelDate tag
                    /*if(orderProd.invoiceit_s__Price_Type__c == 'One Time' && orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Shippable__c == 'Yes') {
                        System.debug('cancel date will not be set for one time shippable product');
                    }*/
                    if(orderProd.invoiceit_s__Status__c == 'Cancelled') { 
                        if(orderProd.Cancel_Date__c != null) {
                            xmlW.writeStartElement(null, 'CancelDate', null);
                                xmlW.writeCharacters(String.valueOf(orderProd.Cancel_Date__c));  
                            xmlW.writeEndElement();
                        }
                    }
                    else if(orderProd.invoiceit_s__Status__c == 'Expired' || (orderProd.invoiceit_s__Status__c == 'Truncated' && orderProd.invoiceit_s__Service_End_Date__c < Date.today())) {
                        if(orderProd.invoiceit_s__Service_End_Date__c != null) {
                            xmlW.writeStartElement(null, 'CancelDate', null);
                                System.debug('service end of charge past its service end date is::'+String.valueOf(orderProd.invoiceit_s__Service_End_Date__c));
                                xmlW.writeCharacters(String.valueOf(orderProd.invoiceit_s__Service_End_Date__c));  
                            xmlW.writeEndElement();
                        }
                    }
                    //added by sai
                    //creating cancel date xml tag only in case of trucated status scenario
                    else if(toCreateCancelDateXml){
                        if(orderProd.Renew_Rebase_Truncate_Date__c != null){
                            xmlW.writeStartElement(null, 'CancelDate', null);
                            xmlW.writeCharacters(string.valueOf(orderProd.Renew_Rebase_Truncate_Date__c));
                            xmlW.writeEndElement();
                        }
                        
                    }
                    //commenting the else part so as to not send in the cancel date in case value is not there
                    /*else {
                        xmlW.writeEmptyElement(null, 'CancelDate', null);
                    }*/
                    //End of CancelDate tag
                    
                    //Beginning of IsProductInventoried tag
                    xmlW.writeStartElement(null, 'IsProductInventoried', null);
                    if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.IsInventoried__c != null)
                        xmlW.writeCharacters(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.IsInventoried__c);
                    xmlW.writeEndElement();
                    //End of IsProductInventoried tag
                    
                    
                   /*  //Beginning of HasChildProducts tag*************************added by akash
                    xmlW.writeStartElement(null, 'HasChildProducts', null);
                    if(!orpcIdVschatOrpc.isEmpty() && orpcIdVschatOrpc.containsKey(orderProd.id)){
                        xmlW.writeCharacters('Y');
                    }
                    else{
                        xmlW.writeCharacters('N');
                    }
                    xmlW.writeEndElement();
                  */  //End of HasChildProducts tag
                    
                   //Beginning of HasparentProducts tag*************************added by akash
                    xmlW.writeStartElement(null, 'HasParentProducts', null);
                    System.debug('@@@@orderProd.invoiceit_s__Order__r.Parent_Order__c'+orderProd.invoiceit_s__Order__r.Parent_Order__c);
                    System.debug('@@@orderProd.Chat_Parent_Order_Rate_Plan_Charge__c'+orderProd.Chat_Parent_Order_Rate_Plan_Charge__c);
                    System.debug('@@@@orderProd.invoiceit_s__Order__r.RecordType.developername'+orderProd.invoiceit_s__Order__r.RecordType.developername);
                    
                    if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name == 'Ngage Live Chat - External Website'){
                        xmlW.writeCharacters('N');
                    }
                    else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name == NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name == '')&& orderProd.invoiceit_s__Order__r.RecordType.developername == 'Nolo_Order'){
                        xmlW.writeCharacters('N');
                    }
                      else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name == NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name == '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == '')){
                        xmlW.writeCharacters('N');
                    }
                      else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name != NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name != '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == '')){
                        xmlW.writeCharacters('Y');                        
                    }
                    else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name != NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name != '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name != NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name != '')){
                        xmlW.writeCharacters('Y');
                    }   
                    xmlW.writeEndElement();
                    //End of HasparentProducts tag 
                   
                /*  //Beginning of ParentProducts SIN tag*************************added by akash (06/25/18)
                        xmlW.writeStartElement(null, 'ParentProductSIN', null);
                        xmlW.writeCharacters(orpcIdVschatOrpc.get(orderProd.id).Chat_Usage_Order_Rate_Plan_Charge__r.SIN__c);
                        xmlW.writeEndElement();
                */  //End of ChildProductCode Tag
                  
                    //Beginning of ParentProductSIN tag***********added by akash
                    xmlW.writeStartElement(null, 'ParentProductSIN', null);
                     
                     if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name == 'Ngage Live Chat - External Website'){
                        xmlW.writeCharacters('');
                    } 
                     else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name == NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name == '')&& orderProd.invoiceit_s__Order__r.RecordType.developername == 'Nolo_Order'){
                        xmlW.writeCharacters('');
                    }
                      else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name == NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name == '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == '')){
                        xmlW.writeCharacters('');
                    }
                      else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name != NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name != '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == '')){
                        xmlW.writeCharacters(junctionObj.Chat_Product_Order_Rate_Plan_Charge__r.SIN__c);                        
                    }
                    else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name != NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name != '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name != NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name != '')){
                        xmlW.writeCharacters(orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.SIN__c);
                    }   
                    xmlW.writeEndElement();
                    //End of HasparentProducts tag 
                    
                        //Need to create these two fields :Akash
                        //Begin of FulfilledBy Tag
                        xmlW.writeStartElement(null, 'FulfilledBy', null);
                           
                        xmlW.writeEndElement();
                        //End of FulfilledBy tag
                    
                        //Begin of FulfillmentID Tag
                        xmlW.writeStartElement(null, 'FulfillmentID', null);
                             if(orderProd.Chat_ID__c != null){
                                xmlW.writeCharacters(orderProd.Chat_ID__c);
                             }
                            else{
                                xmlW.writeCharacters(' ');
                            }
                        xmlW.writeEndElement();
                        //End of FulfillmentID tag
                    //}
                    
                    // Adding Service Start Date Tag for Charges by Sai C
                        xmlW.writeStartElement(null, 'ServiceStartDate', null);
                        if(orderProd.invoiceit_s__Service_Activation_Date__c != null){
                        xmlW.writeCharacters(String.valueOf(orderProd.invoiceit_s__Service_Activation_Date__c));  
                        }
                        else{
                            xmlW.writeCharacters('');
                        }
                        xmlW.writeEndElement();
                     // End of Service Start date Tag for charges 
                    
                     // Adding Service End Date Tag for Charges by Sai C
                        xmlW.writeStartElement(null, 'ServiceEndDate', null);
                        if(orderProd.invoiceit_s__Service_End_Date__c != null){
                         xmlW.writeCharacters(String.valueOf(orderProd.invoiceit_s__Service_End_Date__c));  
                        }
                        else{
                            xmlW.writeCharacters('');
                        }
                        xmlW.writeEndElement();
                     // End of Service End date Tag for charges 
                     
                     // Adding Service End Date Tag for Charges 
                        xmlW.writeStartElement(null, 'LiveDate', null);
                        if(orderProd.Live_Date__c != null){
                      
                                xmlW.writeCharacters(String.valueOf(orderProd.Live_Date__c));  
                            
                        
                        }
                        else{
                            xmlW.writeCharacters('');
                        }
                        xmlW.writeEndElement();
                     // End of Service End date Tag for charges
                    
                    
                    
                    //beginning of Attributes tag
                    xmlW.writeStartElement(null, 'Attributes', null);
                    
                    //beginning of Attribute tag
                    xmlW.writeStartElement(null, 'Attribute', null);
                    
                    //Beginning of Inventory Id Attribute Name tag
                    xmlW.writeStartElement(null, 'Name', null);
                    xmlW.writeCharacters('InventoryId');
                    xmlW.writeEndElement();
                    //End of Inventory Id Attribute Name tag
                    
                    //Beginning of Inventory Id Attribute Value tag
                    xmlW.writeStartElement(null, 'Value', null);
                    if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c != null)
                        xmlW.writeCharacters(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c);
                    xmlW.writeEndElement();
                    //End of Inventory Id Attribute Value tag
                                
                    xmlW.writeEndElement();
                    //End of Attribute tag
                    
                    //Inclusion of Other Attributes
                    for(Order_Charge_Attribute__c orderCharges : orderProd.Order_Charge_Attributes__r) {
                        System.debug('Attributesssss'+orderCharges);
                        //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        //Beginning of Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        if(orderCharges.Attribute_Name__c != null && orderCharges.Attribute_Name__c != '')
                            xmlW.writeCharacters(orderCharges.Attribute_Name__c);
                        xmlW.writeEndElement();
                        //End of Name tag
                        
                        //Beginning of Value Tag
                        xmlW.writeStartElement(null, 'Value', null);
                        if(orderCharges.Attribute_Type__c != null) {
                            if(orderCharges.Attribute_Type__c == 'Text') {
                                if(orderCharges.String_Value__c != null && orderCharges.String_Value__c !='')
                                    xmlW.writeCharacters(orderCharges.String_Value__c);
                            }
                            else if(orderCharges.Attribute_Type__c == 'Number') {
                                if(orderCharges.Number_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(orderCharges.Number_Value__c));
                            }
                            else if(orderCharges.Attribute_Type__c == 'Boolean') {
                                    xmlW.writeCharacters(String.valueOf(orderCharges.Boolean_Value__c));
                            }
                            else if(orderCharges.Attribute_Type__c == 'Picklist') {
                                if(orderCharges.Picklist_Value__c != null && orderCharges.Picklist_Value__c !='')
                                    xmlW.writeCharacters(orderCharges.Picklist_Value__c);
                            }
                            else if(orderCharges.Attribute_Type__c == 'Date') {
                                if(orderCharges.Date_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(orderCharges.Date_Value__c));
                            }
                            else if(orderCharges.Attribute_Type__c == 'Phone') {
                                if(orderCharges.Phone_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(orderCharges.Phone_Value__c));
                            }
                            else {
                                
                            }
                        }
                        xmlW.writeEndElement();
                        //End of Value tag
                        
                        // Added By Sai C for Attribute Value Id Tag
                        //forming value ID tag from here
                       /* xmlW.writeStartElement(null, 'ID', null);
                        if((orderCharges.Attribute_Name__c.contains('Country') || 
                             orderCharges.Attribute_Name__c.contains('State')
                            || orderCharges.Attribute_Name__c.contains('County')
                           || orderCharges.Attribute_Name__c.contains('City')) && orderCharges.Value_ID__c != null){
                                //Beginning of Value ID Tag i.e ID
                                   
                                    xmlW.writeCharacters(orderCharges.Value_ID__c);
                               
                                //End of Value ID tag
                           }
                            else{
                                xmlW.writeCharacters(' ');
                            }
                            xmlW.writeEndElement();*/
                           //End of Value  ID tag
                           
                         //adding ID tag for all attributes here
                        xmlW.writeStartElement(null, 'ID', null);
                        if(orderCharges.Value_ID__c != null){
                            xmlW.writeCharacters(orderCharges.Value_ID__c);
                        }
                        else{
                            xmlW.writeCharacters(' ');
                        }
                        xmlW.writeEndElement(); 
                        
                        
                        xmlW.writeEndElement();
                        //End of Attribute tag
                    }
                    
                    xmlW.writeEndElement();
                    //End of Attributes Tag
                    
                    //Begin of ChildProducts tag ******************************akash
                  /*  xmlW.writeStartElement(null, 'ChildProducts', null);
                        
                        if(!orpcIdVschatOrpc.isEmpty() && orpcIdVschatOrpc.containsKey(orderProd.id)){
                            //Begin of ChildProduct tag
                            xmlW.writeStartElement(null, 'ChildProduct', null);
                            
                                //Begin of ChildProductName tag
                                xmlW.writeStartElement(null, 'ChildProductName', null);
                                xmlW.writeCharacters(orpcIdVschatOrpc.get(orderProd.id).Chat_Usage_Order_Rate_Plan_Charge__r.Name);
                                xmlW.writeEndElement();
                                //End of ChildProductName Tag
                                
                                //Begin of ChildProductCode tag
                                xmlW.writeStartElement(null, 'ChildProductCode', null);
                                xmlW.writeCharacters(orpcIdVschatOrpc.get(orderProd.id).Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c);
                                xmlW.writeEndElement();
                                //End of ChildProductCode Tag
                                
                                //Begin of ChildProductSIN tag
                                xmlW.writeStartElement(null, 'ChildProductSIN', null);
                                xmlW.writeCharacters(orpcIdVschatOrpc.get(orderProd.id).Chat_Usage_Order_Rate_Plan_Charge__r.SIN__c);
                                xmlW.writeEndElement();
                                //End of ChildProductSIN Tag
                            
                            
                            xmlW.writeEndElement();
                           //End of ChildProduct Tag
                        
                        }
                        else{ 
                            xmlW.writeCharacters(' ');
                        }
                    
                    xmlW.writeEndElement();
                   */ //End of ChildProducts Tag
                    
                    
                    xmlW.writeEndElement();
                    //End of LineItem Tag
                    
                }
                
                xmlW.writeEndElement();
                //End of LineItems tag
                
                xmlW.writeEndElement();
                //End of Product tag
            }   
        }
        xmlW.writeEndElement();
        //End of Products Tag
        
        xmlW.writeEndElement();
        //End of Order tag
        
        xmlW.writeEndElement();
        //End of OrderRequest tag
        
        reqXML = xmlW.getXmlString();
        System.debug('Order Request :'+reqXML);
        return reqXML;
    }
    
    //added by sai
    //to avoid dependancy when calling constructXML_OrderRequest from  page
     public static String constructXML_OrderRequestfrompage(String uName,List<invoiceit_s__Job_Rate_Plan_Charge__c> lstOrderProds,invoiceit_s__Job__c orderObj,Map<id,Chat_Product_Order_Charge__c> orpcIdVschatOrpc) {
        system.debug('@@@@@ in constructXML_OrderRequestfrompage');
            
        String reqXML = '';
        String xmlns = '';
        //Logic for generating line item id
        DateTime result1 = DateTime.now();
        String timeStamp = result1.format('yyyy/MM/dd HH:mm:ss');//to convert datetime into string
        System.debug('timeStamp'+timeStamp);
        String[] str1 = timeStamp.split(' ');
        String[] str2 = str1[0].split('/');
        String[] str3 = str1[1].split(':');
        String lineItemId = str2[0]+str2[1]+str2[2]+str3[0]+str3[1]+str3[2];
        System.debug('Id is:'+lineItemId);
        //end of logic - line itemid
        String postDate = '';
        String []validatedDateValue;
        Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>> mapOrderProdIdNLstOrderChargesForOrderProduct = new Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>>();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> lstOrderRPCForAProduct = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();

        //lstOrderCharges contains all charges present under an order, so split it to have values like charges under each orderproduct
        for(invoiceit_s__Job_Rate_Plan_Charge__c orderCharges : lstOrderProds) {
            if(mapOrderProdIdNLstOrderChargesForOrderProduct.containsKey(orderCharges.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c)){
                mapOrderProdIdNLstOrderChargesForOrderProduct.get(orderCharges.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c).add(orderCharges);
            }
            else{
                mapOrderProdIdNLstOrderChargesForOrderProduct.put(orderCharges.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,new List<invoiceit_s__Job_Rate_Plan_Charge__c>{orderCharges});
            }
        }
        System.debug('map order products N List Order Charges&&&'+mapOrderProdIdNLstOrderChargesForOrderProduct);
        //get xmlns value from custom setting
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('OrderRequest');
        xmlns = endPts.xmlns__c;
        system.debug('@@@@xmlns'+xmlns); 
        
        //get server timestamp to send it in requestid
        DateTime result = DateTime.now();
        String timeStampString = result.format();//to convert datetime into string
        String reqID = orderObj.Id + '-' + timeStampString ;
        System.debug('RequestId Order Request :' + reqID);
        
        //construction of XML for release inventory
        Xmlstreamwriter xmlW = new Xmlstreamwriter();
        
        //Beginning of OrderRequest tag
        xmlW.writeStartElement(null,'OrderRequest', null); 
        xmlW.writeAttribute(null,null,'xmlns',xmlns);
        
        //Beginning of requestId tag
        xmlW.writeStartElement(null,'RequestId',null);
        xmlW.writeCharacters(reqID);
        xmlW.writeEndElement();
        //end of Request Id Tag
        
        //Beginning of Order tag
        xmlW.writeStartElement(null,'Order', null); 

        //Beginning of Username tag
        xmlW.writeStartElement(null, 'UserName', null);
        xmlW.writeCharacters(uName);
        xmlW.writeEndElement();
        //End of Username tag
        
        //Beginning of CustomerNumber tag
        if(orderObj.invoiceit_s__Account__r.MH_Cust_Number__c != null) {
            xmlW.writeStartElement(null, 'CustomerNumber', null);
                xmlW.writeCharacters(orderObj.invoiceit_s__Account__r.MH_Cust_Number__c);
            xmlW.writeEndElement();
        }
        else {
            xmlW.writeEmptyElement(null, 'CustomerNumber', null);
        }
        //End of CustomerNumber tag
        
        
         //Beginning of OrgID tag: added on 05/01/2016 by akash
        if(orderObj.invoiceit_s__Account__r.Org_Id__c != null){
             xmlW.writeStartElement(null, 'OrgId', null);
             xmlW.writeCharacters(orderObj.invoiceit_s__Account__r.Org_Id__c);
            xmlW.writeEndElement();
            //End of OrgId tag
        }
       
        
        
        
        //Beginning of OrderNumber tag
        xmlW.writeStartElement(null, 'OrderNumber', null);
            xmlW.writeCharacters(orderObj.Name);
        xmlW.writeEndElement();
        //End of OrderNumber tag
        
        //beginning of Products tag
        xmlW.writeStartElement(null,'Products',null);
        System.debug('Order Id is'+orderObj.Id+'Order Products Number&&'+orderObj.invoiceit_s__Job_Product__r.size());
        
        //getting products for charges sent in the Order Req
        
        for(invoiceit_s__Job_Product__c jobProds : orderObj.invoiceit_s__Job_Product__r) {
            
            if(mapOrderProdIdNLstOrderChargesForOrderProduct.containsKey(jobProds.Id)) {
            
                //Beginning of Product tag
                xmlW.writeStartElement(null,'Product', null); 
                
                //Beginning of ProductId tag
                xmlW.writeStartElement(null,'ProductId',null);
                    xmlW.writeCharacters(jobProds.Id);
                xmlW.writeEndElement();
                //End of ProductId tag
                
                //Beginning of SubscriptionIdentificationNumber tag
                xmlW.writeStartElement(null,'SubscriptionIdentificationNumber',null);
                    if(jobProds.Sin_Number__c != null)
                        xmlW.writeCharacters(jobProds.Sin_Number__c);
                xmlW.writeEndElement();
                //End of SubscriptionIdentificationNumber tag
                
                //Beginning of ProductCode tag
                xmlW.writeStartElement(null,'ProductCode',null);
                    xmlW.writeCharacters(jobProds.invoiceit_s__Product_Code__c);
                xmlW.writeEndElement();
                //End of ProductCode tag
                
                //Beginning of LineItems tag
                xmlW.writeStartElement(null,'LineItems', null); 
                
                //filtering order charges based on a product
                lstOrderRPCForAProduct = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
               
                for(invoiceit_s__Job_Rate_Plan_Charge__c oRpc : lstOrderProds) {
                    
                    if(oRpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id == jobProds.Id) {
                        lstOrderRPCForAProduct.add(oRpc);
                    }
                }
                        
                System.debug('Order Charges Number=='+lstOrderRPCForAProduct.size());
                
                Map<id,Chat_Product_Order_Charge__c> orderChildToChatProductMap = MDL_OnDemandOrderXML.getchatproductsChildMap(lstOrderRPCForAProduct);
                
                for(invoiceit_s__Job_Rate_Plan_Charge__c orderProd : lstOrderRPCForAProduct) {
                    Chat_Product_Order_Charge__c junctionObj = orderChildToChatProductMap.get(orderProd.Id);
                    System.debug('&&orderProducts Details&&'+orderProd);
                    //Beginning of LineItem tag
                    xmlW.writeStartElement(null,'LineItem', null);
                    
                    //Beginning of LineItemId tag
                    xmlW.writeStartElement(null, 'LineItemId', null);
                    xmlW.writeCharacters(orderProd.Id+lineItemId);
                    xmlW.writeEndElement();
                    //End of LineItemId tag
                    
                    //Beginning of SubscriptionIdentificationNumber tag
                    if(orderProd.Sin__c != null) {
                        xmlW.writeStartElement(null, 'SubscriptionIdentificationNumber', null);
                            xmlW.writeCharacters(orderProd.SIN__c);
                        xmlW.writeEndElement();
                    }
                    else {
                        xmlW.writeEmptyElement(null, 'SubscriptionIdentificationNumber', null);
                    }
                    //End of SubscriptionIdentificationNumber tag
                    
                    //Beginning of ProductCode tag
                    if(orderProd.invoiceit_s__Accounting_Code__c  != null) {
                        xmlW.writeStartElement(null, 'ProductCode', null);
                            xmlW.writeCharacters(orderProd.invoiceit_s__Accounting_Code__c);
                        xmlW.writeEndElement();
                    }
                    else {
                        xmlW.writeEmptyElement(null,'ProductCode', null);
                    }
                    //End of ProductCode tag
                    
                    //Beginning of ProductName tag
                    if(orderProd.Name != null) {
                        xmlW.writeStartElement(null, 'ProductName', null);
                            String prodName = orderProd.Name;
                            //prodName = prodName.replace('&', '%26');                            
                            xmlW.writeCharacters(prodName);
                        xmlW.writeEndElement();
                    }
                    else {
                        xmlW.writeEmptyElement(null, 'ProductName', null);
                    }
                    //End of ProductName tag
                    
                    
                    
                     boolean toCreateCancelDateXml = false;
                    
                    //Beginning of Status tag
                    xmlW.writeStartElement(null, 'Status', null);
                    if(orderProd.invoiceit_s__Status__c != null) {
                        string status = '';
                        if(orderProd.invoiceit_s__Status__c == 'Active' || orderProd.invoiceit_s__Status__c == 'Renewed' || orderProd.invoiceit_s__Status__c == 'Rebased' )
                        //Commented By Sai C
                        //|| (orderProd.invoiceit_s__Status__c == 'Truncated' && orderProd.invoiceit_s__Service_End_Date__c > Date.today()))
                            //xmlW.writeCharacters('Active'); 
                          status ='Active';
                        if(orderProd.invoiceit_s__Status__c == 'Cancelled' || (orderProd.invoiceit_s__Status__c == 'Expired' || (orderProd.invoiceit_s__Status__c == 'Truncated' && orderProd.invoiceit_s__Service_End_Date__c < Date.today()))){
                        // && checkCancelConditions(orderProd)) || (orderProd.invoiceit_s__Status__c == 'Truncated' && orderProd.invoiceit_s__Service_End_Date__c < Date.today())){
                             //xmlW.writeCharacters('Cancel'); 
                           status = 'Cancel';
                            
                        }
                           If(((orderProd.invoiceit_s__Price_Type__c == 'One Time' && orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Shippable__c == 'Yes' && orderProd.Fulfilment_Start_Date__c== null)|| (orderProd.invoiceit_s__Price_Type__c == 'Monthly' || orderProd.invoiceit_s__Price_Type__c == 'Annual' )) && orderProd.invoiceit_s__Status__c == 'Truncated' )
                           //if(orderProd.invoiceit_s__Price_Type__c == 'One Time' && orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Shippable__c == 'Yes'&& orderProd.invoiceit_s__Status__c == 'Truncated' && orderProd.Fulfilment_Start_Date__c== null) 
                         /*if((orderProd.Name.contains('Law Directory - Full Set')
                           || orderProd.Name.contains('MH Bar Register Set')
                           || orderProd.Name.contains('Law Directory - Individual Volume')
                           || orderProd.Name.contains('Law Directory DVD')) 
                            && orderProd.invoiceit_s__Status__c == 'Truncated'*/
                            //commented for one time shippable
                      // /*&& orderProd.invoiceit_s__Price_Type__c == 'One Time'*/)
                      {
                           //xmlW.writeCharacters('Cancel'); 
                           status = 'Cancel';
                           toCreateCancelDateXml = true;
                       }  
                        if(status!= null && status!= ''){
                            xmlW.writeCharacters(status);
                        }
                    }           
                    xmlW.writeEndElement();
                    //End of Status tag
                    
                    
                    
                    
                    //Beginning of PostDate tag
                    xmlW.writeStartElement(null, 'PostDate', null);
                    postDate = String.valueOf(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.CreatedDate);
                    validatedDateValue = postDate.split(' ');
                    xmlW.writeCharacters(validatedDateValue[0]);
                    xmlW.writeEndElement();
                    //End of PostDate tag
                                                
                    //Beginning of FulfillmentDate tag
                    if(orderProd.Fulfilment_Start_Date__c != null) {
                        if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != 'System Fulfillment' && (orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != null || orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != '')) { 
                            xmlW.writeStartElement(null, 'FulfillmentDate', null);
                            xmlW.writeCharacters(String.valueOf(orderProd.Fulfilment_Start_Date__c));
                            xmlW.writeEndElement();
                        }
                    }
                    //commenting the else part so as to not send in the fulfillment date in case value is not there
                    /*else {
                        xmlW.writeEmptyElement(null, 'FulfillmentDate', null);
                    }*/
                    //End of FulfillmentDate tag
                    
                    //Beginning of CancelDate tag
                    /*if(orderProd.invoiceit_s__Price_Type__c == 'One Time' && orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Shippable__c == 'Yes') {
                        System.debug('cancel date will not be set for one time shippable product');
                    }*/
                    if(orderProd.invoiceit_s__Status__c == 'Cancelled') { 
                        if(orderProd.Cancel_Date__c != null) {
                            xmlW.writeStartElement(null, 'CancelDate', null);
                                xmlW.writeCharacters(String.valueOf(orderProd.Cancel_Date__c));  
                            xmlW.writeEndElement();
                        }
                    }
                    else if(orderProd.invoiceit_s__Status__c == 'Expired' || (orderProd.invoiceit_s__Status__c == 'Truncated' && orderProd.invoiceit_s__Service_End_Date__c < Date.today())) {
                        if(orderProd.invoiceit_s__Service_End_Date__c != null) {
                            xmlW.writeStartElement(null, 'CancelDate', null);
                                System.debug('service end of charge past its service end date is::'+String.valueOf(orderProd.invoiceit_s__Service_End_Date__c));
                                xmlW.writeCharacters(String.valueOf(orderProd.invoiceit_s__Service_End_Date__c));  
                            xmlW.writeEndElement();
                        }
                    }
                    //added by sai
                    //creating cancel date xml tag only in case of trucated status scenario
                    else if(toCreateCancelDateXml){
                        if(orderProd.Renew_Rebase_Truncate_Date__c != null){
                            xmlW.writeStartElement(null, 'CancelDate', null);
                            xmlW.writeCharacters(string.valueOf(orderProd.Renew_Rebase_Truncate_Date__c));
                            xmlW.writeEndElement();
                        }
                        
                    }
                    //commenting the else part so as to not send in the cancel date in case value is not there
                    /*else {
                        xmlW.writeEmptyElement(null, 'CancelDate', null);
                    }*/
                    //End of CancelDate tag
                    
                    //Beginning of IsProductInventoried tag
                    xmlW.writeStartElement(null, 'IsProductInventoried', null);
                    if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.IsInventoried__c != null)
                        xmlW.writeCharacters(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.IsInventoried__c);
                    xmlW.writeEndElement();
                    //End of IsProductInventoried tag
                    
                    //Beginning of HasparentProducts tag*************************added by akash
                    xmlW.writeStartElement(null, 'HasParentProducts', null);
                    System.debug('@@@@orderProd.invoiceit_s__Order__r.Parent_Order__c'+orderProd.invoiceit_s__Order__r.Parent_Order__c);
                    System.debug('@@@orderProd.Chat_Parent_Order_Rate_Plan_Charge__c'+orderProd.Chat_Parent_Order_Rate_Plan_Charge__c);
                    System.debug('@@@@orderProd.invoiceit_s__Order__r.RecordType.developername'+orderProd.invoiceit_s__Order__r.RecordType.developername);
                    
                    if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name == 'Ngage Live Chat - External Website'){
                        xmlW.writeCharacters('N');
                    }
                    else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name == NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name == '')&& orderProd.invoiceit_s__Order__r.RecordType.developername == 'Nolo_Order'){
                        xmlW.writeCharacters('N');
                    }
                      else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name == NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name == '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == '')){
                        xmlW.writeCharacters('N');
                    }
                      else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name != NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name != '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == '')){
                        xmlW.writeCharacters('Y');                        
                    }
                    else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name != NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name != '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name != NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name != '')){
                        xmlW.writeCharacters('Y');
                    }   
                    xmlW.writeEndElement();
                    //End of HasparentProducts tag
                    //Beginning of ParentProductSIN tag***********added by akash
                    xmlW.writeStartElement(null, 'ParentProductSIN', null);
                     
                    if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name == 'Ngage Live Chat - External Website'){
                        xmlW.writeCharacters('');
                    }
                      else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name == NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name == '')&& orderProd.invoiceit_s__Order__r.RecordType.developername == 'Nolo_Order'){
                        xmlW.writeCharacters('');
                    }
                      else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name == NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name == '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == '')){
                        xmlW.writeCharacters('');
                    }
                      else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name != NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name != '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == '')){
                        
                          
                          xmlW.writeCharacters(junctionObj.Chat_Product_Order_Rate_Plan_Charge__r.SIN__c);                        
                    }
                      else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name != NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name != '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name != NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name != '')){
                        xmlW.writeCharacters(orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.SIN__c);
                    }   
                    xmlW.writeEndElement();
                    //End of HasparentProducts tag 
                  /*  //Beginning of HasChildProducts tag*************************added by akash
                    xmlW.writeStartElement(null, 'HaschildProducts', null);
                   // if(orderProd.invoiceit_s__Order__r.Parent_Order__c == '')
                    if(!orpcIdVschatOrpc.isEmpty() && orpcIdVschatOrpc.containsKey(orderProd.id)){
                    System.Debug ('orpcIdVschatOrpc' + orpcIdVschatOrpc );
                        xmlW.writeCharacters('Y');
                    }
                    else{
                        xmlW.writeCharacters('N');
                    }
                    xmlW.writeEndElement();
                    
                    //End of HasChildProducts tag
                   */ 
                    //***************************akash
                    //if(orderProd.invoiceit_s__Accounting_Code__c == '01510'){
                        //Need to create these two fields :Akash
                        //Begin of FulfilledBy Tag
                        xmlW.writeStartElement(null, 'FulfilledBy', null);
                        xmlW.writeEndElement();
                        //End of FulfilledBy tag
                    
                       
                    //}  
                     //Begin of FulfillmentID Tag
                        xmlW.writeStartElement(null, 'FulfillmentID', null);
                        if(orderProd.Chat_ID__c != null){
                        System.Debug ('orderProd' + orderProd );
                                xmlW.writeCharacters(orderProd.Chat_ID__c);
                             }
                            else{
                                xmlW.writeCharacters(' ');
                            }
                        xmlW.writeEndElement();
                        //End of FulfillmentID tag
                    
                    // Adding Service Start Date Tag for Charges by Sai C
                        xmlW.writeStartElement(null, 'ServiceStartDate', null);
                        if(orderProd.invoiceit_s__Service_Activation_Date__c != null){
                        xmlW.writeCharacters(String.valueOf(orderProd.invoiceit_s__Service_Activation_Date__c));  
                        }
                        else{
                            xmlW.writeCharacters('');
                        }
                        xmlW.writeEndElement();
                     // End of Service Start date Tag for charges 
                    
                    // Adding Service End Date Tag for Charges by Sai C
                        xmlW.writeStartElement(null, 'ServiceEndDate', null);
                        if(orderProd.invoiceit_s__Service_End_Date__c != null){
                      
                                xmlW.writeCharacters(String.valueOf(orderProd.invoiceit_s__Service_End_Date__c));  
                            
                        
                        }
                        else{
                            xmlW.writeCharacters('');
                        }
                        xmlW.writeEndElement();
                     // End of Service End date Tag for charges 
                    
                    // Adding Service End Date Tag for Charges by Sai C
                        xmlW.writeStartElement(null, 'LiveDate', null);
                        if(orderProd.Live_Date__c != null){
                      
                                xmlW.writeCharacters(String.valueOf(orderProd.Live_Date__c));  
                            
                        
                        }
                        else{
                            xmlW.writeCharacters('');
                        }
                        xmlW.writeEndElement();
                     // End of Service End date Tag for charges
                    
                    
                    
                    //beginning of Attributes tag
                    xmlW.writeStartElement(null, 'Attributes', null);
                    
                    //beginning of Attribute tag
                    xmlW.writeStartElement(null, 'Attribute', null);
                    
                    //Beginning of Inventory Id Attribute Name tag
                    xmlW.writeStartElement(null, 'Name', null);
                    xmlW.writeCharacters('InventoryId');
                    xmlW.writeEndElement();
                    //End of Inventory Id Attribute Name tag
                    
                    //Beginning of Inventory Id Attribute Value tag
                    xmlW.writeStartElement(null, 'Value', null);
                    if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c != null)
                        xmlW.writeCharacters(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c);
                    xmlW.writeEndElement();
                    //End of Inventory Id Attribute Value tag
                                
                    xmlW.writeEndElement();
                    //End of Attribute tag
                    
                    //Inclusion of Other Attributes
                    for(Order_Charge_Attribute__c orderCharges : orderProd.Order_Charge_Attributes__r) {
                        System.debug('Attributesssss'+orderCharges);
                        //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        //Beginning of Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        if(orderCharges.Attribute_Name__c != null && orderCharges.Attribute_Name__c != '')
                            xmlW.writeCharacters(orderCharges.Attribute_Name__c);
                        xmlW.writeEndElement();
                        //End of Name tag
                        
                        //Beginning of Value Tag
                        xmlW.writeStartElement(null, 'Value', null);
                        if(orderCharges.Attribute_Type__c != null) {
                            if(orderCharges.Attribute_Type__c == 'Text') {
                                if(orderCharges.String_Value__c != null && orderCharges.String_Value__c !='')
                                    xmlW.writeCharacters(orderCharges.String_Value__c);
                                     
                            }
                            else if(orderCharges.Attribute_Type__c == 'Number') {
                                if(orderCharges.Number_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(orderCharges.Number_Value__c));
                            }
                            else if(orderCharges.Attribute_Type__c == 'Boolean') {
                                    xmlW.writeCharacters(String.valueOf(orderCharges.Boolean_Value__c));
                            }
                            else if(orderCharges.Attribute_Type__c == 'Picklist') {
                                if(orderCharges.Picklist_Value__c != null && orderCharges.Picklist_Value__c !='')
                                    xmlW.writeCharacters(orderCharges.Picklist_Value__c);
                                   
                            }
                            else if(orderCharges.Attribute_Type__c == 'Date') {
                                if(orderCharges.Date_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(orderCharges.Date_Value__c));
                            }
                            else if(orderCharges.Attribute_Type__c == 'Phone') {
                                if(orderCharges.Phone_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(orderCharges.Phone_Value__c));
                            }
                            else {
                                
                            }
                        }
                        xmlW.writeEndElement();
                        //End of Value tag
                        
                        //forming value ID tag from here
                       /* xmlW.writeStartElement(null, 'ID', null);   
                        if((orderCharges.Attribute_Name__c.contains('Country') || 
                             orderCharges.Attribute_Name__c.contains('State')
                            || orderCharges.Attribute_Name__c.contains('County')
                           || orderCharges.Attribute_Name__c.contains('City')) && orderCharges.Value_ID__c != null ){
                                //Beginning of Value ID Tag i.e ID
                                
                                    xmlW.writeCharacters(orderCharges.Value_ID__c);
                                
                                //End of Value ID tag
                           }
                           else{
                               xmlW.writeCharacters(' ');
                           }
                        xmlW.writeEndElement();*/
                        //End of Value ID tag
                        
                        
                        //adding ID tag for all attributes here
                        xmlW.writeStartElement(null, 'ID', null);
                        if(orderCharges.Value_ID__c != null){
                            xmlW.writeCharacters(orderCharges.Value_ID__c);
                        }
                        else{
                            xmlW.writeCharacters(' ');
                        }
                        xmlW.writeEndElement(); 
                        
                        xmlW.writeEndElement();
                        //End of Attribute tag
                    }
                    
                    xmlW.writeEndElement();
                    //End of Attributes Tag
                    
                 /* //Begin of ChildProducts tag ******************************akash
                    xmlW.writeStartElement(null, 'ChildProducts', null);
                        
                        if(!orpcIdVschatOrpc.isEmpty() && orpcIdVschatOrpc.containsKey(orderProd.id)){
                            //Begin of ChildProduct tag
                            xmlW.writeStartElement(null, 'ChildProduct', null);
                            
                                //Begin of ChildProductName tag
                                xmlW.writeStartElement(null, 'ChildProductName', null);
                                xmlW.writeCharacters(orpcIdVschatOrpc.get(orderProd.id).Chat_Usage_Order_Rate_Plan_Charge__r.Name);
                                xmlW.writeEndElement();
                                //End of ChildProductName Tag
                                
                                //Begin of ChildProductCode tag
                                xmlW.writeStartElement(null, 'ChildProductCode', null);
                                xmlW.writeCharacters(orpcIdVschatOrpc.get(orderProd.id).Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c);
                                xmlW.writeEndElement();
                                //End of ChildProductCode Tag
                                
                                //Begin of ChildProductSIN tag
                                xmlW.writeStartElement(null, 'ChildProductSIN', null);
                                xmlW.writeCharacters(orpcIdVschatOrpc.get(orderProd.id).Chat_Usage_Order_Rate_Plan_Charge__r.SIN__c);
                                xmlW.writeEndElement();
                                //End of ChildProductSIN Tag
                            
                            
                            xmlW.writeEndElement();
                           //End of ChildProduct Tag
                        
                        }
                        else{ 
                            xmlW.writeCharacters(' ');
                        }
                    
                    xmlW.writeEndElement();
                    //End of ChildProducts Tag
                   */ 
                    
                    
                    xmlW.writeEndElement();
                    //End of LineItem Tag
                    
                }
                
                xmlW.writeEndElement();
                //End of LineItems tag
                
                xmlW.writeEndElement();
                //End of Product tag
            }   
        }
        xmlW.writeEndElement();
        //End of Products Tag
        
        xmlW.writeEndElement();
        //End of Order tag
        
        xmlW.writeEndElement();
        //End of OrderRequest tag
        
        reqXML = xmlW.getXmlString();
        system.debug('reqXML'+reqXML);
        String reqXmlupdted = reqXML.replace('&','%26');
        String reqXmlupdted1 = reqXmlupdted.replace('+','%2B');
        System.debug('@@@@@Order Request :'+reqXmlupdted1); 
        return reqXmlupdted1 ;
    }
    
    
   public static boolean checkCancelConditions(invoiceit_s__Job_Rate_Plan_Charge__c orderProd){
        //added by Sai C
        if((orderProd.invoiceit_s__Price_Type__c == 'One Time' && orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Shippable__c == 'Yes' && orderProd.Fulfilment_Start_Date__c== null)|| (orderProd.invoiceit_s__Price_Type__c == 'Monthly' || orderProd.invoiceit_s__Price_Type__c == 'Annual' || orderProd.invoiceit_s__Price_Type__c == 'Usage' ) && orderProd.invoiceit_s__Status__c == 'Truncated' )
        /*if((orderProd.Fulfilment_Start_Date__c != null && orderProd.Shippable__c == 'Yes' && orderProd.invoiceit_s__Price_Type__c =='One Time')
                || (orderProd.Shippable__c =='Yes' && orderProd.invoiceit_s__Price_Type__c =='Monthly')
                // add web products condition too || (orderProd.Fulfilment_Start_Date__c != null && orderProd.Shippable__c == 'Yes') 
                )*/
                {
                    return false;
        }
        return true;            
    } 
    
    
    
    
    
    
    
    
     public static String constructXML_OrderRequestFromBatch(String uName,List<invoiceit_s__Job_Rate_Plan_Charge__c> lstOrderProds,invoiceit_s__Job__c orderObj, List<invoiceit_s__Job_Product__c> orderProducts,Map<id,Chat_Product_Order_Charge__c> orpcIdVschatOrpc) {
        String reqXML = '';
        String xmlns = '';
        //Logic for generating line item id
        DateTime result1 = DateTime.now();
        String timeStamp = result1.format('yyyy/MM/dd HH:mm:ss');//to convert datetime into string
        System.debug('timeStamp'+timeStamp);
        String[] str1 = timeStamp.split(' ');
        String[] str2 = str1[0].split('/');
        String[] str3 = str1[1].split(':');
        String lineItemId = str2[0]+str2[1]+str2[2]+str3[0]+str3[1]+str3[2];
        System.debug('Id is:'+lineItemId);
        //end of logic - line itemid
        String postDate = '';
        String []validatedDateValue;
        Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>> mapOrderProdIdNLstOrderChargesForOrderProduct = new Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>>();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> lstOrderRPCForAProduct = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();

        //lstOrderCharges contains all charges present under an order, so split it to have values like charges under each orderproduct
        for(invoiceit_s__Job_Rate_Plan_Charge__c orderCharges : lstOrderProds) {
            if(mapOrderProdIdNLstOrderChargesForOrderProduct.containsKey(orderCharges.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c)){
                mapOrderProdIdNLstOrderChargesForOrderProduct.get(orderCharges.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c).add(orderCharges);
            }
            else{
                mapOrderProdIdNLstOrderChargesForOrderProduct.put(orderCharges.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,new List<invoiceit_s__Job_Rate_Plan_Charge__c>{orderCharges});
            }
        }
        System.debug('map order products N List Order Charges&&&'+mapOrderProdIdNLstOrderChargesForOrderProduct);
        //get xmlns value from custom setting
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('OrderRequest');
        xmlns = endPts.xmlns__c;
        
        //get server timestamp to send it in requestid
        DateTime result = DateTime.now();
        String timeStampString = result.format();//to convert datetime into string
        String reqID = orderObj.Id + '-' + timeStampString ;
        System.debug('RequestId Order Request :' + reqID);
        
        //construction of XML for release inventory
        Xmlstreamwriter xmlW = new Xmlstreamwriter();
        
        //Beginning of OrderRequest tag
        xmlW.writeStartElement(null,'OrderRequest', null); 
        xmlW.writeAttribute(null,null,'xmlns',xmlns);
        
        //Beginning of requestId tag
        xmlW.writeStartElement(null,'RequestId',null);
        xmlW.writeCharacters(reqID);
        xmlW.writeEndElement();
        //end of Request Id Tag
        
        //Beginning of Order tag
        xmlW.writeStartElement(null,'Order', null); 

        //Beginning of Username tag
        xmlW.writeStartElement(null, 'UserName', null);
        xmlW.writeCharacters(uName);
        xmlW.writeEndElement();
        //End of Username tag
        
        //Beginning of CustomerNumber tag
        if(orderObj.invoiceit_s__Account__r.MH_Cust_Number__c != null) {
            xmlW.writeStartElement(null, 'CustomerNumber', null);
                xmlW.writeCharacters(orderObj.invoiceit_s__Account__r.MH_Cust_Number__c);
            xmlW.writeEndElement();
        }
        else {
            xmlW.writeEmptyElement(null, 'CustomerNumber', null);
        }
        //End of CustomerNumber tag
        
          //added by Akash : 25/5/2016  
          //Beginning of orgID tag
        if(orderObj.invoiceit_s__Account__r.Org_Id__c != null) {
            xmlW.writeStartElement(null, 'OrgId', null);
                xmlW.writeCharacters(orderObj.invoiceit_s__Account__r.Org_Id__c);
            xmlW.writeEndElement();
        }
        else {
            xmlW.writeEmptyElement(null, 'OrgId', null);
        }
        //End of orgID tag
        
         
        //Beginning of OrderNumber tag
        xmlW.writeStartElement(null, 'OrderNumber', null);
            xmlW.writeCharacters(orderObj.Name);
        xmlW.writeEndElement();
        //End of OrderNumber tag
        
        //beginning of Products tag
        xmlW.writeStartElement(null,'Products',null);
        //System.debug('Order Id is'+orderObj.Id+'Order Products Number&&'+orderObj.invoiceit_s__Job_Product__r.size());
        
        //getting products for charges sent in the Order Req
        
        for(invoiceit_s__Job_Product__c jobProds : orderProducts ) {
            
            if(mapOrderProdIdNLstOrderChargesForOrderProduct.containsKey(jobProds.Id)) {
            
                //Beginning of Product tag
                xmlW.writeStartElement(null,'Product', null); 
                
                //Beginning of ProductId tag
                xmlW.writeStartElement(null,'ProductId',null);
                    xmlW.writeCharacters(jobProds.Id);
                xmlW.writeEndElement();
                //End of ProductId tag
                
                //Beginning of SubscriptionIdentificationNumber tag
                xmlW.writeStartElement(null,'SubscriptionIdentificationNumber',null);
                    if(jobProds.Sin_Number__c != null)
                        xmlW.writeCharacters(jobProds.Sin_Number__c);
                xmlW.writeEndElement();
                //End of SubscriptionIdentificationNumber tag
                
                //Beginning of ProductCode tag
                xmlW.writeStartElement(null,'ProductCode',null);
                    xmlW.writeCharacters(jobProds.invoiceit_s__Product_Code__c);
                xmlW.writeEndElement();
                //End of ProductCode tag
                
                //Beginning of LineItems tag
                xmlW.writeStartElement(null,'LineItems', null); 
                
                //filtering order charges based on a product
                lstOrderRPCForAProduct = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
                for(invoiceit_s__Job_Rate_Plan_Charge__c oRpc : lstOrderProds) {
                    if(oRpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id == jobProds.Id) {
                        lstOrderRPCForAProduct.add(oRpc);
                    }
                }
                
                Map<id,Chat_Product_Order_Charge__c> orderChildToChatProductMap = MDL_OnDemandOrderXML.getchatproductsChildMap(lstOrderRPCForAProduct);
                System.debug('Order Charges Number=='+lstOrderRPCForAProduct.size());
                for(invoiceit_s__Job_Rate_Plan_Charge__c orderProd : lstOrderRPCForAProduct) {
                    Chat_Product_Order_Charge__c junctionObj = orderChildToChatProductMap.get(orderProd.Id);
                    
                    System.debug('&&orderProducts Details&&'+orderProd);
                    //Beginning of LineItem tag
                    xmlW.writeStartElement(null,'LineItem', null);
                    
                    //Beginning of LineItemId tag
                    xmlW.writeStartElement(null, 'LineItemId', null);
                    xmlW.writeCharacters(orderProd.Id+lineItemId);
                    xmlW.writeEndElement();
                    //End of LineItemId tag
                    
                    //Beginning of SubscriptionIdentificationNumber tag
                    if(orderProd.Sin__c != null) {
                        xmlW.writeStartElement(null, 'SubscriptionIdentificationNumber', null);
                            xmlW.writeCharacters(orderProd.SIN__c);
                        xmlW.writeEndElement();
                    }
                    else {
                        xmlW.writeEmptyElement(null, 'SubscriptionIdentificationNumber', null);
                    }
                    //End of SubscriptionIdentificationNumber tag
                    
                    //Beginning of ProductCode tag
                    if(orderProd.invoiceit_s__Accounting_Code__c  != null) {
                        xmlW.writeStartElement(null, 'ProductCode', null);
                            xmlW.writeCharacters(orderProd.invoiceit_s__Accounting_Code__c);
                        xmlW.writeEndElement();
                    }
                    else {
                        xmlW.writeEmptyElement(null,'ProductCode', null);
                    }
                    //End of ProductCode tag
                    
                    //Beginning of ProductName tag
                    if(orderProd.Name != null) {
                        xmlW.writeStartElement(null, 'ProductName', null);
                            xmlW.writeCharacters(orderProd.Name);
                        xmlW.writeEndElement();
                    }
                    else {
                        xmlW.writeEmptyElement(null, 'ProductName', null);
                    }
                    //End of ProductName tag
                    
                    //Beginning of Status tag
                    xmlW.writeStartElement(null, 'Status', null);                                      
                    xmlW.writeCharacters('Cancel');                        
                             
                    xmlW.writeEndElement();
                    //End of Status tag
                    
                    //Beginning of PostDate tag
                    xmlW.writeStartElement(null, 'PostDate', null);
                    postDate = String.valueOf(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.CreatedDate);
                    validatedDateValue = postDate.split(' ');
                    xmlW.writeCharacters(validatedDateValue[0]);
                    xmlW.writeEndElement();
                    //End of PostDate tag
                                                
                    //Beginning of FulfillmentDate tag
                    if(orderProd.Fulfilment_Start_Date__c != null) {
                        if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != 'System Fulfillment' && (orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != null || orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != '')) { 
                            xmlW.writeStartElement(null, 'FulfillmentDate', null);
                            xmlW.writeCharacters(String.valueOf(orderProd.Fulfilment_Start_Date__c));
                            xmlW.writeEndElement();
                        }
                    }
                    //commenting the else part so as to not send in the fulfillment date in case value is not there
                    /*else {
                        xmlW.writeEmptyElement(null, 'FulfillmentDate', null);
                    }*/
                    //End of FulfillmentDate tag
                    
                    //Beginning of CancelDate tag
                    //if(orderProd.invoiceit_s__Status__c == 'Cancelled') {
                        if(orderProd.invoiceit_s__Service_End_Date__c != null) {
                            xmlW.writeStartElement(null, 'CancelDate', null);
                                xmlW.writeCharacters(String.valueOf(orderProd.invoiceit_s__Service_End_Date__c));  
                            xmlW.writeEndElement();
                        }
                    //}
                    //commenting the else part so as to not send in the cancel date in case value is not there
                    /*else {
                        xmlW.writeEmptyElement(null, 'CancelDate', null);
                    }*/
                    //End of CancelDate tag
                    
                    //Beginning of IsProductInventoried tag
                    xmlW.writeStartElement(null, 'IsProductInventoried', null);
                    if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.IsInventoried__c != null)
                        xmlW.writeCharacters(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.IsInventoried__c);
                    xmlW.writeEndElement();
                    //End of IsProductInventoried tag
                    
                    
                   /*  //Beginning of HasChildProducts tag*************************added by akash
                    xmlW.writeStartElement(null, 'HasChildProducts', null);
                    if(!orpcIdVschatOrpc.isEmpty() && orpcIdVschatOrpc.containsKey(orderProd.id)){
                        xmlW.writeCharacters('Y');
                    }
                    else{
                        xmlW.writeCharacters('N');
                    }
                    xmlW.writeEndElement();
                   */ //End of HasChildProducts tag
                    
                    //Beginning of HasparentProducts tag*************************added by akash
                    xmlW.writeStartElement(null, 'HasParentProducts', null);
                    System.debug('@@@@orderProd.invoiceit_s__Order__r.Parent_Order__c'+orderProd.invoiceit_s__Order__r.Parent_Order__c);
                    System.debug('@@@orderProd.Chat_Parent_Order_Rate_Plan_Charge__c'+orderProd.Chat_Parent_Order_Rate_Plan_Charge__c);
                    System.debug('@@@@orderProd.invoiceit_s__Order__r.RecordType.developername'+orderProd.invoiceit_s__Order__r.RecordType.developername);
                    
                    if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name == 'Ngage Live Chat - External Website'){
                        xmlW.writeCharacters('N');
                    }
                    
                    else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name == NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name == '')&& orderProd.invoiceit_s__Order__r.RecordType.developername == 'Nolo_Order'){
                        xmlW.writeCharacters('N');
                    }
                      else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name == NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name == '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == '')){
                        xmlW.writeCharacters('N');
                    }
                      else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name != NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name != '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == '')){
                        xmlW.writeCharacters('Y');                        
                    }
                    else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name != NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name != '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name != NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name != '')){
                        xmlW.writeCharacters('Y');
                    }   
                    xmlW.writeEndElement();
                    //End of HasparentProducts tag
                    
                    //Beginning of ParentProductSIN tag***********added by akash
                    xmlW.writeStartElement(null, 'ParentProductSIN', null);
                     
                    if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name == 'Ngage Live Chat - External Website'){
                        xmlW.writeCharacters('');
                    }
                    else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name == NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name == '')&& orderProd.invoiceit_s__Order__r.RecordType.developername == 'Nolo_Order'){
                        xmlW.writeCharacters('');
                    }
                      else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name == NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name == '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == '')){
                        xmlW.writeCharacters('');
                    }
                      else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name != NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name != '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name == '')){
                        xmlW.writeCharacters(junctionObj.Chat_Product_Order_Rate_Plan_Charge__r.SIN__c);                        
                    }
                    else if((orderProd.invoiceit_s__Order__r.Parent_Order__r.name != NULL || orderProd.invoiceit_s__Order__r.Parent_Order__r.name != '') && orderProd.invoiceit_s__Order__r.RecordType.developername == 'M_NG_Order' && (orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name != NULL || orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.name != '')){
                        xmlW.writeCharacters(orderProd.Chat_Parent_Order_Rate_Plan_Charge__r.SIN__c);
                    }   
                    xmlW.writeEndElement();
                    //End of HasparentProducts tag
                    
                    //Begin of FulfilledBy Tag
                        xmlW.writeStartElement(null, 'FulfilledBy', null);
                           
                        xmlW.writeEndElement();
                        //End of FulfilledBy tag
                    
                        //Begin of FulfillmentID Tag
                        xmlW.writeStartElement(null, 'FulfillmentID', null);
                             if(orderProd.Chat_ID__c != null){
                                xmlW.writeCharacters(orderProd.Chat_ID__c);
                             }
                            else{
                                xmlW.writeCharacters(' ');
                            }
                        xmlW.writeEndElement();
                        //End of FulfillmentID tag
                        
                     // Adding Service Start Date Tag for Charges by Sai C
                        xmlW.writeStartElement(null, 'ServiceStartDate', null);
                        if(orderProd.invoiceit_s__Service_Activation_Date__c != null){
                        xmlW.writeCharacters(String.valueOf(orderProd.invoiceit_s__Service_Activation_Date__c));  
                        }
                        else{
                            xmlW.writeCharacters('');
                        }
                        xmlW.writeEndElement();
                     // End of Service Start date Tag for charges    
                    
                    // Adding Service End Date Tag for Charges by Sai C
                        xmlW.writeStartElement(null, 'ServiceEndDate', null);
                        if(orderProd.invoiceit_s__Service_End_Date__c != null){
                        xmlW.writeCharacters(String.valueOf(orderProd.invoiceit_s__Service_End_Date__c));  
                        }
                        else{
                            xmlW.writeCharacters('');
                        }
                        xmlW.writeEndElement();
                    
                    // Adding Service End Date Tag for Charges by Sai C
                        xmlW.writeStartElement(null, 'LiveDate', null);
                        if(orderProd.Live_Date__c != null){
                        xmlW.writeCharacters(String.valueOf(orderProd.Live_Date__c));  
                        }
                        else{
                        xmlW.writeCharacters('');
                        }
                        xmlW.writeEndElement();
                     // End of Service End date Tag for charges
                    
                        
                    //beginning of Attributes tag
                    xmlW.writeStartElement(null, 'Attributes', null);
                    
                    //beginning of Attribute tag
                    xmlW.writeStartElement(null, 'Attribute', null);
                    
                    //Beginning of Inventory Id Attribute Name tag
                    xmlW.writeStartElement(null, 'Name', null);
                    xmlW.writeCharacters('InventoryId');
                    xmlW.writeEndElement();
                    //End of Inventory Id Attribute Name tag
                    
                    //Beginning of Inventory Id Attribute Value tag
                    xmlW.writeStartElement(null, 'Value', null);
                    if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c != null)
                        xmlW.writeCharacters(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c);
                    xmlW.writeEndElement();
                    //End of Inventory Id Attribute Value tag
                                
                    xmlW.writeEndElement();
                    //End of Attribute tag
                    
                    //Inclusion of Other Attributes
                    for(Order_Charge_Attribute__c orderCharges : orderProd.Order_Charge_Attributes__r) {
                        System.debug('Attributesssss'+orderCharges);
                        //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        //Beginning of Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        if(orderCharges.Attribute_Name__c != null && orderCharges.Attribute_Name__c != '')
                            xmlW.writeCharacters(orderCharges.Attribute_Name__c);
                        xmlW.writeEndElement();
                        //End of Name tag
                        
                        //Beginning of Value Tag
                        xmlW.writeStartElement(null, 'Value', null);
                        if(orderCharges.Attribute_Type__c != null) {
                            if(orderCharges.Attribute_Type__c == 'Text') {
                                if(orderCharges.String_Value__c != null && orderCharges.String_Value__c !='')
                                    xmlW.writeCharacters(orderCharges.String_Value__c);
                            }
                            else if(orderCharges.Attribute_Type__c == 'Number') {
                                if(orderCharges.Number_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(orderCharges.Number_Value__c));
                            }
                            else if(orderCharges.Attribute_Type__c == 'Boolean') {
                                    xmlW.writeCharacters(String.valueOf(orderCharges.Boolean_Value__c));
                            }
                            else if(orderCharges.Attribute_Type__c == 'Picklist') {
                                if(orderCharges.Picklist_Value__c != null && orderCharges.Picklist_Value__c !='')
                                    xmlW.writeCharacters(orderCharges.Picklist_Value__c);
                            }
                            else if(orderCharges.Attribute_Type__c == 'Date') {
                                if(orderCharges.Date_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(orderCharges.Date_Value__c));
                            }
                            else if(orderCharges.Attribute_Type__c == 'Phone') {
                                if(orderCharges.Phone_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(orderCharges.Phone_Value__c));
                            }
                            else {
                                
                            }
                        }
                        xmlW.writeEndElement();
                        //End of Value tag
                        
                        //adding ID tag for all attributes here
                        xmlW.writeStartElement(null, 'ID', null);
                        if(orderCharges.Value_ID__c != null){
                            xmlW.writeCharacters(orderCharges.Value_ID__c);
                        }
                        else{
                            xmlW.writeCharacters(' ');
                        }
                        xmlW.writeEndElement(); 
                        
                                              
                        xmlW.writeEndElement();
                        //End of Attribute tag
                    }
                    
                    xmlW.writeEndElement();
                    //End of Attributes Tag
                    
                    //Begin of ChildProducts tag ******************************akash
                  /*  xmlW.writeStartElement(null, 'ChildProducts', null);
                        
                        if(!orpcIdVschatOrpc.isEmpty() && orpcIdVschatOrpc.containsKey(orderProd.id)){
                            //Begin of ChildProduct tag
                            xmlW.writeStartElement(null, 'ChildProduct', null);
                            
                                //Begin of ChildProductName tag
                                xmlW.writeStartElement(null, 'ChildProductName', null);
                                xmlW.writeCharacters(orpcIdVschatOrpc.get(orderProd.id).Chat_Usage_Order_Rate_Plan_Charge__r.Name);
                                xmlW.writeEndElement();
                                //End of ChildProductName Tag
                                
                                //Begin of ChildProductCode tag
                                xmlW.writeStartElement(null, 'ChildProductCode', null);
                                xmlW.writeCharacters(orpcIdVschatOrpc.get(orderProd.id).Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c);
                                xmlW.writeEndElement();
                                //End of ChildProductCode Tag
                                
                                //Begin of ChildProductSIN tag
                                xmlW.writeStartElement(null, 'ChildProductSIN', null);
                                xmlW.writeCharacters(orpcIdVschatOrpc.get(orderProd.id).Chat_Usage_Order_Rate_Plan_Charge__r.SIN__c);
                                xmlW.writeEndElement();
                                //End of ChildProductSIN Tag
                            
                            
                            xmlW.writeEndElement();
                           //End of ChildProduct Tag
                        
                        }
                        else{ 
                            xmlW.writeCharacters(' ');
                        }
                    
                    xmlW.writeEndElement();
                   */ //End of ChildProducts Tag
                    
                    xmlW.writeEndElement();
                    //End of LineItem Tag
                    
                }
                
                xmlW.writeEndElement();
                //End of LineItems tag
                
                xmlW.writeEndElement();
                //End of Product tag
            }   
        }
        xmlW.writeEndElement();
        //End of Products Tag
        
        xmlW.writeEndElement();
        //End of Order tag
        
        xmlW.writeEndElement();
        //End of OrderRequest tag
        
        reqXML = xmlW.getXmlString();
         String reqXmlupdted = reqXML.replace('&','%26');
         String reqXmlupdted1 = reqXmlupdted.replace('+','%2B');
        System.debug('@@@@@Order reqXmlupdted1 :'+reqXmlupdted1);
        return reqXmlupdted1;
    }
    public static void parseResponseXML_OrderResponse(List<String> lstResponses) {
        String txtmsg = '';
        List<Case> lstCases = new List<Case>();
        AssignmentRule AR;
        Database.DMLOptions dmlOpts;
        //Fetching the assignment rules on case
        for(AssignmentRule assignRule : [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1]){
            AR = assignRule;
        }
        system.debug('@@@@AR'+AR);
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        dmlOpts = new Database.DMLOptions();
        if(AR!=null)
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        
        system.debug('@@@lstResponses'+ lstResponses);
        for(String resp : lstResponses) {
            
            Dom.Document response = new Dom.Document();
            system.debug('@@@response'+ response);
            response.load(resp);
            dom.Xmlnode res = response.getRootElement();
            //String uniqueId = res.getChildElement('RequestId', null).getText();
            //String []splitRequest = uniqueId.split('-');
            //String toUpdateId = splitRequest[0];
            String respCode = res.getChildElement('HttpResponseCode', null).getText();
            String cusNumber = res.getChildElement('Order',null).getChildElement('CustomerNumber',null).getText();
            dom.Xmlnode res1 = res.getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null);
            dom.Xmlnode[] res3 = res.getChildElement('Order',null).getChildElement('LineItems',null).getChildElements();
            txtmsg = res1.getText();
            System.debug('text message received is :'+txtmsg);
            if(respCode != '200') {
                Case c = new Case();
                c.Description = txtmsg;
                c.Subject = 'Order Request Error';
                c.Priority = 'High';
                c.setOptions(dmlOpts);
                lstCases.add(c);
            }
        }
        if(lstCases.size() > 0)
            Database.insert(lstCases);
    }
    @future(callout = true)
    public static void orderReqInCaseOfAttributesChange(Set<Id> orderCharges,List<Id> lstAttIds,String userName) {
        MDL_Integration_Vim_Efs.orderRequest(orderCharges,lstAttIds,userName);
    }    
    public static void orderRequest(Set<Id> orderCharges,List<Id> lstAttIds,String userName) {
        String reqXML;
        MDL_RecursionHandler.CheckUpdate = true;
        List<String> lstResponseBody = new List<String>();
        List<Error_Log__c> lstErrLogs = new List<Error_Log__c>();
        List<Error_Log__c> lstExistingErrLogs = new List<Error_Log__c>();
        Map<Id,Error_Log__c> mapIdNExistingErrLogs = new Map<Id,Error_Log__c>();
        
        /****************added by akash ***************************/
        List<invoiceit_s__Job_Rate_Plan_Charge__c>orpcList             = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        
        Map<Id,List<Order_Charge_Attribute__c>> mapOrderIdNlstOrderChargeAttributes = new Map<Id,List<Order_Charge_Attribute__c>>();
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('OrderRequest');
        String endPoint = String.valueOf(endPts.Endpoint_URL__c);
        String methodType = endPts.MethodType__c;
        
        //code for authentication
        String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)
        /*String endPoint1 = 'cert3-svcs.martindale.com/mhintegration/order';
        String privateKey = 'F2DCA2AD71561755E0433454B60AF99D';
        String apiKey = '76F1CF765AA41A8E695F66A815B7D345';*/
        
         String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
        String privateKey = endPts.Private_Key__c;
        String publicKey  =   endPts.Public_Key__c;
        String apiKey = endPts.API_key__c;
        
        
       /* String httpVerb = 'POST';
        string textToBeHashed = timeDifferenceInSeconds + ':' + endPoint1 + ':' + httpVerb + ':' + privateKey;
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
        Restrict_Integration_Calls__c rCalls = Restrict_Integration_Calls__c.getValues('Restrict');
        System.debug('**'+rCalls);
        Boolean restrictCalls = Boolean.valueOf(rCalls.Restrict_Callouts__c);
        System.debug('a values is **'+restrictCalls);
        
        
        Map<Id,invoiceit_s__Job__c> mapOrderIdNOrder = new Map<Id,invoiceit_s__Job__c>();
        Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>>mapOrderIdNLstOrderRatePlanCharges = new Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>>();
        
        //get Ordercharges for an order
        for(invoiceit_s__Job_Rate_Plan_Charge__c  orderCharge : [Select i.invoiceit_s__Status__c, i.invoiceit_s__Job_Rate_Plan__c, i.Cancel_Date__c , i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c,i.invoiceit_s__Order__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.Name,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Sin_Number__c,i.Chat_Parent_Order_Rate_Plan_Charge__r.SIN__c,i.Chat_Parent_Order_Rate_Plan_Charge__r.name,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name,i.invoiceit_s__Order__r.Parent_Order__r.name,i.invoiceit_s__Order__r.RecordType.developerName,
                                                                        i.SIN__c,i.invoiceit_s__Accounting_Code__c , i.Name, i.invoiceit_s__Price_Type__c,i.invoiceit_s__Service_End_Date__c,i.invoiceit_s__Service_Activation_Date__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id,i.Fulfilment_Start_Date__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.CreatedDate,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Shippable__c,
                                                                        (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                                                                        LastModifiedById, SystemModstamp, LastActivityDate, Attribute_Name__c, 
                                                                        Attribute_Order__c, Attribute_Picklist_Values__c, Attribute_Type__c, Boolean_Value__c, 
                                                                        Date_Value__c, Maximum_No_Of_Characters_In_Text__c, Minimum_No_Of_Characters_In_Text__c, 
                                                                        Number_Value__c, Order_Rate_Plan_Charge__c, Phone_Value__c, Picklist_Value__c, String_Value__c,Value_ID__c
                                                                        From Order_Charge_Attributes__r order by Attribute_Order__c), 
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Customer_Number__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__c,i.live_Date__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.IsInventoried__c,
                                                                        i.Renew_Rebase_Truncate_Date__c, i.Chat_ID__c
                                                                        From invoiceit_s__Job_Rate_Plan_Charge__c i 
                                                                        where i.Id in: orderCharges
                                                                        and (RecordType.DeveloperName = 'MDL_Order_Rate_Plan_Charge' or RecordType.DeveloperName = 'Nolo_Order_Rate_Plan_Charge' or RecordType.DeveloperName = 'M_NG_Order_Rate_Plan_Charge')]) {
            if(mapOrderIdNLstOrderRatePlanCharges.containsKey(orderCharge.invoiceit_s__Order__c)){
                mapOrderIdNLstOrderRatePlanCharges.get(orderCharge.invoiceit_s__Order__c).add(orderCharge);
            }
            else{
                mapOrderIdNLstOrderRatePlanCharges.put(orderCharge.invoiceit_s__Order__c,new List<invoiceit_s__Job_Rate_Plan_Charge__c>{orderCharge});
            }
            
           /*************************added by akash****************************/                                                                 
           orpcList.add(orderCharge);                                                                
                                                                            
        }
        
        /*************added by akash ******************/
        Map<id,Chat_Product_Order_Charge__c> orpcIdVschatOrpc = new Map<id,Chat_Product_Order_Charge__c>();
        if(!mapOrderIdNLstOrderRatePlanCharges.isEmpty()){
            orpcIdVschatOrpc = MDL_OnDemandOrderXML.getchatproductsMap(orpcList);
        }
        
        
        //get Orders from Order Charges
        for(invoiceit_s__Job__c orderObj : [Select i.invoiceit_s__Account__r.MH_Cust_Number__c, i.invoiceit_s__Account__c,
                                            i.invoiceit_s__Account__r.Org_Id__c, (Select Id, Name, invoiceit_s__Job__c, invoiceit_s__Description__c, invoiceit_s__Product_Code__c, 
                                                   invoiceit_s__Product_Family__c, invoiceit_s__Product__c, invoiceit_s__SequenceNumber__c, Tracking_Number__c, 
                                                   Inventory_Id__c, Customer_Number__c, Sin_Number__c From invoiceit_s__Job_Product__r),
                                             i.OrderNumber__c, i.Name, i.Id, i.Fulfillment_Date__c From invoiceit_s__Job__c i where i.Id in : mapOrderIdNLstOrderRatePlanCharges.keySet()
                                             and (RecordType.DeveloperName = 'MH_Orders' or RecordType.DeveloperName = 'Nolo_Order'or RecordType.DeveloperName = 'M_NG_Order')]) {
            mapOrderIdNOrder.put(orderObj.Id,orderObj);
        }
        //Checking if Order XML already exists in Error Log, if exists do not send that order , queue it along with the existing order
        for(Error_Log__c err : [Select e.XML_Mesaage_Type__c, e.XML_Body__c, e.Sent_Successfully__c, e.Order_Number__c,e.Order_Name__c,e.Error_Reason__c, e.Name, e.Id ,e.Re_process_date_time__c
                                From Error_Log__c e
                                Where e.XML_Mesaage_Type__c = 'OrderRequest' AND e.Order_Number__c in :mapOrderIdNOrder.keySet()] ) {
                mapIdNExistingErrLogs.put(err.Order_Number__c,err);                 
        }
        System.debug('mapOrderId And Error Logs^^^'+mapIdNExistingErrLogs);
        System.debug('mapOrderIdNLstOrderRatePlanCharges:::'+mapOrderIdNLstOrderRatePlanCharges+'size==='+mapOrderIdNLstOrderRatePlanCharges.size());
        System.debug('mapOrderIdNOrder***'+mapOrderIdNOrder+'size==='+mapOrderIdNOrder.size());
        //System.debug('mapOrderIdNAttributes^^^'+mapOrderIdNlstOrderChargeAttributes);
        for(Id orderId : mapOrderIdNOrder.keySet()) {
            if(mapOrderIdNLstOrderRatePlanCharges.containsKey(orderId) && mapOrderIdNOrder.containsKey(orderId)) { 
                System.debug('inside order req method call');
                reqXML=MDL_Integration_Vim_Efs.constructXML_OrderRequest(userName,mapOrderIdNLstOrderRatePlanCharges.get(orderId),mapOrderIdNOrder.get(orderId),orpcIdVschatOrpc);
                String reqXmlupdted1 = reqXML.replace('+','%2B');
                String reqXmlupdted = reqXmlupdted1.replace('&','%26');
                
                
                string ipayload   = 'publicKey='+ publicKey + '&' + 'timestamp=' + timeDifferenceInSeconds + '&' + 'xml=' + reqXmlupdted;
                Blob textToBeHashedInBytes = Blob.valueOf(ipayload);
                Blob mac = Crypto.generateMac('HmacSHA256',Blob.valueOf(ipayload), Blob.valueOf(privateKey));
                String encodedText  = EncodingUtil.base64Encode(mac);
                String Header      =  encodedText + '|'+  timeDifferenceInSeconds;
                String givenEndpoint   = endPts.Endpoint_URL__c;
                String encodedurl = EncodingUtil.urlEncode(givenEndpoint, 'UTF-8');
                
                if(restrictCalls == false) {
                    if(mapIdNExistingErrLogs.containsKey(orderId)) {
                        Error_Log__c err = new Error_Log__c();
                        System.debug('###order already exists in Error Log###');
                        err.XML_Mesaage_Type__c = 'OrderRequest';
                        err.XML_Body__c = reqXML;
                        err.Order_Number__c = orderId;
                        err.Error_Reason__c = 'Previous instance of the same order exists in the Error log';
                        err.Order_Name__c = mapOrderIdNOrder.get(orderId).Name;
                        lstExistingErrLogs.add(err);
                    }
                    else {
                        try{
                            //added by akash on 9/3/16
                             //String givenEndpoint = 'https://back-office-services.lawyers.com/services/efs/v1/handleSalesForceXml';
                             //String givenEndpoint = 'http://98.158.206.132/services/efs/v1/handleSalesForceXml';
                              //Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('OrderRequest');
                            //String givenEndpoint = endPts.Endpoint_URL__c;
                            
                            Http http = new Http(); //global class which is used in both request & response
                            HttpRequest req = new HttpRequest(); //initiate HTTP request
                            //req.setEndpoint(endPoint);
                            req.setEndpoint(givenEndpoint);
                            
                            req.setMethod(methodType);
                            req.setTimeout(20000);
                            
                            //req.setBody(reqXML);
                            //String reqXmlupdted = reqXML.replace('&','%26');
                            req.setBody(ipayload);
                             
                            
                            req.setHeader('Accept', 'application/xml');
                            //req.setHeader('Content-Type', 'text/xml');
                            
                            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                            //req.setHeader('Authorization', aToken);
                            req.setHeader('Authorization', Header);
                            HTTPResponse res = http.send(req);
                            System.debug('Response Body in order Message is : '+res.getBody());
                            if(res.getStatusCode() == 200){
                                Error_Log__c temp_error = MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody() , reqXML);
                                if(temp_error != null){
                                    temp_error.XML_Mesaage_Type__c = 'OrderRequest';
                                    lstErrLogs.add(temp_error);
                                }   
                            }
                            if(res.getStatusCode() == 400 || res.getStatusCode() == 401){                               
                                MDL_Integration_Vim_Efs.parseResponse400Error(res.getBody(),'OrderRequest',reqXML,orderId,mapOrderIdNOrder.get(orderId).Name);                              
                            }
                            else{
                                if(res.getStatusCode() != 500 && res.getStatusCode() != 404 && res.getStatusCode() != 502) { 
                                    lstResponseBody.add(res.getBody());
                                }
                                else {
                                    Error_Log__c err = new Error_Log__c();
                                    err.XML_Mesaage_Type__c = 'OrderRequest';
                                    err.XML_Body__c = reqXML;
                                    err.Order_Number__c = orderId;
                                    err.Order_Name__c = mapOrderIdNOrder.get(orderId).Name;
                                    err.Error_Reason__c = res.getStatusCode() +' : '+res.getStatus();
                                    lstErrLogs.add(err);    
                                }
                            }
                        }catch(System.CalloutException ce) {
                            Error_Log__c err = new Error_Log__c();
                            err.XML_Mesaage_Type__c = 'OrderRequest';
                            err.XML_Body__c = reqXML;
                            err.Order_Number__c = orderId;
                            err.Order_Name__c = mapOrderIdNOrder.get(orderId).Name;
                            err.Error_Reason__c = 'Problem with web service operation. Failed to make a callout to an external system.';
                            lstErrLogs.add(err); 
                        }
                        catch(System.Exception e) {
                            MDL_Integration_Vim_Efs.sendEmailInCaseOfException('Order XMl Request',orderId,e.getMessage());
                        }      
                    }
                }
                else if(restrictCalls == true) {
                    System.debug('No calls will be sent since custom setting is activated');
                }
            }
        }
        if(lstExistingErrLogs.size() > 0)
                Database.insert(lstExistingErrLogs);
        if(lstErrLogs.size() > 0) {
            Database.insert(lstErrLogs);
        }
        MDL_Integration_Vim_Efs.parseResponseXML_OrderResponse(lstResponseBody);
    }
    
    
    
    /******************************************************************************
     * Author      : akash
     * Description : To send XML in case of live date insertion or update
     * Created Date: 22/06/2017
     * ***************************************************************************/
     @future(callout = true)
    public static void livedateXMLCallout(Set<Id> liveDateOrders, String username){
        system.debug('@@@@@ in livedateXMLCallout');
        
        //Set<Id> orderCharges = new Set<Id>();
        Set<Id> orderCharges = (new Map<id,invoiceit_s__Job_Rate_Plan_Charge__c>([select id from invoiceit_s__Job_Rate_Plan_Charge__c where invoiceit_s__Order__c IN:liveDateOrders])).keyset();
        
        
        
        
        //Declarations
        String reqXML;
        List<String> lstResponseBody                                   = new List<String>();
        List<Error_Log__c> lstErrLogs                                  = new List<Error_Log__c>();
        List<Error_Log__c> lstExistingErrLogs                          = new List<Error_Log__c>();
        Map<Id,Error_Log__c> mapIdNExistingErrLogs                     = new Map<Id,Error_Log__c>();
        List<invoiceit_s__Job_Rate_Plan_Charge__c>orpcList             = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        
        Map<Id,List<Order_Charge_Attribute__c>> mapOrderIdNlstOrderChargeAttributes = new Map<Id,List<Order_Charge_Attribute__c>>();
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('OrderRequest');
        String endPoint = String.valueOf(endPts.Endpoint_URL__c);
        String methodType = endPts.MethodType__c;
        String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)
        String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
        String privateKey = endPts.Private_Key__c;
        String publicKey  =   endPts.Public_Key__c;
        String apiKey     = endPts.API_key__c;
        Restrict_Integration_Calls__c rCalls = Restrict_Integration_Calls__c.getValues('Restrict');
        Boolean restrictCalls = Boolean.valueOf(rCalls.Restrict_Callouts__c);
        
        Map<Id,invoiceit_s__Job__c> mapOrderIdNOrder = new Map<Id,invoiceit_s__Job__c>();
        Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>>mapOrderIdNLstOrderRatePlanCharges = new Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>>();
        
        //get Ordercharges for an order
        for(invoiceit_s__Job_Rate_Plan_Charge__c  orderCharge : [Select i.invoiceit_s__Status__c, i.invoiceit_s__Job_Rate_Plan__c, i.Cancel_Date__c , i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c,i.invoiceit_s__Order__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.Name,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Sin_Number__c,i.Chat_Parent_Order_Rate_Plan_Charge__r.SIN__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name, i.invoiceit_s__Order__r.Parent_Order__r.Name, i.Chat_Parent_Order_Rate_Plan_Charge__r.Name, i.invoiceit_s__Order__r.Recordtype.DeveloperName,
                                                                        i.SIN__c,i.invoiceit_s__Accounting_Code__c , i.Name, i.invoiceit_s__Price_Type__c,i.invoiceit_s__Service_End_Date__c,i.invoiceit_s__Service_Activation_Date__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id,i.Fulfilment_Start_Date__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.CreatedDate,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Shippable__c,
                                                                        (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                                                                        LastModifiedById, SystemModstamp, LastActivityDate, Attribute_Name__c, 
                                                                        Attribute_Order__c, Attribute_Picklist_Values__c, Attribute_Type__c, Boolean_Value__c, 
                                                                        Date_Value__c, Maximum_No_Of_Characters_In_Text__c, Minimum_No_Of_Characters_In_Text__c, 
                                                                        Number_Value__c, Order_Rate_Plan_Charge__c, Phone_Value__c, Picklist_Value__c, String_Value__c,Value_ID__c
                                                                        From Order_Charge_Attributes__r order by Attribute_Order__c), 
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Customer_Number__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__c,i.live_Date__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.IsInventoried__c,
                                                                        i.Renew_Rebase_Truncate_Date__c, i.Chat_ID__c,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c
                                                                        From invoiceit_s__Job_Rate_Plan_Charge__c i 
                                                                        where i.Id in: orderCharges
                                                                        and (RecordType.DeveloperName = 'MDL_Order_Rate_Plan_Charge' or RecordType.DeveloperName = 'Nolo_Order_Rate_Plan_Charge'or RecordType.DeveloperName = 'M_NG_Order_Rate_Plan_Charge')]) {
                if(mapOrderIdNLstOrderRatePlanCharges.containsKey(orderCharge.invoiceit_s__Order__c)){
                    mapOrderIdNLstOrderRatePlanCharges.get(orderCharge.invoiceit_s__Order__c).add(orderCharge);
                }
                else{
                    mapOrderIdNLstOrderRatePlanCharges.put(orderCharge.invoiceit_s__Order__c,new List<invoiceit_s__Job_Rate_Plan_Charge__c>{orderCharge});
                }
                                                                                
                                                                             
               orpcList.add(orderCharge);                                                                
                                                                            
          }
        
            Map<id,Chat_Product_Order_Charge__c> orpcIdVschatOrpc = new Map<id,Chat_Product_Order_Charge__c>();
            if(!mapOrderIdNLstOrderRatePlanCharges.isEmpty()){
                orpcIdVschatOrpc = MDL_OnDemandOrderXML.getchatproductsMap(orpcList);
            }
            
            
            //get Orders from Order Charges
            for(invoiceit_s__Job__c orderObj : [Select i.invoiceit_s__Account__r.MH_Cust_Number__c, i.invoiceit_s__Account__c,
                                                i.invoiceit_s__Account__r.Org_Id__c, (Select Id, Name, invoiceit_s__Job__c, invoiceit_s__Description__c, invoiceit_s__Product_Code__c, 
                                                       invoiceit_s__Product_Family__c, invoiceit_s__Product__c, invoiceit_s__SequenceNumber__c, Tracking_Number__c, 
                                                       Inventory_Id__c, Customer_Number__c, Sin_Number__c From invoiceit_s__Job_Product__r),
                                                 i.OrderNumber__c, i.Name, i.Id, i.Fulfillment_Date__c From invoiceit_s__Job__c i where i.Id in : mapOrderIdNLstOrderRatePlanCharges.keySet()
                                                 and (RecordType.DeveloperName = 'MH_Orders' or RecordType.DeveloperName = 'Nolo_Order' or RecordType.DeveloperName = 'M_NG_Order')]) {
                mapOrderIdNOrder.put(orderObj.Id,orderObj);
            }
            //Checking if Order XML already exists in Error Log, if exists do not send that order , queue it along with the existing order
            for(Error_Log__c err : [Select e.XML_Mesaage_Type__c, e.XML_Body__c, e.Sent_Successfully__c, e.Order_Number__c,e.Order_Name__c,e.Error_Reason__c, e.Name, e.Id ,e.Re_process_date_time__c
                                    From Error_Log__c e
                                    Where e.XML_Mesaage_Type__c = 'OrderRequest' AND e.Order_Number__c in :mapOrderIdNOrder.keySet()] ) {
                    mapIdNExistingErrLogs.put(err.Order_Number__c,err);                 
            }
        
          for(Id orderId : mapOrderIdNOrder.keySet()) {
            if(mapOrderIdNLstOrderRatePlanCharges.containsKey(orderId) && mapOrderIdNOrder.containsKey(orderId)) { 
                System.debug('inside order Cancellation method call');
                reqXML=MDL_Integration_Vim_Efs.constructXML_OrderCancel(userName,mapOrderIdNLstOrderRatePlanCharges.get(orderId),mapOrderIdNOrder.get(orderId),orpcIdVschatOrpc);
                String reqXmlupdted1 = reqXML.replace('+','%2B');
                String reqXmlupdted = reqXmlupdted1.replace('&','%26');
                
                
                string ipayload   = 'publicKey='+ publicKey + '&' + 'timestamp=' + timeDifferenceInSeconds + '&' + 'xml=' + reqXmlupdted;
                Blob textToBeHashedInBytes = Blob.valueOf(ipayload);
                Blob mac = Crypto.generateMac('HmacSHA256',Blob.valueOf(ipayload), Blob.valueOf(privateKey));
                String encodedText  = EncodingUtil.base64Encode(mac);
                String Header      =  encodedText + '|'+  timeDifferenceInSeconds;
                String givenEndpoint   = endPts.Endpoint_URL__c;
                String encodedurl = EncodingUtil.urlEncode(givenEndpoint, 'UTF-8');
                
                if(restrictCalls == false) {
                    if(mapIdNExistingErrLogs.containsKey(orderId)) {
                        Error_Log__c err = new Error_Log__c();
                        System.debug('###order already exists in Error Log###');
                        err.XML_Mesaage_Type__c = 'OrderRequest';
                        err.XML_Body__c = reqXML;
                        err.Order_Number__c = orderId;
                        err.Error_Reason__c = 'Previous instance of the same order exists in the Error log';
                        err.Order_Name__c = mapOrderIdNOrder.get(orderId).Name;
                        lstExistingErrLogs.add(err);
                    }
                    else {
                        try{
                            
                            
                            Http http = new Http(); //global class which is used in both request & response
                            HttpRequest req = new HttpRequest(); //initiate HTTP request
                            //req.setEndpoint(endPoint);
                            req.setEndpoint(givenEndpoint);
                            
                            req.setMethod(methodType);
                            req.setTimeout(20000);
                            
                            //req.setBody(reqXML);
                            //String reqXmlupdted = reqXML.replace('&','%26');
                            req.setBody(ipayload);
                             
                            
                            req.setHeader('Accept', 'application/xml');
                            //req.setHeader('Content-Type', 'text/xml');
                            
                            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                            //req.setHeader('Authorization', aToken);
                            req.setHeader('Authorization', Header);
                            HTTPResponse res = http.send(req);
                            System.debug('Response Body in order Message is : '+res.getBody());
                            if(res.getStatusCode() == 200){
                                Error_Log__c temp_error = MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody() , reqXML);
                                 if(temp_error != null){
                                    temp_error.XML_Mesaage_Type__c = 'OrderRequest';
                                    lstErrLogs.add(temp_error);
                                }   
                            }
                            if(res.getStatusCode() == 400 || res.getStatusCode() == 401){                               
                                MDL_Integration_Vim_Efs.parseResponse400Error(res.getBody(),'OrderRequest',reqXML,orderId,mapOrderIdNOrder.get(orderId).Name);                              
                            }
                            else{
                                if(res.getStatusCode() != 500 && res.getStatusCode() != 404 && res.getStatusCode() != 502) { 
                                    lstResponseBody.add(res.getBody());
                                }
                                else {
                                    Error_Log__c err = new Error_Log__c();
                                    err.XML_Mesaage_Type__c = 'OrderRequest';
                                    err.XML_Body__c = reqXML;
                                    err.Order_Number__c = orderId;
                                    err.Order_Name__c = mapOrderIdNOrder.get(orderId).Name;
                                    err.Error_Reason__c = res.getStatusCode() +' : '+res.getStatus();
                                    lstErrLogs.add(err);    
                                }
                            }
                        }catch(System.CalloutException ce) {
                            Error_Log__c err = new Error_Log__c();
                            err.XML_Mesaage_Type__c = 'OrderRequest';
                            err.XML_Body__c = reqXML;
                            err.Order_Number__c = orderId;
                            err.Order_Name__c = mapOrderIdNOrder.get(orderId).Name;
                            err.Error_Reason__c = 'Problem with web service operation. Failed to make a callout to an external system.';
                            lstErrLogs.add(err); 
                        }
                        catch(System.Exception e) {
                            MDL_Integration_Vim_Efs.sendEmailInCaseOfException('Order XMl Request',orderId,e.getMessage());
                        }      
                    }
                }
                else if(restrictCalls == true) {
                    System.debug('No calls will be sent since custom setting is activated');
                }
            }
        }
        
        
        
        
        
    }
    
    
    
    
    //Added by Sai C for order Cancellation - 06-12-2017
    @future(callout = true)
    public static void orderReqInCaseOfOrdercancel(Set<Id> orderCharges,List<Id> lstAttIds,String userName) {
        MDL_Integration_Vim_Efs.orderRequestforCancel(orderCharges,lstAttIds,userName);
    }    
    public static void orderRequestforCancel(Set<Id> orderCharges,List<Id> lstAttIds,String userName) {
        String reqXML;
        MDL_RecursionHandler.CheckUpdate = true;
        List<String> lstResponseBody = new List<String>();
        List<Error_Log__c> lstErrLogs = new List<Error_Log__c>();
        List<Error_Log__c> lstExistingErrLogs = new List<Error_Log__c>();
        Map<Id,Error_Log__c> mapIdNExistingErrLogs = new Map<Id,Error_Log__c>();
        
        /****************added by akash ***************************/
        List<invoiceit_s__Job_Rate_Plan_Charge__c>orpcList             = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        
        // Added for Release Inventory Logic 
        
        //Map<Order Id, Set<Order Product Id>> --> this map is used to release inventories
        Map<Id,Set<Id>> orderIdVsOrderProducts = new Map<Id,Set<Id>>();
        List<invoiceit_s__Job_Product__c> orderProdstoRelease = new List<invoiceit_s__Job_Product__c>();
        //Map<orderId, list of opportunities>
        Map<Id,List<Opportunity>> orderIdVsOpportunites      =  new Map<Id,List<Opportunity>>();
        Map<Id,List<Opportunity>> MHorderIdVsOpportunites      =  new Map<Id,List<Opportunity>>();
        List<Opportunity> oppstoClosedLost                   = new List<Opportunity>();
        Set<Id> oppIds        = new Set<Id>();
        List<invoiceit_crmx__Opportunity_Product__c> oppProdstoRelease = new List<invoiceit_crmx__Opportunity_Product__c>();
        // END
        
        Map<Id,List<Order_Charge_Attribute__c>> mapOrderIdNlstOrderChargeAttributes = new Map<Id,List<Order_Charge_Attribute__c>>();
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('OrderRequest');
        String endPoint = String.valueOf(endPts.Endpoint_URL__c);
        String methodType = endPts.MethodType__c;
        
        //code for authentication
        String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)
        /*String endPoint1 = 'cert3-svcs.martindale.com/mhintegration/order';
        String privateKey = 'F2DCA2AD71561755E0433454B60AF99D';
        String apiKey = '76F1CF765AA41A8E695F66A815B7D345';*/
        
        String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
        String privateKey = endPts.Private_Key__c;
        String publicKey  =   endPts.Public_Key__c;
        String apiKey = endPts.API_key__c;
        
        
       /* String httpVerb = 'POST';
        string textToBeHashed = timeDifferenceInSeconds + ':' + endPoint1 + ':' + httpVerb + ':' + privateKey;
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
        Restrict_Integration_Calls__c rCalls = Restrict_Integration_Calls__c.getValues('Restrict');
        System.debug('**'+rCalls);
        Boolean restrictCalls = Boolean.valueOf(rCalls.Restrict_Callouts__c);
        System.debug('a values is **'+restrictCalls);
        
        
        Map<Id,invoiceit_s__Job__c> mapOrderIdNOrder = new Map<Id,invoiceit_s__Job__c>();
        Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>>mapOrderIdNLstOrderRatePlanCharges = new Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>>();
        
        //get Ordercharges for an order
        for(invoiceit_s__Job_Rate_Plan_Charge__c  orderCharge : [Select i.invoiceit_s__Status__c, i.invoiceit_s__Job_Rate_Plan__c, i.Cancel_Date__c , i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c,i.invoiceit_s__Order__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c,invoiceit_s__order__r.RecordType.DeveloperName,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.Name,i.invoiceit_s__Order__r.Parent_Order__r.name,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Sin_Number__c,i.Chat_Parent_Order_Rate_Plan_Charge__r.name,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name,i.Chat_Parent_Order_Rate_Plan_Charge__r.SIN__c,
                                                                        i.SIN__c,i.invoiceit_s__Accounting_Code__c , i.Name, i.invoiceit_s__Price_Type__c,i.invoiceit_s__Service_End_Date__c,i.invoiceit_s__Service_Activation_Date__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id,i.Fulfilment_Start_Date__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.CreatedDate,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Shippable__c,
                                                                        (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                                                                        LastModifiedById, SystemModstamp, LastActivityDate, Attribute_Name__c, 
                                                                        Attribute_Order__c, Attribute_Picklist_Values__c, Attribute_Type__c, Boolean_Value__c, 
                                                                        Date_Value__c, Maximum_No_Of_Characters_In_Text__c, Minimum_No_Of_Characters_In_Text__c, 
                                                                        Number_Value__c, Order_Rate_Plan_Charge__c, Phone_Value__c, Picklist_Value__c, String_Value__c,Value_ID__c
                                                                        From Order_Charge_Attributes__r order by Attribute_Order__c), 
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Customer_Number__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__c,i.live_Date__c,
                                                                        i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.IsInventoried__c,
                                                                        i.Renew_Rebase_Truncate_Date__c, i.Chat_ID__c,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c
                                                                        From invoiceit_s__Job_Rate_Plan_Charge__c i 
                                                                        where i.Id in: orderCharges
                                                                        and (RecordType.DeveloperName = 'MDL_Order_Rate_Plan_Charge' or RecordType.DeveloperName = 'Nolo_Order_Rate_Plan_Charge' or RecordType.DeveloperName = 'M_NG_Order_Rate_Plan_Charge')]) {
            if(mapOrderIdNLstOrderRatePlanCharges.containsKey(orderCharge.invoiceit_s__Order__c)){
                mapOrderIdNLstOrderRatePlanCharges.get(orderCharge.invoiceit_s__Order__c).add(orderCharge);
            }
            else{
                mapOrderIdNLstOrderRatePlanCharges.put(orderCharge.invoiceit_s__Order__c,new List<invoiceit_s__Job_Rate_Plan_Charge__c>{orderCharge});
            }
                                                                            
            /***************to release inventories logic************************************************/
            if(orderIdVsOrderProducts.containsKey(orderCharge.invoiceit_s__Order__c)){
                    orderIdVsOrderProducts.get(orderCharge.invoiceit_s__Order__c).add(orderCharge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c);                                                            
             }
             else{
                 orderIdVsOrderProducts.put(orderCharge.invoiceit_s__Order__c, new Set<Id>{orderCharge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c});
             }
            //End for Release Inv. Logic
            
           /*************************added by akash****************************/                                                                 
           orpcList.add(orderCharge);                                                                
                                                                            
        }
        
        //Added for Release Inv. Logic
        for(opportunity opp : [select id, Name ,StageName,Created_From_Order__c, Closed_lost_from_Order__c,
                                      Reason_Won_Lost__c, Ngage_Upsell_Order__c ,
                                   (select id,Name,IsInventoried__c,InventoryId__c
                                                                 From invoiceit_crmx__Opportunity_Products__r
                                                                 where IsInventoried__c = 'TRUE' and 
                                                                       InventoryId__c != NULL)
                                      From opportunity
                               where (StageName != 'Closed won'  AND  StageName != 'Closed Lost') AND (Created_From_Order__c IN:mapOrderIdNLstOrderRatePlanCharges.keySet() OR Ngage_Upsell_Order__c IN:mapOrderIdNLstOrderRatePlanCharges.keySet()) ]){
                if(orderIdVsOpportunites.containsKey(opp.Created_From_Order__c)){
                    orderIdVsOpportunites.get(opp.Created_From_Order__c).add(opp);                   
                }
                else{
                    orderIdVsOpportunites.put(opp.Created_From_Order__c,new List<Opportunity>{opp});                   
               } 
                                   
               
                                   
              //Sai : 12/07/2018
              //added New logic to closed MH Order related Opportunities when order Cancelled
                                  system.debug('@@@@@ MH order on Opty '+opp.Ngage_Upsell_Order__c);
                                   if (opp.Ngage_Upsell_Order__c != NULL) {
                                       if(MHorderIdVsOpportunites.containsKey(opp.Ngage_Upsell_Order__c)){
                                            MHorderIdVsOpportunites.get(opp.Ngage_Upsell_Order__c).add(opp);                   
                                        }
                                    else{
                                            MHorderIdVsOpportunites.put(opp.Ngage_Upsell_Order__c,new List<Opportunity>{opp});                   
                                        } 
                                   }
                                   
                                   
                                   
        }
        // END
        
        /*************added by akash ******************/
        Map<id,Chat_Product_Order_Charge__c> orpcIdVschatOrpc = new Map<id,Chat_Product_Order_Charge__c>();
        if(!mapOrderIdNLstOrderRatePlanCharges.isEmpty()){
            orpcIdVschatOrpc = MDL_OnDemandOrderXML.getchatproductsMap(orpcList);
        }
        
        
        //get Orders from Order Charges
        for(invoiceit_s__Job__c orderObj : [Select i.invoiceit_s__Account__r.MH_Cust_Number__c, i.invoiceit_s__Account__c,
                                            i.invoiceit_s__Account__r.Org_Id__c, (Select Id, Name, invoiceit_s__Job__c, invoiceit_s__Description__c, invoiceit_s__Product_Code__c, 
                                                   invoiceit_s__Product_Family__c, invoiceit_s__Product__c, invoiceit_s__SequenceNumber__c, Tracking_Number__c, 
                                                   Inventory_Id__c, Customer_Number__c, Sin_Number__c From invoiceit_s__Job_Product__r),
                                             i.OrderNumber__c, i.Name, i.Id, i.Fulfillment_Date__c From invoiceit_s__Job__c i where i.Id in : mapOrderIdNLstOrderRatePlanCharges.keySet()
                                             and (RecordType.DeveloperName = 'MH_Orders' or RecordType.DeveloperName = 'Nolo_Order'or RecordType.DeveloperName = 'M_NG_Order')]) {
            mapOrderIdNOrder.put(orderObj.Id,orderObj);
        }
        //Checking if Order XML already exists in Error Log, if exists do not send that order , queue it along with the existing order
        for(Error_Log__c err : [Select e.XML_Mesaage_Type__c, e.XML_Body__c, e.Sent_Successfully__c, e.Order_Number__c,e.Order_Name__c,e.Error_Reason__c, e.Name, e.Id ,e.Re_process_date_time__c
                                From Error_Log__c e
                                Where e.XML_Mesaage_Type__c = 'OrderRequest' AND e.Order_Number__c in :mapOrderIdNOrder.keySet()] ) {
                mapIdNExistingErrLogs.put(err.Order_Number__c,err);                 
        }
        System.debug('mapOrderId And Error Logs^^^'+mapIdNExistingErrLogs);
        System.debug('mapOrderIdNLstOrderRatePlanCharges:::'+mapOrderIdNLstOrderRatePlanCharges+'size==='+mapOrderIdNLstOrderRatePlanCharges.size());
        System.debug('mapOrderIdNOrder***'+mapOrderIdNOrder+'size==='+mapOrderIdNOrder.size());
        //System.debug('mapOrderIdNAttributes^^^'+mapOrderIdNlstOrderChargeAttributes);
        for(Id orderId : mapOrderIdNOrder.keySet()) {
            if(mapOrderIdNLstOrderRatePlanCharges.containsKey(orderId) && mapOrderIdNOrder.containsKey(orderId)) { 
                System.debug('inside order Cancellation method call');
                reqXML=MDL_Integration_Vim_Efs.constructXML_OrderCancel(userName,mapOrderIdNLstOrderRatePlanCharges.get(orderId),mapOrderIdNOrder.get(orderId),orpcIdVschatOrpc);
                String reqXmlupdted1 = reqXML.replace('+','%2B');
                String reqXmlupdted = reqXmlupdted1.replace('&','%26');
                
                
                string ipayload   = 'publicKey='+ publicKey + '&' + 'timestamp=' + timeDifferenceInSeconds + '&' + 'xml=' + reqXmlupdted;
                Blob textToBeHashedInBytes = Blob.valueOf(ipayload);
                Blob mac = Crypto.generateMac('HmacSHA256',Blob.valueOf(ipayload), Blob.valueOf(privateKey));
                String encodedText  = EncodingUtil.base64Encode(mac);
                String Header      =  encodedText + '|'+  timeDifferenceInSeconds;
                String givenEndpoint   = endPts.Endpoint_URL__c;
                String encodedurl = EncodingUtil.urlEncode(givenEndpoint, 'UTF-8');
                
                if(restrictCalls == false) {
                    if(mapIdNExistingErrLogs.containsKey(orderId)) {
                        Error_Log__c err = new Error_Log__c();
                        System.debug('###order already exists in Error Log###');
                        err.XML_Mesaage_Type__c = 'OrderRequest';
                        err.XML_Body__c = reqXML;
                        err.Order_Number__c = orderId;
                        err.Error_Reason__c = 'Previous instance of the same order exists in the Error log';
                        err.Order_Name__c = mapOrderIdNOrder.get(orderId).Name;
                        lstExistingErrLogs.add(err);
                    }
                    else {
                        try{
                            //added by akash on 9/3/16
                             //String givenEndpoint = 'https://back-office-services.lawyers.com/services/efs/v1/handleSalesForceXml';
                             //String givenEndpoint = 'http://98.158.206.132/services/efs/v1/handleSalesForceXml';
                              //Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('OrderRequest');
                            //String givenEndpoint = endPts.Endpoint_URL__c;
                            
                            Http http = new Http(); //global class which is used in both request & response
                            HttpRequest req = new HttpRequest(); //initiate HTTP request
                            //req.setEndpoint(endPoint);
                            req.setEndpoint(givenEndpoint);
                            
                            req.setMethod(methodType);
                            req.setTimeout(20000);
                            
                            //req.setBody(reqXML);
                            //String reqXmlupdted = reqXML.replace('&','%26');
                            req.setBody(ipayload);
                             
                            
                            req.setHeader('Accept', 'application/xml');
                            //req.setHeader('Content-Type', 'text/xml');
                            
                            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                            //req.setHeader('Authorization', aToken);
                            req.setHeader('Authorization', Header);
                            HTTPResponse res = http.send(req);
                            System.debug('Response Body in order Message is : '+res.getBody());
                            if(res.getStatusCode() == 200){
                                Error_Log__c temp_error = MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody() , reqXML);
                                
                                 /************logic to release inventory ******************************************/
                                if(!orderIdVsOrderProducts.isEmpty() && orderIdVsOrderProducts.containsKey(orderId)){
                                    for(Id orderProdId : orderIdVsOrderProducts.get(orderId)){
                                        invoiceit_s__Job_Product__c orderprod = new invoiceit_s__Job_Product__c(Id =orderProdId, Inventory_Id__c='' );
                                        orderProdstoRelease.add(orderprod);
                                    }
                                }
                                if(!orderIdVsOpportunites.isEmpty() && orderIdVsOpportunites.containsKey(orderId)){
                                    for(Opportunity opp :orderIdVsOpportunites.get(orderId) ){
                                        opp.StageName = 'Closed Lost';
                                        opp.Reason_Won_Lost__c = 'Administrative';
                                        opp.Closed_lost_from_Order__c= True;
                                        oppstoClosedLost.add(opp);
                                        oppIds.add(opp.id);
                                        
                                        for(invoiceit_crmx__Opportunity_Product__c oppProd : opp.invoiceit_crmx__Opportunity_Products__r){
                                            oppProd.InventoryId__c = '';
                                            oppProdstoRelease.add(oppProd);
                                            
                                        }
                                    }
                                }
                                //Sai : 12/07/2018
                               //added New logic to closed MH Order related Opportunities when order Cancelled
                                 if(!MHorderIdVsOpportunites.isEmpty() && MHorderIdVsOpportunites.containsKey(orderId)){
                                    for(Opportunity opp :MHorderIdVsOpportunites.get(orderId) ){
                                        opp.StageName = 'Closed Lost';
                                        opp.Reason_Won_Lost__c = 'Administrative';
                                        opp.Closed_lost_from_Order__c= True;
                                        oppstoClosedLost.add(opp);
                                        oppIds.add(opp.id);
                                        
                                        for(invoiceit_crmx__Opportunity_Product__c oppProd : opp.invoiceit_crmx__Opportunity_Products__r){
                                            oppProd.InventoryId__c = '';
                                            oppProdstoRelease.add(oppProd);
                                            
                                        }
                                    }
                                }
                                
                                
                                // End for Release Inv. Logic 
                                
                                if(temp_error != null){
                                    temp_error.XML_Mesaage_Type__c = 'OrderRequest';
                                    lstErrLogs.add(temp_error);
                                }   
                            }
                            if(res.getStatusCode() == 400 || res.getStatusCode() == 401){                               
                                MDL_Integration_Vim_Efs.parseResponse400Error(res.getBody(),'OrderRequest',reqXML,orderId,mapOrderIdNOrder.get(orderId).Name);                              
                            }
                            else{
                                if(res.getStatusCode() != 500 && res.getStatusCode() != 404 && res.getStatusCode() != 502) { 
                                    lstResponseBody.add(res.getBody());
                                }
                                else {
                                    Error_Log__c err = new Error_Log__c();
                                    err.XML_Mesaage_Type__c = 'OrderRequest';
                                    err.XML_Body__c = reqXML;
                                    err.Order_Number__c = orderId;
                                    err.Order_Name__c = mapOrderIdNOrder.get(orderId).Name;
                                    err.Error_Reason__c = res.getStatusCode() +' : '+res.getStatus();
                                    lstErrLogs.add(err);    
                                }
                            }
                        }catch(System.CalloutException ce) {
                            Error_Log__c err = new Error_Log__c();
                            err.XML_Mesaage_Type__c = 'OrderRequest';
                            err.XML_Body__c = reqXML;
                            err.Order_Number__c = orderId;
                            err.Order_Name__c = mapOrderIdNOrder.get(orderId).Name;
                            err.Error_Reason__c = 'Problem with web service operation. Failed to make a callout to an external system.';
                            lstErrLogs.add(err); 
                        }
                        catch(System.Exception e) {
                            MDL_Integration_Vim_Efs.sendEmailInCaseOfException('Order XMl Request',orderId,e.getMessage());
                        }      
                    }
                }
                else if(restrictCalls == true) {
                    System.debug('No calls will be sent since custom setting is activated');
                }
            }
        }
        
        if(!oppIds.isEmpty()){
           voidenvelope(oppIds);
            system.debug('@@@@@ in void docusign');
        }
        
        if(lstExistingErrLogs.size() > 0)
                Database.insert(lstExistingErrLogs);
        if(lstErrLogs.size() > 0) {
            Database.insert(lstErrLogs);
        }
        //Added for Release Inv changes
        if(!orderProdstoRelease.isEmpty()){
        database.update(orderProdstoRelease);
        }
        if(!oppstoClosedLost.isEmpty()){
            database.update(oppstoClosedLost);
            
             
            //calling release inventory from here sai: 12/09/2018
            system.debug('@@@calling release inventory callout from expiry');
            MDL_BatchAutoEvergreenHandler.releaseOrderProductInventoriesBatch(oppIds);
            
        }
        if(!oppProdstoRelease.isEmpty()){
           // database.update(oppProdstoRelease);
        }
        
        //End for Release Inv. Changes
        
        MDL_Integration_Vim_Efs.parseResponseXML_OrderResponse(lstResponseBody);
    }
    
    // End of Order Cancellation Request 
    
    public static void reSendHttpRequests(List<Error_Log__c> lstErrLogs) {
        List<Error_Log__c> lstErrLog = new List<Error_Log__c>();
        List<Error_Log__c> lstErrLog_New = new List<Error_Log__c>();
        List<Error_Log__c> lstAllErrLog = new List<Error_Log__c>();
        List<String> lstOrderResponseBody = new List<String>();
        List<String> lstReleaseResponseBody = new List<String>();
        String endPoint;
        String methodType;
        String endPoint1;
        Integration_Endpoints__c endPts;
        String privateKey;
        String publicKey;
        String apiKey;
        String ipayload;
        String Header;
        
         String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000)); 
         
            
            
        
        for(Error_Log__c err : lstErrLogs) {
            err.Re_process_date_time__c = Datetime.now();
            String reqXmlupdted1 = err.XML_Body__c.replace('+','%2B');
            String xmlBody = reqXmlupdted1.replace('&','%26');
            //or condition added by akash on 9/3/2016 to include update org id functionality in this batch(|| err.XML_Mesaage_Type__c == 'Update OrgId')
            if(err.XML_Mesaage_Type__c == 'OrderRequest' ) {
                endPts = Integration_Endpoints__c.getValues('OrderRequest');
                endPoint = String.valueOf(endPts.Endpoint_URL__c);
                methodType = endPts.MethodType__c;
                //endPoint1 = 'cert3-svcs.martindale.com/mhintegration/order';
                endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
                 privateKey = endPts.Private_Key__c;
                publicKey  =   endPts.Public_Key__c;
               apiKey = endPts.API_key__c;
                
                ipayload   = 'publicKey='+ publicKey + '&' + 'timestamp=' + timeDifferenceInSeconds + '&' + 'xml=' + xmlBody;
                Blob textToBeHashedInBytes = Blob.valueOf(ipayload);
                Blob mac = Crypto.generateMac('HmacSHA256',Blob.valueOf(ipayload), Blob.valueOf(privateKey));
                String encodedText  = EncodingUtil.base64Encode(mac);
                Header      =  encodedText + '|'+  timeDifferenceInSeconds;
                String givenEndpoint   = endPts.Endpoint_URL__c;
                String encodedurl = EncodingUtil.urlEncode(givenEndpoint, 'UTF-8');
            }
           
           //Commented For New Service  Changes Sai C 06/19/2017
            /*else if(err.XML_Mesaage_Type__c == 'ReleaseInventory') {
                endPts = Integration_Endpoints__c.getValues('ReleaseInventory');
                endPoint = String.valueOf(endPts.Endpoint_URL__c);
                methodType = endPts.MethodType__c;
                //endPoint1 = 'cert3-svcs.martindale.com/mhintegration/inventory/release';
                endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
                privateKey = endPts.Private_Key__c;
                apiKey = endPts.API_key__c;
                
                String httpVerb = 'POST';
            string textToBeHashed = timeDifferenceInSeconds + ':' + endPoint1 + ':' + httpVerb + ':' + privateKey;
            System.debug('textToBeHashed'+textToBeHashed);
            Blob textToBeHashedInBytes = Blob.valueOf(textToBeHashed);
            System.debug('text to be hashed to blob'+textToBeHashedInBytes);
            String algorithmName = 'SHA-256';
            Blob mac = Crypto.generateDigest(algorithmName, textToBeHashedInBytes);
            System.debug('SHA256 algo'+mac);
            String encodedText  = EncodingUtil.base64Encode(mac);
            System.debug('Base 64 string'+encodedText);
             Header = timeDifferenceInSeconds + ':' + apikey + ':' + encodedText;
            //aToken will be added in HTTP Request Header as Authorization
           // System.debug('authorization token is '+aToken);
            ipayload = 'XML='+ xmlBody;    
                
            }*/
            
            //code for authentication
             //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)
            //String endPoint1 = 'cert3-svcs.martindale.com/mhintegration/order';
            /*String privateKey = 'F2DCA2AD71561755E0433454B60AF99D';
            String apiKey = '76F1CF765AA41A8E695F66A815B7D345';*/
            
            
            
            
            
            
            //end of authentication 
            try{
                Http http = new Http(); //global class which is used in both request & response
                HttpRequest req = new HttpRequest(); //initiate HTTP request
                System.debug('@@endPoint'+ endPoint);
                req.setEndpoint(endPoint);
                req.setMethod(methodType);
                req.setTimeout(20000);
                //req.setBody('XML='+err.XML_Body__c); 
                //System.debug('@@XML'+ err.XML_Body__c);
                req.setBody(ipayload);
                req.setHeader('Accept', 'application/xml');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

                System.debug('XML body is :::'+xmlBody);
                //req.setHeader('Content-Type', 'text/xml');
                req.setHeader('Authorization', Header);
                HTTPResponse res = http.send(req);
                System.debug('Response Body : '+res.getBody()); 
                System.debug('Status code***'+res.getStatusCode()+'STatus in response'+res.getStatus());
                //check if it is a positive response , if it is a positive response ( then we update the status to sent successfully)
                Dom.Document response = new Dom.Document();
                response.load(res.getBody());
                dom.Xmlnode responseBody = response.getRootElement();
                /*modified for rbw 913 - to create error logs on getting failure after resend */
                //if(res.getStatusCode() != 500 && res.getStatusCode() != 400 && res.getStatusCode() != 404 && res.getStatusCode() != 401 && res.getStatusCode() != 502) {                
                if(res.getStatusCode() == 200){
                    Error_Log__c temp_error =  MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody(), err.XML_Body__c);
                    if(temp_error != null){
                        temp_error.XML_Mesaage_Type__c = err.XML_Mesaage_Type__c;
                        lstErrLog_New.add(temp_error);
                    }   
                    err.Sent_Successfully__c = true;                
                    if(res.getBody().contains('OrderRequest')) {
                        lstOrderResponseBody.add(res.getBody());
                    } 
                    else if(res.getBody().contains('ReleaseInventoryResponse')) {
                        lstReleaseResponseBody.add(res.getBody());
                    }
                }
                else{
                    String txtmsg = '';
                    try{
                        if((res.getStatusCode() == 400 || res.getStatusCode() == 401) && responseBody.getChildElement('Messages',null) != null && responseBody.getChildElement('Messages',null).getChildElement('Message',null) != null)
                            txtmsg = responseBody.getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null).getText();
                    }
                    catch(Exception e){
                        
                    }
                    //Error_Log__c error_New = new Error_Log__c();
                   // if(res.getStatusCode() == 502){
                    //List<Error_Log__c> existingerrorLog = new List<Error_Log__c>();
                        if(err.Error_Reason__c.contains('502') && res.getStatusCode() == 502){
                            err.Re_process_date_time__c = system.now();
                        }   
                     //existingerrorLog = [select id,Order_Name__c,Case__c,
                     //                          XML_Mesaage_Type__c,XML_Body__c
                     //                          From Error_Log__c
                     //                          where id=:err.id];
                    //if(!existingerrorLog.isEmpty() && existingerrorLog.size() > 0){
                    //  existingerrorLog[0].Re_process_date_time__c = system.now(); 
                    //}
                   /* else{
                         error_log = new Error_Log__c();
                        error_log.XML_Mesaage_Type__c = 'OrderRequest';
                        error_log.XML_Body__c = reqXML;
                       if(txtmsg != null || txtmsg != '')
                            error_log.Error_Reason__c = res.getStatusCode() + ' : ' + txtmsg;
                        else
                            error_log.Error_Reason__c = res.getStatusCode() + ' : ' + res.getStatus();  
                
                        error_log.Order_Name__c = job.Name;
                        error_log.Re_process_date_time__c =system.now();
                        lstErrLog_New.add(error_log);
                        
                        
                    }*/
                   
               // }
                    else{
                        Error_Log__c error_New = new Error_Log__c();
                    error_New.XML_Mesaage_Type__c = err.XML_Mesaage_Type__c;
                    if((res.getStatusCode() == 400 || res.getStatusCode() == 401))
                        error_New.Error_Reason__c = res.getStatusCode() + ' : ' + txtmsg;
                    else
                        error_New.Error_Reason__c = res.getStatusCode() + ' : ' + res.getStatus();  
                    error_New.Order_Name__c = err.Order_Name__c;
                    error_New.XML_Body__c = err.XML_Body__c;                    
                    lstErrLog_New.add(error_New);   
                        
                    }
                    //err.Sent_Successfully__c = true;
                                
                }
            }catch(System.CalloutException ce) {
                System.debug('Callout Exception has occurred :::');
            }
            lstErrLog.add(err);    
        }
        if(lstErrLog.size() > 0) {
            Database.update(lstErrLog);
        }
        if(lstErrLog_New.size() > 0){
            Database.insert(lstErrLog_New); 
        }
        
        system.debug(' lst error logs ' + lstErrLog);
        system.debug(' lst error logs2 ' + lstErrLog_New);        
        MDL_Integration_Vim_Efs.parseResponseXML_OrderResponse(lstOrderResponseBody);
        MDL_Integration_Vim_Efs.parseResponseXML_ReleaseInventoryResponse(lstReleaseResponseBody);
    }
    public static void sendEmailInCaseOfException(String typeOfMessage,Id objId,String exceptionString) {
        Email_Ids__c eId = Email_Ids__c.getValues('IntegrationErrors');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Integration Error -  Error in '+typeOfMessage);
        mail.setHtmlBody('Id for which error has been generated is :'+objId+'.Error Message is :'+exceptionString);
        List<String> toAddress = new List<String>();
        toAddress.add(eId.Email_Id__c);
        mail.setToAddresses(toAddress);
        Messaging.SendEmail(new Messaging.SingleEmailMessage[] { mail }); 
    }
    public static void pendInventoryForMidTermProducts(String userName,List<invoiceit_s__Job_Rate_Plan_Charge__c> orderRPCList,Map<String,String> mapAttributeNameAndValue,invoiceit_s__Job__c orderRecord) {
        Map<Id,String> mapOrdProdIdNErrResponseBody = new Map<Id,String>();
        Map<Id,Boolean> mapOrdProdIdNResponseIsXML = new Map<Id,Boolean>();
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('PendInventory');
        String endPoint = String.valueOf(endPts.Endpoint_URL__c);
        System.debug('**'+endPoint);
        String methodType = endPts.MethodType__c;
        String reqXML;
        String cusNumb = '';
        String uName = userName;
        List<String>lstResponseBody = new List<String>();
        
        //code for authentication
        String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)
        String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
        String privateKey = endPts.Private_Key__c;
        String publicKey  =   endPts.Public_Key__c; 
        String apiKey = endPts.API_key__c;
        
        
        if(orderRecord.invoiceit_s__Account__r.MH_Cust_Number__c != '') {
            cusNumb = orderRecord.invoiceit_s__Account__r.MH_Cust_Number__c;
        } 
        
        for(invoiceit_s__Job_Rate_Plan_Charge__c oRPC : orderRPCList) {         
            reqXML = MDL_Integration_Vim_Efs.constructXML_pendInvForMidTermProducts(uName,cusNumb,oRPC);
            string ipayload   = 'publicKey='+ publicKey + '&' + 'timestamp=' + timeDifferenceInSeconds + '&' + 'xml=' + reqXML;
               // string ipayload   = 'Hello';
                System.debug ('ipayload'+ipayload);
                Blob textToBeHashedInBytes = Blob.valueOf(ipayload);
                Blob mac = Crypto.generateMac('HmacSHA256',Blob.valueOf(ipayload), Blob.valueOf(privateKey));
                String encodedText  = EncodingUtil.base64Encode(mac);
                String Header      =  encodedText + '|'+  timeDifferenceInSeconds;
                System.Debug('encodedText'+encodedText);
                String givenEndpoint   = endPts.Endpoint_URL__c;
                String encodedurl = EncodingUtil.urlEncode(givenEndpoint, 'UTF-8');
            try {
                    
                    Http http = new Http(); //global class which is used in both request & response
                    HttpRequest req = new HttpRequest(); //initiate HTTP request
                    req.setEndpoint(givenEndpoint);
                    req.setMethod(methodType);
                    req.setTimeout(20000);
                    req.setBody(ipayload); 
                    req.setHeader('Accept', 'application/xml');
                    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    req.setHeader('Authorization', Header);
                    HTTPResponse res = http.send(req);
                    System.debug('Response Body : '+res.getBody()); 
                if(res.getStatusCode() != 500 && res.getStatusCode() != 400 && res.getStatusCode() != 404 && res.getStatusCode() != 401 && res.getStatusCode() != 502) 
                    lstResponseBody.add(res.getBody());  
                if(res.getStatusCode() == 400 || res.getStatusCode() == 401) {
                    mapOrdProdIdNErrResponseBody.put(oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,res.getBody()); 
                    mapOrdProdIdNResponseIsXML.put(oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,true);
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Authentication issue . Kindly inform the system administrator regarding the same.');
                    apexpages.addMessage(am);   
                }
                if(res.getStatusCode() == 404) {
                    mapOrdProdIdNErrResponseBody.put(oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,'404 : The specified resource was not found, or the resource has been deleted. Please contact MHI system administrator.'); 
                    mapOrdProdIdNResponseIsXML.put(oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,false);
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Response Status Code : 404. The specified resource was not found, or the resource has been deleted . Please contact MHI system administrator .');
                    apexpages.addMessage(am);  
                } 
                if(res.getStatusCode() == 500) {
                    mapOrdProdIdNErrResponseBody.put(oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,'500 : Internal Server Error . Please contact MHI system administrator .'); 
                    mapOrdProdIdNResponseIsXML.put(oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,false);
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'There is a network issue . Please contact MHI system administrator .');
                    apexpages.addMessage(am);  
                }      
                if(res.getStatusCode() == 502) {
                    mapOrdProdIdNErrResponseBody.put(oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,'502 : Bad Gateway issue . Please contact MHI system administrator .'); 
                    mapOrdProdIdNResponseIsXML.put(oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,false);
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Bad Gateway issue . Please contact MHI system administrator');
                    apexpages.addMessage(am);  
                }
            }catch(System.CalloutException ce) {
                mapOrdProdIdNErrResponseBody.put(oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,ce.getMessage()); 
                mapOrdProdIdNResponseIsXML.put(oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,false);
                apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Callout exception , kindly try to pend inventory after again');
                apexpages.addMessage(am);   
            }
            catch(System.Exception e) {
                mapOrdProdIdNErrResponseBody.put(oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,e.getMessage()); 
                mapOrdProdIdNResponseIsXML.put(oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,false);
                apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Some Exception occurred , please try again after sometime.'+e.getMessage());
                apexpages.addMessage(am);
            }
        }
        if(!mapOrdProdIdNErrResponseBody.isEmpty() && !mapOrdProdIdNResponseIsXML.isEmpty()){
            MDL_Integration_Vim_Efs.parseErrorResponsePendInventoryMidTermProds(mapOrdProdIdNErrResponseBody,mapOrdProdIdNResponseIsXML);
        }
        MDL_Integration_Vim_Efs.parseResponseXML_PendInventoryResponseForMidTermProds(lstResponseBody,orderRecord.invoiceit_s__Account__c,orderRecord.Id);
    }
    public static String constructXML_pendInvForMidTermProducts(String userName,String customerNumber,invoiceit_s__Job_Rate_Plan_Charge__c oRPC) {
        String requestXMLString = '';
        String xmlns='';
        String aopVal = '';
        Map<String,String>mapAttributeNameAndValue = new Map<String,String>();
        //get xmlns value from custom setting
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('PendInventory');
        xmlns = endPts.xmlns__c;
        
        //construct a map of attributes from the Rate Plan Charge
        for(Order_Charge_Attribute__c att : oRPC.Order_Charge_Attributes__r) {
                if(att.Attribute_Type__c == 'Text')
                    mapAttributeNameAndValue.put(att.Attribute_Name__c,att.String_Value__c);
                else if(att.Attribute_Type__c == 'Picklist')
                    mapAttributeNameAndValue.put(att.Attribute_Name__c,att.Picklist_Value__c);
                else if(att.Attribute_Type__c == 'Number')
                    mapAttributeNameAndValue.put(att.Attribute_Name__c,String.valueOf(att.Number_Value__c));
                else if(att.Attribute_Type__c == 'Boolean')
                    mapAttributeNameAndValue.put(att.Attribute_Name__c,String.valueOf(att.Boolean_Value__c));
                else if(att.Attribute_Type__c == 'Date')
                    mapAttributeNameAndValue.put(att.Attribute_Name__c,String.valueOf(att.Date_Value__c));
        }
        for(String newAttValue : mapAttributeNameAndValue.keySet()) {
            if(newAttValue.endsWith('AOP') || newAttValue.contains('AOP')) {
                aopVal = 'AOP';
            }
            else {
                aopVal = newAttValue;
            }
            mapAttributeNameAndValue.put(aopVal,mapAttributeNameAndValue.get(newAttValue));
        }   
            
        System.debug('&&mapAttributeNameAndValue&&'+mapAttributeNameAndValue);
        //get server timestamp to send it in requestid
        DateTime result = DateTime.now();
        String timeStampString = result.format();//to convert datetime into string
        String reqID = oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c + '-' + timeStampString ;
        System.debug('RequestId PendInventory Request :' + reqID);
        
        //construct the XML here
        Xmlstreamwriter xmlW = new Xmlstreamwriter();
        
        //Beginning of PendInventoryRequest tag
        xmlW.writeStartElement(null,'PendInventoryRequest', null); 
        xmlW.writeAttribute(null,null,'xmlns',xmlns);
        
        //Beginning of requestId tag
        xmlW.writeStartElement(null,'RequestId',null);
        xmlW.writeCharacters(reqID);
        xmlW.writeEndElement();
        //end of Request Id Tag
        
        //Beginning of Username tag
        xmlW.writeStartElement(null, 'UserName', null);
        xmlW.writeCharacters(userName);
        xmlW.writeEndElement();
        //End of Username tag
        
        //Beginning of ProductCode tag
        xmlW.writeStartElement(null,'ProductCode',null);
        xmlW.writeCharacters(oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c);
        xmlW.writeEndElement();
        //End of ProductCode tag
        
        //Beginning of ProductName tag
        xmlW.writeStartElement(null,'ProductName',null);
        xmlW.writeCharacters(oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name);
        xmlW.writeEndElement();
        //End of ProductName tag
        
        String SAN = '' ;
        
        //Beginning of ServiceAccountName tag
        xmlW.writeStartElement(null,'ServiceAccountName',null);
        if(mapAttributeNameAndValue.containsKey('Service Account Name')) {
            SAN = mapAttributeNameAndValue.get('Service Account Name');
            //SAN=SAN.escapeHTML4();
            xmlw.writeCharacters(SAN);
        }
        xmlW.writeEndElement();
        //End of ServiceAccountName tag
        
        //Beginning of CustomerNumber tag
        if(customerNumber != null) {
            xmlW.writeStartElement(null,'CustomerNumber',null);
                xmlW.writeCharacters(customerNumber);
            xmlW.writeEndElement();
        }
        else {
            xmlW.writeEmptyElement(null,'CustomerNumber',null);
        }
        //End of CustomerNumber tag
        
        //Beginning of AOP tag
        xmlW.writeStartElement(null,'AOP',null);
        if(mapAttributeNameAndValue.containsKey('AOP'))
            xmlw.writeCharacters(mapAttributeNameAndValue.get('AOP'));
        xmlW.writeEndElement();
        //End of AOP tag
        
        //Beginning of ProductDeliveryAddress tag
        xmlW.writeStartElement(null,'ProductDeliveryAddress',null);
        
        //Beginning of city tag
        xmlW.writeStartElement(null, 'City', null);
        if(mapAttributeNameAndValue.containsKey('City'))
            if(mapAttributeNameAndValue.get('City')!=null)
            xmlw.writeCharacters(mapAttributeNameAndValue.get('City'));
        xmlW.writeEndElement();
        //End of city tag
        
        //Beginning of county tag
        xmlW.writeStartElement(null, 'County', null);
        if(mapAttributeNameAndValue.containsKey('County'))
            if(mapAttributeNameAndValue.get('County')!=null)
                xmlw.writeCharacters(mapAttributeNameAndValue.get('County'));
        xmlW.writeEndElement();
        //End of county tag
        
        //Beginning of State tag
        xmlW.writeStartElement(null, 'State', null);
        if(mapAttributeNameAndValue.containsKey('State'))
            if(mapAttributeNameAndValue.get('State')!=null)
                xmlw.writeCharacters(mapAttributeNameAndValue.get('State'));
        xmlW.writeEndElement();
        //End of State tag
        
        //Beginning of Country tag
        xmlW.writeStartElement(null, 'Country', null);
        if(mapAttributeNameAndValue.containsKey('Country'))
            if(mapAttributeNameAndValue.get('Country')!=null)
                xmlw.writeCharacters(mapAttributeNameAndValue.get('Country'));
            //xmlW.writeCharacters(a.ShippingCountry);
        xmlW.writeEndElement();
        //End of Country tag
        
        xmlW.writeEndElement();
        //End of ProductDeliveryAddress tag
        
        xmlW.writeEndElement();
        //End of PendInventoryRequest tag
        
        requestXMLString = xmlW.getXmlString();
        System.debug('PendInventory Request for Mid Term Products :'+requestXMLString);
        
        return requestXMLString;
    }
    
    public static void parseResponseXML_PendInventoryResponseForMidTermProds(List<String> lstResponseStrings,String accId,String orderId) {
        String txtmsg;
        Map<String,String> mapRequestIdAndInventoryIds = new Map<String,String>(); //used for positive responses to update inventory id
        Map<String,String> mapRequestIdAndErrorText = new Map<String,String>();
        Map<String,String> mapRequesIdAndSINNumber = new Map<String,String>();
        List<invoiceit_s__Job_Product__c> lstOppProducts = new List<invoiceit_s__Job_Product__c>();
        AssignmentRule AR;
        Database.DMLOptions dmlOpts;
        List<Case> lstCases = new List<Case>();
        for(String resp : lstResponseStrings) {
            Dom.Document response = new Dom.Document();
            response.load(resp);
            dom.Xmlnode res = response.getRootElement();
            String uniqueId = res.getChildElement('RequestId', null).getText();
            String []splitRequest = uniqueId.split('-');
            String toUpdateId = splitRequest[0];
            String respCode = res.getChildElement('HttpResponseCode', null).getText();
            String isInventoryAvailable = res.getChildElement('IsInventoryAvailable', null).getText();
            dom.Xmlnode res1 = res.getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null);
            txtmsg = res1.getText();
            System.debug('text message received is :'+txtmsg);
            if(respCode == '200') {
                String invId = res.getChildElement('InventoryId', null).getText();
                System.debug('Inventory Id obtained is:'+invId);
                mapRequestIdAndInventoryIds.put(toUpdateId,invId);
                mapRequestIdAndErrorText.put(toUpdateId,txtmsg);
            }
            else {
                String textNcode = respCode + '*' + txtmsg;
                mapRequestIdAndErrorText.put(toUpdateId,textNcode);
            }
        }
        System.debug('mapRequestIdAndInventoryIds'+mapRequestIdAndInventoryIds.size()+'^^'+mapRequestIdAndInventoryIds);
        System.debug('mapRequestIdAndErrorText'+mapRequestIdAndErrorText.size()+'&&'+mapRequestIdAndErrorText);        
        for(invoiceit_s__Job_Product__c oppProd : [Select i.Name, i.Inventory_Id__c, i.Id,i.Error_Text__c,i.Sin_Number__c From invoiceit_s__Job_Product__c i
                                                              where i.Id in : mapRequestIdAndErrorText.keyset()]) {
            if(mapRequestIdAndInventoryIds.containsKey(oppProd.Id)) {
                oppProd.Inventory_Id__c = mapRequestIdAndInventoryIds.get(oppProd.Id);
            }
            oppProd.Error_Text__c = mapRequestIdAndErrorText.get(oppProd.Id);
            lstOppProducts.add(oppProd);            
            if(mapRequestIdAndErrorText.get(oppProd.Id) != '') {
                mapRequesIdAndSINNumber.put(oppProd.Id,oppProd.Sin_Number__c);
            }            
        }  
        if(mapRequestIdAndErrorText.size()>0){
            //Fetching the assignment rules on case
            for(AssignmentRule assignRule : [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1]){
                AR = assignRule;
            }
            //Creating the DMLOptions for an "Assign using active assignment rules" checkbox
            dmlOpts = new Database.DMLOptions();
            if(AR!=null)
                dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        }      
       /* for(String reqId : mapRequestIdAndErrorText.keyset()) {
            if(mapRequestIdAndErrorText.get(reqId) != '') {
                Case c = new Case();
                c.Status = 'New';
                c.Priority = 'High';
                c.Subject = 'PendInventory Request Error';
                c.Description = '';
                if(mapRequesIdAndSINNumber.containsKey(reqId)){
                    c.Description += 'Error for Product with SIN Number - '+mapRequesIdAndSINNumber.get(reqId)+'. ';
                }
                c.Description += mapRequestIdAndErrorText.get(reqId);                
                c.AccountId = accId;
                c.Parent_Order__c = orderId;
                c.setOptions(dmlOpts);
                lstCases.add(c);
            }    
        }*/
        if(lstOppProducts.size() > 0)
            Database.update(lstOppProducts);
        if(lstCases.size() > 0)
            Database.insert(lstCases);
    }
    public static void parseResponse400Error(String ResponseString,String messageType,String reqXML,Id objId,String orderName){
        String txtmsg = '';
        Dom.Document response = new Dom.Document();
        response.load(ResponseString);
        dom.Xmlnode res = response.getRootElement();
        String respCode = res.getChildElement('HttpResponseCode', null).getText();
        /*for(dom.Xmlnode resMessage : res.getChildElements()){
            dom.Xmlnode errorText = resMessage.getChildElement('Message',null).getChildElement('Text',null);
            txtmsg += errorText.getText()+'\r\n';
        } */
        txtmsg = res.getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null).getText();       
        System.debug('text message received is :'+txtmsg);
        //insert error log
        Error_Log__c err = new Error_Log__c();
        err.XML_Mesaage_Type__c = messageType;
        err.XML_Body__c = reqXML;
        if(messageType=='OrderRequest'){
            err.Order_Number__c = objId;
            err.Order_Name__c = orderName;
        }
        else if(messageType=='ReleaseInventory'){
            err.Release_inventory_id__c = objId;
        }       
        err.Error_Reason__c = respCode +' : '+txtmsg;       
        Database.Insert(err);      
    }   
    public static void parseErrorResponsePendInventory(Map<Id,String> mapOppProdIdNErrResponseBody, Map<Id,invoiceit_crmx__Opportunity_Product__c> mapOppProdIdNOppProd, Map<Id,Boolean> mapOppProdIdNResponseIsXML){
        String txtmsg = '';     
        List<invoiceit_crmx__Opportunity_Product__c> lstOppProdToUpdate = new List<invoiceit_crmx__Opportunity_Product__c>();
        for(Id oppProdId : mapOppProdIdNErrResponseBody.keyset()){
            if(mapOppProdIdNResponseIsXML.containskey(oppProdId)){
                if(mapOppProdIdNResponseIsXML.get(oppProdId)==true){
                    Dom.Document response = new Dom.Document();
                    response.load(mapOppProdIdNErrResponseBody.get(oppProdId));
                    dom.Xmlnode res = response.getRootElement();            
                    String respCode = res.getChildElement('HttpResponseCode', null).getText();
                    txtmsg = respCode+' : '+res.getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null).getText();       
                    System.debug('text message received is :'+txtmsg);                                      
                }
                else if(mapOppProdIdNResponseIsXML.get(oppProdId)==false){
                    txtmsg = mapOppProdIdNErrResponseBody.get(oppProdId);
                    System.debug('text message received is :'+txtmsg);  
                }
            }
            if(mapOppProdIdNOppProd.containsKey(oppProdId)){
                mapOppProdIdNOppProd.get(oppProdId).Error_Text__c = txtmsg;
                lstOppProdToUpdate.add(mapOppProdIdNOppProd.get(oppProdId));
            }
        }
        if(lstOppProdToUpdate.size()>0){
            Database.Update(lstOppProdToUpdate);
        }                   
    } 
    public static void parseErrorResponsePendInventoryMidTermProds(Map<Id,String> mapOrdProdIdNErrResponseBody, Map<Id,Boolean> mapOrdProdIdNResponseIsXML){
        String txtmsg = '';     
        Map<Id,String> mapOrdProdIdNTxtMsg = new Map<Id,String>();
        List<invoiceit_s__Job_Product__c> lstOrdProdToUpdate = new List<invoiceit_s__Job_Product__c>();
        for(Id ordProdId : mapOrdProdIdNErrResponseBody.keyset()){
            if(mapOrdProdIdNResponseIsXML.containskey(ordProdId)){
                if(mapOrdProdIdNResponseIsXML.get(ordProdId)==true){
                    Dom.Document response = new Dom.Document();
                    response.load(mapOrdProdIdNErrResponseBody.get(ordProdId));
                    dom.Xmlnode res = response.getRootElement();            
                    String respCode = res.getChildElement('HttpResponseCode', null).getText();
                    txtmsg = respCode+' : '+res.getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null).getText();       
                    System.debug('text message received is :'+txtmsg);                                      
                }
                else if(mapOrdProdIdNResponseIsXML.get(ordProdId)==false){
                    txtmsg = mapOrdProdIdNErrResponseBody.get(ordProdId);
                    System.debug('text message received is :'+txtmsg);  
                }
                mapOrdProdIdNTxtMsg.put(ordProdId,txtmsg);
            }   
        }
        for(invoiceit_s__Job_Product__c jobProd : [Select Id,Error_Text__c from invoiceit_s__Job_Product__c where Id in :mapOrdProdIdNTxtMsg.keyset()]){
            jobProd.Error_Text__c = mapOrdProdIdNTxtMsg.get(jobProd.Id);
            lstOrdProdToUpdate.add(jobProd);
        }
        if(lstOrdProdToUpdate.size()>0){
            Database.Update(lstOrdProdToUpdate);
        }                   
    } 
    
    public static void voidenvelope(Set<Id> setOppIds){
        System.debug('===========voidenvelope Method==============');
        for(dsfs__DocuSign_Status__c docustat : [Select id, name,dsfs__DocuSign_Envelope_ID__c,dsfs__Envelope_Status__c From dsfs__DocuSign_Status__c where dsfs__Envelope_Status__c!= 'Completed' AND dsfs__Envelope_Status__c!= 'Voided' AND dsfs__Opportunity__c in :setOppIds]){
                DocusignVoidApi voi = new DocusignVoidApi();
                voi.voidEnvelope(docustat.dsfs__DocuSign_Envelope_ID__c,'Void APIs');
            }
    }
    
    public static Error_Log__c checkForSuccessResponseWithError(String responseString, String requestString){
        
        Dom.Document response = new Dom.Document();
        response.load(ResponseString);
        dom.Xmlnode res = response.getRootElement();
        
        String orderNumber ;   
        
        if(res.getChildElement('Order',null) != null && res.getChildElement('Order',null).getChildElement('OrderNumber',null) != null){
            orderNumber  = res.getChildElement('Order',null).getChildElement('OrderNumber',null).getText();
        }
        String errorText;
        
        if(res.getChildElement('Order',null) != null && res.getChildElement('Order',null).getChildElement('LineItems',null) != null){
            for(dom.Xmlnode lineitem : res.getChildElement('Order',null).getChildElement('LineItems',null).getChildElements()){
                if(lineitem.getChildElement('Messages',null) != null){
                    errorText = lineitem.getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null).getText();
                }
            }
        }   
        
        if(errorText != null){      
            Error_Log__c error = new Error_Log__c();
            error.Error_Reason__c = '200/400 : ' + errorText;
            error.Order_Name__c = orderNumber;
            error.XML_Body__c = requestString;
            //insert error;
            return error;
        }
        
        return null;    
    }   
}
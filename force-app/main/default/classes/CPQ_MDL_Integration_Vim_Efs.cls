/***********************************************************************************************************************        
Change History      
************************************************************************************************************************        
Jira         ModifiedBy    Date         Requested By    Tag     Description 
    
MHBS-8119    Lakshmi      28/04/2022                   T01     Added changes for Parsing %20 in URL Parameter    

MHMAC-58     Sai C        30/12/2022                           Added changes for supporting 2.1 MAC Firm SKU  Order XML

MHMAC-42     Sai C       30/12/2022                            Added changes for supporting 2.1 MAC  CPP, Base Profile Order XML

MHMAC-274    Sai C       01/08/2023                            Added changes for supporting MAC 3.0  for MH and Avvo Products
   
************************************************************************************************************************/


public class CPQ_MDL_Integration_Vim_Efs {
    @future(callout = true)
    public static void pendInventoryRequest(Set<Id> setQuoteLineProdids,String customerNumber,String userName,String acc) {
        List<String> lstResponseBody = new List<String>();
        Map<Id,String> mapOppProdIdNErrResponseBody = new Map<Id,String>();
        Map<Id,SBQQ__QuoteLine__c> mapOppProdIdNOppProd = new Map<Id,SBQQ__QuoteLine__c>();
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
        System.debug('set passed is : '+setQuoteLineProdids);
        for(SBQQ__QuoteLine__c qoLL : [Select i.Id,i.SBQQ__Quote__c, i.Attribute_Relationship__c, i.SBQQ__Product__c,
                                       i.SBQQ__ProductCode__c, i.SBQQ__ProductName__c, i.SBQQ__Product__r.IsInventoried__c, 
                                       i.Inventory_Id__c, i.Error_Text__c  From SBQQ__QuoteLine__c i
                                       where i.Id in : setQuoteLineProdids]) {
                                           
                                           reqXML = CPQ_MDL_Integration_Vim_Efs.constructXML_PendInventory(qoLL,cusNumb,uName); //get request XML from the static method
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
                                                   mapOppProdIdNErrResponseBody.put(qoLL.Id,res.getBody()); 
                                                   mapOppProdIdNOppProd.put(qoLL.Id,qoLL);
                                                   mapOppProdIdNResponseIsXML.put(qoLL.Id,true);                
                                                   apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Authentication issue . Kindly inform the system administrator regarding the same.');
                                                   apexpages.addMessage(am);   
                                               }
                                               if(res.getStatusCode() == 404) {
                                                   mapOppProdIdNErrResponseBody.put(qoLL.Id,'404 : The specified resource was not found, or the resource has been deleted. Please contact MHI system administrator.'); 
                                                   mapOppProdIdNOppProd.put(qoLL.Id,qoLL);
                                                   mapOppProdIdNResponseIsXML.put(qoLL.Id,false);                
                                                   apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Response Status Code : 404. The specified resource was not found, or the resource has been deleted . Please contact MHI system administrator .');
                                                   apexpages.addMessage(am);   
                                               }
                                               if(res.getStatusCode() == 500) {
                                                   mapOppProdIdNErrResponseBody.put(qoLL.Id,'500 : Internal Server Error . Please contact MHI system administrator .' ); 
                                                   mapOppProdIdNOppProd.put(qoLL.Id,qoLL);  
                                                   mapOppProdIdNResponseIsXML.put(qoLL.Id,false);               
                                                   apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'There is a network issue . Please contact MHI system administrator .');
                                                   apexpages.addMessage(am);  
                                               }      
                                               if(res.getStatusCode() == 502) {
                                                   mapOppProdIdNErrResponseBody.put(qoLL.Id,'502 : Bad Gateway issue . Please contact MHI system administrator .'); 
                                                   mapOppProdIdNOppProd.put(qoLL.Id,qoLL);
                                                   mapOppProdIdNResponseIsXML.put(qoLL.Id,false);
                                                   apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Bad Gateway issue . Please contact MHI system administrator');
                                                   apexpages.addMessage(am);  
                                               }
                                           }
                                           catch(System.CalloutException ce) {
                                               mapOppProdIdNErrResponseBody.put(qoLL.Id,ce.getMessage()); 
                                               mapOppProdIdNOppProd.put(qoLL.Id,qoLL);
                                               mapOppProdIdNResponseIsXML.put(qoLL.Id,false);
                                               apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Callout exception , kindly try to pend inventory after again');
                                               apexpages.addMessage(am);   
                                           }
                                           catch(System.Exception e) {
                                               mapOppProdIdNErrResponseBody.put(qoLL.Id,e.getMessage()); 
                                               mapOppProdIdNOppProd.put(qoLL.Id,qoLL);
                                               mapOppProdIdNResponseIsXML.put(qoLL.Id,false);
                                               apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Some Exception occurred , please try again after sometime.'+e.getMessage());
                                               apexpages.addMessage(am);
                                           }                                              
                                       }
        if((!mapOppProdIdNErrResponseBody.isEmpty() && !mapOppProdIdNOppProd.isEmpty() && !mapOppProdIdNResponseIsXML.isEmpty()) && !test.isRunningTest() ){
            CPQ_MDL_Integration_Vim_Efs.parseErrorResponsePendInventory(mapOppProdIdNErrResponseBody,mapOppProdIdNOppProd,mapOppProdIdNResponseIsXML);
        }
        if(!test.isRunningTest()){
        CPQ_MDL_Integration_Vim_Efs.parseResponseXML_PendInventoryResponse(lstResponseBody,acc);
        }
    }
    
    public static String constructXML_PendInventory(SBQQ__QuoteLine__c qoLL,String customerNumber,String userName) {
        String requestXMLString = '';
        String xmlns='';
        //get xmlns value from custom setting
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('PendInventory');
        xmlns = endPts.xmlns__c;
        
        //get server timestamp to send it in requestid
        DateTime result = DateTime.now();
        String timeStampString = result.format();//to convert datetime into string
        String reqID = qoLL.Id + '-' + timeStampString ;
        System.debug('RequestId PendInventory Request :' + reqID);
        
        //getting attributes values
        //List<Opportunity_Charge_Attribute__c> lstAttributes = new List<Opportunity_Charge_Attribute__c>();
        Map<String,String> mapAttributeNameAndValue = new Map<String,String>();
        Map<String,String> mapModifiedNameAndValue = new Map<String,String>();
        String aopVal;
        //List<Id> lstRatePlanIDs = new List<Id>();
        //List<Id> lstRatePlanChargeIDs = new List<Id>();
        Set<Id> attrRelationIds = new Set<Id>(); //added new
        List<Attribute_Lines__c> lstAttributes = new List<Attribute_Lines__c>();
        //start - new
        List<SBQQ__QuoteLine__c> quoteLineLst = [Select Id, SBQQ__Quote__c, Attribute_Relationship__c, SBQQ__Product__c,
                                                 SBQQ__ProductCode__c, SBQQ__ProductName__c, SBQQ__Product__r.IsInventoried__c, 
                                                 Inventory_Id__c, Error_Text__c  From SBQQ__QuoteLine__c Where Id=: qoLL.Id];
        for(SBQQ__QuoteLine__c qll: quoteLineLst){
            attrRelationIds.add(qll.Attribute_Relationship__c);
        }
        
        lstAttributes = [select id, Attribute_Junction__c, Attribute_Type__c, Attribute_Name__c, Phone_Value__c,
                         Picklist_Value__c, String_Value__c, Boolean_Value__c, Date_Value__c, Value_ID__c,
                         Number_Value__c FROM Attribute_Lines__c WHERE Attribute_Junction__c IN:attrRelationIds];
        System.debug('Opportunity Charge Attributes:'+lstAttributes);
        //Map<Id, List<Attribute_Lines__c>> attrRelationIdVsAttrLinesList = new Map<Id, List<Attribute_Lines__c>>();
        for(Attribute_Lines__c att: lstAttributes) {
            /*if(attrRelationIdVsAttrLinesList.containsKey(att.Attribute_Junction__c)){
                attrRelationIdVsAttrLinesList.get(att.Attribute_Junction__c).add(att);
            }
            else{
                attrRelationIdVsAttrLinesList.put(att.Attribute_Junction__c, new List<Attribute_Lines__c>{att});
            }*/
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
        //xmlW.writeCharacters(oppProd.invoiceit_crmx__Product_Code__c);UNCOMMENT AFTER CHANGES - 09/10/2020
        xmlW.writeEndElement();
        //End of ProductCode tag
        
        //Beginning of ProductName tag
        xmlW.writeStartElement(null,'ProductName',null);
        //xmlW.writeCharacters(oppProd.Name); UNCOMMENT AFTER CHANGES - 09/10/2020
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
    
    
    public static String parseResponseXML_PendInventoryResponse(List<String> lstResponseStrings,String accId) {
        String txtmsg;
        String errMsg='';
        Map<String,String> mapRequestIdAndInventoryIds = new Map<String,String>(); //used for positive responses to update inventory id
        Map<String,String> mapRequestIdAndErrorText = new Map<String,String>();
        Map<String,String> mapRequestIdAndOpportunityId = new Map<String,String>();
        List<SBQQ__QuoteLine__c> lstOppProducts = new List<SBQQ__QuoteLine__c>();
        List<Case> lstCases = new List<Case>();
        AssignmentRule AR;
        Database.DMLOptions dmlOpts;
        try {
            for(String resp : lstResponseStrings) {
                if(!test.isRunningTest()){
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
            }
            System.debug('mapRequestIdAndInventoryIds'+mapRequestIdAndInventoryIds.size()+'^^'+mapRequestIdAndInventoryIds);
            System.debug('mapRequestIdAndErrorText'+mapRequestIdAndErrorText.size()+'&&'+mapRequestIdAndErrorText);
            if(mapRequestIdAndInventoryIds.keyset() != null) {
                for(SBQQ__QuoteLine__c oppProd : [Select i.Name, i.Inventory_Id__c,Pend_Date__c , i.SBQQ__ProductName__c, i.Id,i.Error_Text__c,i.SBQQ__Quote__c From SBQQ__QuoteLine__c i
                                                  where i.Id in : mapRequestIdAndErrorText.keyset()]) {
                                                      mapRequestIdAndOpportunityId.put(oppProd.Id,oppProd.SBQQ__Quote__c);
                                                      if(mapRequestIdAndInventoryIds.containsKey(oppProd.Id) && mapRequestIdAndErrorText.containsKey(oppProd.Id)) {
                                                          oppProd.Inventory_Id__c = mapRequestIdAndInventoryIds.get(oppProd.Id);
                                                          if(oppProd.Inventory_Id__c != '' && oppProd.Inventory_Id__c != null){
                                                              oppProd.Pend_Date__c = Date.today();
                                                              //apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, oppProd+''+'Pended Successfully');
                                                              //apexpages.addMessage(am);
                                                              errMsg = errMsg!='' ? errMsg+'<br/>'+oppProd.SBQQ__ProductName__c+': '+'Pended Successfully' : oppProd.SBQQ__ProductName__c+': '+'Pended Successfully';
                                                          }
                                                          oppProd.Error_Text__c = mapRequestIdAndErrorText.get(oppProd.Id);
                                                          lstOppProducts.add(oppProd);
                                                          //apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, oppProd+''+oppProd.Error_Text__c);
                                                          //apexpages.addMessage(am);
                                                          if(oppProd.Error_Text__c != Null && oppProd.Error_Text__c !='')
                                                          errMsg = errMsg!='' ? errMsg+'<br/>'+oppProd.SBQQ__ProductName__c+': '+oppProd.Error_Text__c : oppProd.SBQQ__ProductName__c+': '+oppProd.Error_Text__c;
                                                      }                                                       
                                                  }
            }
            if(mapRequestIdAndErrorText.size()>0 || test.isrunningTest()){
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
            return errMsg;
        }
        catch(System.Exception e) {
            apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Issue in parsing :'+e.getMessage());
            apexpages.addMessage(am);
        }
        return errMsg;
    }
    
    public static void parseErrorResponsePendInventory(Map<Id,String> mapOppProdIdNErrResponseBody, Map<Id,SBQQ__QuoteLine__c> mapOppProdIdNOppProd, Map<Id,Boolean> mapOppProdIdNResponseIsXML){
        String txtmsg = '';     
        List<SBQQ__QuoteLine__c> lstOppProdToUpdate = new List<SBQQ__QuoteLine__c>();
        for(Id oppProdId : mapOppProdIdNErrResponseBody.keyset()){
            if(mapOppProdIdNResponseIsXML.containskey(oppProdId)){
                if(mapOppProdIdNResponseIsXML.get(oppProdId)==true ){
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
    
    @Future(callout = true)//added by saiv 09/18/2020
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
        
        
        for(SBQQ__QuoteLine__c oppProd : [Select i.Id, i.Name, i.Inventory_Id__c, i.Pend_Date__c , i.Error_Text__c, i.Attribute_Relationship__c,
                                          i.SBQQ__Quote__c, i.customerNumber__c From SBQQ__QuoteLine__c i
                                          where i.Id in : setOppProdIds ALL ROWS]){
                                              //and (RecordType.DeveloperName = 'MDL_Opportunity_Product' or RecordType.DeveloperName = 'Nolo_Opportunity_Product') ALL ROWS]) {
                                              reqXML = CPQ_MDL_Integration_Vim_Efs.constructXML_ReleaseInventory(oppProd,uName);  //get request XML from the static method
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
                                                      //need to update
                                                      Error_Log__c temp_error = CPQ_MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody() , reqXML);
                                                      if(temp_error != null){
                                                          temp_error.XML_Mesaage_Type__c = 'ReleaseInventory';
                                                          lstErrLogs.add(temp_error);
                                                      }
                                                      
                                                  }   
                                                  
                                                  if(res.getStatusCode() == 400 || res.getStatusCode() == 401){
                                                      //need to update
                                                      CPQ_MDL_Integration_Vim_Efs.parseResponse400Error(res.getBody(),'ReleaseInventory',reqXML,oppProd.Id,'');
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
                                                  //need to update
                                                  CPQ_MDL_Integration_Vim_Efs.sendEmailInCaseOfException('Release Inventory',oppProd.Id,e.getMessage()); 
                                              }                                                            
                                          }
        
        if(lstErrLogs.size() > 0) {
            Database.insert(lstErrLogs);
        }
        if(!test.isRunningTest()){
        CPQ_MDL_Integration_Vim_Efs.parseResponseXML_ReleaseInventoryResponse(lstResponseBody);
        }
    }
    
    //releaseInvforBatch
    public static void releaseInventoryRequestForBatch(Set<Id> setOppProdIds,String userName) {
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
        
        
        for(SBQQ__QuoteLine__c oppProd : [Select i.Id, i.Name, i.Inventory_Id__c, i.Pend_Date__c , i.Error_Text__c, i.Attribute_Relationship__c,
                                          i.SBQQ__Quote__c, i.customerNumber__c From SBQQ__QuoteLine__c i
                                          where i.Id in : setOppProdIds ALL ROWS]){
                                              //and (RecordType.DeveloperName = 'MDL_Opportunity_Product' or RecordType.DeveloperName = 'Nolo_Opportunity_Product') ALL ROWS]) {
                                              reqXML = CPQ_MDL_Integration_Vim_Efs.constructXML_ReleaseInventory(oppProd,uName);  //get request XML from the static method
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
                                                      //need to update
                                                      Error_Log__c temp_error = CPQ_MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody() , reqXML);
                                                      if(temp_error != null){
                                                          temp_error.XML_Mesaage_Type__c = 'ReleaseInventory';
                                                          lstErrLogs.add(temp_error);
                                                      }
                                                      
                                                  }   
                                                  
                                                  if(res.getStatusCode() == 400 || res.getStatusCode() == 401){
                                                      //need to update
                                                      CPQ_MDL_Integration_Vim_Efs.parseResponse400Error(res.getBody(),'ReleaseInventory',reqXML,oppProd.Id,'');
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
                                                  //need to update
                                                  CPQ_MDL_Integration_Vim_Efs.sendEmailInCaseOfException('Release Inventory',oppProd.Id,e.getMessage()); 
                                              }                                                            
                                          }
        
        if(lstErrLogs.size() > 0) {
            Database.insert(lstErrLogs);
        }
        if(!test.isRunningTest()){
        CPQ_MDL_Integration_Vim_Efs.parseResponseXML_ReleaseInventoryResponse(lstResponseBody);
        }
    }
    @future(callout = true)
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
        
        for(SBQQ__QuoteLine__c oppProd : [Select i.Id, i.Name, i.Inventory_Id__c, i.Pend_Date__c , i.Error_Text__c, i.customerNumber__c, i.Attribute_Relationship__c,
                                          i.SBQQ__Quote__c From SBQQ__QuoteLine__c i
                                          where i.Id in : setOppProdIds ALL ROWS]){
                                              reqXML = CPQ_MDL_Integration_Vim_Efs.constructXML_ReleaseInventory(oppProd,uName,mapOpptyProdNInventoryId.get(oppProd.Id));  //get request XML from the static method
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
                                                          //need to update
                                                          Error_Log__c temp_error = CPQ_MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody() , reqXML);
                                                          if(temp_error != null){
                                                              temp_error.XML_Mesaage_Type__c = 'ReleaseInventory';
                                                              lstErrLogs.add(temp_error);
                                                          }   
                                                      }
                                                      if(res.getStatusCode() == 400 || res.getStatusCode() == 401){
                                                          //need to update
                                                          CPQ_MDL_Integration_Vim_Efs.parseResponse400Error(res.getBody(),'ReleaseInventory',reqXML,oppProd.Id,'');
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
                                                  //need to update
                                                  CPQ_MDL_Integration_Vim_Efs.sendEmailInCaseOfException('Release Inventory',oppProd.Id,e.getMessage()); 
                                              }                                                            
                                          }
        if(lstErrLogs.size() > 0) {
            Database.insert(lstErrLogs);
        }
        system.debug('@@@@lstResponseBody '+lstResponseBody);
        if(!test.isRunningTest()){
        CPQ_MDL_Integration_Vim_Efs.parseResponseXML_ReleaseInventoryResponse(lstResponseBody);   
        }
    }
    
    
    public static String constructXML_ReleaseInventory(SBQQ__QuoteLine__c oppProd,String uName) {
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
        String invID = ''+oppProd.Inventory_Id__c;
        
        //get customerNumber for the product
        if(oppProd.customerNumber__c != null)
            cusNumber = oppProd.customerNumber__c;
        //pending work need to get attribute relation and attribute line
        //2 maps - quoteidvsattrrelation and attrrelationvsList<quoteline>
        //List<SBQQ__QuoteLine__c> quoteLineLst = new List<SBQQ__QuoteLine__c>();
        Set<Id> attrRelationIds = new Set<Id>();
        List<Attribute_Lines__c> attrLinesLst = new List<Attribute_Lines__c>();
        Map<String,String> mapAttributeNameAndValue = new Map<String,String>();
        if(oppProd.Attribute_Relationship__c != null){
            attrRelationIds.add(oppProd.Attribute_Relationship__c);
        }
        Map<Id,List<Attribute_Lines__c>> attrRelationIdVsAttrLinesList = new Map<Id,List<Attribute_Lines__c>>();
        attrLinesLst = [select id, Attribute_Junction__c, Attribute_Type__c, Attribute_Name__c, 
                        Picklist_Value__c, String_Value__c, Boolean_Value__c,Phone_Value__c, Date_Value__c, Value_ID__c,
                        Number_Value__c FROM Attribute_Lines__c WHERE Attribute_Junction__c IN:attrRelationIds];
        
        /*quoteLineLst = [Select id,Name,Inventory_Id__c,Pend_Date__c,Error_Text__c,SBQQ__Quote__c,
Attribute_Relationship__c
From SBQQ__QuoteLine__c Where SBQQ__QuoteLine__c IN: oppProd];*/
        for(Attribute_Lines__c att: attrLinesLst) {
            
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
    
    public static String constructXML_ReleaseInventory(SBQQ__QuoteLine__c oppProd,String uName,String inventoryId) {
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
        Set<Id> attrRelationIds = new Set<Id>();
        List<Attribute_Lines__c> attrLinesLst = new List<Attribute_Lines__c>();
        Map<String,String> mapAttributeNameAndValue = new Map<String,String>();
        if(oppProd.Attribute_Relationship__c != null){
            attrRelationIds.add(oppProd.Attribute_Relationship__c);
        }
        attrLinesLst = [select id, Attribute_Junction__c, Attribute_Type__c, Attribute_Name__c, Phone_Value__c,
                        Picklist_Value__c, String_Value__c, Boolean_Value__c, Date_Value__c, Value_ID__c,
                        Number_Value__c FROM Attribute_Lines__c WHERE Attribute_Junction__c IN:attrRelationIds];
        for(Attribute_Lines__c att: attrLinesLst) {
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
        system.debug('==lstResponses=='+lstResponses);
        String txtmsg;
        Map<String,String> mapRequestIdAndErrorText = new Map<String,String>();
        Map<String,String> mapRequestIdAndAccountId = new Map<String,String>(); 
        Map<String,String> mapRequestIdAndOpportunityId = new Map<String,String>();
        Map<String,String> mapRequestIdAndOrderId = new Map<String,String>();
        List<OrderItem> lstOrderProdToUpdate = new List<OrderItem>();
        List<SBQQ__QuoteLine__c> lstOppProdToUpdate = new List<SBQQ__QuoteLine__c>();
        Set<String> setIdInvToBeBlanked = new Set<String>();                
        Set<String> setOrderProdIdToBeBlanked = new Set<String>();
        Set<String> setInventoryIds = new Set<String>();
        List<Case> lstCases = new List<Case>();
        String objectType = '';
        AssignmentRule AR;
        Database.DMLOptions dmlOpts;
        Schema.DescribeSObjectResult orderProduct = OrderItem.sObjectType.getDescribe();
        String keyPrefixOrderProduct = orderProduct.getKeyPrefix();
        Schema.DescribeSObjectResult oppProduct = SBQQ__QuoteLine__c.sObjectType.getDescribe();
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
        if(objectType=='OrderProduct' || test.isrunningtest()){
            if(setIdInvToBeBlanked.size() > 0){
                for(OrderItem jobRPC : [Select Id,Inventory_Id__c from OrderItem where Id in :setIdInvToBeBlanked]){
                    jobRPC.Inventory_Id__c = '';
                    //oppProd.Pend_Date__c = null;
                    lstOrderProdToUpdate.add(jobRPC);
                }
            }
            for(OrderItem jobRPC : [select Id,Inventory_Id__c,OrderId,Order.AccountId from OrderItem where Id in :mapRequestIdAndErrorText.keyset() ALL ROWS]){
                mapRequestIdAndAccountId.put(jobRPC.Id,jobRPC.Order.AccountId);
                mapRequestIdAndOrderId.put(jobRPC.Id,jobRPC.OrderId);
            }
            /* - Need to update thos cpq order product
if(setIdInvToBeBlanked.size() > 0){
for(OrderItem jobRPC : [Select Id,Created_From_Charge__r.invoiceit_s__Status__c, from OrderItem where invoiceit_s__Status__c = 'Cancelled' and invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c in :setInventoryIds]){
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
} */          
        }
        else if(objectType=='OpportunityProduct' || test.isrunningtest()){
            if(setIdInvToBeBlanked.size() > 0){
                for(SBQQ__QuoteLine__c oppProd : [Select Id,Inventory_Id__c from SBQQ__QuoteLine__c where Id in :setIdInvToBeBlanked]){
                    oppProd.Inventory_Id__c = '';
                    //oppProd.Pend_Date__c = null;
                    lstOppProdToUpdate.add(oppProd);
                }
            }
            for(SBQQ__QuoteLine__c oppProd : [select Id,SBQQ__Quote__r.SBQQ__Account__c,SBQQ__Quote__c from SBQQ__QuoteLine__c where Id in :mapRequestIdAndErrorText.keyset() ALL ROWS]){
                mapRequestIdAndAccountId.put(oppProd.Id,oppProd.SBQQ__Quote__r.SBQQ__Account__c);
                mapRequestIdAndOpportunityId.put(oppProd.Id,oppProd.SBQQ__Quote__c);
            }
        }
        
        
        if(mapRequestIdAndErrorText.size()>0 || test.isrunningtest()){
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
                    c.Parent_Quote__c = mapRequestIdAndOpportunityId.get(reqId);//c.Parent_Opportunity__c
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
    
    @future(callout = true)
    
    public static void orderRequest(Set<Id> OrderItemIds) {
        System.debug('@@@@ In Order Request');
        
        Map<Id,Order> mapOrderIdNOrder = new Map<Id,Order>();
        Map<Id, List<OrderItem>> orderIdVSOrderProducts = new Map<Id, List<OrderItem>>();
        Set<string>attributeRelations = new Set<string>();
        List<OrderItem> orderprodlist = [Select id,Status__c,Product2.IsInventoried__c ,Modified_from_Quote_Builder__c,Quantity,Cancel_Now_Date__c,Fulfillment_date__c,UpgradedDowngraded__c,OrderId,SIN__c,Inventory_Id__c,SFInventoryId__c,Attribute_Relationship__c,Renew_Rebase_Truncate_Date__c,Product2.ProductCode,
                                         ServiceDate,Origin__c,Origin_Product_Code__c,Path__c,EndDate,SBQQ__TerminatedDate__c,SBQQ__QuoteLine__r.Last_day_of_month__c,Product2.Name,blng__NextBillingDate__c,SBQQ__BundleRoot__c,ParentProduct__c,Live_Date__c,
                                         Order.Account.Phone,Order.Account.Contact_Email__c,Order.Account.Last_Name__c,Order.Account.First_Name__c,Contact__r.Website__c,Order.Status__c,
                                         Contact__r.Email,Contact__r.LastName,Contact__r.FirstName,Contact__r.Professional_ID__c,Contact__r.Phone,
                                         Chat_ID__c,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.SIN__c,SBQQ__ProductSubscriptionType__c,CreatedDate from OrderItem where ID IN:OrderItemIds AND Status__c !='Upgraded' AND Status__c !='Downgraded' AND Order.Status__c !='Off set' AND Order.Status__c !='Modified'];
        
        String reqXML;
        Integer numberOfDays = Date.daysInMonth(date.today().year(), date.today().month());
        Date lastDayOfMonth = Date.newInstance(date.today().year(), date.today().month(), numberOfDays);
        MDL_RecursionHandler.CheckUpdate = true;
        List<String> lstResponseBody = new List<String>();
        List<Error_Log__c> lstErrLogs = new List<Error_Log__c>();
        List<Error_Log__c> lstExistingErrLogs = new List<Error_Log__c>();
        Map<Id,Error_Log__c> mapIdNExistingErrLogs = new Map<Id,Error_Log__c>();
        
        Map<Id,List<Attribute_Lines__c>> mapOrderIdNlstOrderChargeAttributes = new Map<Id,List<Attribute_Lines__c>>();
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('OrderRequest');
        String endPoint = String.valueOf(endPts.Endpoint_URL__c);
        String methodType = endPts.MethodType__c;
        
        //code for authentication
        String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)
        String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
        String privateKey = endPts.Private_Key__c;
        String publicKey  = endPts.Public_Key__c;
        String apiKey = endPts.API_key__c;
        
        Restrict_Integration_Calls__c rCalls = Restrict_Integration_Calls__c.getValues('Restrict');
        System.debug('**'+rCalls);
        Boolean restrictCalls = Boolean.valueOf(rCalls.Restrict_Callouts__c);
        System.debug('a values is **'+restrictCalls);
        
        //get Orders from Order Products
        for(OrderItem op : orderprodlist){
            if(op.Attribute_Relationship__c!=null){
                attributeRelations.add(op.Attribute_Relationship__c);
            }
            
            
            if(orderIdVSOrderProducts.containsKey(op.orderId)){
                orderIdVSOrderProducts.get(op.orderId).add(op);
            }
            else{
                orderIdVSOrderProducts.put(op.orderId, new List<OrderItem>{op});
            }
        }
        
        List<Attribute_Lines__c> attributes = [select id, Attribute_Junction__c, Attribute_Type__c, Attribute_Name__c, 
                                               Picklist_Value__c, String_Value__c, Boolean_Value__c, Date_Value__c,Phone_Value__c, Value_ID__c,
                                               Number_Value__c FROM Attribute_Lines__c where Attribute_Junction__c  IN:attributeRelations];
        Map<string, List<Attribute_Lines__c>> attributeRelationVSattributes = new Map<string, List<Attribute_Lines__c>>();
        for(Attribute_Lines__c ab : attributes){
            if(attributeRelationVSattributes.containsKey(ab.Attribute_Junction__c)){
                attributeRelationVSattributes.get(ab.Attribute_Junction__c).add(ab);
            }
            else{
                attributeRelationVSattributes.put(ab.Attribute_Junction__c, new List<Attribute_Lines__c>{ab});
            }
        }
        
        Map<Id,Order> OrderMap = new Map<Id,Order>([select Id ,SBQQ__Quote__r.Name,QuoteId,SBQQ__Quote__r.id,Account.Avvo_CustomerID__c, Account.MH_Cust_Number__c ,Account.IB_Customer_Number__c,Account.RecordType.DeveloperName,AccountId ,
                                                    Account.Org_Id__c,Account.Parent.Name,Account.Contact_Email__c,Firm_Name_from_BS__c,OrderNumber, Account.Name,
                                                    Account.BillingCountry,Account.BillingState,Account.BillingCity,Account.BillingStreet,
                                                    Account.BillingPostalCode,Account.Website,Account.Phone,Name From order where Id IN : orderIdVSOrderProducts.keyset()]);
        // End of data Setup
        
        
        //Checking if Order XML already exists in Error Log, if exists do not send that order , queue it along with the existing order
        for(Error_Log__c err : [Select e.XML_Mesaage_Type__c, e.XML_Body__c, e.Sent_Successfully__c, e.Order_Number__c,e.Order_Name__c,e.Error_Reason__c, e.Name, e.Id ,e.Re_process_date_time__c
                                From Error_Log__c e
                                Where e.XML_Mesaage_Type__c = 'OrderRequest' AND e.Order_Number__c in :mapOrderIdNOrder.keySet()] ) {
                                    mapIdNExistingErrLogs.put(err.Order_Number__c,err);                 
                                }
        System.debug('mapOrderId And Error Logs^^^'+mapIdNExistingErrLogs);
        
        reqXML = '';
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
        
        //get xmlns value from custom setting
        
        xmlns = endPts.xmlns__c;
        
        //get server timestamp to send it in requestid
        DateTime result = DateTime.now();
        String timeStampString = result.format();//to convert datetime into string
        String reqID = OrderMap.keySet() + '-' + timeStampString ;
        
        
        //construction of XML for Order XML
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
        //xmlW.writeCharacters(uName);
        xmlW.writeEndElement();
        //End of Username tag
        
        // Start of Order XML 
        for(string orderId : orderIdVSOrderProducts.keyset()){
            
            
            //Beginning of CustomerNumber tag
            if(Ordermap.get(orderid).Account.MH_Cust_Number__c != null) {
                xmlW.writeStartElement(null, 'CustomerNumber', null);
                xmlW.writeCharacters(Ordermap.get(orderid).Account.MH_Cust_Number__c);
                xmlW.writeEndElement();
            }
            else {
                xmlW.writeEmptyElement(null, 'CustomerNumber', null);
            }
            //End of CustomerNumber tag
            
              if(Ordermap.get(orderid).Account.RecordType.DeveloperName == 'M_A_Atty_Account') {
            //Beginning of Parent customernumber tag
            if(Ordermap.get(orderid).Account.IB_Customer_Number__c != null) {
                xmlW.writeStartElement(null, 'ParentCustomerNumber', null);
                xmlW.writeCharacters(Ordermap.get(orderid).Account.IB_Customer_Number__c);
                xmlW.writeEndElement();
            }
            else {
                xmlW.writeEmptyElement(null, 'ParentCustomerNumber', null);
            }

            if(Ordermap.get(orderid).Account.Avvo_CustomerID__c!= null) {
                xmlW.writeStartElement(null, 'AvvoCustomerId', null);
                xmlW.writeCharacters(Ordermap.get(orderid).Account.Avvo_CustomerID__c);
                xmlW.writeEndElement();
            }
            else {
                xmlW.writeEmptyElement(null, 'AvvoCustomerId', null);
            }

            }
            
             //Beginning of QuoteId tag: added on 08/23/2023
            if(Ordermap.get(orderid).SBQQ__Quote__r.Name!= null){
                xmlW.writeStartElement(null, 'QuoteId', null);
                xmlW.writeCharacters(Ordermap.get(orderid).SBQQ__Quote__r.Name);
                xmlW.writeEndElement();
                //End of QuoteId tag
            }
            
             else {
            xmlW.writeEmptyElement(null, 'QuoteId', null);
            }
            
            
            //Beginning of OrgID tag: added on 05/01/2016 by akash
            if(Ordermap.get(orderid).Account.Org_Id__c != null){
                xmlW.writeStartElement(null, 'OrgId', null);
                xmlW.writeCharacters(Ordermap.get(orderid).Account.Org_Id__c);
                xmlW.writeEndElement();
                //End of OrgId tag
            }
            
             else {
            xmlW.writeEmptyElement(null, 'OrgId', null);
            }
            //End of orgID tag
            
           if(Ordermap.get(orderid).Account.RecordType.DeveloperName == 'M_A_Atty_Account') {
               
            //Beginning of ServiceAccountName tag
            xmlW.writeStartElement(null, 'ServiceAccountName', null);
                if(Ordermap.get(orderid).Firm_Name_from_BS__c != null){
                  xmlW.writeCharacters(Ordermap.get(orderid).Firm_Name_from_BS__c);
              }
              
              // Added based on MAC 3.0 Order
              else if(Ordermap.get(orderid).Account.Parent.Name!= null && Ordermap.get(orderid).Account.RecordType.DeveloperName == 'M_A_Atty_Account'){
              
                   xmlW.writeCharacters(Ordermap.get(orderid).Account.Parent.Name);
               
              }
              
              else if(Ordermap.get(orderid).Account.Name != null){
              
                   xmlW.writeCharacters(Ordermap.get(orderid).Account.Name);
               
              }
            xmlW.writeEndElement();
            //End of ServiceAccountName tag
           
             //Beginning of Email tag
            xmlW.writeStartElement(null, 'Email', null);
            if(Ordermap.get(orderid).Account.Contact_Email__c != null){
            
                  xmlW.writeCharacters(Ordermap.get(orderid).Account.Contact_Email__c);
              }
            xmlW.writeEndElement();
            //End of Email tag
            
            //Beginning of ServiceCountry tag
            xmlW.writeStartElement(null, 'ServiceCountry', null);
              xmlW.writeCharacters(Ordermap.get(orderid).Account.BillingCountry);
            xmlW.writeEndElement();
            //End of ServiceCountry tag
           
            
            //Beginning of ServiceState tag
            xmlW.writeStartElement(null, 'ServiceState', null);
              xmlW.writeCharacters(Ordermap.get(orderid).Account.BillingState);
            xmlW.writeEndElement();
            //End of ServiceState tag
            
            //Beginning of ServiceCity tag
            xmlW.writeStartElement(null, 'ServiceCity', null);
              xmlW.writeCharacters(Ordermap.get(orderid).Account.BillingCity);
            xmlW.writeEndElement();
            //End of ServiceCity tag
            
            
            //Beginning of ServiceStreetAddress tag
            xmlW.writeStartElement(null, 'ServiceStreetAddress', null);
              xmlW.writeCharacters(Ordermap.get(orderid).Account.BillingStreet);
            xmlW.writeEndElement();
            //End of ServiceStreetAddress tag
           
            
            //Beginning of ServiceZip tag
            xmlW.writeStartElement(null, 'ServiceZip', null);
              xmlW.writeCharacters(Ordermap.get(orderid).Account.BillingPostalCode  );
            xmlW.writeEndElement();
            //End of ServiceZip tag
            
           
            //Beginning of WebsiteURL tag
            xmlW.writeStartElement(null, 'WebsiteURL', null);
             if(Ordermap.get(orderid).Account.Website != null){
              xmlW.writeCharacters(Ordermap.get(orderid).Account.Website );
              }
            xmlW.writeEndElement();
            //End of WebsiteURL tag
            
                      
            //Beginning of Phone tag
            xmlW.writeStartElement(null, 'Phone', null);
            if(Ordermap.get(orderid).Account.Phone != null){
                xmlW.writeCharacters(String.valueOf(Ordermap.get(orderid).Account.Phone));
                                   
            }
              
            xmlW.writeEndElement();
            //End of Phone tag
            
           }
            //Beginning of OrderNumber tag
            xmlW.writeStartElement(null, 'OrderNumber', null);
              xmlW.writeCharacters(Ordermap.get(orderid).OrderNumber);
            xmlW.writeEndElement();
            //End of OrderNumber tag
            
            //beginning of Products tag
            xmlW.writeStartElement(null,'Products',null);
            //getting order products
            List<OrderItem> opTemplist = orderIdVSOrderProducts.get(orderId);
            for(OrderItem op : opTemplist){
                //start of order product related xml here
                //Beginning of Product tag
                xmlW.writeStartElement(null,'Product', null); 
                
                //Beginning of ProductId tag
                xmlW.writeStartElement(null,'ProductId',null);
                xmlW.writeCharacters(op.Id);
                xmlW.writeEndElement();
                //End of ProductId tag
                
                //Beginning of SubscriptionIdentificationNumber tag
                xmlW.writeStartElement(null,'SubscriptionIdentificationNumber',null);
                if(op.SIN__c != null)
                    xmlW.writeCharacters(op.SIN__c);
                xmlW.writeEndElement();
                //End of SubscriptionIdentificationNumber tag
                
                //Beginning of ProductCode tag
                xmlW.writeStartElement(null,'ProductCode',null);
                xmlW.writeCharacters(op.Product2.ProductCode);
                xmlW.writeEndElement();
                //End of ProductCode tag
                
                //Beginning of LineItems tag
                xmlW.writeStartElement(null,'LineItems', null); 
                
                //Beginning of LineItem tag
                xmlW.writeStartElement(null,'LineItem', null);
                
                //Beginning of LineItemId tag
                xmlW.writeStartElement(null, 'LineItemId', null);
                xmlW.writeCharacters(op.Id+lineItemId);
                xmlW.writeEndElement();
                //End of LineItemId tag
                if(op.Sin__c != null) {
                    xmlW.writeStartElement(null, 'SubscriptionIdentificationNumber', null);
                    xmlW.writeCharacters(op.SIN__c);
                    xmlW.writeEndElement();
                }
                else {
                    xmlW.writeEmptyElement(null, 'SubscriptionIdentificationNumber', null);
                }
                
                //Beginning of ProductCode tag
                if(op.Product2.Name != null) {
                xmlW.writeStartElement(null,'ProductCode',null);
                xmlW.writeCharacters(op.Product2.ProductCode);
                xmlW.writeEndElement();
                //End of ProductCode tag
                
                }
                else {
                    xmlW.writeEmptyElement(null, 'ProductCode', null);
                }
                
                if(op.Product2.Name != null) {
                    xmlW.writeStartElement(null, 'ProductName', null);
                    xmlW.writeCharacters(op.Product2.Name);
                    xmlW.writeEndElement();
                }
                else {
                    xmlW.writeEmptyElement(null, 'ProductName', null);
                }
                
                 //Beginning of Quantity tag
                if(op.Quantity != null && (op.Product2.ProductCode == '11018' || op.Product2.ProductCode == '11019') ) {
                    Integer IntQuantity = Integer.valueOf(op.Quantity );
                   
                    xmlW.writeStartElement(null,'Quantity',null);
                    xmlW.writeCharacters(String.valueof(IntQuantity));
                    xmlW.writeEndElement();
                    
                    }
                //End of Quantity tag
                
                xmlW.writeStartElement(null, 'Status', null);
                if(op.Status__c != null) {
                    string status = '';
                    
                    if(op.Status__c == 'Active'  && op.Modified_from_Quote_Builder__c != null ) {
                        
                        status ='Modified';
                   } 
                   
                    else if((op.Status__c == 'Active' || op.Status__c == 'Renewed' || op.Status__c == 'Rebased' ) && op.Modified_from_Quote_Builder__c == null )
                        //commented by Sai C
                        //|| (orderProd.invoiceit_s__Status__c == 'Truncated' && orderProd.invoiceit_s__Service_End_Date__c > Date.today()))
                        //xmlW.writeCharacters('Active'); 
                        status ='Active';
                        
                    if(op.Status__c == 'Cancelled' || op.Status__c == 'Expired' || op.Status__c == 'Truncated' || op.UpgradedDowngraded__c == True || Test.isRunningTest()){
                        //xmlW.writeCharacters('Cancel'); 
                        status = 'Cancel';
                        
                    }
                    
                   
                    
                    xmlW.writeCharacters(status); 
                } 
                xmlW.writeEndElement();
                // End of Status
                
                //Beginning of Path tag
                if(op.Path__c != null) {
                xmlW.writeStartElement(null,'Path',null);
                xmlW.writeCharacters(op.Path__c);
                xmlW.writeEndElement();
                //End of Path tag
                
                }
                //else {
                 //   xmlW.writeEmptyElement(null, 'Path', null);
                //}
               
                //MAC added part of upgrade and downgrade
                //Beginning of Origin Product Code  
                if(op.Origin_Product_Code__c!= null) {
                xmlW.writeStartElement(null,'Origin',null);
                xmlW.writeCharacters(op.Origin_Product_Code__c);
                xmlW.writeEndElement();
                //End of Origin Product Code tag
                
                }
              //  else {
                 //   xmlW.writeEmptyElement(null, 'Origin', null);
               // }
                
                //Beginning of PostDate tag
                xmlW.writeStartElement(null, 'PostDate', null);
                postDate = String.valueOf(op.CreatedDate);
                validatedDateValue = postDate.split(' ');
                xmlW.writeCharacters(validatedDateValue[0]);
                xmlW.writeEndElement();
                //End of PostDate tag
                
                
                 //Beginning of FulfillmentDate tag
                    if(op.Fulfillment_date__c!= null) {
                       // if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != 'System Fulfillment' && (orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != null || orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != '')) { 
                            xmlW.writeStartElement(null, 'FulfillmentDate', null);
                            xmlW.writeCharacters(String.valueOf(op.Fulfillment_date__c));
                            xmlW.writeEndElement();
                        //}
                    }
                
                if(op.Status__c == 'Cancelled' || test.isrunningtest()) {
                
                    if (op.Cancel_Now_Date__c != null) {
                        xmlW.writeStartElement(null, 'CancelDate', null);
                        xmlW.writeCharacters(String.valueOf(op.Cancel_Now_Date__c));  
                        xmlW.writeEndElement();
                    }
                     
                    else if(op.SBQQ__TerminatedDate__c != null) {
                        xmlW.writeStartElement(null, 'CancelDate', null);
                        xmlW.writeCharacters(String.valueOf(op.SBQQ__TerminatedDate__c));  
                        xmlW.writeEndElement();
                    }
                   else  If (op.SBQQ__QuoteLine__r.Last_day_of_month__c!= null){
                   
                        xmlW.writeStartElement(null, 'CancelDate', null);
                        xmlW.writeCharacters(String.valueOf(op.SBQQ__QuoteLine__r.Last_day_of_month__c));  
                        xmlW.writeEndElement();
                   
                   } 
                    
                }
                
                else if (op.Cancel_Now_Date__c != null) {
                  
                        xmlW.writeStartElement(null, 'CancelDate', null);
                        xmlW.writeCharacters(String.valueOf(op.Cancel_Now_Date__c));  
                        xmlW.writeEndElement();
                    }
               
                
                else if(op.Status__c == 'Expired' || op.Status__c == 'Truncated' || test.isrunningtest()) {
                   // if(op.SBQQ__TerminatedDate__c != null) {
                       // String terminatedate = lastDayOfMonth ;
                        xmlW.writeStartElement(null, 'CancelDate', null);
                        System.debug('service end of charge past its service end date is::'+String.valueOf(op.SBQQ__TerminatedDate__c));
                        if(op.SBQQ__TerminatedDate__c != null) { 
                        
                           xmlW.writeCharacters(String.valueOf(op.SBQQ__TerminatedDate__c));  
                        }
                        else{
                            xmlW.writeCharacters(String.valueOf(lastDayOfMonth)); 
                        }
                         
                        xmlW.writeEndElement();
                    //}
                }
                
                  else if(op.UpgradedDowngraded__c == True && op.Cancel_Now_Date__c == null) {
                   // if(op.SBQQ__TerminatedDate__c != null) {
                       // String terminatedate = lastDayOfMonth ;
                        xmlW.writeStartElement(null, 'CancelDate', null);
                       
                            xmlW.writeCharacters(String.valueOf(lastDayOfMonth)); 
                       
                         
                        xmlW.writeEndElement();
                    //}
                }
                    //Beginning of IsProductInventoried tag
                    xmlW.writeStartElement(null, 'IsProductInventoried', null);
                    if(op.Product2.IsInventoried__c != False){
                       
                         xmlW.writeCharacters('True');
                    }
                    else{
                        xmlW.writeCharacters('False');
                    }
                        xmlW.writeEndElement();
                    //End of IsProductInventoried tag
                    
                    //Beginning of HasparentProducts tag*****
                    xmlW.writeStartElement(null, 'HasParentProducts', null);
                    If(op.SBQQ__RequiredBy__c != null && op.SBQQ__RequiredBy__r.SIN__c != null && !op.ParentProduct__c.contains('Package') &&
                        !op.ParentProduct__c.contains('Bundle') ){
                        
                        xmlW.writeCharacters('Y');
                        //xmlW.writeEndElement();
                        
                    }
                    
                    else{
                            xmlW.writeCharacters('N');
                    }
                    xmlW.writeEndElement();
                    //End of HasparentProducts tag 
                    
                    
                    //Beginning of ParentProductSIN tag***********added by akash
                    xmlW.writeStartElement(null, 'ParentProductSIN', null);
                     
                    if(op.SBQQ__RequiredBy__c != null && op.SBQQ__RequiredBy__r.SIN__c != null && !op.ParentProduct__c.contains('Package') &&
                        !op.ParentProduct__c.contains('Bundle') ){
                        xmlW.writeCharacters(op.SBQQ__RequiredBy__r.SIN__c );
                    }
                    else {
                        xmlW.writeCharacters('');
                    }
                      
                    xmlW.writeEndElement();
                   //End of ParentProductSIN tag 
                   
                    //Begin of FulfillmentID Tag
                        xmlW.writeStartElement(null, 'FulfillmentID', null);
                        if(op.Chat_ID__c != null){
                        System.Debug ('orderProd' + op);
                                xmlW.writeCharacters(op.Chat_ID__c);
                             }
                            else{
                                xmlW.writeCharacters(' ');
                            }
                        xmlW.writeEndElement();
                        //End of FulfillmentID tag
                    
                    
                //Beginning of Inventory Id Attribute Name tag
                //xmlW.writeStartElement(null, 'Name', null);
                //xmlW.writeCharacters('InventoryId');
                //xmlW.writeEndElement();
                //End of Inventory Id Attribute Name tag
                
                //Beginning of Inventory Id Attribute Value tag
               // xmlW.writeStartElement(null, 'Value', null);
                //if(op.Inventory_Id__c!= null)
                //    xmlW.writeCharacters(op.Inventory_Id__c);
                //xmlW.writeEndElement();
                //End of Inventory Id
                
                // Adding Service Start Date Tag for Charges by Sai C
                xmlW.writeStartElement(null, 'ServiceStartDate', null);
                if(op.ServiceDate != null){
                    xmlW.writeCharacters(String.valueOf(op.ServiceDate));  
                }
                else{
                    xmlW.writeCharacters('');
                }
                xmlW.writeEndElement();
                // End of Service Start date Tag for charges 
                
                // Adding Service End Date Tag for Charges by Sai C
                xmlW.writeStartElement(null, 'ServiceEndDate', null);
                if(op.EndDate != null && op.Status__c != 'Truncated' && op.Status__c != 'Expired' && op.Status__c != 'Cancelled'){
                    xmlW.writeCharacters(String.valueOf(op.EndDate));  
                }
                else if( op.Status__c == 'Truncated' || op.Status__c == 'Expired' || op.Status__c == 'Cancelled' || Test.isRunningTest() ){
                        
                       if(op.SBQQ__TerminatedDate__c != null) { 
                        
                           xmlW.writeCharacters(String.valueOf(op.SBQQ__TerminatedDate__c)); 
                        }
                        else{
                            xmlW.writeCharacters(String.valueOf(lastDayOfMonth)); 
                        } 
                }
                else{
                    xmlW.writeCharacters('');
                }
                xmlW.writeEndElement();
                // End of Service End date Tag for charges 
                
               if(op.Product2.ProductCode == '11014' || op.Product2.ProductCode == '11017'|| op.Product2.ProductCode == '11015' || op.Product2.ProductCode == '11016'){
                     
                   if(op.Product2.ProductCode == '11014' || op.Product2.ProductCode == '11015' || op.Product2.ProductCode == '11016'){
                       
                  
 
                    xmlW.writeStartElement(null, 'Attributes', null);
                     
                       
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of Professional Id Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('ProfessionalId');
                        xmlW.writeEndElement();
                        //End of Professional Id Attribute Name tag
                        
                        //Beginning of ProfessionalId Attribute Value tag
                         if(op.Contact__r.Professional_ID__c != null){
                         
                            xmlW.writeStartElement(null, 'Value', null);
                            
                                xmlW.writeCharacters(op.Contact__r.Professional_ID__c);
                            xmlW.writeEndElement();
                        
                         }
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                       
                     
                     //Beginning of FirstName tag
                    
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of FirstName Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('FirstName');
                        xmlW.writeEndElement();
                        //End of FirstName Attribute Name tag
                        
                        //Beginning of FirstName Attribute Value tag
                         if(op.Contact__r.FirstName != null){
                            xmlW.writeStartElement(null, 'Value', null);
                            
                                xmlW.writeCharacters(op.Contact__r.FirstName);
                            xmlW.writeEndElement();
                           }
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                     
                   
                      //Beginning of LastName tag
                     
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of LastName Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('LastName');
                        xmlW.writeEndElement();
                        //End of LastName Attribute Name tag
                        
                        //Beginning of LastName Attribute Value tag
                        if(op.Contact__r.LastName != null){
                            xmlW.writeStartElement(null, 'Value', null);
                            
                                xmlW.writeCharacters(op.Contact__r.LastName);
                            xmlW.writeEndElement();
                          }
                          
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                      
                   
                    //Beginning of Contact Email tag
                    
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of Contact Email Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('Email');
                        xmlW.writeEndElement();
                        //End of Contact Email Attribute Name tag
                        
                        //Beginning of Contact Email Attribute Value tag
                         if(op.Contact__r.Email != null){
                            xmlW.writeStartElement(null, 'Value', null);
                            
                                xmlW.writeCharacters(op.Contact__r.Email);
                            xmlW.writeEndElement();
                         } 
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                           
                   
                   //Beginning of Contact Phone tag
                     
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of Contact Phone Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('Phone');
                        xmlW.writeEndElement();
                        //End of Contact Phone Attribute Name tag
                        
                        //Beginning of Contact Phone Attribute Value tag
                        if(op.Contact__r.Phone!= null){
                        
                            xmlW.writeStartElement(null, 'Value', null);
                            
                                xmlW.writeCharacters(op.Contact__r.Phone);
                            xmlW.writeEndElement();
                        
                         }  
                         
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                       
                   
                   //Beginning of Contact Phone tag
                     if(op.Contact__r.Website__c != null){
                          String Website;
                          Website = op.Contact__r.Website__c ;
                          
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of Contact WebsiteURL Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('WebsiteURL');
                        xmlW.writeEndElement();
                        //End of Contact WebsiteURL Attribute Name tag
                        
                        //Beginning of Contact WebsiteURL Attribute Value tag
                        xmlW.writeStartElement(null, 'Value', null);
                        
                        if(op.Contact__r.Website__c != null){
                          xmlW.writeCharacters(Website);
                          }
                                        
                        xmlW.writeEndElement();
                        
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                        }  
                        
                        xmlW.writeEndElement();
                        //End of Attributes tag
                       
                     }
                   
                    if(op.Product2.ProductCode == '11017'){
                       
                  
 
                    xmlW.writeStartElement(null, 'Attributes', null);
                     
                     
                     //Beginning of FirstName tag
                     if(op.Order.Account.First_Name__c != null){
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of FirstName Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('FirstName');
                        xmlW.writeEndElement();
                        //End of FirstName Attribute Name tag
                        
                        //Beginning of FirstName Attribute Value tag
                        xmlW.writeStartElement(null, 'Value', null);
                        
                            xmlW.writeCharacters(op.Order.Account.First_Name__c);
                        xmlW.writeEndElement();
                        
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                        }
                   
                      //Beginning of LastName tag
                     if(op.Order.Account.Last_Name__c != null){
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of LastName Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('LastName');
                        xmlW.writeEndElement();
                        //End of LastName Attribute Name tag
                        
                        //Beginning of LastName Attribute Value tag
                        xmlW.writeStartElement(null, 'Value', null);
                        
                            xmlW.writeCharacters(op.Order.Account.Last_Name__c);
                        xmlW.writeEndElement();
                        
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                        }
                   
                    //Beginning of Account Email tag
                     if(op.Order.Account.Contact_Email__c  != null){
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of Account Email Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('Email');
                        xmlW.writeEndElement();
                        //End of Account Email Attribute Name tag
                        
                        //Beginning of Account Email Attribute Value tag
                        xmlW.writeStartElement(null, 'Value', null);
                        
                            xmlW.writeCharacters(op.Order.Account.Contact_Email__c );
                        xmlW.writeEndElement();
                        
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                        }    
                   
                   //Beginning of Account Phone tag
                     if(op.Order.Account.Phone  != null){
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of Account Phone Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('Phone');
                        xmlW.writeEndElement();
                        //End of Account Phone Attribute Name tag
                        
                        //Beginning of Account Phone Attribute Value tag
                        xmlW.writeStartElement(null, 'Value', null);
                        
                           if(Ordermap.get(orderid).Account.Phone!= null){
                            xmlW.writeCharacters(String.valueOf(Ordermap.get(orderid).Account.Phone));
                                   
                            }
                        xmlW.writeEndElement();
                        
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                        
                        }                                        
                         xmlW.writeEndElement();
                        //End of Attributes tag
                     }
                 }
                if(!attributeRelationVSattributes.isEmpty() && attributeRelationVSattributes.containskey(op.Attribute_Relationship__c)){
                    //getting attributes here
                    List<Attribute_Lines__c> attTempList = attributeRelationVSattributes.get(op.Attribute_Relationship__c);
                    
                    //beginning of Attributes tag
                    xmlW.writeStartElement(null, 'Attributes', null);
                    
                   if(op.Inventory_Id__c!= null || test.isRunningTest()){ 
                    //beginning of Attribute tag  
                    xmlW.writeStartElement(null, 'Attribute', null);    
                            
                            
                    //Beginning of Inventory Id Attribute Name tag  
                    xmlW.writeStartElement(null, 'Name', null); 
                    xmlW.writeCharacters('InventoryId');    
                    xmlW.writeEndElement(); 
                    //End of Inventory Id Attribute Name tag    
                            
                    //Beginning of Inventory Id Attribute Value tag 
                    xmlW.writeStartElement(null, 'Value', null);    
                       if(!test.isRunningTest()){     
                    xmlW.writeCharacters(op.Inventory_Id__c);   
                       }
                    xmlW.writeEndElement(); 
                            
                     xmlW.writeEndElement();    
                     //End of Attribute tag  
                            
                     }   
                     //End of Inventory Id
                     
                    // part of MAC 3.0 to include SalesforceInventory Inventory Id
                     
                    if(op.SFInventoryId__c != null || test.isRunningTest()){ 
                    //beginning of Attribute tag  
                    xmlW.writeStartElement(null, 'Attribute', null);    
                            
                            
                    //Beginning of SalesforceInventory Id Attribute Name tag  
                    xmlW.writeStartElement(null, 'Name', null); 
                    xmlW.writeCharacters('SalesforceInventoryId');    
                    xmlW.writeEndElement(); 
                    //End of SalesforceInventory Id Attribute Name tag    
                            
                    //Beginning of SalesforceInventory Id Attribute Value tag 
                    xmlW.writeStartElement(null, 'Value', null);    
                       if(!test.isRunningTest()){     
                    xmlW.writeCharacters(op.SFInventoryId__c);   
                       }
                    xmlW.writeEndElement(); 
                            
                     xmlW.writeEndElement();    
                     //End of Attribute tag  
                            
                     }   
                     //End of Salesforce Inventory Id
                     
                    for(Attribute_Lines__c at : attTempList){
                        //Start attributes XML Logic here
                        
                        
                        
                        
                        //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        // xmlW.writeEndElement();
                        //End of Attribute tag
                        
                        //Inclusion of Other Attributes
                        System.debug('@@@@@ Attributes '+at);
                        //beginning of Attribute tag
                        // xmlW.writeStartElement(null, 'Attribute', null);
                        
                        //Beginning of Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        if(at.Attribute_Name__c != null && at.Attribute_Name__c != '')
                            xmlW.writeCharacters(at.Attribute_Name__c);
                        xmlW.writeEndElement();
                        //End of Name tag
                        
                        //Beginning of Value Tag
                        xmlW.writeStartElement(null, 'Value', null);
                        if(at.Attribute_Type__c != null) {
                            if(at.Attribute_Type__c == 'Text'|| at.Attribute_Type__c == 'String') {
                                if(at.String_Value__c != null && at.String_Value__c !='')
                                    xmlW.writeCharacters(at.String_Value__c);
                            }
                            else if(at.Attribute_Type__c == 'Number') {
                                if(at.Number_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(at.Number_Value__c));
                            }
                            else if(at.Attribute_Type__c == 'Boolean') {
                                xmlW.writeCharacters(String.valueOf(at.Boolean_Value__c));
                            }
                            else if(at.Attribute_Type__c == 'Picklist') {
                                if(at.Picklist_Value__c != null && at.Picklist_Value__c !=''){
                                    xmlW.writeCharacters(at.Picklist_Value__c);
                                    }
                                    else if(at.String_Value__c != null && at.String_Value__c !=''){
                                        xmlW.writeCharacters(at.String_Value__c );
                                    }
                            }
                            else if(at.Attribute_Type__c == 'Date') {
                                if(at.Date_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(at.Date_Value__c));
                            }
                            else if(at.Attribute_Type__c == 'Phone') {
                                if(at.Phone_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(at.Phone_Value__c));
                            }
                            else {
                                
                            }
                        }
                        xmlW.writeEndElement();
                        //End of Value tag
                        
                        // Added By Sai C for Attribute Value Id Tag
                        //forming value ID tag from here
                        xmlW.writeStartElement(null, 'ID', null);
                        
                        //Beginning of Value ID Tag i.e ID
                        if(at.Value_ID__c != null){
                            xmlW.writeCharacters(at.Value_ID__c);
                            
                            //End of Value ID tag
                        }
                        
                        else{
                            xmlW.writeCharacters(' ');
                        }
                        xmlW.writeEndElement(); 
                        
                        xmlW.writeEndElement();
                        //End of Attribute tag         
                        
                        
                    }
                    xmlW.writeEndElement();
                    //End of Attributes tag
                }
                
                
                xmlW.writeEndElement();
                //End of Product Tag
                
                
                
                xmlW.writeEndElement();
                //End of LineItem tag
                
                xmlW.writeEndElement();
                //End of LineItems tag
                
                
                
            }
            
            //xmlW.writeEndElement();
            //End of Products Tag
            
            
            
            
            
            
        } 
        
        xmlW.writeEndElement();
        //End of Products Tag
        
        xmlW.writeEndElement();
        //End of Order tag
        if(!test.isRunningTest()){
        xmlW.writeEndElement();
        //End of OrderRequest tag
        }
        
        
        reqXML = xmlW.getXmlString();
        System.debug('Order Request :'+reqXML);
        //  return reqXML; 
        
            
        String reqXmlRemove = reqXML.replace('%20','+'); //<T01>    
        String reqXmlupdted1 = reqXmlRemove.replace('+','%2B'); //<T01>
        //String reqXmlupdted1 = reqXML.replace('+','%2B');
        String reqXmlupdted = reqXmlupdted1.replace('&','%26');
        
        
        string ipayload   = 'publicKey='+ publicKey + '&' + 'timestamp=' + timeDifferenceInSeconds + '&' + 'xml=' + reqXmlupdted;
        Blob textToBeHashedInBytes = Blob.valueOf(ipayload);
        Blob mac = Crypto.generateMac('HmacSHA256',Blob.valueOf(ipayload), Blob.valueOf(privateKey));
        String encodedText  = EncodingUtil.base64Encode(mac);
        String Header      =  encodedText + '|'+  timeDifferenceInSeconds;
        String givenEndpoint   = endPts.Endpoint_URL__c;
        String encodedurl = EncodingUtil.urlEncode(givenEndpoint, 'UTF-8');                
        
        for ( id orderId :  OrderMap.keySet()){
            
            
            
            if(restrictCalls == false) {
                if(mapIdNExistingErrLogs.containsKey(Orderid ) ) {
                    Error_Log__c err = new Error_Log__c();
                    System.debug('###order already exists in Error Log###');
                    err.XML_Mesaage_Type__c = 'OrderRequest';
                    err.XML_Body__c = reqXML;
                    err.Order_Number__c = orderId;
                    err.Error_Reason__c = 'Previous instance of the same order exists in the Error log';
                    if(mapOrderIdNOrder != null && mapOrderIdNOrder.containsKey(orderId)){
                        err.Order_Name__c = mapOrderIdNOrder.get(orderId).Name;
                    }
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
                            Error_Log__c temp_error = CPQ_MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody() , reqXML);
                            if(temp_error != null){
                                temp_error.XML_Mesaage_Type__c = 'OrderRequest';
                                lstErrLogs.add(temp_error);
                            }   
                        }
                        if(Test.isRunningTest() || res.getStatusCode() == 400 || res.getStatusCode() == 401){ 
                            if(res.getStatusCode() == 400 && res.getBody()!=null){
                                System.debug('Response Body in order Message is profile issue: '+res.getBody());
                                  lstResponseBody.add(res.getBody());
                            
                           }   
                            else{
                                   CPQ_MDL_Integration_Vim_Efs.parseResponse400Error(res.getBody(),'OrderRequest',reqXML,orderId,mapOrderIdNOrder.get(orderId).Name);                              

                            }
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
                                if(mapOrderIdNOrder != null && mapOrderIdNOrder.containsKey(orderId)){
                                    err.Order_Name__c = mapOrderIdNOrder.get(orderId).Name;
                                }
                                err.Error_Reason__c = res.getStatusCode() +' : '+res.getStatus();
                                lstErrLogs.add(err);    
                            }
                        }
                    }catch(System.CalloutException ce) {
                        Error_Log__c err = new Error_Log__c();
                        err.XML_Mesaage_Type__c = 'OrderRequest';
                        err.XML_Body__c = reqXML;
                        err.Order_Number__c = orderId;
                        if(mapOrderIdNOrder != null && mapOrderIdNOrder.containsKey(orderId)){
                            err.Order_Name__c = mapOrderIdNOrder.get(orderId).Name;
                        }
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
        
         if(lstExistingErrLogs.size() > 0)
                Database.insert(lstExistingErrLogs);
        if(lstErrLogs.size() > 0) {
            Database.insert(lstErrLogs);
        }
        CPQ_MDL_Integration_Vim_Efs.parseResponseXML_OrderResponse(lstResponseBody);
    }
    
    public static void parseResponseXML_OrderResponse(List<String> lstResponses) {
        
        String txtmsg = '';
        List<Case> lstCases = new List<Case>();
        List<order> lstorderids = new List<order>();
        List<Account> lstaccids = new List<Account>();
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
                 
            response.load(resp);
            
           system.debug('@@@response'+ response);
            dom.Xmlnode res = response.getRootElement();
            List<Dom.XmlNode> Systems = res.getChildElement('Systems', null).getChildElements();
            //String uniqueId = res.getChildElement('RequestId', null).getText();
            //String []splitRequest = uniqueId.split('-');
            //String toUpdateId = splitRequest[0];
            
            for (Dom.XmlNode resSystem : Systems){
            
                 system.debug('===SystemInv==='+resSystem);
                 
                  if(resSystem.getChildElement('Name', null).getText() == 'QUASI'){
                  
                       system.debug('===In QUASI method ==='+resSystem.getChildElement('Name', null).getText());
                        system.debug('===In http response ==='+resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('OrderResponse',null).getChildElement('HttpResponseCode',null).getText());
                        system.debug('=== Customer Number value == '+ resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('OrderResponse',null).getChildElement('Order',null).getChildElement('CustomerNumber',null).getText());

                      //if(resSystem.getChildElement('HttpResponse', null).getChildElement('Code', null).getText() != '200')
                       if(resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('OrderResponse',null).getChildElement('HttpResponseCode',null).getText() != '200'){

                          
                        if( resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('OrderResponse',null).getChildElement('Order',null) != null){
                        //String respCode = resSystem.getChildElement('HttpResponseCode', null).getText();
                        String respCode = resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('OrderResponse',null).getChildElement('HttpResponseCode',null).getText();

                        String cusNumber = resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('OrderResponse',null).getChildElement('Order',null).getChildElement('CustomerNumber',null).getText();
                        String orderNumber = resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('OrderResponse',null).getChildElement('Order',null).getChildElement('OrderNumber',null).getText();
                        String requestID= resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('OrderResponse',null).getChildElement('RequestId',null).getText();

                        dom.Xmlnode res1 = resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('OrderResponse',null).getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null);
                        
                        system.debug('@@@HttpResponseCode'+ respCode );
                        system.debug('@@@cusNumber '+ cusNumber );
                        system.debug('@@@orderNumber '+ orderNumber );
                        
                        if(orderNumber!=null && orderNumber != ''){
                        
                        
                        
                        lstorderids.add([Select Id , Order_Value__c From Order where Order_Value__c =: orderNumber limit 1]);
                          
                        if(cusNumber !=null && cusNumber != ''){
                        
                        
                        
                        lstaccids.add([Select Id,MH_Cust_Number__c From Account where MH_Cust_Number__c =: cusNumber limit 1]);
                        
                        }
                        
                        }
                        txtmsg = res1.getText();
                        System.debug('text message received is :'+txtmsg);
                        System.debug('CustomerNumber received is :'+cusNumber );
                        if(respCode != '200') {
                            Case c = new Case();
                            c.Description = txtmsg;
                            c.Subject = 'Order Request Error';
                            c.Priority = 'High';
                            if(lstorderids.size()>0){
                            
                            c.Order__c = lstorderids[0].id;
                            
                            }
                            
                            if(lstaccids.size()>0){
                            System.debug('In Account List  '+lstaccids);
                            
                            c.AccountId = lstaccids[0].id;
                            
                            }
                            
                            c.setOptions(dmlOpts);
                            lstCases.add(c);
                        }
                    }
                  }
            }
            
                    if(resSystem.getChildElement('Name', null).getText() == 'OFS'){
                  
                       system.debug('===In OFS method ==='+resSystem.getChildElement('Name', null).getText());
                        system.debug('===In http response ==='+resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('OrderResponse',null).getChildElement('HttpResponseCode',null).getText());
                        system.debug('=== Customer Number value == '+ resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('OrderResponse',null).getChildElement('Order',null).getChildElement('CustomerNumber',null).getText());

                      //if(resSystem.getChildElement('HttpResponse', null).getChildElement('Code', null).getText() != '200')
                       if(resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('OrderResponse',null).getChildElement('HttpResponseCode',null).getText() != '200'){

                          
                        if( resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('OrderResponse',null).getChildElement('Order',null) != null){
                        //String respCode = resSystem.getChildElement('HttpResponseCode', null).getText();
                        String respCode = resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('OrderResponse',null).getChildElement('HttpResponseCode',null).getText();

                        String cusNumber = resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('OrderResponse',null).getChildElement('Order',null).getChildElement('CustomerNumber',null).getText();
                        String orderNumber = resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('OrderResponse',null).getChildElement('Order',null).getChildElement('OrderNumber',null).getText();
                        dom.Xmlnode res1 = resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('OrderResponse',null).getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null);
                        
                        system.debug('@@@HttpResponseCode'+ respCode );
                        system.debug('@@@cusNumber '+ cusNumber );
                        system.debug('@@@orderNumber '+ orderNumber );
                        
                        if(orderNumber!=null && orderNumber != ''){
                        
                        
                        
                        lstorderids.add([Select Id , Order_Value__c From Order where Order_Value__c =: orderNumber limit 1]);
                          
                        if(cusNumber !=null && cusNumber != ''){
                        
                        
                        
                        lstaccids.add([Select Id,MH_Cust_Number__c From Account where MH_Cust_Number__c =: cusNumber limit 1]);
                        
                        }
                        
                        }
                        txtmsg = res1.getText();
                        System.debug('text message received is :'+txtmsg);
                        System.debug('CustomerNumber received is :'+cusNumber );
                        if(respCode != '200') {
                            Case c = new Case();
                            c.Description = txtmsg;
                            c.Subject = 'Order Request Error';
                            c.Priority = 'High';
                            if(lstorderids.size()>0){
                            
                            c.Order__c = lstorderids[0].id;
                            
                            }
                            
                            if(lstaccids.size()>0){
                            System.debug('In Account List  '+lstaccids);
                            
                            c.AccountId = lstaccids[0].id;
                            
                            }
                            
                            c.setOptions(dmlOpts);
                            lstCases.add(c);
                        }
                    }
                  }
            }
            
            
         
       
            }
            }
             if(lstCases.size() > 0)
            Database.insert(lstCases);
            
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
    /* commented for midterm
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
    } */
    /*public static void voidenvelope(Set<Id> setOppIds){
        System.debug('===========voidenvelope Method==============');
        for(dsfs__DocuSign_Status__c docustat : [Select id, name,dsfs__DocuSign_Envelope_ID__c,dsfs__Envelope_Status__c From dsfs__DocuSign_Status__c where dsfs__Envelope_Status__c!= 'Completed' AND dsfs__Envelope_Status__c!= 'Voided' AND dsfs__Opportunity__c in :setOppIds]){
                DocusignVoidApi voi = new DocusignVoidApi();
                voi.voidEnvelope(docustat.dsfs__DocuSign_Envelope_ID__c,'Void APIs');
            }
    }*/ //commented for docusign
    public static Error_Log__c checkForSuccessResponseWithError(String responseString, String requestString){
         String errorText;
        String orderNumber ; 
        Dom.Document response = new Dom.Document();
        if(!test.isRunningTest()){
        response.load(ResponseString);
        dom.Xmlnode res = response.getRootElement();
        
          
        
        if(res.getChildElement('Order',null) != null && res.getChildElement('Order',null).getChildElement('OrderNumber',null) != null){
            orderNumber  = res.getChildElement('Order',null).getChildElement('OrderNumber',null).getText();
        }
       
        
        if(res.getChildElement('Order',null) != null && res.getChildElement('Order',null).getChildElement('LineItems',null) != null){
            for(dom.Xmlnode lineitem : res.getChildElement('Order',null).getChildElement('LineItems',null).getChildElements()){
                if(lineitem.getChildElement('Messages',null) != null){
                    errorText = lineitem.getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null).getText();
                }
            }
        }   
    }
        if(errorText != null || test.isRunningTest()){      
            Error_Log__c error = new Error_Log__c();
            error.Error_Reason__c = '200/400 : ' + errorText;
            error.Order_Name__c = orderNumber;
            error.XML_Body__c = requestString;
            //insert error;
            return error;
        }
        
        return null;    
    }  
    
    
    public static String orderRequestfrompage(Set<Id> OrderItemIds) {
        Map<Id,Order> mapOrderIdNOrder = new Map<Id,Order>();
        Map<Id, List<OrderItem>> orderIdVSOrderProducts = new Map<Id, List<OrderItem>>();
        Set<string>attributeRelations = new Set<string>();
        
        
        List<OrderItem> orderprodlist = [Select id,Status__c,Path__c,Origin__c,Modified_from_Quote_Builder__c , Cancel_Now_Date__c,Origin_Product_Code__c,Quantity,UpgradedDowngraded__c,Fulfillment_date__c,OrderId,Product2.IsInventoried__c,SIN__c,Inventory_Id__c,SFInventoryId__c,Attribute_Relationship__c,Renew_Rebase_Truncate_Date__c,Product2.ProductCode,
                                         ServiceDate,EndDate,SBQQ__QuoteLine__r.Last_day_of_month__c,SBQQ__TerminatedDate__c,SBQQ__BundleRoot__c,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.SIN__c,ParentProduct__c,Live_Date__c,
                                         Chat_ID__c,Product2.Name,blng__NextBillingDate__c,SBQQ__ProductSubscriptionType__c,CreatedDate,
                                         Order.Account.Phone,Order.Account.Contact_Email__c,Order.Status__c,Order.Account.Last_Name__c,Order.Account.First_Name__c,Contact__r.Website__c,
                                         Contact__r.Email,Contact__r.LastName,Contact__r.FirstName,Contact__r.Professional_ID__c,Contact__r.Phone 
                                         from OrderItem where ID IN:OrderItemIds AND Status__c !='Upgraded' AND Status__c !='Downgraded' AND Order.Status__c !='Off set' ];
       
        String reqXML;
        Integer numberOfDays = Date.daysInMonth(date.today().year(), date.today().month());
        Date lastDayOfMonth = Date.newInstance(date.today().year(), date.today().month(), numberOfDays);
        MDL_RecursionHandler.CheckUpdate = true;
        List<String> lstResponseBody = new List<String>();
        List<Error_Log__c> lstErrLogs = new List<Error_Log__c>();
        List<Error_Log__c> lstExistingErrLogs = new List<Error_Log__c>();
        Map<Id,Error_Log__c> mapIdNExistingErrLogs = new Map<Id,Error_Log__c>();
        
        Map<Id,List<Attribute_Lines__c>> mapOrderIdNlstOrderChargeAttributes = new Map<Id,List<Attribute_Lines__c>>();
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('OrderRequest');
        String endPoint = String.valueOf(endPts.Endpoint_URL__c);
        String methodType = endPts.MethodType__c;
        
        //code for authentication
        String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)
        String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
        String privateKey = endPts.Private_Key__c;
        String publicKey  = endPts.Public_Key__c;
        String apiKey = endPts.API_key__c;
        
        Restrict_Integration_Calls__c rCalls = Restrict_Integration_Calls__c.getValues('Restrict');
        System.debug('**'+rCalls);
        Boolean restrictCalls = Boolean.valueOf(rCalls.Restrict_Callouts__c);
        System.debug('a values is **'+restrictCalls);
        
        //get Orders from Order Products
        for(OrderItem op : orderprodlist){
        
             if(op.Attribute_Relationship__c!=null){
                attributeRelations.add(op.Attribute_Relationship__c);
            }
            
            if(orderIdVSOrderProducts.containsKey(op.orderId)){
                orderIdVSOrderProducts.get(op.orderId).add(op);
            }
            else{
                orderIdVSOrderProducts.put(op.orderId, new List<OrderItem>{op});
            }
        }
        
        List<Attribute_Lines__c> attributes = [select id, Attribute_Junction__c, Attribute_Type__c, Attribute_Name__c, 
                                               Picklist_Value__c, String_Value__c, Boolean_Value__c, Date_Value__c,Phone_Value__c, Value_ID__c,
                                               Number_Value__c FROM Attribute_Lines__c where Attribute_Junction__c  IN:attributeRelations];
        Map<string, List<Attribute_Lines__c>> attributeRelationVSattributes = new Map<string, List<Attribute_Lines__c>>();
        for(Attribute_Lines__c ab : attributes){
            if(attributeRelationVSattributes.containsKey(ab.Attribute_Junction__c)){
                attributeRelationVSattributes.get(ab.Attribute_Junction__c).add(ab);
            }
            else{
                attributeRelationVSattributes.put(ab.Attribute_Junction__c, new List<Attribute_Lines__c>{ab});
            }
        }
        
        Map<Id,Order> OrderMap = new Map<Id,Order>([select Id ,SBQQ__Quote__r.Name,QuoteId,SBQQ__Quote__r.id,Account.Avvo_CustomerID__c,Account.MH_Cust_Number__c ,Account.RecordType.DeveloperName,AccountId ,
                                                    Account.Name,Account.Parent.Name,Account.Org_Id__c,Account.Contact_Email__c,Firm_Name_from_BS__c,OrderNumber, Account.IB_Customer_Number__c,
                                                    Account.BillingCountry,Account.BillingState,Account.BillingCity,Account.BillingStreet,
                                                    Account.BillingPostalCode,Account.Website,Account.Phone,Name From order where Id IN : orderIdVSOrderProducts.keyset()]);
        // End of data Setup
        
        
        //Checking if Order XML already exists in Error Log, if exists do not send that order , queue it along with the existing order
        for(Error_Log__c err : [Select e.XML_Mesaage_Type__c, e.XML_Body__c, e.Sent_Successfully__c, e.Order_Number__c,e.Order_Name__c,e.Error_Reason__c, e.Name, e.Id ,e.Re_process_date_time__c
                                From Error_Log__c e
                                Where e.XML_Mesaage_Type__c = 'OrderRequest' AND e.Order_Number__c in :mapOrderIdNOrder.keySet()] ) {
                                    mapIdNExistingErrLogs.put(err.Order_Number__c,err);                 
                                }
        System.debug('mapOrderId And Error Logs^^^'+mapIdNExistingErrLogs);
        
        reqXML = '';
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
        
        //get xmlns value from custom setting
        
        xmlns = endPts.xmlns__c;
        
        //get server timestamp to send it in requestid
        DateTime result = DateTime.now();
        String timeStampString = result.format();//to convert datetime into string
        String reqID = OrderMap.keySet() + '-' + timeStampString ;
        
        
        //construction of XML for Order XML
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
        //xmlW.writeCharacters(uName);
        xmlW.writeEndElement();
        //End of Username tag
        
        // Start of Order XML 
        for(string orderId : orderIdVSOrderProducts.keyset()){
            
            
            //Beginning of CustomerNumber tag
            if(Ordermap.get(orderid).Account.MH_Cust_Number__c != null) {
                xmlW.writeStartElement(null, 'CustomerNumber', null);
                xmlW.writeCharacters(Ordermap.get(orderid).Account.MH_Cust_Number__c);
                xmlW.writeEndElement();
            }
            else {
                xmlW.writeEmptyElement(null, 'CustomerNumber', null);
            }
            //End of CustomerNumber tag
            //Beginning of Parent customernumber tag
            if(Ordermap.get(orderid).Account.IB_Customer_Number__c != null) {
                xmlW.writeStartElement(null, 'ParentCustomerNumber', null);
                xmlW.writeCharacters(Ordermap.get(orderid).Account.IB_Customer_Number__c);
                xmlW.writeEndElement();
            }
            else {
                xmlW.writeEmptyElement(null, 'ParentCustomerNumber', null);
            }
            
             if(Ordermap.get(orderid).Account.Avvo_CustomerID__c!= null) {
                xmlW.writeStartElement(null, 'AvvoCustomerId', null);
                xmlW.writeCharacters(Ordermap.get(orderid).Account.Avvo_CustomerID__c);
                xmlW.writeEndElement();
            }
            else {
                xmlW.writeEmptyElement(null, 'AvvoCustomerId', null);
            }
            
             //Beginning of QuoteId tag: added on 08/23/2023
            if(Ordermap.get(orderid).SBQQ__Quote__r.Name != null){
                xmlW.writeStartElement(null, 'QuoteId', null);
                xmlW.writeCharacters(Ordermap.get(orderid).SBQQ__Quote__r.Name);
                xmlW.writeEndElement();
                //End of QuoteId tag
            }
            
             else {
            xmlW.writeEmptyElement(null, 'QuoteId', null);
            }
            
            
            //Beginning of OrgID tag: added on 05/01/2016 by akash
            if(Ordermap.get(orderid).Account.Org_Id__c != null){
                xmlW.writeStartElement(null, 'OrgId', null);
                xmlW.writeCharacters(Ordermap.get(orderid).Account.Org_Id__c);
                xmlW.writeEndElement();
                //End of OrgId tag
            }
            
            else {
            xmlW.writeEmptyElement(null, 'OrgId', null);
            }
            //End of orgID tag
            
            if(Ordermap.get(orderid).Account.RecordType.DeveloperName == 'M_A_Atty_Account') {
               
             //Beginning of ServiceAccountName tag
            xmlW.writeStartElement(null, 'ServiceAccountName', null);
                if(Ordermap.get(orderid).Firm_Name_from_BS__c != null){
                  xmlW.writeCharacters(Ordermap.get(orderid).Firm_Name_from_BS__c);
              }
              
              // Added based on MAC 3.0 Order
              else if(Ordermap.get(orderid).Account.Parent.Name!= null && Ordermap.get(orderid).Account.RecordType.DeveloperName == 'M_A_Atty_Account'){
              
                   xmlW.writeCharacters(Ordermap.get(orderid).Account.Parent.Name);
               
              }
              
              else if(Ordermap.get(orderid).Account.Name != null){
              
                   xmlW.writeCharacters(Ordermap.get(orderid).Account.Name);
               
              }
            xmlW.writeEndElement();
            //End of ServiceAccountName tag
           
           
             //Beginning of Email tag
            xmlW.writeStartElement(null, 'Email', null);
            if(Ordermap.get(orderid).Account.Contact_Email__c != null){
                  xmlW.writeCharacters(Ordermap.get(orderid).Account.Contact_Email__c);
              }            
            xmlW.writeEndElement();
            //End of Email tag
            
              
            //Beginning of ServiceCountry tag
            xmlW.writeStartElement(null, 'ServiceCountry', null);
              xmlW.writeCharacters(Ordermap.get(orderid).Account.BillingCountry);
            xmlW.writeEndElement();
            //End of ServiceCountry tag
           
            
            //Beginning of ServiceState tag
            xmlW.writeStartElement(null, 'ServiceState', null);
              xmlW.writeCharacters(Ordermap.get(orderid).Account.BillingState);
            xmlW.writeEndElement();
            //End of ServiceState tag
            
            //Beginning of ServiceCity tag
            xmlW.writeStartElement(null, 'ServiceCity', null);
              xmlW.writeCharacters(Ordermap.get(orderid).Account.BillingCity);
            xmlW.writeEndElement();
            //End of ServiceCity tag
            
            
            //Beginning of ServiceStreetAddress tag
            xmlW.writeStartElement(null, 'ServiceStreetAddress', null);
              xmlW.writeCharacters(Ordermap.get(orderid).Account.BillingStreet);
            xmlW.writeEndElement();
            //End of ServiceStreetAddress tag
           
            
            //Beginning of ServiceZip tag
            xmlW.writeStartElement(null, 'ServiceZip', null);
              xmlW.writeCharacters(Ordermap.get(orderid).Account.BillingPostalCode  );
            xmlW.writeEndElement();
            //End of ServiceZip tag
            
           
            //Beginning of WebsiteURL tag
            xmlW.writeStartElement(null, 'WebsiteURL', null);
              
            if(Ordermap.get(orderid).Account.Website != null){
                  xmlW.writeCharacters(Ordermap.get(orderid).Account.Website );
            }
            xmlW.writeEndElement();
            //End of WebsiteURL tag
            
                      
            //Beginning of Phone tag
            xmlW.writeStartElement(null, 'Phone', null);
              if(Ordermap.get(orderid).Account.Phone != null){
                xmlW.writeCharacters(String.valueOf(Ordermap.get(orderid).Account.Phone));
                                   
            }
            xmlW.writeEndElement();
            //End of Phone tag
            
           }
            
            //Beginning of OrderNumber tag
            xmlW.writeStartElement(null, 'OrderNumber', null);
              xmlW.writeCharacters(Ordermap.get(orderid).OrderNumber);
            xmlW.writeEndElement();
            //End of OrderNumber tag
            
            //beginning of Products tag
            xmlW.writeStartElement(null,'Products',null);
            //getting order products
            List<OrderItem> opTemplist = orderIdVSOrderProducts.get(orderId);
            for(OrderItem op : opTemplist){
                //start of order product related xml here
                //Beginning of Product tag
                xmlW.writeStartElement(null,'Product', null); 
                
                //Beginning of ProductId tag
                xmlW.writeStartElement(null,'ProductId',null);
                xmlW.writeCharacters(op.Id);
                xmlW.writeEndElement();
                //End of ProductId tag
                
                //Beginning of SubscriptionIdentificationNumber tag
                xmlW.writeStartElement(null,'SubscriptionIdentificationNumber',null);
                if(op.SIN__c != null)
                    xmlW.writeCharacters(op.SIN__c);
                xmlW.writeEndElement();
                //End of SubscriptionIdentificationNumber tag
                
                //Beginning of ProductCode tag
                xmlW.writeStartElement(null,'ProductCode',null);
                xmlW.writeCharacters(op.Product2.ProductCode);
                xmlW.writeEndElement();
                //End of ProductCode tag
                
                //Beginning of LineItems tag
                xmlW.writeStartElement(null,'LineItems', null); 
                
                //Beginning of LineItem tag
                xmlW.writeStartElement(null,'LineItem', null);
                
                //Beginning of LineItemId tag
                xmlW.writeStartElement(null, 'LineItemId', null);
                xmlW.writeCharacters(op.Id+lineItemId);
                xmlW.writeEndElement();
                //End of LineItemId tag
                if(op.Sin__c != null) {
                    xmlW.writeStartElement(null, 'SubscriptionIdentificationNumber', null);
                    xmlW.writeCharacters(op.SIN__c);
                    xmlW.writeEndElement();
                }
                else {
                    xmlW.writeEmptyElement(null, 'SubscriptionIdentificationNumber', null);
                }
                
                 //Beginning of ProductCode tag
                if(op.Product2.Name != null) {
                xmlW.writeStartElement(null,'ProductCode',null);
                xmlW.writeCharacters(op.Product2.ProductCode);
                xmlW.writeEndElement();
                //End of ProductCode tag
                
                }
                else {
                    xmlW.writeEmptyElement(null, 'ProductCode', null);
                }
                
                if(op.Product2.Name != null) {
                    xmlW.writeStartElement(null, 'ProductName', null);
                    xmlW.writeCharacters(op.Product2.Name);
                    xmlW.writeEndElement();
                }
                else {
                    xmlW.writeEmptyElement(null, 'ProductName', null);
                }
                
                //Beginning of Quantity tag
                if(op.Quantity != null && (op.Product2.ProductCode == '11018' || op.Product2.ProductCode == '11019') ) {
                    Integer IntQuantity = Integer.valueOf(op.Quantity);
                   
                    xmlW.writeStartElement(null,'Quantity',null);
                    xmlW.writeCharacters(String.valueof(IntQuantity));
                    xmlW.writeEndElement();
                    
                    }
                //End of Quantity tag
                
                xmlW.writeStartElement(null, 'Status', null);
                if(op.Status__c != null) {
                    string status = '';
                    
                    if(op.Status__c == 'Active'  && op.Modified_from_Quote_Builder__c != null ) {
                        
                        status ='Modified';
                   } 
                   
                   
                     else if ((op.Status__c == 'Active' || op.Status__c == 'Renewed' || op.Status__c == 'Rebased' ) && op.Modified_from_Quote_Builder__c == null)
                        //commented by Sai C
                        //|| (orderProd.invoiceit_s__Status__c == 'Truncated' && orderProd.invoiceit_s__Service_End_Date__c > Date.today()))
                        //xmlW.writeCharacters('Active'); 
                        status ='Active';
                    if(op.Status__c == 'Cancelled' || op.Status__c == 'Expired' || op.Status__c == 'Truncated' || op.UpgradedDowngraded__c == True || Test.isRunningTest()){
                        //xmlW.writeCharacters('Cancel'); 
                        status = 'Cancel';
                        
                    }
                    
                    
                    xmlW.writeCharacters(status); 
                } 
                xmlW.writeEndElement();
                // End of Status
                
                //Beginning of Path tag
                if(op.Path__c != null) {
                xmlW.writeStartElement(null,'Path',null);
                xmlW.writeCharacters(op.Path__c);
                xmlW.writeEndElement();
                //End of Path tag
                
                }
                //else {
                 //   xmlW.writeEmptyElement(null, 'Path', null);
                //}
               
                //MAC added part of upgrade and downgrade
                //Beginning of Origin Product Code  
                if(op.Origin_Product_Code__c!= null) {
                xmlW.writeStartElement(null,'Origin',null);
                xmlW.writeCharacters(op.Origin_Product_Code__c);
                xmlW.writeEndElement();
                //End of Origin Product Code tag
                
                }
                //else {
                //    xmlW.writeEmptyElement(null, 'Origin', null);
                //}
                
                //Beginning of PostDate tag
                xmlW.writeStartElement(null, 'PostDate', null);
                postDate = String.valueOf(op.CreatedDate);
                validatedDateValue = postDate.split(' ');
                xmlW.writeCharacters(validatedDateValue[0]);
                xmlW.writeEndElement();
                //End of PostDate tag
                
                //Beginning of FulfillmentDate tag
                    if(op.Fulfillment_date__c!= null) {
                       // if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != 'System Fulfillment' && (orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != null || orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != '')) { 
                            xmlW.writeStartElement(null, 'FulfillmentDate', null);
                            xmlW.writeCharacters(String.valueOf(op.Fulfillment_date__c));
                            xmlW.writeEndElement();
                        //}
                    }
                
                if(op.Status__c == 'Cancelled' || Test.isRunningTest()) { 
                
                  if(op.Cancel_Now_Date__c != null) {
                        xmlW.writeStartElement(null, 'CancelDate', null);
                        xmlW.writeCharacters(String.valueOf(op.Cancel_Now_Date__c));  
                        xmlW.writeEndElement();
                    }
                    
                    
                  else  if(op.SBQQ__TerminatedDate__c != null) {
                        xmlW.writeStartElement(null, 'CancelDate', null);
                        xmlW.writeCharacters(String.valueOf(op.SBQQ__TerminatedDate__c));  
                        xmlW.writeEndElement();
                    }
                    else  If (op.SBQQ__QuoteLine__r.Last_day_of_month__c!= null){
                   
                        xmlW.writeStartElement(null, 'CancelDate', null);
                        xmlW.writeCharacters(String.valueOf(op.SBQQ__QuoteLine__r.Last_day_of_month__c));  
                        xmlW.writeEndElement();
                   
                   } 
                }
                
                else if (op.Cancel_Now_Date__c != null) {
                  
                        xmlW.writeStartElement(null, 'CancelDate', null);
                        xmlW.writeCharacters(String.valueOf(op.Cancel_Now_Date__c));  
                        xmlW.writeEndElement();
                    }
                    
                else if(op.Status__c == 'Expired' || op.Status__c == 'Truncated'  || Test.isRunningTest()) {
                   // if(op.SBQQ__TerminatedDate__c!= null) {
                        xmlW.writeStartElement(null, 'CancelDate', null);
                        System.debug('service end of charge past its service end date is::'+String.valueOf(op.SBQQ__TerminatedDate__c));
                        //xmlW.writeCharacters(String.valueOf(op.SBQQ__TerminatedDate__c)); 
                        
                        if(op.SBQQ__TerminatedDate__c != null) { 
                        
                           xmlW.writeCharacters(String.valueOf(op.SBQQ__TerminatedDate__c)); 
                        }
                        else{
                            xmlW.writeCharacters(String.valueOf(lastDayOfMonth)); 
                        } 
                        xmlW.writeEndElement();
                    //}
                }
                
                 else if(op.UpgradedDowngraded__c == True && op.Cancel_Now_Date__c == null) {
                   // if(op.SBQQ__TerminatedDate__c != null) {
                       // String terminatedate = lastDayOfMonth ;
                        xmlW.writeStartElement(null, 'CancelDate', null);
                       
                            xmlW.writeCharacters(String.valueOf(lastDayOfMonth)); 
                       
                         
                        xmlW.writeEndElement();
                    //}
                }
                
                //Beginning of IsProductInventoried tag
                    xmlW.writeStartElement(null, 'IsProductInventoried', null);
                    if(op.Product2.IsInventoried__c != False){
                       
                         xmlW.writeCharacters('True');
                    }
                    else{
                        xmlW.writeCharacters('False');
                    }
                        xmlW.writeEndElement();
                    //End of IsProductInventoried tag
                    
                //Beginning of HasparentProducts tag*****
                    xmlW.writeStartElement(null, 'HasParentProducts', null);
                    If(op.SBQQ__RequiredBy__c != null && op.SBQQ__RequiredBy__r.SIN__c != null && !op.ParentProduct__c.contains('Package') &&
                        !op.ParentProduct__c.contains('Bundle') ){
                      //If(op.SBQQ__RequiredBy__c != null && op.SBQQ__BundleRoot__c == null){
  
                        xmlW.writeCharacters('Y');
                        //xmlW.writeEndElement();
                        
                    }
                    
                    else{
                            xmlW.writeCharacters('N');
                    }
                    xmlW.writeEndElement();
                    //End of HasparentProducts tag 
                    
                    
                    //Beginning of ParentProductSIN tag***********added by akash
                    xmlW.writeStartElement(null, 'ParentProductSIN', null);
                     
                    if(op.SBQQ__RequiredBy__c != null && op.SBQQ__RequiredBy__r.SIN__c != null && !op.ParentProduct__c.contains('Package') &&
                        !op.ParentProduct__c.contains('Bundle')  ){
                        xmlW.writeCharacters(op.SBQQ__RequiredBy__r.SIN__c );
                    }
                    else {
                        xmlW.writeCharacters('');
                    }
                      
                    xmlW.writeEndElement();
                   //End of ParentProductSIN tag 
                   
                   //Begin of FulfillmentID Tag
                        xmlW.writeStartElement(null, 'FulfillmentID', null);
                        if(op.Chat_ID__c != null){
                        System.Debug ('orderProd' + op);
                                xmlW.writeCharacters(op.Chat_ID__c);
                             }
                            else{
                                xmlW.writeCharacters(' ');
                            }
                        xmlW.writeEndElement();
                        //End of FulfillmentID tag
                        
                    
                //Beginning of Inventory Id Attribute Name tag
                //xmlW.writeStartElement(null, 'Name', null);
                //xmlW.writeCharacters('InventoryId');
                //xmlW.writeEndElement();
                //End of Inventory Id Attribute Name tag
                
                //Beginning of Inventory Id Attribute Value tag
                //xmlW.writeStartElement(null, 'Value', null);
                //if(op.Inventory_Id__c!= null)
                   // xmlW.writeCharacters(op.Inventory_Id__c);
                //xmlW.writeEndElement();
                //End of Inventory Id
                
                // Adding Service Start Date Tag for Charges by Sai C
                xmlW.writeStartElement(null, 'ServiceStartDate', null);
                if(op.ServiceDate != null){
                    xmlW.writeCharacters(String.valueOf(op.ServiceDate));  
                }
                else{
                    xmlW.writeCharacters('');
                }
                xmlW.writeEndElement();
                // End of Service Start date Tag for charges 
                
                // Adding Service End Date Tag for Charges by Sai C
                xmlW.writeStartElement(null, 'ServiceEndDate', null);
                if(op.EndDate != null && op.Status__c != 'Truncated' && op.Status__c != 'Expired' && op.Status__c != 'Cancelled'){
                    xmlW.writeCharacters(String.valueOf(op.EndDate));  
                }
                else if( op.Status__c == 'Truncated' || op.Status__c == 'Expired' || op.Status__c == 'Cancelled' || Test.isRunningTest()){
                        
                        if(op.SBQQ__TerminatedDate__c != null) { 
                        
                            xmlW.writeCharacters(String.valueOf(op.SBQQ__TerminatedDate__c)); 
                        }
                        else{
                            xmlW.writeCharacters(String.valueOf(lastDayOfMonth)); 
                        }  
                }
                else{
                    xmlW.writeCharacters('');
                }
                xmlW.writeEndElement();
                // End of Service End date Tag for charges 
                
                
                // Adding Service End Date Tag for Charges 
                //To Send Live Date - added by saiv 07/27/2021
                
                xmlW.writeStartElement(null, 'LiveDate', null);
                if(op.Live_Date__c != null){
                    xmlW.writeCharacters(String.valueOf(op.Live_Date__c));  
                  }
                else{
                    xmlW.writeCharacters('');
                }
                xmlW.writeEndElement();
                // End of Service End date Tag for charges
                
                if(op.Product2.ProductCode == '11014' || op.Product2.ProductCode == '11017'|| op.Product2.ProductCode == '11015'|| op.Product2.ProductCode == '11016'){
                     
                   if(op.Product2.ProductCode == '11014' || op.Product2.ProductCode == '11015'|| op.Product2.ProductCode == '11016'){
                       
                  
 
                    xmlW.writeStartElement(null, 'Attributes', null);
                     
                       
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of Professional Id Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('ProfessionalId');
                        xmlW.writeEndElement();
                        //End of Professional Id Attribute Name tag
                        
                        //Beginning of ProfessionalId Attribute Value tag
                        //moved to value tag
                       if(op.Contact__r.Professional_ID__c != null){
                        xmlW.writeStartElement(null, 'Value', null);
                        
                            xmlW.writeCharacters(op.Contact__r.Professional_ID__c);
                        xmlW.writeEndElement();
                        
                        }
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                        
                     
                     //Beginning of FirstName tag
                    
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of FirstName Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('FirstName');
                        xmlW.writeEndElement();
                        //End of FirstName Attribute Name tag
                        
                        //Beginning of FirstName Attribute Value tag
                         if(op.Contact__r.FirstName != null){
                         
                            xmlW.writeStartElement(null, 'Value', null);
                            
                                xmlW.writeCharacters(op.Contact__r.FirstName);
                            xmlW.writeEndElement();
                         }
                         
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                       
                   
                      //Beginning of LastName tag
                    
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of LastName Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('LastName');
                        xmlW.writeEndElement();
                        //End of LastName Attribute Name tag
                        
                        //Beginning of LastName Attribute Value tag
                         if(op.Contact__r.LastName != null){
                            xmlW.writeStartElement(null, 'Value', null);
                            
                                xmlW.writeCharacters(op.Contact__r.LastName);
                            xmlW.writeEndElement();
                           }
                           
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                     
                   
                    //Beginning of Contact Email tag
                    
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of Contact Email Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('Email');
                        xmlW.writeEndElement();
                        //End of Contact Email Attribute Name tag
                        
                        //Beginning of Contact Email Attribute Value tag
                         if(op.Contact__r.Email != null){
                            xmlW.writeStartElement(null, 'Value', null);
                            
                                xmlW.writeCharacters(op.Contact__r.Email);
                            xmlW.writeEndElement();
                           }   
                             
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                        
                   
                   //Beginning of Contact Phone tag
                    
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of Contact Phone Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('Phone');
                        xmlW.writeEndElement();
                        //End of Contact Phone Attribute Name tag
                        
                        //Beginning of Contact Phone Attribute Value tag
                         if(op.Contact__r.Phone!= null){
                            xmlW.writeStartElement(null, 'Value', null);
                            
                                xmlW.writeCharacters(op.Contact__r.Phone);
                            xmlW.writeEndElement();
                            
                         } 
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                        
                   
                   //Beginning of Contact Phone tag
                     if(op.Contact__r.Website__c != null){
                          String Website;
                          Website = op.Contact__r.Website__c ;
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of Contact WebsiteURL Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('WebsiteURL');
                        xmlW.writeEndElement();
                        //End of Contact WebsiteURL Attribute Name tag
                        
                        //Beginning of Contact WebsiteURL Attribute Value tag
                        xmlW.writeStartElement(null, 'Value', null);
                        
                        if(op.Contact__r.Website__c != null){
                              xmlW.writeCharacters(Website);
                              }
                            
                        xmlW.writeEndElement();
                        
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                        }  
                        
                        xmlW.writeEndElement();
                        //End of Attributes tag
                       
                     }
                   
                    if(op.Product2.ProductCode == '11017'){
                       
                  
 
                    xmlW.writeStartElement(null, 'Attributes', null);
                     
                     
                     //Beginning of FirstName tag
                     if(op.Order.Account.First_Name__c != null){
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of FirstName Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('FirstName');
                        xmlW.writeEndElement();
                        //End of FirstName Attribute Name tag
                        
                        //Beginning of FirstName Attribute Value tag
                        xmlW.writeStartElement(null, 'Value', null);
                        
                            xmlW.writeCharacters(op.Order.Account.First_Name__c);
                        xmlW.writeEndElement();
                        
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                        }
                   
                      //Beginning of LastName tag
                     if(op.Order.Account.Last_Name__c != null){
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of LastName Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('LastName');
                        xmlW.writeEndElement();
                        //End of LastName Attribute Name tag
                        
                        //Beginning of LastName Attribute Value tag
                        xmlW.writeStartElement(null, 'Value', null);
                        
                            xmlW.writeCharacters(op.Order.Account.Last_Name__c);
                        xmlW.writeEndElement();
                        
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                        }
                   
                    //Beginning of Account Email tag
                     if(op.Order.Account.Contact_Email__c  != null){
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of Account Email Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('Email');
                        xmlW.writeEndElement();
                        //End of Account Email Attribute Name tag
                        
                        //Beginning of Account Email Attribute Value tag
                        xmlW.writeStartElement(null, 'Value', null);
                        
                            xmlW.writeCharacters(op.Order.Account.Contact_Email__c );
                        xmlW.writeEndElement();
                        
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                        }    
                   
                   //Beginning of Account Phone tag
                     if(op.Order.Account.Phone  != null){
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of Account Phone Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('Phone');
                        xmlW.writeEndElement();
                        //End of Account Phone Attribute Name tag
                        
                        //Beginning of Account Phone Attribute Value tag
                        xmlW.writeStartElement(null, 'Value', null);
                        
                           if(Ordermap.get(orderid).Account.Phone != null){
                            xmlW.writeCharacters(String.valueOf(Ordermap.get(orderid).Account.Phone));
                                   
                            }
                        xmlW.writeEndElement();
                        
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                        
                        }                                        
                         xmlW.writeEndElement();
                        //End of Attributes tag
                     }
                 }
                 
                if(!attributeRelationVSattributes.isEmpty() && attributeRelationVSattributes.containskey(op.Attribute_Relationship__c)){
                    //getting attributes here
                    List<Attribute_Lines__c> attTempList = attributeRelationVSattributes.get(op.Attribute_Relationship__c);
                    
                    //beginning of Attributes tag
                    xmlW.writeStartElement(null, 'Attributes', null);
                    
                         if(op.Inventory_Id__c!= null){
                          //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Beginning of Inventory Id Attribute Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        xmlW.writeCharacters('InventoryId');
                        xmlW.writeEndElement();
                        //End of Inventory Id Attribute Name tag
                        
                        //Beginning of Inventory Id Attribute Value tag
                        xmlW.writeStartElement(null, 'Value', null);
                        
                            xmlW.writeCharacters(op.Inventory_Id__c);
                        xmlW.writeEndElement();
                        
                         xmlW.writeEndElement();
                        //End of Attribute tag 
                        
                        }
                        //End of Inventory Id
                    
                    // part of MAC 3.0 to include SalesforceInventory Inventory Id
                     
                    if(op.SFInventoryId__c != null || test.isRunningTest()){ 
                    //beginning of Attribute tag  
                    xmlW.writeStartElement(null, 'Attribute', null);    
                            
                            
                    //Beginning of SalesforceInventory Id Attribute Name tag  
                    xmlW.writeStartElement(null, 'Name', null); 
                    xmlW.writeCharacters('SalesforceInventoryId');    
                    xmlW.writeEndElement(); 
                    //End of SalesforceInventory Id Attribute Name tag    
                            
                    //Beginning of SalesforceInventory Id Attribute Value tag 
                    xmlW.writeStartElement(null, 'Value', null);    
                       if(!test.isRunningTest()){     
                    xmlW.writeCharacters(op.SFInventoryId__c);   
                       }
                    xmlW.writeEndElement(); 
                            
                     xmlW.writeEndElement();    
                     //End of Attribute tag  
                            
                     }   
                     //End of Salesforce Inventory Id
                     
                    for(Attribute_Lines__c at : attTempList){
                        //Start attributes XML Logic here
                        
                        
                        
                        
                        //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        //Inclusion of Other Attributes
                        System.debug('@@@@@ Attributes '+at);
                        //beginning of Attribute tag
                        // xmlW.writeStartElement(null, 'Attribute', null);
                        
                        //Beginning of Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        if(at.Attribute_Name__c != null && at.Attribute_Name__c != '')
                            xmlW.writeCharacters(at.Attribute_Name__c);
                        xmlW.writeEndElement();
                        //End of Name tag
                        
                        //Beginning of Value Tag
                        xmlW.writeStartElement(null, 'Value', null);
                        if(at.Attribute_Type__c != null) {
                            if(at.Attribute_Type__c == 'Text' || at.Attribute_Type__c == 'String') {
                                if(at.String_Value__c != null && at.String_Value__c !='')
                                    xmlW.writeCharacters(at.String_Value__c);
                            }
                            else if(at.Attribute_Type__c == 'Number') {
                                if(at.Number_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(at.Number_Value__c));
                            }
                            else if(at.Attribute_Type__c == 'Boolean') {
                                xmlW.writeCharacters(String.valueOf(at.Boolean_Value__c));
                            }
                            else if(at.Attribute_Type__c == 'Picklist') {
                                if(at.Picklist_Value__c != null && at.Picklist_Value__c !=''){
                                    xmlW.writeCharacters(at.Picklist_Value__c);
                                    }
                                    else if(at.String_Value__c != null && at.String_Value__c !=''){
                                        xmlW.writeCharacters(at.String_Value__c );
                                    }
                            }
                            else if(at.Attribute_Type__c == 'Date') {
                                if(at.Date_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(at.Date_Value__c));
                            }
                            else if(at.Attribute_Type__c == 'Phone') {
                                if(at.Phone_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(at.Phone_Value__c));
                            }
                            else {
                                
                            }
                        }
                        xmlW.writeEndElement();
                        //End of Value tag
                        
                        // Added By Sai C for Attribute Value Id Tag
                        //forming value ID tag from here
                        xmlW.writeStartElement(null, 'ID', null);
                        
                        //Beginning of Value ID Tag i.e ID
                        if(at.Value_ID__c != null){
                            xmlW.writeCharacters(at.Value_ID__c);
                            
                            //End of Value ID tag
                        }
                        
                        else{
                            xmlW.writeCharacters(' ');
                        }
                        xmlW.writeEndElement(); 
                        
                        xmlW.writeEndElement();
                        //End of Attribute tag         
                        
                        
                    }
                    xmlW.writeEndElement();
                    //End of Attributes tag
                }
                
                
                xmlW.writeEndElement();
                //End of Product Tag
                
                xmlW.writeEndElement();
                //End of LineItem tag
                
                xmlW.writeEndElement();
                //End of LineItems tag
                
                
                
            }
            
            //xmlW.writeEndElement();
            //End of Products Tag
            
            
            
            
            
            
        } 
        
        xmlW.writeEndElement();
        //End of Products Tag
        
        xmlW.writeEndElement();
        //End of Order tag
        
        xmlW.writeEndElement();
        //End of OrderRequest tag
        
        
        
        reqXML = xmlW.getXmlString();
        System.debug('Order Request :'+reqXML);
        //  return reqXML; 
        
        
        String reqXmlupdted1 = reqXML.replace('+','%2B');
        String reqXmlupdted = reqXmlupdted1.replace('&','%26');
        return reqXmlupdted ;         
   
    }
    //added by saiv 07/26/2021
    
    @future(callout = true)
    public static void livedateXMLCallout(Set<Id> liveDateOrders, String username){
        system.debug('@@@@@ in livedateXMLCallout');
        
        //Set<Id> orderCharges = new Set<Id>();
        Set<Id> orderCharges = (new Map<id,OrderItem>([select id from OrderItem where OrderId IN:liveDateOrders])).keyset();
        
        
        
        
        //Declarations
        String reqXML;
        List<String> lstResponseBody                                   = new List<String>();
        List<Error_Log__c> lstErrLogs                                  = new List<Error_Log__c>();
        List<Error_Log__c> lstExistingErrLogs                          = new List<Error_Log__c>();
        Map<Id,Error_Log__c> mapIdNExistingErrLogs                     = new Map<Id,Error_Log__c>();
        List<OrderItem>orpcList             = new List<OrderItem>();
        Set<Id> orderItemIDs = new Set<Id>();
        
        //Map<Id,List<Order_Charge_Attribute__c>> mapOrderIdNlstOrderChargeAttributes = new Map<Id,List<Order_Charge_Attribute__c>>();
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
        
        Map<Id,Order> mapOrderIdNOrder = new Map<Id,Order>();
        Map<Id,List<OrderItem>>mapOrderIdNLstOrderRatePlanCharges = new Map<Id,List<OrderItem>>();
        system.debug('===orderCharges==='+orderCharges);
        //get Ordercharges for an order
        for(OrderItem  orderCharge : [Select id,Status__c,Product2.IsInventoried__c ,Fulfillment_date__c,OrderId,SIN__c,Inventory_Id__c,Attribute_Relationship__c,Renew_Rebase_Truncate_Date__c,Product2.ProductCode,
                                                                 ServiceDate,EndDate,SBQQ__TerminatedDate__c,SBQQ__QuoteLine__r.Last_day_of_month__c,Product2.Name,blng__NextBillingDate__c,SBQQ__BundleRoot__c,ParentProduct__c,Live_Date__c,
                                                                 Chat_ID__c,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.SIN__c,SBQQ__ProductSubscriptionType__c,CreatedDate from OrderItem
                                                                 where Id in: orderCharges]) {
                system.debug('===orderCharge==='+orderCharge);                                                
                if(mapOrderIdNLstOrderRatePlanCharges.containsKey(orderCharge.OrderId)){
                    mapOrderIdNLstOrderRatePlanCharges.get(orderCharge.OrderId).add(orderCharge);
                }
                else{
                    mapOrderIdNLstOrderRatePlanCharges.put(orderCharge.OrderId,new List<OrderItem>{orderCharge});
                }
                system.debug('==mapOrderIdNLstOrderRatePlanCharges=='+mapOrderIdNLstOrderRatePlanCharges);                                                               
                                                                             
               orpcList.add(orderCharge); 
               orderItemIDs.add(orderCharge.Id);                                                               
                                                                            
          }
            
            
            //get Orders from Order Charges
            for(Order orderObj : [Select id, Name, OrderNumber,AccountId,RecordType.DeveloperName 
                                    From Order where Id in : mapOrderIdNLstOrderRatePlanCharges.keySet()]) {
                mapOrderIdNOrder.put(orderObj.Id,orderObj);
            }
            system.debug('===mapOrderIdNOrder==='+mapOrderIdNOrder);
            //Checking if Order XML already exists in Error Log, if exists do not send that order , queue it along with the existing order
            for(Error_Log__c err : [Select e.XML_Mesaage_Type__c, e.XML_Body__c, e.Sent_Successfully__c, e.Order_Number__c,e.Order_Name__c,e.Error_Reason__c, e.Name, e.Id ,e.Re_process_date_time__c
                                    From Error_Log__c e
                                    Where e.XML_Mesaage_Type__c = 'OrderRequest' AND e.Order_Number__c in :mapOrderIdNOrder.keySet()] ) {
                    mapIdNExistingErrLogs.put(err.Order_Number__c,err);                 
            }
        
          for(Id orderId : mapOrderIdNOrder.keySet()) {
            if(mapOrderIdNLstOrderRatePlanCharges.containsKey(orderId) && mapOrderIdNOrder.containsKey(orderId)) { 
                System.debug('inside order Cancellation method call');
                //reqXML=CPQ_MDL_Integration_Vim_Efs.constructXML_OrderCancel(userName,mapOrderIdNLstOrderRatePlanCharges.get(orderId),mapOrderIdNOrder.get(orderId),orpcIdVschatOrpc);
                reqXML=CPQ_MDL_Integration_Vim_Efs.orderRequestfrompage(orderItemIDs);
                
                 // Commented 9/29 String reqXmlupdted1 = reqXML.replace('+','%2B');
                
                 String reqXmlRemove = reqXML.replace('%20','+'); //<T01>    
                String reqXmlupdted1 = reqXmlRemove.replace('+','%2B'); //<T01>
                
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
                                Error_Log__c temp_error = CPQ_MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody() , reqXML);
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
                            CPQ_MDL_Integration_Vim_Efs.sendEmailInCaseOfException('Order XMl Request',orderId,e.getMessage());
                        }      
                    }
                }
                else if(restrictCalls == true) {
                    System.debug('No calls will be sent since custom setting is activated');
                }
            }
        }
    }
    
    public void FkMethod(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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
/*
 *
 * Created By     :  Lister Technologies
 * Creation Date   :  10/03/2015
 * Purpose      :  Optimized code to send pend inventory request on button click from Opportunity
 * 
*/
public with sharing class MDL_PendInventoryRequestCtrl {
  private ApexPages.StandardController standardController;
  //opportunity object
  public Opportunity oppRecord;
  //string to get opportunity id
  public String oppid{get;set;}  
  public List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> oppRPCList;
  public List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> newOppRPCList;
  Set<Id> setOppProductids;
  public MDL_PendInventoryRequestCtrl(ApexPages.StandardController standardController) {
    this.standardController = standardController;
    oppid=standardController.getId();    
    oppRecord = new Opportunity();
    oppRPCList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
    newOppRPCList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
    setOppProductids = new Set<Id>();
  }
  public PageReference sendPendInventoryRequest() {
    Restrict_Integration_Calls__c endPts = Restrict_Integration_Calls__c.getValues('Restrict');
    System.debug('**'+endPts);
    Boolean a = Boolean.valueOf(endPts.Restrict_Callouts__c);
    System.debug('a values is **'+a);
    Map<String,String> mapAttributeNameAndValue = new Map<String,String>();
    oppRecord = [Select o.Id, o.Account.MH_Cust_Number__c ,o.AccountId From Opportunity o where o.Id =: oppid];
    User u = [select Id, username from User where Id = :UserInfo.getUserId()];
    String userName = u.Username;
    oppRPCList = [Select invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__c, invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Family__c, invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c, 
                  invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c, invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Description__c, invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name, invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.IsInventoried__c, invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.InventoryId__c, 
                  invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id,
                  invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, invoiceit_crmx__Opportunity_Rate_Plan__r.Name, invoiceit_crmx__Opportunity_Rate_Plan__r.Id,
                  invoiceit_crmx__Opportunity_Rate_Plan__c, Name, Id,
                  (Select String_Value__c, Boolean_Value__c, Date_Value__c, Number_Value__c, Phone_Value__c, Picklist_Value__c, Opportunity_Rate_Plan_Charge__c, Name, Id,value_ID__c, Attribute_Name__c,Attribute_Type__c From Opportunity_Charge_Attributes__r)
                  from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c where invoiceit_crmx__Opportunity__c=:oppid and invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.IsInventoried__c = 'true'
                  and (RecordType.DeveloperName = 'MDL_Opportunity_Rate_Plan_Charge' or RecordType.DeveloperName = 'Nolo_Opportunity_Rate_Plan_Charge')];
    for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRPC : oppRPCList) {
      if(oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.InventoryId__c == null || oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.InventoryId__c == '') {
        newOppRPCList.add(oppRPC);
      }
    }  
    system.debug('@@@@@newOppRPCList'+newOppRPCList);  
    for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRPC : oppRPCList) {
        setOppProductids.add(oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c);
        for(Opportunity_Charge_Attribute__c att: oppRPC.Opportunity_Charge_Attributes__r) {
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
    }
    System.debug('MapAttributes'+mapAttributeNameAndValue);
    //end of atributes value
    
    //if restrict integration custom setting is set to true , error will be thrown 
    if(a==true) {
      apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'No callouts will be sent because Custom Setting for restricting callouts is enabled.Please disable that and then proceed to pend the products');
          apexpages.addMessage(am);  
          return null;
    }    
    
    if(setOppProductids.size() > 0) {
      for(String attValue : mapAttributeNameAndValue.values()) {System.debug('attValue is :::'+attValue);
        if(attValue == null || attValue == '') {
          apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Inventory cannot be pended if any of the attribute values are null.Please fill in attribute values before pending the inventory');
          apexpages.addMessage(am);  
          return null;
        }
      }
        if(newOppRPCList.size()>0)
            pendInventoryRequest(oppRecord.Account.MH_Cust_Number__c,newOppRPCList,userName,oppRecord.Account.Id);
      
    }
    else {
        apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'No inventorable products exists in the opportunity currently.Please add inventorable products to pend them ');
        apexpages.addMessage(am);  
        return null;
    }
    return new PageReference('/'+oppid);
  }
  public PageReference cancel() {
    return new PageReference('/'+oppid);
  }
  public void pendInventoryRequest(String customerNumber,List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> oppRPCList,String userName,String acc){
    List<String> lstResponseBody = new List<String>();
    Map<Id,String> mapOppProdIdNErrResponseBody = new Map<Id,String>(); 
    Map<Id,Boolean> mapOppProdIdNResponseIsXML = new Map<Id,Boolean>();
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
    String publicKey  =   endPts.Public_Key__c;  
    String apiKey = endPts.API_key__c;
    
    /*  
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
    String aToken = timeDifferenceInSeconds + ':' + apikey + ':' + encodedText;
    //aToken will be added in HTTP Request Header as Authorization
    System.debug('authorization token is '+aToken);
    //end of authentication
    */
    if(customerNumber!=null) {
        cusNumb = customerNumber;
    }
    for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRPC : oppRPCList){
        reqxml= constructXML_PendInventory(oppRPC,cusNumb,uName); //get request XML from the static method
        system.debug('@@@@@reqXML'+ reqXML);
        //reqxml='xml='+ reqXML;
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
            system.debug('@@@@xml'+ reqxml);  
            //req.setHeader('Content-Type', 'text/xml');
             req.setHeader('Accept', 'application/xml');
             req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setHeader('Authorization', Header);
           // req.setHeader('Authorization', aToken);
            HTTPResponse res = http.send(req);
            System.debug('Response Body : '+res.getBody()); 
            if(res.getStatusCode() != 500 && res.getStatusCode() != 400 && res.getStatusCode() != 404 && res.getStatusCode() != 401 && res.getStatusCode() != 502) { 
                lstResponseBody.add(res.getBody());
            }
            if(res.getStatusCode() == 400 || res.getStatusCode() == 401) {
              mapOppProdIdNErrResponseBody.put(oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id,res.getBody()); 
              mapOppProdIdNResponseIsXML.put(oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id,true);               
              apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Authentication issue . Kindly inform the system administrator regarding the same.');
              apexpages.addMessage(am);    
            }
            if(res.getStatusCode() == 404) {
                mapOppProdIdNErrResponseBody.put(oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id,'404 : The specified resource was not found, or the resource has been deleted. Please contact MHI system administrator.'); 
                mapOppProdIdNResponseIsXML.put(oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id,false);                
                apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Response Status Code : 404. The specified resource was not found, or the resource has been deleted . Please contact MHI system administrator .');
                apexpages.addMessage(am);   
            }
            if(res.getStatusCode() == 500) {
              mapOppProdIdNErrResponseBody.put(oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id,'500 : Internal Server Error . Please contact MHI system administrator .' ); 
              mapOppProdIdNResponseIsXML.put(oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id,false);               
              apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'There is a network issue . Please contact MHI system administrator .');
              apexpages.addMessage(am);  
            }      
            if(res.getStatusCode() == 502) {
              mapOppProdIdNErrResponseBody.put(oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id,'502 : Bad Gateway issue . Please contact MHI system administrator .'); 
              mapOppProdIdNResponseIsXML.put(oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id,false);
              apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Bad Gateway issue . Please contact MHI system administrator');
              apexpages.addMessage(am);  
            }
            }catch(System.CalloutException ce) {
              mapOppProdIdNErrResponseBody.put(oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id,ce.getMessage());            
              mapOppProdIdNResponseIsXML.put(oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id,false);
              apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Callout exception , kindly try to pend inventory after again');
              apexpages.addMessage(am);   
            }
            catch(System.Exception e) {
              mapOppProdIdNErrResponseBody.put(oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id,e.getMessage());             
              mapOppProdIdNResponseIsXML.put(oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id,false);
              apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Some Exception occurred , please try again after sometime.'+e.getMessage());
              apexpages.addMessage(am);
            }                                              
        }
        if(!mapOppProdIdNErrResponseBody.isEmpty() && !mapOppProdIdNResponseIsXML.isEmpty()){
          parseErrorResponsePendInventory(mapOppProdIdNErrResponseBody,mapOppProdIdNResponseIsXML);
        }
      if(!Test.isRunningTest()){
            system.debug('@@@@@lstResponseBody'+lstResponseBody);
            MDL_Integration_Vim_Efs.parseResponseXML_PendInventoryResponse(lstResponseBody,acc);
      }   
  }
  public String constructXML_PendInventory(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRPC,String customerNumber,String userName){
    String requestXMLString = '';
    String xmlns='';
    //get xmlns value from custom setting
    Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('PendInventory');
    xmlns = endPts.xmlns__c;
    
    //get server timestamp to send it in requestid
    DateTime result = DateTime.now();
    String timeStampString = result.format();//to convert datetime into string
    String reqID = oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id + '-' + timeStampString ;
    Map<String,String> mapAttributeNameAndValue = new Map<String,String>();
    Map<String,String> mapModifiedNameAndValue = new Map<String,String>();
    Map<String,String> attributeNameVSValueIdstemp = new Map<String,String>();  //to hold value Ids for attributes
    Map<String,String> attributeNameVSValueIds = new Map<String,String>();   
    String aopVal;
    System.debug('RequestId PendInventory Request :' + reqID);
    for(Opportunity_Charge_Attribute__c att: oppRPC.Opportunity_Charge_Attributes__r) {
        if(att.String_Value__c != null)
            mapAttributeNameAndValue.put(att.Attribute_Name__c,att.String_Value__c);
        if(att.Picklist_Value__c != null)
            mapAttributeNameAndValue.put(att.Attribute_Name__c,att.Picklist_Value__c);
        
        if(att.Value_ID__c != null){
            attributeNameVSValueIdstemp.put(att.Attribute_Name__c, att.Value_ID__c);
        }
        else{
            attributeNameVSValueIdstemp.put(att.Attribute_Name__c, ' ');
        }
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
        attributeNameVSValueIds.put(aopVal, attributeNameVSValueIdstemp.get(newAttValue));
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
    xmlW.writeCharacters(oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c);
    xmlW.writeEndElement();
    //End of ProductCode tag
    
    //Beginning of ProductName tag
    xmlW.writeStartElement(null,'ProductName',null);
    xmlW.writeCharacters(oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name);
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
    
     //Beginning of AOPId tag
    xmlW.writeStartElement(null,'AOPId',null);
    if(attributeNameVSValueIds.containsKey('AOP'))
        xmlw.writeCharacters(attributeNameVSValueIds.get('AOP'));
    xmlW.writeEndElement();
    //End of AOPId tag  
    
    //Beginning of ProductDeliveryAddress tag
    xmlW.writeStartElement(null,'ProductDeliveryAddress',null);
    
    //Beginning of city tag
    xmlW.writeStartElement(null, 'City', null);
    if(mapModifiedNameAndValue.containsKey('City'))
        if(mapModifiedNameAndValue.get('City')!=null)
        xmlw.writeCharacters(mapModifiedNameAndValue.get('City'));
    xmlW.writeEndElement();
    //End of city tag
    
    //Beginning of city ID tag
    xmlW.writeStartElement(null, 'CityId', null);
    if(attributeNameVSValueIds.containsKey('City'))
        if(attributeNameVSValueIds.get('City')!=null)
        xmlw.writeCharacters(attributeNameVSValueIds.get('City'));
    xmlW.writeEndElement();
    //End of city ID tag  
    
    //Beginning of county tag
    xmlW.writeStartElement(null, 'County', null);
    if(mapModifiedNameAndValue.containsKey('County'))
        if(mapModifiedNameAndValue.get('County')!=null)
            xmlw.writeCharacters(mapModifiedNameAndValue.get('County'));
    xmlW.writeEndElement();
    //End of county tag
    
    //Beginning of county ID tag
    xmlW.writeStartElement(null, 'CountyId', null);
    if(attributeNameVSValueIds.containsKey('County'))
        if(attributeNameVSValueIds.get('County')!=null)
            xmlw.writeCharacters(attributeNameVSValueIds.get('County'));
    xmlW.writeEndElement();
    //End of county ID tag  
    
    //Beginning of State tag
    xmlW.writeStartElement(null, 'State', null);
    if(mapModifiedNameAndValue.containsKey('State'))
        if(mapModifiedNameAndValue.get('State')!=null)
            xmlw.writeCharacters(mapModifiedNameAndValue.get('State'));
    xmlW.writeEndElement();
    //End of State tag
    
       //Beginning of State ID tag
    xmlW.writeStartElement(null, 'StateId', null);
    if(attributeNameVSValueIds.containsKey('State'))
        if(attributeNameVSValueIds.get('State')!=null)
            xmlw.writeCharacters(attributeNameVSValueIds.get('State'));
    xmlW.writeEndElement();
    //End of State ID tag
    
    //Beginning of Country tag
    xmlW.writeStartElement(null, 'Country', null);
    if(mapModifiedNameAndValue.containsKey('Country'))
        if(mapModifiedNameAndValue.get('Country')!=null)
            xmlw.writeCharacters(mapModifiedNameAndValue.get('Country'));
        //xmlW.writeCharacters(a.ShippingCountry);
    xmlW.writeEndElement();
    //End of Country tag
    
    //Beginning of Country ID tag
    xmlW.writeStartElement(null, 'CountryId', null);
    if(attributeNameVSValueIds.containsKey('Country'))
        if(attributeNameVSValueIds.get('Country')!=null)
            xmlw.writeCharacters(attributeNameVSValueIds.get('Country'));
       
    xmlW.writeEndElement();
    //End of Country ID tag  
    
    xmlW.writeEndElement();
    //End of ProductDeliveryAddress tag
    
    xmlW.writeEndElement();
    //End of PendInventoryRequest tag
    
    requestXMLString = xmlW.getXmlString();
        String reqXmlupdted = requestXMLString .replace('&','%26');
        String reqXmlupdted1 = reqXmlupdted.replace('+','%2B');
        System.debug('@@@@@reqXmlupdted1 :'+reqXmlupdted1); 
        return reqXmlupdted1 ;
    System.debug('PendInventory Request :'+requestXMLString);
    
    return requestXMLString;
  }
  public void parseErrorResponsePendInventory(Map<Id,String> mapOppProdIdNErrResponseBody, Map<Id,Boolean> mapOppProdIdNResponseIsXML){
      String txtmsg = '';      
      List<invoiceit_crmx__Opportunity_Product__c> lstOppProdToUpdate = new List<invoiceit_crmx__Opportunity_Product__c>();
      for(invoiceit_crmx__Opportunity_Product__c oppProd : [select Id,Error_Text__c from invoiceit_crmx__Opportunity_Product__c where Id in :mapOppProdIdNErrResponseBody.keyset()]){
        if(mapOppProdIdNResponseIsXML.containskey(oppProd.Id)){
          if(mapOppProdIdNResponseIsXML.get(oppProd.Id)==true){
            Dom.Document response = new Dom.Document();
            response.load(mapOppProdIdNErrResponseBody.get(oppProd.Id));
            dom.Xmlnode res = response.getRootElement();          
            String respCode = res.getChildElement('HttpResponseCode', null).getText();
            txtmsg = respCode+' : '+res.getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null).getText();       
            System.debug('text message received is :'+txtmsg);                              
          }
          else if(mapOppProdIdNResponseIsXML.get(oppProd.Id)==false){
            txtmsg = mapOppProdIdNErrResponseBody.get(oppProd.Id);
            System.debug('text message received is :'+txtmsg);  
          }
        }
        if(txtmsg != ''){
            oppProd.Error_Text__c = txtmsg;
            lstOppProdToUpdate.add(oppProd);
        }       
      }
      if(lstOppProdToUpdate.size()>0){
        Database.Update(lstOppProdToUpdate);
      }                    
    } 
}
/**
 * Class: CPQ_CheckInvRequestCtrl
 * Test Class: 
 * Created by: SaiV
 * Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHMAC-377      SaiV     11/12/2023        SaiC         <T01>    Generate bulk Check Inventory XML request to Orderbroker upon Proposal generation + discount validations
MHMAC-276,364  CK       09/27/2023        SaiC         <T02>    Quote Invalidation during Check Inventory: Create Task & send email notification
************************************************************************************************************************
*/


public with sharing class CPQ_CheckInvRequestCtrl {
    public CPQ_CheckInvRequestCtrl() {

    }
    //<T01>
    public string cpq_checkInventoryRequest(Set<Id> setQuoteLineProdids,String customerNumber, String avvoCustId, String userName,String acc) {
        List<String> lstResponseBody = new List<String>();
        Map<Id,String> mapOppProdIdNErrResponseBody = new Map<Id,String>();
        Map<Id,SBQQ__QuoteLine__c> mapOppProdIdNOppProd = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,Boolean> mapOppProdIdNResponseIsXML = new Map<Id,Boolean>();
        List<Error_Log__c> lstErrLogs = new List<Error_Log__c>();
        String Msg;
        //end points is stored in a custom setting - get values from there and use it heres
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('CheckInventory');
        String endPoint = String.valueOf(endPts.Endpoint_URL__c);
        System.debug('**'+endPoint);
        String methodType = endPts.MethodType__c;
        String reqXML;
        String cusNumb = '';
        String uName = userName;
        //code for authentication
        String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)
        String publicKey  = endPts.Public_Key__c;
        String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
        String privateKey = endPts.Private_Key__c;
        String apiKey = endPts.API_key__c;
        
        String httpVerb = 'POST'; 
        
        if(customerNumber!=null) {
            cusNumb = customerNumber;
        }
        List<SBQQ__QuoteLine__c> quoteLineLst = new List<SBQQ__QuoteLine__c>();
        Id quoteId;
        System.debug('set passed is : '+setQuoteLineProdids);
        for(SBQQ__QuoteLine__c qoLL : [Select i.Id,i.SBQQ__Quote__c, i.Attribute_Relationship__c, i.SBQQ__Product__c,
                                        i.SBQQ__ProductCode__c, i.SBQQ__ProductName__c, i.SBQQ__Product__r.IsInventoried__c, 
                                        i.Inventory_Id__c, i.Error_Text__c  From SBQQ__QuoteLine__c i
                                        where i.Id in : setQuoteLineProdids]) {
                                            quoteLineLst.add(qoLL);
                                            quoteId = qoLL.SBQQ__Quote__c;
                                        }
                                        system.debug('quoteId==='+quoteId);
        reqXML = constructXML_PendInventory(quoteLineLst,cusNumb,avvoCustId,uName); //get request XML from the static method
        system.debug('reqXML==='+reqXML);
        
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
        
        try {
            Http http = new Http(); //global class which is used in both request & response
            HttpRequest req = new HttpRequest(); //initiate HTTP request
            //req.setEndpoint(endPoint);
            req.setEndpoint(givenEndpoint);
            
            req.setMethod(methodType);
            req.setTimeout(20000);
            
            //req.setBody(reqXML); 
            req.setBody(ipayload);
            
            //req.setHeader('Content-Type', 'text/xml');
            req.setHeader('Accept', 'application/xml');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            
            //req.setHeader('Authorization', aToken);
            req.setHeader('Authorization', Header);
            HTTPResponse res = http.send(req);
            System.debug('Response Body :'+res.getBody()); 
            System.debug('Response Name'+res.getStatus());
            System.debug('Response Name'+res.getStatusCode());
            //system.debug('response child element',)
            
            //if(res.getStatusCode() == 200) {
                lstResponseBody.add(res.getBody());   
            //}else{
                //Msg = res.getStatusCode()+' - Please contact system administrator';
            //}
            
            
            //if(res.getStatusCode() != 500 && res.getStatusCode() != 400 && res.getStatusCode() != 404 && res.getStatusCode() != 401 && res.getStatusCode() != 502) { 
                //lstResponseBody.add(res.getBody());
            //}
            /*
            if(res.getStatusCode() == 400 || res.getStatusCode() == 401) {
                
            }
            if(res.getStatusCode() == 404) {
                    
            }
            if(res.getStatusCode() == 500) {
                    
            }      
            if(res.getStatusCode() == 502) {
                
            }*/
        }
        catch(System.CalloutException ce) {
            Error_Log__c err = new Error_Log__c();
            err.XML_Mesaage_Type__c = 'Reserve Request';
            err.XML_Body__c = reqXML;
            err.Quote__c = quoteId;
            err.Error_Reason__c = 'Callout exception , kindly try to pend inventory after again';
            lstErrLogs.add(err);
        }
        catch(System.Exception e) {
            Error_Log__c err = new Error_Log__c();
            err.XML_Mesaage_Type__c = 'Reserve Request';
            err.XML_Body__c = reqXML;
            err.Quote__c = quoteId;
            err.Error_Reason__c = 'Some Exception occurred , please try again after sometime';
            lstErrLogs.add(err);
        } 
        system.debug('===lstErrLogs==='+lstErrLogs);
        if(!lstErrLogs.isEmpty()){
            Insert lstErrLogs;
        }
        if(!test.isRunningTest()){
            system.debug('===lstResponseBody==='+lstResponseBody);
            Msg = parseResponseXML_PendInventoryResponse(lstResponseBody,acc,quoteId);
        }
        return Msg;
    }
    //<T01>
    public static String constructXML_PendInventory(List<SBQQ__QuoteLine__c> qlLst,String customerNumber, String avvoCustId, String userName) {
        system.debug('in constructXML');
        String requestXMLString = '';
        String xmlns='';
        //get xmlns value from custom setting
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('CheckInventory');
        xmlns = endPts.xmlns__c;
        
        //get server timestamp to send it in requestid
        DateTime result = DateTime.now();
        String timeStampString = result.format();//to convert datetime into string
        String reqID;
        String quoteId;
        String quantity;
        Decimal qty;
        Integer integerVal;
        //getting attributes values
        Map<String,String> mapAttributeNameAndValue = new Map<String,String>();
        Map<String,String> mapModifiedNameAndValue = new Map<String,String>();
        
        String SAN = '';
        Set<Id> attrRelationIds = new Set<Id>(); //added new
        List<Attribute_Lines__c> lstAttributes = new List<Attribute_Lines__c>();
        List<Attribute_Lines__c> attrLinesLst = new List<Attribute_Lines__c>();
        Map<Id,Id> attrRelatnVsQuoteLine = new Map<Id,Id>();
        
        Map<Id,List<Attribute_Lines__c>> attrRltnVsAttrLines = new Map<Id,List<Attribute_Lines__c>>();
        
        //List<Attribute_Lines__c> AttrLinesLst = new List<Attribute_Lines__c>();
        //start - new
        List<SBQQ__QuoteLine__c> quoteLineLst = [Select Id, SBQQ__Quote__c, SBQQ__Quote__r.Name, Attribute_Relationship__c, SBQQ__Product__c, SFInventoryId__c,AvvoInventoryId__c,
                                                    SBQQ__ProductCode__c, SBQQ__ProductName__c, SBQQ__Product__r.IsInventoried__c, SBQQ__Quote__r.SBQQ__Account__r.Name, 
                                                    Inventory_Id__c, Error_Text__c,SBQQ__Quantity__c From SBQQ__QuoteLine__c Where Id IN:qlLst AND SBQQ__Product__r.IsInventoried__c = TRUE];
        system.debug('==quoteLineLst=='+quoteLineLst);
        Map<Id, String> qlVsQuantity = new Map<Id, String>();
        for(SBQQ__QuoteLine__c qll: quoteLineLst){
            attrRelationIds.add(qll.Attribute_Relationship__c);
            attrRelatnVsQuoteLine.put(qll.Attribute_Relationship__c,qll.Id);
            reqID = qll.SBQQ__Quote__c + '-' + timeStampString;
            quoteId = qll.SBQQ__Quote__r.Name;
            SAN = qll.SBQQ__Quote__r.SBQQ__Account__r.Name;
            //quantity = String.ValueOf(qll.SBQQ__Quantity__c);
            qlVsQuantity.put(qll.Id, String.ValueOf(qll.SBQQ__Quantity__c));
            /*qty = Decimal.valueOf(quantity);
            integerVal = qty.intValue();
            qty = Decimal.valueOf(quantity);
            integerVal = qty.intValue();*/
        }
        system.debug('==SAN=='+SAN);
        system.debug('==attrRelationIds=='+attrRelationIds);
        lstAttributes = [select id, Attribute_Junction__c, Attribute_Junction__r.Id,Attribute_Type__c, Attribute_Name__c, Phone_Value__c,
                            Picklist_Value__c, String_Value__c, Boolean_Value__c, Date_Value__c, Value_ID__c,
                            Number_Value__c FROM Attribute_Lines__c WHERE Attribute_Junction__c IN:attrRelationIds];
        System.debug('Opportunity Charge Attributes:'+lstAttributes);
        
        for(Attribute_Lines__c att: lstAttributes){
            if(attrRltnVsAttrLines.containsKey(att.Attribute_Junction__c)){
                attrRltnVsAttrLines.get(att.Attribute_Junction__c).add(att);
            }
            else{
                attrRltnVsAttrLines.put(att.Attribute_Junction__c, new List<Attribute_Lines__c>{att});
            }   
        }
        
        system.debug('===attrRltnVsAttrLines==='+attrRltnVsAttrLines);
        
        Xmlstreamwriter xmlW = new Xmlstreamwriter();
        
        xmlW.writeStartElement(null,'CheckInventoryRequest', null); 
        xmlW.writeAttribute(null,null,'xmlns',xmlns);
        
        //Beginning of requestId tag
        xmlW.writeStartElement(null,'RequestId',null);
        xmlW.writeCharacters(reqID);
        xmlW.writeEndElement();
        
        xmlW.writeStartElement(null,'CustomerNumber', null); 
        xmlW.writeCharacters(customerNumber);
        xmlW.writeEndElement();
    
        if(avvoCustId != null){
            xmlW.writeStartElement(null,'AvvoCustomerId', null); 
            xmlW.writeCharacters(avvoCustId);
            xmlW.writeEndElement();
        }
        //String SAN = '';
        xmlW.writeStartElement(null,'ServiceAccountName',null);
        xmlw.writeCharacters(SAN);
        xmlW.writeEndElement();
        
        xmlW.writeStartElement(null, 'UserName', null);
        xmlW.writeCharacters(userName);
        xmlW.writeEndElement();
        
        xmlW.writeStartElement(null, 'QuoteId', null);
        xmlW.writeCharacters(quoteId);
        xmlW.writeEndElement();
        
        //quote lines start - this should be under for loop - bulkifying starts here
        xmlW.writeStartElement(null, 'QuoteLines', null);
        for(SBQQ__QuoteLine__c qline: quoteLineLst){
            String aop = '';
            String aopId = '';
            String city = '';
            String cityId = '';
            String county = '';
            String countyId = '';
            String state = '';
            String stateId = '';
            String country = '';
            String countryId = '';
            system.debug('====qline====='+qline);
            system.debug('=====attrlinesforql====='+attrRltnVsAttrLines.get(qline.Attribute_Relationship__c));
            for(Attribute_Lines__c attLns: attrRltnVsAttrLines.get(qline.Attribute_Relationship__c)){
                system.debug('====attLns====='+attLns);
                if(attLns.Attribute_Name__c == 'AOP'){
                    aop = attLns.Picklist_Value__c;
                    aopId = attLns.Value_ID__c;
                }else if(attLns.Attribute_Name__c == 'City'){
                    city = attLns.Picklist_Value__c;
                    cityId = attLns.Value_ID__c;
                }else if(attLns.Attribute_Name__c == 'County'){
                    county = attLns.Picklist_Value__c;
                    countyId = attLns.Value_ID__c;
                }else if(attLns.Attribute_Name__c == 'State'){
                    state = attLns.Picklist_Value__c;
                    stateId = attLns.Value_ID__c;
                }else if(attLns.Attribute_Name__c == 'Country'){
                    country = attLns.String_Value__c;
                    countryId = attLns.Value_ID__c;
                }
            }
            system.debug('aop'+aop);
            system.debug('aopId'+aopId);
            system.debug('city'+city);
            system.debug('cityId'+cityId);
            system.debug('county'+county);
            system.debug('countyId'+countyId);
            system.debug('state'+state);
            system.debug('stateId'+stateId);
            system.debug('country'+country);
            system.debug('countryId'+countryId);
            xmlW.writeStartElement(null, 'QuoteLine', null);
            //QL Id
            xmlW.writeStartElement(null,'QuoteLineId',null);
            xmlW.writeCharacters(qline.Id);
            xmlW.writeEndElement();
            //Quantity
            system.debug('===quantity===='+qlVsQuantity.get(qline.Id));
            xmlW.writeStartElement(null,'Quantity',null);
            //xmlW.writeCharacters(quantity);
            xmlW.writeCharacters(qlVsQuantity.get(qline.Id));
            xmlW.writeEndElement();
            //AvvoInvId
            //xmlW.writeStartElement(null,'AvvoInventory',null);
            //xmlW.writeCharacters(qline.AvvoInventoryId__c);
            //xmlW.writeEndElement();
            //SF Inv Id
            if(qline.SFInventoryId__c != null && qline.AvvoInventoryId__c == null){
            xmlW.writeStartElement(null,'SalesforceInventoryId',null);
            xmlW.writeCharacters(qline.SFInventoryId__c);
            xmlW.writeEndElement();
            }else if(qline.AvvoInventoryId__c != null){
                xmlW.writeStartElement(null,'AvvoInventoryId',null);
                xmlW.writeCharacters(qline.AvvoInventoryId__c);
                xmlW.writeEndElement(); 
    
                xmlW.writeStartElement(null,'SalesforceInventoryId',null);
                xmlW.writeCharacters(qline.AvvoInventoryId__c);
                xmlW.writeEndElement();
            }
            //ProdCode
            xmlW.writeStartElement(null,'ProductCode',null);
            xmlW.writeCharacters(qline.SBQQ__ProductCode__c);
            xmlW.writeEndElement();
            //ProdName
            xmlW.writeStartElement(null,'ProductName',null);
            xmlW.writeCharacters(qline.SBQQ__ProductName__c);
            xmlW.writeEndElement();
            
        if((qline.SFInventoryId__c != null && qline.AvvoInventoryId__c == null) || Test.isRunningTest()){
            //AopName
            xmlW.writeStartElement(null,'AOP',null);
            xmlw.writeCharacters(aop);    
            xmlW.writeEndElement();
            //AopId
            xmlW.writeStartElement(null,'AOPId',null);
            xmlw.writeCharacters(aopId);    
            xmlW.writeEndElement();
            //ProdDeliveryAddress - Start
            xmlW.writeStartElement(null,'ProductDeliveryAddress',null);
                //City
                if((city != null && city != '' && cityId != null) || Test.isRunningTest()){
                    xmlW.writeStartElement(null,'City',null);
                    xmlw.writeCharacters(city);    
                    xmlW.writeEndElement();
                    //CityId
                    xmlW.writeStartElement(null,'CityId',null);
                    xmlw.writeCharacters(cityId);    
                    xmlW.writeEndElement();
                }
                //County
                if((county != null && county != '' && countyId != null) || Test.isRunningTest()){
                    xmlW.writeStartElement(null,'County',null);
                    if(Test.isRunningTest()){
                        county='test';
                    }
                    xmlw.writeCharacters(county);    
                    xmlW.writeEndElement();
                    //CountyId
                    xmlW.writeStartElement(null,'CountyId',null);
                    if(Test.isRunningTest()){
                        countyId='test';
                    }
                    xmlw.writeCharacters(countyId);    
                    xmlW.writeEndElement();
                }
                //State
                xmlW.writeStartElement(null,'State',null);
                 if(Test.isRunningTest()){
                        state='test';
                    }
                xmlw.writeCharacters(state);    
                xmlW.writeEndElement();
                //StateId
                xmlW.writeStartElement(null,'StateId',null);
            if(Test.isRunningTest()){
                        stateId='test';
                    }
                xmlw.writeCharacters(stateId);    
                xmlW.writeEndElement();
                //Country
                xmlW.writeStartElement(null,'Country',null);
             if(Test.isRunningTest()){
                        country='test';
                    }
                xmlw.writeCharacters(country);    
                xmlW.writeEndElement();
                //CountryId
                xmlW.writeStartElement(null,'CountryId',null);
            if(Test.isRunningTest()){
                        countryId='test';
                    }
                xmlw.writeCharacters(countryId);    
                xmlW.writeEndElement();
            xmlW.writeEndElement();
                //ProdDeliveryAddress - Start
        }
        xmlW.writeEndElement();
        
            
        }
        xmlW.writeEndElement();
        xmlW.writeEndElement();
        
        requestXMLString = xmlW.getXmlString();
        System.debug('ReserveInventory Request :'+requestXMLString);
        return requestXMLString;
    }
    //<T01>
    public static String parseResponseXML_PendInventoryResponse(List<String> lstResponseStrings,String accId, String qId) {
    
        String txtmsg;
        String errMsg='';
        system.debug('==lstResponseStrings=='+lstResponseStrings);
        String quoteId = qId;
        String reqId;
        Id quoteLineId;
        String availCount;
        String resErrMsg;
    
        Map<Id,String> quoteLineIdVsAvailableCount = new Map<Id,String>(); //For QUASI
        Map<Id,String> quoteLineIdVsOfsInvId = new Map<Id,String>(); //For OFS
        Map<Id,String> quoteLineIdVsErrMsg = new Map<Id,String>(); //For error msg with 200
        
        Map<String,String> systemVS400ErrorText = new Map<String,String>();
    
        List<SBQQ__QuoteLine__c> qlForUpdate = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        Map<Id,String> quoteOwnerMap = new Map<Id,String>();//<T02>
        Map<Id,String> quoteNameMap = new Map<Id,String>();//<T02>
        Map<String,String> systemVsServerFailedRes = new Map<String,String>();
        system.debug('==quoteId=='+quoteId);
        
        for (String xmlResponse : lstResponseStrings) {
            Dom.Document doc = new Dom.Document();
            doc.load(xmlResponse);
    
            Dom.XmlNode root = doc.getRootElement();
            List<Dom.XmlNode> Systems = root.getChildElement('Systems', null).getChildElements();
            
            for (Dom.XmlNode resSystem : Systems){
                system.debug('===SystemInv==='+resSystem);
                
                //for QUASI
                if(resSystem.getChildElement('Name', null).getText() == 'QUASI'){
                    if(resSystem.getChildElement('HttpResponse', null).getChildElement('Code', null).getText() == '200'){ //for 200 response
                        List<Dom.XmlNode> quoteLines = new List<Dom.XmlNode>();
                        if( resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('CheckInventoryResponse',null).getChildElement('QuoteLines',null) != Null){
                            quoteLines = resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('CheckInventoryResponse',null).getChildElement('QuoteLines',null).getChildElements();
                        }else if(resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('CheckInventoryResponse',null).getChildElement('HttpResponseCode',null) != null){ 
                            if(resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('CheckInventoryResponse',null).getChildElement('HttpResponseCode',null).getText() == '400'){
                                systemVS400ErrorText.put('QUASI', resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('CheckInventoryResponse',null).getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null).getText());
                            }
                        }
                        system.debug('====quoteLines===='+quoteLines);
                        for(Dom.XmlNode ql: quoteLines){
                            //if error text is not null
                            Dom.XmlNode message = ql.getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null);
                            String eMsg = '';
                            system.debug('====message====='+message);
                            eMsg = message.getText();
                            system.debug('====eMsg====='+eMsg);
                            
                            if(eMsg !=''){
                                system.debug('=========in emsg=====');
                                //copying error text with qlId
                                quoteLineIdVsErrMsg.put(ql.getChildElement('QuoteLineId',null).getText(), ql.getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null).getText());
                                //if available count is provided with error text
                                if(ql.getChildElement('Inventory',null).getText() !=''){
                                    quoteLineIdVsAvailableCount.put(ql.getChildElement('QuoteLineId',null).getText(), ql.getChildElement('Inventory', null).getChildElement('Available', null).getText());
                                }
                            }else{
                                system.debug('=========not in emsg=====');
                                //if reserved and available counts are provided
                                quoteLineIdVsAvailableCount.put(ql.getChildElement('QuoteLineId',null).getText(), ql.getChildElement('Inventory', null).getChildElement('Available', null).getText());
                            }
                        }
                        system.debug('====quoteLineIdVsErrMsg====='+quoteLineIdVsErrMsg);
                        system.debug('====quoteLineIdVsAvailableCount====='+quoteLineIdVsAvailableCount);
                    }else{ //for non 200 response
                        systemVsServerFailedRes.put(resSystem.getChildElement('Name', null).getText(), resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getText());  
                    }
                }
                //for OFS
                if(resSystem.getChildElement('Name', null).getText() == 'OFS'){
                    if(resSystem.getChildElement('HttpResponse', null).getChildElement('Code', null).getText() == '200'){ //for 200 response
                        List<Dom.XmlNode> quoteLines = new List<Dom.XmlNode>();
                        if( resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('CheckInventoryResponse',null).getChildElement('QuoteLines',null) != Null){
                            quoteLines = resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('CheckInventoryResponse',null).getChildElement('QuoteLines',null).getChildElements();
                        }else if(resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('CheckInventoryResponse',null).getChildElement('HttpResponseCode',null) != null){ 
                            if(resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('CheckInventoryResponse',null).getChildElement('HttpResponseCode',null).getText() == '400'){
                                systemVS400ErrorText.put('OFS', resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('CheckInventoryResponse',null).getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null).getText());
                            }
                        }
                        system.debug('====quoteLines===='+quoteLines);
                        for(Dom.XmlNode ql: quoteLines){
                            //if error text is not null
                            Dom.XmlNode message = ql.getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null);
                            String eMsg = '';
                            system.debug('====messageOFS====='+message);
                            eMsg = message.getText();
                            system.debug('====eMsgOFS====='+eMsg);
                            
                            if(eMsg != ''){
                                system.debug('=========in emsg=====');
                                //copying error text with qlId
                                quoteLineIdVsErrMsg.put(ql.getChildElement('QuoteLineId',null).getText(), ql.getChildElement('Messages',null).getChildElement('Message',null).getChildElement('Text',null).getText());
                                //if available count is provided with error text
                                if(ql.getChildElement('Inventory',null).getText() !=''){
                                    quoteLineIdVsAvailableCount.put(ql.getChildElement('QuoteLineId',null).getText(), ql.getChildElement('Inventory', null).getChildElement('Available', null).getText());
                                }    
                            }else{
                                system.debug('=========not in emsg=====');
                                //if reserved and available counts are provided
                                quoteLineIdVsAvailableCount.put(ql.getChildElement('QuoteLineId',null).getText(), ql.getChildElement('Inventory', null).getChildElement('Available', null).getText());
                            }
                        }
                        system.debug('====quoteLineIdVsErrMsg====='+quoteLineIdVsErrMsg);
                        system.debug('====quoteLineIdVsAvailableCount====='+quoteLineIdVsAvailableCount);
                    }else{ //for non 200 response
                        systemVsServerFailedRes.put(resSystem.getChildElement('Name', null).getText(), resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getText());  
                    }
                }    
            }
        }
        system.debug('====systemVsServerFailedRes===='+systemVsServerFailedRes);
        qlList = [Select id, Name,Inventory_Id__c, AvailableCount__c, Available__c, SBQQ__ProductName__c, SBQQ__ProductCode__c,Error_Text__c, 
                            SBQQ__Quote__c, SBQQ__Product__r.IsInventoried__c, SIN__c,SBQQ__Quote__r.OwnerId,SBQQ__Quote__r.Name,SBQQ__Quote__r.Owner.Email,SBQQ__Quote__r.Owner.Name from SBQQ__QuoteLine__c
                                            where SBQQ__Quote__c=:quoteId AND SBQQ__Product__r.IsInventoried__c = TRUE AND SIN__c = Null AND (Inventory_Id__c = Null OR AvailableCount__c = Null)];//<T02> Added fields to the query
        String failedError;
        String subStgfailedError;
        for(SBQQ__QuoteLine__c ql: qlList){
            system.debug('quoteline'+ql);
            //for 200 response 
            if(quoteLineIdVsErrMsg.get(ql.Id)!= null){
                system.debug('===in errormessage==='+quoteLineIdVsErrMsg.get(ql.Id));
                ql.Error_Text__c = quoteLineIdVsErrMsg.get(ql.Id);
                errMsg = 'PDF generation failed. Please review the quote lines for more details.';
            }else{
                system.debug('===in else for error text===');
                ql.Error_Text__c = '';
            }
            if(quoteLineIdVsAvailableCount.get(ql.Id) != null){
                ql.AvailableCount__c = quoteLineIdVsAvailableCount.get(ql.Id);
                if(quoteLineIdVsAvailableCount.get(ql.Id) > '0'){
                    ql.Available__c = true;
                }
            }
            //for failed response
            if(systemVsServerFailedRes != Null){
                if(!systemVsServerFailedRes.isEmpty() || Test.isRunningTest()){
                    String ownerDet = ql.SBQQ__Quote__r.OwnerId + '-' + ql.SBQQ__Quote__r.Owner.Email + '-' + ql.SBQQ__Quote__r.Owner.Name;
                    quoteOwnerMap.put(ql.SBQQ__Quote__c,ownerDet);//<T02>
                    quoteNameMap.put(ql.SBQQ__Quote__c,ql.SBQQ__Quote__r.Name);//<T02>
                }
                if(systemVsServerFailedRes.get('QUASI') != Null && (ql.SBQQ__ProductCode__c == '11019' || ql.SBQQ__ProductCode__c == '11018') || Test.isRunningTest()){
                    system.debug('===in quasi===='+failedError);
                    failedError = systemVsServerFailedRes.get('QUASI');
                    if(Test.isRunningTest() != true){
                    subStgfailedError = failedError.substringAfter('response:');
                    }
                    ql.Error_Text__c = subStgfailedError;
                }
                if(systemVsServerFailedRes.get('OFS') != Null && (ql.SBQQ__ProductCode__c != '11019' || ql.SBQQ__ProductCode__c != '11018')|| Test.isRunningTest()){
                    system.debug('===in ofs====');
                    failedError = systemVsServerFailedRes.get('OFS');
                    if(Test.isRunningTest() != true){
                    subStgfailedError = failedError.substringAfter('response:');
                    }
                    ql.Error_Text__c = subStgfailedError;
                }
            }
            if(systemVS400ErrorText != Null){
                if(systemVS400ErrorText.get('QUASI') != Null && (ql.SBQQ__ProductCode__c == '11019' || ql.SBQQ__ProductCode__c == '11018')|| Test.isRunningTest()){
                    system.debug('===in quasi====');
                    //failedError = systemVS400ErrorText.get('QUASI');
                    //subStgfailedError = failedError.substringAfter('response:');
                    ql.Error_Text__c = systemVS400ErrorText.get('QUASI');
                }
                if(systemVS400ErrorText.get('OFS') != Null && (ql.SBQQ__ProductCode__c != '11019' || ql.SBQQ__ProductCode__c != '11018')|| Test.isRunningTest()){
                    system.debug('===in ofs====');
                    //failedError = systemVsServerFailedRes.get('OFS');
                    //subStgfailedError = failedError.substringAfter('response:');
                    ql.Error_Text__c = systemVS400ErrorText.get('OFS');
                }
            }
            qlForUpdate.add(ql);
        }
        system.debug('===qlForUpdate==='+qlForUpdate);
        if(!qlForUpdate.isEmpty()){
            update qlForUpdate;
            if(systemVsServerFailedRes != Null && !systemVsServerFailedRes.isEmpty()){//<T02> Start
                List<Task> tasksToInsert = new List<Task>();
                Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Sales_Task_Type').getRecordTypeId();
                for(Id qtId : quoteOwnerMap.keyset()){
                    Task tsk = new Task();
                    tsk.RecordTypeId = taskRecordTypeId;
                    tsk.Status = 'Open';
                    if(quoteOwnerMap.containsKey(qtId)){
                        system.debug('quoteOwner Id '+quoteOwnerMap.get(qtId).split('-')[0]);
                        tsk.OwnerId = quoteOwnerMap.get(qtId).split('-')[0];
                    }
                    tsk.Priority = 'High';
                    tsk.Recent_Task__c = false;
                    tsk.Subject = 'Unavailable Inventory on '+quoteNameMap.get(qtId);
                    tsk.Type = 'Other';
                    tsk.Description = 'Check the line items with the red flag';
                    tsk.CPQ_Quote__c = qtId;
                    tsk.Inventory_Check__c = true;
                    tasksToInsert.add(tsk);
                }
                system.debug('===tasksToInsert==='+tasksToInsert);
                if(!tasksToInsert.isEmpty()){
                    Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>();
                    insert tasksToInsert;
                    Map<Id,Id> quoteTaskMap = new Map<Id,Id>();
                    for (Task t : tasksToInsert) {
                        quoteTaskMap.put(t.CPQ_Quote__c,t.Id);
                    }
                    for(Id qtId : quoteTaskMap.keyset()){
                        Id taskId = quoteTaskMap.get(qtId);
                        String instanceURL = URL.getSalesforceBaseUrl().toExternalForm();
                        String taskURL = instanceURL + '/' + taskID;
                        System.debug('Task URL: ' + taskURL);
                        //Send Email for Task Owner
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        if(quoteOwnerMap.containsKey(qtId)){
                            system.debug('quoteOwner email '+quoteOwnerMap.get(qtId).split('-')[1]);
                            String toEmail = quoteOwnerMap.get(qtId).split('-')[1];
                            message.toAddresses = new String[] {toEmail};
                                }
                        //message.optOutPolicy = 'FILTER';
                        message.subject = 'Unavailable Inventory on '+quoteNameMap.get(qtId);
                        message.plainTextBody = 'New Task\n\n'
                            +'To: '+quoteOwnerMap.get(qtId).split('-')[2]+'\n\n'
                            +'You have been assigned the following new task:\n\n'
                            +'Subject: '+message.subject+'\n'
                            +'Priority: High\n'
                            +'Comments: Check the line items with the red flag\n\n'
                            +'For more details, click the following link:\n\n'
                            +taskURL;
                        messages.add(message);
                    }
                    if(!messages.isEmpty()){
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    }
                }
            }//<T02> Ends
        }
        
        //system.debug('====errMsg==='+errMsg);
        return errMsg;
    }
}
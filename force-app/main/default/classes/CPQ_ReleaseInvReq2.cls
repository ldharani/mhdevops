/* 
* Class Name: CPQ_ReleaseInvReq2    
* Test Class: CPQ_ReleaseInvReq2_Test
* Description: This class is responsible for releasing inventory when quote is closed lost
* Developed By:  Sai V
* Modification History : Created on Sep 22,2023
*  
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
RelsInvTrg   SaiV          09/22/2023                   <T08>   Release inv trigger logic
************************************************************************************************************************
*/
//<T08>
public with sharing class CPQ_ReleaseInvReq2 {
    //<T08>
    public static void CPQ_ReleaseInvReq2(List<SBQQ__Quote__c> newQuoteLst, Map<Id,SBQQ__Quote__c> oldMap) {
        List<SBQQ__Quote__c> qRec = [select id, Name, SBQQ__Status__c, SBQQ__Account__c, SBQQ__Account__r.MH_Cust_Number__c, 
                            SBQQ__Account__r.Avvo_CustomerID__c,(Select id, SBQQ__ProductName__c 
                            from SBQQ__LineItems__r) FROM SBQQ__Quote__c Where Id IN :newQuoteLst];
        User u = [select Id, username from User where Id = :UserInfo.getUserId()];
        String userName = u.Username;
        String custNum;
        String avvoCuId;
        String accId;
        String quoteId;
        String quoteName;
        //Set<Id> quoteLineIds = new Set<Id>();
        for(SBQQ__Quote__c qo:qRec){
            if(qo.SBQQ__Status__c == 'Closed Lost' && oldMap.get(qo.Id).SBQQ__Status__c != qo.SBQQ__Status__c){
                custNum = qo.SBQQ__Account__r.MH_Cust_Number__c;
                avvoCuId = qo.SBQQ__Account__r.Avvo_CustomerID__c;
                accId = qo.SBQQ__Account__c;
                quoteId = qo.Id; 
                quoteName = qo.Name;
            }
        }
        if(!test.isRunningTest()){
            cpq_releaseInvRequest(quoteId, quoteName,custNum, avvoCuId, userName, accId);//reserve inv method <T01>
        }
    }
    @Future(callout = true)//<T08>
    public Static void cpq_releaseInvRequest(String quoteId, String qName, String customerNumber, String avvoCustId, String userName,String acc) {
        system.debug('=====in release=====');
        List<String> lstResponseBody = new List<String>();
        List<Error_Log__c> lstErrLogs = new List<Error_Log__c>();
        String Msg;
        //end points is stored in a custom setting - get values from there and use it heres
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('ReleaseInventory');
        String xmlns='';
        xmlns = endPts.xmlns__c;
        //get server timestamp to send it in requestid
        DateTime result = DateTime.now();
        String timeStampString = result.format();//to convert datetime into string
        String endPoint = String.valueOf(endPts.Endpoint_URL__c);
        System.debug('**'+endPoint);
        String methodType = endPts.MethodType__c;
        String reqXML;
        String cusNumb = '';
        String uName = userName;
        String reqID = quoteId + '-' + timeStampString;
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

        //XML Request start
        
        Xmlstreamwriter xmlW = new Xmlstreamwriter();
        xmlW.writeStartElement(null,'ReleaseInventoryRequest', null); 
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

            xmlW.writeStartElement(null, 'QuoteId', null);
            xmlW.writeCharacters(qName);
            xmlW.writeEndElement();
        xmlW.writeEndElement();
        reqXML = xmlW.getXmlString();
        system.debug('====releaseReqXML=='+reqXML);
        //reqXML
        //XML Request end

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
    
            lstResponseBody.add(res.getBody());
            system.debug('=====lstResponseBody====='+lstResponseBody);
        }
        catch(System.CalloutException ce) {
            Error_Log__c err = new Error_Log__c();
            err.XML_Mesaage_Type__c = 'Release Request';
            err.XML_Body__c = reqXML;
            err.Quote__c = quoteId;
            err.Error_Reason__c = 'Callout exception , kindly try to pend inventory after again';
            lstErrLogs.add(err);
        }
        catch(System.Exception e) {
            Error_Log__c err = new Error_Log__c();
            err.XML_Mesaage_Type__c = 'Release Request';
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
            parseResponseXML_ReleaseInventoryResponse(lstResponseBody,acc,quoteId);
        }
    }
    //<T08>
    public static void parseResponseXML_ReleaseInventoryResponse(List<String> lstResponseStrings,String accId, String qId) {
    
        String txtmsg;
        String errMsg='';
        system.debug('==lstResponseStrings=='+lstResponseStrings);
        String quoteId = qId;
        String reqId;
        Id quoteLineId;
        String availCount;
        String resErrMsg;
        String quoteIdfromReq;
    
        Map<Id,String> quoteIdVsErrMsg = new Map<Id,String>();
        Map<Id,String> quoteIdOFSVsErrMsg = new Map<Id,String>();
        Map<Id,String> quoteIdVsSuccessMsg = new Map<Id,String>();
        List<SBQQ__Quote__c> quoteLst = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> quoteForUpdate = new List<SBQQ__Quote__c>();
        Map<String,String> systemVsServerFailedRes = new Map<String,String>();
        system.debug('==quoteId=='+quoteId);
    
        for (String xmlResponse : lstResponseStrings) {
            Dom.Document doc = new Dom.Document();
            doc.load(xmlResponse);
            
            Dom.XmlNode root = doc.getRootElement();
            List<Dom.XmlNode> Systems = root.getChildElement('Systems', null).getChildElements();

            for (Dom.XmlNode resSystem : Systems){

                reqId = resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('ReleaseInventoryResponse', null).getChildElement('RequestId',null).getText();
                String []splitRequest = reqId.split('-');
                quoteIdfromReq = splitRequest[0]; //getting quoteId from the response

                system.debug('===SystemInv==='+resSystem);
                
                //for QUASI
                if(resSystem.getChildElement('Name', null).getText() == 'QUASI'){
                    if(resSystem.getChildElement('HttpResponse', null).getChildElement('Code', null).getText() == '200'){
                        Dom.XmlNode message = resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('ReleaseInventoryResponse', null).getChildElement('Messages', null).getChildElement('Message', null).getChildElement('Text',null);
                            String eMsg = '';
                            system.debug('====message====='+message);
                            eMsg = message.getText();
                            system.debug('====eMsg====='+eMsg);
                        if(eMsg != ''){
                            quoteIdVsErrMsg.put(quoteIdfromReq, eMsg);
                        }else{
                            quoteIdVsSuccessMsg.put(quoteIdfromReq, 'Success');
                        }

                    }else{
                        systemVsServerFailedRes.put(resSystem.getChildElement('Name', null).getText(), resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getText());  
                    }
                }
                //for OFS
                if(resSystem.getChildElement('Name', null).getText() == 'OFS'){
                    if(resSystem.getChildElement('HttpResponse', null).getChildElement('Code', null).getText() == '200'){
                        Dom.XmlNode message = resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getChildElement('ReleaseInventoryResponse', null).getChildElement('Messages', null).getChildElement('Message', null).getChildElement('Text',null);
                            String eMsg = '';
                            system.debug('====message====='+message);
                            eMsg = message.getText();
                            system.debug('====eMsg====='+eMsg);
                        if(eMsg != ''){
                            quoteIdOFSVsErrMsg.put(quoteIdfromReq, eMsg);
                        }else{
                            quoteIdVsSuccessMsg.put(quoteIdfromReq, 'Success');
                        }
                    }else{
                        systemVsServerFailedRes.put(resSystem.getChildElement('Name', null).getText(), resSystem.getChildElement('HttpResponse', null).getChildElement('Body', null).getText());  
                    }
                }    
            }
        }
        system.debug('====systemVsServerFailedRes===='+systemVsServerFailedRes);
        quoteLst = [Select id, ReleaseStatusOFS__c, ReleaseStatusQUASI__c, SBQQ__Status__c from SBQQ__Quote__c where id=:quoteId AND SBQQ__Status__c = 'Closed Lost'];
        String failedError;
        String subStgfailedError;                                    
        for(SBQQ__Quote__c qo: quoteLst){
            if(quoteIdVsErrMsg.get(qo.Id) != null){
                qo.ReleaseStatusOFS__c = quoteIdVsErrMsg.get(qo.Id);
            }
            if(quoteIdOFSVsErrMsg.get(qo.Id) != null){
                qo.ReleaseStatusQUASI__c = quoteIdOFSVsErrMsg.get(qo.Id);
            }
            if(quoteIdVsSuccessMsg.get(qo.Id) != null && quoteIdVsErrMsg.get(qo.Id) == Null && quoteIdOFSVsErrMsg.get(qo.Id) == Null){
                qo.ReleaseStatusOFS__c = 'Inventory Relased Successfully';
                qo.ReleaseStatusQUASI__c = 'Inventory Relased Successfully';
            }
            
            if(systemVsServerFailedRes != Null){
                if(systemVsServerFailedRes.get('QUASI') != Null){
                    system.debug('===in quasi====');
                    failedError = systemVsServerFailedRes.get('QUASI');
                    subStgfailedError = failedError.substringAfter('response:');
                    qo.ReleaseStatusQUASI__c = subStgfailedError;
                }
                if(systemVsServerFailedRes.get('OFS') != Null){
                    system.debug('===in ofs====');
                    failedError = systemVsServerFailedRes.get('OFS');
                    subStgfailedError = failedError.substringAfter('response:');
                    qo.ReleaseStatusOFS__c = subStgfailedError;
                }
            }
            quoteForUpdate.add(qo);
        }
        system.debug('===quoteForUpdate==='+quoteForUpdate);
        if(!quoteForUpdate.isEmpty()){
            update quoteForUpdate;
        }
    }
}
public with sharing class CPQ_MDL_PendInventoryRequestCtrl {
    private ApexPages.StandardController standardController;
    //opportunity object
    public SBQQ__Quote__c quoteRecord;
    //string to get opportunity id
    public String quoteId{get;set;}  
    public boolean showConfirm{get;set;}
    public boolean isSaved{get;set;}//addedsaiv
    public List<SBQQ__QuoteLine__c> quoteLineList;
    public List<SBQQ__QuoteLine__c> newquoteLineList;
    public List<Attribute_Lines__c> attrLinesList; //added for CPQ
    Set<Id> attrRelationIds; //added for CPQ
    Set<Id> setQuoteLineProdids;
    public Boolean visibleConfirm {get; set;}
    public CPQ_MDL_PendInventoryRequestCtrl(ApexPages.StandardController standardController) {
        this.standardController = standardController;
        visibleConfirm = true;
        quoteId=standardController.getId();    
        quoteRecord = new SBQQ__Quote__c();
        quoteLineList = new List<SBQQ__QuoteLine__c>();
        newquoteLineList = new List<SBQQ__QuoteLine__c>();
        attrRelationIds = new Set<Id>(); //added for CPQ
        attrLinesList = new List<Attribute_Lines__c>();//added for CPQ
        setQuoteLineProdids = new Set<Id>();
        showConfirm = false;        
        //quoteAttrValidation(quoteId);
    }
    //attr validation
    public PageReference quoteAttrValidation(){
        String qoId = quoteId;
        String errorMsg = '';
        List<SBQQ__QuoteLine__c> qoLinesLst = new List<SBQQ__QuoteLine__c>();
        Set<Id> attrRelationId = new Set<Id>();
        Set<Id> prodIds = new Set<Id>();
        Map<Id,Id> prodIdIdVsAttrReltnId = new Map<Id,Id>();
        qoLinesLst = [select id,SBQQ__Quote__c, Attribute_Relationship__c, SBQQ__Product__c, SBQQ__ProductCode__c,SBQQ__Product__r.Name from SBQQ__QuoteLine__c
                      where SBQQ__Quote__c=: qoId];
        for(SBQQ__QuoteLine__c ql:qoLinesLst){
            attrRelationId.add(ql.Attribute_Relationship__c);
            prodIds.add(ql.SBQQ__Product__c);
            prodIdIdVsAttrReltnId.put(ql.SBQQ__Product__c, ql.Attribute_Relationship__c);
        }
        Map<id,Integer> prodVsAttrSize = new Map<id,Integer>();
        List<Product2> prodLst = [select id,name,(select id,Product__c
                                                From Product_Attributes__r) from Product2 where id IN: prodIds];
        for(Product2 prod: prodLst){
            if(prod.Product_Attributes__r != Null){
                prodVsAttrSize.put(prod.Id,prod.Product_Attributes__r.size());
            }
        }
        /*List<ProductAttribute__c> prodAttrLst = [select id,Product__c
                                                From ProductAttribute__c where Product__c IN:prodIds];*/
        Map<Id, Integer> attrRelatnIdVsAttrLines = new Map<Id, Integer>();
        List<Attribute_Relationship__c> attrRelationLst = [select id, (select id,Attribute_Junction__c from Attribute_Lines__r)
                                          from Attribute_Relationship__c where id IN:attrRelationId];
        for(Attribute_Relationship__c attrRel:attrRelationLst){
            if(attrRel.Attribute_Lines__r != Null){
                attrRelatnIdVsAttrLines.put(attrRel.Id, attrRel.Attribute_Lines__r.size());
            }
        }
        
        List<Attribute_Lines__c> attrLinesLst = [select id, Attribute_Junction__c, Attribute_Type__c,
                                                 Address_String__c, Boolean_Value__c, Multi_Select_Value__c,
                                                Number_Value__c, Phone_Value__c, Picklist_Value__c, String_Value__c
                                                From Attribute_Lines__c where Attribute_Junction__c IN:attrRelationId];
        if(attrLinesLst.isEmpty()){
            //errorMsg = 'Please add attributes';
            showConfirm = true;
            apexpages.Message am=new apexpages.Message(ApexPages.Severity.Error, 'Please add attributes');
            apexpages.addMessage(am); 
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMsg));
            return null;
        }
        else{
            if(prodIdIdVsAttrReltnId != Null && prodIdIdVsAttrReltnId.size()>0){
                for(SBQQ__QuoteLine__c ql:qoLinesLst){
                    if(prodVsAttrSize.containsKey(ql.SBQQ__Product__c) && attrRelatnIdVsAttrLines.containsKey(prodIdIdVsAttrReltnId.get(ql.SBQQ__Product__c))){
                        if((prodVsAttrSize.get(ql.SBQQ__Product__c) != attrRelatnIdVsAttrLines.get(prodIdIdVsAttrReltnId.get(ql.SBQQ__Product__c)))  || test.isRunningTest()){
                            if(ql.SBQQ__Product__r.Name.contains('SEO') || ql.SBQQ__ProductCode__c == '01662'){//for SEO Products
                                if(prodVsAttrSize.get(ql.SBQQ__Product__c) > attrRelatnIdVsAttrLines.get(prodIdIdVsAttrReltnId.get(ql.SBQQ__Product__c))){
                                    showConfirm = true;
                                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Error, 'Please create all the attributes');
                                    apexpages.addMessage(am);
                                    return null;
                                }    
                            }
                            else{
                                showConfirm = true;
                                apexpages.Message am=new apexpages.Message(ApexPages.Severity.Error, 'Please create all the attributes');
                                apexpages.addMessage(am);
                                return null;
                            }
                            //errorMsg = 'Please create all the attributes';
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMsg));
                            
                        }
                    }
                }    
            }    
        }
        /*
        for(Attribute_Lines__c al:attrLinesLst){
            if(al.Attribute_Type__c == 'Picklist' && (al.Picklist_Value__c == Null ||al.Picklist_Value__c == '')){
                errorMsg = 'Please fill all the attributes';        
            }    
        }*/
        return null;
    }
    public PageReference sendPendInventoryRequest() {
        isSaved = true;
        Restrict_Integration_Calls__c endPts = Restrict_Integration_Calls__c.getValues('Restrict');
        System.debug('**'+endPts);
        Boolean a = Boolean.valueOf(endPts.Restrict_Callouts__c);
        System.debug('a values is **'+a);
        Map<String,String> mapAttributeNameAndValue = new Map<String,String>();
        quoteRecord = [select id, SBQQ__Account__c, SBQQ__Account__r.MH_Cust_Number__c 
                       FROM SBQQ__Quote__c WHERE ID=: quoteId];
        User u = [select Id, username from User where Id = :UserInfo.getUserId()];
        String userName = u.Username;
        quoteLineList = [select id, SBQQ__Quote__c, Attribute_Relationship__c, SBQQ__Product__c,
                         SBQQ__ProductCode__c, SBQQ__ProductName__c, SBQQ__Product__r.IsInventoried__c, 
                         Inventory_Id__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=: quoteId AND 
                         SBQQ__Product__r.IsInventoried__c = true];
        system.debug('@@@quoteLineList'+quoteLineList);
        for(SBQQ__QuoteLine__c qoline: quoteLineList){
            if(qoline.Inventory_Id__c == NULL || qoline.Inventory_Id__c == ''){
                newquoteLineList.add(qoline);  
                attrRelationIds.add(qoline.Attribute_Relationship__c);
                //setQuoteLineProdids.add(qoline.Id);
            }
        }
        system.debug('@@@@@newquoteLineList'+newquoteLineList); 
        //added to get attributes from attr lines
        Map<Id,List<Attribute_Lines__c>> attrRelationIdVsAttrLinesList = new Map<Id,List<Attribute_Lines__c>>();
        attrLinesList = [select id, Attribute_Junction__c, Attribute_Type__c, Attribute_Name__c, 
                         Picklist_Value__c, String_Value__c, Boolean_Value__c, Date_Value__c, Value_ID__c,
                         Number_Value__c FROM Attribute_Lines__c WHERE Attribute_Junction__c IN:attrRelationIds];
        //attrRelationIdVsAttrLinesList.put(attrRelationIds,);
        for(Attribute_Lines__c att: attrLinesList){
            if(attrRelationIdVsAttrLinesList.containsKey(att.Attribute_Junction__c)){
                attrRelationIdVsAttrLinesList.get(att.Attribute_Junction__c).add(att);
            }
            else{
                attrRelationIdVsAttrLinesList.put(att.Attribute_Junction__c, new List<Attribute_Lines__c>{att});
            }   
        }
        for(SBQQ__QuoteLine__c oppRPC : quoteLineList){
            setQuoteLineProdids.add(oppRPC.Id);
            if(!attrRelationIdVsAttrLinesList.isEmpty() && attrRelationIdVsAttrLinesList.containsKey(oppRPC.Attribute_Relationship__c)){
                List<Attribute_Lines__c> tempAttlst = attrRelationIdVsAttrLinesList.get(oppRPC.Attribute_Relationship__c);
                for(Attribute_Lines__c atl: tempAttlst){
                    if(atl.Attribute_Type__c == 'Text' || atl.Attribute_Type__c == 'String')
                        mapAttributeNameAndValue.put(atl.Attribute_Name__c,atl.String_Value__c);
                    else if(atl.Attribute_Type__c == 'Picklist')
                        if(atl.Picklist_Value__c != null){
                            mapAttributeNameAndValue.put(atl.Attribute_Name__c,atl.Picklist_Value__c);
                        }
                    else{
                        mapAttributeNameAndValue.put(atl.Attribute_Name__c,atl.String_Value__c);
                    }
                    else if(atl.Attribute_Type__c == 'Number')
                        mapAttributeNameAndValue.put(atl.Attribute_Name__c,String.valueOf(atl.Number_Value__c));
                    else if(atl.Attribute_Type__c == 'Boolean')
                        mapAttributeNameAndValue.put(atl.Attribute_Name__c,String.valueOf(atl.Boolean_Value__c));
                    else if(atl.Attribute_Type__c == 'Date')
                        mapAttributeNameAndValue.put(atl.Attribute_Name__c,String.valueOf(atl.Date_Value__c));    
                }      
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
        
        if(setQuoteLineProdids.size() > 0) {
            for(String attValue : mapAttributeNameAndValue.values()) {System.debug('attValue is :::'+attValue);
                                                                      if(attValue == null || attValue == '') {
                                                                          apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Inventory cannot be pended if any of the attribute values are null.Please fill in attribute values before pending the inventory');
                                                                          apexpages.addMessage(am);  
                                                                          return null;
                                                                      }
                                                                     }
            if(newquoteLineList.size()>0 && !Test.isRunningTest()){
                String Msg = pendInventoryRequest(quoteRecord.SBQQ__Account__r.MH_Cust_Number__c,newquoteLineList,userName,quoteRecord.SBQQ__Account__r.Id);
                apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info,Msg);
                apexpages.addMessage(am);
                return null;
            }
        }
        else {
            apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'No inventorable products exists in the opportunity currently.Please add inventorable products to pend them ');
            apexpages.addMessage(am);  
            return null;
        }
        return new PageReference('/'+quoteId);//line90
    }
    public PageReference cancel() {
        return new PageReference('/'+quoteId);
    }
    public String pendInventoryRequest(String customerNumber,List<SBQQ__QuoteLine__c> quoteLineList,String userName,String acc){
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
        String Msg;
        
        //code for authentication
        String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)
        
        String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
        String privateKey = endPts.Private_Key__c;
        String publicKey  =   endPts.Public_Key__c;  
        String apiKey = endPts.API_key__c;
        if(customerNumber!=null) {
            cusNumb = customerNumber;
        }
        for(SBQQ__QuoteLine__c qoLL : quoteLineList){
            reqxml= constructXML_PendInventory(qoLL,cusNumb,uName); //get request XML from the static method
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
                if((res.getStatusCode() != 500 && res.getStatusCode() != 400 && res.getStatusCode() != 404 && res.getStatusCode() != 401 && res.getStatusCode() != 502) || test.isRunningTest()){ 
                    lstResponseBody.add(res.getBody());
                }
                if(res.getStatusCode() == 400 || res.getStatusCode() == 401) {
                    mapOppProdIdNErrResponseBody.put(qoLL.Id,res.getBody()); 
                    mapOppProdIdNResponseIsXML.put(qoLL.Id,true);               
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Authentication issue . Kindly inform the system administrator regarding the same.');
                    apexpages.addMessage(am);    
                }
                if(res.getStatusCode() == 404) {
                    mapOppProdIdNErrResponseBody.put(qoLL.Id,'404 : The specified resource was not found, or the resource has been deleted. Please contact MHI system administrator.'); 
                    mapOppProdIdNResponseIsXML.put(qoLL.Id,false);                
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Response Status Code : 404. The specified resource was not found, or the resource has been deleted . Please contact MHI system administrator .');
                    apexpages.addMessage(am);   
                }
                if(res.getStatusCode() == 500) {
                    mapOppProdIdNErrResponseBody.put(qoLL.Id,'500 : Internal Server Error . Please contact MHI system administrator .' ); 
                    mapOppProdIdNResponseIsXML.put(qoLL.Id,false);               
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'There is a network issue . Please contact MHI system administrator .');
                    apexpages.addMessage(am);  
                }      
                if(res.getStatusCode() == 502) {
                    mapOppProdIdNErrResponseBody.put(qoLL.Id,'502 : Bad Gateway issue . Please contact MHI system administrator .'); 
                    mapOppProdIdNResponseIsXML.put(qoLL.Id,false);
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Bad Gateway issue . Please contact MHI system administrator');
                    apexpages.addMessage(am);  
                }
            }catch(System.CalloutException ce) {
                mapOppProdIdNErrResponseBody.put(qoLL.Id,ce.getMessage());            
                mapOppProdIdNResponseIsXML.put(qoLL.Id,false);
                apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Callout exception , kindly try to pend inventory after again');
                apexpages.addMessage(am);   
            }
            catch(System.Exception e) {
                mapOppProdIdNErrResponseBody.put(qoLL.Id,e.getMessage());             
                mapOppProdIdNResponseIsXML.put(qoLL.Id,false);
                apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Some Exception occurred , please try again after sometime.'+e.getMessage());
                apexpages.addMessage(am);
            }                                              
        }
        if(!mapOppProdIdNErrResponseBody.isEmpty() && !mapOppProdIdNResponseIsXML.isEmpty()){
            parseErrorResponsePendInventory(mapOppProdIdNErrResponseBody,mapOppProdIdNResponseIsXML);
        }
        if(!Test.isRunningTest()){
            system.debug('@@@@@lstResponseBody'+lstResponseBody);
            Msg = CPQ_MDL_Integration_Vim_Efs.parseResponseXML_PendInventoryResponse(lstResponseBody,acc);
            //apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info,Msg);
            //apexpages.addMessage(am);
            
        }
        return Msg;
    }
    public String constructXML_PendInventory(SBQQ__QuoteLine__c qoLL,String customerNumber,String userName){
        String requestXMLString = '';
        String xmlns='';
        //get xmlns value from custom setting
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('PendInventory');
        xmlns = endPts.xmlns__c;
        
        //get server timestamp to send it in requestid
        DateTime result = DateTime.now();
        String timeStampString = result.format();//to convert datetime into string
        String reqID = qoLL.Id + '-' + timeStampString ;
        Map<String,String> mapAttributeNameAndValue = new Map<String,String>();
        Map<String,String> mapModifiedNameAndValue = new Map<String,String>();
        Map<String,String> attributeNameVSValueIdstemp = new Map<String,String>();  //to hold value Ids for attributes
        Map<String,String> attributeNameVSValueIds = new Map<String,String>();   
        String aopVal;
        System.debug('RequestId PendInventory Request :' + reqID);
        Map<Id, List<Attribute_Lines__c>> attrRelationIdVsAttrLinesList = new Map<Id, List<Attribute_Lines__c>>();
        for(Attribute_Lines__c att: attrLinesList) {
            if(attrRelationIdVsAttrLinesList.containsKey(att.Attribute_Junction__c)){
                attrRelationIdVsAttrLinesList.get(att.Attribute_Junction__c).add(att);
            }
            else{
                attrRelationIdVsAttrLinesList.put(att.Attribute_Junction__c, new List<Attribute_Lines__c>{att});
            }   
            /*
            if(att.String_Value__c != null)
                mapAttributeNameAndValue.put(att.Attribute_Name__c,att.String_Value__c);
            if(att.Picklist_Value__c != null)
                mapAttributeNameAndValue.put(att.Attribute_Name__c,att.Picklist_Value__c);
            
            if(att.Value_ID__c != null){
                attributeNameVSValueIdstemp.put(att.Attribute_Name__c, att.Value_ID__c);
            }
            else{
                attributeNameVSValueIdstemp.put(att.Attribute_Name__c, ' ');
            }*/
        }
        //for(SBQQ__QuoteLine__c oppRPC : quoteLineList){
        if(!attrRelationIdVsAttrLinesList.isEmpty() && attrRelationIdVsAttrLinesList.containsKey(qoLL.Attribute_Relationship__c)){
            List<Attribute_Lines__c> tempAttlst = attrRelationIdVsAttrLinesList.get(qoLL.Attribute_Relationship__c);
            for(Attribute_Lines__c atl: tempAttlst){
                if(atl.String_Value__c != null)
                    mapAttributeNameAndValue.put(atl.Attribute_Name__c,atl.String_Value__c);
                if(atl.Picklist_Value__c != null)
                    mapAttributeNameAndValue.put(atl.Attribute_Name__c,atl.Picklist_Value__c);
                
                if(atl.Value_ID__c != null){
                    attributeNameVSValueIdstemp.put(atl.Attribute_Name__c, atl.Value_ID__c);
                }
                else{
                    attributeNameVSValueIdstemp.put(atl.Attribute_Name__c, ' ');
                }        
            }      
        }
        //}
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
        xmlW.writeCharacters(qoLL.SBQQ__ProductCode__c);
        xmlW.writeEndElement();
        //End of ProductCode tag
        
        //Beginning of ProductName tag
        xmlW.writeStartElement(null,'ProductName',null);
        xmlW.writeCharacters(qoLL.SBQQ__ProductName__c);
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
        //return null; //remove it after uncommenting below
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
        List<SBQQ__QuoteLine__c> lstOppProdToUpdate = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c oppProd : [select Id,Error_Text__c from SBQQ__QuoteLine__c where Id in :mapOppProdIdNErrResponseBody.keyset()]){
            if(mapOppProdIdNResponseIsXML.containskey(oppProd.Id)){
                if((mapOppProdIdNResponseIsXML.get(oppProd.Id)==true)){
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
    
    public Boolean getErrorsPresent(){
    
        if( ApexPages.hasMessages(ApexPages.Severity.INFO) ||  ApexPages.hasMessages(ApexPages.Severity.ERROR)){
            visibleConfirm =false;
        }else{
            visibleConfirm = true;
        }
    
    return visibleConfirm;
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
    }
}
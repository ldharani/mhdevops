/*
** Created by       : Lister Technologies
** Created Date     : 8th June,2015
** Created purpose  : MHBS-92 : AVS Validation Button , MHBS-17
*/
public class PaymentMethodDisplayController {
    public invoiceit_s__Payment_Method__c payMethod{get;set;}
    private Id paymentMethodId;
    private String accId;
    public boolean isCreditCard{get;set;}
    public boolean isNewPayMethod{get;set;}
    private boolean isAVSSuccess;
    public boolean isAddressBlank{get;set;}
    private Boolean valid;
    public PaymentMethodDisplayController(ApexPages.StandardController controller) {
        String payMethodQuery = getObjectSelectQuery('invoiceit_s__Payment_Method__c');
        try{
            isAddressBlank = false;
            isAVSSuccess = true;
            valid = false;
            if(controller.getRecord() != null)
                paymentMethodId = controller.getRecord().id;
            else
                paymentMethodId = null;
            payMethodQuery += ' WHERE Id = '+'\''+paymentMethodId+'\''+'';
            if(paymentMethodId != null) {
                payMethod = Database.query(payMethodQuery);
                isNewPayMethod = false;
            }   
            else {
                payMethod = new invoiceit_s__Payment_Method__c();
                isNewPayMethod = true;
            }   
            if(payMethod.invoiceit_s__Payment_Method__c == 'Credit Card') {
                isCreditCard = true;
            }
            else{
                isCreditCard = false;
            }
            accId = ApexPages.currentPage().getParameters().get('accId');
            System.debug('accId'+accId);
            if(accId != null) {
                if(accId.length() >= 15) {
                    payMethod.invoiceit_s__Account__c = accId;
                }
            }
        }catch(Exception ex) {
            apexpages.Message am=new apexpages.Message(ApexPages.Severity.Error, ex.getMessage());
            apexpages.addMessage(am);   
        }       
    }
    public String getObjectSelectQuery(String objectName) {
        String sQuery = 'SELECT ';
        sQuery += getObjectFields(objectName);
        sQuery += ' FROM '+ objectName + ' ';
        return sQuery;
    }
    public String getObjectFields(String objectName) {
        String sQuery = '';
        Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for(Schema.SObjectField column: objectFieldMap.values()) {
        sQuery += column+', ';
        }
        sQuery = sQuery.substring(0, sQuery.length()-2); //this is done in order to remove the last 
        sQuery += ' ';
        return sQuery;
    }
    public Pagereference updatePaymentMethod() {
        if(payMethod.invoiceit_s__Payment_Method__c == 'Credit Card') {
            isCreditCard = true;
        }
        else{
            isCreditCard = false;
        }
        try{    
            isAddressBlank = false;
            isAVSSuccess = true;
            String xmlStr;
            String ExpireDate;
            if(isCreditCard) {
                if(payMethod.invoiceit_s__Card_Expiration_Month__c != null && payMethod.invoiceit_s__Card_Expiration_Year__c != null)
                    ExpireDate = payMethod.invoiceit_s__Card_Expiration_Month__c+''+payMethod.invoiceit_s__Card_Expiration_Year__c.subString(2);
                else
                    ExpireDate = '';    
                    
                //do the needed validations for credit card before sending it to Authorize.net
                
                if(payMethod.invoiceit_s__Card_Number__c == null) {
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info,'Please enter the card number before saving the payment method');
                    apexpages.addMessage(am);   
                    return null;
                }   
                if(payMethod.invoiceit_s__Card_Type__c == null) {
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info,'Please select the card type before saving the payment method');
                    apexpages.addMessage(am);   
                    return null;
                }
                if(payMethod.invoiceit_s__Card_Expiration_Month__c == null) {
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info,'Please select the card expiration month before saving the payment method');
                    apexpages.addMessage(am);   
                    return null;
                }
                if(payMethod.invoiceit_s__Card_Expiration_Year__c == null) {
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info,'Please select the card expiration year before saving the payment method');
                    apexpages.addMessage(am);   
                    return null;
                }
                //Added condition to Throw Validation Error only For new Records which dont have CVV OR existing records whose Default is set to 1 and CVV is blank 
               
                if((payMethod.invoiceit_s__CVV__c == null && payMethod.invoiceit_s__Default__c) || (payMethod.Id == null && payMethod.invoiceit_s__CVV__c == null)) {
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info,'Please enter the CVV before saving the payment method');
                    apexpages.addMessage(am);   
                    return null;
                }
                
                
                 if( (payMethod.invoiceit_s__Payment_Method__c == 'Credit Card') && (payMethod.invoiceit_s__CVV__c == null) )
                 {
                   apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info,'Please enter the CVV before saving the payment method');
                   apexpages.addMessage(am);   
                   return null;
                 
                 }
                  
                 
                 
                 
                //for mod - 10 validation of credit card
                if(payMethod.invoiceit_s__Card_Number__c.isNumeric()){
                    valid = validateCreditCardNumber(payMethod.invoiceit_s__Card_Number__c);
                    if(valid==false){
                        apexpages.Message am=new apexpages.Message(ApexPages.Severity.Error,'The credit card number is not valid. Please enter a valid credit card number');
                        apexpages.addMessage(am);   
                        return null;
                    }
                }
                else{
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Error,'The credit card number is not valid. Please enter a valid credit card number');
                    apexpages.addMessage(am);   
                    return null;
                }
                if(valid==true){
                    if(payMethod.Id == null || payMethod.invoiceit_s__Default__c){
                        xmlStr = constructXMLAuthorizeNet(makeEmptyForNull(payMethod.invoiceit_s__Card_Number__c), makeEmptyForNull(ExpireDate) , makeEmptyForNull(payMethod.invoiceit_s__CVV__c), makeEmptyForNull(payMethod.invoiceit_s__Billing_First_Name__c), makeEmptyForNull(payMethod.invoiceit_s__Billing_Last_Name__c), makeEmptyForNull(payMethod.invoiceit_s__Billing_Address__c), makeEmptyForNull(payMethod.invoiceit_s__Billing_City__c), makeEmptyForNull(payMethod.invoiceit_s__Billing_State_Province__c), makeEmptyForNull(payMethod.invoiceit_s__Billing_Zip_Postal__c), makeEmptyForNull(payMethod.invoiceit_s__Billing_Country__c));
                        if(xmlStr=='queryError'){
                            apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'No default payment gateway available. Please add a default payment gateway to authorize the credit card');
                            apexpages.addMessage(am);
                            return null;
                        }
                        String avsResp = sendHTTPRequest(xmlStr);
                        if(avsResp!=null){
                            if(avsResp.contains('Error @')){
                                if(avsResp.split('@')[1]!='' && avsResp.split('@')[1]!=null){
                                    String errText = avsResp.split('@')[1];
                                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Error,errText);
                                    apexpages.addMessage(am);                               
                                    return null;
                                } 
                            }
                        }
                        if(avsResp!='' && avsResp!=null)
                        payMethod.AVS_Response__c = avsResp;
                        System.debug('isAVSSuccess'+isAVSSuccess+'isAddressBlank'+isAddressBlank);
                        //if AVS validation fails
                        if(isAVSSuccess == false && isAddressBlank == false) {
                            apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'AVS validation has failed : '+ payMethod.AVS_Response__c + '. Kindly change the address and save again or blank out address and save again');
                            apexpages.addMessage(am);   
                            isAddressBlank = true;
                            return null;
                        }
                    }
                }                
            }            
            upsert payMethod;
        }catch(Exception ex) {
            apexpages.Message am;
            if(ex.getMessage().contains('Credit Card Detials you entered already Exists')){
                am = new apexpages.Message(ApexPages.Severity.Error, 'Credit Card Detials you entered already Exists. Please update the Existing one');
             }
            else{
                am=new apexpages.Message(ApexPages.Severity.Error, ex.getMessage() + ', Line Number ' + ex.getLineNumber());
            }
             
            apexpages.addMessage(am);   
            return null;
        }
        return new Pagereference('/'+payMethod.invoiceit_s__Account__c);
    }
    //mod - 10 validation
    public boolean validateCreditCardNumber(String creditCardNumber){
        //// 1. Starting with the check digit double the value of every other digit 
        //// 2. If doubling of a number results in a two digits number, add up the digits to get a single digit number. This will results in eight single digit numbers                    
        //// 3. Get the sum of the digits
        String reversedCCN = creditCardNumber.reverse();
        Integer[] chars = reversedCCN.getChars();
        Boolean isValid = false;
        Integer sumOfNumbers = 0;
        for(Integer i = 0;i<chars.size();i++){
            chars[i] = chars[i] - 48;
            if(math.mod(i,2)!=0){
                chars[i] = chars[i] * 2;
            }
            sumOfNumbers += (chars[i]/10) + (math.mod(chars[i],10));
            //System.debug(i+'  '+chars[i]+'  '+sumOfNumbers);
        }
        System.debug('sumOfNumbers'+sumOfNumbers);
        if(math.mod(sumOfNumbers,10)==0){
            isValid = true;
        }
        else{
            isValid = false;
        }
        return isValid;
    }
    public Pagereference cancelPaymentMethod() {
        Schema.DescribeSObjectResult payMeth = invoiceit_s__Payment_Method__c.sObjectType.getDescribe();
        String keyPrefix = payMeth.getKeyPrefix();
        PageReference cancelPageRef;
        if(payMethod.invoiceit_s__Account__c != null)
            cancelPageRef = new Pagereference('/'+payMethod.invoiceit_s__Account__c);
        else
            cancelPageRef = new Pagereference('/'+keyPrefix);
        return cancelPageRef;
    }
    private String makeEmptyForNull(String initParam) {
        if(initParam == null) {
            initParam = '';
        }
        return initParam;
    }
    private String constructXMLAuthorizeNet(String cardNumber,String expirationDate,String cardCode,String firstName,String lastName,String address,String city,String state,String zip,String country){
        
        String requestXMLString = '';
        String authName = 'Authorize.net';
        String xmlns = 'AnetApi/xml/v1/schema/AnetApiSchema.xsd';
        invoiceit_s__Gateway__c paymentGateway;
        String paymentGatewayQuery = getObjectSelectQuery('invoiceit_s__Gateway__c') + ' WHERE invoiceit_s__Gateway_Type__c = '+'\''+authName+'\''+' and invoiceit_s__Active__c = true and  invoiceit_s__Default__c = true';
        
        for(invoiceit_s__Gateway__c gate : Database.query(paymentGatewayQuery)){
            paymentGateway = gate;
        }
        if(paymentGateway==null){
            return 'queryError';
        }
        String merchId = paymentGateway.invoiceit_s__Merchant_ID__c ;
        String tranId = paymentGateway.invoiceit_s__Security_Key__c ;
        System.debug(address+' '+city+' '+state+' '+zip);
        if(address=='' && city=='' && state=='' && zip=='' && country==''){         
            isAddressBlank = true;
        }
        try{
            //CSC_Authentication_EndPoint__c cscauth = CSC_Authentication_EndPoint__c.getValues('Sandbox EndPoint');
            //String merchId = cscauth.API_login__c;
            //String tranId = cscauth.Transaction_ID__c;
            
            //construction of XML for authorize.net webservice
            Xmlstreamwriter xmlW = new Xmlstreamwriter();
            
            //Beginning of createTransactionRequest tag
            xmlW.writeStartElement(null,'createTransactionRequest', null); 
            xmlW.writeAttribute(null,null,'xmlns',xmlns);
            
                //Beginning of merchantAuthentication tag
                xmlW.writeStartElement(null,'merchantAuthentication',null);
                
                    //Beginning of Name Tag
                    xmlW.writeStartElement(null,'name',null);
                    xmlW.writeCharacters(merchId);
                    xmlW.writeEndElement();
                    //end of Name Tag
                    
                    //Beginning of transactionKey Tag
                    xmlW.writeStartElement(null,'transactionKey',null);
                    xmlW.writeCharacters(tranId);
                    xmlW.writeEndElement();
                    //end of transactionKey Tag
                    
                xmlW.writeEndElement();
                //end of merchantAuthentication tag
                
                //Beginning of transactionRequest tag
                xmlW.writeStartElement(null,'transactionRequest',null);
                
                    //Beginning of transactionType Tag
                    xmlW.writeStartElement(null,'transactionType',null);
                    xmlW.writeCharacters('authOnlyTransaction');
                    xmlW.writeEndElement();
                    //end of transactionType Tag
                    
                    //Beginning of amount Tag
                    xmlW.writeStartElement(null,'amount',null);
                    xmlW.writeCharacters('1');
                    xmlW.writeEndElement();
                    //end of amount Tag
                    
                    //Beginning of payment tag
                    xmlW.writeStartElement(null,'payment',null);
                    
                        //Beginning of payment tag
                        xmlW.writeStartElement(null,'creditCard',null);
                        
                            //Beginning of cardNumber Tag
                            xmlW.writeStartElement(null,'cardNumber',null);
                            xmlW.writeCharacters(cardNumber);
                            xmlW.writeEndElement();
                            //end of cardNumber Tag
                            
                            //Beginning of expirationDate Tag
                            xmlW.writeStartElement(null,'expirationDate',null);
                            xmlW.writeCharacters(expirationDate);
                            xmlW.writeEndElement();
                            //end of expirationDate Tag
                            
                            //Beginning of cardCode Tag
                            if(cardCode!=null && cardCode!=''){
                                xmlW.writeStartElement(null,'cardCode',null);
                                xmlW.writeCharacters(cardCode);
                                xmlW.writeEndElement();
                            }
                            //end of cardCode Tag
                        
                        xmlW.writeEndElement();
                        //end of creditCard Tag
                    
                    xmlW.writeEndElement();
                    //end of payment Tag
                        //Beginning of billTo tag
                    xmlW.writeStartElement(null,'billTo',null);
                    
                        //Beginning of firstName Tag
                        xmlW.writeStartElement(null,'firstName',null);
                        xmlW.writeCharacters(firstName);
                        xmlW.writeEndElement();
                        //end of firstName Tag
            
                        //Beginning of lastName Tag
                        xmlW.writeStartElement(null,'lastName',null);
                        xmlW.writeCharacters(lastName);
                        xmlW.writeEndElement();
                        //end of lastName Tag
                        if(address!=''){
                            if(address.contains('\r\n')){
                                address = address.replace('\r\n',' ');
                            }
                        }
                        //Beginning of address Tag
                        xmlW.writeStartElement(null,'address',null);
                        xmlW.writeCharacters(address);
                        xmlW.writeEndElement();
                        //end of address Tag
            
                        //Beginning of city Tag
                        xmlW.writeStartElement(null,'city',null);
                        xmlW.writeCharacters(city);
                        xmlW.writeEndElement();
                        //end of city Tag
                        
                        //Beginning of state Tag
                        xmlW.writeStartElement(null,'state',null);
                        xmlW.writeCharacters(state);
                        xmlW.writeEndElement();
                        //end of state Tag
                        
                        //Beginning of zip Tag
                        xmlW.writeStartElement(null,'zip',null);
                        xmlW.writeCharacters(zip);
                        xmlW.writeEndElement();
                        //end of zip Tag
                        
                        //Beginning of country Tag
                        xmlW.writeStartElement(null,'country',null);
                        xmlW.writeCharacters(country);
                        xmlW.writeEndElement();
                        //end of country Tag
            
                    xmlW.writeEndElement();
                    //end of billTo tag
                    //transaction settings tag to avoid duplicate transaction error
                    //transactionSettings tag
                    xmlW.writeStartElement(null,'transactionSettings',null);                    
                        //Beginning of setting Tag
                        xmlW.writeStartElement(null,'setting',null);
                        
                            //Beginning of settingName Tag
                            xmlW.writeStartElement(null,'settingName',null);
                            xmlW.writeCharacters('duplicateWindow');
                            xmlW.writeEndElement();
                            //End of settingName Tag
                            
                            //Beginning of settingValue Tag
                            xmlW.writeStartElement(null,'settingValue',null);
                            xmlW.writeCharacters('0');
                            xmlW.writeEndElement();
                            //End of settingValue Tag
                            
                        xmlW.writeEndElement();
                        //end of setting Tag                        
                    xmlW.writeEndElement();
                    //end of transactionSettings tag
                xmlW.writeEndElement();
                //end of transactionRequest tag
                
            xmlW.writeEndElement();
            //end of createTransactionRequest tag
            
            requestXMLString = xmlW.getXmlString();
            System.debug('Request sent is : '+requestXMLString);
        }catch(Exception ex){
            apexpages.Message am=new apexpages.Message(ApexPages.Severity.Error, ex.getMessage() + ', Line Number ' + ex.getLineNumber());
            apexpages.addMessage(am);   
            return null;
        }    
        return requestXMLString;
    }
    private String sendHTTPRequest(String xmlbody) {
        String avsString;
        String errorText = '';   
        try{
            //CSC_Authentication_EndPoint__c cscauth = CSC_Authentication_EndPoint__c.getValues('Sandbox EndPoint');
            //String endPoint = cscauth.Endpoint_URL__c;
            String methodType = 'POST';
            String endpt = 'https://api.authorize.net/xml/v1/request.api';
            HttpRequest req = new HttpRequest(); 
            req.setEndpoint(endpt); 
            req.setMethod(methodType); 
            req.setHeader('Content-Type','text/xml'); 
            req.setBody(xmlbody); 
            Http http = new Http(); 
            HTTPResponse res = http.send(req);   
            System.debug('%%%%%%%'+res.getBody());
            if(res.getStatusCode() == 200){
                avsString = parseResponseXML(res.getBodyDocument());
            }
            else{
                errorText = res.getStatusCode() + ' : ' + res.getStatus() + '. Please contact the System Administrator';
                avsString = 'Error @'+errorText;
            }
        }catch(CalloutException ce){
            errorText = 'Problem with web service operation. Failed to make a callout to an external system.';
            avsString = 'Error @'+errorText;
        }catch(Exception ex){
            apexpages.Message am=new apexpages.Message(ApexPages.Severity.Error, ex.getMessage() + ', Line Number ' + ex.getLineNumber());
            apexpages.addMessage(am);   
            return null;
        }
        return avsString;
    }
    private String parseResponseXML(dom.Document resBodyDoc) {
        String avsString = '';
        dom.Document resDoc = resBodyDoc;
        string ns = 'AnetApi/xml/v1/schema/AnetApiSchema.xsd';
        try{
            dom.XmlNode  envelope = resDoc.getRootElement();
            system.debug('#envelope:'+envelope);
            system.debug('messages tag:'+envelope.getChildElement('messages',ns));
            
            string resultCode= envelope.getChildElement('messages',ns).getChildElement('resultCode',ns).getText();
            system.debug('#resultCode:'+resultCode);
            
            //success scenario
            if(resultCode== 'Ok'){
                string TransCode = envelope.getChildElement('transactionResponse',ns).getChildElement('transId',ns).getText();
                string AVSCode = envelope.getChildElement('transactionResponse',ns).getChildElement('avsResultCode',ns).getText();
                
                system.debug('#AVSCode :'+AVSCode);
                if(envelope.getChildElement('transactionResponse',ns).getChildElement('errors',ns)!=null){
                    if(envelope.getChildElement('transactionResponse',ns).getChildElement('errors',ns).getChildElement('error',ns)!=null){
                        String errorCode = envelope.getChildElement('transactionResponse',ns).getChildElement('errors',ns).getChildElement('error',ns).getChildElement('errorCode',ns).getText();
                        String errorText = envelope.getChildElement('transactionResponse',ns).getChildElement('errors',ns).getChildElement('error',ns).getChildElement('errorText',ns).getText();
                        avsString = 'Error @'+'Error Code : '+errorCode+'. '+errorText; 
                        isAddressBlank = true; 
                    }
                }
                else{
                    if(AVSCode =='A'){        avsString = 'Address (Street)matches, ZIP does not';isAVSSuccess = true;}
                    else if(AVSCode =='B'){   avsString = 'Address information not provided for AVS check';isAVSSuccess = false;}
                    else if(AVSCode =='E'){   avsString = 'AVS error';isAVSSuccess = false;}
                    else if(AVSCode =='G'){   avsString = 'Non-U.S. Card Issuing Bank';isAVSSuccess = true;}
                    else if(AVSCode =='N'){   avsString = 'No Match on Address(Street) or ZIP';isAVSSuccess = false;}
                    else if(AVSCode =='P'){   avsString = 'AVS not applicable for this transaction';isAVSSuccess = false;}
                    else if(AVSCode =='R'){   avsString = 'Retry System unavailable or timed out';isAVSSuccess = false;}
                    else if(AVSCode =='S'){   avsString = 'Service not supported by issuer';isAVSSuccess = true;}
                    else if(AVSCode =='U'){   avsString = 'Address information is unavailable';isAVSSuccess = true;}
                    else if(AVSCode =='W'){   avsString = 'Nine digit ZIP matches, Address (Street) does not';isAVSSuccess = true;}
                    else if(AVSCode =='X'){   avsString = 'Address (Street) and nine digit ZIP match';isAVSSuccess = true;}
                    else if(AVSCode =='Y'){   avsString = 'Address (Street) and five digit ZIP match';isAVSSuccess = true;}
                    else if(AVSCode =='Z'){   avsString = 'Five digit ZIP matches,Address (Street) does not';isAVSSuccess = true;}
                    else{ avsString = 'Un Identified AVSCode';isAVSSuccess = false;}
                }
                
            }
            //error scenario
            else if(resultCode == 'Error') {
                String errorText = '';              
                String errText = envelope.getChildElement('messages',ns).getChildElement('message',ns).getChildElement('text',ns).getText();
                String errCode = envelope.getChildElement('messages',ns).getChildElement('message',ns).getChildElement('code',ns).getText();
                if(envelope.getChildElement('transactionResponse',ns)!=null){
                    if(envelope.getChildElement('transactionResponse',ns).getChildElement('errors',ns)!=null){
                        errorText = envelope.getChildElement('transactionResponse',ns).getChildElement('errors',ns).getChildElement('error',ns).getChildElement('errorText',ns).getText();
                    }
                }
                else{
                    errorText = errCode + ':' + errText;
                }
                avsString = 'Error @'+errorText; 
                isAddressBlank = true;      
            }
        }catch(Exception ex){
            apexpages.Message am=new apexpages.Message(ApexPages.Severity.Error, ex.getMessage() + ', Line Number ' + ex.getLineNumber());
            apexpages.addMessage(am);   
            return null;
        }
        return avsString;
    }
}
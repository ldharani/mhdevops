/**
 * Author: SaiV Ravulapati
 * Class: DocusignPaymentApi
 * Test Class:
 * Description: Docusign integration class for sending pdf, receving CC details and creation of PMs
 Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHMAC-438    SaiV        11/20/2023        John M      <T01>    Issue with Payment Method creation
************************************************************************************************************************

*/
public with sharing class DocusignPaymentApi {
    
    //Method to get access token
    public static String getAccessToken() {
        String access_token = null;
        
        //Instantiate a request object
        HttpRequest req = new HttpRequest();
        //set the request METHOD
        req.setMethod('POST');
        
        DocuSign_endpoints__c Docsendpts =  DocuSign_endpoints__c.getValues('Docusign Payment API');
        
        //set the request endpoint
        String authendpoint = Docsendpts.OAuthEndPoint__c;//'https://account-d.docusign.com/oauth/token';
        System.Debug(LoggingLevel.INFO, '**RequestAuthEndpoint' + authendpoint);
        req.setEndPoint(authendpoint);
        
        //set the request headers
        //1. Content -type
        String authRequestContentType = 'application/x-www-form-urlencoded';
        System.Debug(LoggingLevel.INFO, '**authRequestContentType ' + authRequestContentType);
        req.setHeader('Content-type', authRequestContentType);
        
        //2. Host
        String authRequestDomain = Docsendpts.OAuthReqDomain__c; //'account-d.docusign.com';
        System.Debug(LoggingLevel.INFO, '**authRequestDomain ' + authRequestDomain);
        req.setHeader('Host', authRequestDomain);
        
        Id userId =UserInfo.getUserId(); 
        User dsUser = [select id,dsfs__DSProSFUsername__c FROM User where Id=: userId];
        system.debug('dsuser===='+dsUser.dsfs__DSProSFUsername__c);
        
        String USERNAME = dsUser.dsfs__DSProSFUsername__c; //Docsendpts.Username__c;
        String PASSWORD = Docsendpts.Password__c;
        String INTEGRATOR_KEY = Docsendpts.Integration_Key__c;
        String ACCOUNT_ID = Docsendpts.Account_ID__c;
        String BASE_URL = Docsendpts.Base_URL__c;
        DocuSignSetting__mdt dsMDT = [select id, MasterLabel,alg__c,Scope__c,PrivateKey__c from DocuSignSetting__mdt where MasterLabel='JWT setting'];
        system.debug('===dsMDT===='+dsMDT);
        //DocuSignSetting__mdt  dsMDT = DocuSignSetting__mdt.getInstance('JWT_setting');
        //DocuSignSetting__mdt
        //system.debug('-==dsMDT===='+dsMDT);
        //Moved to DocuSignSetting__mdt
        String alg = dsMDT.alg__c ;//'RS256';
        String scope = dsMDT.Scope__c;//'signature spring_read spring_write';
        String pkey = dsMDT.PrivateKey__c; 
        //String pkey = 'MIIEpAIBAAKCAQEAs3ROf8jWzUbHMioeO+ufTUA4T4FY2xYavFo7FoW0EE2QgKwa4nYNwx3bb+0OsiKgC2gwT6yaC8oFt15hjvdV3uozJwP6/ufpQoUH4Q6dyfFkwkxp3IRfWtvBBBpIBaWm9nY8DU/B/pSYhXkoK0RmkPEdg/nbjwX96Q6UzlSNuamYkZubQpyZmxmVXZWII1QL4Q15gMpbtU5OqrEX4ZEYoXJf9ZEq6wG0rFO87RlYD3B8r+rJnBu9X22YfU5+gJNgJhOn+hfcbfL+ik2eDckw/53tPJgiCSstbXeuIclg9uU962vedGDL5pvY1QH8oOTwx5AAuBATJjGywwNdSHrd4wIDAQABAoIBAE/LVqBhWIn8f9RhgAIa2kHKXX+Uv0LjyE2aPY3dM9zP8IIWhPnPjn0FCK7zFMbGuK15zYmP8Qtu8C3CDNU6S3eMYeRmU7QGwOSwLHm5OxYxfSEcQzInthK7hk7htMa2CtCqcDdnEJa30j3/Soo6pvSqEfq+Hg+xlV6M+kPouwAjlwrZcoxXtr2Uc8BHH9AL8kP60mSO23+YkNppuny6FjiJMo3ULdH+b1il1xo+Nn72i4uMzcM+7C78KXqHhB1FWvLP3he9hZK0chYGYgVgi2+J0tm0hLtEbOd44wIXZasewDTnIFeeCUymO67TBz3MQ7twLq0cmd9+9JXAFtJ4l8kCgYEA6O5lGUKFxOBol3kSTUOhnfZXNHQXqGrDay42ZowsjhKVfQ2adWEmcQIGBjLMsQVWQOuIBhqRsGrFZd/9VK6tWmBvep52243r/lOrcv4a71E7PcUg28JlhmpzSeg2ZJwMZgCEF8yMl8xNoMh7feH+a2K/INQ5pysHx00WuG5O4e8CgYEAxToWvPvcgelj25BPifrn5m/qkBPvQQW4pSPjMs0QZDKk88gYMz1fhsEtgHi8MkK2OxTBav97YoerOXOtQiEpClj027k58gAVS7BcgPY8FwnnbiNAOYOP4PCtGcy1XPLkVwdrC9R2J0VURNAWhcQvPNMX2vfG3SohEpvOwLaCp00CgYBg6YbwqofDcOazVvExalkcwrhnn4GUVc82kcSah+mltr+xhu5jtebrj7735zzYzfKkEhrHB1jkQJgemcHp8L85YfQf3TxwfqzYZPFpZ6XHOlHeklzocgoRkcqjzlSLKY3TBpXu3PEF2z/VDHSs3FEhVrVUsFfIYJPc7Qrt8x8oywKBgQCC8FvkP/pXrZGEVbzYyGFplefOm81+B8RcrwTJ12cIfq8Qwkl+y0I+fsYswvt/CtddRhxbYx6Rfazpyai/fLB4lDKMJd8YkYGR7Jadb9zZFtQ1ROYAyR2eo2ro9AV8ni2GsgAZrIZ88ARQYy5wxJzv7t2pnFLExpGKfzK2svTvCQKBgQDe9euk5LWOCNrHK+e3Q8cmZOaOxWUduG2Ry0tVFrKR9QmR9aqjb6uQrnisTvEK8yE5uLxASgEULS3M3rMlLzLb8RkaVHsFwjkgpPv56q7FTK7C2PwsQY3E9Ip1Ejv26bjAy/ymY4lhhKEm1q/apPGw6484GK3Rf/QM0b42McK0hw==';
        //end        
        DocuSignJWT jwtObject = new DocuSignJWT(alg, USERNAME, INTEGRATOR_KEY, pkey, scope, authRequestDomain);
        String requestBody = '';
        //Set the request body  
        if (!Test.isRunningTest()) {
            requestBody = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion='+ jwtObject .issue();
        }else{
            requestBody = 'test-token-will-not-be-used';
        }
         
        System.Debug(LoggingLevel.INFO, '**RequestAuthBody' + requestBody);
        req.setBody(requestBody);
        
        //call the service
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        System.Debug(LoggingLevel.INFO, '**ResponseAuthBody' + res.getbody());
        System.Debug(LoggingLevel.INFO, '**ResponseAuth' + res);
        
        //Obtain the access token from the Response
        if (res.getStatusCode() == 200) {
            System.JSONParser parser = System.JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    access_token = parser.getText();
                    break;
                }
            }
        }
        system.debug('==access_token=='+access_token);
        return access_token;
        
    }
    
    //Method to generate envelope and send via Docusign
    @future (callout=true)
    public static void generateandSendEnvelope(String quoteId, String ccEmail, String emailSub, String emailBody){
        system.debug('====quoteId'+quoteId);
        List<SBQQ__Quote__c> qoLst = new List<SBQQ__Quote__c>();
        List<blng__PaymentMethod__c> existingPMs = new List<blng__PaymentMethod__c>();
        List<blng__PaymentMethod__c> allPMs = new List<blng__PaymentMethod__c>();
        Date SentDate = system.today();
        String billingEmail = '';
        String billingName = '';
        String Sender = '';
        String SenderEmail = '';
        String Subject = '';
        String accName = '';
        String recordtypeName = '';
        String Body = '';
        Id accId;
        if(quoteId != Null){
            qoLst = [select id,SBQQ__Account__c,SBQQ__Account__r.Name,PrimaryContactEmail__c, Billing_Contact__r.email,SBQQ__SalesRep__r.Name,RecordType.Name,
                     SBQQ__SalesRep__r.Email,Billing_Contact__r.FirstName, Billing_Contact__r.LastName from SBQQ__Quote__c where id=:quoteId];
            for(SBQQ__Quote__c q:qoLst){
                billingEmail = q.Billing_Contact__r.email;
                billingName = q.Billing_Contact__r.FirstName+' '+q.Billing_Contact__r.LastName;
                Sender = q.SBQQ__SalesRep__r.Name;
                SenderEmail = q.SBQQ__SalesRep__r.Email;
                //Subject = 'Martindale Test Agreement'+q.SBQQ__Account__r.Name;
                system.debug('emailsubinpaymentAPI====='+emailSub);
                if(emailSub != null){
                    Subject = emailSub;    
                }else{
                    if(q.RecordType.Name == 'M-A Quote'){
                        Subject = 'Martindale-Avvo Agreement for '+q.SBQQ__Account__r.Name;
                    }else{
                        Subject = 'Martindale-Hubbell Agreement for '+q.SBQQ__Account__r.Name;
                    }
                    //Subject = 'Martindale Agreement'+q.SBQQ__Account__r.Name;    
                }
                if(emailBody != null){
                   Body = emailBody;
                }
                accId = q.SBQQ__Account__c;
                accName = q.SBQQ__Account__r.Name;
            }
        }
        system.debug('====billingEmail'+billingEmail);
        system.debug('====billingName'+billingName);
        system.debug('====ccEmail'+ccEmail);
        system.debug('====Subject'+Subject);
        //To get existing PMs on account
        //String TodayMonth = '';
        //String TodayYear = '';
        Integer TodayMonth = Date.today().month();
        Integer TodayYear = Date.today().year();
        system.debug('==month'+TodayMonth);
        system.debug('==year'+TodayYear);
        allPMs = [select id, blng__Account__c, blng__CardExpirationMonth__c, blng__PaymentType__c, blng__CardExpirationYear__c from blng__PaymentMethod__c where blng__Account__c=:accId 
                       AND blng__Active__c = TRUE];
        //AND (blng__CardExpirationYear__c > 'TodayYear' OR blng__CardExpirationYear__c = 'TodayYear') AND (blng__CardExpirationMonth__c > 'TodayMonth' OR blng__CardExpirationMonth__c = 'TodayMonth')];
        
        system.debug('====allPMs'+allPMs);
        for(blng__PaymentMethod__c pm:allPMs){
            if(pm.blng__PaymentType__c == 'Credit Card'){
                Integer cardExp = integer.valueof(pm.blng__CardExpirationMonth__c);
                Integer cardExpYear = integer.valueof(pm.blng__CardExpirationYear__c);
                system.debug('==cardExp===='+cardExp);
                system.debug('==cardExpYear===='+cardExpYear);
                if(cardExpYear > TodayYear){
                    system.debug('==pm===='+pm);  
                    existingPMs.add(pm);
                }else if(cardExpYear == TodayYear){
                    if(cardExp >= TodayMonth){
                        existingPMs.add(pm);
                    }
                }
            }else{
                existingPMs.add(pm);
            }
        }
        system.debug('==existingPMs===='+existingPMs);  
        //payment gateway accID - 52b2cbbc-5982-47d7-bdde-268803368d18  
        ContentDocumentLink contentlink = [select id,LinkedEntityId,contentdocumentid, SystemModstamp from ContentDocumentLink where LinkedEntityId=:quoteId order by SystemModstamp DESC limit 1];
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId, versionData 
                                           FROM ContentVersion WHERE contentdocumentid = :contentlink.contentdocumentid];
                                           
        //Get the access token
        String accessToken = getAccessToken();
        String reqBody;
        String responseBody;
        
        String contentTitle = contentVersion_2.Title;
        system.debug('====contentTitle===='+contentTitle);            
        
        DocuSign_endpoints__c authEndPts =  DocuSign_endpoints__c.getValues('AuthNet Details');
        String authNetGateWayId = authEndPts.Integration_Key__c; 
        if(!String.isEmpty(accessToken)){
            String DocumentID = '1';
            //JSON Req Body
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('documents');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('documentBase64',EncodingUtil.base64Encode(contentVersion_2.versionData));
            gen.writeStringField('documentId','1');
            gen.writeStringField('fileExtension','pdf');
            gen.writeStringField('name',contentTitle);
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeStringField('emailSubject', Subject);
            gen.writeFieldName('customFields');
            gen.writeStartObject();
            gen.writeFieldName('textCustomFields');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('name','##SFOpportunity');
            gen.writeStringField('show','false');
            gen.writeStringField('required','false');
            gen.writeStringField('value',quoteId); //quoteId
            gen.writeEndObject();
            
            gen.writeEndArray();
            gen.writeEndObject();
            gen.writeFieldName('recipients');
            gen.writeStartObject();
            gen.writeFieldName('signers');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('email',
                                 
                                 billingEmail
                                );
            gen.writeStringField('name',
                                 
                                 billingName
                                );
            gen.writeStringField('recipientId','1');
            gen.writeStringField('routingOrder','1');
            gen.writeFieldName('emailNotification');
            gen.writeStartObject();
            gen.writeStringField('emailSubject', Subject);
            gen.writeStringField('EmailBody', Body);
            gen.writeStringField('supportedLanguage','en');
            gen.writeEndObject();
            gen.writeFieldName('tabs');
            gen.writeStartObject();
            
            //PAYMENT WIDGET ADDITION TO THE DOC/
            gen.writeFieldName('formulaTabs');
                gen.writeStartArray();
                if(existingPMs.isEmpty()){
                    gen.writeStartObject();
                        gen.writeStringField('required','true');
                        gen.writeStringField('formula','1 * 100');
                        gen.writeStringField('roundDecimalPlaces','2');
                        gen.writeFieldName('paymentDetails');
                        gen.writeStartObject();
                            gen.writeStringField('currencyCode','USD');
                            gen.writeStringField('gatewayAccountId', authNetGateWayId
                                                );
                            gen.writeStringField('paymentOption','save_and_authorize');
                        gen.writeEndObject();
                        gen.writeStringField('tabLabel','Payment1');
                        gen.writeStringField('documentId','1');
                        gen.writeStringField('pageNumber','1');
                        gen.writeStringField('xPosition','0');
                        gen.writeStringField('yPosition','0');
                        gen.writeStringField('show', 'false');
                    gen.writeEndObject();
                }/*else{
                   gen.writeStartObject();
                        gen.writeStringField('required','false');
                        gen.writeStringField('formula','1 * 100');
                        gen.writeStringField('roundDecimalPlaces','2');
                        gen.writeFieldName('paymentDetails');
                        gen.writeStartObject();
                            gen.writeStringField('currencyCode','USD');
                            gen.writeStringField('gatewayAccountId', '52b2cbbc-5982-47d7-bdde-268803368d18'
                                                );
                            gen.writeStringField('paymentOption','save_and_authorize');
                        gen.writeEndObject();
                        gen.writeStringField('tabLabel','Payment1');
                        gen.writeStringField('documentId','1');
                        gen.writeStringField('pageNumber','1');
                        gen.writeStringField('xPosition','0');
                        gen.writeStringField('yPosition','0');
                        gen.writeStringField('show', 'false');
                    gen.writeEndObject(); 
                }*/
            gen.writeEndArray();
            
            gen.writeFieldName('signHereTabs');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('anchorString','sign');
            gen.writeStringField('anchorXOffset','0');
            gen.writeStringField('anchorYOffset','0');
            gen.writeStringField('anchorUnits', 'Pixels');
            gen.writeStringField('documentId', '1');
            gen.writeStringField('recipientId', '1');
            gen.writeStringField('tabLabel', 'Sign Here');
            gen.writeStringField('name', 'Sign Here');
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeFieldName('checkboxTabs');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('anchorString','true');
            gen.writeStringField('anchorXOffset','0');
            gen.writeStringField('anchorYOffset','0');
            gen.writeStringField('anchorUnits', 'Pixels');
            gen.writeStringField('documentId', '1');
            gen.writeStringField('recipientId', '1');
            gen.writeStringField('name', 'AutoPay');
            gen.writeStringField('tabLabel', 'AutoPay');
            gen.writeStringField('font', 'Helvetica');
            gen.writeStringField('selected', 'true');
            gen.writeStringField('locked', 'false');
            gen.writeStringField('fontSize', 'Size14');
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndArray();
            //if(ccEmail != null){
                gen.writeFieldName('carbonCopies');
                gen.writeStartArray();
                gen.writeStartObject();
                gen.writeStringField('email', SenderEmail
                                    );
                gen.writeStringField('name',
                                     
                                     Sender
                                    );
                gen.writeStringField('routingOrder','1');
                gen.writeFieldName('emailNotification');
                gen.writeStartObject();
                gen.writeStringField('emailSubject',Subject);
                gen.writeStringField('EmailBody', Body);
                gen.writeStringField('supportedLanguage','en');
                gen.writeEndObject();
                gen.writeStringField('recipientId', '2');
                //gen.writeEndObject();
                gen.writeEndObject();
                //email to carbon copy
            if(ccEmail != null){
                gen.writeStartObject();
                gen.writeStringField('email', ccEmail
                                    );
                gen.writeStringField('name',
                                     
                                     ccEmail
                                    );
                gen.writeStringField('routingOrder','2');
                gen.writeFieldName('emailNotification');
                gen.writeStartObject();
                gen.writeStringField('emailSubject',Subject);
                gen.writeStringField('EmailBody', Body);
                gen.writeStringField('supportedLanguage','en');
                gen.writeEndObject();
                gen.writeStringField('recipientId', '3');
                gen.writeEndObject();
            }
                //end
                //T02
                gen.writeEndArray();
            //}//endingif
            gen.writeEndObject();
            gen.writeStringField('status','sent');
            gen.writeEndObject();
            String JSONString = gen.getAsString();
            system.debug('JSONString');                                 
            //return JSONString;
            DocuSign_endpoints__c Docsendpts =  DocuSign_endpoints__c.getValues('Docusign Payment API');
            String USERNAME = Docsendpts.Username__c;
            String PASSWORD = Docsendpts.Password__c;
            String INTEGRATOR_KEY = Docsendpts.Integration_Key__c;
            String ACCOUNT_ID = Docsendpts.Account_ID__c;
            String BASE_URL = Docsendpts.Base_URL__c;                         
            Http httpProtocol = new Http();
            HttpRequest request = new HttpRequest();
            String endpoint = String.format('{0}/accounts/{1}/envelopes/', new String[]{BASE_URL, ACCOUNT_ID});
            System.Debug(LoggingLevel.INFO, '***endpoint ' + endpoint);
            request.setEndPoint(endpoint);
            request.setMethod('POST');
            request.setHeader('grant_type', 'Bearer');
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            request.setHeader('Accept', 'application/json');
            request.setHeader('Content-type', 'application/json');
            request.setBody(JSONString);
            //request.setTimeout(20);
            HttpResponse response = httpProtocol.send(request);
            System.Debug(LoggingLevel.INFO, '***response.getBody() ' + response.getBody());
            System.debug(LoggingLevel.INFO, '***response.getStatus() ' + response.getStatus());
            if (response.getStatus() == 'Created') {
                System.debug('=Received details='+response.getBody());
            }  
            responseBody = response.getBody();
            system.debug('responseBody'+responseBody);
            Map<Object,String> mapDeserializedJSONBody = new Map<Object,String>();
            String EnvelopeId;
            String EnvelopeLink;
            if(responseBody != null){
                DsEnvelopeJson2Apex objResponse = (DsEnvelopeJson2Apex) JSON.deserialize(responseBody, DsEnvelopeJson2Apex.class);
                system.debug('objResponse'+objResponse);
                EnvelopeId = objResponse.envelopeId;
                EnvelopeLink = objResponse.uri;
                if(EnvelopeId != Null){
                    DocusignPaymentApi.createDSstatusRecord(EnvelopeId, quoteId, EnvelopeLink, billingName, billingEmail, Subject, Sender, SenderEmail);
                }
            }
        }
    }
    //To create DocuSign Status Record
    public static void createDSstatusRecord(String EnvelopeId, String quoteId, String EnvelopeLink, 
                                            String recipient, String recipientEmail, String subject,
                                           String Sender, String SenderEmail){
        system.debug('==EnvelopeId=='+EnvelopeId);
        system.debug('==quoteId=='+quoteId);
        //do stuff
        //EnvelopeLink__c 
        DocuSign_endpoints__c Docsendpts =  DocuSign_endpoints__c.getValues('Docusign Payment API');
        String EnvelopLink = Docsendpts.EnvelopeLink__c;                             
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c();
        ds.Quote__c = quoteId;
        ds.dsfs__DocuSign_Envelope_ID__c = EnvelopeId;
        ds.dsfs__Subject__c = subject;
        ds.dsfs__Sender__c = Sender;
        ds.dsfs__Sender_Email__c = SenderEmail;
        ds.dsfs__Envelope_Status__c = 'Sent';
        ds.dsfs__Sent_Date_Time__c = DateTime.Now();
        ds.dsfs__Envelope_Link__c = EnvelopeId+EnvelopLink+EnvelopeId; //for prod -https://app.docusign.com?back=documents/details/
        Insert ds;
        //DocusignPaymentApi.createDSRecipientRecords();                                    
    }
    /*
    public static void createDSRecipientRecords(){
        
    }*/
    //Method to get Customer and Payment Ids from Docusign
    @future (callout=true)
    public static void getPaymntInfo(String envelopeId, String quoteId){
        //Get the access token
        String accessToken = getAccessToken();
        System.Debug(LoggingLevel.INFO, '***accessTokenPMinfo ' + accessToken);
        String customerProfileId;
        //String paymentProfileId;
        List<Object> paymentProfileId;
        String responseBody;
        String CustomerId;
        String PaymentSourceId;
        String ChargeId; //transactionId
        
        if (!String.isEmpty(accessToken)) {
            //instantiate an Http instance  
            Http httpProtocol = new Http();
            
            //instantiate an HttpRequest instance  
            HttpRequest request = new HttpRequest();
            
            DocuSign_endpoints__c Docsendpts =  DocuSign_endpoints__c.getValues('Docusign Payment API');
            String USERNAME = Docsendpts.Username__c;
            String PASSWORD = Docsendpts.Password__c;
            String INTEGRATOR_KEY = Docsendpts.Integration_Key__c;
            String ACCOUNT_ID = Docsendpts.Account_ID__c;
            String BASE_URL = Docsendpts.Base_URL__c;
            
            String endpoint = String.format('{0}/accounts/{1}/envelopes/{2}/recipients/1/tabs', new String[]{BASE_URL, ACCOUNT_ID, envelopeId});
            System.Debug(LoggingLevel.INFO, '***endpoint ' + endpoint);
            request.setEndPoint(endpoint);
            
            //set the POST method
            request.setMethod('GET');
            
            //set Authentication Header
            request.setHeader('grant_type', 'Bearer');
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            
            //set Accept Header
            request.setHeader('Accept', 'application/json');
            
            //set Content Type Header
            request.setHeader('Content-type', 'application/json');
            
            //set Empty Body - Check out https://developers.docusign.com/docs/clm-api/reference/Objects/Folders/Search/ for more details if required
            //request.setBody('');
            
            //Make the request and capture the response
            HttpResponse response = httpProtocol.send(request);
            System.Debug(LoggingLevel.INFO, '***response.getBody() ' + response.getBody());
            System.debug(LoggingLevel.INFO, '***response.getStatus() ' + response.getStatus());
            
            if (response.getStatusCode() == 200) {
                System.debug('=Received details='+response);
                responseBody = response.getBody();
            }
            system.debug('responseBody'+responseBody);
            //return responseBody;
            //getPaymntIdfromJsonResponse(response);
            //Map<String, Object> mapDeserializedJSONBody = new Map<String, Object>();
            Map<Object,String> mapDeserializedJSONBody = new Map<Object,String>();
            if(responseBody != null){
                DsJson2Apex objResponse = (DsJson2Apex) JSON.deserialize(responseBody, DsJson2Apex.class);
                system.debug('objResponseDS===='+objResponse);
                if(objResponse != null && objResponse.formulaTabs != null){
                    for(DsJson2Apex.cls_formulaTabs fTabInfo: objResponse.formulaTabs){
                        system.debug('custId'+fTabInfo.paymentDetails.customerId);
                        CustomerId = fTabInfo.paymentDetails.customerId;
                        PaymentSourceId = fTabInfo.paymentDetails.paymentSourceId;
                        ChargeId = fTabInfo.paymentDetails.chargeId;
                        getPaymentMethodDetails(CustomerId,PaymentSourceId,quoteId,ChargeId);
                        //voidDocuSignTransaction(ChargeId);
                    }
                }
            }
        }
    }
    //Method to get payment details and creation of payment method
    public static void getPaymentMethodDetails(String CustomerId, String PaymentSourceId, String quoteId, String ChargeId){
        system.debug('=CustomerId='+CustomerId);
        system.debug('=PaymentSourceId='+PaymentSourceId);
        system.debug('=quoteId='+quoteId);
        List<SBQQ__Quote__c> qoLst = [select id,SBQQ__Account__c,SBQQ__Account__r.Business_Unit__c,PrimaryContactEmail__c, Billing_Contact__r.email from SBQQ__Quote__c where id=:quoteId];
        String accId = qoLst[0].SBQQ__Account__c;
        String email = qoLst[0].Billing_Contact__r.email;
        String busUnit = qoLst[0].SBQQ__Account__r.Business_Unit__c;
        String paymntMthdId; //to store inserted payment method ID for payment creation
        String accountId; //to store account Id for payment creation
        String businessUnit;
        system.debug('email'+email);
        List<blng__PaymentMethod__c> oldPaymntMethodUpdate = new List<blng__PaymentMethod__c>();
        //List<SBQQ__Quote__c> qoToUpdate = new List<SBQQ__Quote__c>();
        DocuSign_endpoints__c authEndPts =  DocuSign_endpoints__c.getValues('AuthNet Details');
        String responseBody;
        String endpoint = authEndPts.Base_URL__c;//'https://apitest.authorize.net/xml/v1/request.api';//need to move this to custom setting
        String API_Login = authEndPts.Username__c; //'2bH9W37zeDTP';//need to move this to custom setting
        String Transaction_key = authEndPts.Password__c;//'6U7g65wm2BMn8S4R';//need to move this to custom setting
        String paymntGateWayId = authEndPts.Account_ID__c;
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        //string messageBody1 = '{"getCustomerPaymentProfileRequest": {"merchantAuthentication": {"name":"'+API_Login+'","transactionKey":"'+Transaction_key+'"},"customerProfileId": "'+CustomerId+'","customerPaymentProfileId": "'+PaymentSourceId+'","includeIssuerInfo": "true"},"unmaskExpirationDate":"true"}';
        string messageBody1 = '{"getCustomerPaymentProfileRequest": { "merchantAuthentication": {"name":"'+API_Login+'","transactionKey": "'+Transaction_key+'"},"customerProfileId": "'+CustomerId+'","customerPaymentProfileId": "'+PaymentSourceId+'","unmaskExpirationDate": "true","includeIssuerInfo": "true"}}';
        
        system.debug('==messageBody1=='+messageBody1);
        req.setHeader('Content-length', String.valueOf(messageBody1.length()));
        req.setBody(messageBody1);
        req.setEndPoint(endpoint);
        
        req.setTimeout(60*1000);
        Http h1 = new Http();
        String resp1;
        HttpResponse res1 = h1.send(req);
        system.debug('==http response=='+res1);
        system.debug('==httpBody=='+res1.getBody());
        responseBody = res1.getBody();
        //return res1.getBody();
        //String businessUnit = '';
        if(accId != Null){
            List<blng__PaymentMethod__c> existPaymntMthd = [select id,blng__Active__c,
                                                            blng__AutoPay__c,blng__Account__c, blng__Account__r.Business_Unit__c from blng__PaymentMethod__c
                                                            where blng__Account__c =:accId];
            system.debug('==existPaymntMthd=='+existPaymntMthd);
            for(blng__PaymentMethod__c ePM: existPaymntMthd){
                if(ePM.blng__AutoPay__c == TRUE){
                    ePM.blng__AutoPay__c = FALSE;
                    oldPaymntMethodUpdate.add(ePM);
                }
            }
        }    
        
        List<blng__PaymentMethod__c> paymntMethodInsert = new List<blng__PaymentMethod__c>();
        if(responseBody!= Null){
            responseBody = responseBody.trim().replace('\uFEFF', '');
            JSONParser parser = JSON.createParser(responseBody);
            //AuthNetJson2Apex objResponse = (AuthNetJson2Apex) JSON.deserialize(responseBody, AuthNetJson2Apex.class);
            AuthNetJson2Apex objResponse = (AuthNetJson2Apex) parser.readValueAs(AuthNetJson2Apex.class);
            system.debug('objResponse'+objResponse);
            //system.debug('objResponse'+objResponse.paymentProfile.payment.bankAccount);
            if(objResponse.paymentProfile.payment.bankAccount != NULL){
                
                //String accNumstr = objResponse.paymentProfile.payment.bankAccount.accountNumber;
                //String accNum = accNumstr.right(4);
                //Integer accNum = Integer.valueOf(result);
                //system.debug('====accNum====='+accNum);
                //String accRoutingNum
                
                blng__PaymentMethod__c paymntmtd = new blng__PaymentMethod__c();
                paymntmtd.blng__Active__c = True;
                paymntmtd.blng__AutoPay__c = True;
                paymntmtd.blng__Account__c = accId;
                paymntmtd.Payment_Profile_ID__c = CustomerId;
                paymntmtd.blng__PaymentType__c = 'ACH';
                paymntmtd.blng__PaymentGateway__c = paymntGateWayId;//'a613w000001dyJ6';
                paymntmtd.isCreatedbyDS__c = TRUE;
                paymntmtd.blng__BankAccountNumber__c = objResponse.paymentProfile.payment.bankAccount.accountNumber;
                system.debug('===acctype==='+objResponse.paymentProfile.payment.bankAccount.accountType);
                paymntmtd.blng__BankAccountType__c = objResponse.paymentProfile.payment.bankAccount.accountType;
                paymntmtd.blng__BankAccountName__c = objResponse.paymentProfile.payment.bankAccount.nameOnAccount;
                //objResponse.paymentProfile.payment.bankAccount.accountType
                paymntmtd.blng__BankRoutingCode__c = objResponse.paymentProfile.payment.bankAccount.routingNumber;
                paymntmtd.blng__BillingFirstName__c = objResponse.paymentProfile.billTo.firstName;
                paymntmtd.blng__BillingLastName__c = objResponse.paymentProfile.billTo.lastName;
                //paymntmtd.blng__BillingEmail__c = 'vihari.ramachandra@gmail.com';
                paymntmtd.blng__BillingEmail__c = email;
                paymntmtd.blng__BankName__c = 'Standard';
                 paymntmtd.ChargeId__c = ChargeId;
                paymntMethodInsert.add(paymntmtd);
            }else{
                //String cc = objResponse.paymentProfile.payment.creditCard.cardNumber;
                blng__PaymentMethod__c paymntmtd = new blng__PaymentMethod__c();
                paymntmtd.blng__Active__c = True;
                paymntmtd.blng__AutoPay__c = True;
                paymntmtd.blng__Account__c = accId;
                paymntmtd.Payment_Profile_ID__c = CustomerId;
                 paymntmtd.isCreatedbyDS__c = TRUE;
                paymntmtd.Card_Number__c = objResponse.paymentProfile.payment.creditCard.cardNumber;
                paymntmtd.blng__Nameoncard__c = objResponse.paymentProfile.billTo.firstName+' '+objResponse.paymentProfile.billTo.lastName;
                if(objResponse.paymentProfile.payment.creditCard.cardType =='AmericanExpress'){
                    paymntmtd.blng__CardType__c = 'American Express';
                }else{
                    paymntmtd.blng__CardType__c = objResponse.paymentProfile.payment.creditCard.cardType;
                }
                String expDate = objResponse.paymentProfile.payment.creditCard.expirationDate;
                paymntmtd.blng__CardExpirationMonth__c = expDate.right(2).substring(0,2);
                paymntmtd.blng__CardExpirationYear__c = expDate.substring(0, 4);
                system.debug('==cardmonth==='+paymntmtd.blng__CardExpirationMonth__c);
                system.debug('==cardyear=='+paymntmtd.blng__CardExpirationYear__c);
                //paymntmtd.blng__CVV__c = opp.CVV__c;
                paymntmtd.blng__BillingStreet__c = objResponse.paymentProfile.billTo.address;
                paymntmtd.blng__BillingCity__c = objResponse.paymentProfile.billTo.city;
                if((objResponse.paymentProfile.billTo.country == 'US'|| objResponse.paymentProfile.billTo.country == 'USA' ||objResponse.paymentProfile.billTo.country == 'United States'||objResponse.paymentProfile.billTo.country == 'U.S.A')|| test.isRunningTest()){
                    paymntmtd.blng__BillingCountry__c = 'United States';
                }
                paymntmtd.blng__BillingStateProvince__c = objResponse.paymentProfile.billTo.state;
                paymntmtd.blng__BillingZipPostal__c = objResponse.paymentProfile.billTo.zip;
                paymntmtd.blng__PaymentType__c = 'Credit Card';
                paymntmtd.blng__PaymentGateway__c = paymntGateWayId;//'a613w000001dyJ6'; //need to move to custom setting
                paymntmtd.blng__BillingFirstName__c = objResponse.paymentProfile.billTo.firstName;
                paymntmtd.blng__BillingLastName__c = objResponse.paymentProfile.billTo.lastName;
                //paymntmtd.blng__BillingEmail__c = 'vihari.ramachandra@gmail.com';
                paymntmtd.blng__BillingEmail__c = email;
                paymntmtd.blng__PaymentGatewayToken__c = PaymentSourceId;
                paymntmtd.ChargeId__c = ChargeId;
                paymntMethodInsert.add(paymntmtd);
            }
            system.debug('paymntMethodInsert'+paymntMethodInsert);   
        }
        if(!oldPaymntMethodUpdate.isEmpty()){
            Update oldPaymntMethodUpdate;
        }
        if(!paymntMethodInsert.isEmpty()){
            Insert paymntMethodInsert;
        }
    }
    //void transaction only for MH CC authentication
    public static void voidDocuSignTransaction(String pmId, String ChargeId){ 
    //public static void voidDocuSignTransaction(Set<Id> paymntTransacId){ 
        List<blng__PaymentMethod__c> payMtForUpdate = new List<blng__PaymentMethod__c>();
        system.debug('=====ChargeId===='+ChargeId);
        String responseBody;
        DocuSign_endpoints__c authEndPts =  DocuSign_endpoints__c.getValues('AuthNet Details');
        String endpoint = authEndPts.Base_URL__c;//'https://apitest.authorize.net/xml/v1/request.api';//need to move this to custom setting
        String API_Login = authEndPts.Username__c; //'2bH9W37zeDTP';//need to move this to custom setting
        String Transaction_key = authEndPts.Password__c;//'6U7g65wm2BMn8S4R';//need to move this to custom setting
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        string messageBody1 = '{"createTransactionRequest": {"merchantAuthentication": {"name": "'+API_Login+'","transactionKey": "'+Transaction_key+'"},"transactionRequest": {"transactionType": "voidTransaction","refTransId": "'+ChargeId+'"}}}';
        
        system.debug('==messageBody1=='+messageBody1);
        req.setHeader('Content-length', String.valueOf(messageBody1.length()));
        req.setBody(messageBody1);
        req.setEndPoint(endpoint);
        
        req.setTimeout(60*1000);
        Http h1 = new Http();
        String resp1;
        HttpResponse res1 = h1.send(req);
        system.debug('==http response=='+res1);
        system.debug('==httpBody=='+res1.getBody());
        responseBody = res1.getBody();  
        
        String callMsg = '';
        
        if(responseBody!= Null){
            responseBody = responseBody.trim().replace('\uFEFF', '');
            JSONParser parser = JSON.createParser(responseBody);
            //AuthNetJson2Apex objResponse = (AuthNetJson2Apex) JSON.deserialize(responseBody, AuthNetJson2Apex.class);
            AuthNetVoidTransJson2Apex objResponse = (AuthNetVoidTransJson2Apex) parser.readValueAs(AuthNetVoidTransJson2Apex.class);
            system.debug('objResponse'+objResponse);
            system.debug('====response code===='+objResponse.messages.message);
            for(AuthNetVoidTransJson2Apex.cls_message msg: objResponse.messages.message){
                if(msg.text == 'Successful.' && msg.code == 'I00001'){
                    callMsg = msg.code;
                }
            }
        }
        if(callMsg != '' && callMsg == 'I00001'){
            system.debug('===in success=====');
            //isVoided__c 
            for(blng__PaymentMethod__c pmtMthd: [select id, isVoided__c, VoidDateTime__c from blng__PaymentMethod__c where id=:pmId]){
                pmtMthd.isVoided__c = true;
                pmtMthd.VoidDateTime__c = System.Now();
                payMtForUpdate.add(pmtMthd);
            }
        }
        system.debug('===in payMtForUpdate====='+payMtForUpdate);
        if(!payMtForUpdate.isEmpty()){
            update payMtForUpdate;
        }
    }
}
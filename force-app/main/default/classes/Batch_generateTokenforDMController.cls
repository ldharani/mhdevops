global class Batch_generateTokenforDMController implements Database.Batchable<sObject>, Database.allowscallouts {
    private Set<Id> sPaymentMethodId = new Set<Id>();
    
    public Batch_generateTokenforDMController(Set<Id> sPaymentMethodId) {
        this.sPaymentMethodId = sPaymentMethodId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        string strSOQL = 'SELECT ' + queryAllFields('blng__PaymentMethod__c');
        strSOQL += ' , blng__PaymentGateway__r.adnblng__APILoginId__c, blng__Account__r.blng__CustomerProfileId__c, blng__PaymentGateway__r.adnblng__APITransactionKey__c, blng__PaymentGateway__r.Endpoint_URL__c ';
        strSOQL += ' FROM blng__PaymentMethod__c';
        strSOQL += ' WHERE Payment_Profile_ID__c = null';
        strSOQL += ' AND Id IN: sPaymentMethodId';
        strSOQL += ' AND blng__PaymentType__c = \'Credit Card\'';
        
        return Database.getQueryLocator(strSOQL);
    }
    global void execute(Database.BatchableContext bc, List<blng__PaymentMethod__c> listPaymentMethod){
        // String[] paymentMethodLines = splitFileToLines('PaymentMethodToLoad');
        Map<String, Object> mapDeserializedJSONBody = new Map<String, Object>();
        string authResponse;
        string customerProfileId;
        List<Object> paymentProfileId;
        
        set<String> sPMNames = new set<String>();
        
        /*sPMNames.add('PM-0289');
sPMNames.add('PM-0290');
sPMNames.add('PM-0291');
sPMNames.add('PM-0292');
sPMNames.add('PM-0293');
sPMNames.add('PM-0294');
sPMNames.add('PM-0295');
sPMNames.add('PM-0296');
sPMNames.add('PM-0297');
sPMNames.add('PM-0298');
sPMNames.add('PM-0299');
sPMNames.add('PM-0300');
sPMNames.add('PM-0061');

strSOQL += ' AND Name IN: sPMNames';*/
        // strSOQL += ' AND Id = \'a5y7j000000GvbdAAC\'';
        system.debug('@@@@@@@@'+listPaymentMethod);
        List<blng__PaymentMethod__c> listPaymentMethodUpdate = new List<blng__PaymentMethod__c>();
        List<Account> listAccount = new List<Account>();
        set<Id> sAccountAddedForUpdate = new set<Id>();
        List<paymentMethodDetails> pay = new List<paymentMethodDetails>();
        for(blng__PaymentMethod__c objPM: listPaymentMethod){
            System.debug('FFFFFFFFSSFFF');
            String[] inputvalues = New String[]{};            
                //inputvalues = paymentMethodLines[i].split(',', 18); 
            paymentMethodDetails pm = new paymentMethodDetails();
            pm.customerProfileId = objPM.blng__Account__r.blng__CustomerProfileId__c;
            pm.firstName = objPM.blng__BillingFirstName__c;
            pm.lastName = objPM.blng__BillingLastName__c;
            pm.email = objPM.blng__BillingEmail__c;
            pm.phoneNumber= objPM.blng__BillingPhone__c;
            if(pm.phoneNumber != null && pm.phoneNumber.length() > 11){
                pm.phoneNumber = pm.phoneNumber.substring(0, 11);
            }
            
            pm.address = objPM.blng__BillingStreet__c + ',' + objPM.blng__StreetAddress2__c;
            if(pm.address != null && pm.address.length() > 60){
                pm.address = pm.address.substring(0, 60);
            }
            
            pm.city = objPM.blng__BillingCity__c;
            if(pm.city != null && pm.city.length() > 40){
                pm.city = pm.city.substring(0, 40);
            }
            
            pm.state = objPM.blng__BillingStateProvince__c;
            if(pm.state != null && pm.state.length() > 40){
                pm.state = pm.state.substring(0, 40);
            }
            
            pm.zip = objPM.blng__BillingZipPostal__c;
            if(pm.zip != null && pm.zip.length() > 20){
                pm.zip = pm.zip.substring(0, 20);
            }
            
            pm.country = objPM.blng__BillingCountry__c;
            if(pm.country != null && pm.country.length() > 60){
                pm.country = pm.country.substring(0, 60);
            }
            
            // pm.cardNumber = objPM.blng__CardNumber__c;
            pm.cardNumber = objPM.Card_Number__c;
            pm.expirationDate = objPM.blng__CardExpirationMonth__c + '-' + objPM.blng__CardExpirationYear__c;
            pm.PGAPILoginId = objPM.blng__PaymentGateway__r.adnblng__APILoginId__c;
            if(objPM.blng__PaymentGateway__c != null){
                pm.PGAPITransactionKey = objPM.blng__PaymentGateway__r.adnblng__APITransactionKey__c;
                pm.PGEndpointURL = objPM.blng__PaymentGateway__r.Endpoint_URL__c;
                System.debug('dddddfffffff');
                if(pm.PGEndpointURL != null){
                    System.debug('xxxxxxxxxxxxaaaaaaaddd');
                    if(pm.customerProfileId != null){
                        authResponse = sendRequestCreatePaymentProfile(pm);
                    }else{
                        
                        authResponse = sendRequest(pm);
                    }
                }
                
                /*string cardNumber;
string expirationDate;

cardNumber = inputvalues[9];
expirationDate = inputvalues[8] + '-' + inputvalues[7];

authResponse = sendRequest(cardNumber,expirationDate);*/
                
                system.debug('AuthResponse ==>' +authResponse);
                mapDeserializedJSONBody  =(Map<String,object>)JSON.deserializeUntyped(authResponse.substring(1,authResponse.length())) ;            
                
                //mapDeserializedJSONBody = (Map<String, Object>)JSON.deserializeUntyped(authResponse);
                if(mapDeserializedJSONBody != null){
                    customerProfileId = mapDeserializedJSONBody.containskey('customerProfileId')? String.valueOf(mapDeserializedJSONBody.get('customerProfileId')) : null;
                    paymentProfileId = mapDeserializedJSONBody.containskey('customerPaymentProfileIdList')?  (List<Object>)mapDeserializedJSONBody.get('customerPaymentProfileIdList') : null;                
                }
                if(paymentProfileId == null){
                    paymentProfileId = new List<Object>();
                    paymentProfileId.add(mapDeserializedJSONBody.containskey('customerPaymentProfileId')?  String.valueOf(mapDeserializedJSONBody.get('customerPaymentProfileId')) : null);                
                }
                if((customerProfileId != null) || (paymentProfileId != null && !paymentProfileId.isempty())){
                    blng__PaymentMethod__c pmRecord = New blng__PaymentMethod__c(Id=objPM.Id); 
                    if(customerProfileId != null){
                        pmRecord.Payment_Profile_ID__c = customerProfileId;
                    }
                    if(paymentProfileId != null && !paymentProfileId.isempty()){
                        pmRecord.blng__PaymentGatewayToken__c = String.valueof(paymentProfileId[0]);
                    }
                    pmRecord.Authorize_response__c = authResponse;
                    pmRecord.recordTypeId =Schema.SObjectType.blng__PaymentMethod__c.getRecordTypeInfosByDeveloperName().get('Post_Tokenized_Payment_Method').getRecordTypeId();
                    if(objPM.Card_Number__c != null && objPM.Card_Number__c.length() >= 4){
                        pmRecord.Card_Number__c = objPM.Card_Number__c.substring(objPM.Card_Number__c.length() - 4, objPM.Card_Number__c.length());
                        pmRecord.blng__CardNumber__c = objPM.Card_Number__c.substring(objPM.Card_Number__c.length() - 4, objPM.Card_Number__c.length());
                    }
                    listPaymentMethodUpdate.add(pmRecord);
                }else{
                    blng__PaymentMethod__c pmRecord = New blng__PaymentMethod__c(Id=objPM.Id); 
                    pmRecord.Authorize_response__c = authResponse;
                    if(objPM.Card_Number__c != null && objPM.Card_Number__c.length() >= 4){
                        pmRecord.Card_Number__c = objPM.Card_Number__c.substring(objPM.Card_Number__c.length() - 4, objPM.Card_Number__c.length());
                        pmRecord.blng__CardNumber__c = objPM.Card_Number__c.substring(objPM.Card_Number__c.length() - 4, objPM.Card_Number__c.length());
                    }
                    listPaymentMethodUpdate.add(pmRecord);
                }
                if(customerProfileId != null && sAccountAddedForUpdate.contains(objPM.blng__Account__c) == false){
                    sAccountAddedForUpdate.add(objPM.blng__Account__c);
                    Account acc = new Account (Id = objPM.blng__Account__c);
                    acc.blng__CustomerProfileId__c = customerProfileId;
                    listAccount.add(acc);
                }
            }
        }
        system.debug('@@@@@@@@'+listPaymentMethodUpdate);
        if(listPaymentMethodUpdate.size() > 0){
            update listPaymentMethodUpdate;
        }
        
        if(listAccount.size() > 0){
            update listAccount;
        }
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
    
    public static string sendRequest(paymentMethodDetails pm){
        HttpRequest req1 = new HttpRequest();
        req1.setMethod('POST');
        req1.setEndpoint(pm.PGEndpointURL);
        req1.setHeader('content-type', 'application/json');
        string messageBody1 ='{"createCustomerProfileRequest":{"merchantAuthentication":{"name":"' + pm.PGAPILoginId + '","transactionKey":"' + pm.PGAPITransactionKey + '"},"profile":{"merchantCustomerId":"'+ pm.customerProfileId +'","description":"Profile description here","email":"'+pm.email+'","paymentProfiles":{"customerType":"individual","billTo": {     "firstName": "'+pm.firstName+'","lastName": "'+pm.lastName+'","address": "'+pm.address+'","city": "'+pm.city+'","state": "'+pm.state+'","zip": "'+pm.zip+'","country": "'+pm.country+'","phoneNumber": "' + pm.phoneNumber + '"  },"payment":{"creditCard":{"cardNumber":"'+pm.cardNumber+'","expirationDate":"'+pm.expirationDate+'"}}}},"validationMode":"liveMode"}}';
        system.debug(messageBody1);
        req1.setHeader('Content-length', String.valueOf(messageBody1.length()));
        req1.setBody(messageBody1);
        
        req1.setTimeout(60*1000);
        Http h1 = new Http();
        String resp1;
        HttpResponse res1 = h1.send(req1);
        return res1.getBody();
        
    }
    
    public static string sendRequestCreatePaymentProfile(paymentMethodDetails pm){
        HttpRequest req1 = new HttpRequest();
        req1.setMethod('POST');
        req1.setEndpoint(pm.PGEndpointURL);
        req1.setHeader('content-type', 'application/json');
        string messageBody1 ='{ "createCustomerPaymentProfileRequest": { "merchantAuthentication": {"name":"' + pm.PGAPILoginId + '","transactionKey":"' + pm.PGAPITransactionKey + '" }, "customerProfileId": "'+ pm.customerProfileId +'", "paymentProfile": { "billTo": { "firstName": "'+pm.firstName+'","lastName": "'+pm.lastName+'","address": "'+pm.address+'","city": "'+pm.city+'","state": "'+pm.state+'","zip": "'+pm.zip+'","country": "'+pm.country+'","phoneNumber": "' + pm.phoneNumber + '" },"payment":{"creditCard":{"cardNumber":"'+pm.cardNumber+'","expirationDate":"'+pm.expirationDate+'" } }, "defaultPaymentProfile": false }, "validationMode": "liveMode" } }';
        
        system.debug(messageBody1);
        req1.setHeader('Content-length', String.valueOf(messageBody1.length()));
        req1.setBody(messageBody1);
        
        req1.setTimeout(60*1000);
        Http h1 = new Http();
        String resp1;
        HttpResponse res1 = h1.send(req1);
        return res1.getBody();
        
    }
    
    /*
    private static String[] splitFileToLines(String csvDocName){
        String STRING_LF = '\n';
        String STRING_CRLF = '\r\n';
        String[] lines = New String[]{};
            
            //get the content from the document for the given file name.
            ContentVersion doc;
        try{
            doc = [SELECT Id, Title,VersionData FROM ContentVersion WHERE Title = :csvDocName LIMIT 1];                
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'No ' + csvDocName + ' File'));
        }
        
        //process the file content and split into list of lines
        if (doc != null){
            String fileContent = doc.VersionData.toString();
            fileContent = fileContent.remove('\"');
            
            if (fileContent.indexOf(STRING_CRLF)>0){
                lines = fileContent.split(STRING_CRLF);
            }else{
                lines = fileContent.split(STRING_LF);            
            }
        }
        
        System.debug('No. of lines in the file ' + csvDocName + ' are ' + lines.size());
        return lines;
    }
    */
    /*
Method Name: queryAllFields
Description: This method is used to return all fields of sObject 
Parameter  : sObject API Name
*/
    Public static string queryAllFields(String strObjectAPIName){
        
        
        DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(strObjectAPIName).getDescribe();
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        String queryFields = String.join( fieldNames, ',' );
        return queryFields;
    }// END OF METHOD - queryAllFields
    
    public class paymentMethodDetails{   
        
        public string firstName;
        public string lastName;
        public string address;
        public string city;
        public string state;
        public string country;
        public string zip;
        public string cardNumber;
        public string phoneNumber;
        public string expirationDate;
        public string email;
        public string PGAPILoginId;
        public string PGAPITransactionKey;
        public string PGEndpointURL;
        public string customerProfileId;
    }
    /*
How to generate Tokenization?

generateTokenforDMController objToken = new generateTokenforDMController();
objToken.generateToken();

*/
}
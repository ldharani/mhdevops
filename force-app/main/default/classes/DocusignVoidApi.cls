public with sharing class DocusignVoidApi {

    /*
    private static final String USERNAME = '97de0b5c-8b64-47f2-9317-005b795839f9';
    private static final String PASSWORD = 'Docusign2018';    
    private static final String INTEGRATOR_KEY = '5889ae64-deae-4ae4-9411-c0f17d7caa3a';
    private static final String ACCOUNT_ID = '2342190' ; //'59033688';
    // for production use 'www.docusign.net/restapi/v2'
    // for sandbox use 'https://demo.docusign.net/restapi/v2'
    private static final String BASE_URL = 'https://demo.docusign.net/restapi/v2' ;
    */
    private static final String AUTH_TEMPLATE = '<DocuSignCredentials><Username>{0}</Username><Password>{1}</Password><IntegratorKey>{2}</IntegratorKey></DocuSignCredentials>';
    private static final String STATUS_VOID = 'voided';
    
    
    public HttpResponse voidEnvelope(String envelopeId, String voidReason){
        
        DocuSign_endpoints__c Docsendpts =  DocuSign_endpoints__c.getValues('Docusign Integration details');
        String USERNAME = Docsendpts.Username__c;
        String PASSWORD = Docsendpts.Password__c;
        String INTEGRATOR_KEY = Docsendpts.Integration_Key__c;
        String ACCOUNT_ID = Docsendpts.Account_ID__c;
        String BASE_URL = Docsendpts.Base_URL__c;
         System.debug('@@@@@@'+USERNAME+'' + PASSWORD+'' + INTEGRATOR_KEY +'' + ACCOUNT_ID +'' + BASE_URL);
        String endpoint = String.format('{0}/accounts/{1}/envelopes/{2}', new String[]{BASE_URL, ACCOUNT_ID, envelopeId});
        
        DocusignStatusRequest statusUpdate = new DocusignStatusRequest();
        statusUpdate.status = STATUS_VOID;
        statusUpdate.voidedReason = voidReason;
        
        // initialize the api client for the desired environment
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('PUT');
        request.setHeader('X-DocuSign-Authentication', String.format(AUTH_TEMPLATE, new String[]{USERNAME,PASSWORD,INTEGRATOR_KEY}));
        request.setHeader('Accept','application/json');
        request.setHeader('Content-Type','application/json');
        request.setBody(JSON.serialize(statusUpdate));
        system.debug('======='+request);
        if(!Test.isRunningTest()){
        return h.send(request);
        }
        
        return null;
        
    }

    public class DocusignStatusRequest{
        public String status {get; set;}
        public String voidedReason {get; set;}
    }
    
    
}
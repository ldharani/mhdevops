@isTest
public class Test_DocusignVoidApi {

    @isTest
    public static void test1(){
        DocuSign_endpoints__c ds = new DocuSign_endpoints__c();
        ds.Name = 'Docusign Integration details';
        ds.Username__c ='97de0b5c-8b64-47f2-9317-005b795839f9';
        ds.Account_ID__c= '2342190';
        ds.Base_URL__c='https://demo.docusign.net/restapi/v2';
        ds.Integration_Key__c='5889ae64-deae-4ae4-9411-c0f17d7caa3a';
        ds.Password__c='Dshubbell';
        insert ds;
        
        
        DocusignVoidApi doc = new DocusignVoidApi();
        
        doc.voidEnvelope('test','test');
    }
}
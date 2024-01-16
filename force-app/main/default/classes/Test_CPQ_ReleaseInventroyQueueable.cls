@isTest
public class Test_CPQ_ReleaseInventroyQueueable {

    static testMethod void testUpsellMethod() {
        
        Set<Id> oppIds = new Set<Id>();
        Set<Id> oppProdIds = new Set<Id>();
        Map<Id,String> mapOpptyProdNInventoryId = new Map<Id,String>();
        
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc =  util.getAccount();
        Contact con = util.getContact(acc.Id);
        
        opportunity testopp= new opportunity();
        testopp.Name='Test IJ';
        testopp.accountId=acc.Id;
        testopp.StageName='Prospecting';
        testopp.CloseDate = date.today();
        testopp.Marketing_Contact__c = con.Id;
        testopp.Billing_Contact__c = con.Id;
        testopp.Primary_Contact__c = con.Id;
        insert testopp;
        
        Product2  oppprod1 = new Product2(Name = 'Reputation Boost',ProductCode = '12000',IsInventoried__c =true);
        insert oppProd1;         
        
        SBQQ__Quote__c objquote= new SBQQ__Quote__c();
        objquote.SBQQ__Account__c=acc.Id;
        objquote.SBQQ__Opportunity2__c=testopp.id;
        insert objquote;
        
        SBQQ__QuoteLine__c quoteline=new SBQQ__QuoteLine__c();
        quoteline.SBQQ__Product__c=oppProd1.id;
        quoteline.SBQQ__Quote__c=objquote.Id;
        quoteline.Inventory_Id__c = '123';
        insert quoteline;
        
        Email_Ids__c em = new Email_Ids__c(Name ='IntegrationErrors',Email_Id__c='test@test.com');
        insert em;
        
        oppIds.add(testopp.Id);
        oppProdIds.add(quoteline.Id);
        mapOpptyProdNInventoryId.put(oppProd1.Id,'123');
        
        Integration_Endpoints__c ie = new Integration_Endpoints__c(Name='ReleaseInventory',API_key__c='76F1CF765AA41A8E695F66A815B7D345',Endpoint_URL__c='http://stg-back-office-services.lawyers.com/services/inventory/v2/release',Endpoint_URL_for_authentication__c='svcs-stg1.martindale.com/mhintegration/inventory/release',MethodType__c='POST',Private_Key__c='eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa',Public_Key__c='b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966',xmlns__c='http://svcs.martindale.com/MHIntegration/ReleaseInventoryRequest/v1.00');
        insert ie;
        
        Restrict_Integration_Calls__c res = new Restrict_Integration_Calls__c(Name='Restrict',Restrict_Callouts__c=false);
        insert res;
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('releaseResponse');
        mock.setStatusCode(500);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        System.enqueueJob(new CPQ_ReleaseInventroyQueueable(oppIds,oppProdIds,'TestUser',mapOpptyProdNInventoryId));
        Test.stopTest();
    }
}
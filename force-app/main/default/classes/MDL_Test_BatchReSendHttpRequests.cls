/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
private class MDL_Test_BatchReSendHttpRequests {

    static testMethod void myUnitTest() {
    	
    	MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
    	Account acc = util.getAccount();
    	invoiceit_s__Currency__c cur = util.getCurrencyObject();
    	invoiceit_s__Job__c job = util.getOrder(acc.Id, cur.Id);
    	String cNum = acc.MH_Cust_Number__c;
    	String orderNum = job.Name;
    	
        Error_Log__c err = new Error_Log__c();
        err.XML_Mesaage_Type__c = 'OrderRequest';
        err.XML_Body__c = '<OrderRequest xmlns="http://svcs.martindale.com/MHIntegration/OrderRequest/v1.00"><RequestId>a0Hc0000006OjzCEAS-6/30/2014 11:15 AM</RequestId><Order><UserName>lori.ashley@rainbow2.qa</UserName><CustomerNumber>'+cNum+'</CustomerNumber><OrderNumber>'+orderNum+'</OrderNumber><Products><Product><ProductId>a0Dc000000FHoRxEAL</ProductId><SubscriptionIdentificationNumber>1000000514.11053.a0Dc000000FHoRxEAL</SubscriptionIdentificationNumber><ProductCode>11053</ProductCode><LineItems><LineItem><LineItemId>a0Fc0000003MZDQEA420140630111501</LineItemId><SubscriptionIdentificationNumber>1000000514.01885.a0Fc0000003MZDQEA4</SubscriptionIdentificationNumber><ProductCode>01885</ProductCode><ProductName>CWS Plus Build - WX Yr 1</ProductName><Status>Cancel</Status><PostDate>2014-06-30</PostDate><FulfillmentDate>2014-06-30</FulfillmentDate><CancelDate>2014-06-30</CancelDate><IsProductInventoried>false</IsProductInventoried><Attributes><Attribute><Name>InventoryId</Name><Value></Value></Attribute></Attributes></LineItem></LineItems></Product></Products></Order></OrderRequest>';
        err.Sent_Successfully__c = false;
        err.Error_Reason__c = '400 : There is an error while validating the input XML. Please contact us at mhdevelopers@Martindale.com.';
        insert err;
        
        Test.startTest();
        MDL_BatchReSendHttpRequests m = new MDL_BatchReSendHttpRequests();
        Database.executeBatch(m);
        Test.stopTest();
    }
    static testMethod void schedulerTest() {
    	Test.startTest();
    	MDL_ScheduleReSendHTTPRequests m = new MDL_ScheduleReSendHTTPRequests();
    	String sch = '0 0 23 * * ?';
    	system.schedule('Test check', sch, m);
    	Test.stopTest(); 
    }
}
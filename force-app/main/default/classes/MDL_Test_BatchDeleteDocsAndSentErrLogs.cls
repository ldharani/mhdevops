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
private class MDL_Test_BatchDeleteDocsAndSentErrLogs {
   /*
   static testMethod void testBatch() {
        Document doc = new Document();
        String bodyDoc = 'This is a test document';
        Blob b = Blob.valueOf(bodyDoc);
        Folder f = [Select f.Type, f.Name, f.Id From Folder f where f.Name = 'Quote PDFs'];
        doc.FolderId = f.Id;
        doc.Name = 'Test Document';
        doc.Body = b;
        insert doc;
        
        Error_Log__c err = new Error_Log__c();
        err.Error_Reason__c ='Test reason';
        err.Sent_Successfully__c = true;
        insert err;
        
        Error_Log__c err1 = new Error_Log__c();
        err1.Error_Reason__c ='Test reason';
        err1.Sent_Successfully__c = true;
        insert err1;
        
        Test.startTest();
        MDL_BatchDeleteDocsAndSentErrLogs m = new MDL_BatchDeleteDocsAndSentErrLogs();       
        Database.executeBatch(m);
        Test.stopTest();
    }
    static testMethod void testSchedule() {
        Test.startTest();
        MDL_ScheduleDeleteDocsAndSentErrLogs m = new MDL_ScheduleDeleteDocsAndSentErrLogs();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, m);
        Test.stopTest(); 
    }*/
    static testMethod void testBatchCreateCase5Days() {
        
        RecordType r = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType = 'Case' and r.Name = 'MDL Oppty Renew' LIMIT 1];      
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account account2 = util.getAccount();
        Contact contact2 = util.getContact(account2.Id);
        invoiceit_s__Currency__c currency2 = util.getCurrencyObject();
        invoiceit_s__Job__c order2 = util.getOrder(account2.Id , currency2.Id);
        order2.invoiceit_s__Number_Of_Terms__c = 1;
        order2.invoiceit_s__Service_End_Date__c = Date.Today().addDays(5);
        update order2;
        System.debug('SED:::'+order2.invoiceit_s__Service_End_Date__c);
        
        Case c = new Case();
        c.Parent_Order__c = order2.Id;
        
        if(r!= null) {
            c.RecordTypeId = r.Id;
        }
        insert c;
        System.debug('order:'+c.Parent_Order__c);
        System.debug('order end date:'+c.Parent_Order__r.invoiceit_s__Service_End_Date__c);
        Test.startTest();
        MDL_BatchCreateCaseForOppty5Days m = new MDL_BatchCreateCaseForOppty5Days();
        Database.executeBatch(m);
        Test.stopTest();
    }
    static testMethod void testSchedulerCreateCase5Days() {
        Test.startTest();
        MDL_ScheduleCreateCaseForOppty5Days m = new MDL_ScheduleCreateCaseForOppty5Days();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, m);
        Test.stopTest();
    }
    static testMethod void testBatchCase120Days() {
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account account2 = util.getAccount();
        Contact contact2 = util.getContact(account2.Id);
        invoiceit_s__Currency__c currency2 = util.getCurrencyObject();
        invoiceit_s__Job__c order2 = util.getOrder(account2.Id , currency2.Id);
        order2.invoiceit_s__Number_Of_Terms__c = 1;
        order2.invoiceit_s__Service_End_Date__c = Date.today().addMonths(4).toStartOfMonth().addDays(-1);
        update order2;
        System.debug('SED:::'+order2.invoiceit_s__Service_End_Date__c);
        Test.startTest();
        MDl_BatchCreateCaseForOrders120Days m = new MDl_BatchCreateCaseForOrders120Days();
        Database.executeBatch(m);
        Test.stopTest();
    }
    static testMethod void testSchedulerCreateCase120Days() {
        Test.startTest();
        MDL_ScheduleCreateCaseForOrders120Days m = new MDL_ScheduleCreateCaseForOrders120Days();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, m);
        Test.stopTest();
    }
}
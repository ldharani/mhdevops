@isTest
public class orderActivationQueueable_Test {
    static testMethod void testExecute() {
        Set<Id> quoteIds = new Set<Id>();
        Test.startTest();
		SBQQ__Quote__c q = new SBQQ__Quote__c();
        insert q;
        quoteIds.add(q.id);
        orderActivationQueueable queueable = new orderActivationQueueable(quoteIds);
        System.enqueueJob(queueable);
        Test.stopTest();
    }
}
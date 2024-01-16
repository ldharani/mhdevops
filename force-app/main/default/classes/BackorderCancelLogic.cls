global class BackorderCancelLogic implements Database.Batchable<sObject>{
    @TestVisible
    private static integer todayOffset = 0;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        dateTime now = System.now().addDays(todayOffset);
        return Database.getQueryLocator([
            SELECT Id, Cancelled__c
            FROM Backorder__c
            WHERE cancelled__c = false AND Cancel_Date__c <= :now]);
    }

    global void execute(Database.BatchableContext BC, List<Backorder__c> backorders) {
        for(Backorder__c backorder: backorders) {
            backorder.Cancelled__c = true;
        }
        Database.update(backorders,false);
    }

    global void finish(Database.BatchableContext BC) {

    }
}
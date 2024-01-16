global class SubscriptionCancelLogic implements Database.Batchable<sObject>{
    @TestVisible
    private static integer todayOffset = 0;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        dateTime now = System.now().addDays(todayOffset);
        return Database.getQueryLocator([SELECT Id, Cancelled__c
                FROM Subscription__c
                WHERE cancelled__c = false AND Cancel_Date__c <= :now]);
    }

    global void execute(Database.BatchableContext BC, List<Subscription__c> subscriptions) {
        for(Subscription__c subscription: subscriptions) {
            subscription.Cancelled__c = true;
        }
        Database.update(subscriptions,false);
    }

    global void finish(Database.BatchableContext BC) {
    }
}
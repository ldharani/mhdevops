global class BatchPaymntMethdInActiveCls implements Database.Batchable<sObject>,Database.AllowsCallouts {
    global String query;
    global String TodayMonth = '';
    global String TodayYear = '';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        TodayMonth = String.valueOf(Date.today().month());
        TodayYear = String.valueOf(Date.today().year());
        system.debug('==QLnsquery=='+TodayMonth);
        system.debug('==QLnsquery=='+TodayYear);
        query = ' select id,blng__Active__c,blng__CardExpirationMonth__c ,blng__CardExpirationYear__c, blng__PaymentType__c '+ 
                ' FROM blng__PaymentMethod__c  where blng__Active__c = true AND blng__PaymentType__c =\'Credit Card\' '+
                ' AND blng__CardExpirationMonth__c < \'' + TodayMonth + '\' AND blng__CardExpirationYear__c <= \'' + TodayYear + '\'';
        system.debug('==QLnsquery=='+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<blng__PaymentMethod__c> pmList){
        List<blng__PaymentMethod__c> pmToUpdate = new List<blng__PaymentMethod__c>();
        for(blng__PaymentMethod__c pm: pmList){
            if(pm.blng__Active__c == TRUE){
                pm.blng__Active__c = FALSE;
            }
            pmToUpdate.add(pm);
        }
        if(!pmToUpdate.isEmpty()){
            update pmToUpdate;
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}
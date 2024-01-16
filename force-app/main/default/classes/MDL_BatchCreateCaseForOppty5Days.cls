global class MDL_BatchCreateCaseForOppty5Days implements Database.Batchable<sObject>{
    global String query;
    global Database.QueryLocator start(Database.BatchableContext BC) {  
        Date endDate = Date.Today().addDays(5);
        //Date endDate = Date.today().addMonths(2).toStartOfMonth().addDays(-1); 
        String query =  'Select c.Parent_Order__r.invoiceit_s__Service_End_Date__c, c.Parent_Order__c, c.OwnerId, c.Id, c.AccountId From Case c where c.Status != \'Closed\' and c.Parent_Order__r.invoiceit_s__Service_End_Date__c =: endDate';
        if(Test.isRunningTest()) {
            query += ' LIMIT 5';
        }
        return Database.getQueryLocator(query); 
    }
    global void execute(Database.BatchableContext BC, List<Case> scope) {
        List<Case> lstCases = new List<Case>();
        RecordType r = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType = 'Case' and r.Name = 'MDL Oppty Renew' LIMIT 1];
        //QueueSobject queue = [select Id, QueueId from QueueSobject WHERE SobjectType = 'Case' AND Queue.Name = 'DG Queue' LIMIT 1]; 
        Group queue = [select Id from Group where Type='Queue' and DeveloperName='Fulfillment_Operations' LIMIT 1];
        for(Case c : scope) {
            if(queue!=null){
                c.OwnerId = queue.Id;
            }
            lstCases.add(c);
        }
        if(lstCases.size() > 0) {
            Database.update(lstCases);
        }
    }
    global void finish(Database.BatchableContext BC) {
        /*Date endDate = Date.today().addMonths(1).addDays(-7);
        Integer caseDay = endDate.day();
        //String scheduleStr = '0 0 3 '+caseDay+' * ?';
        String scheduleStr = '0 1 * * * ?';
        System.schedule('Assign Cases to DG queue', scheduleStr, new MDL_ScheduleCreateCaseForOppty5Days());*/
    }
}
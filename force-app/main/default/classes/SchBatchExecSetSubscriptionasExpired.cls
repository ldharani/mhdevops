/**@@
#Batch CLASS NAME  : SchBatchExecSetSubscriptionasExpired
#DESCRIPTION       : This is scheduler class for batch class - BatchExecSetSubscriptionasExpired
#CREATED BY        : Serge Kandukuri
@@**/
Public class SchBatchExecSetSubscriptionasExpired implements Schedulable{
    Public void execute(SchedulableContext SC) { 
        String query = 'SELECT Id, SBQQ__Contract__c FROM SBQQ__Subscription__c WHERE CALENDAR_MONTH(SBQQ__EndDate__c) =: previousMonth AND Status__c = \'Active\'';
        BatchExecSetSubscriptionasExpired objBatchExec = new BatchExecSetSubscriptionasExpired(query);
        database.executeBatch(objBatchExec, 200);      
    }
}
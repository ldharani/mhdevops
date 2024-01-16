/**@@
#Batch CLASS NAME  : SchBatchExecSetOrderProductasExpired
#DESCRIPTION       : This is scheduler class for batch class - BatchExecSetOrderProductasExpired
#CREATED BY        : Serge Kandukuri
@@**/
Public class SchBatchExecSetOrderProductasExpired implements Schedulable{
    Public void execute(SchedulableContext SC) { 
        String query = 'SELECT Id, OrderId FROM Orderitem WHERE CALENDAR_MONTH(EndDate) =: previousMonth AND Status__c = \'Active\'';
        BatchExecSetOrderProductasExpired objBatchExec = new BatchExecSetOrderProductasExpired(query);
        Database.executeBatch(objBatchExec, 200); 
    }
}
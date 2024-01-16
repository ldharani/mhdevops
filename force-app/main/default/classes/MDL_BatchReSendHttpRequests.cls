/*
 * Created By : Lister Technologies
 * Created Date : 5-June-2014
 * Created Purpose : Batch Class which will be used to resend HTTP requests in case of network failure 
 * Test Class : MDL_Test_BatchReSendHttpRequests.cls
 */
global class MDL_BatchReSendHttpRequests implements Database.Batchable<sObject>,Database.AllowsCallouts{
    global String query;
    global String endPoint;
    global String methodType;
    global List<String> lstOrderResponseBody;
    global List<String> lstReleaseResponseBody;
    global List<Error_Log__c> lstErrLog;
    global List<Error_Log__c> lstAllErrorLogs;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'Select e.XML_Mesaage_Type__c, e.XML_Body__c, e.Order_Number__c,e.Order_Name__c,e.Re_process_date_time__c,e.Error_Reason__c, e.Name, e.Id From Error_Log__c e where Sent_Successfully__c != true order by CreatedDate';
        if(test.isRunningTest()) {
            query += ' LIMIT 5';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Error_Log__c> scope) {
        lstAllErrorLogs = new List<Error_Log__c>();
        lstErrLog = new List<Error_Log__c>();
        lstOrderResponseBody = new List<String>();
        lstReleaseResponseBody = new List<String>();
        for(Error_Log__c err : scope) {
            if(err.Error_Reason__c != null && !(err.Error_Reason__c.startsWith('400')) && !(err.Error_Reason__c.startsWith('200')) ){
                lstAllErrorLogs.add(err);
            }
        }
        system.debug('error logs list ' + lstAllErrorLogs);
        if(!test.isRunningTest())
            MDL_Integration_Vim_Efs.reSendHttpRequests(lstAllErrorLogs);
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}
public without sharing class IntegrationEngine_BatchProcessRecords extends IntegrationEngine_BatchBase {

    public static void scheduleBatchJob() {
        Integration_Settings__c integrationSettings = Integration_Settings__c.getInstance();
        if (string.isBlank(integrationSettings.Integration_Job_ID__c)) {
            integrationSettings.Integration_Job_ID__c = Database.executeBatch(
                    new IntegrationEngine_BatchProcessRecords(),
                    Limits.getLimitCallouts());

            upsert integrationSettings;
        }
    }

    public Database.QueryLocator Start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
                SELECT ID, Number_of_Attempts__c, Account_Name__c, Contact__c, Task_Id__c, Professional_Id__c, Error_Message__c, Status__c, Integration__c
                FROM Error_Log__c
                WHERE Number_of_Attempts__c = 0
                AND Status__c = 'New']);
    }

    public void Finish(Database.BatchableContext bc) {
        Integration_Settings__c integrationSettings = Integration_Settings__c.getInstance();
        if (processedRecords) {
            processedRecords = false;
            integrationSettings.Integration_Job_ID__c = Database.executeBatch(this,Limits.getLimitCallouts());
        } else {
            integrationSettings.Integration_Job_ID__c = null;
        }
        update integrationSettings;
    }
}
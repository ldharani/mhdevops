global without sharing class IntegrationEngine_RetryRecords extends IntegrationEngine_BatchBase implements Schedulable, Database.AllowsCallouts, Database.Stateful {
    boolean fullRetry;
    integer minutesBetweenRetries;
    Id cronTriggerId;

    public static void ScheduleBatchJob() {
        ScheduleBatchJob(false);
    }

    public static void ScheduleBatchJob(boolean fullRetry) {
        if (fullRetry) {
            Database.executeBatch(new IntegrationEngine_RetryRecords(true, 0),
                    Limits.getLimitCallouts());
        }
        else {
            Integration_Settings__c integrationSettings = Integration_Settings__c.getInstance();
            // Default of 5 minutes if minutes aren't specified
            integer minutesBetweenRetries = integrationSettings.Minutes_Between_Retries_Banana_Stand__c != null &&
                    integrationSettings.Minutes_Between_Retries_Banana_Stand__c > 0
                    ? integrationSettings.Minutes_Between_Retries_Banana_Stand__c.intValue()
                    : 5;
            for (integer i = 0; i < (60 / minutesBetweenRetries); i++) {
                system.schedule('Integration Engine Retry Records ' + (i + 1),
                        '0 ' + i * minutesBetweenRetries + ' * ? * *',
                        new IntegrationEngine_RetryRecords(false, minutesBetweenRetries));
            }
        }
    }

    public IntegrationEngine_RetryRecords(boolean fullRetry, integer minutesBetweenRetries) {
        this.fullRetry = fullRetry;
        this.minutesBetweenRetries = minutesBetweenRetries;
    }

    global void execute(SchedulableContext sc) {
        if (sc != null) {
            cronTriggerId = sc.getTriggerId();
        }
        Database.executeBatch(this, Limits.getLimitCallouts());
    }

    public Database.QueryLocator Start(Database.BatchableContext bc) {
        Integration_Settings__c integrationSettings = Integration_Settings__c.getInstance();
        if (fullRetry == true) {
            return Database.getQueryLocator([SELECT ID, Number_of_Attempts__c, Account_Name__c, Contact__c, Task_Id__c, Professional_Id__c, Error_Message__c, Status__c, Integration__c, Find_Task_Play__c
                                             FROM Error_Log__c
                                             WHERE Status__c Not In ('New', 'Completed', 'Successful') and
                                             Number_of_Attempts__c > 0 AND
                                             (Integration__c In ('Banana Stand', 'Banana Stand Professionals Sync Create','Banana Stand Professionals Sync Destroy')  AND
                                             Number_of_Attempts__c <: integrationSettings.Max_Retries_Banana_Stand__c)]);
        }
        else {
            DateTime startTime = system.now();
            if (cronTriggerId != null) {
                // PreviousFireTime will be when this job started.
                startTime = [SELECT PreviousFireTime FROM CronTrigger WHERE Id =: cronTriggerId].PreviousFireTime;
            }
            return Database.getQueryLocator([
                    SELECT ID, Number_of_Attempts__c, Account_Name__c, Contact__c, Task_Id__c, Professional_Id__c, Error_Message__c, Status__c, Integration__c, Find_Task_Play__c
                    FROM Error_Log__c
                    WHERE Status__c Not In ('New', 'Completed','Error - Fatal', 'Successful') and
                    Date_Time_Submitted__c <:startTime.addMinutes(-1 * minutesBetweenRetries) and
                    Date_Time_Submitted__c >=: startTime.addMinutes(-2 * minutesBetweenRetries) and
                    ((Integration__c In ('Banana Stand', 'Banana Stand Professionals Sync Create','Banana Stand Professionals Sync Destroy') and
                    Number_of_Attempts__c < :integrationSettings.Max_Retries_Banana_Stand__c))
            ]);
        }
    }

    public void Finish(Database.BatchableContext bc) {
    }
}
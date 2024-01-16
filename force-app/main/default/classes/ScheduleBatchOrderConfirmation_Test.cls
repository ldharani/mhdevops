@istest
public class ScheduleBatchOrderConfirmation_Test {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testmethod void run2condition(){
        
        //inserting account
        account acc             = new account();
        acc.Name                = 'test';
        acc.Customer_Status__c  = 'New';
        acc.Acquisition_date__c = date.today().addmonths(-12);
        acc.Order_Status__c     = 'Active';
        insert acc;
        
        
        //MDL_UtilClass_TestClass utilclass = new MDL_UtilClass_TestClass();
        //account acc1 = utilclass.getAccount();
        //acc1.Customer_Status__c  = 'New';
        // acc1.Acquisition_date__c = date.today().addmonths(-12);
        //update acc1;
        string sh='';
        test.startTest();
        ScheduleBatchOrderConfirmation sch1 = new ScheduleBatchOrderConfirmation();
        system.schedule('jobName', CRON_EXP, sch1);
        test.stopTest();
        
    }
}
@isTest
public class MDL_TriggerOnErrorLog_Test { 

    public static testmethod void testCaseA(){
        test.startTest();
        
        Error_Log__c err = new Error_Log__c();
        err.Error_Reason__c = '400 : Bad Request';
        err.Order_Name__c  = 'Test';
        insert err;       
        test.stopTest();
    }    
}
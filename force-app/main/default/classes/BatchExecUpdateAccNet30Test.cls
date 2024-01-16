@isTest
public class BatchExecUpdateAccNet30Test{
    @testSetup static void methodName() {
        Id mhRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        
        Account objAcc = new Account();
        objAcc.Name = 'Test Account';
        objAcc.Payment_Terms__c = null;
        objAcc.RecordtypeId = mhRecordTypeId;
        insert objAcc;
    }
    
    static testmethod void testmethod1(){
        BatchExecUpdateAccNet30 objBatch = new BatchExecUpdateAccNet30();
        Database.executeBatch(objBatch, 200); 
        
    }
    
}
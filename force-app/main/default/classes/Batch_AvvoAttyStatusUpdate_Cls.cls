/***************
 * Class Name: Batch_AvvoAttyStatusUpdate_Cls
 * Test Class: Test_AvvoAttyStatusUpdate_cls
 * Description: This class updates the customer status and order status 
 * 				on the Avvo Atty accounts based on the Advertising status field.
 * Developed By: Ieswarya J
 * Modification History : Created on July 22,2020
 * 
 * 
 * ******/
public class Batch_AvvoAttyStatusUpdate_Cls implements Database.Batchable<sObject>{
    
    
    public Database.querylocator start(Database.BatchableContext BC) {
        Id AvvoAttyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
       String query = 'Select Id,ParentId,Customer_Status__c,Order_Status__c from Account where RecordtypeId =:AvvoAttyRecordTypeId and Customer_Status__c=null limit 50000';
           
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Account> ListofAcc) {
        AvvoAttyStatusUpdate_cls.IsBatchprocess = true;
        AvvoAttyStatusUpdate_cls.UpdateAttyAccountStatus(ListofAcc);
      }
    
    public void finish(Database.BatchableContext BC) {
        system.debug('Job is in finish method');
       AvvoAttyStatusUpdate_cls.IsBatchprocess = false; 
        
    }

}
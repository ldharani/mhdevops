/***************
 * Class Name: Batch_AvvoFirmSingleRunUpdate_Cls
 * Test Class: Test_AvvoAttyStatusUpdate_cls
 * Description: This class updates the customer status and order status 
 *              on the Avvo Firm accounts based on the Advertising status field.
 * Developed By: Ieswarya J
 * Modification History : Created on Aug 18,2020
 * 
 * 
 * ******/
public class Batch_AvvoFirmSingleRunUpdate_Cls implements Database.Batchable<sObject>{
    
    public Database.querylocator start(Database.BatchableContext BC) {
        Id AvvoFirmRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId();
               
        String query = 'Select Id,ParentId,Avvo_Customer_Status__c,Avvo_Order_Status__c from Account where RecordtypeId =:AvvoFirmRecordTypeId and Avvo_Customer_Status__c=null limit 50000 ';
         
            return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Account> ListofAcc) {
        AvvoAttyStatusUpdate_cls.IsBatchprocess = true;
       AvvoAttyStatusUpdate_cls.updateAvvoFirmAccounts(ListofAcc);
    }
    
    public void finish(Database.BatchableContext BC) {
        system.debug('Job-2 is in finish method');
        AvvoAttyStatusUpdate_cls.IsBatchprocess = false; 
      }
}
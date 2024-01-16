/***************
 * Class Name: Batch_AvvoIBFirmAccUpdate_Cls
 * Test Class: Test_AvvoAttyStatusUpdate_cls
 * Description: This class updates the customer status and order status 
 *              on the Avvo Firm accounts based on the Advertising status field.
 * Developed By: Ieswarya J
 * Modification History : Created on July 22,2020
 * 
 * 
 * ******/
public class Batch_AvvoIBFirmAccUpdate_Cls implements Database.Batchable<sObject>{
   // public Id RecordId;
    
    public Database.querylocator start(Database.BatchableContext BC) {
        Id AvvoFirmRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId();
        Id AvvoAttyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        set<Id> setofFirmid = new set<Id>();
        map<Id,integer> mapofIdtoChildcount = new map<Id,integer>();
        set<Id> SetofParentId = new set<Id>();
        Date startdate;
        Date enddate;
        
        Avvo_status_update_batch__c setting = Avvo_status_update_batch__c.getinstance();
              startdate = setting.start_date__c;
              enddate = setting.end_date__c;
              
    system.debug('startdate:'+startdate+'enddate'+enddate);
        for(Account acc:[select Id,ParentId,Avvo_customer_Status__c,Customer_Status__c,Order_Status__c,Avvo_Order_Status__c from Account where lastmodifieddate >=: startdate and lastmodifieddate <=: enddate and RecordtypeId =:AvvoAttyRecordTypeId]){
                setofFirmid.add(acc.ParentId);
            }
             system.debug('setofFirmid:'+setofFirmid);
            
            for(Account acc:[select Id,(select Id from childaccounts limit 20) from Account where Id in:setofFirmid]){
              if(acc.childaccounts.size()>19){
                  SetofParentId.add(acc.Id);
              }
            }
        
        system.debug('SetofParentId:'+SetofParentId);
        String query = 'Select Id,ParentId,Avvo_Customer_Status__c,Avvo_Order_Status__c from Account where RecordtypeId =:AvvoFirmRecordTypeId and Id in:SetofParentId ';
        
       system.Debug('Query'+query);
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
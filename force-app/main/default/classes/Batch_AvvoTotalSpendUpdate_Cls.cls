public class Batch_AvvoTotalSpendUpdate_Cls implements Database.Batchable<sObject>{
    public Database.querylocator start(Database.BatchableContext BC) {
        Id AvvoAttyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        //string accId = '0012I00002VMYZ4';      
        String query = 'Select Id,name,Active_Opportunities_Amount__c,ActiveOpportunitiesAmountLM__c from Account where RecordtypeId =:AvvoAttyRecordTypeId and Active_Opportunities_Amount__c!=0 limit 50000';
        //String query = 'Select Id,name,Active_Opportunities_Amount__c,ActiveOpportunitiesAmountLM__c from Account where RecordtypeId =:AvvoAttyRecordTypeId and Active_Opportunities_Amount__c!=0 and id =: accId';
        system.debug('==query=='+query); 
            return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> ListofAcc) {
        system.debug('==ListofAcc=='+ListofAcc);
        List<Account> accLstToUpdate = new List<Account>();
        for(Account acc: ListofAcc){
            if(acc.Active_Opportunities_Amount__c != 0){
                //system.debug('==inif====');
                acc.ActiveOpportunitiesAmountLM__c = acc.Active_Opportunities_Amount__c;
                accLstToUpdate.add(acc);
            }     
        }
        system.debug('==accLstToUpdate=='+accLstToUpdate);
        if(!accLstToUpdate.isEmpty()){
            update accLstToUpdate;    
        }
        
    }
    public void finish(Database.BatchableContext BC) {
        
    }
}
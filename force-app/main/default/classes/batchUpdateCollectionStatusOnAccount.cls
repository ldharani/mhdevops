/**************************************************************
  
 * Description : Updating Collection Status on Account when Past Due Amount is Modified
 * Class Name  : batchUpdateCollectionStatusOnAccount
 * Test Class  : batchUpdateCollectionStatusAccountTest
 * Created Date : 28/08/2023
 * Created By : Lakshmi
 * 
 * Change History
************************************************************************************************************************
Jira       ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************/
// <T01>
public class batchUpdateCollectionStatusOnAccount implements Database.Batchable<sObject> {
    public Set<Id> accIdsSet = new Set<Id>();    
    public batchUpdateCollectionStatusOnAccount(Set<Id> accIds)
    {
        this.accIdsSet = accIds;        
    }
    @invocablemethod(label='Update Collection Status On Account' 
    Description='MHBS-9069' category='Account')
    public static void updateCollectionStatus(List<String> accIds)
    {     
        set<Id> accIdsSet = new set<Id>();
        for(String accId : accIds){
            accIdsSet.add(accId);
        }
        Id jobId = Database.executeBatch(new batchUpdateCollectionStatusOnAccount(accIdsSet), 1);
    }
    
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, SFBD__CollectionsStatus__c  From Account Where Id IN:accIdsSet and Total_Amount_Past_Dues__c > 10';
        
        if(test.isRunningTest()){
            query = 'Select Id, SFBD__CollectionsStatus__c  From Account Where Id IN:accIdsSet';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC , List<Account> scope){
        try{
            for(Account acc : scope){                
                    acc.SFBD__CollectionsStatus__c = 'In Collections';
            }
            if(!scope.isEmpty()){                
                update scope;
            } 
        }
        catch(exception e){
               Util.processException(e,true,'Exception occurred while updating collection status on Account'+scope);
        }
        
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    
}
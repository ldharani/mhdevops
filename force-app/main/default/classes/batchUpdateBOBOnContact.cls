/**************************************************************
  
 * Description : MH AE adding lead/contact to book of business
 * Class Name  : batchUpdateBOBOnContact
 * Test Class  : batchUpdateBOBOnContactTest 
 * Created Date : 04/07/2023
 * Created By : Lakshmi
 * 
 * Change History
************************************************************************************************************************
Jira       ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************/
// <T01>
public class batchUpdateBOBOnContact implements Database.Batchable<sObject> {
    public Set<Id> accIdsSet = new Set<Id>();    
    public batchUpdateBOBOnContact(Set<Id> accIds)
    {
        this.accIdsSet = accIds;        
    }
    @invocablemethod(label='Update BOB Fields On Contact' 
    Description='MHBS-9069' category='Contact')
    public static void updateBOBOnContact(List<String> accIds)
    {
        Set<Id>  accIdsSet = new Set<Id>();
        List<Account> accList = [Select Id,ParentId from Account where Id IN: accIds];
        
        for(Account acc : accList){
            if(acc.ParentId != null){
                accIdsSet.add(acc.ParentId);
            }
            else{
                accIdsSet.add(acc.Id);
            }
        }        
        Id jobId = Database.executeBatch(new batchUpdateBOBOnContact(accIdsSet), 1);
    }
    
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, In_AE_Book__c,Book_Owner__c,Date_Added_to_AE_Book__c,Date_of_Last_AE_Activity__c,Account.Book_Owner__c  From Contact Where AccountID IN:accIdsSet';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC , List<Contact> scope){
        try{
            for(Contact con : scope){                
                    con.In_AE_Book__c = false;
                    con.Date_Added_to_AE_Book__c = null;
                    con.Book_Owner__c = null;
            }
            if(!scope.isEmpty()){                
                update scope;
            } 
        }
        catch(exception e){
               Util.processException(e,true,'Exception occurred while updating Avalara_Address_Validation_Error__c field.');
        }
        
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    
}
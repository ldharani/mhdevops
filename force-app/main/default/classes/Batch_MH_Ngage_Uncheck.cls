/**@@
#BATCH CLASS NAME      :    Batch_MH_Ngage_Uncheck
#TEST CLASS            :    Batch_MH_Ngage_Uncheck_Test
#CREATED BY            :    VR
#TICKET                :    MHBS-6708
#DESCRIPTION           :    Unchecks Has_MH_Product__c which got checked by Batch_MH_Ngage_Association

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************
@@**/

global  class Batch_MH_Ngage_Uncheck implements Database.Batchable<Sobject>,Database.Stateful  {
        
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = 'SELECT Id , AccountId , Account.ParentID , (SELECT ID from SBQQ__Subscriptions__r where Status__c!=\'Cancelled\' and Status__c!=\'Off set\' and SBQQ__Product__r.Family=\'Ngage\')  from Contract where lastmodifieddate = Today and Status__c=\'Cancelled\' ';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc,List<Contract> scope)
    {
        System.debug('SCOPE '+scope); System.debug('SCOPE '+scope.size());
        Set<ID> ParentIDs = new Set<ID>();
        Set<ID> AccountIDsOfCancelledContracts = new Set<ID>();
        List<Account> AccountsToBeUnchecked = new List<Account>();
        Map<ID,List<SBQQ__Subscription__c>> AccountToSubMap = new Map<ID,List<SBQQ__Subscription__c>>();
		Map<ID,ID> mapOfAccToParAcc = new Map<ID,ID>();
        
        //Scope : List of cancelled contracts    
        for(Contract contr:scope)
        {
            AccountIDsOfCancelledContracts.add(contr.AccountID);
            AccountToSubMap.put(contr.AccountID,new List<SBQQ__Subscription__c>());
            mapOfAccToParAcc.put(contr.Account.ID,contr.Account.ParentID);
        }
        System.debug('Batch2 - AccountIDsOfCancelledContracts '+AccountIDsOfCancelledContracts);
        
        //Check if Accounts of picked cancelled contracts has any other active ngage product
        Map<ID,SBQQ__Subscription__c> mapOfSubs = new Map<ID,SBQQ__Subscription__c>([SELECT ID ,SBQQ__Account__r.ParentID FROM SBQQ__Subscription__c where SBQQ__Account__c IN :AccountIDsOfCancelledContracts AND Status__c!='Cancelled' and Status__c!='Off set' and SBQQ__Product__r.Family='Ngage' AND SBQQ__Account__r.Has_MH_Product__c=TRUE]);
        for(ID subID:mapOfSubs.keySet())
        {
            ID accId = mapOfSubs.get(subID).SBQQ__Account__c;
            if(AccountToSubMap.containsKey(accId))
            {
                AccountToSubMap.get(accId).add(mapOfSubs.get(subID));
            }
        }
        
        System.debug('AccountToSubMap'+AccountToSubMap);  //List of non cancelled ngage prods under each account
        
        for(ID accID:AccountToSubMap.keySet())
        {
            if(AccountToSubMap.get(accID).isEmpty()) //If there are no non-cancelled ngage prods under each account
                                                     //OR If all the ng prods are cancelled   
            {
                 ParentIDs.add(mapOfAccToParAcc.get(accID)); //Get Parent AccountIDs of selected Subs
            }
        }
            
        System.debug('ParentIDs'+ParentIDs);  
        
        Map<ID,Account> mapOfAccts = new Map<ID,Account>([SELECT ID,Name,ParentId,Has_MH_Product__c, RecordType.Name  FROM Account 
        WHERE ParentId in :ParentIDs AND RecordType.Name = 'M-NG Account' ]);
        System.debug('mapOfAccts : '+mapOfAccts);
        
        for(ID Id:mapOfAccts.keySet())
        {
            ID AccId = Id;
            Account acc = mapOfAccts.get(Id);
            acc.Has_MH_Product__c = False;
            AccountsToBeUnchecked.add(acc);
        }
        If(!AccountsToBeUnchecked.isEmpty())
        {
            try{
            Update AccountsToBeUnchecked;
            }
            catch(Exception e){
            Util.processException(e,true,'Error during updation of Accounts'+AccountsToBeUnchecked);
        }
            
        }
		
             
        
        
        
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
}
/***********************************************************************************************************************
 * @author - Lakshmi
 * @date - 11 Apr 2022
 * @description - Batch class to populate MH Account and MH Subscription
 * @testclass - Batch_PopulateMHAccOnAvvoSub_Test

Change History
************************************************************************************************************************
    Date       Requester      JIRA               Tag          Description                                                
04/28/2022     Dave         MHBS-6885            T01          Reconciliation report for Martindale Base Profile
*/

 
    global class Batch_PopulateMHAccOnAvvoSub implements Database.Batchable <SObject>,Database.AllowsCallouts,Database.Stateful{
    
    String exId;
    
    global Batch_PopulateMHAccOnAvvoSub(){
        init('');
    }
    
     global Batch_PopulateMHAccOnAvvoSub(String exId){
       init(exId);
    }
    
    global void init(String exId){
        if(!String.isEmpty(exId)){
            this.exId = exId;
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String strQuery;
        strQuery= 'Select Id,AccountId,Account.Parent.ParentId,Related_MH_Order__c,Type,num_of_Active_Advanced_360_Subscriptions__c,numofActiveMartindaleBaseProfileSub__c from Opportunity where RecordType.DeveloperName = \'M_A_Opportunity\' and (num_of_Active_Advanced_360_Subscriptions__c > 0 or numofActiveMartindaleBaseProfileSub__c > 0) and StageName = \'Receipt\' and Related_MH_Order__c = null';
        if(!String.isEmpty(this.exId))  {
           strQuery += ' and Id=: exId';        
        } 
        system.debug(strQuery+'strQuery');
        if(test.isRunningTest()) {
            strQuery = 'Select Id,AccountId,Account.Parent.ParentId,Related_MH_Order__c,Type,num_of_Active_Advanced_360_Subscriptions__c,numofActiveMartindaleBaseProfileSub__c from Opportunity where RecordType.DeveloperName = \'M_A_Opportunity\' Limit 1';           
        }
        
        return Database.getQueryLocator(strQuery);
        
    }
    
    global void execute(Database.BatchableContext BC, List <Opportunity> oppList) {
        Map<Id,Opportunity> mapOfAccountIdNOpp = new Map<Id,Opportunity>();
        List<Opportunity> lstofOppToUpdate = new List<Opportunity>();
        for(Opportunity opp : oppList){
            mapOfAccountIdNOpp.put(opp.Account.Parent.ParentId,opp); 
        }
        
        for(Order ord : [Select Id,Account.ParentId,(Select Id from OrderItems where (Product2.Name = 'Martindale-Avvo Complete Profile Plus'  or Product2.Name = 'Martindale Base Profile') Limit 1) from Order where Order.Account.ParentId in: mapOfAccountIdNOpp.keyset() and Account.RecordType.DeveloperName = 'Nolo_Account']){
            if(ord.OrderItems.size() > 0){
                if(mapOfAccountIdNOpp.containskey(ord.Account.ParentId)){
                    Opportunity opp = new Opportunity(Id = mapOfAccountIdNOpp.get(ord.Account.ParentId).Id);
                    opp.Related_MH_Order__c = ord.Id;
                    lstofOppToUpdate.add(opp);
                }
            }
            
        }
        
        if(lstofOppToUpdate.size() > 0){
            try{
                update lstofOppToUpdate;
            }
            catch(Exception ex){
                Util.processException(ex,true,'Error during update of Opportunity for Parent Order update '+lstofOppToUpdate);
            }
        }
    
    }
    
    global void finish(Database.BatchableContext BC) {

    }
    }
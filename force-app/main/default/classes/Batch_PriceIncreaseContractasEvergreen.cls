/***********************************************************************************************************************
 * @author - SS
 * @date - 11 Mar 2022
 * @description - To create EG to EG opportunity and quote for price increased evergreen contracts
 * @testclass - Test_Batch_EvgPriceIncrease

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-5998    SS            11/03/2022   John Mattheson          Create EG to EG opportunity and quote for price increased evergreen contracts
************************************************************************************************************************/

global class Batch_PriceIncreaseContractasEvergreen implements Database.Batchable <SObject>,Database.Stateful  {
    String exId;
    
    global Batch_PriceIncreaseContractasEvergreen(){
        init('');
    }
    
     global Batch_PriceIncreaseContractasEvergreen(String exId){
       init(exId);
    }
    
    global void init(String exId){
        if(!String.isEmpty(exId)){
            this.exId = exId;
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strQuery;  
        
        list<string> statuslist = new list<string>{'Evergreen'};
            
            strQuery= 'Select Id,Modify_Status__c,Status__c,SBQQ__Order__c from contract where Status__c in: statuslist and Price_Increased__c = true';
        if(!String.isEmpty(this.exId))  {
           strQuery += ' and  id = ' + '\''+ this.exId+'\'';        
        }      
        if(test.isRunningTest()) {
            strQuery= 'Select Id,Modify_Status__c,Status__c,SBQQ__Order__c from contract limit 1';           
        }        
        return Database.getQueryLocator(strQuery);
        
    }
    
    global void execute(Database.BatchableContext BC, List <Contract> ContractsList) {
        List<Contract> updateContracts = new List<Contract>();
        List<Order> updateOrders = new List<Order>();
        List<orderItem> updateOrderItems = new List<Orderitem>();
        List<SBQQ__Subscription__c> updateSubs = new List<SBQQ__Subscription__c>();
        Set<Id> orderids = new Set<Id>();
        
        //update contracts to create opportunity
        for(Contract obj: ContractsList){
                obj.Modify_Status__c = 'Evergreen Modify';
            if(test.isRunningTest() != true){
                System.enqueueJob(new AmendQueueable(obj.Id));
            }
                orderids.add(obj.SBQQ__Order__c);
                updateContracts.add(obj);
            
        }
        
        for(SBQQ__Subscription__c obj:[select Id,SBQQ__Product__r.Name,SBQQ__Contract__c,Status__c from SBQQ__Subscription__c where SBQQ__Contract__c in:ContractsList  and Status__c = 'Active']){
           System.debug(obj);
            if(obj.SBQQ__Product__r.Name != 'Custom Content'){                
                obj.Status__c= 'Rebased';
                updateSubs.add(obj);
            }
        } 
        system.debug('updateSubs'+updateSubs);
        
        //update orders
        for(Order obj : [select Id,Status__c from order where Id in :orderids]){
            obj.Status__c='Evergreened';
            updateOrders.add(obj);
        } system.debug('orderids'+orderids);
        
        
        //update Orderitem
        for(orderItem obj:[select id,SBQQ__Contract__c,Status__c from orderItem where OrderId in :orderids]){
            obj.Status__c='Rebased';
            updateOrderItems.add(obj);
        }        
        
        Savepoint sp =  Database.setSavepoint();
        try{
            update updateContracts; 
        }
        catch(Exception e){
            Util.processException(e,true,'Error during updation of Contracts'+updateContracts);
            Database.rollback(sp);            
            
        }
        
        try{
            update updateOrders;
        }
        catch(Exception e){
            Util.processException(e,true,'Error during updation of Orders'+updateOrders);
        }
        
        try{
            update updateOrderItems;
        }
        catch(Exception e){
            Util.processException(e,true,'Error during updation of OrderItems'+updateOrderItems);
        }
        
        try{            
            update updateSubs;
        }
        catch(Exception e){
           Util.processException(e,true,'Error during updation of Subscription'+updateSubs);
        }
    }
    
    
    global void finish(Database.BatchableContext BC) {
    }
}
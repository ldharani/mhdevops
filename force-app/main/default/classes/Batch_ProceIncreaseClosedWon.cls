/***********************************************************************************************************************
 * @author - SS
 * @date - 11 Mar 2022
 * @description - To update Quote Status as Closed Won
 * @testclass - 

Change History
************************************************************************************************************************
*/
global class Batch_ProceIncreaseClosedWon implements Database.Batchable<sObject>, Database.AllowsCallouts, database.stateful {
    String exId;
    
    global Batch_ProceIncreaseClosedWon(){
        init('');
    }
    
     global Batch_ProceIncreaseClosedWon(String exId){
       init(exId);
    }
    
    global void init(String exId){
        if(!String.isEmpty(exId)){
            this.exId = exId;
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strQuery;
        strQuery= 'Select Id,Bill_To_Contact__c,Marketing_Contact__c,Primary_Contact__c,AccountId,Amend_Quote__c,Status__c,SBQQ__Quote__c,AutoEvergreen_Failure_Reason__c, EndDate,SBQQ__RenewalOpportunity__c,SBQQ__Order__c from contract where Status__c = \'Evergreen\'and Price_Increased__c = true'; 
        
        if(!String.isEmpty(this.exId))  {
           strQuery += ' and  id = ' + '\''+ this.exId+'\'';        
        } 
        system.debug(strQuery+'strQuery');
        if(test.isRunningTest()) {
            strQuery= 'Select Id,Bill_To_Contact__c,Marketing_Contact__c,Primary_Contact__c,AccountId,Amend_Quote__c,Status__c,SBQQ__Quote__c,AutoEvergreen_Failure_Reason__c, EndDate,SBQQ__RenewalOpportunity__c,SBQQ__Order__c from contract';           
        }
        
        return Database.getQueryLocator(strQuery);
        
    }
    
    global void execute(Database.BatchableContext BC, List <Contract> ContractsList) {
        

        Map<Id,Contract> quoteContractMap = new Map<Id,Contract>();
        Set<Id> quoteIds = new Set<Id>();
        Map<Id,Id> quoteContIDs = new Map<Id,Id>();
        list<SBQQ__Quote__c> Updatequotelist= new list<SBQQ__Quote__c>();
        Map<Id,Id> quoteVsContractIds = new Map<Id,Id>();
        
        for(Contract obj: ContractsList){

            quoteContractMap.put(obj.Amend_Quote__c,obj);
        }

        if(quoteContractMap.size() > 0){    
        
            //Query the Amended Quote to udpate all Contacts field
            for(SBQQ__Quote__c quote: [select Id,SBQQ__MasterEvergreenContract__c,SBQQ__Status__c,SBQQ__Ordered__c,Reason_Won_Lost__c,SBQQ__EndDate__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Marketing_Contact__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Bill_To_Contact__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Primary_Contact__c from SBQQ__Quote__c where id in:quoteContractMap.keyset() and SBQQ__Status__c!='Closed Won']){            
               quoteVsContractIds.put(quote.Id,quote.SBQQ__MasterEvergreenContract__c);
                quote.Marketing_Contact__c=quoteContractMap.get(quote.Id).Marketing_Contact__c;
                quote.Billing_Contact__c=quoteContractMap.get(quote.Id).Bill_To_Contact__c;
                quote.SBQQ__PrimaryContact__c=quoteContractMap.get(quote.Id).Primary_Contact__c;
                Updatequotelist.add(quote);
            }
            
            try{
              update Updatequotelist ;
            }
            catch(Exception ex){
                Util.processException(ex,true,'Error Updating Quote With Contacts'+Updatequotelist,quoteVsContractIds);
            }
            
            Updatequotelist = new List<SBQQ__Quote__c>();
            
            //Query the Amemded Quote to update Status as Closed Won
            for(SBQQ__Quote__c quote: [select Id,SBQQ__MasterEvergreenContract__c,SBQQ__Status__c,SBQQ__Ordered__c,Reason_Won_Lost__c,SBQQ__EndDate__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Marketing_Contact__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Bill_To_Contact__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Primary_Contact__c from SBQQ__Quote__c where id in:quoteContractMap.keyset() and SBQQ__Status__c!='Closed Won']){
                quoteVsContractIds.put(quote.Id,quote.SBQQ__MasterEvergreenContract__c);
                quote.SBQQ__Ordered__c= true;  
                quote.SBQQ__Status__c = 'Closed Won';
                quote.Reason_Won_Lost__c = 'Evergreen Increase';  
                
                Updatequotelist.add(quote);
                system.debug('enter update 2 quote'+quote.Id);      
            }
            
            try{
                update Updatequotelist;
            }       
            catch(Exception ex){
               
                Util.processException(ex,true,'Error Updating Quote With Closed Won'+Updatequotelist,quoteVsContractIds);
            }
            
            //Update Price Increased as False for Contracts     
            for(Contract contr: ContractsList){
                contr.Price_Increased__c = false;
            }
            
            try{
                update ContractsList;
            } 
            catch(Exception ex){
                Util.processException(ex,true,'Error Updating Contract with Price Increased as False'+ContractsList);
            }
        }       
    
    }

global void finish(Database.BatchableContext BC) {
    
}

}
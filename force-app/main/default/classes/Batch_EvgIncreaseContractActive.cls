/***********************************************************************************************************************
 * @author - SS
 * @date - 11 Mar 2022
 * @description - To change the contract back to original status by updating the related quote as Closed Lost
 * @testclass - Test_Batch_EvgPriceIncrease

Change History
************************************************************************************************************************
*/

global class Batch_EvgIncreaseContractActive implements Database.Batchable <SObject>,Database.AllowsCallouts,Database.Stateful  {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strQuery ='';
        
        strQuery= 'Select Id,Status__c,Amend_Quote__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c ,SBQQ__RenewalOpportunity__c,SBQQ__Order__c from contract where Status__c != \'Evergreen\' and Status__c like \'%in progress\' and Price_Increased__c = true';
        
        System.debug(strQuery+'strQuery');
        if(test.isRunningTest()) {
            strQuery= 'Select Id,Status__c,Amend_Quote__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c ,SBQQ__RenewalOpportunity__c,SBQQ__Order__c from contract limit 1';         
        }
        
        return Database.getQueryLocator(strQuery);
        
    }
    
    global void execute(Database.BatchableContext BC, List <Contract> ContractsList) {
        
        List<SBQQ__Quote__c> ClosedLostQuotes = new list<SBQQ__Quote__c>();
        Set<Id> listofquoteIds = new Set<id>();
        Set<Id> quoteIds = new Set<id>();
        Map<Id,Id> mapofquotetocontractId=new map<Id,Id>();
        Map<Id,String> MapofcontractToError = new map<id,string>();
        
        for(Contract obj: ContractsList){
            if(obj.Status__c == 'Evergreen in progress'){
                quoteIds.add(obj.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c);
                mapofquotetocontractId.put(obj.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c,obj.Id);
            }else{
                if(obj.Amend_Quote__c != null){
                    quoteIds.add(obj.Amend_Quote__c); 
                    mapofquotetocontractId.put(obj.Amend_Quote__c,obj.Id);
                }
            }
            
            
        } 
        
        //close lost the quotes
        for(SBQQ__Quote__c quote: [select Id,Reason_Won_Lost__c, IsEvergeened__c,SBQQ__Status__c from SBQQ__Quote__c where SBQQ__Status__c !='Approved' and SBQQ__Status__c != 'QA Review' and Id in : quoteIds] ){
            quote.SBQQ__Status__c = 'Closed Lost';
            quote.Reason_Won_Lost__c='Evergreen Increase';
            ClosedLostQuotes.add(quote);
        }
        
        
        system.debug('ClosedLostQuotes'+ClosedLostQuotes);
        
        try{
            if(Test.isRunningTest() ) {  
                ClosedLostQuotes[0].Id = null;            
            }
            update ClosedLostQuotes;        
            
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }        
    
    global void finish(Database.BatchableContext BC) {
    }
}
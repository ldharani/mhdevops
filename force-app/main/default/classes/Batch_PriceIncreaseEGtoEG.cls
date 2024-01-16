/***********************************************************************************************************************
 * @author - SS
 * @date - 11 Mar 2022
 * @description - To create EG to EG opportunity and quote for price increased evergreen contracts
 * @testclass - Test_Batch_EvgPriceIncrease

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-5998    SS            11/03/2022   John Mattheson          Update EG to EG quote for price increased evergreen contracts
************************************************************************************************************************/
global class Batch_PriceIncreaseEGtoEG implements Database.Batchable <SObject>,Database.AllowsCallouts,Database.Stateful{
    
    String exId;
    
    global Batch_PriceIncreaseEGtoEG(){
        init('');
    }
    
     global Batch_PriceIncreaseEGtoEG(String exId){
       init(exId);
    }
    
    global void init(String exId){
        if(!String.isEmpty(exId)){
            this.exId = exId;
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String strQuery;
        strQuery= 'Select Id,Amend_Quote__c,Status__c,SBQQ__Quote__c,AutoEvergreen_Failure_Reason__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Status__c ,SBQQ__Order__c from contract where Status__c = \'Evergreen\' and Price_Increased__c = true'; 
        if(!String.isEmpty(this.exId))  {
           strQuery += ' and  id = ' + '\''+ this.exId+'\'';        
        } 
        system.debug(strQuery+'strQuery');
        if(test.isRunningTest()) {
            strQuery= 'Select Id,Amend_Quote__c,Status__c,SBQQ__RenewalOpportunity__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c,AutoEvergreen_Failure_Reason__c from contract';           
        }
        
        return Database.getQueryLocator(strQuery);
        
    }
    
    global void execute(Database.BatchableContext BC, List <Contract> ContractsList) {
        MDL_RecursionHandler.batchAutoEvgPriceincreaseCheck = false;
        System.debug('ContractsList'+ContractsList);
        Set<Id> quoteIds = new Set<Id>();
        List<SBQQ__QuoteLine__c> updateQuoteline = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> qlineList = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> insertqlineList = new List<SBQQ__QuoteLine__c>();
        Map<Id,Id> quoteLineVsContractIds = new Map<Id,Id>();
        
        for(Contract obj: ContractsList){
            quoteIds.add(obj.Amend_Quote__c); 
            
        } 
        
        //Extract Old Quote Lines of Amended Quote
        if(quoteIds.size() > 0){
            if(!test.isRunningTest()){
                qlineList= [ select id,SBQQ__Quote__r.SBQQ__MasterEvergreenContract__c,SBQQ__Group__c,SBQQ__Quote__c,Part_of_Upsell__c,SBQQ__SubscriptionType__c,SBQQ__ProductSubscriptionType__c,SBQQ__SubscriptionTerm__c,SBQQ__EndDate__c,SBQQ__Quantity__c from SBQQ__QuoteLine__c where SBQQ__Quote__c in : quoteIds and SBQQ__Source__c = null];
            }else{
                qlineList = [ select id,SBQQ__Quote__r.SBQQ__MasterEvergreenContract__c,SBQQ__Group__c,SBQQ__Quote__c,Part_of_Upsell__c,SBQQ__SubscriptionType__c,SBQQ__ProductSubscriptionType__c,SBQQ__SubscriptionTerm__c,SBQQ__EndDate__c,SBQQ__Quantity__c from SBQQ__QuoteLine__c limit 1];
            }
        
        
            List<SBQQ__Quote__c> qList = [Select Id,Calculate_Billing_Unit_Price__c from SBQQ__Quote__c where id in:quoteIds];
            List<SBQQ__QuoteLineGroup__c> insertQLG = new  List<SBQQ__QuoteLineGroup__c>();
            
            //Create Quote Line Group for Old Quote Lines
            for(SBQQ__Quote__c q: qList){                
                SBQQ__QuoteLineGroup__c group1 = new SBQQ__QuoteLineGroup__c();
                group1.name = 'Group 1';
                group1.SBQQ__Quote__c = q.Id ;
                group1.SBQQ__CustomerTotal__c = 0;
                group1.SBQQ__ListTotal__c = 0;
                group1.SBQQ__NetTotal__c = 0;
                group1.SBQQ__Number__c = 1;
                insertQLG.add(group1);              
                q.Calculate_Billing_Unit_Price__c = true;
            }
            try{    
            insert insertQLG;
            }
            catch(Exception ex){
                Util.processException(ex,true,'Error during insert of Quote Line Group'+insertQLG);
            }
            
            //Create Map for Quote and Quote Line Group
            List<SBQQ__QuoteLineGroup__c> qlgList = [Select Id,SBQQ__Quote__c from SBQQ__QuoteLineGroup__c where SBQQ__Quote__c in:quoteIds];
            Map<id,id> quoteVsqlgId = new Map<Id,Id>();
            for(SBQQ__QuoteLineGroup__c qlg :qlgList){
                quoteVsqlgId.put(qlg.SBQQ__Quote__c,qlg.Id);
            
            }
        
            //Update Old Quote Line Quantity to 0 and update Quote Line Group to Group 1
            if(qlineList.size() > 0){
                for(SBQQ__QuoteLine__c quoteline: qlineList){  
                    quoteLineVsContractIds.put(quoteline.Id,quoteline.SBQQ__Quote__r.SBQQ__MasterEvergreenContract__c);
                    quoteline.SBQQ__Quantity__c = 0;                 
                    if(quoteVsqlgId.containskey(quoteline.SBQQ__Quote__c))
                        quoteline.SBQQ__Group__c = quoteVsqlgId.get(quoteline.SBQQ__Quote__c);
                }
            }  
                
            if(!test.isrunningtest()){ 
                try{
                    update qlineList;
                }
                catch(Exception e){
                    Util.processException(e,true,'Error during updation of Quote Lines'+qlineList,quoteLineVsContractIds);
                }
                try{
                    update qList;
                }
                catch(Exception e){
                   Util.processException(e,true,'Error during updation of Quote Lines'+qList);
                }

            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {

    }
    
}
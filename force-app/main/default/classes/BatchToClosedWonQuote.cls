/***************
* Class Name: BatchToClosedWonQuote
* Test Class: BatchToCreateAttyQuoteProcess_Test
* Description: MHBS-9016 Automate close won the Quote with WebVantage Products
* Developed By: Jeyamugundan
* Modification History : Created on May 10,2023* 
* ******/ 
global class BatchToClosedWonQuote implements Database.Batchable<sObject>,Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator( [SELECT Id,SBQQ__Status__c,Is_Quote_Created_By_Batch__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Marketing_Contact__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Bill_To_Contact__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Primary_Contact__c FROM SBQQ__Quote__c WHERE  Is_Quote_Created_By_Batch__c= True AND SBQQ__Status__c != 'Closed Won' AND SBQQ__Status__c != 'Closed Lost' AND (SBQQ__Opportunity2__r.OrgID_Mismatch_Check__c =0 OR SBQQ__Opportunity2__r.OrgID_Mismatch_Check__c = Null) ] );
    }
    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> newQuote){
        List<SBQQ__Quote__c> quoListUpdate = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c QuoR : newQuote){
            QuoR.Marketing_Contact__c=QuoR.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Marketing_Contact__c;
            QuoR.Billing_Contact__c=QuoR.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Bill_To_Contact__c;
            QuoR.SBQQ__PrimaryContact__c=QuoR.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Primary_Contact__c;
            QuoR.SBQQ__Ordered__c=true;  
            QuoR.SBQQ__Status__c = 'Closed Won';
            quoListUpdate.add(QuoR);   
        }
        
        try{
            if(quoListUpdate.Size() > 0){
                Update quoListUpdate;
            }
        }catch(Exception e){
            Util.processException(e,true,'Quote Update Fail on BatchToClosedWonQuote' + quoListUpdate);
        }
        
    }  
    global void finish(Database.BatchableContext bc){
        Database.executeBatch(new BatchToCreateContract(),1);
    }  
}
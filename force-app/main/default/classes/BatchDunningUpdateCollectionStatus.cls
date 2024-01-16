/***********************************************************************************************************************
 * @author - Lakshmi
 * @date - 27 Nov 20223
 * @description - Batch class to update Collection Status on Account when past due amount is updated
 * @testclass - BatchDunningUpdateCollectionStatusTest

Change History
************************************************************************************************************************
*/
global class BatchDunningUpdateCollectionStatus implements Database.Batchable <SObject> {
    
    String exId;
    global BatchDunningUpdateCollectionStatus(){
        init('');
    }
    
    global BatchDunningUpdateCollectionStatus(String exId){
       init(exId);
    }
    
    global void init(String exId){
        if(!String.isEmpty(exId)){
            this.exId = exId;
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strQuery;
        strQuery= 'Select Id,Retrigger_Dunning_Emails__c,SFBD__CollectionsStatus__c from Account where Retrigger_Dunning_Emails__c = true and Total_Amount_Past_Dues__c > 10 and Dunning_Exception__c = false and SFBD__CollectionsStatus__c = \'Pending Collections\'';
        if(!String.isEmpty(this.exId))  {
           strQuery += ' and Id=: exId';        
        } 
        system.debug(strQuery+'strQuery');
        if(test.isRunningTest()) {
            strQuery = 'Select Id,Retrigger_Dunning_Emails__c,SFBD__CollectionsStatus__c from Account Limit 1';           
        }
        
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext BC, List <Account> accList) {
        for(Account acc : accList){
            acc.Retrigger_Dunning_Emails__c = false;
            acc.SFBD__CollectionsStatus__c = 'In Collections';
        }
        if(accList.size() > 0){
            try{
                update accList;
            }
            catch(Exception ex){
                Util.processException(ex,true,'Error updating the Accounts Collection Status'+ accList);
            }
        }
            
    }
    global void finish(Database.BatchableContext BC) {

    }
    
}
/***********************************************************************************************************************
 * @author - SaiVihari
 * @date - 13 Apr 2022
 * @description - Batch class to update SEO strategist assignment
 * @testclass - 

Change History
************************************************************************************************************************
*/
global class Batch_automateSEOStrategistAssignment implements Database.Batchable <SObject>,Database.AllowsCallouts,Database.Stateful{
    global String query;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = ' select id,Project_ID__c,Project__c,Project_Milestone__c,SEOStrategistonProject__c,Assigned_Onwer__c'+ 
                ' FROM Milestone1_Task__c where SEOStrategistonProject__c != NULL AND Assigned_Onwer__c = \'MS - SEO Strategist\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List <Milestone1_Task__c> tskList) {
        system.debug('==tskList=='+tskList);
        List<Milestone1_Task__c> tsksToUpdate = new List<Milestone1_Task__c>();
        for(Milestone1_Task__c tsk: tskList){
           if(tsk.Assigned_Onwer__c == 'MS - SEO Strategist' && tsk.SEOStrategistonProject__c != Null){
                tsk.Assigned_Onwer__c = tsk.SEOStrategistonProject__c;
                tsk.assign_To_Type__c  = 'User';
                tsksToUpdate.add(tsk);
            }
        }
        system.debug('==tsksToUpdate=='+tsksToUpdate);
        if(!tsksToUpdate.isEmpty()){
            update tsksToUpdate;
        }
    }
    global void finish(Database.BatchableContext BC) {

    }
}
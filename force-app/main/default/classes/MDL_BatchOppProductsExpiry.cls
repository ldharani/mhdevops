/*
 * Created By : Lister Technologies
 * Created Date : 29-April-2014
 * Created Purpose : Batch Class which will be used to send Release Inventory in case of Opp Products Expiration 
 * Test Class : MDL_Test_BatchOppProductsExpiry.cls
 *
 * Modified Date : 11 March 2015
 * Purpose : Inventory should not be released if the renew/rebase opportunity is open past 30 days. It has SIN
 *
 * Modified Date : 15 May 2015
 * Purpose : Blanking of inventory id after release is done in the Integration class after receiving 200 response. Hence commented update in the batch
 */
global class MDL_BatchOppProductsExpiry implements Database.Batchable<sObject>,Database.AllowsCallouts{
    global String query;
    global User u;
    global Set<Id> setOppProdIds;
    global MDL_BatchOppProductsExpiry() {
        u = [select Id, username from User where Id = :UserInfo.getUserId()];
        setOppProdIds = new Set<Id>();
        query = '';
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'Select i.invoiceit_crmx__Product__c, i.Product_SIN__c, i.Valid_Till__c, i.Name, i.IsInventoried__c, i.InventoryId__c, i.Id From invoiceit_crmx__Opportunity_Product__c i  where i.Valid_Till__c < TODAY and i.InventoryId__c != \'\' and i.invoiceit_crmx__Opportunity__r.StageName != \'Closed Won\' and i.invoiceit_crmx__Opportunity__r.Quote_Type__c!=\'Renew\' and (i.RecordType.DeveloperName = \'MDL_Opportunity_Product\' or i.RecordType.DeveloperName = \'Nolo_Opportunity_Product\') ' ;
        if(Test.isRunningTest()) {
        	query += ' LIMIT 5';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<invoiceit_crmx__Opportunity_Product__c> scope) {
        List<invoiceit_crmx__Opportunity_Product__c> lstOppProdToUpdate = new List<invoiceit_crmx__Opportunity_Product__c>();
        for(invoiceit_crmx__Opportunity_Product__c oppProducts : scope) {
            if(oppProducts.Product_SIN__c==null || oppProducts.Product_SIN__c==''){
                setOppProdIds.add(oppProducts.Id);
                oppProducts.InventoryId__c = '';
                lstOppProdToUpdate.add(oppProducts);
            }
        }
        if(!test.isRunningTest()) {
            MDL_Integration_Vim_Efs.releaseInventoryRequestFromBatch(setOppProdIds, u.Username);
        }   
        /*if(lstOppProdToUpdate.size() > 0) {
            Database.update(lstOppProdToUpdate);
        }*/
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}
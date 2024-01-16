/*
** Created By : Lister Technologies
** Created Purpose : Created to update the existing Total Amount Past Due on Account
** Test class : Batch_DunningUpdateOnAccount_Test

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Description
MHBS-8877    Jey         05/04/2023     Fix Past Due amount on Accounts for Dunning  
************************************************************************************************************************
*/
global class Batch_ToUpdatePastDueAmount implements Database.Batchable<sObject>{
    
    global Database.querylocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Total_Amount_Past_Dues__c FROM Account WHERE RecordType.DeveloperName =\'Nolo_Account\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> ListofAcc) {
    /*    Map<Id,Decimal> mapAcc = new Map<Id,Decimal>();
        Id MHRecordTypeId = Schema.SObjectType.blng__Invoice__c.getRecordTypeInfosByDeveloperName().get('MH_Invoice').getRecordTypeId();
        
        List<blng__Invoice__c> invlist = new List<blng__Invoice__c>();
        if(test.isRunningTest()){
            invlist = [SELECT Id,blng__Account__c,blng__Balance__c FROM blng__Invoice__c WHERE RecordTypeId =: MHRecordTypeId AND blng__Account__c IN: ListofAcc];
            system.debug('BatchAAAAAAA '  + invlist);
        }else{
            invlist = [SELECT Id,blng__Account__c,blng__Balance__c FROM blng__Invoice__c WHERE RecordTypeId =: MHRecordTypeId AND blng__Account__c IN: ListofAcc AND blng__Balance__c > 1 AND blng__InvoiceStatus__c = 'POSTED' AND blng__DueDate__c < TODAY];
            system.debug('BatchBBBBBBB '  + invlist);
        }
        for(blng__Invoice__c inv : invlist){
            if(mapAcc.ContainsKey(inv.blng__Account__c)){
                Decimal dec = mapAcc.get(inv.blng__Account__c);
                dec += inv.blng__Balance__c;
                mapAcc.put(inv.blng__Account__c,dec );
            }else{
                mapAcc.put(inv.blng__Account__c,inv.blng__Balance__c );
            }
        }
        List<Account> updateAcc = new List<Account>();
        for(Account acc : ListofAcc) {
            if(mapAcc.ContainsKey(acc.Id)){
                //acc.Total_Amount_Past_Dues__c = mapAcc.get(acc.Id);
                updateAcc.add(acc);
            }
        }
        
        if(updateAcc.size()>0){
            Update updateAcc;
        }
        */
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}
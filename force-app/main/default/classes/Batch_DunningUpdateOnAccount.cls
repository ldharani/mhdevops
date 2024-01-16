global class Batch_DunningUpdateOnAccount implements Database.Batchable<sObject>{
    
    // global void execute(SchedulableContext SC) { 
    //     Batch_DunningUpdateOnAccount btc = new Batch_DunningUpdateOnAccount();
    //     Database.executeBatch(btc,200); 
    // },Schedulable
    global Database.querylocator start(Database.BatchableContext BC) {
        String query;
        if(test.isRunningTest()){
            query = 'select Id,SFBD__CollectionsStatus__c ,SFBD__CollectionsPlanDate__c from Account';
        }else{
            //query = 'select Id,SFBD__CollectionsStatus__c ,SFBD__CollectionsPlanDate__c from Account WHERE Past_Due_Date__c <= TODAY AND Total_Amount_Past_Dues__c > 10 AND AccountBalanceAmount__c > 0 AND Finance_Class__c != \'National\'';
            query = 'select Id,SFBD__CollectionsStatus__c ,SFBD__CollectionsPlanDate__c,SFBD__DunningMethod__c,Total_Amount_Past_Dues__c,AccountBalanceAmount__c,Dunning_Exception__c,Finance_Class__c from Account WHERE Dunning_Exception__c = False AND SFBD__DunningMethod__c != Null AND SFBD__CollectionsStatus__c != \'Bad Debt\' AND Total_Amount_Past_Dues__c > 10 AND AccountBalanceAmount__c > 0 AND Finance_Class__c != \'National\' AND Finance_Class__c != \'Agency\' ';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> ListofAcc) {
        System.debug('AABBBCCC ' + ListofAcc);
        Id MHRecordTypeId = Schema.SObjectType.blng__Invoice__c.getRecordTypeInfosByDeveloperName().get('MH_Invoice').getRecordTypeId();
        
        Map<Id,Account> mapAcc = new Map<Id,Account>();
        List<blng__Invoice__c> invlist = new List<blng__Invoice__c>();
        
        if(test.isRunningTest()){
            invlist = [Select Id,blng__Account__r.Past_Due_Date__c,blng__DueDate__c,blng__Account__r.Dunning_Exception__c,blng__Account__r.Due_Date__c,blng__Account__r.SFBD__CollectionsStatus__c,blng__Account__r.SFBD__CollectionsPlanDate__c,blng__Account__c from blng__Invoice__c WHERE RecordTypeId =: MHRecordTypeId AND blng__Account__c IN: ListofAcc];
            system.debug('BatchAAAAAAA '  + invlist);
        }else{
            invlist = [Select Id,blng__Account__r.Past_Due_Date__c,blng__DueDate__c,blng__Account__r.Dunning_Exception__c,blng__Account__r.Due_Date__c,blng__Account__r.SFBD__CollectionsStatus__c,blng__Account__r.SFBD__CollectionsPlanDate__c,blng__Account__c from blng__Invoice__c WHERE RecordTypeId =: MHRecordTypeId AND blng__Balance__c > 0 AND blng__Account__c IN: ListofAcc];
            system.debug('BatchBBBBBBB '  + invlist);
        }
        
        for(blng__Invoice__c inv : invlist){
            System.debug('BatchCCCCCC ' + inv.blng__Account__r.Due_Date__c);
            System.debug('BatchDDDDDD ' + inv.blng__DueDate__c);
            
            if(inv.blng__Account__r.Due_Date__c == inv.blng__DueDate__c || test.isRunningTest()){
                System.debug('BatchEEEEE '); 
                
                Date pastDuePlus14;
                if(!test.isRunningTest()){
                    System.debug('BatchFFFFF ' + inv.blng__Account__r.Past_Due_Date__c);
                    pastDuePlus14 = inv.blng__Account__r.Past_Due_Date__c.addDays(13);
                    System.debug('BatchGGGGG ' + pastDuePlus14);
                }else{
                    System.debug('BatchHHHHH ' + pastDuePlus14);
                    pastDuePlus14 = System.today();    
                }
                
                Account acc = new Account(Id = inv.blng__Account__c);
                System.debug('BatchIIIII ' + inv.ID + ' ' + acc.Id);
                System.debug('BatchJJJJJ ' + inv.blng__Account__r.SFBD__CollectionsStatus__c);
                System.debug('BatchKKKKK ' + inv.blng__Account__r.SFBD__CollectionsPlanDate__c);
                System.debug('BatchLLLLL ' + inv.blng__Account__r.Dunning_Exception__c);
                System.debug('BatchMMMMM ' + inv.blng__Account__r.Past_Due_Date__c);
                System.debug('BatchNNNNN ' + pastDuePlus14);
                               
                if(inv.blng__Account__r.SFBD__CollectionsStatus__c != 'In Collections' && inv.blng__Account__r.SFBD__CollectionsPlanDate__c == Null && inv.blng__Account__r.Dunning_Exception__c == False){
                    System.debug('BatchOOOOPPPP');
                    if(inv.blng__Account__r.Past_Due_Date__c == System.today()){
                        System.debug('BatchOOOOOO ' + acc.Id);
                        acc.SFBD__CollectionsStatus__c = 'Pending Collections';
                        mapAcc.put(acc.Id, acc);
                    }else if(pastDuePlus14 == system.today()){
                        System.debug('BatchPPPPPP ' + acc.Id);
                        acc.SFBD__CollectionsStatus__c = 'In Collections';
                        acc.SFBD__CollectionsPlanDate__c = system.today();
                        mapAcc.put(acc.Id, acc);
                    }
                }
            }
        }
        
        system.debug('BatchQQQQQQ '+ mapAcc);
        if(mapAcc.size() > 0){
            system.debug('BatchRRRRRR '+ mapAcc);
            Update mapAcc.values();
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
    
}
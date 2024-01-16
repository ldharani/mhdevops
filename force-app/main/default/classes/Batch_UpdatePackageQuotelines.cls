/***********************************************************************************************************************
 * @author - SS
 * @date - 30 Mar 2022
 * @description - To update package relationship on cloned quotelines for evergreen price increase process
 * @testclass - Test_Batch_EvgPriceIncrease

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6878    SS            30/03/2022   John Mattheson          Package relationship cascading on EG price increase batch job
************************************************************************************************************************/
global class Batch_UpdatePackageQuotelines implements Database.Batchable <SObject>,Database.AllowsCallouts,Database.Stateful{
    
    global Set<Id> qlIds;

    global Batch_UpdatePackageQuotelines(Set<Id> qlIds) {
        this.qlIds = qlIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strQuery;
        
        System.debug(qlIds);
        strQuery= 'Select Id,SBQQ__Bundled__c,SBQQ__RequiredBy__c, Name, SBQQ__Product__r.Name  from SBQQ__QuoteLine__c where id in :qlIds'; 
       
        if(test.isRunningTest()) {
            strQuery= 'Select Id,SBQQ__Bundled__c,SBQQ__RequiredBy__c, Name, SBQQ__Product__r.Name  from SBQQ__QuoteLine__c where id in :qlIds';           
        }
        System.debug(strQuery);
        
        return Database.getQueryLocator(strQuery);
        
    }
    
    global void execute(Database.BatchableContext bc, List<SBQQ__QuoteLine__c> qlList) {
        Id martindalePkgId;
        Id pkgId;
        System.debug('Quoteline Ids : ' + qlIds);
        System.debug(qlList.size());
        System.debug(qlList);
        List<SBQQ__QuoteLine__c> updateQuotelines = new List<SBQQ__QuoteLine__c>();
       for(SBQQ__QuoteLine__c ql:qlList){
            System.debug(ql.SBQQ__Product__r.Name);
            if(ql.SBQQ__Product__r.Name.contains('All Martindale Packages')){
                martindalePkgId = ql.Id;
            }
            if(ql.SBQQ__Product__r.Name.contains('Package') && ql.SBQQ__Product__r.Name.contains('All Martindale Packages') != true){
                pkgId = ql.Id;
            }
            System.debug('martindalePkgId'+martindalePkgId +'pkgId'+pkgId);
        }
        
        for(SBQQ__QuoteLine__c ql:qlList){
            if(ql.SBQQ__Product__r.Name.contains('All Martindale Packages') != true){
                      if(ql.SBQQ__Product__r.Name.contains('Package')){
                ql.SBQQ__RequiredBy__c = martindalePkgId;

                      }else {
                          if(ql.SBQQ__Bundled__c == true){
                           ql.SBQQ__RequiredBy__c = pkgId;
                          }

                      }
            }
            updateQuotelines.add(ql);
            System.debug('martindalePkgId'+martindalePkgId +'pkgId'+pkgId);
        } 
        System.debug('updateQuotelines : '+updateQuotelines);
        try{
        update updateQuotelines;
        } 
        catch(Exception ex){
                Util.processException(ex,true,'Error during update of requiredby field Cloned Quote Lines'+updateQuotelines);
            }
            
    } 
    
     global void finish(Database.BatchableContext BC) {
       
    }
    
}
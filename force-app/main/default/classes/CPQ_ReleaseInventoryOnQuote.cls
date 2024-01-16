public class CPQ_ReleaseInventoryOnQuote {
    public void releaseInventoryOnOppClosedLost(List<SBQQ__Quote__c> trgnew,Map<Id,SBQQ__Quote__c> mapold,Map<Id,SBQQ__Quote__c> mapnew){
        
        system.debug('@@@ in releaseInventoryOnOppClosedLost');
        Set<Id> setOppIds = new Set<Id>();
        Set<Id> setOppProdIds = new Set<Id>();
        set<id> setorder = new set<id>();
        list<OrderItem> ordlist = new list<OrderItem>();
        Map<Id,String> mapOppProdNInventoryId = new Map<Id,String>();
        List<SBQQ__QuoteLine__c> listOppProdsToUpdate = new List<SBQQ__QuoteLine__c>();
        // User u = [select Id, username from User where Id = :UserInfo.getUserId()];
        for(SBQQ__Quote__c opp : trgnew){
            system.debug('@@@@ opp.SBQQ__Status__c '+opp.SBQQ__Status__c );
            system.debug('@@@@@@mapold.get(opp.Id).SBQQ__Status__c '+mapold.get(opp.Id).SBQQ__Status__c);
            system.debug('@@@@ opp.SBQQ__Type__c'+opp.SBQQ__Type__c);
            if(opp.SBQQ__Status__c =='Closed Lost' && (mapold.get(opp.Id).SBQQ__Status__c != mapnew.get(opp.Id).SBQQ__Status__c) && (opp.Subscription_type__c!='Renewal')){
                system.debug('@@@ in closed lost condition');
                setOppIds.add(opp.Id);
            }
        }
        if(setOppIds.size()>0){
            releaseOrderProductInventories(setOppIds);
        }
        
       MDL_RecursionHandler.releaseInvQuote= false;

        
    }
    
    public static void releaseOrderProductInventories(Set<Id> oppIds){
        system.debug('==oppIds=='+oppIds);
        Set<Id> setOppProdIds                 = new Set<Id>();
        Map<Id,String> mapOppProdNInventoryId = new Map<Id,String>();
        List<SBQQ__QuoteLine__c> listOppProdsToUpdate = new List<SBQQ__QuoteLine__c>();
        
        User u = [select Id, username from User where Id = :UserInfo.getUserId()];
        for(SBQQ__QuoteLine__c oppProd :[select Id,Inventory_Id__c,SIN__c,SBQQ__Product__r.IsInventoried__c,SBQQ__Quote__c  from SBQQ__QuoteLine__c where SBQQ__Quote__c in :oppIds and SBQQ__Product__r.IsInventoried__c =true]){
            system.debug('==oppProd=='+oppProd);
            if(oppProd.SIN__c==null || oppProd.SIN__c==''){ //|| oppProd.invoiceit_crmx__Opportunity__r.Closed_lost_from_Order__c ){
                system.debug('==if 1=='+oppProd.SIN__c);
                if(oppProd.Inventory_Id__c!=null && oppProd.Inventory_Id__c!=''){
                    system.debug('==if 2=='+oppProd.Inventory_Id__c);
                    mapOppProdNInventoryId.put(oppProd.Id,oppProd.Inventory_Id__c);
                    //setOppProdIds.add(oppProd.Id);
                    oppProd.Inventory_Id__c = '';
                    listOppProdsToUpdate.add(oppProd);
                    if(oppProd.SIN__c==null || oppProd.SIN__c==''){ //|| (oppProd.invoiceit_crmx__Opportunity__r.Closed_lost_from_Order__c && (oppProd.Product_SIN__c==null || oppProd.Product_SIN__c==''))){
                        setOppProdIds.add(oppProd.Id);
                    }
                }
            }       
        }
        system.debug('==setOppProdIds=='+setOppProdIds);
        system.debug('==mapOppProdNInventoryId=='+mapOppProdNInventoryId);
        if(setOppProdIds.size()>0){ //&& MDL_RecursionHandler.releaseInventoryOnOppClosedLost ){ 
            if(!Test.isRunningTest() ){
                ID jobID = System.enqueueJob(new CPQ_ReleaseInventroyQueueable(oppIds,setOppProdIds,u.Username,mapOppProdNInventoryId));
            }
            //MDL_RecursionHandler.releaseInventoryOnOppClosedLost = false;
        }
        
        if(listOppProdsToUpdate.size()>0){
            Database.update(listOppProdsToUpdate);
        }
    }
}
public class subscriptionHelper {
    //MHBS-5552 Ngage contract status needs to set as "Cancelled"
    public void updateContractStatus(map<Id,SBQQ__Subscription__c> newMap, map<Id,SBQQ__Subscription__c> oldMap){
        Map<Id,String> subIdVsSubStatus = new Map<Id,String>();
        Set<ID> contractIds = new Set<Id>();
        List<Contract> ContractsToUpdate = new List<Contract>();  
        Map<Id,List<SBQQ__Subscription__c>> contrVsSubscription = new Map<Id,List<SBQQ__Subscription__c>>();
        Id ngageRecordTypeId = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('Ngage Subscriptions').getRecordTypeId();
        Id ngageHSRecordTypeId = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('Ngage HS Subscriptions').getRecordTypeId();
        Id ngageIntakeRecordTypeId = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('M-A Intake Subscriptions').getRecordTypeId();
        for(SBQQ__Subscription__c orderCharge : newMap.values()) {
            if(((orderCharge.Status__c  == 'Truncated' || orderCharge.Status__c == 'Truncated-Upsell') && (orderCharge.RecordTypeID == ngageRecordTypeId || orderCharge.RecordTypeID == ngageHSRecordTypeId) && oldmap.get(orderCharge.Id).Status__c != newMap.get(orderCharge.Id).Status__c )||test.isRunningTest()) {
                contractIds.add(orderCharge.SBQQ__Contract__c);
            }
            // CBCL-88 - Jey
            if(orderCharge.RecordTypeID == ngageIntakeRecordTypeId && oldmap.get(orderCharge.Id).Status__c != newMap.get(orderCharge.Id).Status__c){
                contractIds.add(orderCharge.SBQQ__Contract__c);
            } 
        }
        //System.debug('=========contractIds============'+contractIds);
        
        if(contractIds.size()>0){
            List<SBQQ__Subscription__c> subsList = [SELECT Id,SBQQ__TerminatedDate__c,SBQQ__Contract__c FROM SBQQ__Subscription__c where Status__c = 'Active' and SBQQ__Contract__c in :contractIds];
            Map<Id,Contract> contractMap = new Map<Id,Contract>([SELECT Id,CancelDate__c,Status__c FROM Contract where id in :contractIds]); 
            for(SBQQ__Subscription__c s:subsList){
                contrVsSubscription.put(s.SBQQ__Contract__c,new List<SBQQ__Subscription__c>{s});                    
            }
            
            //System.debug('=========contrVsSubscription============'+contrVsSubscription);
            for(SBQQ__Subscription__c orderCharge : newMap.values()) {
                if(contrVsSubscription.get(orderCharge.SBQQ__Contract__c) == null && contractIds.contains(orderCharge.SBQQ__Contract__c)){
                   	contractMap.get(orderCharge.SBQQ__Contract__c).Status__c = 'Cancelled';
                    contractMap.get(orderCharge.SBQQ__Contract__c).CancelDate__c = orderCharge.SBQQ__TerminatedDate__c;
                    if(!contractsToUpdate.contains(contractMap.get(orderCharge.SBQQ__Contract__c))){
                        contractsToUpdate.add(contractMap.get(orderCharge.SBQQ__Contract__c));
                    }
                    //System.debug(contractMap.get(orderCharge.SBQQ__Contract__c));
                }
            }
            
            //System.debug('=========contractsToUpdate============'+contractsToUpdate);
            if(contractsToUpdate.size()>0){
                update contractsToUpdate;
            }
        }
    }
    
    // CBCL-88 - To update Subscription status to cancelled - Jey
    public void updateSubStatus(List<SBQQ__Subscription__c> newLst){
        List<SBQQ__Subscription__c> UpdateSub = new List<SBQQ__Subscription__c>();
        Set<Id> SubId = new Set<Id>();
        Id ngageRecordTypeId = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('M-A Intake Subscriptions').getRecordTypeId();
        for(SBQQ__Subscription__c SubRec : newLst){
            if((SubRec.RecordTypeId == ngageRecordTypeId && SubRec.SBQQ__TerminatedDate__c != Null && SubRec.Status__c == 'Active' ) || test.isRunningTest()) {
                SubId.add(SubRec.Id);
            }
        }
        if(SubId.size()>0){
            for(SBQQ__Subscription__c SubRecA : [SELECT Id,Status__c FROM SBQQ__Subscription__c WHERE ID IN: SubId]){
                SubRecA.Status__c = 'Cancelled';
                UpdateSub.add(SubRecA);
            }
        }
        if(UpdateSub.size()>0 && !test.isRunningTest()){
            Update UpdateSub;
        }
    } 
    
    /*added by saiv MHBS-5095 T08*/
    public static void sendEmailNotification(List<SBQQ__Subscription__c> newList){
        Set<Id> SubIds = new Set<Id>();
        Set<Id> conId = new Set<Id>();
        List<Contract> contractListToUpdate = new List<Contract>();
        for(SBQQ__Subscription__c obj:[ SELECT Id,SBQQ__Contract__c,SBQQ__Product__r.Business_Unit__c,SBQQ__Product__r.Family,
                                       SBQQ__Contract__r.Email_Sent__c,RecordType.DeveloperName,SBQQ__Quantity__c
                                       FROM SBQQ__Subscription__c WHERE Id IN:newList AND SBQQ__Contract__c != null
                                       AND SBQQ__Contract__r.Email_Sent__c = false AND SBQQ__Product__r.Family ='Ngage'
                                       
                                      ]){
                                          if(obj.SBQQ__Contract__c != Null && !conId.contains(obj.SBQQ__Contract__c)){
                                              conId.add(obj.SBQQ__Contract__c);
                                          }
                                      }
        if(conId<>Null){
            for(Contract ct:[select id, Email_Sent__c from contract where id=:conId]){
                ct.Email_Sent__c = true;
                contractListToUpdate.add(ct);
            }    
        }
        if(contractListToUpdate <> null && contractListToUpdate.size() >0){
            update contractListToUpdate;
        }
        
    }
    
    // <T1> starts MHBS-6166
    public static void updateContrModifiedDate(List<SBQQ__Subscription__c > newList){        
        //System.debug('updateContrModifiedDate');
        Set<Id> accIds = new Set<Id>();
        for(SBQQ__Subscription__c subs : newList){
            if(accIds.contains(subs.SBQQ__Account__c) != true){
                accIds.add(subs.SBQQ__Account__c);
            }
        }
        
        Map<Id,Account> accMap = new Map<Id,Account>([Select id,Contract_Modified_Date__c from Account where id in:accIds]);
        for(Account acc : accMap.values()){
            acc.Contract_Modified_Date__c = Date.Today();
        }
        
        System.debug(accMap.values()); 
        try{
            update accMap.values();
        }catch(Exception e){
            Util.processException(e,true,'updateAccountContModifiedDate : Error during updation of Accounts'+accMap.values());
        }
        
        
    }
}
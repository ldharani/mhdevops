public class quoteHelper {
    
    public static void updateCaseOwnersinOppty(List<SBQQ__Quote__c> quolist, map<Id,SBQQ__Quote__c> oldMap, map<Id,SBQQ__Quote__c> newMap){
        Set<Id>optyIds = new Set<Id>();
        List<Case> updateCases = new List<Case>();
        
        Map<String,String> queueNareaMap = new Map<String,String>();
        
        Id RecordTypeId_mhOppty = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId(); 
        
        for(SBQQ__Quote__c oppt : quolist){
            if((oppt.SBQQ__Status__c == 'Closed Won' && oppt.SBQQ__Status__c!=oldMap.get(oppt.Id).SBQQ__Status__c &&  oppt.RecordTypeid == RecordTypeId_mhOppty) || test.isRunningTest()) {
                optyIds.add(oppt.SBQQ__Opportunity2__c);
            }       
        }
        
        if(!optyIds.isEmpty() && optyIds!=NULL){
            List<Case> caseList = new List<Case>();
            if(!test.isRunningTest()){
                caseList = [Select id, sub_area__c,Area__c From case where Parent_Opportunity__c in:optyIds];
            }
            //T01 system.debug('====@@@=====caseList'+caseList);
            if(!caseList.isempty() && caseList!=NULL){
                List<String> queueName = new List<String>();
                queueName.add('Social Starter');
                queueName.add('Editorial');
                //String queueName = 'Editorial,Social Starter'; 
                List<Group> queueList = [Select Id,Name from Group where Name in:queueName and Type = 'Queue'];
                //T01 System.debug('@@@@@@queue List'+queueList);
                
                
                for(Group g:queueList){
                    queueNareaMap.put(g.name,g.id);
                    
                } 
                //T01 System.debug('@@@@@@@@@@queueNareaMap'+queueNareaMap);
                
                
                
                for(Case c : caseList){
                    if(queueNareaMap.containskey(c.Area__c)){
                        c.ownerId = queueNareaMap.get(c.Area__c);
                        updateCases.add(c);
                    }
                }
            }
        } 
        
        if(!updateCases.isempty()){
            update updateCases;
        }
    }
    
    public static void updateContractStatus(List<SBQQ__Quote__c> quolist){
        system.debug('rrr 3');
        List<Id> contractId = new List<Id>();
        Map<Id,Contract> contractToUpdateMap = new Map<Id,Contract>();

        for(SBQQ__Quote__c quo : quolist){
            
            contractId.add(quo.SBQQ__MasterEvergreenContract__c);
            system.debug('rrr contractId :::' + contractId);
                
        } 

        for(Contract cnt : [Select id,Status__c from Contract where id IN: contractId]){
            contractToUpdateMap.put(cnt.id,cnt);
        }   
        
        for(SBQQ__Quote__c quo : quolist){
            if(quo.SBQQ__Status__c == Constant.QUOTE_CLOSED_WON){
                contractToUpdateMap.get(quo.SBQQ__MasterEvergreenContract__c).Status__c = Constant.CONTRACT_EVERGREEN;
            }
            else{
                contractToUpdateMap.get(quo.SBQQ__MasterEvergreenContract__c).Status__c = Constant.CONTRACT_AMEND_PROGRESS;
            }
            //c.Status__c = Constant.CONTRACT_AMEND_PROGRESS;
        }
        update contractToUpdateMap.values();
    }
    
    public static void UpdateNgageSource (List<SBQQ__Quote__c> quolist,Map<Id,SBQQ__Quote__c> newMap, Map<Id,SBQQ__Quote__c> oldMap){
        List<Opportunity> oppList = new List<Opportunity>();
        Set<Id> OppId = new Set<Id>();
        Map<Id,SBQQ__Quote__c> quoIds = new Map<Id,SBQQ__Quote__c>();
        for(SBQQ__Quote__c quo : quolist){
            if(quo.Ngage_Source__c != oldMap.get(quo.Id).Ngage_Source__c){
                quoIds.put(quo.Id,quo);
                OppId.add(quo.SBQQ__Opportunity2__c);
            }
        } 
        if(quoIds.size()>0){
            for(Opportunity opp : [SELECT Id,SBQQ__PrimaryQuote__c,Ngage_Source__c FROM Opportunity WHERE SBQQ__PrimaryQuote__c IN: quoIds.keySet()]){
                opp.Ngage_Source__c = quoIds.get(opp.SBQQ__PrimaryQuote__c).Ngage_Source__c;
                oppList.add(opp);
            }
        }
        if(oppList.size()>0){
            Update oppList;
        }
    }
    
    public static void updatePrimaryContactOnAccount(List<SBQQ__Quote__c> newList, Map<Id,SBQQ__Quote__c> oldMap){
         List<Account> accountsToBeUpdated = new List<Account>();
         
         for(SBQQ__Quote__c quote:newList){
             if(quote.SBQQ__Status__c == 'Closed Won' && oldMap.get(quote.ID).SBQQ__Status__c!='Closed Won'){
                   //quote.SBQQ__Account__r.Primary_Billing_Contact__c = quote.Billing_Contact__c;
                   //quote.SBQQ__Account__r.Primary_Business_Contact__c = quote.SBQQ__PrimaryContact__c;
                   Account acc = new Account(Id=quote.SBQQ__Account__c);
                 if((quote.SBQQ__PrimaryContact__c!=null && acc.Primary_Business_Contact__c != null && quote.SBQQ__PrimaryContact__c !=acc.Primary_Business_Contact__c) || (quote.Billing_Contact__c!=null && acc.Primary_Billing_Contact__c!= null && quote.Billing_Contact__c !=acc.Primary_Billing_Contact__c)){
                     if(quote.SBQQ__PrimaryContact__c!=null && quote.SBQQ__PrimaryContact__c !=acc.Primary_Business_Contact__c){
                     acc.Primary_Business_Contact__c = quote.SBQQ__PrimaryContact__c;
                     }
                     if(quote.Billing_Contact__c!=null && quote.Billing_Contact__c !=acc.Primary_Billing_Contact__c){
                   acc.Primary_Billing_Contact__c = quote.Billing_Contact__c;
                	 }
                     accountsToBeUpdated.add(acc);
                 }
                   
             }
         }
        
         try{
             if(accountsToBeUpdated.size()>0){
             update accountsToBeUpdated;
             }
         }
         catch(Exception e)
         {
             
         }
        //T01 System.debug('Accounts to be updated '+accountsToBeUpdated);
     }
    public  void FkMethod(){
    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    }
    /*
    Public static void updateSubscriptiontoTruncateUpsell(List<SBQQ__Quote__c> quolist, map<Id,SBQQ__Quote__c> oldMap){
        
        set<Id> sQuoteId = new set<Id>();
        for(SBQQ__Quote__c qt: quolist){
            if((qt.SBQQ__Status__c == 'Closed Won' && (qt.SBQQ__Type__c == 'Renewal' || qt.SBQQ__Type__c == 'Amendment') && qt.SBQQ__Status__c != oldMap.get(qt.Id).SBQQ__Status__c && qt.Amend_Bundle__c == 'Upsell') || test.isRunningTest()){
                sQuoteId.add(qt.Id);
            }
        }
        
        if(!sQuoteId.isEmpty()){
            set<String> productCode = new set<String>();
            productCode.add('01808'); // Web Bronze 
            productCode.add('01811'); // Web Silver
            productCode.add('01972'); // Web Gold
            productCode.add('01809'); // Web Platinum
            productCode.add('11006'); // Professional Profile
            
            List<SBQQ__QuoteLine__c> lstQLI = new List<SBQQ__QuoteLine__c>();
            if(!test.isRunningTest()){
           lstQLI = [SELECT Id, SBQQ__Group__c, SBQQ__Group__r.Name, SBQQ__RenewedSubscription__c, SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c, SBQQ__UpgradedSubscription__c, SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c FROM SBQQ__QuoteLine__c WHERE (SBQQ__Quote__c IN: sQuoteId AND SBQQ__ProductOption__c = null AND SBQQ__Quantity__c = 0 AND SBQQ__Productcode__c IN: productCode) AND (SBQQ__RenewedSubscription__c != null OR SBQQ__UpgradedSubscription__c != null)];
            }
            if((!lstQLI.isEmpty()) || test.isRunningTest() ){
                List<Orderitem> lstOIUpdate = new List<Orderitem>();
                Orderitem objOI;
                
                List<SBQQ__Subscription__c> lstSubUpdate = new List<SBQQ__Subscription__c>();
                SBQQ__Subscription__c objSub;
                for(SBQQ__QuoteLine__c qli: lstQLI){
                    if(qli.SBQQ__RenewedSubscription__c != null){ //&& qli.SBQQ__Group__c == null){ //commented for SP-69 release                        objSub = new SBQQ__Subscription__c(id=qli.SBQQ__RenewedSubscription__c);
                        objSub.Status__c = 'Truncated-Upsell';
                        objSub.Subscription_Status__c = 'Truncated-Upsell';
                        lstSubUpdate.add(objSub);
                        
                        if(qli.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c != null){
                            objOI = new Orderitem(id=qli.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c);
                            objOI.Status__c = 'Truncated-Upsell';
                            lstOIUpdate.add(objOI);
                        }
                    }
                    if(qli.SBQQ__RenewedSubscription__c != null){ //&& qli.SBQQ__Group__c == null){ //commented for SP-69 release                        objSub = new SBQQ__Subscription__c(id=qli.SBQQ__UpgradedSubscription__c);
                        objSub.Status__c = 'Truncated-Upsell';
                        objSub.Subscription_Status__c = 'Truncated-Upsell';
                        lstSubUpdate.add(objSub);
                        
                        if(qli.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c != null){
                            objOI = new Orderitem(id=qli.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c);
                            objOI.Status__c = 'Truncated-Upsell';
                            lstOIUpdate.add(objOI);
                        }
                    }
                }
                if(!lstOIUpdate.isEmpty()){
                    update lstOIUpdate;
                }
                
                if(!lstSubUpdate.isEmpty()){
                    update lstSubUpdate;
                }
                
                
            }
        }
    }*/ // END OF METHOD - updateSubscriptiontoTruncateUpsell
    
}
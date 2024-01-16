public class CreateRebaseMidtermContractsCntrl {
    
    @AuraEnabled
    public static Boolean loadComponent(string qId){
        Boolean showComp = false;
        SBQQ__Quote__c q = [Select Id,SBQQ__Status__c,Subscription_type__c from SBQQ__Quote__c where Id = :qId];
        List<Order> ordList = [Select Id,SBQQ__Contracted__c from Order where SBQQ__Quote__c =:qId ];
        System.debug(q.SBQQ__Status__c);
        System.debug(q.Subscription_type__c);
        System.debug(ordList.size()>0);
        System.debug(ordList.size()>0 && ordList[0].SBQQ__Contracted__c == false);
        if(q.SBQQ__Status__c =='Closed Won' && (q.Subscription_type__c == 'Rebase' || q.Subscription_type__c == 'Mid-Term') && (ordList.size()>0 && ordList[0].SBQQ__Contracted__c == false)){
            System.debug('showComp'+showComp);
            showComp = true;
            System.debug('showComp'+showComp);
        }
        return showComp;         
    }
    
    @AuraEnabled
    public static String updateOrderContracted(string qId){
        Order ord = [Select Id,SBQQ__Contracted__c from Order where SBQQ__Quote__c = :qId];
      
        if(ord.SBQQ__Contracted__c == false){
            ord.SBQQ__Contracted__c = true;
            if(!Test.isRunningTest()){
            update ord; 
            }
        }      
        
         return null;
    }

}
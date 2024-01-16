public class subscriptionStatusHandling {
    
    public static void SubStatusHandlingOnAccount(List<Subscription__c> subList, Map<Id,Subscription__c>OldMap){
        Set<Id> accIds = new Set<Id>();
        //Map<Id, List<Subscription__c>> accVsSubId = new Map<Id, List<Subscription__c>>();
        //List<Subscription__c> activeSubs = new List<Subscription__c>();
        List<Account> queryAccounts = new List<Account>();
        List<Account> acctsToUpdate = new List<Account>();
        List<Subscription__c> singleSubs = new List<Subscription__c>();
        
        for(Subscription__c Subs: subList){
            system.debug('===Subs.Cancelled__c===='+Subs.Cancelled__c);
            if(Subs.Cancelled__c == false || (OldMap!=Null && Subs.Cancelled__c != OldMap.get(Subs.Id).Cancelled__c)){
            //send sub to query accounts
            accIds.add(Subs.Account__c);
            }
        }
        system.debug('===accIds==='+accIds);
        if(!accIds.isEmpty()){
        singleSubs = [select Id, Cancelled__c, Name, Account__c, Account__r.SubscriptionStatus__c from Subscription__c where Account__c IN:accIds];
        queryAccounts = [select Id, SubscriptionStatus__c, Name from Account where Id IN:accIds];
        system.debug('===singleSubs==='+singleSubs);
        system.debug('===queryAccounts==='+queryAccounts);
        for(Account acc:queryAccounts){
            for(Subscription__c subStatus: singleSubs){   
                if(subStatus.Cancelled__c == false){
                    acc.SubscriptionStatus__c = 'Active';
                }
                else{
                    acc.SubscriptionStatus__c = 'Cancelled';
                }
            }
            acctsToUpdate.add(acc);
        }
        }
        system.debug('===acctsToUpdate==='+acctsToUpdate);
        if(!acctsToUpdate.isEmpty()){
            update acctsToUpdate;
        }
    }
}
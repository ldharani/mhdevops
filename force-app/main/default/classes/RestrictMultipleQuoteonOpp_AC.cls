public class RestrictMultipleQuoteonOpp_AC {
    
    public Static void restrictMethod(List<SBQQ__Quote__c> quoteList){
        Set<Id> oppIds = new Set<Id>();
        for(SBQQ__Quote__c qRec : quoteList){
            oppIds.add(qRec.SBQQ__Opportunity2__c);
        }

        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        for(Opportunity opp : [SELECT Id,(SELECT Id,Name FROM SBQQ__Quotes2__r) FROM Opportunity WHERE Id IN: oppIds]){
            oppMap.put(opp.Id,opp);
        }

        for(SBQQ__Quote__c qRecA : quoteList){
            if(oppMap.containsKey(qRecA.SBQQ__Opportunity2__c)){
                if(oppMap.get(qRecA.SBQQ__Opportunity2__c).SBQQ__Quotes2__r != null && oppMap.get(qRecA.SBQQ__Opportunity2__c).SBQQ__Quotes2__r.size()>0){// If greater than 0, throw error
                    qRecA.addError('You cannot create more than one Quote');
                }
            }
        }
    }
}
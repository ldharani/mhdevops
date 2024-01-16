/*
Apex Class   : Trigger_QuoteLineConsumptionRate_Helper
Created By   : Serge Kandukuri
Description  : This is Helper class for QuoteLineConsumptionRateTrigger
*/
public class Trigger_QuoteLineConsumptionRate_Helper{
    
    public static void updatePriceOnQLConsumptionSchedule(List<SBQQ__QuoteLineConsumptionRate__c> newList){
        set<Id> sConsumptionScheduleRate = new set<Id>();
        for(SBQQ__QuoteLineConsumptionRate__c csRate: newList){
            sConsumptionScheduleRate.add(csRate.SBQQ__QuoteLineConsumptionSchedule__c);
        }
        if(!sConsumptionScheduleRate.isEmpty()){
            List<SBQQ__QuoteLineConsumptionSchedule__c> lstQLICS = [SELECT Id, SBQQ__QuoteLine__c FROM SBQQ__QuoteLineConsumptionSchedule__c WHERE Id IN: sConsumptionScheduleRate];
            Map<Id, Id> mapCSIdwithQLIId = new Map<Id, Id>();
            for(SBQQ__QuoteLineConsumptionSchedule__c qlics: lstQLICS){
                mapCSIdwithQLIId.put(qlics.id, qlics.SBQQ__QuoteLine__c);
            }
            if(!mapCSIdwithQLIId.isEmpty()){
                List<SBQQ__QuoteLine__c> lstQLI = [SELECT Id, SBQQ__SubscriptionType__c, Usage_List_Price__c FROM SBQQ__QuoteLine__c WHERE Id IN: mapCSIdwithQLIId.values()];
                Map<Id, decimal> mapQLIWithUsagePrice = new Map<Id, decimal>();
                for(SBQQ__QuoteLine__c qli: lstQLI){
                    if(qli.SBQQ__SubscriptionType__c == 'Evergreen' && qli.Usage_List_Price__c != null){
                        mapQLIWithUsagePrice.put(qli.Id, qli.Usage_List_Price__c);
                    }
                }
                List<SBQQ__QuoteLineConsumptionRate__c> lstQLCSRateUpdate = new List<SBQQ__QuoteLineConsumptionRate__c>();
                SBQQ__QuoteLineConsumptionRate__c objCSRateUpdate;
                for(SBQQ__QuoteLineConsumptionRate__c csRate: newList){
                    if(mapQLIWithUsagePrice != null && mapQLIWithUsagePrice.containsKey(mapCSIdwithQLIId.get(csRate.SBQQ__QuoteLineConsumptionSchedule__c))){
                        objCSRateUpdate = new SBQQ__QuoteLineConsumptionRate__c(id=csRate.id);
                        objCSRateUpdate.SBQQ__Price__c = mapQLIWithUsagePrice.get(mapCSIdwithQLIId.get(csRate.SBQQ__QuoteLineConsumptionSchedule__c));
                        lstQLCSRateUpdate.add(objCSRateUpdate);
                        
                    }
                }
                if(!lstQLCSRateUpdate.isEmpty()){
                    update lstQLCSRateUpdate;
                }
            }
        }
    }
}
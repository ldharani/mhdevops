/*
Apex Class   : Trigger_QuoteLineConsumptionRate_Handler
Created By   : Serge Kandukuri
Description  : This is Handler class for QuoteLineConsumptionRateTrigger
*/
public class Trigger_QuoteLineConsumptionRate_Handler{
    public static void afterInsertHandler(List<SBQQ__QuoteLineConsumptionRate__c> newList){
        Trigger_QuoteLineConsumptionRate_Helper.updatePriceOnQLConsumptionSchedule(newList);
    }
    
}
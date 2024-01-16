/*
Apex Class   : Trigger_QuoteLine_Handler
Description  : This is Handler class for QuoteLineTrigger
Created By   : Serge Kandukuri

Change History 
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6018    SS            31/03/2022   John Mattheson  T01     Move process builders to apex
MHMAC-394    SaiV          09/07/2023       SaiC        T02     Update Professional Contact with Active MAC Product association
MHMAC-480    RR            10/25/2023   John Mattheson  T04    Remove validations for professionals
************************************************************************************************************************/
public class Trigger_QuoteLine_Handler{
    public static void afterInsertHandler(List<SBQQ__QuoteLine__c> newList){
        //Trigger_QuoteLine_Helper.splitQLI(newList);
        
          if(MDL_RecursionHandler.batchAutoEvgPriceincreaseCheck == true ){
        Trigger_QuoteLine_Helper.updateParentQuote(newList);
          }
           //T03
        Trigger_QuoteLine_Helper.updateParentQuo(newList);
       
        if(!system.isFuture()){
            Trigger_QuoteLine_Helper.populateBillingSchedule(newList, null);//<T01>
        }
            //system.debug('===newListQLs==='+newList);
            //M_A_UpgradeandDowngradeUpdates.quoteLineUpgradeandDowngradeUpdates(newList);//T02
            /*
            Set<Id> quoteId = new Set<Id>();
            for(SBQQ__QuoteLine__c quoteLine: newList){
                if(quoteLine.SBQQ__ProductCode__c == '11017' && quoteLine.SBQQ__Quantity__c > 0){
                    quoteId.add(quoteLine.SBQQ__Quote__c);
                }
            }
            if(quoteId != Null){
                M_A_UpgradeandDowngradeUpdates.updateFirmQL(quoteId);    
            }*/
        //}
        
    }
    
    public static void afterUpdateHandler(List<SBQQ__QuoteLine__c> newList, Map<Id, SBQQ__QuoteLine__c> oldMap){
        //Trigger_QuoteLine_Helper.setQuantityto1(newList);
        //Trigger_QuoteLine_Helper.recalculationNeeded(newList, oldMap);
        Trigger_QuoteLine_Helper.updatePriceOnQLConsumptionSchedule(newList, oldMap);
        Trigger_QuoteLine_Helper.updateOrderItemandSubs(newList, oldMap);
        //Trigger_QuoteLine_Helper.UpdateProductCheckOnContact(newList, oldMap); //MHMAC-407 MHMAC-480
        Trigger_QuoteLine_Helper.UpdateQuoteLineGrp(newList, oldMap);

        if(MDL_RecursionHandler.qlUpgrdDwngrdUpdates == true){
            M_A_UpgradeandDowngradeUpdates.quoteLineUpgradeandDowngradeUpdates(newList, oldMap);
            //M_A_UpgradeandDowngradeUpdates.quoteLineUpgradeandDowngradeUpdates(newList);
        }
        Trigger_QuoteLine_Helper.UpdateCancelNowDate(newList, oldMap);
    }
    
    //added by saiv
    public static void beforeDeleteHandler(List<SBQQ__QuoteLine__c> oldList){
        Trigger_QuoteLine_Helper.sendReleaseInventory(oldList);
    }
    //T03
    public static void afterDeleteHandler(List<SBQQ__QuoteLine__c> oldList){
        
        Trigger_QuoteLine_Helper.updateParentQuo(oldList);
    }
}
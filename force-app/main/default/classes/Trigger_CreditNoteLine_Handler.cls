/**@@
#TRIGGER NAME          :    CreditNoteLineTrigger
#HANDLER CLASS NAME    :    Trigger_CreditNoteLine_Handler
#HELPER CLASS NAME     :    Trigger_CreditNoteLine_Helper
#TEST CLASS            :    CreditNoteLineTriggerTest
#CREATED BY            :    Serge Kandukuri
#DESCRIPTION           :    This Handler class will handles all the trigger events and make call to the Helper class to handling the appropriate logic.   
@@**/
public class Trigger_CreditNoteLine_Handler{
    /**@@
        #DESCRIPTION   : Before Insert Hanlder
        #Paramaters    : trigger.new
    @@**/
    public static void beforeInsertHandler(List<blng__CreditNoteLine__c> newList){        
        Trigger_CreditNoteLine_Helper.validateUsageRecord(newList);
    }// END OF BEFORE INSERT HANDLER
    
    /**@@
        #DESCRIPTION   : Before Update Hanlder
        #Paramaters    : trigger.new
    @@**/
    public static void beforeUpdateHandler(List<blng__CreditNoteLine__c> newList, Map<Id, blng__CreditNoteLine__c> oldMap){        
        Trigger_CreditNoteLine_Helper.validateUsageRecord(newList);
    }// END OF BEFORE INSERT HANDLER
}
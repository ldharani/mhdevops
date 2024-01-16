/**@@
#TRIGGER NAME          :    UsageTrigger
#HANDLER CLASS NAME    :    Trigger_Usage_Handler
#HELPER CLASS NAME     :    Trigger_Usage_Helper
#TEST CLASS            :    UsageTriggerTest
#CREATED BY            :    Serge Kandukuri
#DESCRIPTION           :    This Handler class will handles all the trigger events and make call to the Helper class to handling the appropriate logic.   
@@**/
public class Trigger_Usage_Handler{
    
    /**@@
        #DESCRIPTION   : Before Insert Hanlder
        #Paramaters    : trigger.new
    @@**/
    public static void beforeInsertHandler(List<blng__Usage__c> newList){        
        Trigger_Usage_Helper.usageLeadIddupCheck(newList);
    }// END OF BEFORE INSERT HANDLER
    
  
}// END OF CLASS
/**@@
#TRIGGER NAME          :    ContractTrigger
#HANDLER CLASS NAME    :    Trigger_Contract_Handler
#HELPER CLASS NAME     :    Trigger_Contract_Helper
#TEST CLASS            :    ContractTriggerTest
#CREATED BY            :    Serge Kandukuri
#DESCRIPTION           :    This Handler class will handles all the trigger events and make call to the Helper class to handling the appropriate logic.   
@@**/
public class Trigger_Contract_Handler{
    
    /**@@
        #DESCRIPTION   : Before Insert Hanlder
        #Paramaters    : trigger.new
    @@**/
    public static void beforeInsertHandler(List<Contract> newList){        
        
        Trigger_Contract_Helper.populateContractFields(newList);
    }// END OF BEFORE INSERT HANDLER
    
  
}// END OF CLASS
/**@@
#TRIGGER NAME          :    InvoiceLineTrigger
#HANDLER CLASS NAME    :    Trigger_InvoiceLine_Handler
#HELPER CLASS NAME     :    Trigger_InvoiceLine_Helper
#TEST CLASS            :    InvoiceLineTriggerTest
#CREATED BY            :    Serge Kandukuri
#DESCRIPTION           :    This Handler class will handles all the trigger events and make call to the Helper class to handling the appropriate logic.   
@@**/
public class Trigger_InvoiceLine_Handler{
    
    /**@@
        #DESCRIPTION   : After Insert Hanlder
        #Paramaters    : trigger.new
    @@**/
    public static void afterInsertHandler(List<blng__InvoiceLine__c> newList){        
        Trigger_InvoiceLine_Helper.createBiWeeklyInvoiceLines(newList);
    }// END OF AFTER UPDATE HANDLER
    
  
}// END OF CLASS
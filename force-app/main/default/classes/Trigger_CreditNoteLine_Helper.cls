/**@@
#TRIGGER NAME        :    CreditNoteLineTrigger
#HANDLER CLASS NAME  :    Trigger_CreditNoteLine_Handler
#HELPER CLASS NAME   :    Trigger_CreditNoteLine_Helper
#TEST CLASS          :    CreditNoteLineTriggerTest
#CREATED BY          :    Serge Kandukuri
#DESCRIPTION         :    This Helper class will handles all the trigger events and handling the appropriate logic.   
@@**/
public class Trigger_CreditNoteLine_Helper{

    /**@@
    #DESCRIPTION   : create Contract and Set End Date
    #Paramaters    : trigger.new
    @@**/
    public static void validateUsageRecord(List<blng__CreditNoteLine__c> newList){
        set<Id> sUsageId = new set<Id>();
        Set<ID> creditNoteLineIDs = new Set<Id>();
        for(blng__CreditNoteLine__c cnl: newList){
            if(cnl.Usage__c != null){
                sUsageId.add(cnl.Usage__c);
            }
            creditNoteLineIDs.add(cnl.id);
        }
        		
        
        if(!sUsageId.isEmpty()){
            List<blng__Usage__c> lstUsageUpdate = new List<blng__Usage__c>();
            Date dtToday = system.today();
            List<blng__CreditNoteLine__c> lstExistingCreditnoteLine = [SELECT Id, Usage__c,blng__Status__c FROM blng__CreditNoteLine__c WHERE Usage__c IN: sUsageId and blng__Status__c='Posted'];
            set<Id> sUsageExistinexistingCN = new set<Id>();
            for(blng__CreditNoteLine__c cnl: lstExistingCreditnoteLine){
                sUsageExistinexistingCN.add(cnl.Usage__c);
            }
            
            for(blng__CreditNoteLine__c cnl: newList){
                if(cnl.Usage__c != null){
                    if(sUsageExistinexistingCN != null && sUsageExistinexistingCN.contains(cnl.Usage__c)){
                        cnl.addError('Usage already has been credited for this Credit Note Line.');
                    }
                    else{
                        blng__Usage__c objUsage = new blng__Usage__c(id=cnl.Usage__c);
                        objUsage.Credit_Status__c = cnl.blng__Status__c;
                        objUsage.Date_of_credit__c = cnl.blng__CreditNoteLineDate__c;
                        objUsage.Credit_Amount__c = cnl.blng__TotalAmount__c;
                        lstUsageUpdate.add(objUsage);
                    }
                }
            }
            if(!lstUsageUpdate.isEmpty()){
                update lstUsageUpdate;
            }
        }
    }
}
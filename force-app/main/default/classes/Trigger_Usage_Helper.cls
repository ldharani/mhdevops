/**@@
#TRIGGER NAME        :    UsageTrigger
#HANDLER CLASS NAME  :    Trigger_Usage_Handler
#HELPER CLASS NAME   :    Trigger_Usage_Helper
#TEST CLASS          :    UsageTriggerTest
#CREATED BY          :    Serge Kandukuri
#DESCRIPTION         :    This Helper class will handles all the trigger events and handling the appropriate logic.   
@@**/
public class Trigger_Usage_Helper{

    /**@@
        #DESCRIPTION   : this method is used to validate duplicate Lead Id
        #Paramaters    : trigger.new
    @@**/
    public static void usageLeadIddupCheck(List<blng__Usage__c> newList){ 
        Set<String> sLeadId = new Set<String>();
        for(blng__Usage__c usa : newList){
            if(usa.Lead_Id__c != null){
                sLeadId.add(usa.Lead_Id__c);
            }
        }
        
        if(sLeadId.size() > 0 ){
            Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
            
            List<blng__Usage__c> lstUsage = [select Lead_Id__c from blng__Usage__c where Lead_Id__c IN: sLeadId AND blng__OrderProduct__r.Order.RecordtypeId =: strMAIntakeRecTypeId];
            Map<String, blng__Usage__c> mapLeadIdWithUsage = new Map<String, blng__Usage__c>();
            for(blng__Usage__c usg: lstUsage){
                mapLeadIdWithUsage.put(usg.Lead_Id__c, usg);
            }
            
            for(blng__Usage__c usg: newList){
                if(mapLeadIdWithUsage.containsKey(usg.Lead_ID__c)){
                    usg.Lead_Id__c.addError('Lead Id already Exist ');
                }
            }
            
        }
    }
}
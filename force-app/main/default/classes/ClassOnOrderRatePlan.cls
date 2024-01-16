public class ClassOnOrderRatePlan{
    @InvocableMethod
    public static void ratePlanUpdate(List<Id> jobRatePlanLst){
        Set<Id> prodRPCId = new Set<Id>();
        Set<Id> jobRPId = new Set<Id>();
        List<invoiceit_s__Job_Rate_Plan__c> jobRPToUpdate = new List<invoiceit_s__Job_Rate_Plan__c>();
        Map<String,Id> prodRPMap = new Map<String,Id>();
        system.debug('==jobRatePlanLst=='+jobRatePlanLst);
        for(invoiceit_s__Job_Rate_Plan__c jobRP: [select id,name, invoiceit_s__Product_Rate_Plan__c,
                                                    (select id,name,invoiceit_s__Product_Rate_Plan_Charge__c from invoiceit_s__Job_Rate_Plan_Charge__r) 
                                                    from invoiceit_s__Job_Rate_Plan__c where ID IN:jobRatePlanLst]){
            system.debug('==jobRP=='+jobRP);                                        
            for(invoiceit_s__Job_Rate_Plan_Charge__c jobRPC: jobRP.invoiceit_s__Job_Rate_Plan_Charge__r){
            system.debug('==jobRPC=='+jobRPC);  
                if(jobRP.Name != jobRPC.Name && jobRP.Name.contains('Professional Profile')){ //&& !jobRPC.Name.contains('PKG')){
                    system.debug('==in if==');
                    prodRPCId.add(jobRPC.invoiceit_s__Product_Rate_Plan_Charge__c);
                    jobRPId.add(jobRP.Id);
                }
            }
        }
        if(!prodRPCId.isEmpty()){
            for(invoiceit_s__Product_Rate_Plan_Charge__c prodRPC:[select id,name, invoiceit_s__Product_Rate_Plan__c 
                                                                    From invoiceit_s__Product_Rate_Plan_Charge__c where Id IN:prodRPCId]){
                prodRPMap.put(prodRPC.Name, prodRPC.invoiceit_s__Product_Rate_Plan__c);                                                        
            }
        }
        system.debug('==prodRPMap=='+prodRPMap);
        if(!prodRPMap.isEmpty()){
            for(invoiceit_s__Job_Rate_Plan__c jobRaPl: [select id,name, invoiceit_s__Product_Rate_Plan__c,
                                                    (select id,name,invoiceit_s__Product_Rate_Plan_Charge__c from invoiceit_s__Job_Rate_Plan_Charge__r) 
                                                    from invoiceit_s__Job_Rate_Plan__c where Id IN:jobRPId]){
                for(invoiceit_s__Job_Rate_Plan_Charge__c jobRaPlC: jobRaPl.invoiceit_s__Job_Rate_Plan_Charge__r){
                    jobRaPl.invoiceit_s__Product_Rate_Plan__c = prodRPMap.get(jobRaPlC.Name);
                    jobRaPl.Name = jobRaPlC.Name;
                    jobRPToUpdate.add(jobRaPl);
                }
            }
        }
        system.debug('==jobRPToUpdate=='+jobRPToUpdate);
        if(!jobRPToUpdate.isEmpty()){
            update jobRPToUpdate;
        }
    }
}
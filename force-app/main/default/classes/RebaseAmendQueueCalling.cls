public class RebaseAmendQueueCalling{

   @AuraEnabled
   public static List<Contract> validationQ(String contractId){
       List<Contract> ConC = [SELECT Id,AccountId,Account.Avalara_Address_Validation_Error__c FROM Contract WHERE Id =: contractId];
       return ConC;
   }
    
    @AuraEnabled
    public static void RebaseAmendQueue(String contractId){
        
        system.enqueueJob(new AmendQueueable(contractId));
    }
   
   @AuraEnabled
   public static void EvergreenAmendQueue(String contractId){
    system.debug('Contract id '+contractId);
    system.enqueueJob(new AmendQueueable(contractId));
   }


   @AuraEnabled
    public static Contract saveContract(Contract con){
        if(con!=null){
            update con;
        }
        return con;
    }
}
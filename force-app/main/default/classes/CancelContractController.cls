public class CancelContractController {
   @AuraEnabled
   public static void CancelAmendQueue(String contractId){
    //Integer delayInMinutes = 1;
    //System.enqueueJob(new AmendQueueable(contractId), delayInMinutes);
    system.enqueueJob(new AmendQueueable(contractId));
   }
   @AuraEnabled
   public static Contract getContract(String conid){
    List<contract> conLst = [select id, SBQQ__RenewalForecast__c,SBQQ__RenewalQuoted__c,ContractNumber, IsCancelQuoteCreated__c,Status__c, 
                             Created_from_Contract__r.Status__c, EndDate, ContractStatusWhileCancel__c from contract 
                             where id=:conid];
       if(conLst!= Null && !conLst.isEmpty()){
           return conLst[0];
       }
       return null;
   } 
    @AuraEnabled
    public static Contract saveContract(Contract con){
        if(con!=null){
            update con;
        }
        return con;
    }
}
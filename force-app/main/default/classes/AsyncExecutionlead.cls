public class AsyncExecutionlead implements Queueable , Database.AllowsCallouts {
   
   public List<Account> accountsToIntegrate;
   public List<Contact> contactsToIntegrate;
   public Map<Id,Id> accountIdVsContactIdMap;
   public static boolean isqueuable = false;

  public AsyncExecutionlead(List<Account> accountsq,List<Contact> contactsToIntegrateq,Map<Id,Id> accountIdVsContactIdMapq){
      this.accountsToIntegrate= accountsq;
      this.contactsToIntegrate = contactsToIntegrateq;
      this.accountIdVsContactIdMap = accountIdVsContactIdMapq;

  }
    public void execute(QueueableContext context) {
        IntegrationEngine.IntegrateAccounts_BananaStandConvert(accountsToIntegrate,contactsToIntegrate,accountIdVsContactIdMap);
        isqueuable = true;        
    }
}
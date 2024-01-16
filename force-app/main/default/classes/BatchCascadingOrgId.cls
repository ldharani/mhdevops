//Author       : Betsy
//Description  : Responsible for updating Org Id in Parent IB Account 
//				 and Firm Org Id in the related contacts of the parent account
//				 when Org Id is updated in MH Avvo Attorney child account
public class BatchCascadingOrgId implements Database.Batchable<sObject>{
	
    public String query;
    public List<Contact> conIds = new List<Contact>();
    public String Org_Id;
    
       public BatchCascadingOrgId(List<Contact> contactIds, String OrgId){
         	this.conIds = contactIds;
           	this.Org_Id = OrgId;
       }
    
    public class InputVariables {
        @InvocableVariable
        public List<Contact> contacts;
        @InvocableVariable
        public String OrgId;
    }
    
    @invocablemethod(label='Update Contact Firm Org Id' Description='MHBS-8415' category='Contact')
    public static void updateContactFirmOrgId(List<InputVariables> InputVariables)
    {
        List<Contact> contactIds = inputVariables.get(0).contacts;
        String OrgIdToUpdate = inputVariables.get(0).OrgId;
		for(Contact con: [Select Id, Firm_Org_ID__c From Contact Where Id IN: contactIds]){
            con.Firm_Org_ID__c = OrgIdToUpdate;
        }   
       Id jobId = Database.executeBatch(new BatchCascadingOrgId(contactIds,OrgIdToUpdate), 1); 
    }
       
   
  public Database.QueryLocator start(Database.BatchableContext BC) {  
      query = 'Select Id,Firm_Org_ID__c FROM Contact';
      query+= ' Where Id IN :conIds';
      if(Test.isRunningTest()){
          query+= ' Limit 5';
      }
        System.debug(query);
        return Database.getQueryLocator(query);
    }
     
   public void execute(Database.BatchableContext BC, List<Contact> contactList){
       
       for(Contact con : contactList)
        {        
            // Update Firm Org Id with Org Id
            con.Firm_Org_ID__c = Org_Id;
        }
      
           try{
           if(contactList.size() > 0){
               update contactList;
           }
       }
       catch(exception ex){
           system.debug('@@@@ Exception while updating Org Id'+ ex);
       }
   
       
       
   }

   public void finish(Database.BatchableContext BC){
   }
}
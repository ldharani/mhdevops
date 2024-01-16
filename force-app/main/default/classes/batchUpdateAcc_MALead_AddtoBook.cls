/**************************************************************
 * Description : To Update Respective Avvo Firm and Attorney Accounts when Add to book is true in M-A Lead
 * Class Name  : batchUpdateAcc_MALead_AddtoBook
 * Test Class  : batchUpdateAcc_MALead_AddtoBook_Test 
 * 
 * Change History
************************************************************************************************************************
Jira       ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************/
public class batchUpdateAcc_MALead_AddtoBook implements Database.Batchable<sObject>{
    public Set<Id> ibacc = new Set<Id>();
    public Boolean isAddedToBook ;
    public batchUpdateAcc_MALead_AddtoBook(Set<Id> ib,Boolean isAddToBook)
    {
		this.ibacc = ib;
        this.isAddedToBook = isAddToBook;
    }
    @invocablemethod(label='Update Accounts Related to Lead' Description='MHBS-10096' category='Account')
    public static void updateAccounts(List<String> leadIds)
    {
        Set<Id> conIds = new Set<Id>();
        Set<Id> ib = new Set<Id>();
        List<Lead> ldList = [SELECT Id, contact__c,Add_to_Book__c FROM Lead WHERE Id IN : leadIds];
        Boolean isAddToBook = ldList[0].Add_to_Book__c;
        for(Lead ld: ldList){
            conIds.add(ld.contact__c);
        }
        for(Contact con: [Select Id, AccountID From Contact Where Id IN: conIds]){
            if(con.AccountId != null){
            	ib.add(con.AccountID);   
            }
        }
        System.debug('@@@test'+ib+' '+isAddToBook);
        Id jobId = Database.executeBatch(new batchUpdateAcc_MALead_AddtoBook(ib,isAddToBook), 1);
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id,Name,In_AE_Book__c,Martindale_Avvo_Book_Owner__c From Account Where (ParentId in:ibacc and RecordType.DeveloperName = \'M_A_Firm_Account\') OR (Avvo_18_digit_IB_Account__c in:ibacc and RecordType.DeveloperName = \'M_A_Atty_Account\')';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC , List<Account> scope){
        System.debug('@@@test'+scope);
        try{
            List<Account> accupdate = new List<Account>();
            for(Account acc : scope){
                if(isAddedToBook == true){
                    acc.Martindale_Avvo_Book_Owner__c = userinfo.getuserid();
                    acc.In_AE_Book__c = true;
                }
                else{
                    acc.Martindale_Avvo_Book_Owner__c = null;
                    acc.In_AE_Book__c = false;
                }
                accupdate.add(acc);
            }
            if(!accupdate.isEmpty()){
                update accupdate;
            }
        }
        catch(exception e){
        	Util.processException(e,true,'Exception while Account Update');
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}
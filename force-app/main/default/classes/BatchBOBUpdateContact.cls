/*****
Class Name: BatchBOBUpdateContact 
Created by: Bharath
* @testclass - BatchBOBUpdateContact_Test

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-9258    Bharath       01/06/2023                   <T01>   Issue with Create Lead from Contact
************************************************************************************************************************/
public class BatchBOBUpdateContact implements Database.Batchable<sObject>{
    List<Contact> con = new List<Contact>();
    List<Contact> conTest = new List<Contact>(); //<T01>
    public BatchBOBUpdateContact(List<Contact> conToUpdate){
        con = conToUpdate;
		//<T01> starts
        conTest.add(conToUpdate[0]);
        System.debug('@@@@9090 Batch Update Contact ContactList :'+con.size()+' '+con);
		//<T01> ends
    }
	public List<Contact> start(Database.BatchableContext BC) {
		//<T01> starts
        if(Test.isRunningTest()){
            return conTest;
        }
        else{
            return con;
        }
		//<T01> ends
	}
	public void execute(Database.BatchableContext BC, List<Contact> conList) {
        System.debug('@@@@9090 Batch Update Contact 2 ContactList :'+conList);
        if(!conList.isEmpty()){
            try{
                update conList;
            }catch(Exception e){
                Util.processException(e,true,'Error during updation of contacts in BatchBOBUpdateContact'+conList);            
            }
        }
	}
	public void finish(Database.BatchableContext BC) {
	}
}
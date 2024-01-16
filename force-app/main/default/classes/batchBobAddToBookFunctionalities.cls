/**************************************************************
  
 * Description : MH AE adding lead/contact to book of business
 * Class Name  : batchBobAddToBookFunctionalities
 * Test Class  : batchBobAddToBookFunctionalitiesTest 
 * Created Date : 19/12/2022 by Sachin
 * 
 * Change History
************************************************************************************************************************
Jira       ModifiedBy    Date         Requested By    Tag     Description
MHBS-8287  Sachin        25/11/2022                   T01     Open Items in MH book of business Additional requirement to MHBS 7870
MHBS-9119  Bharath       09/06/2023                   T02     Book of Business Error - Lead cannot be put in book
MHBS-10096 Bharath       01/11/2023   Kavitha VS      <T03>   BOB Functionality not working for MA Leads created by MAC sales Rep
MHBS-9261  Lakshmi       08/10/2023                   T04     Book of Business info on Parent Account - Roll up from child accounts
************************************************************************************************************************/
// <T01>
public class batchBobAddToBookFunctionalities implements Database.Batchable<sObject> {
    public Set<Id> accIdsSet = new Set<Id>();
    public Boolean isAddedToBook ;
    public String strMessageFromFlow ;
    public Boolean isMALead; //<T03>
    public batchBobAddToBookFunctionalities(Set<Id> accIds, Boolean isAddToBook, String strMessage, Boolean flag) //<T03>
    {
        this.isMALead = flag; //<T03>
        this.accIdsSet = accIds;
        this.isAddedToBook = isAddToBook;
        this.strMessageFromFlow = strMessage;
    }
    @invocablemethod(label='Update Contact Related to Account' 
                     Description='MHBS-8276 Point-2 & 7' category='Contact')
    public static void updateContact(List<String> leadIds)
    {
        Boolean flag = false; //<T03>
        Set<Id>  conOldIds = new Set<Id>();
        Set<Id>  accIds = new Set<Id>();
        List<Lead> ldList = [SELECT Id, contact__c, Add_to_Book__c,Created_From_Contact__c,IsConverted, status,Record_Type_Name__c FROM Lead WHERE Id IN : leadIds]; //<T03>
        for(Lead ld: ldList){
            conOldIds.add(ld.contact__c);
        }
        //<T03> starts
        if(ldList[0].Record_Type_Name__c == 'M-A Lead'){
            flag = true;
        }
        //<T03> ends
       string strMessage ='';
        if(ldList[0].IsConverted == true){
            strMessage = 'leadConversion';
        } 
        else if((ldList[0].status == 'Unqualified' || ldList[0].status == 'Closed - Not Converted') && ldList[0].contact__c != null){
            strMessage = 'statusUpdate';
        }
       else{
            strMessage = 'AddToBook';
       }
        Boolean isAddToBook = ldList[0].Add_to_Book__c;
        for(Contact con: [Select Id, AccountID From Contact Where Id IN: conOldIds]){
            //<T02> starts
            if(con.AccountId != null){
            	accIds.add(con.AccountID);   
            }
            //<T02> ends
        } 
        Id jobId = Database.executeBatch(new batchBobAddToBookFunctionalities(accIds, isAddToBook, strMessage,flag), 1); //<T03>
    }
    
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, In_AE_Book__c,Book_Owner__c,Date_Added_to_AE_Book__c,Open_MH_Lead__c, Date_of_Last_AE_Activity__c,Account.ParentId,Account.Book_Owner__c,Martindale_Avvo_Book_Owner__c  From Contact Where AccountID IN:accIdsSet'; //<T03>
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC , List<Contact> scope){
        try{
            List<Account> lstAccount = new List<Account>();
            for(Contact con : scope){
                System.debug('Test -AAA ' + isAddedToBook);
                System.debug('Test -ABBB ' + strMessageFromFlow);
                System.debug('Test -ACCC ' + isAddedToBook);
                
                if(isAddedToBook == true && strMessageFromFlow =='AddToBook'){
                    con.In_AE_Book__c = true;
                    con.Date_Added_to_AE_Book__c = system.today();
                    //<T03> starts
                    if(isMALead){
                        con.Martindale_Avvo_Book_Owner__c = userinfo.getuserid();
                    }
                    else{
                    	con.Book_Owner__c = userinfo.getuserid();  
                    }
                    //<T03> ends
                    //<T04>
                    if(con.Account.ParentId != null){
                        Account acc = new Account (Id = con.Account.ParentId);
                        acc.In_AE_Book__c = true;
                        acc.Date_Added_to_AE_Book__c = system.today();
                        if(isMALead){
                        	acc.Martindale_Avvo_Book_Owner__c = userinfo.getuserid();
                    	}
                    	else{
                    		acc.Book_Owner__c = userinfo.getuserid();  
                    	}
                        lstAccount.add(acc);
                    }
                    if(con.AccountId != null){
                        Account acc1 = new Account (Id = con.AccountId);
                        acc1.In_AE_Book__c = true;
                        acc1.Date_Added_to_AE_Book__c = system.today();
                        if(isMALead){
                        	acc1.Martindale_Avvo_Book_Owner__c = userinfo.getuserid();
                    	}
                    	else{
                    		acc1.Book_Owner__c = userinfo.getuserid();  
                    	}
                        lstAccount.add(acc1);
                    }
                    //<T04>
                    System.debug('Test -CCC ' + con.Book_Owner__c + con.Account.Book_Owner__c);
                }
                else if(isAddedToBook == false && strMessageFromFlow =='AddToBook'){
                    System.debug('Test -XXXXXX ' + userinfo.getuserid());
                    con.In_AE_Book__c = false;
                    con.Date_Added_to_AE_Book__c = null;
                    //<T03> starts
                    if(isMALead){
                        con.Martindale_Avvo_Book_Owner__c = null;
                    }
                    else{
                    	con.Book_Owner__c = null;  
                    }
                    //<T03> ends
                    //<T04>
                    if(con.Account.ParentId != null){
                        Account acc = new Account (Id = con.Account.ParentId);
                        acc.In_AE_Book__c = false;
                        acc.Date_Added_to_AE_Book__c = null;
                        if(isMALead){
                        	acc.Martindale_Avvo_Book_Owner__c = null;
                    	}
                    	else{
                    		acc.Book_Owner__c = userinfo.getuserid();  
                    	}
                        lstAccount.add(acc);
                    }
                    if(con.AccountId != null){
                        Account acc1 = new Account (Id = con.AccountId);
                        acc1.In_AE_Book__c = false;
                        acc1.Date_Added_to_AE_Book__c = null;
                        if(isMALead){
                        	acc1.Martindale_Avvo_Book_Owner__c = null;
                    	}
                    	else{
                    		acc1.Book_Owner__c = null;  
                    	}
                        lstAccount.add(acc1);
                    }
                    //<T04>
                }
                else if(strMessageFromFlow =='leadConversion'){
                    System.debug('Test -EEE ');
                    //<T03> starts
                    if(isMALead){
                        con.Open_Martindale_Avvo_Lead__c = false;
                    }
                    else{
                    	con.Open_MH_Lead__c = false; 
                    }
                    //<T03> ends
                }
                else if(strMessageFromFlow =='statusUpdate'){
                    System.debug('Test -UUUUUUUSSS ');
                    //<T03> starts
                    if(isMALead){
                        con.Open_Martindale_Avvo_Lead__c = false;
                    }
                    else{
                    	con.Open_MH_Lead__c = false; 
                    }
                    //<T03> ends
                    con.Date_of_Last_AE_Activity__c = system.today();
                }
            }
            System.debug('ttttt ' + scope);
            if(!scope.isEmpty()){
                System.debug('YYAYAYA ' + scope);
                update scope;
            }
            //<T04>
            if(lstAccount != null && lstAccount.size() > 0){
                update lstAccount;
            } 
            //<T04>
        }
        catch(exception e){
               Util.processException(e,true,'Exception occurred while updating Avalara_Address_Validation_Error__c field.');

        }
        
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    
}
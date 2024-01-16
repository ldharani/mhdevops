public class LeadDuplicationManagement {

    Public Lead lead{get;set;}
    public Map<id, List<AccountContactRelation>> conIdVsRelatedContacts{get;set;}
    public list<contact> conlist{get;set;}
    public boolean CheckconIdVsRelatedContacts{get;set;} 
    public String leadRecordType;
    //public Id accountidToRedirect{get;set;}
    //public Id accoundIdTo;
    public string selectedContactId{get; set;}
    
    //commaseperated to key to avoid null pointer exception when key not present in above map
    public static string commaSeperatedInvKeys {get;set;}
    
   
    public LeadDuplicationManagement(ApexPages.StandardController controller) {
        
         system.debug('@@@@ in controller');
        conIdVsRelatedContacts = new Map<id, List<AccountContactRelation>>();
        
        lead                    = (Lead)controller.getRecord();
        
        lead                    = [select id,Email,RecordType.DeveloperName
                                          from lead 
                                          where id=: lead.id];
        leadRecordType          = lead.RecordType.DeveloperName;
        conlist                 = [select id,Name,
                                          Email from contact
                                          where Email =: lead.Email];
        conIdVsRelatedContacts = LeadDuplicationClass.getDuplicateContacts(lead);
        
        //creating comma seperated key 
        //null pointer exception in vf page
        commaSeperatedInvKeys = '';
        if(conIdVsRelatedContacts != null && conIdVsRelatedContacts.size() > 0 ){
            for(Id conid : conIdVsRelatedContacts.keySet()){
                commaSeperatedInvKeys +=  String.valueof(conid) + ',';
            }
            CheckconIdVsRelatedContacts = true;
        }
   

    }
    
   /* public Id getaccountidToRedirect(){
        system.debug('@@@@accountidTo'+accoundIdTo);
        Id accid='';
        if(accoundIdTo!=null){
            accid = [select id from account where id=:accoundIdTo].id;
        }
       return accid;
        
    }*/
    
    public pageReference customleadConversion(){
        //get selected contact
   		//string conId = apexpages.currentpage().getparameters().get('selected');
   		
        String parentIdtoUpdate = '';
        List<account> acclistToUpsert     = new List<account>();
        system.debug('@@@@@ contact id'+ selectedContactId);
        
        
        system.debug('@@@@@ lead'+lead);
        
        AccountContactRelation act;
        
        system.debug('@@@leadRecordType'+lead.RecordType.DeveloperName);
        
        String accountRecordtype = '';
        if(lead.RecordType.DeveloperName== 'MDL_Leads'){
            accountRecordtype = 'MH_Accounts'; // JV
        }
        else{
            accountRecordtype = 'Nolo_Account';
        }
        system.debug('@@@accountRecordtype'+accountRecordtype);
        
        if(conIdVsRelatedContacts.containsKey(selectedContactId)){
            for(accountContactRelation actsingle : conIdVsRelatedContacts.get(selectedContactId)){
                parentIdtoUpdate = actsingle.Account.Parent_ID__c;
               /* if(actsingle.account.RecordType.DeveloperName == accountRecordtype){
                     act = new AccountContactRelation();
                      act =  actsingle;
                    break;
                }*/
            }
        }
        
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        if(act != null){
            lc.setAccountId(act.accountId);
        	lc.setContactId(act.ContactId);
        }
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        String accountidToRedirect = lcr.getAccountId();
        string contId = lcr.getContactId();
        
        system.debug('@@@@ accountidToRedirect'+accountidToRedirect);
        system.debug('@@@@ act'+act);
        
        //deleting new contact here
        //inserting accountcontactRelation
        //inserting Parent Record
        if(act == null){
            system.debug('@@@in contact delete'+ act);
            delete new contact(id = contId);
            
            accountcontactRelation actnew = new accountcontactRelation();
            actnew.AccountId   = accountidToRedirect;
            actnew.ContactId   = selectedContactId;
            insert actnew;
            
            account acctoUpdate = new account(id = accountidToRedirect, ParentId = parentIdtoUpdate);
            update acctoUpdate;
            //linking new account with parent account
            
            /* Parent record Logic
            account parentAcc = new account();
            parentAcc.Name    = 'Parent';
            acclistToUpsert.add(parentAcc);*/
            
            
            
        }
        
       PageReference pg = new PageReference('/'+accountidToRedirect);
        pg.setRedirect(true);
        system.debug('@@@@pg'+pg);
        system.debug('@@@lcr'+lcr);
         system.debug('@@@act'+act);
        return pg;
    }
    
    public PageReference getSelected()
    {
        System.debug('Entered account selection block');
        selectedContactId = ApexPages.currentPage().getParameters().get('conId');
        
        return null;
    }
    
    public pageReference redirectToStandardPage(){
        system.debug('@@@in page Action');
        
        system.debug('@@@@conIdVsRelatedContacts size'+conIdVsRelatedContacts.size());
        PageReference pg = null;
        if(conIdVsRelatedContacts.isEmpty()){
            pg = new PageReference('/lead/leadconvert.jsp?nooverride=1&retURL=%2F'+lead.id+'&id='+lead.id);
            pg.setRedirect(true);
        }
        return pg;
        
        
    }
    
  /*  @RemoteAction
    public static void customConversion(Id conId) {
        AccountContactRelation act = new AccountContactRelation();
        
        system.debug('@@@leadRecordType'+leadRecordType);
        
        String accountRecordtype = '';
        if(lead.RecordType.DeveloperName== 'MDL_Leads'){
            accountRecordtype = 'MH_Accounts'; // JV
        }
        else{
            accountRecordtype = 'Nolo_Account';
        }
        system.debug('@@@leadRecordType'+leadRecordType);
        
        if(conIdVsRelatedContacts.containsKey(conId)){
            for(accountContactRelation actsingle : conIdVsRelatedContacts.get(conId)){
                if(actsingle.account.RecordType.DeveloperName == accountRecordtype){
                    act = actsingle;
                    break;
                }
            }
        }
        
        system.debug('@@@act'+act);
        
        //custom lead conversion logic starts here
        
        //1.if lead record type matches with any of the account recordtype
        
    }*/

}
/***********************************************************************************************************************
 * @author - Akash
 * @date - 
 * @description - 
 * @testclass - 

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6861    VR            25/04/2022                   T01     Added changes for Street Line 2 Field
MHBS-8270    Bharath       30/01/2023                   T02     Contact indirect relationship not being created
************************************************************************************************************************/



public class LeadDuplicationExtension {
    
    Public Static Boolean ValidationFire = True;
    Public Lead                  lead                    {get;set;}
    public Map<id,List<account>> parectAccVsAccounts     {get;set;}
    public List<account>         parentAccounts          {get;set;}  
    public string                selectedParentAccId     {get;set;}
    //commaseperated to key to avoid null pointer exception when key not present in above map
    public string                commaSeperatedInvKeys   {get;set;}
    public boolean               CheckparectAccVsAccounts{get;set;}
    public Map<id,set<id>>       conIdVsParentIds;
    public List<contact>         conlist                 {get;set;}
    public Map<id,Account>       parentAccIdVsAccount;
    public Map<id,List<account>> conIdVsParentAccounts   {get;set;}
    public string                selectedcontId          {get;set;}
    public static boolean displayPopup{get;set;}
    public String popupURL {get;set;}
    public Map<id, set<id>>      parentaccidVsconids;
    public boolean MNGChatAvailable {get;set;}
    public Id MNGOrderIdtoNavigate;
    public string chatSelection{get;set;} 
    public Set<string>chatProductCodes;
    public Map<Id,Id>            accountIdVsContactIdMap {get;set;}
    public Map<Id,Id>            accountIdVsContactIdMapMH {get;set;}
    public Set<string> leadEmails {get;set;}

   // public boolean errors{get;set;}
    
    
    public LeadDuplicationExtension(ApexPages.StandardController controller){
        
        system.debug('@@@@ in controller');
        parectAccVsAccounts = new Map<id,List<account>>();
        parentAccounts      = new List<account>();
        leadEmails = new Set<string>();
        
        MNGChatAvailable        = false;
        chatProductCodes        = new set<string>();
        lead                    = (Lead)controller.getRecord();
        
        lead                    = [select id,Name,Description,ownerId,Email,RecordType.DeveloperName,Address,Status,Professional_ID__c,
                                          Company,FirstName,lastName,MiddleName,Salutation,Title ,MobilePhone,phone,Email_3__c,Email_2__c,Website,
                                          Avvo_com_Email__c,RecordTypeId,LeadSource,Avvo_com_Rating_Text__c,Address_3__c,Address_2__c,
                                          Ad_Region_ID__c,Ad_Region_Name__c,Avvo_Rating__c,City_2__c,City_3__c,DoNotCall,
                                          Claimed_Method__c,Claimed_Date__c,Client_Review_Rating__c,Client_Reviews_All_Time__c,
                                          Client_Reviews_Calendar_Month__c, County_1__c, County_2__c, County_3__c, Delete_Indicator__c,
                                          Guides_All_Time__c, Guides_Calendar_Month__c, Headshot_URL__c, 
                                           Last_Login_Date__c, License_State_1__c, License_State_2__c,License_State_3__c,                                       
                                          Peer_Endorsements_Received_All_Time__c, Peer_Endorsements_Received_Calendar_Mon__c, Phone_2__c, Phone_3__c,
                                          Practice_Area_1__c, Practice_Area_2__c, Practice_Area_3__c, Practice_Area_4__c, Practice_Area_5__c, Practice_Indicator__c,
                                          Practice_Status__c, Professional_Type__c, Profile_URL__c, Questions_Answered_All_Time__c,Questions_Answered_Calendar_Month__c,
                                           State_2__c, State_3__c, State_ID__c, Zip_Postal_Code_2__c, Zip_Postal_Code_3__c,Subscription_Welcome__c,
                                          Subscription_Webinar__c, Subscription_Newsletter__c, Subscription_Feedback__c, Subscription_Conference__c, Subscription_Announcement__c,
                                          Subscription_Advertising__c, Contact_Email__c, Contact_Name__c,New_Claim__c,SF_State__c, Q_A_Subscriptions__c, 
                                           Opt_Out_URL_Advertising__c,Opt_Out_URL_Announcement__c, Opt_Out_URL_Conference__c, Opt_Out_URL_Feedback__c,
                                          Opt_Out_URL_Newsletter__c, Opt_Out_URL_Webinar__c, Opt_Out_URL_Welcome__c, Lead_Conversion_Website__c,Last_Profile_Update__c,
                                          Do_Not_Call_Date_Time__c,Assistant_Title__c, Assistant_Phone__c, Assistant_Name__c,Assistant_Email__c,Goes_By_Name__c,
                                          pi__Needs_Score_Synced__c,Address_Street_Line_2__c, //T01
                                          city, street, state, country, postalcode,License_Date__c,Campaign_ID__c,Date_Added_to_Avvo_Marketing_Campaign__c,Avvo_Lead_Source__c  
                                          
                                           
                                          from lead 
                                          where id=: lead.id];
        system.debug('===lead==='+lead);
            if(lead.Email!=Null){
                leadEmails.add(lead.Email);
            }
            if(lead.Email_3__c!=Null && lead.Email != lead.Email_3__c){
                leadEmails.add(lead.Email_3__c);
            }
            system.debug('===leadEmails==='+leadEmails); 
 
        init();
        
        //creating comma seperated key 
        //null pointer exception in vf page
        commaSeperatedInvKeys = '';
        if(parectAccVsAccounts != null && parectAccVsAccounts.size() > 0 ){
            for(Id parentaccountId : parectAccVsAccounts.keySet()){
                commaSeperatedInvKeys +=  String.valueof(parentaccountId) + ',';
            }
            CheckparectAccVsAccounts = true;
        }
        
    }
    
    public void init(){
        system.debug('@@@init'+ lead);
         system.debug('===leadEmails==='+leadEmails);
        set<Id> parentAccids                  = new set<id>();
        conlist                               = new List<contact>();
        conIdVsParentIds                      = new Map<id,set<id>>();
        parentAccIdVsAccount                  = new Map<id,account>();
        conIdVsParentAccounts                 = new Map<id,List<account>>();
        parentaccidVsconids                   = new Map<id, set<id>>();
        
        List<AccountContactRelation> accConList = new List<AccountContactRelation>();
        accConList = [Select id,contactId,AccountId,isActive, 
                        Account.Name,account.RecordType.Name,
                          account.RecordType.DeveloperName,
                           Account.Parent_ID__c 
                      From AccountContactRelation 
                      //where contact.Email =:lead.Email OR contact.Email =:lead.Email_3__c Limit 100];
                       where contact.Email in: leadEmails Limit 100];                                    
        system.debug('===accConList==='+accConList);
        if(lead.Email != null){
            for(AccountContactRelation relatedContact: accConList){
                   parentAccids.add(relatedContact.Account.Parent_ID__c);
                   if(conIdVsParentIds.containsKey(relatedContact.contactId)){
                                conIdVsParentIds.get(relatedContact.contactId).add(relatedContact.Account.Parent_ID__c);                                             
                   }
                   else{
                       conIdVsParentIds.put(relatedContact.contactId, new set<Id>{relatedContact.Account.Parent_ID__c});
                   }
                   System.debug('@@@@@@@@@@@@@@@---------conIdVsParentIds--------'+conIdVsParentIds);
                  // to create related contact in parent account also
                  if(relatedContact.AccountId == relatedContact.Account.Parent_ID__c){
                      if(parentaccidVsconids.containsKey(relatedContact.AccountId)){
                          parentaccidVsconids.get(relatedContact.AccountId).add(relatedContact.id);
                      }
                      else{
                          parentaccidVsconids.put(relatedContact.AccountId, new set<id>{relatedContact.id});
                      }
                  }                                          
            }
            
        }
        
        if(!conIdVsParentIds.isEmpty()){
            conlist  = [select id,Name, Email
                               From contact
                               where id IN:conIdVsParentIds.keySet()];
        }
        
         if(!parentAccids.isEmpty()){
            for(Account acc : [select id,Name, 
                                       RecordType.DeveloperName,
                                       RecordType.Name,
                                       MH_Cust_Number__c,Business_Unit__c,
                                       Parent_ID__c,ParentId
                                       From account
                               where Parent_ID__c IN:parentAccids]){
                                   
                  if(acc.ParentId == null){
                                parentAccounts.add(acc); 
                        parentAccIdVsAccount.put(acc.id,acc);
                   }
                  else{
                      if(parectAccVsAccounts.containsKey(acc.Parent_ID__c)){
                          parectAccVsAccounts.get(acc.Parent_ID__c).add(acc);
                      }
                      else{
                          parectAccVsAccounts.put(acc.Parent_ID__c,new List<account>{acc});
                      }
                  }               
                                   
              }
            
        }
        
        List<account> tempAccList;
        for(Id singleconId : conIdVsParentIds.keySet()){
            tempAccList = new List<account>();
            for(Id eachParentId : conIdVsParentIds.get(singleconId)){
                if(parentAccIdVsAccount.containsKey(eachParentId)){
                    tempAccList.add(parentAccIdVsAccount.get(eachParentId));
                }
            }
            if(!tempAccList.isEmpty()){
                conIdVsParentAccounts.put(singleconId,tempAccList);
            }
        }
        
        for(Chat_Products__c cp: Chat_Products__c.getall().values()){
            if(cp.ConversationProduct__c == false){
                chatProductCodes.add(cp.Product_Name__c);
            }
        }
        
    }
    
    
     public List<SelectOption> getchatOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('YES','YES')); 
        options.add(new SelectOption('NO (Ngage Only opportunity)','NO (Ngage Only opportunity)')); 
         return options;
      
    }
    
     public pageReference redirectToStandardPage(){
        system.debug('@@@in page Action');
        
        system.debug('@@@@parectAccVsAccounts size'+parectAccVsAccounts.size());
         
        
        PageReference pg = null;
       /*  if(lead.MobilePhone == NULL){
             errors = true;
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Mobile Phone Number'));
         }  */
       // else 
         if(parectAccVsAccounts.isEmpty()){
             System.debug('@@@inside my if condition for standard convert-------->');
               pg = new PageReference('/apex/leadConvertPage?id='+lead.id);
               pg.setRedirect(true);
             
         }
         else if(!parectAccVsAccounts.isEmpty()){
                
                //check for JV and MH Accounts available or Not
                Map<Id,account> jvmhaccs  = new Map<Id,account>();
                for(Id parentAccId: parectAccVsAccounts.keySet()){
                    for(account acc : parectAccVsAccounts.get(parentAccId)){
                        if(acc.RecordType.DeveloperName == 'MH_Accounts' || acc.RecordType.DeveloperName =='Nolo_Account'){
                            jvmhaccs.put(acc.id,acc);
                        }
                     }
                 }
                
                //querying all active orders and its charges belongs to jvmhaccounts
               // List<invoiceit_s__Job__c> activeOrders = new List<invoiceit_s__Job__c>();
                system.debug('@@@@@@jvmhaccs'+jvmhaccs.keySet());
             system.debug('@@@@@@chatProductCodes'+chatProductCodes);
                /*if(lead.RecordType.DeveloperName == 'M_NG_Leads' &&  !jvmhaccs.isEmpty()
                             && !chatProductCodes.isEmpty()){
                 
                        
                         Map<ID,ID>featureChargeparentIds = new Map<Id,Id>();        
                        for(invoiceit_s__Job_Rate_Plan_Charge__c charges : [select id, Name,invoiceit_s__Accounting_Code__c,
                                                                                 invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c,
                                                                               (select id, Chat_Product_Order_Rate_Plan_Charge__c,Chat_Usage_Order_Rate_Plan_Charge__c
                                                                                     From Chat_Product_Order_Charges__r)
                                                                               From invoiceit_s__Job_Rate_Plan_Charge__c
                                                                            where invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.invoiceit_s__Account__c IN:jvmhaccs.keySet()
                                                                                  and (invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.invoiceit_s__Status__c = 'Active'
                                                                                        OR invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.invoiceit_s__Status__c = 'Evergreen')
                                                                                 and invoiceit_s__Accounting_Code__c IN:chatProductCodes
                                                                                order by invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.CreatedDate DESC LIMIT 1]){
                                           
                                                                                    
                                                                                    
                                          if(charges.Chat_Product_Order_Charges__r.size() == 0){
                                               MNGChatAvailable = true;
                                                MNGOrderIdtoNavigate = charges.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c;
                                               break;
                                           }
                                          else if(charges.Chat_Product_Order_Charges__r.size() > 0){
                                              featureChargeparentIds.put(charges.Chat_Product_Order_Charges__r[0].Chat_Usage_Order_Rate_Plan_Charge__c,
                                                                           charges.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c);
                                               // featureChargeparentIds.add(charges.Chat_Product_Order_Charges__r[0].Chat_Usage_Order_Rate_Plan_Charge__c);                                      
                                          }                                          
                                                                                
                            }
                        
                   // }
                   // 
                     If(MNGChatAvailable == false && !featureChargeparentIds.isEmpty()){
                              for(invoiceit_s__Job_Rate_Plan_Charge__c chatcharge : [select id, Name,invoiceit_s__Accounting_Code__c,
                                                                                 invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c,
                                                                               (select id, Name 
                                                                                     From Order_Rate_Plan_Charges2__r)
                                                                               From invoiceit_s__Job_Rate_Plan_Charge__c
                                                                            where ID IN:featureChargeparentIds.keyset()]){
                                           if(chatcharge.Order_Rate_Plan_Charges2__r.size() < 5){
                                                      MNGChatAvailable = true;
                                                      MNGOrderIdtoNavigate = featureChargeparentIds.get(chatcharge.id);
                                                      break;    
                                            }                                      
                                                                                      
                                 }         
                      }
                }*/
               
                
                
                
                
                
                
                
                
             //Lead leadtoupdate = new lead(id= lead.id, Create_Parent_Account__c= true);
             //update leadtoupdate;
          
        }
        return pg;
  
    }
    
    public PageReference getSelected()
    {
        System.debug('Entered account selection block');
        selectedParentAccId = ApexPages.currentPage().getParameters().get('parentAccId');
        selectedcontId      = ApexPages.currentPage().getParameters().get('contId');
        
        
        return null;
    }
    
    public pageReference customleadConversion(){
        
        system.debug('@@@in custom lead conversion');
        Account requiredAccount;
     
        
        if(MNGChatAvailable && chatSelection== NULL){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select Chat Option'));
                 return null;
        }
        if(MNGChatAvailable && chatSelection =='Yes' ){
             PageReference pg = new PageReference('/'+MNGOrderIdtoNavigate);
             pg.setRedirect(true);
             return pg;
        }
        
       if(selectedParentAccId == Null && chatSelection=='NO'){
            System.debug('testtsts');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'An Account for this email already exists for this Business Unit. Please check the button next to the Account you want to update with this information.'));
                 return null;
        }
        //added by saiv - 03/01/2021
        if(selectedcontId == Null){
            system.debug('==selectedcontId=='+selectedcontId);
            system.debug('==selectedParentAccId=='+selectedParentAccId);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select existing account/contact to convert this lead'));
            return null;    
        }
        
        /*************************************************************************
         * Deleting all Campaign Members which are not belongs to lead business unit 
         * before conversion
         * ********************************************************************/
           deleteCampaignMembers(lead);
        
        
        
        
        
        
         String accountRecordtype = '';
         string avvoFirmAccountId;
        if(lead.RecordType.DeveloperName== 'MDL_Leads'){
            accountRecordtype = 'MH_Accounts'; // JV
        }
        else if(lead.RecordType.DeveloperName== 'Nolo_Leads'){
            accountRecordtype = 'Nolo_Account';
        }
        else if(lead.RecordType.DeveloperName== 'M_NG_Leads'){
            accountRecordtype = 'M_NG_Account';
        }
        
        
       else if(lead.RecordType.DeveloperName== 'Captorra_Lead'){
           accountRecordtype = 'Captorra_Account';
        }
        
        else if(lead.RecordType.DeveloperName== 'M_A_Claimed_Leads'|| lead.RecordType.DeveloperName== 'Martindale_Avvo_Lead'){
              if (parectAccVsAccounts.containsKey(selectedParentAccId)) {
                for(account acc : parectAccVsAccounts.get(selectedParentAccId)){
                  //TODO:
                    if(acc.RecordType.DeveloperName == 'M_A_Firm_Account' ){
                      avvoFirmAccountId = acc.id;
                    }
                }

           }

           //avvoFirmAccountId = parectAccVsAccounts.containsKey(selectedParentAccId)? parectAccVsAccounts.get(selectedParentAccId)[0].id:NULL;
        }
        else if(lead.RecordType.DeveloperName== 'M_N_Leads'){
            accountRecordtype = 'M_N_Account';
        }
        
         // M-A intake case changes
        else if(lead.RecordType.DeveloperName== 'M_A_Intake_Leads'){
            accountRecordtype = 'M_A_Intake_Account';
        }
        
        
        System.debug('============selectedParentAccId=========='+selectedParentAccId);
        System.debug('===========parectAccVsAccounts.containsKey(selectedParentAccId)========='+parectAccVsAccounts.containsKey(selectedParentAccId));
        if(parectAccVsAccounts.containsKey(selectedParentAccId)){
            for(Account acc : parectAccVsAccounts.get(selectedParentAccId)){
                if(acc.RecordType.DeveloperName == accountRecordtype){
                    requiredAccount = new account();
                    requiredAccount = acc;
                    break;
                }
                
            }
        }
        
        ValidationFire = False;
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        
        //commented on 4-17
         if(lead.RecordType.DeveloperName == 'M_A_Claimed_Leads' || lead.RecordType.DeveloperName== 'Martindale_Avvo_Lead'){
         //|| lead.RecordType.DeveloperName == 'Captorra_Lead'){
            system.debug('In do not opty creation --->');
            lc.setDoNotCreateOpportunity(true);
        } 
        
        if(requiredAccount != null){
            lc.setAccountId(requiredAccount.Id);
                //lc.setContactId(selectedcontId);
        }
        
        AccountLogic.SYNC_ACCOUNT_CHANGES = false;
        //avvoContactLogic.SYNC_CONTACT_CHANGES = false;
        AccountContactRelationshipLogic.SYNC_ACCOUNT_CONTACT_CHANGES = False; 
        
        //Added this flag to bypass outreach task association
        TaskTriggerHandler.leadcoversionflag = True;
        ValidationFire = False;
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        
        String accountidToRedirect = lcr.getAccountId();
        string contctId            = lcr.getContactId();
        string opptyId             = lcr.getOpportunityId();
        
        system.debug('@@@@ accountidToRedirect'+accountidToRedirect);
        system.debug('@@@@ requiredAccount'+requiredAccount);
        System.debug('@@@@@@contctId----------'+contctId);
        
        
        /*opportunitycontactRole oppcontactrole = [select id from opportunitycontactRole where contactId =: contctId];
        system.debug('@@@@oppcontactrole'+oppcontactrole);
        try{
            delete oppcontactrole;
        }
        catch(exception ex){
            system.debug('@@@@@exception'+ex);
        }*/
        
        //need to update opty to delete this new conatct created
      // update new opportunity(id= opptyId, Auth_By_Contact__c= null);
        
        
        //system.debug('@@@@@@oppcontactrole'+oppcontactrole);
        //added by saiv ncons -111
        //system.debug('@@@in contact delete'+ contctId);
        /*contact c = new contact(id=contctId);
        try{
            delete c;
            system.debug('@@@@contact deleted');
        }
        catch(Exception e){
            c.addError('ERROR: You do not have permissions to delete a Contact Record. Contact the System Administrator to do that.'+e.getMessage());
        }*/

        
        
        
        //delete new contact(id=contctId);
         
        //deleting new contact here
        //inserting accountcontactRelation
        //inserting Parent Record
        if(requiredAccount == null){
        
            if(avvoFirmAccountId == NULL 
                                 && lead.RecordTypeId!= null 
                                   && (lead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Claimed Leads').getRecordTypeId() || 
                                       lead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Lead').getRecordTypeId() )){
              
              string whereClause              = 'id= :accountidToRedirect';
              String soql                     = genericUtilityClass.getCreatableFieldsSOQL('account',whereClause);
              
              system.debug('@@@@@@@soql' + soql);
              
              List<Account>ParentAccounts     = new List<Account>();
              Account tempAcc                 = (Account)Database.query(soql);
              account avvoFirmAccount;
               avvoFirmAccount         = tempAcc.clone(false, true);
               avvoFirmAccount.RecordTypeId        = Schema.SObjectType.account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId();
               avvoFirmAccount.MH_Cust_Number__c = '';
               insert avvoFirmAccount;
               avvoFirmAccountId = avvoFirmAccount.Id;

             }  

            
            accountcontactRelation actnew = new accountcontactRelation();
            actnew.AccountId   = accountidToRedirect;
            actnew.ContactId   = selectedcontId;
            System.debug('-----------accountId'+accountidToRedirect +'contact id-----------'+selectedcontId);
            
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select existing account/contact to convert this lead'));
            
            
            if(lead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Claimed Leads').getRecordTypeId()
              || lead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Lead').getRecordTypeId()){
                Account_Contact_Relation__c actnew1 = new Account_Contact_Relation__c();
                actnew1.Account__c   = accountidToRedirect;
                actnew1.Contact__c   = selectedcontId;
                actnew1.Roles__c     = 'Lead/Paying Attorney';
                System.debug('---------Custom Account contact--accountId----new'+accountidToRedirect +'contact id-----------'+selectedcontId);
                insert actnew1;
            }
            
            system.debug('selected contact'+selectedcontId);
            List<task> alltasks = new List<task>();
            //Who.Type='Lead' AND 
            for(Task t : [select id,whoId, RecordType.DeveloperName,Lead_Tasks__c from task where  //Lead_Tasks__c = TRUE AND 
                    AccountId=:accountidToRedirect]){
            //
               // if(t.WhoId  != selectedcontId){
                    t.WhoId  = selectedcontId;
                   //t.Lead_Tasks__c = FALSE;
                   /*if(opptyId!= Null && opptyId!='' ){
                       if(t.RecordType.DeveloperName != 'Customer_Service_Task'){
                           t.whatid = opptyId;                    
                       }
                       else{
                       
                       }
                }*/
                
                alltasks.add(t);
                
            }
            system.debug('@@@all tasks size'+alltasks.size());
             system.debug('@@@all tasks'+alltasks);
            if(!alltasks.isEmpty()){
                update alltasks;
            }
            
          
             updateChildAccount(lead, accountidToRedirect, selectedParentAccId,opptyId,selectedcontId,avvoFirmAccountId);
            
            
           // List<accountcontactRelation> actlisttoInsert = new List<accountcontactRelation>();
            
          /*  if(parentaccidVsconids.isEmpty() || (!parentaccidVsconids.isEmpty() && parentaccidVsconids.containsKey(selectedParentAccId)
                               && parentaccidVsconids.get(selectedParentAccId).contains(selectedcontId)) ){
                    accountcontactRelation actnewParent = new accountcontactRelation();
                   actnewParent.AccountId               = accountidToRedirect;
                   actnewParent.ContactId               = selectedcontId;
                   //actnewParent.IsDirect                = true; 
                   actlisttoInsert.add(actnewParent);                
                
            }*/
       
            //insert actlisttoInsert;
            
            //added by saiv ncons -111
            } 
            
            
            else{
                List<task> alltasks1 = new List<task>();
                //Who.Type='Lead' AND 
            for(Task t1 : [select id,whoId,RecordType.DeveloperName,Lead_Tasks__c  from task where //Lead_Tasks__c = TRUE AND 
                    AccountId=:accountidToRedirect]){
               // if(t1.WhoId  != selectedcontId){
                    t1.WhoId  = selectedcontId;
                  //  t1.Lead_Tasks__c = FALSE;
                   /*  if(opptyId!= Null && opptyId!='' ){
                      if(t1.RecordType.DeveloperName != 'Customer_Service_Task'){
                               t1.whatid = opptyId;                    
                           }
                           else{
                           
                           }
                   
                }*/
                
                alltasks1.add(t1);
                
            }
            system.debug('@@@all taksks'+alltasks1);
            system.debug('@@@all taksks size '+alltasks1.size());
            if(!alltasks1.isEmpty()){
                update alltasks1;
            }
            }  
        system.debug('@@@in contact delete'+ contctId);
        contact c = new contact(id=contctId);
        try{
            delete c;
        }
        catch(Exception e){
            c.addError('ERROR: You do not have permissions to delete a Contact Record. Contact the System Administrator to do that.'+e.getMessage());
        }
             
           
        if(selectedcontId != null && opptyId != null){
       
            OpportunityContactRole opConRole= new OpportunityContactRole(ContactId=selectedcontId,OpportunityId=opptyId,Role='Decision Maker',IsPrimary=true);
            insert opConRole;
        
        }
       
        //update new opportunity(id = opptyId, Auth_By_Contact__c= selectedcontId);
        
        //<T02> Starts
        //This code will add a account contact relationship for all the contacts available in the parent account to the account which is newly created
        if(selectedParentAccId != null){
            List<AccountContactRelation> finallist = new List<AccountContactRelation>();
            for(Contact con: [Select Id from Contact where AccountId =: selectedParentAccId]){
                AccountContactRelation acr = new AccountContactRelation();
                acr.AccountId = accountidToRedirect;
                acr.ContactId = con.Id;
                finallist.add(acr); 
            }
            System.debug('AccContRelation --- '+finallist);
            try{
                insert finallist;
            }
            catch(Exception e){
                 Util.processException(e,true,'Error while creating a new account contact relationship');
            }
        }
         //<T02> ends
        
        deletetasks(accountidToRedirect);
        
        PageReference pg = new PageReference('/'+accountidToRedirect);
        pg.setRedirect(true);
        system.debug('@@@@pg'+pg);
        system.debug('@@@lcr'+lcr);
         //system.debug('@@@act'+act);
        return pg;
        
        
    }
    
   
    public static void deletetasks(id accountidToRedirect){
        
          List<task> deletetasks = new List<task>();
            for(Task dt : [select id,Subject,whoId from task where AccountId=:accountidToRedirect 
                           AND (Subject like '%This Lead Has Been Assigned to You%' 
                           OR Subject like '%Try Again Follow Up Call - Action Required%')]){
               
                     deletetasks.add(dt);
               
                
            }
            system.debug('@@@ delete tasks '+deletetasks.size());
            if(!deletetasks.isEmpty()){
                delete deletetasks;
            }
            
    }    
     
    public static void updateChildAccount(lead leadToConvert, string childaccid, string parentAccountid, String OppId, string contId , String avvoFirmAccountId){
        
            system.debug('@@@@ oppId'+oppId);
           
            List<sobject> commonlist           = new list<sobject>();
            Id acc_nolo_RecordtypeID          = Schema.SObjectType.account.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Account).getRecordTypeId();
            Id acc_MN_RecordtypeId            = Schema.SObjectType.account.getRecordTypeInfosByName().get('M-N Account').getRecordTypeId();
            Id acc_MA_Intake_RecordtypeId            = Schema.SObjectType.account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
            Id acc_Ngage_RecordtypeId            = Schema.SObjectType.account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId();
            Id acc_Captora_RecordtypeId            = Schema.SObjectType.account.getRecordTypeInfosByName().get('Captorra Account').getRecordTypeId();
            
            Id opp_nolo_RecordtypeID          = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Opportunity).getRecordTypeId();
            Id opp_MN_RecordtypeId            = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('M-N Opportunity').getRecordTypeId();
            Id opp_MA_Intake_RecordtypeId            = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('M-A Intake Opportunity').getRecordTypeId();
            
            Id opp_Ngage_RecordtypeId            = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('M-NG Opportunity').getRecordTypeId();
            Id opp_Captorra_RecordtypeId            = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Captorra Opportunity').getRecordTypeId();
            system.debug('@@@@ OppRecord tyepe '+opp_MA_Intake_RecordtypeId);
            Id avvoAttorneyAccountRectypeId   = Schema.SObjectType.account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
            //Id opp_AvvoAttorneyRectypeId      = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Avvo Sales Opportunity').getRecordTypeId();
            
            List<Lead> leadstoUpdate = new List<Lead>();
            List<Account> accountsToIntegrate = new List<Account>();
            List<Id> contactIdsCreated = new List<Id>();
            List<Contact> contactsToIntegrate;
            
            Map<Id,Id> accountIdVsContactIdMap = new Map<Id,Id>();
            Map<Id,Id> accountIdVsContactIdMapMH = new Map<Id,Id>();
            
            String accRecordtypeid = '';
            String oppRecordtypeid = '';
            String LeadDecription ;
            String LeadName ;
            String LeadEmail ;
            String LeadProfessionalID;
            String LeadEmail3;//added by saiv
            String LeadEmail2;//added by saiv
            String LeadAvvocomEmail;//added by saiv
            
           Account ParentAcctsDetail ;
            //trigger field updates recordtype
            
            //Gets all Account details:
            If(parentAccountid!= null){
                
                ParentAcctsDetail = [Select ID,Name From Account Where Id=: parentAccountid];
            }
            
            //Check for Lead Description 
            if(leadToConvert.Description != Null){
                LeadDecription =  leadToConvert.Description ;
            }
            
            if(leadToConvert.Professional_ID__c!= Null){
                LeadProfessionalID =  leadToConvert.Professional_ID__c;
            }
            System.debug('@@@@Professional Id on the lead is------>'+LeadProfessionalID );
            //added by saiv for Email3, Email2 and LeadAvvocomEmail 06/17/19 - Updated 06/21/19
            if(leadToConvert.Email_3__c!=Null){
                LeadEmail3 = leadToConvert.Email_3__c;
            }
            system.debug('====Lead Email 3==='+LeadEmail3);
            //Email2
            if(leadToConvert.Email_2__c!=Null){
                LeadEmail2 = leadToConvert.Email_2__c;
            }
            system.debug('====Lead Email 2==='+LeadEmail2);
            
            //LeadAvvocomEmail
            if(leadToConvert.Avvo_com_Email__c!=Null && leadToConvert.Avvo_com_Email__c != leadToConvert.Email_3__c){
                LeadAvvocomEmail = leadToConvert.Avvo_com_Email__c;
            }
            
            system.debug('====Lead Avvocom Email==='+LeadAvvocomEmail);
            //end
            if(leadToConvert.FirstName!= Null && leadToConvert.lastName!= NUll ){
                if(leadToConvert.MiddleName!=Null){
                    LeadName =  leadToConvert.FirstName + ' '+ leadToConvert.MiddleName + ' '+ leadToConvert.lastName;
                }else{
                    LeadName =  leadToConvert.FirstName + ' '+ leadToConvert.lastName;            
                }
                
                    
            }
            
           /* if(leadToConvert.Contact_Email__c!= Null || leadToConvert.Contact_Email__c!=''){
                System.debug('@@@@@@@Lead Email value---->'+leadToConvert.Contact_Email__c);
                LeadEmail =  leadToConvert.Contact_Email__c;
            }*/
            
            //System.debug('@@@@@@@Lead Email value2---->'+leadToConvert.Email);
            
            //if recordtype MH Lead
            System.debug('==============================Lead convert record type id'+leadToConvert.RecordTypeId);
            if(leadToConvert.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Lead).getRecordTypeId()){
                System.debug('Inside MH'+leadToConvert.RecordTypeId);
                accRecordtypeid = acc_nolo_RecordtypeID;
                oppRecordtypeid = opp_nolo_RecordtypeID;
            }
            else if(leadToConvert.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-N Leads').getRecordTypeId()){
                System.debug('Inside MN'+leadToConvert.RecordTypeId);
                accRecordtypeid = acc_MN_RecordtypeId;
                oppRecordtypeid = opp_MN_RecordtypeId;
            }
            
             // M- A Intake 
            else if(leadToConvert.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Intake Leads').getRecordTypeId()){
                System.debug('Inside MA Intake '+leadToConvert.RecordTypeId);
                accRecordtypeid = acc_MA_Intake_RecordtypeId;
                oppRecordtypeid = opp_MA_Intake_RecordtypeId;
            }
            
            
            else if(leadToConvert.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-NG Leads').getRecordTypeId()){
                System.debug('Inside MN-G'+leadToConvert.RecordTypeId);
                accRecordtypeid = acc_Ngage_RecordtypeId;
                oppRecordtypeid = opp_Ngage_RecordtypeId;
            }
            else if(leadToConvert.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Captorra Lead').getRecordTypeId()){
                System.debug('Inside Captora'+leadToConvert.RecordTypeId);
                accRecordtypeid = acc_Captora_RecordtypeId;
                oppRecordtypeid = opp_Captorra_RecordtypeId;
            }
            
            else if(LeadToConvert.RecordTypeId != Null && LeadToConvert.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Claimed Leads').getRecordTypeId()){
                accRecordtypeid = avvoAttorneyAccountRectypeId;
                
              //  oppRecordtypeid = opp_AvvoAttorneyRectypeId;
                 
            }
            
            else if(LeadToConvert.RecordTypeId != Null && LeadToConvert.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Lead').getRecordTypeId()){
                accRecordtypeid = avvoAttorneyAccountRectypeId;
                
              //  oppRecordtypeid = opp_AvvoAttorneyRectypeId;
                 
            }
            
            //updating child account - last updated by saiv - 1/9/17
            account childaccount;
            account parentAccount;
            account avvoFirmAccount;
            opportunity opp;
            contact con;
            if(accRecordtypeid !='' && accRecordtypeid == acc_nolo_RecordtypeID){
                childaccount = new account(id= childaccid, parentId =parentAccountid,
                                           Legal_Entity__c = 'M-H Taxable', Invoice_Delivery_Type__c = 'Email', //updated saiv MHBS-4000
                                           Billing_Schedule__c = 'Advanced', RecordTypeId = accRecordtypeid,
                                           Business_Unit__c = 'Martindale-Hubbell',
                                           Address_Street_Line_2__c = leadtoConvert.Address_Street_Line_2__c, //T01
                                           Dunning_Hold__c = TRUE, Hold_dunning_letter_till__c= date.today());
                opp          = new opportunity(id = oppId, RecordtypeId = oppRecordtypeid,Auth_By_Contact__c = contId, Description = LeadDecription);
                parentAccount = new Account(id=parentAccountid,Dunning_Hold__c = TRUE, Hold_dunning_letter_till__c= date.today());
                accountIdVsContactIdMapMH.put(contId,childaccount.ID); //T01
            }
            else if(accRecordtypeid !='' && accRecordtypeid == acc_MN_RecordtypeId){
                childaccount = new account(id= childaccid, parentId =parentAccountid,
                                           RecordTypeId = accRecordtypeid);
                childaccount.Credit_Status__c = '';
                childaccount.Credit_Sub_Status__c ='';
                //childaccount.invoiceit_s__Payment_Terms__c = '';
                childaccount.Billing_Schedule__c ='';
                childaccount.Legal_Entity__c ='M-N Taxable';
                childaccount.Business_Unit__c = 'Martindale-Nolo';
                childaccount.Hold_dunning_letter_till__c = date.today();
                childaccount.Dunning_Hold__c = TRUE;
                                           
                 opp          = new opportunity(id = oppId, RecordtypeId = oppRecordtypeid, Auth_By_Contact__c = contId, invoiceit_crmx__Number_Of_Terms__c=null, Description = LeadDecription );
                 parentAccount = new Account(id=parentAccountid,Dunning_Hold__c = TRUE, Hold_dunning_letter_till__c= date.today());
                 
            }
            
            else if(accRecordtypeid !='' && accRecordtypeid == acc_MA_Intake_RecordtypeId){
                childaccount = new account(id= childaccid, parentId =parentAccountid,
                                           RecordTypeId = accRecordtypeid);
                childaccount.Credit_Status__c = '';
                childaccount.Credit_Sub_Status__c ='';
                //childaccount.invoiceit_s__Payment_Terms__c = '';
                childaccount.Billing_Schedule__c ='';
                //childaccount.Legal_Entity__c ='M-N Taxable';
                childaccount.Business_Unit__c = 'M-A Intake';
                childaccount.Hold_dunning_letter_till__c = null;
                childaccount.Dunning_Hold__c = False;
                                           
                 opp          = new opportunity(id = oppId, RecordtypeId = oppRecordtypeid, Auth_By_Contact__c = contId, invoiceit_crmx__Number_Of_Terms__c=null, Description = LeadDecription );
                 parentAccount = new Account(id=parentAccountid,Dunning_Hold__c = FALSE, Hold_dunning_letter_till__c= null);
                 
            }
            else if(accRecordtypeid !='' && accRecordtypeid == acc_Ngage_RecordtypeId){
                System.debug('Inside Ngage=================================');
                childaccount = new account(id= childaccid, parentId =parentAccountid,Hold_dunning_letter_till__c = null,Dunning_Hold__c = FALSE,RecordTypeId = accRecordtypeid, Business_Unit__c = 'Martindale-Ngage');
                parentAccount = new Account(id=parentAccountid,Dunning_Hold__c = FALSE, Hold_dunning_letter_till__c= null);
                opp          = new opportunity(id = oppId, Auth_By_Contact__c = contId, invoiceit_crmx__Billing_Contact__c = contId, RecordTypeId = oppRecordtypeid,IsLeadCoversion__c=TRUE, invoiceit_crmx__Number_Of_Terms__c=null );
            }
            
            else if(accRecordtypeid !='' && accRecordtypeid == acc_Captora_RecordtypeId){
                System.debug('Inside Captora =================================');
                childaccount = new account(id= childaccid, parentId =parentAccountid,Hold_dunning_letter_till__c = null, Billing_Schedule__c='',Invoice_Delivery_Type__c ='',Dunning_Hold__c = FALSE,RecordTypeId = accRecordtypeid, Business_Unit__c = 'Captorra');
                parentAccount = new Account(id=parentAccountid,Dunning_Hold__c = FALSE, Hold_dunning_letter_till__c= null);
                opp          = new opportunity(id = oppId, Auth_By_Contact__c = contId, invoiceit_crmx__Billing_Contact__c = contId,RecordTypeId = oppRecordtypeid,IsLeadCoversion__c=TRUE, invoiceit_crmx__Number_Of_Terms__c=12);
            }
            
            else if(accRecordtypeid !='' && accRecordtypeid == avvoAttorneyAccountRectypeId){
                System.debug('@@@@@@@@Lead Email-------->'+LeadEmail);
                childaccount = new account(id= childaccid, Name = LeadName, parentId =avvoFirmAccountId,Hold_dunning_letter_till__c = null,Dunning_Hold__c = FALSE,Contact_Name__c = leadName,RecordTypeId = accRecordtypeid, Business_Unit__c = 'Martindale-Avvo', Billing_Schedule__c='',Legal_Entity__c ='',Invoice_Delivery_Type__c ='');
                
                if(leadToConvert.Contact_Email__c!= NULL){
                    childAccount.Contact_Email__c = leadToConvert.Contact_Email__c;
                }
                
                if(leadToConvert.Claimed_Date__c!= NULL){
                    childAccount.Claimed_Date__c= leadToConvert.Claimed_Date__c;
                }
                /*
                if(leadtoConvert.qbdialer__Dials__c!=NULL){
                    childAccount.qbdialer__Dials__c= leadtoConvert.qbdialer__Dials__c;
                }
                
                if(leadtoConvert.qbdialer__ResponseTime__c!=NULL){
                    childAccount.qbdialer__ResponseTime__c= leadtoConvert.qbdialer__ResponseTime__c;
                }
                */
                if(leadtoConvert.SF_State__c!=NULL){
                    childAccount.SF_State__c= leadtoConvert.SF_State__c;
                }
                /*
                if(leadtoConvert.qbdialer__CloseScore__c!=NULL){
                    childAccount.qbdialer__CloseScore__c= leadtoConvert.qbdialer__CloseScore__c;
                }
                
                if(leadtoConvert.qbdialer__CloseDate__c!=NULL){
                    childAccount.qbdialer__CloseDate__c= leadtoConvert.qbdialer__CloseDate__c;
                }
                */
                if(leadtoConvert.Campaign_ID__c!=NULL && leadtoConvert.Date_Added_to_Avvo_Marketing_Campaign__c  !=NULL){
                    //System.debug('@@@@@Date Added to Avvo Marketing Campaign------>'+leadtoConvert.Date_Added_to_Avvo_Marketing_Campaign__c);
                    Date startDate = Date.Today();
                    integer marketingtime = integer.valueOf(system.Label.Marketing_Time_Frame);
                    integer noOfdays =  leadtoConvert.Date_Added_to_Avvo_Marketing_Campaign__c.daysBetween(startDate ); //Date.Today() - leadtoConvert.Date_Added_to_Avvo_Marketing_Campaign__c ;
                    
                    //System.debug('@@@@@No of Days------->'+noOfdays );
                    if(noOfDays < marketingtime ){
                        //System.debug('Inside the if condition-for avvo campaign Id-------->>>>>>>>');
                        childAccount.Current_Avvo_Marketing_Campaign__c= leadtoConvert.Campaign_ID__c;
                        childAccount.Date_Added_to_Avvo_Marketing_Campaign__c  = leadtoConvert.Date_Added_to_Avvo_Marketing_Campaign__c  ;

                    }
                    
                }
                
                /*if(leadtoConvert.Date_Added_to_Avvo_Marketing_Campaign__c  !=NULL){
                    childAccount.Date_Added_to_Avvo_Marketing_Campaign__c  = leadtoConvert.Date_Added_to_Avvo_Marketing_Campaign__c  ;
                }*/
                
                
                parentAccount = new Account(id=parentAccountid,Dunning_Hold__c = FALSE, Hold_dunning_letter_till__c= null, Billing_Schedule__c='',Legal_Entity__c ='',Invoice_Delivery_Type__c ='');
               // opp          = new opportunity(id = oppId, Name = LeadName, Auth_By_Contact__c = contId, invoiceit_crmx__Billing_Contact__c = contId, RecordTypeId = oppRecordtypeid,IsLeadCoversion__c=TRUE, invoiceit_crmx__Number_Of_Terms__c=null );
                avvoFirmAccount = new account(id= avvoFirmAccountId, Name = ParentAcctsDetail.Name , parentId =parentAccountid,Hold_dunning_letter_till__c = null,Dunning_Hold__c = FALSE, Business_Unit__c = 'Martindale-Avvo',  Billing_Schedule__c='',Legal_Entity__c ='',Invoice_Delivery_Type__c ='');
                
                commonlist.add(avvoFirmAccount);
                AccountLogic.SYNC_ACCOUNT_CHANGES = False;
                //avvoContactLogic.SYNC_CONTACT_CHANGES = False;
                AccountContactRelationshipLogic.SYNC_ACCOUNT_CONTACT_CHANGES = False; 

                 accountsToIntegrate.add(childaccount);
                 accountIdVsContactIdMap.put(contId, childaccount.Id);
                
            }
            else{
               
                childaccount = new account(id= childaccid, parentId =parentAccountid,Hold_dunning_letter_till__c = null,Dunning_Hold__c = FALSE);
                parentAccount = new Account(id=parentAccountid,Dunning_Hold__c = FALSE, Hold_dunning_letter_till__c= null);
                opp          = new opportunity(id = oppId, Auth_By_Contact__c = contId, Description = LeadDecription);
            }
            System.debug('@@@@@@'+contId);

            if (contId!=null) {
                contactsToIntegrate = [SELECT Id, AccountId, Phone, Phone_2__c, Phone_3__c, Professional_Id__c
                FROM Contact
                WHERE Id =:contId];
                if(contactsToIntegrate!=Null && !contactsToIntegrate.isempty()){
                    con = contactsToIntegrate[0];
                     
                    System.debug('@@@@@@@@@@@contact ------->'+con);
                    
                    if(accountIdVsContactIdMap.containskey(con.id) || test.isRunningTest()){
                        con.Related_To_Account__c = childaccount.id; 
                        if(LeadProfessionalID!=NULL || LeadProfessionalID!=''){
                            con.Professional_Id__c = LeadProfessionalID;
                                
                        }
                        
                        if(leadToConvert.Lead_Conversion_Website__c!=Null){
                            con.Website__c = leadToConvert.Lead_Conversion_Website__c;
                        }
                        
                       
                        
                        //added by saiv for Email3, Email2 and LeadAvvocomEmail
                        if(LeadEmail3!=NULL || LeadEmail3!=''){
                            con.Email_3__c = LeadEmail3;
                               
                        }
                        if(LeadEmail2!=NULL || LeadEmail2!=''){
                            con.Email_2__c = LeadEmail2;
                               
                        }
                        if(LeadAvvocomEmail!= NULL){ //&& LeadEmail3 == con.Email){
                            con.Avvo_com_Email__c = LeadAvvocomEmail;
                        }
                        //end
                        
                        if(leadtoConvert.Email!=NULL){
                            con.Email = leadtoConvert.Email;    
                        }
                        
                        if(leadtoConvert.Address_3__c!=NULL){
                            con.Address_3__c= leadtoConvert.Address_3__c;
                                
                        }
                        
                        if(leadtoConvert.Avvo_com_Rating_Text__c!=NULL){
                            con.Avvo_com_Rating_Text__c = leadtoConvert.Avvo_com_Rating_Text__c;
                                
                        }
                        if(leadtoConvert.Address_2__c!=NULL){
                            con.Address_2__c= leadtoConvert.Address_2__c;
                                
                        }
                        if(leadtoConvert.Ad_Region_ID__c!=NULL){
                            con.Ad_Region_ID__c= leadtoConvert.Ad_Region_ID__c;
                                
                        }
                        if(leadtoConvert.Ad_Region_Name__c!=NULL){
                            con.Ad_Region_Name__c= leadtoConvert.Ad_Region_Name__c;
                                
                        }
                        if(leadtoConvert.Avvo_Rating__c!=NULL){
                            con.Avvo_Rating__c= leadtoConvert.Avvo_Rating__c;
                                
                        }
                        if(leadtoConvert.City_2__c!=NULL){
                            con.City_2__c= leadtoConvert.City_2__c;
                                
                        }
                        
                        if(leadtoConvert.City_3__c!=NULL){
                            con.City_3__c= leadtoConvert.City_3__c;
                                
                        }
                        
                        if(leadtoConvert.Claimed_Date__c!=NULL){
                            con.Claimed_Date__c= leadtoConvert.Claimed_Date__c;
                                
                        }
                        
                        if(leadtoConvert.Claimed_Method__c!=NULL){
                            System.debug('@@@@@@@cehcking again the value in side if--->'+leadtoConvert.Claimed_Method__c);
                            con.Claimed_Method__c= leadtoConvert.Claimed_Method__c;
                                
                        }
                        
                        if(leadtoConvert.Client_Review_Rating__c!=NULL){
                            con.Client_Review_Rating__c= leadtoConvert.Client_Review_Rating__c;
                                
                        }
                        
                        if(leadtoConvert.Client_Reviews_All_Time__c!=NULL ){
                            con.Client_Reviews_All_Time__c= leadtoConvert.Client_Reviews_All_Time__c;
                                
                        }
                        
                        if(leadtoConvert.Client_Reviews_Calendar_Month__c!=NULL ){
                            con.Client_Reviews_Calendar_Month__c= leadtoConvert.Client_Reviews_Calendar_Month__c;
                                
                        }
                        
                        if(leadtoConvert.County_1__c!=NULL){
                            con.County_1__c= leadtoConvert.County_1__c;
                                
                        }
                        if(leadtoConvert.County_2__c!=NULL){
                            con.County_2__c= leadtoConvert.County_2__c;
                                
                        }
                        if(leadtoConvert.County_3__c!=NULL){
                            con.County_3__c= leadtoConvert.County_3__c;
                                
                        }
                        System.debug('@@@Delete Indicator_------------->'+leadtoConvert.Delete_Indicator__c);
                        
                        /*if(leadtoConvert.Delete_Indicator__c!=NULL || leadtoConvert.Delete_Indicator__c!=''){
                            con.Delete_Indicator__c= leadtoConvert.Delete_Indicator__c;
                                
                        }*/
                        /*
                        if(leadtoConvert.qbdialer__Dials__c!=NULL){
                            con.qbdialer__Dials__c= leadtoConvert.qbdialer__Dials__c;
                                
                        }
                        */
                        if(leadtoConvert.Guides_All_Time__c!=NULL ){
                            con.Guides_All_Time__c= leadtoConvert.Guides_All_Time__c;
                                
                        }
                        
                        if(leadtoConvert.Guides_Calendar_Month__c!=NULL ){
                            con.Guides_Calendar_Month__c= leadtoConvert.Guides_Calendar_Month__c;       
                        }
                        
                        if(leadtoConvert.Headshot_URL__c!=NULL ){
                            con.Headshot_URL__c= leadtoConvert.Headshot_URL__c;       
                        }
                        /*
                        if(leadtoConvert.qbdialer__isdcCallStats__c!=NULL ){
                            con.qbdialer__isdcCallStats__c = leadtoConvert.qbdialer__isdcCallStats__c;       
                        }
                        
                        if(leadtoConvert.qbdialer__LastCallTime__c!=NULL ){
                            con.qbdialer__LastCallTime__c= leadtoConvert.qbdialer__LastCallTime__c;
                                
                        }
                        */
                        if(leadtoConvert.Last_Login_Date__c!=NULL){
                            con.Last_Login_Date__c= leadtoConvert.Last_Login_Date__c;
                                
                        }
                        
                        if(leadtoConvert.License_State_1__c!=NULL){
                            con.License_State_1__c= leadtoConvert.License_State_1__c;
                                
                        }
                        
                        if(leadtoConvert.License_State_2__c!=NULL){
                            con.License_State_2__c= leadtoConvert.License_State_2__c;
                                
                        }
                        
                        if(leadtoConvert.License_State_3__c!=NULL){
                            con.License_State_3__c= leadtoConvert.License_State_3__c;
                                
                        }
                        
                        if(leadtoConvert.Peer_Endorsements_Received_All_Time__c!=NULL){
                            con.Peer_Endorsements_Received_All_Time__c= leadtoConvert.Peer_Endorsements_Received_All_Time__c;
                                
                        }
                        
                        if(leadtoConvert.Peer_Endorsements_Received_Calendar_Mon__c!=NULL ){
                            con.Peer_Endorsements_Received_Calendar_Mon__c= leadtoConvert.Peer_Endorsements_Received_Calendar_Mon__c;
                                
                        }
                        
                        if(leadtoConvert.Phone_2__c!=NULL){
                            con.Phone_2__c= leadtoConvert.Phone_2__c;
                            con.HomePhone = leadtoConvert.Phone_2__c;
                                
                        }
                        
                        if(leadtoConvert.Phone_3__c!=NULL){
                            con.Phone_3__c= leadtoConvert.Phone_3__c;
                            con.OtherPhone = leadtoConvert.Phone_3__c;
                                
                        }
                        
                        /*if(leadtoConvert.Phone_2__c!=NULL ){
                            con.HomePhone = leadtoConvert.Phone_2__c;
                                
                        }
                        
                        if(leadtoConvert.Phone_3__c!=NULL){
                            con.OtherPhone = leadtoConvert.Phone_3__c;
                                
                        }*/
                        
                        if(leadtoConvert.Practice_Area_1__c!=NULL){
                            con.Practice_Area_1__c= leadtoConvert.Practice_Area_1__c;
                                
                        }
                        
                        if(leadtoConvert.Practice_Area_2__c!=NULL){
                            con.Practice_Area_2__c= leadtoConvert.Practice_Area_2__c;
                                
                        }
                        
                        if(leadtoConvert.Practice_Area_3__c!=NULL){
                            con.Practice_Area_3__c= leadtoConvert.Practice_Area_3__c;
                                
                        }
                        
                        if(leadtoConvert.Practice_Area_4__c!=NULL){
                            con.Practice_Area_4__c= leadtoConvert.Practice_Area_4__c;
                                
                        }
                        
                        if(leadtoConvert.Practice_Area_5__c!=NULL){
                            con.Practice_Area_5__c= leadtoConvert.Practice_Area_5__c;
                                
                        }
                        
                        if(leadtoConvert.Practice_Indicator__c!=NULL){
                            con.Practice_Indicator__c= leadtoConvert.Practice_Indicator__c;
                                
                        }
                        
                        if(leadtoConvert.Practice_Status__c!=NULL){
                            con.Practice_Status__c= leadtoConvert.Practice_Status__c;
                                
                        }
                        
                        if(leadtoConvert.Professional_Type__c!=NULL){
                            con.Professional_Type__c= leadtoConvert.Professional_Type__c;
                                
                        }
                        
                       if(leadtoConvert.Profile_URL__c!=NULL){
                            con.Profile_URL__c= leadtoConvert.Profile_URL__c;
                                
                        }
                        
                        if(leadtoConvert.Questions_Answered_All_Time__c!=NULL ){
                            con.Questions_Answered_All_Time__c= leadtoConvert.Questions_Answered_All_Time__c;
                                
                        }
                        
                        if(leadtoConvert.Questions_Answered_Calendar_Month__c!=NULL ){
                            con.Questions_Answered_Calendar_Month__c= leadtoConvert.Questions_Answered_Calendar_Month__c;
                                
                        }
                        /*
                        if(leadtoConvert.qbdialer__ResponseTime__c!=NULL){
                            con.qbdialer__ResponseTime__c= leadtoConvert.qbdialer__ResponseTime__c;
                                
                        }
                        */
                        if(leadtoConvert.State_2__c!=NULL){
                            con.State_2__c= leadtoConvert.State_2__c;
                                
                        }
                        
                        if(leadtoConvert.State_3__c!=NULL){
                            con.State_3__c= leadtoConvert.State_3__c;
                                
                        }
                        
                        if(leadtoConvert.State_ID__c!=NULL ){
                            con.State_ID__c= leadtoConvert.State_ID__c;
                                
                        }
                        
                        if(leadtoConvert.Zip_Postal_Code_2__c!=NULL){
                            con.Zip_Postal_Code_2__c= leadtoConvert.Zip_Postal_Code_2__c;
                                
                        }
                        
                        if(leadtoConvert.Zip_Postal_Code_3__c!=NULL){
                            con.Zip_Postal_Code_3__c= leadtoConvert.Zip_Postal_Code_3__c;
                                
                        }
                        
                        if(leadtoConvert.Subscription_Welcome__c!=NULL ){
                            con.Subscription_Welcome__c= leadtoConvert.Subscription_Welcome__c;
                                
                        }
                        
                        if(leadtoConvert.Subscription_Webinar__c!=NULL){
                            con.Subscription_Webinar__c= leadtoConvert.Subscription_Webinar__c;
                                
                        }
                        
                        if(leadtoConvert.Subscription_Newsletter__c!=NULL){
                            con.Subscription_Newsletter__c= leadtoConvert.Subscription_Newsletter__c;
                                
                        }
                        
                        if(leadtoConvert.Subscription_Feedback__c!=NULL){
                            con.Subscription_Feedback__c= leadtoConvert.Subscription_Feedback__c;
                                
                        }
                        
                        if(leadtoConvert.Subscription_Conference__c!=NULL){
                            con.Subscription_Conference__c= leadtoConvert.Subscription_Conference__c;
                                
                        }
                        
                        if(leadtoConvert.Subscription_Announcement__c!=NULL){
                            con.Subscription_Announcement__c= leadtoConvert.Subscription_Announcement__c;
                                
                        }
                        
                        if(leadtoConvert.Subscription_Advertising__c!=NULL){
                            con.Subscription_Advertising__c= leadtoConvert.Subscription_Advertising__c;
                                
                        }
                        if(leadtoConvert.Street!=null && leadtoConvert.Professional_Id__c!= null){
                            
                            con.Avvo_Contact_Street_Address_1__c = leadtoConvert.Street;    
                        }
                        
                        if(leadtoConvert.City!=null && leadtoConvert.Professional_Id__c!= null){
                            con.Avvo_Contact_City__c= leadtoConvert.City;    
                        }
                        
                        if(leadtoConvert.State!=null && leadtoConvert.Professional_Id__c!= null){
                            con.Avvo_Contact_State_Name__c= leadtoConvert.State;    
                        }
                        
                        if(leadtoConvert.Country!= null && leadtoConvert.Professional_Id__c!= null){
                            con.Avvo_Contact_Country__c = leadtoConvert.Country;    
                        }
                        
                        if(leadtoConvert.PostalCode!=null && leadtoConvert.Professional_Id__c!= null){
                            con.Avvo_Contact_Zip_Code__c= leadtoConvert.PostalCode;    
                        }
                        
                        if(leadtoConvert.Phone!=NULL){
                            con.Phone= leadtoConvert.Phone;    
                        }
                        
                        if(leadtoConvert.Q_A_Subscriptions__c!=NULL){
                            con.Q_A_Subscriptions__c= leadtoConvert.Q_A_Subscriptions__c;    
                        }
                        
                        if(leadtoConvert.Opt_Out_URL_Advertising__c!=NULL){
                            con.Opt_Out_URL_Advertising__c= leadtoConvert.Opt_Out_URL_Advertising__c;    
                        }
                        
                        if(leadtoConvert.Opt_Out_URL_Announcement__c!=NULL ){
                            con.Opt_Out_URL_Announcement__c= leadtoConvert.Opt_Out_URL_Announcement__c;    
                        }
                        
                        if(leadtoConvert.Opt_Out_URL_Conference__c!=NULL ){
                            con.Opt_Out_URL_Conference__c= leadtoConvert.Opt_Out_URL_Conference__c;    
                        }
                        
                        if(leadtoConvert.Opt_Out_URL_Feedback__c!=NULL){
                            con.Opt_Out_URL_Feedback__c= leadtoConvert.Opt_Out_URL_Feedback__c;    
                        }
                        
                        if(leadtoConvert.Opt_Out_URL_Newsletter__c!=NULL ){
                            con.Opt_Out_URL_Newsletter__c= leadtoConvert.Opt_Out_URL_Newsletter__c;    
                        }
                        
                        if(leadtoConvert.Opt_Out_URL_Webinar__c!=NULL ){
                            con.Opt_Out_URL_Webinar__c= leadtoConvert.Opt_Out_URL_Webinar__c;    
                        }
                        
                        if(leadtoConvert.Opt_Out_URL_Welcome__c!=NULL){
                            con.Opt_Out_URL_Welcome__c= leadtoConvert.Opt_Out_URL_Welcome__c;    
                        }
                        
                        if(leadtoConvert.Last_Profile_Update__c!=NULL){
                            con.Last_Profile_Update__c= leadtoConvert.Last_Profile_Update__c;    
                        }
                        
                        if(leadtoConvert.Do_Not_Call_Date_Time__c!=NULL){
                            con.Do_Not_Call_Date_Time__c= leadtoConvert.Do_Not_Call_Date_Time__c;    
                        }
                        
                        if(leadtoConvert.Assistant_Title__c!=NULL){
                            con.POC_Title_Notes__c = leadtoConvert.Assistant_Title__c;    
                        }
                        
                        if(leadtoConvert.Assistant_Phone__c!=NULL){
                            con.POC_Phone__c = leadtoConvert.Assistant_Phone__c;    
                        }
                        
                        if(leadtoConvert.Assistant_Name__c!=NULL){
                            con.POC_Name__c = leadtoConvert.Assistant_Name__c;    
                        }
                        
                        if(leadtoConvert.Assistant_Email__c!=NULL){
                            con.POC_Email__c = leadtoConvert.Assistant_Email__c;    
                        }
                        
                        if(leadtoConvert.Goes_By_Name__c!=NULL){
                            con.Goes_By_Name__c= leadtoConvert.Goes_By_Name__c;    
                        }
                        
                        if(leadtoConvert.pi__Needs_Score_Synced__c!=NULL){
                            con.pi__Needs_Score_Synced__c= leadtoConvert.pi__Needs_Score_Synced__c;    
                        }
                        /*
                        if(leadtoConvert.qbdialer__ContactDate__c!=NULL ){
                            con.qbdialer__ContactDate__c= leadtoConvert.qbdialer__ContactDate__c;    
                        }
                        
                        if(leadtoConvert.qbdialer__ContactScore__c!=NULL){
                            con.qbdialer__ContactScore__c= leadtoConvert.qbdialer__ContactScore__c;    
                        }
                        
                        if(leadtoConvert.qbdialer__ContactScoreId__c!=NULL){
                            con.qbdialer__ContactScoreId__c= leadtoConvert.qbdialer__ContactScoreId__c;    
                        }
                        */
                        if(leadtoConvert.City_2__c!=NULL){
                            con.OtherCity = leadtoConvert.City_2__c;
                                
                        }
                        
                        if(leadtoConvert.State_2__c!=NULL){
                            con.OtherState = leadtoConvert.State_2__c;
                                
                        }
                        
                        if(leadtoConvert.Address_2__c!=NULL){
                            con.OtherStreet = leadtoConvert.Address_2__c;
                                
                        }
                        
                        if(leadtoConvert.ownerId != NULL && (leadtoConvert.Professional_ID__c != null)){
                            con.Avvo_Attorney_Account_Owner__c = leadtoConvert.ownerId;
                                
                        }
                        
                         if(leadtoConvert.Zip_Postal_Code_2__c!=NULL){
                            con.OtherPostalCode = leadtoConvert.Zip_Postal_Code_2__c;
                                
                        }
                        
                        
                        if(leadtoConvert.License_Date__c!=NULL){
                            con.License_Date__c = leadtoConvert.License_Date__c;
                                
                        }
                        
                        if(leadtoConvert.Avvo_Lead_Source__c !=NULL){
                            con.Avvo_Lead_Source__c = leadtoConvert.Avvo_Lead_Source__c;
                                
                        }
                        
                        System.debug('@@@@@CLaimed Method------------>'+leadtoConvert.Claimed_Method__c);
                        //System.debug('@@@@@Contact CLaimed Method------------>'+con.Claimed_Method__c);
                        //System.debug('@@@@@@@Contact existing Phone ------------>'+con.Phone);
                        
                        if((leadtoConvert.Claimed_Method__c!=NULL && leadtoConvert.Claimed_Method__c == 'Bulk Claim') || 
                        (leadtoConvert.Delete_Indicator__c == 'Deleted') || (leadtoConvert.Practice_Status__c != NULL) || 
                        (leadtoConvert.DoNotCall == True) || (leadtoConvert.Phone == NULL && leadtoConvert.Phone_2__c == NULL && leadtoConvert.Phone_3__c == NULL && con.Phone == NULL && con.Phone_2__c == NULL && con.Phone_3__c == NULL) ||
                        (leadtoConvert.Practice_Indicator__c == 'Not Practicing') ){
                            con.Avvo_Advertising_Status_Contact__c = 'Not Callable';
                        }else if(leadtoConvert.New_claim__c == True){
                            con.Avvo_Advertising_Status_Contact__c = 'New Claim';                            
                        }else{
                            con.Avvo_Advertising_Status_Contact__c = 'Seek List Only';
                        } 
                        
                        System.debug('@@@@Contact Email3----->'+con.Email_3__c);
                        System.debug('@@@@Contact Avvo_com_Email__c----->'+con.Avvo_com_Email__c);
                        System.debug('@@@@Contact Professional ID----->'+con.Professional_Id__c);
                        System.debug('@@@@------>'+con.Related_To_Account__c);
                        commonlist.add(con);
                    }
                    //T01
                    else if(accountIdVsContactIdMapMH.containskey(con.id) || test.isRunningTest()){
                        
                        System.debug('Avalara Address Validation');
                        if(leadtoConvert.Address_Street_Line_2__c!=NULL || leadtoConvert.Address_Street_Line_2__c!=''){
                            con.Address_Street_Line_2__c = leadtoConvert.Address_Street_Line_2__c;    
                        }
                        commonlist.add(con);
                    }
                }     
            }
            else {
                System.debug('@@@Inside the else condition------>');
                contactsToIntegrate = new List<Contact>();
            }
            commonlist.add(childaccount);
            commonlist.add(parentAccount);
            
            System.debug('@@@@@@con------------->'+con);
            
             if (accountsToIntegrate.size() > 0) {
                system.debug('--In Banana Stand Integration ----'+accountsToIntegrate);
                system.debug('--contacts Integration ----'+contactsToIntegrate);
                
                //IntegrationEngine.IntegrateContacts_BananaStandProfessionalsSyncCreateRelationship(contactsToIntegrate);
                IntegrationEngine.IntegrateAccounts_BananaStandConvert(accountsToIntegrate,contactsToIntegrate,accountIdVsContactIdMap);
            }
            
            System.debug('@@@@@opp------>'+opp);
            if (opp!= null){
                commonlist.add(opp);
            }
            
            System.debug('Common List'+commonlist);
            update commonlist;
            system.debug('----xxx----'+childaccount);
           
    }
    
    
    
    //this method to delete campaign members which are not belongs to 
    //lead business unit
    public static void deleteCampaignMembers(lead l){
        List<CampaignMember> campmemberstoDelete = new List<CampaignMember>();
         string businessUnit='';
         if(l.RecordType.DeveloperName == 'MDL_Leads'){
                businessUnit = 'JV';
             }
            else if(l.RecordType.DeveloperName == 'Nolo_Leads'){
                businessUnit = 'Martindale-Hubbell';
             }
            else if(l.RecordType.DeveloperName == 'M_N_Leads'){
                businessUnit = 'Martindale-Nolo';
             }
            
             //M- A Intake Cases 
               else if(l.RecordType.DeveloperName == 'M_A_Intake_Leads'){
                businessUnit = 'M-A Intake';
             }
             
            else if(l.RecordType.DeveloperName == 'M_NG_Leads'){
                businessUnit = 'Martindale-Ngage';
             }
        
        if(businessUnit != '' && businessUnit != NULL){
            campmemberstoDelete = [select id, CampaignId, LeadId
                                         From CampaignMember 
                                         where LeadId =: l.id AND Campaign.Busineess_Unit__c !=:businessUnit];
                                         // AND Campaign.Busineess_Unit__c != NULL];
        }
        
        if(!campmemberstoDelete.isEmpty()){
            delete campmemberstoDelete;
        }
    }

}
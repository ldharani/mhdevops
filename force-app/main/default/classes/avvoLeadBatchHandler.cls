/***
Notes : external Id field on Account Object with name RefExtId__c
scenarios : 1 --> if l.email and l.email3 same 
                   i. if more than one account found no changes, show error
                   ii. if one account found do the lead conversion

            2 --> if l.email and l.email3 are different
                   i. if l.email matching one account found : do the merge then no need to check for l.email3
                   iii. if l.email matching more than one account found thenn check for l.email3 account : if one account found do the merge
                   iv. if l.email no matching account found and then check for l.email3 account : if one accountn found do the merge
                   v. if l.email matching more than one account, if l.email3 matching more than one account then populate lead conversion error message on lead




***/


public class avvoLeadBatchHandler {

///* 6/10
     public static boolean IsLeadConvertTrigger = false;
    public static void filterLeadstoCovert(List<lead> leadList){

        List<lead> filteredleads = new List<lead>();
        Integer noOfDays;
        //get custom setting data
        List<Avvo_Lead_Criteria__mdt>  leadconversionSettings =  new List<Avvo_Lead_Criteria__mdt>();
        
        leadconversionSettings  = [Select id, DeveloperName, MasterLabel,Claim_Method__c, No_of_Days__c,Owner__c,
                       Claim_Attribute__c From Avvo_Lead_Criteria__mdt Where Claim_Attribute__c!= null];
        
        system.debug('------- SaiC ----------leadList'+leadList);
        system.debug('------- SaiC ----------leadconversionSettings'+leadconversionSettings);
        for(Lead l : leadList){
             Date Today = Date.Today();
             //Integer noOfDays =  Today -  l.Claimed_Date__c;
             
             //noOfDays = today.daysBetween(l.Claimed_Date__c);
             noOfDays = l.Claimed_Date__c.daysBetween(today);
             system.debug('------- SaiC  ----------noOfDays- '+noOfDays);


            for(Avvo_Lead_Criteria__mdt lsetting : leadconversionSettings){
                List<string> claimedMethods = lsetting.Claim_Method__c.split(',');
                List<string> cliamedAttributes = lsetting.Claim_Attribute__c.split(',');
                List<String> claimedprofles = lsetting.Owner__c.split(',');
                Boolean claimedMethodMatch = false;
                Boolean claimedAttributeMatch = false;
                Boolean leadprofilecheck = false;

                //Claimed Method Check
                for(string cm : claimedMethods){
                    if(l.Claimed_Method__c == cm){
                        claimedMethodMatch = true;
                        system.debug('------- SaiC  ----------Claim method Check- '+claimedMethodMatch );
                        break;
                        
                    }
                    
                }
                
                
                //Lead Profile Check
                for(string pc : claimedprofles ){
                    if(l.Owner.Profile.Name == pc ){
                        leadprofilecheck = true;
                        system.debug('------- SaiC  ----------Lead Profile Check- '+leadprofilecheck );
                        break;
                    }
                }
                
                //Claimed Attribute Check
               /* for(string ca : cliamedAttributes){
                    if(l.Claim_Attribution__c== ca){
                        claimedAttributeMatch = true;
                        system.debug('------- SaiC  ----------Claim attribute Check- '+claimedAttributeMatch );
                        break;
                    }
                 }*/
                 

                //checking the main scenarios here
                System.debug('@@@@@@claimedMethodMatch----------->>>>> '+claimedMethodMatch + '--------lead id' + l.id );
                System.debug('@@@@@@leadprofilecheck ----------->>>>> '+leadprofilecheck );
                System.debug('@@@@@@noOfDays ----------->>>>> '+noOfDays + '---------setting' + lsetting.No_of_Days__c );
                
                if(claimedMethodMatch && leadprofilecheck && noOfDays >= lsetting.No_of_Days__c){
                    filteredleads.add(l);
                    system.debug('------- SaiC  ----------filteredleads- '+filteredleads);
                    
                }




            }
         

        }


        if(!filteredleads.isEmpty()){
            batchHandler(filteredleads);
        }


    }


     public static void batchHandler(List<lead> leadList){

        system.debug('------- SaiC  ----------batchHandler Leads- '+leadList);
        
        Set<String> leadEmails = new Set<String>();
        List<AccountContactRelation> accConList = new List<AccountContactRelation>();
        Map<String, Set<Id>> leadEmailVsParentAccounts = new  Map<String, Set<Id>>();
        set<Id> parentAccids                  = new set<id>();
        account parentAccounts;
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        List<Account> commonlist           = new list<Account>();
        List<Contact> contactlist = new list<Contact>();
        Map<String,String> conIdVSIBaccExternalId = new  Map<String,String> ();
        List<AccountContactRelation> AccountContactRelationList= new List<AccountContactRelation>();
        List<Account_Contact_Relation__c > AccountContactRelationcustom= new List<Account_Contact_Relation__c>();
        Map<String,String> conIdVSAvvoFirmaccExternalId = new  Map<String,String> ();
        List<AccountContactRelation> accConListToInsert = new List<AccountContactRelation>();
         List<contact> deleteContacts = new List<contact>();
        Set<String>accountsToIntegrateIds = new Set<String>();
        Set<String>contactsToIntegrateIds = new Set<String>();
        Map<String, String> leadIdVsCampaignId = new Map<String, String>();
        

           List<Account> accountsToIntegrate = new List<Account>();
            List<Contact> contactsToIntegrate = new List<Contact>();
             Map<Id,Id> accountIdVsContactIdMap = new Map<Id,Id>();

          List<contact>contactstoUpdte = new List<contact>();
          List<lead> updateLeadList = new LIst<Lead>();
          Map<Id,Id> leadIdVsAvvoFirmId = new Map<Id,Id>();
          Map<Id, Lead> idVsLead      = new Map<Id, Lead>();
          Map<id, id>  parentaccidVsconid = new Map<id, id>();
          //Map<id,account>parectAccVsAccounts = new  Map<id,account>();
          Map<string, List<account>>parectAccVsAccounts = new  Map<string, List<account>>();
        for(Lead l : leadList) {
            if(l.Email != NULL ) {
                leadEmails.add(l.Email);
            }
            if(l.Email_3__c != NULL){
                leadEmails.add(l.Email_3__c );
            }
            system.debug('------- SaiC  ----------Lead Emails - '+leadEmails);
            idVsLead.put(l.Id, l);
        }
        
        if(!leadEmails.isEmpty()){
                 accConList = [Select id,contactId,AccountId,isActive, contact.Email,Account.parent.parentid,
                        Account.Name,account.RecordType.Name,
                          account.RecordType.DeveloperName,
                           Account.Parent_ID__c 
                      From AccountContactRelation 
                       where contact.Email IN:leadEmails]; 
                
               system.debug('------- SaiC  ----------accConList - '+accConList );
                
                
               for(AccountContactRelation acr : accConList) {
                    String ParentAccId = acr.Account.Parent_ID__c ;
                   if(acr.Account.RecordType.DeveloperName == 'M_A_Atty_Account') {
                       ParentAccId = acr.Account.parent.parentid;
                   }
                   parentAccids.add(ParentAccId);
                    
                    parentaccidVsconid.put(ParentAccId, acr.contactId);
                   if(leadEmailVsParentAccounts.containskey(acr.contact.Email)){
                       leadEmailVsParentAccounts.get(acr.contact.Email).add(ParentAccId);
                       //system.debug('------- SaiC  ----------leadEmailVsParentAccounts - '+leadEmailVsParentAccounts);
                   }
                   else{
                       leadEmailVsParentAccounts.put(acr.contact.Email, new Set<Id>{ParentAccId});
                       
                        system.debug('------- SaiC  ----------leadEmailVsParentAccounts - '+leadEmailVsParentAccounts);
                   }
               }        

        }

        system.debug('------- SaiC  ----------parentAccids- '+parentAccids);
         if(!parentAccids.isEmpty()){
            for(Account acc : [select id,Name, parent.parentid,
                                       RecordType.DeveloperName,
                                       RecordType.Name,
                                       MH_Cust_Number__c,Business_Unit__c,
                                       Parent_ID__c,ParentId
                                       From account
                               where Parent_ID__c IN:parentAccids]){
                  
                  
                                   
                  if(acc.ParentId == null){
                                  //Parentaccids ?
                                //parentAccounts.add(acc); 
                       // parentAccIdVsAccount.put(acc.id,acc);
                       
                       system.debug('------- SaiC  ----------acc.ParentId- '+acc.ParentId);
                   }
                  else{
                      if(parectAccVsAccounts.containsKey(acc.Parent_ID__c)){
                          parectAccVsAccounts.get(acc.Parent_ID__c).add(acc);
                          
                          system.debug('------- SaiC  ----------parectAccVsAccounts- '+parectAccVsAccounts);
                      }
                      else{
                          parectAccVsAccounts.put(acc.Parent_ID__c,new List<account>{acc});
                           system.debug('------- SaiC  ----------parectAccVsAccounts- '+parectAccVsAccounts);
                      }
                  }               
                                   
              }
            
        }

        LeadStatus convertStatus = [SELECT Id, MasterLabel
            FROM LeadStatus
            WHERE IsConverted=true
            LIMIT 1];

         Map<string, string> leadIdVsMatchParentAccId = new Map<string, string>();   

        for(Lead l : leadList) {
            boolean emailfound = false;
            boolean errorNeeded = false;
            integer emailsize = 0;
            integer email3size = 0;
            system.debug('------- SaiC  ----------leadList- '+leadList);
            if(l.Email != NULL){
                 if(leadEmailVsParentAccounts.containsKey(l.Email)) {
                    emailsize = leadEmailVsParentAccounts.get(l.Email).size();

                    system.debug('------- SaiC  ----------leadEmailVsParentAccounts.get(l.Email).size()- '+leadEmailVsParentAccounts.get(l.Email).size());
                    if(leadEmailVsParentAccounts.get(l.Email).size() == 1 ){
                        String selectedParentAccId = (new list<id>(leadEmailVsParentAccounts.get(l.Email))) [0];
                        leadIdVsMatchParentAccId.put(l.Id, selectedParentAccId);
                        system.debug('------- SaiC  ----------leadIdVsMatchParentAccId- '+leadIdVsMatchParentAccId);
                        if (parectAccVsAccounts.containsKey(selectedParentAccId)) {
                            for(account acc : parectAccVsAccounts.get(selectedParentAccId)){
                                //TODO:
                                if(acc.RecordType.DeveloperName == 'M_A_Firm_Account' ){
                                    leadIdVsAvvoFirmId.put(l.Id, acc.Id);
                                }
                            }
                        }    
                        Database.LeadConvert lc = new Database.LeadConvert();
                        lc.setLeadId(l.id);
                        lc.setConvertedStatus(convertStatus.MasterLabel);
                        lc.setDoNotCreateOpportunity(true);
                        leadConverts.add(lc);
                        emailfound = true;
                        
                        //system.debug('------- SaiC  ----------emailfound - '+emailfound );
                    }
                    

                 }
                    system.debug('------- SaiC  ----------emailfound - '+emailfound );
            }

             if(l.Email_3__c != NULL && !emailfound){
                if(leadEmailVsParentAccounts.containsKey(l.Email_3__c)) {
                    email3size = leadEmailVsParentAccounts.get(l.Email_3__c).size();

                    if(leadEmailVsParentAccounts.get(l.Email_3__c).size() == 1 ){
                        String selectedParentAccId = (new list<id>(leadEmailVsParentAccounts.get(l.Email_3__c))) [0];
                        leadIdVsMatchParentAccId.put(l.Id, selectedParentAccId);
                        if (parectAccVsAccounts.containsKey(selectedParentAccId)) {
                            for(account acc : parectAccVsAccounts.get(selectedParentAccId)){
                                //TODO:
                                if(acc.RecordType.DeveloperName == 'M_A_Firm_Account' ){
                                    leadIdVsAvvoFirmId.put(l.Id, acc.Id);
                                }
                            }
                        }    
                        Database.LeadConvert lc = new Database.LeadConvert();
                        lc.setLeadId(l.id);
                        lc.setConvertedStatus(convertStatus.MasterLabel);
                        lc.setDoNotCreateOpportunity(true);
                        leadConverts.add(lc);
                        emailfound = true;
                    }
                    
            }
            system.debug('------- SaiC  ----------email 3 - '+emailfound );
          }  

         if(!emailfound && (emailsize > 1 || email3size > 1) ){
                 l.Lead_Conversion_Error_Message__c = 'Too many duplicate Accounts';
                        updateLeadList.add(l);
         }
            
         else if(!emailfound){
             Database.LeadConvert lc = new Database.LeadConvert();
                        lc.setLeadId(l.id);
                        lc.setConvertedStatus(convertStatus.MasterLabel);
                        lc.setDoNotCreateOpportunity(true);
                        leadConverts.add(lc);

         }

           system.debug('------- SaiC  ----------leadConverts - '+leadConverts);


          /*  if(l.Email != NULL) {
                if(leadEmailVsParentAccounts.containsKey(l.Email)) {
                    if(leadEmailVsParentAccounts.get(l.Email).size() == 1 ){
                        String selectedParentAccId = (new list<string>(leadEmailVsParentAccounts.get(l.Email)) )[0] );
                        leadIdVsMatchParentAccId.put(l.Id, selectedParentAccId);
                        if (parectAccVsAccounts.containsKey(selectedParentAccId)) {
                            for(account acc : parectAccVsAccounts.get(selectedParentAccId)){
                                //TODO:
                                if(acc.RecordType.DeveloperName == 'Avvo_Firm_Accounts' ){
                                    leadIdVsAvvoFirmId.put(l.Id, acc.Id);
                                }
                            }
                        }    
                        Database.LeadConvert lc = new Database.LeadConvert();
                        lc.setLeadId(l.id);
                        lc.setConvertedStatus(convertStatus.MasterLabel);
                        lc.setDoNotCreateOpportunity(true);
                        leadConverts.add(lc);
                    }
                    else if(leadEmailVsParentAccounts.get(l.Email).size() > 1 ) {
                        l.Lead_Conversion_Error_Message__c = 'Too many duplicate Accounts';
                        updateLeadList.add(l);
                    }
                }
                else{
                     Database.LeadConvert lc = new Database.LeadConvert();
                        lc.setLeadId(l.id);
                        lc.setConvertedStatus(convertStatus.MasterLabel);
                        lc.setDoNotCreateOpportunity(true);
                        leadConverts.add(lc);
                }

            }*/
   // /* 6/10    
    }
        //added to Bypass update callouts  - 08/20
        AccountLogic.SYNC_ACCOUNT_CHANGES = false;
        //avvoContactLogic.SYNC_CONTACT_CHANGES = false;
        AccountContactRelationshipLogic.SYNC_ACCOUNT_CONTACT_CHANGES = False; 
        //
        
        set<string>convertedLeadAccountIds = new Set<string>();

        Database.LeadConvertResult[] lcrs = Database.convertLead(leadConverts, false);
         system.debug('----------lcrs : ----'+lcrs);
         for(Database.LeadConvertResult lc : lcrs){
            convertedLeadAccountIds.add(lc.getAccountId());

         }
            
         system.debug('----------SOQL query : ----'+convertedLeadAccountIds); 
           
        Map<Id, Account> convertedAccIdVsAccount = new Map<Id,Account>();
         if(!convertedLeadAccountIds.isEmpty()){
              string whereClause              = 'Id IN : convertedLeadAccountIds';
              String soql                     = genericUtilityClass.getCreatableFieldsSOQL('account',whereClause);
              for(account acc : Database.query(soql)){
                  convertedAccIdVsAccount.put(acc.Id, acc);
              }
         }

        Id avvoAttorneyAccountRectypeId   = Schema.SObjectType.account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
           
        for(Database.LeadConvertResult lc : lcrs){
            String leadId              = lc.getLeadId();
            String accountidToRedirect = lc.getAccountId();
            string contctId            = lc.getContactId();
            string opptyId             = lc.getOpportunityId();
            account childaccount;
            account parentAccount;
            account avvoFirmAccount;
            lead  l = idVsLead.get(leadId);
            String leadName;
            String LeadOwner ;
            Date leadCampaignDate;
            
            if(l.MiddleName!=Null){
            
                leadName  =  l.FirstName + ' '+ l.MiddleName + ' '+ l.lastName;
            }          
            else{
                    leadName = l.firstName + ' '+ l.lastName;
            }
            
            if(l.Owner.Profile.Name =='Avvo Sales Development'){
            
                LeadOwner = l.ownerid;
            }
            
            if(l.campaign_ID__c!=NULL && l.Date_Added_to_Avvo_Marketing_Campaign__c!=Null){
                
                Date startDate = Date.Today();
                integer marketingtime = integer.valueOf(system.Label.Marketing_Time_Frame);
                    integer noOfdays =  l.Date_Added_to_Avvo_Marketing_Campaign__c.daysBetween(startDate );
                    
                    System.debug('@@@@@No of Days------->'+noOfdays );
                    System.debug('@@@@@@@@@@@Lead Campaign Date First----------->'+l.Date_Added_to_Avvo_Marketing_Campaign__c);

                    if(noOfDays < marketingtime ){
                        if(!leadIdVsCampaignId.containskey(l.Id)){
                            leadIdVsCampaignId.put(l.id, l.campaign_ID__c); 
                        } 
                        leadCampaignDate =  l.Date_Added_to_Avvo_Marketing_Campaign__c;  
                    }    
            }
            
            //1. Email Matching IB account available and avvo firm account also available
            if(!leadIdVsAvvoFirmId.isEmpty() && leadIdVsAvvoFirmId.containsKey(leadId)){
                string parentAccId   = leadIdVsMatchParentAccId.get(leadId);
                string avvofirmAccId = leadIdVsAvvoFirmId.get(leadId);
                 childaccount = new account(id= accountidToRedirect, /*Ownerid = LeadOwner, */ Name = LeadName, parentId =avvofirmAccId, 
                                             Hold_dunning_letter_till__c = null,Dunning_Hold__c = FALSE,Contact_Name__c = leadName,
                                             RecordTypeId = avvoAttorneyAccountRectypeId, Business_Unit__c = 'Avvo');
                
                if(leadIdVsCampaignId.containskey(l.id)){
                    childaccount.Current_Avvo_Marketing_Campaign__c= leadIdVsCampaignId.get(l.id);
                }                             
                System.debug('@@@@@@@@@@@Lead Campaign Date----------->'+leadCampaignDate);
                if(leadCampaignDate!=Null){
                    System.debug('Inside the campaign if condition----------------------->');
                    childaccount.Date_Added_to_Avvo_Marketing_Campaign__c = leadCampaignDate;
                }
                 
                parentAccount = new Account(id = parentAccId,Dunning_Hold__c = FALSE, Hold_dunning_letter_till__c= null);
                avvoFirmAccount = new account(id= avvofirmAccId, parentId = parentAccId,Hold_dunning_letter_till__c = null,
                                             Dunning_Hold__c = FALSE, Business_Unit__c = 'Avvo');
                commonlist.add(avvoFirmAccount);
                commonlist.add(childaccount);
                commonlist.add(parentAccount);
                //commonlist.add(new accountcontactRelation(AccountId = accountidToRedirect , contactId = parentaccidVsconid.get(parentAccId)));
                AccountContactRelationList.add(new accountcontactRelation(AccountId = accountidToRedirect , contactId = parentaccidVsconid.get(parentAccId)));
                
                //Avvo Firm AccountContactRelation Record 
                AccountContactRelationList.add(new accountcontactRelation(AccountId = avvofirmAccId , contactId = parentaccidVsconid.get(parentAccId)));
                
                AccountContactRelationcustom.add(new Account_Contact_Relation__c(Account__c  = accountidToRedirect , Contact__c   = parentaccidVsconid.get(parentAccId) , Roles__c     = 'Lead/Paying Attorney'));
                 system.debug('------- SaiC  ----------AccountContactRelationcustom  - '+AccountContactRelationcustom);
                deleteContacts.add(new contact(id = contctId));
               accountsToIntegrateIds.add(accountidToRedirect);
               contactsToIntegrateIds.add(parentaccidVsconid.get(parentAccId));
                accountIdVsContactIdMap.put(parentaccidVsconid.get(parentAccId),accountidToRedirect);
                 contactstoUpdte.add(updatecontact( parentaccidVsconid.get(parentAccId), idVsLead.get(leadId), childaccount));
            }
            //2. Email Matching IB account available but not avvo firm account
            else if(!leadIdVsAvvoFirmId.containsKey(leadId) && leadIdVsMatchParentAccId.containskey(leadId)) {
                 string parentAccId   = leadIdVsMatchParentAccId.get(leadId);
               // Account avvofirmReference       = new Account(RefExtId__c = leadId+ 'AvvoFirm');
                childaccount = new account(id= accountidToRedirect, RefExtId__c = leadId+ ':AvvoAttorney',
                    //parent = avvofirmReference, 
                                             Hold_dunning_letter_till__c = null,Dunning_Hold__c = FALSE,Contact_Name__c = leadName,
                                             RecordTypeId = avvoAttorneyAccountRectypeId, Business_Unit__c = 'Avvo');
               
                if(leadIdVsCampaignId.containskey(l.id)){
                    childaccount.Current_Avvo_Marketing_Campaign__c= leadIdVsCampaignId.get(l.id);
                }                             
                System.debug('@@@@@@@@@@@Lead Campaign Date----------->'+leadCampaignDate);
                if(leadCampaignDate!=Null){
                    System.debug('Inside the campaign if condition----------------------->');
                    childaccount.Date_Added_to_Avvo_Marketing_Campaign__c = leadCampaignDate;
                }
               


                Account tempAcc                 = convertedAccIdVsAccount.get(accountidToRedirect);
                account avvoFirmAccount1         = tempAcc.clone(false, true);
               avvoFirmAccount1.RecordTypeId     = Schema.SObjectType.account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId();
               avvoFirmAccount1.MH_Cust_Number__c = '';
               avvoFirmAccount1.RefExtId__c      = leadId+ ':AvvoFirm';
               avvoFirmAccount1.ParentId        = parentAccId;
               avvoFirmAccount1.Hold_dunning_letter_till__c = null;
               avvoFirmAccount1.Dunning_Hold__c = FALSE;
               avvoFirmAccount1.Business_Unit__c = 'Avvo';

                parentAccount = new Account(id = parentAccId,Dunning_Hold__c = FALSE, Hold_dunning_letter_till__c= null);
                commonlist.add(avvoFirmAccount1);
                commonlist.add(childaccount);
                commonlist.add(parentAccount);
                //commonlist.add(new accountcontactRelation(AccountId = accountidToRedirect , contactId = parentaccidVsconid.get(parentAccId)));
                AccountContactRelationList.add(new accountcontactRelation(AccountId = accountidToRedirect , contactId = parentaccidVsconid.get(parentAccId)));
                AccountContactRelationcustom.add(new Account_Contact_Relation__c(Account__c  = accountidToRedirect , Contact__c   = parentaccidVsconid.get(parentAccId) , Roles__c     = 'Lead/Paying Attorney')); 
                deleteContacts.add(new contact(id = contctId));
                 conIdVSAvvoFirmaccExternalId.put(leadId+ ':AvvoFirm' , parentaccidVsconid.get(parentAccId));conIdVSAvvoFirmaccExternalId.put(leadId+ ':AvvoFirm' , parentaccidVsconid.get(parentAccId));
                 contactstoUpdte.add(updatecontact( parentaccidVsconid.get(parentAccId), idVsLead.get(leadId), childaccount));
                 
                 accountsToIntegrateIds.add(accountidToRedirect);
                  contactsToIntegrateIds.add(parentaccidVsconid.get(parentAccId));
                     accountIdVsContactIdMap.put(parentaccidVsconid.get(parentAccId),accountidToRedirect);
               
            }

            //3. completely new Lead i.e no matching available
            else{
                 Account ibReference       = new Account(RefExtId__c = leadId+ 'IB');
                 //Account avvofirmReference       = new Account(RefExtId__c = leadId+ 'AvvoFirm');

                 childaccount = new account(id= accountidToRedirect, RefExtId__c = leadId+ ':AvvoAttorney',
                       //parent = avvofirmReference, 
                                             Hold_dunning_letter_till__c = null,Dunning_Hold__c = FALSE,Contact_Name__c = leadName,
                                             RecordTypeId = avvoAttorneyAccountRectypeId, Business_Unit__c = 'Avvo');
                 
                 if(leadIdVsCampaignId.containskey(l.id)){
                    childaccount.Current_Avvo_Marketing_Campaign__c= leadIdVsCampaignId.get(l.id);
                }                             
                System.debug('@@@@@@@@@@@Lead Campaign Date----------->'+leadCampaignDate);
                if(leadCampaignDate!=Null){
                    System.debug('Inside the campaign if condition----------------------->');
                    childaccount.Date_Added_to_Avvo_Marketing_Campaign__c = leadCampaignDate;
                }
                
                  //contact parentcon = new contact(Id=contctId, account = ibReference);
           
                  Account tempAcc                 = convertedAccIdVsAccount.get(accountidToRedirect);
                Account avvoFirmAccount1;
				if(tempAcc!=null)
                { 
                    avvoFirmAccount1            = tempAcc.clone(false, true);
                	avvoFirmAccount1.RecordTypeId        = Schema.SObjectType.account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId();
                	avvoFirmAccount1.MH_Cust_Number__c    = '';  
                	avvoFirmAccount1.Business_Unit__c = 'Avvo';
               		// avvoFirmAccount1.Parent            =   ibReference;      
                	avvoFirmAccount1.RefExtId__c = leadId+ ':AvvoFirm';
                }


                Account parentAccount1           = tempAcc.clone(false, true);

                parentAccount1.RecordTypeId      = Schema.SObjectType.account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
                parentAccount1.Business_Unit__c  = 'Internet Brands';
                parentAccount1.Legal_Entity__c   = ' M-N Taxable';
                parentAccount1.MH_Cust_Number__c = '';
                parentAccount1.RefExtId__c       = leadId+ ':IB';


                commonlist.add(avvoFirmAccount1);
                commonlist.add(childaccount);
                commonlist.add(parentAccount1);
               //commonlist.add(parentcon);
                //contactlist.add(parentcon);
                conIdVSIBaccExternalId.put(contctId,leadId+ ':IB' );
                //commonlist.add(new accountcontactRelation(AccountId = accountidToRedirect , contactId = contctId));
                AccountContactRelationList.add(new accountcontactRelation(AccountId = accountidToRedirect , contactId = contctId));
                AccountContactRelationcustom.add(new Account_Contact_Relation__c(Account__c  = accountidToRedirect , Contact__c   = contctId  , Roles__c     = 'Lead/Paying Attorney'));
                accountsToIntegrateIds.add(accountidToRedirect);
                contactstoUpdte.add(updatecontact( contctId, idVsLead.get(leadId), childaccount));
                 contactsToIntegrateIds.add(contctId);
                    accountIdVsContactIdMap.put(contctId,accountidToRedirect);
                    conIdVSAvvoFirmaccExternalId.put(leadId+ ':AvvoFirm' ,contctId);
                    
                    
                    //8/20/2019
                    
                     AccountLogic.SYNC_ACCOUNT_CHANGES = False;
                    //avvoContactLogic.SYNC_CONTACT_CHANGES = False;
                    AccountContactRelationshipLogic.SYNC_ACCOUNT_CONTACT_CHANGES = False; 

            }
        }
        
  Map<string,Account> externalIdVsAccount = new Map<string,Account>();
                 
          
          if(!commonlist.isEmpty()) {
              try{
                  
                  system.debug('@@@@@--- commonlist -- ' +commonlist);
                  upsert commonlist;
                  
                  List<account> accountsToUpdate = new List<account>();
                 for(Account acc : commonlist){
                    if(acc.RefExtId__c != NULL){
                        externalIdVsAccount.put(acc.RefExtId__c, acc);
                    }  
                  }

                  List<account> accstoUpdate = new List<account>();
                  Id ibrecordtypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
                  for(string externalId : externalIdVsAccount.keyset()){
                      account acc = externalIdVsAccount.get(externalId);
                      if(acc.RecordTypeId != ibrecordtypeId && acc.ParentId == NULL){
                            List<string> externalidsplit = externalId.split(':');
                            string leadId = externalidsplit[0];
                            if(externalidsplit[1] == 'AvvoAttorney'){
                                string parentkey = leadId + ':AvvoFirm';
                                if(externalIdVsAccount.containskey(parentkey)){
                                    acc.parentId = externalIdVsAccount.get(parentkey).id;
                                    accstoUpdate.add(acc);
                                }
                            }
                            if(externalidsplit[1] == 'AvvoFirm'){
                                 string parentkey = leadId + ':IB';
                                 if(externalIdVsAccount.containskey(parentkey)){
                                    acc.parentId = externalIdVsAccount.get(parentkey).id;
                                    accstoUpdate.add(acc);
                                }

                                 if(conIdVSAvvoFirmaccExternalId.containskey(leadId + ':AvvoFirm')){
                                    AccountContactRelationList.add(new accountcontactRelation(AccountId = acc.Id , contactId = conIdVSAvvoFirmaccExternalId.get(leadId + ':AvvoFirm')));
               

                               }
                            }
                      }
                  }

                  

                  if(!accstoUpdate.isEmpty()){
                    update accstoUpdate;
                  }

                  system.debug('------- SaiC  ----------accstoUpdate - '+accstoUpdate);
                  system.debug('------- SaiC  ----------Account List - '+commonlist); 
                  
                  
              }
              catch(exception ex){
                  system.System.debug('@@@@@Exception ex Account '+ ex);
              }
              
          }
          
          
          if(!conIdVSIBaccExternalId.isEmpty()) {
              try{


                  for(String contid : conIdVSIBaccExternalId.keyset()){
                      string parentAcckey  = conIdVSIBaccExternalId.get(contid);
                      if(externalIdVsAccount.containskey(parentAcckey)){
                        contactlist.add(new contact(id = contid, AccountId = externalIdVsAccount.get(parentAcckey).id)) ;
                      }

                  }
                  
                  if(!contactlist.isEmpty()){
                    upsert contactlist;
                  }
                  
                  system.debug('------- SaiC  ----------Contact List- '+contactlist); 
                  
                  
              }
              catch(exception ex){
                  system.System.debug('@@@@@Exception ex'+ ex);
              }
              
          }
          
          if(!AccountContactRelationList.isEmpty()) {
              try{
                  system.debug('------- SaiC  ----------AccountContactRelationList- '+AccountContactRelationList); 
                  //----Ronak ---error coming in debug on the below line -- 06/18/2019
                  //upsert AccountContactRelationList;
              }
              catch(exception ex){
                  system.System.debug('@@@@@Exception ex AccountContactRelationList'+ ex);
              }
              
          }
          
          system.debug('------- SaiC  ----------AccountContactRelationcustom- '+AccountContactRelationcustom); 
         if(!AccountContactRelationcustom.isEmpty()) {
              try{
                  
                  upsert AccountContactRelationcustom;
                  //system.debug('------- SaiC  ----------AccountContactRelationList- '+AccountContactRelationcustom); 
                  
              }
              catch(exception ex){
                  system.System.debug('@@@@@Exception ex AccountContactRelationList'+ ex);
              }
              
          }
          
          
          //6/17
          if(!contactstoUpdte.isEmpty()){
            update contactstoUpdte;
          }
        
          if(!deleteContacts.isEmpty() && !test.isRunningTest()){
            delete deleteContacts;
          }

        List<Account> accountsToBeUpdate = new List<Account>();
         if(!accountsToIntegrateIds.isEmpty()){
            accountsToIntegrate = [Select id, Name from Account 
                                          where ID IN: accountsToIntegrateIds];
            
            for(Account a: accountsToIntegrate){
                accountsToBeUpdate.add(a);
            }
            if(!accountsToBeUpdate.isempty()){
                update accountsToBeUpdate;
            
            }
            
         }
          
         if(!contactsToIntegrateIds.isEmpty()){
            contactsToIntegrate = [Select id, Name ,Professional_ID__c from contact 
                                           where id IN: contactsToIntegrateIds];
         }
    
        system.debug('------ Accounts Id-----'+accountsToIntegrate);
        system.debug('------ Contact Id-----'+contactsToIntegrate);
        
        
        if(!accountsToIntegrate.isEmpty() && !contactsToIntegrate.isEmpty()){
           //IntegrationEngine.IntegrateAccounts_BananaStandConvert(accountsToIntegrate,contactsToIntegrate,accountIdVsContactIdMap);
           ID jobID = System.enqueueJob(new AsyncExecutionLead(accountsToIntegrate,contactsToIntegrate,accountIdVsContactIdMap ));
        }

     }

//6/10 */
    
        public static contact updatecontact(string conId, Lead l ,Account Acc){
         
         String leadphone ;
         String Profid;
         If(l.Phone != Null){
             
             leadphone = l.Phone;
         }
         
          If(l.Professional_ID__c!= Null){
             
             Profid = l.Professional_ID__c;
         }
         contact con = new Contact(id = conId,
                          Related_To_Account__c = Acc.id,
                          Email_3__c  = l.Email_3__c,
                          Email_2__c  = l.Email_2__c,
                          Avvo_com_Email__c = l.Avvo_com_Email__c ,
                          Professional_Id__c = Profid,
                          //Website__c = l.Website,
                          Address_3__c =l.Address_3__c,
                          Avvo_com_Rating_Text__c = l.Avvo_com_Rating_Text__c,
                          Address_2__c= l.Address_2__c,
                          Ad_Region_ID__c= l.Ad_Region_ID__c,
                          Ad_Region_Name__c= l.Ad_Region_Name__c,
                          Avvo_Rating__c= l.Avvo_Rating__c,
                          City_2__c= l.City_2__c,
                          City_3__c= l.City_3__c,
                          Claimed_Date__c= l.Claimed_Date__c,
                          Claimed_Method__c= l.Claimed_Method__c,
                          Client_Review_Rating__c= l.Client_Review_Rating__c,
                          Client_Reviews_All_Time__c= l.Client_Reviews_All_Time__c,
                          Client_Reviews_Calendar_Month__c= l.Client_Reviews_Calendar_Month__c,
                          County_1__c= l.County_1__c,
                          County_2__c= l.County_2__c,
                          County_3__c= l.County_3__c,
                          DoNotCall = l.DoNotCall, 
                        //  qbdialer__Dials__c= l.qbdialer__Dials__c,
                          Guides_All_Time__c= l.Guides_All_Time__c,
                          Guides_Calendar_Month__c= l.Guides_Calendar_Month__c,
                          Headshot_URL__c= l.Headshot_URL__c,
                         // qbdialer__isdcCallStats__c = l.qbdialer__isdcCallStats__c,
                         // qbdialer__LastCallTime__c= l.qbdialer__LastCallTime__c,
                          Last_Login_Date__c= l.Last_Login_Date__c,
                          License_State_1__c= l.License_State_1__c,
                          License_State_2__c= l.License_State_2__c,
                          License_State_3__c= l.License_State_3__c,
                          Peer_Endorsements_Received_All_Time__c= l.Peer_Endorsements_Received_All_Time__c,
                          Peer_Endorsements_Received_Calendar_Mon__c= l.Peer_Endorsements_Received_Calendar_Mon__c,
                          Phone_2__c= l.Phone_2__c,
                          Phone_3__c= l.Phone_3__c,
                          Practice_Area_1__c= l.Practice_Area_1__c,
                          Practice_Area_2__c= l.Practice_Area_2__c,
                          Practice_Area_3__c= l.Practice_Area_3__c,
                          Practice_Area_4__c= l.Practice_Area_4__c,
                          Practice_Area_5__c= l.Practice_Area_5__c,
                          Practice_Status__c= l.Practice_Status__c,
                          Professional_Type__c= l.Professional_Type__c,
                          Profile_URL__c= l.Profile_URL__c,
                          Questions_Answered_All_Time__c= l.Questions_Answered_All_Time__c,
                          Questions_Answered_Calendar_Month__c= l.Questions_Answered_Calendar_Month__c,
                        //  qbdialer__ResponseTime__c= l.qbdialer__ResponseTime__c,
                          State_2__c= l.State_2__c,
                          State_3__c= l.State_3__c,
                          State_ID__c= l.State_ID__c,
                          Zip_Postal_Code_2__c= l.Zip_Postal_Code_2__c,
                          Zip_Postal_Code_3__c= l.Zip_Postal_Code_3__c,
                          Subscription_Welcome__c= l.Subscription_Welcome__c,
                          Subscription_Webinar__c= l.Subscription_Webinar__c,
                          Subscription_Newsletter__c= l.Subscription_Newsletter__c,
                          Subscription_Feedback__c= l.Subscription_Feedback__c,
                          Subscription_Conference__c= l.Subscription_Conference__c,
                          Subscription_Announcement__c= l.Subscription_Announcement__c,
                          Subscription_Advertising__c= l.Subscription_Advertising__c,
                          Avvo_Contact_Street_Address_1__c = l.Street,
                          Avvo_Contact_City__c= l.City,
                          Avvo_Contact_State_Name__c= l.State,
                          Avvo_Contact_Country__c = l.Country,
                          Avvo_Contact_Zip_Code__c= l.PostalCode,
                          Phone = leadphone,
                          Q_A_Subscriptions__c= l.Q_A_Subscriptions__c,
                          Opt_Out_URL_Advertising__c= l.Opt_Out_URL_Advertising__c,
                          Opt_Out_URL_Announcement__c= l.Opt_Out_URL_Announcement__c,
                          Opt_Out_URL_Conference__c= l.Opt_Out_URL_Conference__c,
                          Opt_Out_URL_Feedback__c= l.Opt_Out_URL_Feedback__c,
                          Opt_Out_URL_Newsletter__c= l.Opt_Out_URL_Newsletter__c,
                          Opt_Out_URL_Webinar__c= l.Opt_Out_URL_Webinar__c,
                          Opt_Out_URL_Welcome__c= l.Opt_Out_URL_Welcome__c,
                          Website__c = l.Lead_Conversion_Website__c,
                          Last_Profile_Update__c= l.Last_Profile_Update__c,
                          Do_Not_Call_Date_Time__c= l.Do_Not_Call_Date_Time__c,
                          POC_Title_Notes__c = l.Assistant_Title__c,
                          POC_Phone__c = l.Assistant_Phone__c,
                          POC_Name__c = l.Assistant_Name__c,
                          POC_Email__c = l.Assistant_Email__c,
                          Practice_Indicator__c = l.Practice_Indicator__c,
                          Goes_By_Name__c= l.Goes_By_Name__c,
                          OtherCity = l.City_2__c,
                          OtherState = l.State_2__c,
                          OtherStreet = l.Address_2__c,
                          Avvo_Attorney_Account_Owner__c = l.ownerId,
                          OtherPostalCode = l.Zip_Postal_Code_2__c,
                          HomePhone = l.Phone_2__c,
                          OtherPhone = l.Phone_3__c,
                          pi__Needs_Score_Synced__c= l.pi__Needs_Score_Synced__c,
                        //  qbdialer__ContactDate__c= l.qbdialer__ContactDate__c,
                        //  qbdialer__ContactScore__c= l.qbdialer__ContactScore__c,
                          Avvo_Lead_Source__c = l.Avvo_Lead_Source__c
                        //  qbdialer__ContactScoreId__c= l.qbdialer__ContactScoreId__c//,
                          //Avvo_Advertising_Status_Contact__c = acc.Advertising_Status_Logic__c
                          
                          
                           );
                           
           if((l.Claimed_Method__c!=NULL && l.Claimed_Method__c == 'Bulk Claim') || 
            (l.Delete_Indicator__c == 'Deleted') || (l.Practice_Status__c != NULL) || 
            (l.DoNotCall == True) || (l.Phone == NULL && l.Phone_2__c == NULL && l.Phone_3__c == NULL && con.Phone == NULL && con.Phone_2__c == NULL && con.Phone_3__c == NULL) ||
            (l.Practice_Indicator__c == 'Not Practicing') ){
                con.Avvo_Advertising_Status_Contact__c = 'Not Callable';
            }else {
                con.Avvo_Advertising_Status_Contact__c = 'New Claim';                            
            }

         return con;
    }
    
}
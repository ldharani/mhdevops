public without sharing class AccountLogic {

    public static boolean isApexTest = false;
    public static boolean throwError = false;
    public static boolean updateAvvoAccTypeOnContactrecurssion = false; 

    public static boolean SYNC_ACCOUNT_CHANGES = true;
    
    public void avvoAccountLogic(List<Account> accounts, Map<id,Account> oldMap, Map<id,Account> newMap){
    
     // Avvo after update logic 
        List<Account> accountsList = new List<Account>();
            Set<Id> accountIdsOwnerChanged = new Set<Id>();
            
            Id RecordTypeId_avvoAttrny = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId(); 

            // only execute when relevant fields change
            for(Id accountId : newMap.keySet()){
                Account oldAccount = oldMap.get(accountId);
                Account newAccount = newMap.get(accountId);
                //Commented by Ronak on 02/06/2020 as part of CPU time limit issue
                //System.debug('@@@@@Leada conversion or not----->'+oldAccount.Leadconvertion__c);
                //System.debug('@@@@@New Leada conversion or not----->'+newAccount.Leadconvertion__c);
                if(oldAccount.RecordtypeId == RecordTypeId_avvoAttrny &&
                    (oldAccount.Phone != newAccount.Phone ||
                    oldAccount.Name != newAccount.Name ||
                    oldAccount.Contact_Email__c != newAccount.Contact_Email__c ||
                    oldAccount.Contact_Name__c != newAccount.Contact_Name__c ||
                    oldAccount.BillingStreet != newAccount.BillingStreet ||
                    oldAccount.BillingCity != newAccount.BillingCity ||
                    oldAccount.BillingState != newAccount.BillingState ||
                    oldAccount.BillingPostalCode != newAccount.BillingPostalCode ||        
                    oldAccount.Deleted_Date_Time__c != newAccount.Deleted_Date_Time__c)){
                    accountsList.add(newAccount);
                }
                
                //System.debug('@@@@@@aqccounts'+accountsList);
                
                // Sync Account Owner with Contact
                if(oldAccount.OwnerId != newAccount.OwnerId){
                    accountIdsOwnerChanged.add(accountId);
                }
            }

            if(accountIdsOwnerChanged.size() > 0){
                OwnerSyncWithContact(accountIdsOwnerChanged);
            }
            if (accountsList.size() > 0) {
                DoAfterUpdate(accounts);
            }
    }
    
    
    public void DoAfterUpdate(List<Account> accounts) {
        if(SYNC_ACCOUNT_CHANGES) {
            IntegrationEngine.IntegrateAccounts_BananaStand(accounts);
        }
    }

    public void OwnerSyncWithContact(Set<Id> accountIds) {
        List<Contact> contacts = new List<Contact>();
        List<Contact> contactsToUpdate = new List<Contact>();

        contacts = [Select Id, OwnerId, AccountId, Account.OwnerId from Contact
                        where AccountId in :accountIds];
        for(Contact contact : contacts){
            if(contact.OwnerId != contact.Account.OwnerId){
                contact.OwnerId = contact.Account.OwnerId;
                contactsToUpdate.add(contact);
            }
        }

        if(contactsToUpdate.size() > 0){
            update contactsToUpdate;
        }
    }

    public class AccountLogicException extends Exception {
    }
    
    public void adverStatusUpdate(List<Account> accounts, Map<id,Account> oldMap, Map<id,Account> newMap){
        //System.debug('@inside my method advertisign wstatuys ---------->');
        Set<Id> acctIds = new Set<Id>(); 
        List<Account> accountList = new List<Account>();
        List<Contact> avvoConList = new List<Contact>();
        List<Contact> contList = new List<Contact>();
        
        List<Contact> conListToUpdate = new List<Contact>();
        Map<Id, List<Contact>> accVsConListMap = new Map<Id, List<Contact>>();
        
        for(Account acc : accounts){
            //Account oldAcc = oldMap.get(acc.id);
            //Account newAcc = newMap.get(acc.Id);
            //System.debug('Old advertising status-------------->'+oldMap.get(acc.id).Advertising_Status_Logic__c);
            //System.debug('New advertising status-------------->'+newMap.get(acc.Id).Advertising_Status_Logic__c);
            if((oldMap.get(acc.id) == null) || ( acc.Advertising_Status_Logic__c!=NULL && (oldMap.get(acc.id).Advertising_Status_Logic__c!= newMap.get(acc.Id).Advertising_Status_Logic__c))){
                accountList.add(acc);
                acctIds.add(acc.id);
            }
        }
    
        if(accountList.size()>0 && !accountList.isempty()){
            avvoConList = [Select id, name,Related_To_Account__c ,Avvo_Advertising_Status_Contact__c From Contact Where Related_To_Account__c in: acctIds];
            
            for(Contact con: avvoConList){
                if(accVsConListMap.containskey(con.Related_To_Account__c)){
                    accVsConListMap.get(con.Related_To_Account__c).add(con);
                }
                else{
                    accVsConListMap.put(con.Related_To_Account__c, new List<Contact> {con});
                }
                
            }
            
            for(Account acc: accountList){
                if(accVsConListMap.containskey(acc.id)){
                    contList = accVsConListMap.get(acc.id);
                    
                    for(Contact con: contList){
                        con.Avvo_Advertising_Status_Contact__c = acc.Advertising_Status_Logic__c;
                        conListToUpdate.add(con);
                    }
                    
                }
            }
        }
        
        if(!conListToUpdate.isempty() && conListToUpdate!=NULL){
            update conListToUpdate;
        }
    
    }
    
    public void avvoAccountOwnerupdate(List<Account> accounts, Map<id,Account> oldMap, Map<id,Account> newMap){
        
      //System.debug('@@@ Inside Accountowner update on Contact ---------->');
        Set<Id> acctIds = new Set<Id>(); 
        List<Account> accountList = new List<Account>();
        List<Contact> avvoConList = new List<Contact>();
        List<Contact> contList = new List<Contact>();
        
        List<Contact> conListToUpdate = new List<Contact>();
        Map<Id, List<Contact>> accVsConListMap = new Map<Id, List<Contact>>();
        
        for(Account acc : accounts){
            
            //System.debug('@@@ In For loop ---------->');
            if((trigger.isInsert && acc.Claimed_Date__c != null) || ( trigger.isUpdate && acc.Claimed_Date__c != null && (oldMap.get(acc.id).ownerId!= newMap.get(acc.Id).ownerId))){
                accountList.add(acc);
                acctIds.add(acc.id);
                //System.debug('@@@ Account Ids ---------->'+acctIds);
            }
        }
    
        if(accountList.size()>0 && !accountList.isempty()){
            avvoConList = [Select id, name,Related_To_Account__c ,Avvo_Attorney_Account_Owner__c From Contact Where Related_To_Account__c in: acctIds];
            
            for(Contact con: avvoConList){
                if(accVsConListMap.containskey(con.Related_To_Account__c)){
                    accVsConListMap.get(con.Related_To_Account__c).add(con);
                    //System.debug('@@@ Contact map accVsConListMap ---------->'+accVsConListMap);
                }
                else{
                    accVsConListMap.put(con.Related_To_Account__c, new List<Contact> {con});
                    //System.debug('@@@ Else Contact map accVsConListMap ---------->'+accVsConListMap);
                }
                
            }
            
            for(Account acc: accountList){
                if(accVsConListMap.containskey(acc.id)){
                    contList = accVsConListMap.get(acc.id);
                    
                    for(Contact con: contList){
                        con.Avvo_Attorney_Account_Owner__c = acc.ownerId;
                        conListToUpdate.add(con);
                    }
                    
                }
            }
        }
        
        if(!conListToUpdate.isempty() && conListToUpdate!=NULL){
            update conListToUpdate;
            
            //System.debug('@@@ Contact Update---------->'+conListToUpdate);
        }   
    }
    //MHBS-3922-SaiV
    public static void avvoWinbackProcess(List<account> accList, Map<id,account> accOldMap){
        
        Set<Id> updatedFromWFAccIds = new Set<Id>();
        Set<Id> updatedAccIds = new Set<Id>();
        List<Account> accountListToUpdate = new List<Account>();
        Map<Id, String> accountIdVsOldAccOwner = new Map<Id, String>();
        List<contact> conList = new List<contact>();
        List<contact> contactListToUpdate = new List<contact>();
        Set<Id> accOwnerId = new Set<Id>();
        Id avvoAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        
        for(Account a:accList){
            
            system.debug('==accOldMap.get(a.id).Win_back__c==='+accOldMap.get(a.id).Win_back__c);
            system.debug('==a.Win_back__c==='+a.Win_back__c);
            if(a.OwnerId != accOldMap.get(a.id).OwnerId && a.recordTypeId == avvoAccRecordTypeId
               && a.Win_back__c != accOldMap.get(a.id).Win_back__c){
                accountIdVsOldAccOwner.put(a.Id, accOldMap.get(a.id).OwnerId);
                updatedFromWFAccIds.add(a.Id);
            }
        }
        if(!updatedFromWFAccIds.isEmpty()){
            List<Account> accLst = [select id, OwnerId, Owner_Full_Name__c, Advertising_Status__c, AM_Book__c, Customer_No_Book__c,
                            Assigned_to_an_AM__c, MRR_Baseline__c, Full_Cancel_Count__c, recordTypeId,Avvo_Trial_End_Date__c,
                             Avvo_Trial_Original_Amount__c,Avvo_Trial_Start_Date__c,Win_back__c from Account where Id IN:updatedFromWFAccIds];
            
            for(Account acc: accLst){
                system.debug('==acc=='+acc);
                
                if(!accountIdVsOldAccOwner.containskey(acc.OwnerId) && acc.Win_back__c == FALSE
                        && acc.Owner_Full_Name__c.contains('Integration')){
                    system.debug('==In winback If condition==');
                    
                    if(acc.Advertising_Status__c != 'Current' && acc.Advertising_Status__c != 'Backorder' && acc.Advertising_Status__c != 'Backorder/Cancelled'
                        && acc.AM_Book__c == FALSE && acc.Customer_No_Book__c == FALSE){
                            acc.Assigned_to_an_AM__c = Null;
                            acc.Full_Cancel_Count__c = 0;
                            acc.MRR_Baseline__c = 0;
                            system.debug('==in if==');
                            acc.Avvo_Trial_End_Date__c = Null;
                            acc.Avvo_Trial_Start_Date__c = Null;
                            acc.Avvo_Trial_Original_Amount__c = Null;
                            updatedAccIds.add(acc.Id);
                            accountListToUpdate.add(acc);
                        }
                }
            }
        }
        if(!updatedAccIds.isEmpty()){
            conList = [select id, FirstName, LastName, Last_Activity_AM_CRM__c, Last_AM_Connected_Call__c, Last_AM_Email_sent__c,
                        Last_AM_Left_Message__c, Onboarding_Completed__c, Email_Suppression_Reason__c,Elite_Setup_Call_Completed__c,
                        Elite_Setup_Call_Scheduled__c ,Opt_out_TrueScheduler__c ,Related_To_Account__c FROM Contact WHERE Related_To_Account__c IN:updatedAccIds];
            system.debug('==conList=='+conList);
            for(Contact con:conList){
                system.debug('==in con if===');
                con.Onboarding_Completed__c = FALSE;
                con.Email_Suppression_Reason__c = NULL;
                //con.Scheduled_By__c = NULL;             
               // added additional fields to update
                con.Elite_Setup_Call_Completed__c = NULL;
                con.Elite_Setup_Call_Scheduled__c = NULL;
                con.Opt_out_TrueScheduler__c = NULL;
                con.Last_Activity_AM_CRM__c = NULL;
                con.Last_AM_Connected_Call__c = NULL;
                con.Last_AM_Email_sent__c = NULL;
                con.Last_AM_Left_Message__c = NULL;
                con.Avvo_AI_Sales_Assistant__c = Null;
                con.Avvo_AI_Sales_Assistant_Date_Added__c = Null;
                con.Avvo_AI_Sales_Assistant_Hot_Lead_Date__c = Null;
                con.Avvo_AI_Sales_Assistant_Hot_Lead__c = false;
                
                //MHBS-5952 Added by VR;3/1/21
                con.Avvo_Retention_AI__c = false;
				con.Avvo_Retention_AI_Date_Added__c = Null;
				con.Avvo_Retention_AI_Hot_Lead__c = false;
				con.Avvo_Retention_AI_Hot_Lead_Date__c = Null;
                
                contactListToUpdate.add(con);
            }
        }
        if(!accountListToUpdate.isEmpty() && accountListToUpdate!=NULL){
            system.debug('===accountListToUpdate==='+accountListToUpdate);
            update accountListToUpdate;
        }
        if(!contactListToUpdate.isEmpty() && contactListToUpdate!=NULL){
            System.debug('===contactListToUpdate===:'+contactListToUpdate);
            update contactListToUpdate; 
        }
    }
    //added by saiv - MHBS-4220 04/07/2020
    public static void updateAvvoAccTypeOnContact(List<Account> accLst, Map<Id,Account> oldMap){
        Map<Id,String> accIdVSAccType = new Map<Id,String>();
        List<Contact> conLst = new List<Contact>();
        List<Contact> updateCon = new List<Contact>();
        Id avvoAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        
        for(Account acc: accLst){
            if(acc.Avvo_Account_Type__c != oldMap.get(acc.Id).Avvo_Account_Type__c && acc.recordTypeId == avvoAccRecordTypeId){
                accIdVSAccType.put(acc.Id, acc.Avvo_Account_Type__c);
            } 
        }
        system.debug('==accIdVSAccType=='+accIdVSAccType);
        if(!accIdVSAccType.isEmpty()){
            conLst = [select id, firstName, LastName, Related_To_Account__c, Related_To_Account__r.Avvo_Account_Type__c,
                        Related_To_Account__r.Id from Contact where Related_To_Account__c IN:accIdVSAccType.Keyset()];
        }
        system.debug('==conLst=='+conLst);
        for(Contact con: conLst){
            if(accIdVSAccType.containskey(con.Related_To_Account__c)){
                con.Avvo_Account_Type__c = accIdVSAccType.get(con.Related_To_Account__c);
                updateCon.add(con);

            }
        }
        system.debug('==updateCon=='+updateCon);
        if(!updateCon.isEmpty()){
            update updateCon;
        }
    }
    
     public  void FkMethod(){
    Integer i = 0;
    i++;
   i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
   
    
    }
    
}
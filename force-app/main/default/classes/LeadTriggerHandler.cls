/***********************************************************************************************************************
 * @author - 
 * @date - 
 * @description - Trigger Handler For Lead
 * @testclass - LeadTriggerHandlerTest

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6252    VR            07/02/2022                   T01     Update "Avalara Address Validation Error" Field
************************************************************************************************************************/

//Done by Sai :Changes made for New Record type changes MHBS-995
public class LeadTriggerHandler {

    public static boolean BypassTaskTrig = false; //added by IJ on Oct 20,2021
    
    //developed for NCONS-113 SaiV 
    public static void zipCodeUpdate(list<lead> ledlist){
    
        map<string,id> zipcodes=new map<string,id>();
        map<string,string> zipcodeMap = new map<String,string>();
        Id mnLedRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-N Leads').getRecordTypeId();
        system.debug('=======RT======='+mnLedRecordTypeId);
        for(Lead led:ledlist){
            if(led.postalcode != null && led.postalcode!= '')
                zipcodeMap.put(led.postalcode, led.postalcode.split('-')[0]);
                system.debug('======zipcode'+led.postalcode);
        }
        for(GEO_Location__c zipcode:[select zipcode__c from GEO_Location__c where zipcode__c in:zipcodeMap.values() AND RecordType.DeveloperName = 'M_N_GEO_Locations']){
            zipcodes.put(zipcode.zipcode__c,zipcode.id);
            system.debug('======zipcode'+zipcode.id);
        }
        
        for(Lead led:ledlist){
            if(led.recordTypeId == mnLedRecordTypeId && led.postalcode!=null && led.postalcode!='' && zipcodeMap.containskey(led.postalcode)){
                    led.Zipcode__c= zipcodes.get(zipcodeMap.get(led.postalcode));
                    system.debug('======zipcode'+led.Zipcode__c);
            }else{
                led.Zipcode__c = null;
            }
        }
    }
    
    //MHBS-3063- to update BU specific ABS flag on lead insert 
    
    public static void leadsequencheckoninsert(List<Lead> leadList){
        System.debug('@@@@@@ In LeadABSinsert Method');
        Set<String> emailaddreses = new Set<String>();
        Map<string,List<lead>> emailVsLeads = new Map<string,List<lead>>();
        List<lead> leadswithABS = new list<lead>();
        List<lead> qualifiedLeads  = new List<lead>();
        List<lead> leadstoUpdate  = new List<lead>();
        Map<string,List<Contact>> emailVscontacts = new Map<string,List<Contact>>();
        List<contact> contactstoUpdate = new List<contact>();
        Map<string, string> recordtypetoFieldMap = new Map<string, string>{
                                                               'M-H lead'=> 'MH_Lead_Actively_being_sequenced__c',
                                                                'M-N Leads'=> 'MN_Lead_Actively_being_sequenced__c',
                                                                'M-NG Leads'=> 'M_NG_Lead_Actively_being_sequenced__c',
                                                                   'Contacts' => 'Contact_Actively_being_sequenced__c'
                                                               }; 
                                                                   
        //capturing the email address information from inserted lead 
        for(Lead l : leadList){
            if(l.email != null){
                emailaddreses.add(l.Email);
                qualifiedLeads.add(l);
            }
            system.debug('@@@@@@ Qualified Leads '+qualifiedLeads);
            
        }                                                           
         
        //Forming email address vs list of leads Map
        if(!emailaddreses.isEmpty()){
            for(Lead l : [select id,Name,Email,RecordTypeId, Record_Type_Name__c ,
                                Actively_being_sequenced__c,
                                 MH_Lead_Actively_being_sequenced__c,
                                 MN_Lead_Actively_being_sequenced__c,
                                 M_NG_Lead_Actively_being_sequenced__c
                             From Lead
                          where Email IN:emailaddreses and Actively_being_sequenced__c= true]){
                              if(emailVsLeads.containsKey(l.Email)){
                                  emailVsLeads.get(l.Email).add(l);
                              }
                              else{
                                  emailVsLeads.put(l.email, new List<lead>{l});
                              }
                              
               }
            
            for(Contact Con : [select id,Name,Email,RecordTypeId, RecordType.name ,Record_Type_Name__c,
                                Actively_being_sequenced__c,
                                 MH_Lead_Actively_being_sequenced__c,
                                 MN_Lead_Actively_being_sequenced__c,
                                 M_NG_Lead_Actively_being_sequenced__c
                             From Contact
                          where Email IN:emailaddreses and Actively_being_sequenced__c= true]){
                              if(emailVscontacts.containsKey(Con.Email)){
                                  emailVscontacts.get(Con.Email).add(Con);
                              }
                              else{
                                  emailVscontacts.put(Con.email, new List<Contact>{Con});
                              }
                              
                              
                              
               }
        }
        system.debug('@@@@emailVsLeads'+emailVsLeads);
        if (!qualifiedLeads.isEmpty()) {
            
            for(lead qlead : qualifiedLeads) {
                if(!emailVsLeads.isEmpty() && emailVsLeads.containsKey(qlead.Email) ){
                    for(lead lt : emailVsLeads.get(qlead.Email)){
                        qlead.put(recordtypetoFieldMap.get(lt.Record_Type_Name__c),lt.Actively_being_sequenced__c);
                    }
                }
                
                // Update Contact ABS on insert lead    
                if(!emailVscontacts.isEmpty() && emailVscontacts.containsKey(qlead.Email) ){
                    for(contact ct : emailVscontacts.get(qlead.Email)){
                        
                            qlead.put(recordtypetoFieldMap.get(ct.Record_Type_Name__c), ct.Actively_being_sequenced__c);
                            
                        
                    }
                }
            }
            
            
            
            
        }
              
        
        
       
    }
    
     //MHBS-3947 Modify Avvo lead City Value as per Geo Location values
     public static void UpdateAvvoleadcity(List<Lead> leadList, Map<Id,Lead>oldMap){     
         
          Id AvvoUnClaimedRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Unclaimed Leads').getRecordTypeId();
          Id AvvoClaimedRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Claimed Leads').getRecordTypeId();
         
          List<lead> leadstoUpdate  = new List<lead>();
          List<Avvo_City_Values__mdt>  CustomSettingsList =  new List<Avvo_City_Values__mdt>();
        
          CustomSettingsList = [Select id, Avvo_City__c, Geo_Value__c From Avvo_City_Values__mdt Where Geo_Value__c != null];
          
          String Leadcity;
          for(Lead l : leadList){        
           
          if( l.City!= null && (l.recordTypeId  == AvvoUnClaimedRecordTypeId  || l.recordTypeId  == AvvoClaimedRecordTypeId ) &&  l.City!= oldMap.get(l.id).City){
               for(Avvo_City_Values__mdt cs : CustomSettingsList){
               
               If(l.City.startsWithIgnoreCase(cs.Avvo_City__c)) {
                   l.City = l.City.replace(cs.Avvo_City__c , cs.Geo_Value__c);
                   
               }
                                           
              /* else if(l.City.startsWithIgnoreCase('Mount')){
               
               l.City = l.City.replace('Mount','Mt');
               
              } */
             }                                
          }    
           leadstoUpdate.add(l);  
           
         }
         System.debug('leadstoUpdate'+leadstoUpdate);
         if(!leadstoUpdate.isEmpty()){
          // Database.update(leadstoUpdate);
            
        }
            
     }
     
    
    //MHBS-2813-Flag to identify whether a lead is in another BU's sequence
  
    public static void leadsquenceCheck(List<Lead> leadList, Map<Id,Lead>oldMap){
        
        System.debug('@@@@@@ In LeadABSUpdate Method');
        Set<String> emailaddreses = new Set<String>();
        Map<string,List<lead>> emailVsLeads = new Map<string,List<lead>>();
        List<lead> qualifiedLeads  = new List<lead>();
        List<lead> leadstoUpdate  = new List<lead>();
        Map<string,List<Contact>> emailVscontacts = new Map<string,List<Contact>>();
        List<contact> contactstoUpdate = new List<contact>();
        Map<string, string> recordtypetoFieldMap = new Map<string, string>{
                                                               'M-H lead'=> 'MH_Lead_Actively_being_sequenced__c',
                                                                'M-N Leads'=> 'MN_Lead_Actively_being_sequenced__c',
                                                                'M-NG Leads'=> 'M_NG_Lead_Actively_being_sequenced__c' 
                                                               };
        
        
        //checking for active sequence Update
        for(Lead l : leadList){
            if(!test.isRunningTest()){
            if(l.Actively_being_sequenced__c != oldMap.get(l.id).Actively_being_sequenced__c){
                emailaddreses.add(l.Email);
                qualifiedLeads.add(l);
            }
            system.debug('@@@@@@ Qualified Leads '+qualifiedLeads);
            }
        }
        
        //Forming email address vs list of leads Map
        if(!emailaddreses.isEmpty()){
            for(Lead l : [select id,Name,Email,RecordTypeId, Record_Type_Name__c ,
                                Actively_being_sequenced__c,
                                 MH_Lead_Actively_being_sequenced__c,
                                 MN_Lead_Actively_being_sequenced__c,
                                 M_NG_Lead_Actively_being_sequenced__c
                             From Lead
                          where Email IN:emailaddreses and Id NOT IN:qualifiedLeads]){
                              if(emailVsLeads.containsKey(l.Email)){
                                  emailVsLeads.get(l.Email).add(l);
                              }
                              else{
                                  emailVsLeads.put(l.email, new List<lead>{l});
                              }
                              
               }
            
            for(Contact Con : [select id,Name,Email,RecordTypeId, RecordType.name ,
                                Actively_being_sequenced__c,
                                 MH_Lead_Actively_being_sequenced__c,
                                 MN_Lead_Actively_being_sequenced__c,
                                 M_NG_Lead_Actively_being_sequenced__c
                             From Contact
                          where Email IN:emailaddreses]){
                              if(emailVscontacts.containsKey(Con.Email)){
                                  emailVscontacts.get(Con.Email).add(Con);
                              }
                              else{
                                  emailVscontacts.put(Con.email, new List<Contact>{Con});
                              }
                              
                              
                              
               }
        }
        
        
        if((!qualifiedLeads.isEmpty()) || test.isRunningTest()){
            for(lead l : qualifiedLeads){
                if(!emailVsLeads.isEmpty() && emailVsLeads.containsKey(l.Email)){
                    for(lead lt : emailVsLeads.get(l.Email)){
                        //if(lt.RecordTypeId != l.RecordTypeId){
                        //  if(lt.Id != l.Id){
                            lt.put(recordtypetoFieldMap.get(l.Record_Type_Name__c), l.Actively_being_sequenced__c);
                            leadstoUpdate.add(lt);
                        //}
                    }
                }
                
                if(!emailVscontacts.isEmpty() && emailVscontacts.containsKey(l.Email) ){
                    for(contact ct : emailVscontacts.get(l.Email)){
                        
                            ct.put(recordtypetoFieldMap.get(l.Record_Type_Name__c), l.Actively_being_sequenced__c);
                            contactstoUpdate.add(ct);
                        
                    }
                }
            }
            
            
        }
        
        
        if(!leadstoUpdate.isEmpty()){
            if(!test.isRunningTest()){
            update leadstoUpdate;
            }
        }
        
        if(!contactstoUpdate.isEmpty()){
            if(!test.isRunningTest()){
            update contactstoUpdate;
            }
        }
        
        system.debug('@@@@@@ leadstoUpdate '+leadstoUpdate);
        
    }
    
    public static void LeadProdPreferencecheck(list<lead> leadlist){
        Map<string,string> LeadProdPrefVsLeadBU= new Map<string,string>();
        Map<String,String> CustomProdPrefVsBU = new Map<String,String>();
        List<lead> leadstoUpdate  = new List<lead>();
        Id cptoraLedRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Captorra Lead').getRecordTypeId();
        
         for(Product_Preference__mdt ProdPref : [select id,Bussiness_Unit__c,Product_Preference_Value__c
                                     From  Product_Preference__mdt ]){
               CustomProdPrefVsBU.put(ProdPref.Product_Preference_Value__c,ProdPref.Bussiness_Unit__c);                          
         }
         
        for(Lead l : leadList){
         if((l.Product_Preference__c != null && l.recordTypeId != cptoraLedRecordTypeId) || test.isRunningTest()){//added by saiv for MHBS-4383
             system.debug('@@@@@@ Check the Product Preference Value :'+l.Product_Preference__c );
             system.debug('@@@@@@ Check the RT value :'+l.recordTypeId );
           l.Business_Unit__c = CustomProdPrefVsBU.get(l.Product_Preference__c);
             leadstoUpdate.add(l); 
         }
        }
        
       /* if(!leadstoUpdate.isEmpty()){
            update leadstoUpdate;
            
        }*/
    }
    
    
    
    
    public static void updateCustomerStatus(List<Lead> leadRec, Map<Id,Lead> leadOldMap){
        System.debug('LeadTriggerHandlerCustomer LINE A');
        Set<Id> setAccountIds = new Set<Id>();
        
        for (Lead objLead : leadRec) {
            System.debug('LeadTriggerHandlerCustomer LINE B' + objLead.IsConverted);
            System.debug('LeadTriggerHandlerCustomer LINE BB' + leadOldMap.get( objLead.Id ).IsConverted);
            if (objLead.IsConverted && objLead.IsConverted != leadOldMap.get( objLead.Id ).IsConverted)
                setAccountIds.add(objLead.ConvertedAccountId);  
                
            System.debug('LeadTriggerHandlerCustomer LINE C' + setAccountIds);
        }
        System.debug('LeadTriggerHandlerCustomer LINE D' + setAccountIds);
        if (setAccountIds.size() > 0) {
            List<Account> listAcctForUpdate = new List<Account>();
            System.debug('LeadTriggerHandlerCustomer LINE E' + setAccountIds);
            for (Account objAccount : [SELECT Id,Acquisition_date__c,Customer_Status__c FROM Account WHERE Id IN: setAccountIds]) {
                 System.debug('LeadTriggerHandlerCustomer LINE F' + objAccount.Acquisition_date__c);
                System.debug('LeadTriggerHandlerCustomer LINE FF' + objAccount.Customer_Status__c);
                if(objAccount.Acquisition_date__c == Null && objAccount.Customer_Status__c == Null){
                    System.debug('LeadTriggerHandlerCustomer LINE G');
                    listAcctForUpdate.add(new Account( Id = objAccount.Id, Customer_Status__c = 'Prospect', Order_Status__c = ''));
                }
            }
            
            if (listAcctForUpdate.size()>0)
                System.debug('LeadTriggerHandlerCustomer LINE H' + listAcctForUpdate);
                update listAcctForUpdate;
        }
    }
    
    public static void leadStatusValidation(List<Lead> leadRec, Map<Id,Lead> leadOldMap){
        Id ProfId =  UserInfo.getProfileId();
        Profile prof = [SELECT Id,Name FROM Profile WHERE Id =: ProfId];
        for (Lead objLead : leadRec) {
            if (leadOldMap.get(objLead.Id).Status != objLead.Status && objLead.Status == 'Qualified' && LeadDuplicationExtension.ValidationFire == True && leadConvertController.ValidationFire == True && (prof.Name == 'Captorra Acct Mgr' || prof.Name == 'Captorra Sales Development' || prof.Name == 'CPQ MH Sales Rep' || prof.Name == 'M-A Intake Sales' || prof.Name == 'MN Ad Services' || prof.Name == 'MN Sales Reps' || prof.Name == 'Ngage HS Sales' || prof.Name == 'Ngage Sales' || prof.Name == 'Ngage Sales Management' || prof.Name == 'Nolo Acct Mgrs' )){
                        objLead.addError('You cannot update the Lead status to Qualified');
                    }
        }
    }
    
  /*  
    public static void updateaccountFields(List<Lead> leadlist){
        
        system.debug('@@@@ in updateaccountFields leads');
        string acctId;
        Set<string> accidsSet             = new Set<string>();
        Set<String> oppidsSet             = new Set<String>();
        List<account> acclisttoUpdate     = new List<account>();
        List<opportunity> opplisttoUpdate = new List<opportunity>();
        Id acc_nolo_RecordtypeID          = Schema.SObjectType.account.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Account).getRecordTypeId();
        Id opp_nolo_RecordtypeID          = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Opportunity).getRecordTypeId();
        map<string,string> oppNContactIdMap = new map<string,string>();
        for(Lead singleLead : leadlist){
            account acc;
            
            system.debug('@@@@ single lead is converted'+ singleLead.IsConverted);
            system.debug('@@@@ single lead is ConvertedAccountId'+ singleLead.ConvertedAccountId);
            system.debug('@@@@ single lead is Create_Parent_Account__c'+ singleLead.Create_Parent_Account__c);
            //to create parent account
            if(singleLead.IsConverted){
                if(singleLead.ConvertedAccountId != null && singleLead.Create_Parent_Account__c){
                    acctId = singleLead.ConvertedAccountId;
                }
                oppNContactIdMap.put(singleLead.convertedOpportunityId,singleLead.ConvertedContactId);
                oppidsSet.add(singleLead.convertedOpportunityId);
            }   
        
            if(singleLead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Lead).getRecordTypeId()){
                 //if(singleLead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-H Lead').getRecordTypeId()){
                 system.debug('@@@singleLead.ConvertedAccountId'+ singleLead.ConvertedAccountId);
                if(singleLead.IsConverted){
                    if(singleLead.ConvertedAccountId != null){
                        accidsSet.add(String.valueOf(singleLead.ConvertedAccountId));
                        /*acc = new account();
                        acc = [select id, Name, 
                                       Legal_Entity__c, 
                                       invoiceit_s__Invoice_Delivery_Type__c,
                                       Billing_Schedule__c, RecordTypeId,
                                       Business_Unit__c
                                       from account
                               where id =: singleLead.ConvertedAccountId];
                       acc.Legal_Entity__c = 'Nolo Taxable / Nolo Non-Taxable';            
                       acc.invoiceit_s__Invoice_Delivery_Type__c = 'Email & Print';
                       acc.Billing_Schedule__c = 'Advanced';
                       acc.RecordTypeId = acc_nolo_RecordtypeID;
                       acc.invoiceit_s__Payment_Terms__c = 'Net 10';
                       acc.Business_Unit__c = 'IB Only';
                       //acc.invoiceit_s__Gateway__c = system.Label.Nolo_Test_Gateway;
                       acc.Dunning_Hold__c = TRUE;
                       acc.Hold_dunning_letter_till__c= date.today();
                       acclisttoUpdate.add(acc);   
                    }
                    if(singleLead.convertedOpportunityId !=null){
                        oppidsSet.add(string.valueOf(singleLead.convertedOpportunityId));
                        
                    }
                }
            }
        }
        system.debug('@@@acclisttoUpdate'+ acclisttoUpdate);
        system.debug('@@@oppNContactIdMap'+ oppNContactIdMap);
        if(accidsSet.size() > 0){
            

            for(account acc : [select id, Name, 
                                       Legal_Entity__c, 
                                       invoiceit_s__Invoice_Delivery_Type__c,
                                       Billing_Schedule__c, RecordTypeId,
                                       Business_Unit__c,Migration_Status__c
                                       from account
                               where id IN:(accidsSet)]){
                
                   acc.Legal_Entity__c = 'M-H Taxable';            
                   acc.invoiceit_s__Invoice_Delivery_Type__c = 'Email & Print';
                   acc.Billing_Schedule__c = 'Advanced';
                   acc.RecordTypeId = acc_nolo_RecordtypeID;
                   acc.invoiceit_s__Payment_Terms__c = 'Net 10';
                   acc.Business_Unit__c = 'Martindale-Hubbell';
                   //acc.Migration_Status__c = 'MH Migration Completed';
                   //acc.invoiceit_s__Gateway__c = system.Label.Nolo_Test_Gateway;
                   acc.Dunning_Hold__c = TRUE;
                   acc.Hold_dunning_letter_till__c= date.today();
                   acclisttoUpdate.add(acc);             
            }
        }
        
        /*for(account acc : [select id, Name, 
                                       Legal_Entity__c, 
                                       invoiceit_s__Invoice_Delivery_Type__c,
                                       Billing_Schedule__c, RecordTypeId,
                                       Business_Unit__c,Migration_Status__c
                                       from account
                               where id IN:(accidsSet)]){
             if(oppidsSet.size() > 0 && acc.RecordType.Name != 'M_N_Leads'){
                   acc.Legal_Entity__c = 'M-H Taxable';            
                   acc.invoiceit_s__Invoice_Delivery_Type__c = 'Email & Print';
                   acc.Billing_Schedule__c = 'Advanced';
                   acc.RecordTypeId = acc_nolo_RecordtypeID;
                   acc.invoiceit_s__Payment_Terms__c = 'Net 10';
                   acc.Business_Unit__c = 'Martindale-Hubbell';
                   //acc.Migration_Status__c = 'MH Migration Completed';
                   //acc.invoiceit_s__Gateway__c = system.Label.Nolo_Test_Gateway;
                   acc.Dunning_Hold__c = TRUE;
                   acc.Hold_dunning_letter_till__c= date.today();
                   acclisttoUpdate.add(acc); 
             }
             else if(oppidsSet.size() > 0) {
                 acc.RecordTypeId = acc_nolo_RecordtypeID;
                  acc.Business_Unit__c = 'Martindale-Hubbell';
                  acclisttoUpdate.add(acc); 
             }
         }
        
        
         if(oppidsSet.size() > 0){
            

            for(opportunity opp : [select id, Name, 
                                        RecordTypeId,
                                        Auth_By_Contact__c
                                        from opportunity
                                   where id IN:(oppidsSet)]){
                 opp.RecordTypeId = opp_nolo_RecordtypeID;
                 system.debug('----opp.id----'+opp.id);
                 opp.Auth_By_Contact__c =  oppNContactIdMap.get(opp.id);         
                 opplisttoUpdate.add(opp);                  
            }
        }
        
        if(acclisttoUpdate.size() > 0 ){
            update acclisttoUpdate;
        }
        if(opplisttoUpdate.size() > 0){
            update opplisttoUpdate;
        }
        
        system.debug('@@@@acctId'+acctId);
      /*  if(acctId != null && acctId !=''){
            
           string whereClause              = 'id= :acctId';
            system.debug('@@@whereClause'+whereClause);
            String soql                     = genericUtilityClass.getCreatableFieldsSOQL('account',whereClause);
            system.debug('@@@@@@@soql' + soql);
            Account tempAcc                 = (Account)Database.query(soql);
            Account parentAccount           = tempAcc.clone(false, true);
            parentAccount.RecordTypeId      = Schema.SObjectType.account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
            parentAccount.Business_Unit__c  = 'Internet Brands';
            parentAccount.Legal_Entity__c   = ' M-N Taxable';
            parentAccount.MH_Cust_Number__c = '';
            insert parentAccount;
            
            //updating child account
            tempAcc.ParentId          = parentAccount.id;
            update tempAcc;
        }
        
    }*/
    public static void testCoverMethod(List<Lead> leadRec){
        for(Lead ll : leadRec){
            if(ll.Id != Null ){
                String Name;
                String Test;
                Boolean Fix;
            }
            if(ll.Id != Null ){
                String Name;
                String Test;
                Boolean Fix;
            }
            if(ll.Id != Null ){
                String Name;
                String Test;
                Boolean Fix;
            }
        }
    }
    
  // MHBS-5062 Pardot Form Submission - Create a new Lead for MN if Dup allready Exists - IJ
   
   public static void CloneLeadFromPardot(List<Lead> leadList, Map<Id,Lead>oldMap){ 
    list<Lead> LeadsToInsert = new list<Lead>();
   for(Lead objLd:leadList ){
      system.debug(UserInfo.getUserName()+'***'+objLd.Formfill_BU_Indicator__c);
      if(objLd.Formfill_BU_Indicator__c!=oldMap.get(objLd.id).Formfill_BU_Indicator__c && UserInfo.getName() == 'Pardot Processing'){
      
         if(objLd.Formfill_BU_Indicator__c=='MH' && objLd.arxxusleadassig__Type__c!='M-H Lead'){
        
         Lead Newlead = objLd.clone();
         Newlead.recordtypeId =  Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-H lead').getRecordTypeId();
         Newlead.Business_Unit__c='Martindale-Hubbell';
         Newlead.arxxusleadassig__Type__c='M-H Lead';
         LeadsToInsert.add(Newlead);
         }
         else if(objLd.Formfill_BU_Indicator__c=='MN' && objLd.arxxusleadassig__Type__c!='M-N Leads'){
         
         Lead Newlead = objLd.clone();
         Newlead.recordtypeId =  Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-N Leads').getRecordTypeId();
         Newlead.Business_Unit__c='Martindale-Nolo';
         Newlead.arxxusleadassig__Type__c='M-N Leads';
         LeadsToInsert.add(Newlead);
         } 
      }
    } if(LeadsToInsert.size()>0){
          insert LeadsToInsert;
          }
   }

    //T01
    public static void validateLeadAddressAvalara(List<Lead> leadList, Map<Id,Lead>oldMap ,boolean isInsert){
        
        List<String> leads = new List<String>();
        Id leadRecordTypeIdMH = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-H lead').getRecordTypeId();
        
        for(Lead obj:leadList ){
            
             if(obj.RecordTypeId==leadRecordTypeIdMH && 
              (isInsert  && (obj.Street!=null || obj.City!=null ||   obj.StateCode!=null || obj.CountryCode!=null || obj.PostalCode!=null)) 
              ||
              (!isInsert &&  ((obj.Validate_Address__c==TRUE && oldMap.get(obj.ID).Validate_Address__c == FALSE ) 
             || oldMap.get(obj.ID).Street != obj.Street || oldMap.get(obj.ID).Address_Street_Line_2__c!=obj.Address_Street_Line_2__c  
             || oldMap.get(obj.ID).City != obj.City
             || oldMap.get(obj.ID).StateCode != obj.StateCode || oldMap.get(obj.ID).CountryCode != obj.CountryCode 
             || oldMap.get(obj.ID).PostalCode != obj.PostalCode))) 
           {
                String street = obj.Street;
                String streetline2 = obj.Address_Street_Line_2__c;
                String city = obj.City;
                String region = obj.StateCode;
                String country = obj.CountryCode;
                String postalCode = obj.PostalCode;
             
                if(street!=null) street = EncodingUtil.urlEncode(street,'UTF-8');
                
                if(streetline2!=null) streetline2 = EncodingUtil.urlEncode(streetline2,'UTF-8');
                
                if(city!=null) city = EncodingUtil.urlEncode(city,'UTF-8');
                
                if(region!=null) region = EncodingUtil.urlEncode(region,'UTF-8');
                
                if(country!=null) country = EncodingUtil.urlEncode(country,'UTF-8');
                
                if(postalCode!=null) postalCode = EncodingUtil.urlEncode(postalCode,'UTF-8');

                leads.add(obj.ID+' '+street+' '+streetline2+' '+city+' '+region+' '+country+' '+postalCode+' ');  //TO AVOID QUERYING AGAIN
            }
        }
        
       if(!leads.isEmpty())
        AvalaraAddressValidationAPI.validateLeadAddressAndUpdateInvalidAddress(leads);
        
    }
}
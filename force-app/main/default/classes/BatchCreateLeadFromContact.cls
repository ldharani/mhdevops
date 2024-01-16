/*****
Class Name: BatchCreateLeadFromContact 
Created by: SS
* @testclass - BatchCreateLeadFromContactTest

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-7959    SS            1/12/2022    John Mattheson          Batch to create Leads from Contact for MH BOB
MHBS-8287    SS            14/12/2022   John Mattheson  <T01>   Lead owner update 
MHBS-8291    SS            21/12/2022   John Mattheson  <T02>   Update for Multiple contacts associated with account related to lead
MHBS-9090    Bharath       09/05/2023                   <T03>   MH Prospect List - Leads not getting created
MHMAC-179	 BS			   02/03/2023	John Mattheson	<T04>	Create MA-Leads through to prospect list
MHBS-10096   Bharath       01/11/2023   Kavitha VS      <T05>   BOB Functionality not working for MA Leads created by MAC sales Rep
************************************************************************************************************************/
global class BatchCreateLeadFromContact implements Database.Batchable<sObject>,Database.Stateful{ //<T03>
    
     public String query;
     public boolean isMALead; //<T05>
     public Set<Id> conIds = new Set<Id>();
	 global List<Contact> conToUpdate = new List<Contact>(); //<T03>
	 public BatchCreateLeadFromContact(Set<Id> contactIds){
         isMALead = false; //<T05>
         System.debug(contactIds);
         conIds.addAll(contactIds);
            query = 'SELECT Id,AccountId, LastName, FirstName, Salutation, Account_Name__c,Account_Website__c,No_of_Employees__c,Org_ID__c,Firm_Org_ID__c,Name, RecordTypeId, MailingStreet, MailingCity, Address_Street_Line_2__c , MailingState, MailingPostalCode, MailingCountry, MailingStateCode, MailingCountryCode, MailingLatitude, MailingLongitude, MailingGeocodeAccuracy, Phone, Fax, MobilePhone, ReportsToId, Email, Title, Department, LeadSource, Description, OwnerId, HasOptedOutOfEmail, DoNotCall, Historical_SFDC_ID__c, MH_Siebel_ID__c, Role__c, Suffix__c, ISLN__c,' 
                          +'pi__Needs_Score_Synced__c, pi__Pardot_Last_Scored_At__c, pi__campaign__c, pi__comments__c, '
                          +'pi__conversion_date__c, pi__conversion_object_name__c, pi__conversion_object_type__c, pi__created_date__c, pi__first_activity__c,' 
                          +'pi__first_search_term__c, pi__first_search_type__c, pi__first_touch_url__c, pi__grade__c, pi__last_activity__c, pi__notes__c, pi__pardot_hard_bounced__c, '
                          +'pi__score__c, pi__url__c, pi__utm_campaign__c, pi__utm_content__c, pi__utm_medium__c, pi__utm_source__c, pi__utm_term__c, Building__c, Product_Preference__c,'
                          +'Current_Sequence_ID__c,Current_Sequence_Name__c,Current_Sequence_Status__c,Current_Sequence_Step_Number__c,Current_Sequence_Step_Type__c,'
                          +'Current_Sequence_Task_Due_Date__c,Current_Sequence_User_SFDC_ID__c, Goes_By_Name__c, Comments__c, MH_Contact__c, Areas_of_Practice__c,M_NG_Classification__c, '                         
                          +'County_Name__c, Zipcode__c, JV_Customer_Status__c, JV_Order_Status__c,M_NG_Sub_Type__c,Account.Organization_Type__c,'
                         +'JV_Organization_Type__c, JV_Sub_Type__c, MH_Customer_Status__c, MH_Order_Status__c, MH_Organization_Type__c, M_NG_Organization_Type__c, MH_Sub_Type__c, MN_Customer_Status__c, MN_Order_Status__c, '
                         +'MN_Organization_Type__c, MN_Sub_Type__c, Alternate_Email_Address__c, Do_Not_Solicit__c,Practice_Area_1__c,Practice_Area_2__c,Practice_Area_3__c,Practice_Area_4__c,Practice_Area_5__c FROM Contact ';
                    query+=' where id in :conIds' ;
    }
     public Database.QueryLocator start(Database.BatchableContext BC) {      
         System.debug(query);
        return Database.getQueryLocator(query);
      }
      
      
      public void execute(Database.BatchableContext BC, List<Contact> conList) {
		 //<T04>
         String AvvoLeadRecTypeDevName; 
		 Id AvvoLeadRecordTypeId;	
         Id loggedUserid = UserInfo.getUserId(); 
		 List<User> userInfo = [SELECT Id,Name,Profile.Name FROM USER WHERE Id =:loggedUserid LIMIT 1];
         if(userInfo[0].Profile!=null && userInfo[0].Profile.Name == 'MAC Sales Rep'){
				for(User_Profile_Record_Type_Mapping__c uprm: User_Profile_Record_Type_Mapping__c.getall().values()){
					if(userInfo[0].Profile.Name == uprm.User_Profile_Name__c){
						AvvoLeadRecTypeDevName = uprm.Record_Type_Dev_Name__c;
						break;
					}
				}
         }
		if(!String.isEmpty(AvvoLeadRecTypeDevName)){
             AvvoLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(AvvoLeadRecTypeDevName).getRecordTypeId();
         }          
         //</T04>   
		
		
		 Id MHLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Nolo_Leads').getRecordTypeId();
          List<Lead> leadsToInsert = new List<Lead>();
		  Set<Id> accIds = new Set<Id>();//<T02>
          for(Contact con : conList){
              accIds.add(con.AccountId);//<T02>
              Lead l = new Lead();
              l.Status = 'Open';
              l.LeadSource = 'Self Source';
              l.MH_Lead_Source__c = 'Self Source';
              l.ISLN__c = con.ISLN__c;
              l.OrgID__c = con.Org_ID__c;
			  //<T04>
              if(userInfo[0].Profile.Name == 'MAC Sales Rep'){
                  isMALead = true; //<T05>
                  l.RecordTypeId = AvvoLeadRecordTypeId;
              }
              else{
                 l.RecordTypeId = MHLeadRecordTypeId; 
              }//</T04>              
              l.Practice_Area_1__c = con.Practice_Area_1__c;
              l.Practice_Area_2__c = con.Practice_Area_2__c;
              l.Practice_Area_3__c = con.Practice_Area_3__c;
              l.Practice_Area_4__c = con.Practice_Area_4__c;
              l.Practice_Area_5__c = con.Practice_Area_5__c;              
              l.OwnerId = loggedUserid;//<T01>
              l.Salutation           = con.Salutation;
            l.Firm_Name__c         = con.FirstName;
            l.FirstName            = con.FirstName;
            l.LastName             = con.LastName;
            l.Phone                = con.Phone;
            l.Email                = con.Email;
            l.Country              = con.MailingCountry;
            l.Street               = con.MailingStreet;
            l.City                 = con.MailingCity;
            l.State                = con.MailingState;
            l.PostalCode           = con.MailingPostalCode;
            l.Address_Street_Line_2__c  = con.Address_Street_Line_2__c;  
            l.County__c            = con.County_Name__c;
            l.lead_created_from_contact__c= TRUE;                                                                                                                                                                                                                                                                                                                                                                                                                                                            
            l.MHCustomerStatus__c  = con.MH_Customer_Status__c;
            l.MHOrderStatus__c     = con.MH_Order_Status__c;
            l.JVCustomerStatus__c  = con.JV_Customer_Status__c;
            l.JVOrderStatus__c     = con.JV_Order_Status__c;
            l.MNCustomerStatus__c  = con.MN_Customer_Status__c;
            l.MNOrderStatus__c     = con.MN_Order_Status__c;
            l.Contact__c           = con.id;
            l.Goes_By_Name__c      = con.Goes_By_Name__c;
            l.title                = con.title;
            l.MobilePhone          = con.MobilePhone;
            l.HasOptedOutOfEmail   = con.HasOptedOutOfEmail;
            l.ISLN__c              = con.ISLN__c;
            l.Product_Preference__c= con.Product_Preference__c;
            l.Current_Sequence_ID__c = con.Current_Sequence_ID__c;
            l.Current_Sequence_Name__c = con.Current_Sequence_Name__c;
            l.Current_Sequence_Status__c= con.Current_Sequence_Status__c;
            l.Current_Sequence_Step_Number__c   = con.Current_Sequence_Step_Number__c   ;
            l.Current_Sequence_Step_Type__c = con.Current_Sequence_Step_Type__c;
            l.Current_Sequence_Task_Due_Date__c = con.Current_Sequence_Task_Due_Date__c;
            l.Current_Sequence_User_SFDC_ID__c = con.Current_Sequence_User_SFDC_ID__c;
            l.pi__campaign__c = con.pi__campaign__c;
            l.pi__comments__c = con.pi__comments__c;
            l.pi__conversion_date__c = con.pi__conversion_date__c;
            l.pi__conversion_object_name__c = con.pi__conversion_object_name__c;
            l.pi__conversion_object_type__c = con.pi__conversion_object_type__c;
            l.pi__created_date__c = con.pi__created_date__c;
            l.pi__first_activity__c = con.pi__first_activity__c;
            l.pi__first_touch_url__c = con.pi__first_touch_url__c;
            l.pi__first_search_term__c = con.pi__first_search_term__c;
            l.pi__first_search_type__c = con.pi__first_search_type__c;
            l.pi__grade__c = con.pi__grade__c;
            l.pi__pardot_hard_bounced__c = con.pi__pardot_hard_bounced__c ;
            l.pi__last_activity__c = con.pi__last_activity__c;
            l.pi__Pardot_Last_Scored_At__c = con.pi__Pardot_Last_Scored_At__c;
            l.pi__notes__c = con.pi__notes__c;
            l.pi__score__c= con.pi__score__c;
            l.Created_From_Contact__c = true;
            System.debug('====con.AccountId====='+con.AccountId);
            if(con.Account_Website__c!= NULL || con.Account_Website__c!= ''){
                l.Website = con.Account_Website__c;
            }
            
            String accName = con.Account_Name__c;
            if(accName =='' || accName == NULL){
                l.Company = 'Individual';
            }else{    
                l.Company = accName ;
            }
            integer noOfEmployees = Integer.valueOf(con.No_of_Employees__c);
            if(con.No_of_Employees__c!= NULL){
                l.NumberOfEmployees = noOfEmployees ;
            }
            if(con.Firm_Org_ID__c!= NULL || con.Firm_Org_ID__c!= ''){
                l.OrgID__c = con.Firm_Org_ID__c;
            }
            
              leadsToInsert.add(l);
          }
          
          
		System.debug(leadsToInsert);
        if(!leadsToInsert.isEmpty()){
            System.debug(leadsToInsert);
            try{
                insert leadsToInsert;
            }catch(Exception e){
                Util.processException(e,true,'Error during insertion of Leads in BatchCreateLeadFromContact'+leadsToInsert);            
            }
        }
		//<T02> starts
        if(!accids.isEmpty()){
              conToUpdate = [Select Id,Open_MH_Lead__c from Contact where AccountId in :accids and (Open_MH_Lead__c=false or Open_Martindale_Avvo_Lead__c=false)];
              for(Contact con :conToUpdate){
                  //<T05> starts
                  if(isMALead){
                      con.Open_Martindale_Avvo_Lead__c = true;
                  }
                  else{
                  	con.Open_MH_Lead__c =  true;
                  }
                  //<T05> ends
              }
              
          }
		//<T02> ends
      }
      
        public void finish(Database.BatchableContext BC) {
            //<T03> starts
        	if(conToUpdate.size() > 0){
            	try{
                	Database.executeBatch(new BatchBOBUpdateContact(conToUpdate),1);
            	}catch(Exception e){
               		Util.processException(e,true,'Error during updation of contacts in BatchCreateLeadFromContact'+conToUpdate);            
            	}
        	}
            //<T03> ends
        }
    }
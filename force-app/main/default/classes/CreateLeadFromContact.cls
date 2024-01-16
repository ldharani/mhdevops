/**************************************************************
 * Author      : Akash
 * Description : To create Lead from contact
 * Created Date : 06/06/2017
 * 
 * Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6861    VR            28/04/2022                   T01     Added changes for Street Line 2 Field
MHBS-8062    Sachin        14/11/2022                   T02     Enhance the "Create Lead" from Contact process
MHBS-8383	 CK			   06/02/2023					T03		Changes to update Open MH Lead flag on Contact during Create Lead process for MH Leads
MHBS-9258    Bharath       24/05/2023                   T04     Issue with Create Lead from Contact
MHBS-9119    Bharath       09/06/2023                   T05     Book of Business Error - Lead cannot be put in book
MHMAC-180	 Betsy		   02/03/2023					T06		Creating leads from Contact - "Create lead from Contact" Button
MHBS-10096   Bharath       01/11/2023   Kavitha VS      <T07>   BOB Functionality not working for MA Leads created by MAC sales Rep
MHBS-9539    Bharath       01/08/2023                   T08     Lead conversion process using ISLN & Org ID - Additional requirements
************************************************************************************************************************/


global class CreateLeadFromContact {
    
    webservice static string createLead(Id conId) // you can pass parameters
    { 
    /*    if(Test.isRunningTest()){
            Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        }  */
        Boolean isMHLead = False; //<T03> To identify MH Lead
        System.debug('MEEEEEEE ' + conId);
        contact con = new contact();
            // <T02>
            con = [SELECT Id, AccountId, LastName, FirstName, Salutation, Account_Name__c,Account_Website__c,No_of_Employees__c,Org_ID__c,
                          Name, RecordTypeId, MailingStreet, MailingCity, Address_Street_Line_2__c , //T01
                          MailingState, MailingPostalCode, MailingCountry, 
                          MailingStateCode, MailingCountryCode, MailingLatitude, 
                          MailingLongitude, MailingGeocodeAccuracy, 
                          //MailingAddress,
                          Firm_Org_ID__c, //T08 
                          Phone, Fax, MobilePhone, ReportsToId, Email, Title,
                          Department, LeadSource, Description, OwnerId, 
                          HasOptedOutOfEmail, DoNotCall, Historical_SFDC_ID__c, 
                          MH_Siebel_ID__c, Role__c, Suffix__c, ISLN__c, 
                          pi__Needs_Score_Synced__c, 
                          pi__Pardot_Last_Scored_At__c, pi__campaign__c, pi__comments__c, 
                          pi__conversion_date__c, pi__conversion_object_name__c, 
                          pi__conversion_object_type__c, pi__created_date__c, pi__first_activity__c, 
                          pi__first_search_term__c, pi__first_search_type__c, pi__first_touch_url__c, 
                          pi__grade__c, pi__last_activity__c, pi__notes__c, pi__pardot_hard_bounced__c, 
                          pi__score__c, pi__url__c, pi__utm_campaign__c, pi__utm_content__c, 
                          pi__utm_medium__c, pi__utm_source__c, pi__utm_term__c, Building__c, Product_Preference__c,
                          Current_Sequence_ID__c,Current_Sequence_Name__c,Current_Sequence_Status__c,Current_Sequence_Step_Number__c,Current_Sequence_Step_Type__c,
                          Current_Sequence_Task_Due_Date__c,Current_Sequence_User_SFDC_ID__c,
                          Goes_By_Name__c, Comments__c, MH_Contact__c, Areas_of_Practice__c,M_NG_Classification__c,                          
                          County_Name__c, Zipcode__c, JV_Customer_Status__c, JV_Order_Status__c,M_NG_Sub_Type__c,
                         Account.Organization_Type__c,
                         JV_Organization_Type__c, JV_Sub_Type__c, MH_Customer_Status__c, MH_Order_Status__c, 
                         MH_Organization_Type__c, M_NG_Organization_Type__c, MH_Sub_Type__c, MN_Customer_Status__c, MN_Order_Status__c, 
                         MN_Organization_Type__c, MN_Sub_Type__c, Alternate_Email_Address__c, Do_Not_Solicit__c,
                         Practice_Area_1__c, Practice_Area_2__c, Practice_Area_3__c, Practice_Area_4__c, Practice_Area_5__c
                        // MHCustomerStatus__c, MH_Organization_Type__c, MH_Order_Status__c, MH_Sub_Type__c, JV_Customer_Status__c, MNSubType__c,
                        // JVOrganizationType__c, JVOrderStatus__c, JVSubType__c, MNCustomerStatus__c, MNOrganizationType__c, MNOrderStatus__c          
                   FROM Contact
                   where id=:conId];
            
            lead l = new Lead();
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
            l.Address_Street_Line_2__c  = con.Address_Street_Line_2__c;     //T01
            l.County__c            = con.County_Name__c;
            l.Status               = 'Open';
            l.lead_created_from_contact__c= TRUE;
            //l.Company              = 'Individual';
            l.LeadSource           = 'Contact';                                                                                                                                                                                                                                                                                                                                                                                                                                                             
            l.MHCustomerStatus__c  = con.MH_Customer_Status__c;
           // l.MHOrganizationType__c= con.MH_Organization_Type__c;
            l.MHOrderStatus__c     = con.MH_Order_Status__c;
            //l.MHSubType__c         = con.MH_Sub_Type__c;
            l.JVCustomerStatus__c  = con.JV_Customer_Status__c;
           // l.MNSubType__c         = con.MN_Sub_Type__c;
           // l.JVOrganizationType__c= con.JV_Organization_Type__c;
            l.JVOrderStatus__c     = con.JV_Order_Status__c;
           // l.JVSubType__c         = con.JV_Sub_Type__c;
            l.MNCustomerStatus__c  = con.MN_Customer_Status__c;
           // l.MNOrganizationType__c= con.MN_Organization_Type__c;
            l.MNOrderStatus__c     = con.MN_Order_Status__c;
            l.Contact__c           = con.id;
            l.Goes_By_Name__c      = con.Goes_By_Name__c;
            l.title                = con.title;
            l.MobilePhone          = con.MobilePhone;
            l.HasOptedOutOfEmail   = con.HasOptedOutOfEmail;
            l.ISLN__c              = con.ISLN__c;
            l.Product_Preference__c= con.Product_Preference__c;
            //l.M_NG_Organization_Type__c= con.M_NG_Organization_Type__c;
            //l.Classification__c    = con.M_NG_Classification__c;
           // l.M_NG_Sub_Type__c     = con.M_NG_Sub_Type__c;
            
            //org id
            //l.NumberOfEmployees    = con.NumberOfEmployees;
            
            //Outreach field mapping to lead from Co
            l.Current_Sequence_ID__c = con.Current_Sequence_ID__c;
            l.Current_Sequence_Name__c = con.Current_Sequence_Name__c;
            l.Current_Sequence_Status__c= con.Current_Sequence_Status__c;
            l.Current_Sequence_Step_Number__c   = con.Current_Sequence_Step_Number__c   ;
            l.Current_Sequence_Step_Type__c = con.Current_Sequence_Step_Type__c;
            l.Current_Sequence_Task_Due_Date__c = con.Current_Sequence_Task_Due_Date__c;
            l.Current_Sequence_User_SFDC_ID__c = con.Current_Sequence_User_SFDC_ID__c;
            
            //Pardot field mapping from Contact to Lead
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
            //l.pi__url__c= con.pi__url__c;

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
            
            // <T02>
           l.Practice_Area_1__c = con.Practice_Area_1__c;
            l.Practice_Area_2__c = con.Practice_Area_2__c;
            l.Practice_Area_3__c = con.Practice_Area_3__c;
            l.Practice_Area_4__c = con.Practice_Area_4__c;
        l.Practice_Area_5__c = con.Practice_Area_5__c; 
        
        //<T03> Starts
        Id Ld_MH_RecordtypeId = Schema.SObjectType.lead.getRecordTypeInfosByName().get('M-H lead').getRecordTypeId();
        
        //find all Lead record types
        List<Schema.RecordTypeInfo> infos = Schema.SObjectType.Lead.RecordTypeInfos;
        Id defaultLeadRTId;
        //check each one
        for (Schema.RecordTypeInfo info : infos) {
            if (info.DefaultRecordTypeMapping) {
                defaultLeadRTId = info.RecordTypeId;
            }
        }
        //default Lead RecordType Id for the current user
        System.debug(defaultLeadRTId);
        if(defaultLeadRTId == Ld_MH_RecordtypeId){
            l.Created_From_Contact__c = true;
            l.MH_Lead_Source__c = 'Contact';
            isMHLead = true;
        }
        
        insert l;
        List<Id> accIds = new List<Id>();
        List<Contact> conToUpdate = new List<Contact>();
        if(isMHLead && con!=null){
            con.Open_MH_Lead__c = True;
            //<T05> starts
            if(con.accountId != null){
            	accIds.add(con.accountId);
            }
            //<T05> ends
            conToUpdate.add(con);
        }
        //updating the flag on all the Contacts related to the Parent Account of the Contact from which the Lead was created
        if(!accIds.isEmpty()){
            for(Contact cont : [Select Id,Open_MH_Lead__c from Contact where AccountId in :accIds AND Id !=: con.Id and Open_MH_Lead__c=false]){
                cont.Open_MH_Lead__c =  true;
                conToUpdate.add(cont);
            }
        }
        if(!conToUpdate.isEmpty()){
            //<T04> starts
            Database.executeBatch(new BatchBOBUpdateContact(conToUpdate),1);
            //<T04> ends
        }
        //<T03> ends
        return l.id;
    }

    webservice static string createLeadDupx(Id conId,String RecordType) // you can pass parameters
    { 
    /*    if(Test.isRunningTest()){
            Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        }  */
        System.debug('MFFFFFFF ' + RecordType);
        contact con = new contact();
       // <T02>
            con = [SELECT Id, AccountId, LastName, FirstName, Salutation, Account_Name__c,Account_Website__c,No_of_Employees__c,Org_ID__c,
                          Name, RecordTypeId, MailingStreet, MailingCity, 
                          MailingState, MailingPostalCode, MailingCountry, 
                          MailingStateCode, MailingCountryCode, MailingLatitude, 
                          MailingLongitude, MailingGeocodeAccuracy, 
                          //MailingAddress, 
                          Firm_Org_ID__c, //T08 
                          Phone, Fax, MobilePhone, ReportsToId, Email, Title,
                          Department, LeadSource, Description, OwnerId, 
                          HasOptedOutOfEmail, DoNotCall, Historical_SFDC_ID__c, 
                          MH_Siebel_ID__c, Role__c, Suffix__c, ISLN__c, 
                          pi__Needs_Score_Synced__c, 
                          pi__Pardot_Last_Scored_At__c, pi__campaign__c, pi__comments__c, 
                          pi__conversion_date__c, pi__conversion_object_name__c, 
                          pi__conversion_object_type__c, pi__created_date__c, pi__first_activity__c, 
                          pi__first_search_term__c, pi__first_search_type__c, pi__first_touch_url__c, 
                          pi__grade__c, pi__last_activity__c, pi__notes__c, pi__pardot_hard_bounced__c, 
                          pi__score__c, pi__url__c, pi__utm_campaign__c, pi__utm_content__c, 
                          pi__utm_medium__c, pi__utm_source__c, pi__utm_term__c, Building__c, Product_Preference__c,
                          Current_Sequence_ID__c,Current_Sequence_Name__c,Current_Sequence_Status__c,Current_Sequence_Step_Number__c,Current_Sequence_Step_Type__c,
                          Current_Sequence_Task_Due_Date__c,Current_Sequence_User_SFDC_ID__c,
                          Goes_By_Name__c, Comments__c, MH_Contact__c, Areas_of_Practice__c,M_NG_Classification__c,                          
                          County_Name__c, Zipcode__c, JV_Customer_Status__c, JV_Order_Status__c,M_NG_Sub_Type__c,
                         Account.Organization_Type__c,
                         JV_Organization_Type__c, JV_Sub_Type__c, MH_Customer_Status__c, MH_Order_Status__c, 
                         MH_Organization_Type__c, M_NG_Organization_Type__c, MH_Sub_Type__c, MN_Customer_Status__c, MN_Order_Status__c, 
                         MN_Organization_Type__c, MN_Sub_Type__c, Alternate_Email_Address__c, Do_Not_Solicit__c,
                   Practice_Area_1__c, Practice_Area_2__c, Practice_Area_3__c, Practice_Area_4__c, Practice_Area_5__c
                        // MHCustomerStatus__c, MH_Organization_Type__c, MH_Order_Status__c, MH_Sub_Type__c, JV_Customer_Status__c, MNSubType__c,
                        // JVOrganizationType__c, JVOrderStatus__c, JVSubType__c, MNCustomerStatus__c, MNOrganizationType__c, MNOrderStatus__c          
                   FROM Contact
                   where id=:conId];
            
            lead l = new Lead();
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
            l.County__c            = con.County_Name__c;
            l.Status               = 'Open';
            l.lead_created_from_contact__c= TRUE;
            //l.Company              = 'Individual';
            l.LeadSource           = 'Contact';                                                                                                                                                                                                                                                                                                                                                                                                                                                             
            l.MHCustomerStatus__c  = con.MH_Customer_Status__c;
           // l.MHOrganizationType__c= con.MH_Organization_Type__c;
            l.MHOrderStatus__c     = con.MH_Order_Status__c;
            //l.MHSubType__c         = con.MH_Sub_Type__c;
            l.JVCustomerStatus__c  = con.JV_Customer_Status__c;
           // l.MNSubType__c         = con.MN_Sub_Type__c;
           // l.JVOrganizationType__c= con.JV_Organization_Type__c;
            l.JVOrderStatus__c     = con.JV_Order_Status__c;
           // l.JVSubType__c         = con.JV_Sub_Type__c;
            l.MNCustomerStatus__c  = con.MN_Customer_Status__c;
           // l.MNOrganizationType__c= con.MN_Organization_Type__c;
            l.MNOrderStatus__c     = con.MN_Order_Status__c;
            l.Contact__c           = con.id;
            l.Goes_By_Name__c      = con.Goes_By_Name__c;
            l.title                = con.title;
            l.MobilePhone          = con.MobilePhone;
            l.HasOptedOutOfEmail   = con.HasOptedOutOfEmail;
            l.ISLN__c              = con.ISLN__c;
            l.Product_Preference__c= con.Product_Preference__c;
            //l.M_NG_Organization_Type__c= con.M_NG_Organization_Type__c;
            //l.Classification__c    = con.M_NG_Classification__c;
           // l.M_NG_Sub_Type__c     = con.M_NG_Sub_Type__c;
            
            //org id
            //l.NumberOfEmployees    = con.NumberOfEmployees;
            
            //Outreach field mapping to lead from Co
            l.Current_Sequence_ID__c = con.Current_Sequence_ID__c;
            l.Current_Sequence_Name__c = con.Current_Sequence_Name__c;
            l.Current_Sequence_Status__c= con.Current_Sequence_Status__c;
            l.Current_Sequence_Step_Number__c   = con.Current_Sequence_Step_Number__c   ;
            l.Current_Sequence_Step_Type__c = con.Current_Sequence_Step_Type__c;
            l.Current_Sequence_Task_Due_Date__c = con.Current_Sequence_Task_Due_Date__c;
            l.Current_Sequence_User_SFDC_ID__c = con.Current_Sequence_User_SFDC_ID__c;
            
            //Pardot field mapping from Contact to Lead
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
            //l.pi__url__c= con.pi__url__c;

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
        if(!String.isBlank(RecordType)){
            l.RecordTypeId = RecordType;
        }
        // <T02>
            l.Practice_Area_1__c = con.Practice_Area_1__c;
            l.Practice_Area_2__c = con.Practice_Area_2__c;
            l.Practice_Area_3__c = con.Practice_Area_3__c;
            l.Practice_Area_4__c = con.Practice_Area_4__c;
            l.Practice_Area_5__c = con.Practice_Area_5__c;  
            
      System.debug('MGGGGGGG ' + l.RecordTypeId);      
            insert l;
            
  System.debug('MHHHHHHH ' + l.RecordTypeId);
        return l.id;
    }
	
	//<T06>    
webservice static string createAvvoLead(Id conId,String ProfName) // you can pass parameters
    { 
        String LeadRecTypeDevName;
        System.debug('createAvvoLead ProfName ' + ProfName);
        for(User_Profile_Record_Type_Mapping__c uprm: User_Profile_Record_Type_Mapping__c.getall().values()){
            if(ProfName == uprm.User_Profile_Name__c){
                LeadRecTypeDevName = uprm.Record_Type_Dev_Name__c;
                break;
            }
        }
        Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(LeadRecTypeDevName).getRecordTypeId();
        contact con = new contact();
       
            con = [SELECT Id, AccountId, LastName, FirstName, Salutation, Account_Name__c,Account_Website__c,No_of_Employees__c,Org_ID__c,
                          Name, RecordTypeId, MailingStreet, MailingCity, 
                          MailingState, MailingPostalCode, MailingCountry, 
                          MailingStateCode, MailingCountryCode, MailingLatitude,
                   		  Firm_Org_ID__c, //T08 
                          MailingLongitude, MailingGeocodeAccuracy, 
                          Phone, Fax, MobilePhone, ReportsToId, Email,Email_2__c,Email_3__c,Website__c, Title,
                   		  Practice_Area_1__c,Practice_Area_2__c,Practice_Area_3__c,Practice_Area_4__c,Practice_Area_5__c,
                   		  Practice_Status__c,Professional_ID__c,
                          Department, LeadSource, Description, OwnerId, 
                          HasOptedOutOfEmail, DoNotCall, Historical_SFDC_ID__c, 
                          MH_Siebel_ID__c, Role__c, Suffix__c, ISLN__c, 
                          pi__Needs_Score_Synced__c, 
                          pi__Pardot_Last_Scored_At__c, pi__campaign__c, pi__comments__c, 
                          pi__conversion_date__c, pi__conversion_object_name__c, 
                          pi__conversion_object_type__c, pi__created_date__c, pi__first_activity__c, 
                          pi__first_search_term__c, pi__first_search_type__c, pi__first_touch_url__c, 
                          pi__grade__c, pi__last_activity__c, pi__notes__c, pi__pardot_hard_bounced__c, 
                          pi__score__c, pi__url__c, pi__utm_campaign__c, pi__utm_content__c, 
                          pi__utm_medium__c, pi__utm_source__c, pi__utm_term__c, Building__c, Product_Preference__c,
                          Current_Sequence_ID__c,Current_Sequence_Name__c,Current_Sequence_Status__c,Current_Sequence_Step_Number__c,Current_Sequence_Step_Type__c,
                          Current_Sequence_Task_Due_Date__c,Current_Sequence_User_SFDC_ID__c,
                          Goes_By_Name__c, Comments__c, MH_Contact__c, Areas_of_Practice__c,M_NG_Classification__c,                          
                          County_Name__c, Zipcode__c, JV_Customer_Status__c, JV_Order_Status__c,M_NG_Sub_Type__c,
                         Account.Organization_Type__c,
                         JV_Organization_Type__c, JV_Sub_Type__c, MH_Customer_Status__c, MH_Order_Status__c, 
                         MH_Organization_Type__c, M_NG_Organization_Type__c, MH_Sub_Type__c, MN_Customer_Status__c, MN_Order_Status__c, 
                         MN_Organization_Type__c, MN_Sub_Type__c, Alternate_Email_Address__c, Do_Not_Solicit__c
                        // MHCustomerStatus__c, MH_Organization_Type__c, MH_Order_Status__c, MH_Sub_Type__c, JV_Customer_Status__c, MNSubType__c,
                        // JVOrganizationType__c, JVOrderStatus__c, JVSubType__c, MNCustomerStatus__c, MNOrganizationType__c, MNOrderStatus__c          
                   FROM Contact
                   where id=:conId];
            
            lead l = new Lead();
            l.Salutation           = con.Salutation;
            l.Firm_Name__c         = con.FirstName;
            l.FirstName            = con.FirstName;
            l.LastName             = con.LastName;
            l.Phone                = con.Phone;
            l.Email                = con.Email;
        	l.Email_2__c		   = con.Email_2__c;
        	l.Email_3__c		   = con.Email_3__c;
        	l.Website			   = con.Website__c;
            l.Country              = con.MailingCountry;
            l.Street               = con.MailingStreet;
            l.City                 = con.MailingCity;
            l.State                = con.MailingState;
            l.PostalCode           = con.MailingPostalCode;
            l.County__c            = con.County_Name__c;
            l.Status               = 'Open';
            l.lead_created_from_contact__c= TRUE;
            l.LeadSource           = 'Contact';                                                                                                                                                                                                                                                                                                                                                                                                                                                             
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
        	l.Practice_Area_1__c   = con.Practice_Area_1__c;
        	l.Practice_Area_2__c   = con.Practice_Area_2__c;
        	l.Practice_Area_3__c   = con.Practice_Area_3__c;
        	l.Practice_Area_4__c   = con.Practice_Area_4__c;
        	l.Practice_Area_5__c   = con.Practice_Area_5__c;
        	l.Professional_ID__c   = con.Professional_ID__c;
            
            //Outreach field mapping to lead from Co
            l.Current_Sequence_ID__c = con.Current_Sequence_ID__c;
            l.Current_Sequence_Name__c = con.Current_Sequence_Name__c;
            l.Current_Sequence_Status__c= con.Current_Sequence_Status__c;
            l.Current_Sequence_Step_Number__c   = con.Current_Sequence_Step_Number__c   ;
            l.Current_Sequence_Step_Type__c = con.Current_Sequence_Step_Type__c;
            l.Current_Sequence_Task_Due_Date__c = con.Current_Sequence_Task_Due_Date__c;
            l.Current_Sequence_User_SFDC_ID__c = con.Current_Sequence_User_SFDC_ID__c;
            
            //Pardot field mapping from Contact to Lead
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
        if(LeadRecordTypeId !=null){
            l.RecordTypeId = LeadRecordTypeId;
        }
        l.Created_From_Contact__c = true; //<T07>     
      	System.debug('MGGGGGGG ' + l.RecordTypeId);      
            insert l;
        //<T07> starts
        List<Id> accIds = new List<Id>();
        List<Contact> conToUpdate = new List<Contact>();
        if(con!=null){
            con.Open_Martindale_Avvo_Lead__c = True;
            if(con.accountId != null){
            	accIds.add(con.accountId);
            }
            conToUpdate.add(con);
        }
        if(!accIds.isEmpty()){
            for(Contact cont : [Select Id,Open_Martindale_Avvo_Lead__c from Contact where AccountId in :accIds AND Id !=: con.Id and Open_Martindale_Avvo_Lead__c=false]){
                cont.Open_Martindale_Avvo_Lead__c =  true;
                conToUpdate.add(cont);
            }
        }
        if(!conToUpdate.isEmpty()){
            Database.executeBatch(new BatchBOBUpdateContact(conToUpdate),1);
        }
        //<T07> ends    
  	  	System.debug('MHHHHHHH ' + l.RecordTypeId);
        	return l.id;
    }//</T06>
}
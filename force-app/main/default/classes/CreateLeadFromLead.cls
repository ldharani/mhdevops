/**************************************************************
 * Author      : Ronak
 * Description : To create Lead from Lead
 * Created Date : 05/23/2018
 * ***********************************************************/

/* 
* Class Name   : CreateLeadFromLead
* Test Class   : CreateLeadFromLeadTest
* Description  : 

*  

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-7638    Sachin  	   29/09/2022			<T01>   Update MN Lead Source Based on Clone vs Self Sourced
************************************************************************************************************************

*/

global class CreateLeadFromLead {
    
    webservice static string createLead(Id lid) // you can pass parameters
    { 
        Lead lea = new Lead();
       
            lea = [SELECT Id, LastName, FirstName, Salutation,NumberOfEmployees ,
                          Name, RecordTypeId, Company,Pardot_Business_Unit__c,
                          Phone, Fax, MobilePhone, Email, Title,Website ,
                          LeadSource, Description,PostalCode,State,City,Country,Street,
                          HasOptedOutOfEmail, DoNotCall, Historical_SFDC_ID__c, 
                          ISLN__c, MHCustomerStatus__c , MHOrderStatus__c,JVCustomerStatus__c ,MNCustomerStatus__c ,JVOrderStatus__c,
                          pi__Pardot_Last_Scored_At__c, pi__campaign__c, pi__comments__c, County__c,
                          pi__conversion_date__c, pi__conversion_object_name__c, MNOrderStatus__c,
                          pi__conversion_object_type__c, pi__created_date__c, pi__first_activity__c, 
                          pi__first_search_term__c, pi__first_search_type__c, pi__first_touch_url__c, 
                          pi__grade__c, pi__last_activity__c, pi__notes__c, pi__pardot_hard_bounced__c, 
                          pi__score__c, pi__url__c, pi__utm_campaign__c, pi__utm_content__c, 
                          pi__utm_medium__c, pi__utm_source__c, pi__utm_term__c, Product_Preference__c,
                          Current_Sequence_ID__c,Current_Sequence_Name__c,Current_Sequence_Status__c,Current_Sequence_Step_Number__c,Current_Sequence_Step_Type__c,
                          Current_Sequence_Task_Due_Date__c,Current_Sequence_User_SFDC_ID__c,
                          Goes_By_Name__c, Comments__c, Areas_of_Practice__c,M_NG_Classification__c,       OrgID__c ,                   
                           Zipcode__c,
                         
                          M_NG_Organization_Type__c          
                   FROM Lead
                   where id=:lid];
            
            lead l = new Lead();
            l.Salutation           = lea.Salutation;
            l.FirstName            = lea.FirstName;
            l.FirstName            = lea.FirstName;
            l.LastName             = lea.LastName;
            l.Company              = lea.Company;
            l.Phone                = lea.Phone;
            l.Email                = lea.Email;
            l.Country              = lea.Country;
            l.Street               = lea.Street;
            l.City                 = lea.City;
            l.State                = lea.State;
            l.PostalCode           = lea.PostalCode;
            l.County__c            = lea.County__c;
            l.Status               = 'Open';
            l.lead_created_from_contact__c= FALSE;
            l.LeadSource           = 'Clone'; 
 	    // <T01>
	    l.MN_Lead_Source__c = 'Clone';                                                                                                                                                                                                                                                                                                                                                                                                                                                             
            l.MHCustomerStatus__c  = lea.MHCustomerStatus__c  ;
           // l.MHOrganizationType__c= con.MH_Organization_Type__c;
            l.MHOrderStatus__c     = lea.MHOrderStatus__c;
            //l.MHSubType__c         = con.MH_Sub_Type__c;
            l.JVCustomerStatus__c  = lea.JVCustomerStatus__c ;
           // l.MNSubType__c         = con.MN_Sub_Type__c;
           // l.JVOrganizationType__c= con.JV_Organization_Type__c;
            l.JVOrderStatus__c     = lea.JVOrderStatus__c;
           // l.JVSubType__c         = con.JV_Sub_Type__c;
            l.MNCustomerStatus__c  = lea.MNCustomerStatus__c ;
           // l.MNOrganizationType__c= con.MN_Organization_Type__c;
            l.MNOrderStatus__c     = lea.MNOrderStatus__c;
            //l.Contact__c           = l.id;
            l.Goes_By_Name__c      = lea.Goes_By_Name__c;
            l.title                = lea.title;
            l.MobilePhone          = lea.MobilePhone;
            l.HasOptedOutOfEmail   = lea.HasOptedOutOfEmail;
            l.ISLN__c              = lea.ISLN__c;
            l.Product_Preference__c= lea.Product_Preference__c;
            //l.M_NG_Organization_Type__c= con.M_NG_Organization_Type__c;
            //l.Classification__c    = con.M_NG_Classification__c;
           // l.M_NG_Sub_Type__c     = con.M_NG_Sub_Type__c;
            
            //org id
            //l.NumberOfEmployees    = con.NumberOfEmployees;
            
            //Outreach field mapping to lead from Co
            l.Current_Sequence_ID__c = lea.Current_Sequence_ID__c;
            l.Current_Sequence_Name__c = lea.Current_Sequence_Name__c;
            l.Current_Sequence_Status__c= lea.Current_Sequence_Status__c;
            l.Current_Sequence_Step_Number__c   = lea.Current_Sequence_Step_Number__c   ;
            l.Current_Sequence_Step_Type__c = lea.Current_Sequence_Step_Type__c;
            l.Current_Sequence_Task_Due_Date__c = lea.Current_Sequence_Task_Due_Date__c;
            l.Current_Sequence_User_SFDC_ID__c = lea.Current_Sequence_User_SFDC_ID__c;
            
            //Pardot field mapping from Contact to Lead
            l.Pardot_Business_Unit__c = lea.Pardot_Business_Unit__c;
            l.pi__campaign__c = lea.pi__campaign__c;
            l.pi__comments__c = lea.pi__comments__c;
            l.pi__conversion_date__c = lea.pi__conversion_date__c;
            l.pi__conversion_object_name__c = lea.pi__conversion_object_name__c;
            l.pi__conversion_object_type__c = lea.pi__conversion_object_type__c;
            l.pi__created_date__c = lea.pi__created_date__c;
            l.pi__first_activity__c = lea.pi__first_activity__c;
            l.pi__first_touch_url__c = lea.pi__first_touch_url__c;
            l.pi__first_search_term__c = lea.pi__first_search_term__c;
            l.pi__first_search_type__c = lea.pi__first_search_type__c;
            l.pi__grade__c = lea.pi__grade__c;
            l.pi__pardot_hard_bounced__c = lea.pi__pardot_hard_bounced__c ;
            l.pi__last_activity__c = lea.pi__last_activity__c;
            l.pi__Pardot_Last_Scored_At__c = lea.pi__Pardot_Last_Scored_At__c;
            l.pi__notes__c = lea.pi__notes__c;
            l.pi__score__c= lea.pi__score__c;
            //l.pi__url__c= lea.pi__url__c;
            l.Website = lea.Website ;
            
            l.NumberOfEmployees = lea.NumberOfEmployees ;
            l.OrgID__c = lea.OrgID__c ;
            
         
            insert l;
            
  
        return l.id;
    }

}
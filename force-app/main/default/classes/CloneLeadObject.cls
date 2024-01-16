public class CloneLeadObject {
    
    Public string leadId {get;set;}
    @InvocableMethod

   //Public static void createChildLeadecords(List<Id> LeadIds) {
    public static void cloneLeadObject(List<String> LeadId){
    Map<String,Lead> EmailVsParentLeads = new Map<String,Lead>();
     List<lead>leadstoCreate = new List<lead>();
        System.debug('LeadId--> ' + LeadId);
        for(Lead l : [select id,Firstname,lastname,company,Business_Unit__c,Country,street,city,state,postalCode,Areas_of_Practice__c, Subject__c, Type_of_Business__c,RecordType.Name, Classification__c, Record_Type_Name__c,  
                        email,phone,ISLN__c, Zipcode__c, Firm_Name__c, LeadSource, Description, Campaign_ID__c, Campaign_Name__c, Comments__c,
                        Contact__r.name, County__c, Create_Parent_Account__c, Current_Sequence_ID__c, Current_Sequence_Name__c, Current_Sequence_Status__c, Current_Sequence_Step_Number__c,
                        Current_Sequence_Step_Type__c, Current_Sequence_Task_Due_Date__c, Current_Sequence_User_SFDC_ID__c, DB_Created_Date_without_Time__c, DB_Lead_Age__c, 
                        Goes_By_Name__c, JVCustomerStatus__c, JVOrderStatus__c, JVOrganizationType__c, JVSubType__c, LeadConvertion__c, lead_created_from_contact__c, Lead_Id__c, Lead_Owner_Change_Date__c,
                        Lead_Owner_Number__c, Locations__c, Marketing_Spend__c, MH_Classification__c, MH_Customer_Number__c, MHCustomerStatus__c, MH_Lead_Actively_being_sequenced__c, MH_Lead_Source__c,
                        MHOrderStatus__c, MHOrganizationType__c, MHSubType__c, MN_Classification__c, MN_County__c, MNCustomerStatus__c, M_NG_Classification__c, M_NG_Customer_Status__c, M_NG_Lead_Actively_being_sequenced__c,
                        M_NG_Lead_Source__c, M_NG_Order_Status__c,M_NG_Organization_Type__c , M_NG_Sub_Type__c, MN_Lead_Actively_being_sequenced__c, MN_Lead_Source__c, MNOrderStatus__c, MNOrganizationType__c, MNSubType__c,
                        Organization_Type__c, Title, MobilePhone ,status, DoNotCall, Website, HasOptedOutOfEmail,Salutation, OrgID__c, Org_Sub_Type__c, Product_Preference__c, Reason_Not_Converted__c, Stop_Sequences__c, UL_SF_ID__c, Unqualified_Reason_Description__c, Zipcode__r.Name
                        from Lead
                              Where id IN: LeadId]) {
              EmailVsParentLeads.put(l.email,l);
              System.debug('EmailVsParentLeads--> ' + EmailVsParentLeads);
              System.debug('Child l--> ' + l);
         }

        Map<String, Map<String, lead>> emailVsRecordTypeNameVsLead = new Map<String, Map<String, lead>>();

        for(lead l : [select id, Name, RecordType.Name, Status, Email
                             From Lead 
                             Where Email IN: EmailVsParentLeads.keyset()
                                  AND Status != 'Closed - Not Converted' AND Status != 'Unqualified' AND Id NOT IN: LeadId ]) {
              
              System.debug('child leads--> ' + l);
              if(emailVsRecordTypeNameVsLead.containsKey(l.email)){
                 Map<String, Lead> tempMap = new Map<String, Lead>();
                 tempMap = emailVsRecordTypeNameVsLead.get(l.email);
                 tempMap.put(l.RecordType.Name, l);
                 emailVsRecordTypeNameVsLead.put(l.email, tempMap);
                 System.debug('Check 1'); 
                 
              }
              else{
                 Map<String, Lead> tempMap = new Map<String, Lead>();
                 tempMap.put(l.RecordType.Name, l);
                 emailVsRecordTypeNameVsLead.put(l.email, tempMap);
                 System.debug('Check 2');
              }

         }

       
        for(String email : EmailVsParentLeads.keyset()){
            Lead plead = EmailVsParentLeads.get(email);
            System.debug('parent lead--> ' + plead.Business_Unit__c);
            System.debug(' respective lead--> ' + emailVsRecordTypeNameVsLead);
            
            
            if(!emailVsRecordTypeNameVsLead.isEmpty() && emailVsRecordTypeNameVsLead.containsKey(plead.email)) {
                    Map<String,Lead> childMap = emailVsRecordTypeNameVsLead.get(plead.email);
                    System.debug('Business_Unit__c--> ' + plead.Business_Unit__c);
                 System.debug(' childMap--> ' + childMap);   
                if(plead.Business_Unit__c == 'Martindale-Hubbell'  && !childMap.containsKey('M-H lead')) {
                   //Lead creation logic
                    Lead cloneLead =  plead.clone(false,false,false,false);
                    cloneLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-H lead').getRecordTypeId();
                    cloneLead.ownerId = '00G0G000007YPPm';
                    cloneLead.Status = 'open';
                    cloneLead.Reason_Not_Converted__c = '';
                    leadstoCreate.add(cloneLead);
                }
                else if(plead.Business_Unit__c== 'Martindale-Nolo'  && !childMap.containsKey('M-N Leads')){
                    //Lead creation logic
                    Lead cloneLead =  plead.clone(false,false,false,false);
                    cloneLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-N Leads').getRecordTypeId();
                    cloneLead.arxxusleadassig__Type__c= 'M-N Leads';
                    cloneLead.Status = 'open';
                    cloneLead.Reason_Not_Converted__c = '';
                    System.debug('cloneLead.arxxusleadassig__Type__c'+cloneLead.arxxusleadassig__Type__c);
                    System.debug('cloneLead.Owner.id'+cloneLead.Owner.id);
                    leadstoCreate.add(cloneLead);
                }
                else if(plead.Business_Unit__c == 'Martindale-NGage'  && !childMap.containsKey('M-NG Leads')){
                    //Lead creation logic
                    Lead cloneLead =  plead.clone(false,false,false,false);
                    cloneLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-NG Leads').getRecordTypeId();
                    cloneLead.ownerId = '00G0G0000071yWZ';
                    cloneLead.Status = 'open';
                    cloneLead.Reason_Not_Converted__c = '';
                    leadstoCreate.add(cloneLead);
                }
            }
            else if(emailVsRecordTypeNameVsLead.isEmpty() || !emailVsRecordTypeNameVsLead.containsKey(plead.email)){
                if(plead.Business_Unit__c == 'Martindale-Hubbell') {
                   //Lead creation logic
                    Lead cloneLead =  plead.clone(false,false,false,false);
                    cloneLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-H lead').getRecordTypeId();
                    cloneLead.ownerId = '00G0G000007YPPm';
                    cloneLead.Status = 'open';
                    cloneLead.Reason_Not_Converted__c = '';
                    leadstoCreate.add(cloneLead);
                }
                
                else if(plead.Business_Unit__c == 'Martindale-Nolo'){
                    //Lead creation logic
                    Lead cloneLead =  plead.clone(false,false,false,false);
                    cloneLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-N Leads').getRecordTypeId();
                    cloneLead.arxxusleadassig__Type__c= 'M-N Leads';
                    cloneLead.Status = 'open';
                    cloneLead.Reason_Not_Converted__c = '';
                    System.debug('cloneLead.arxxusleadassig__Type__c'+cloneLead.arxxusleadassig__Type__c);
                    System.debug('cloneLead.Owner.id'+cloneLead.Owner.id);
                    leadstoCreate.add(cloneLead);
                }
                else if(plead.Business_Unit__c == 'Martindale-NGage' ){
                    //Lead creation logic
                    Lead cloneLead =  plead.clone(false,false,false,false);
                    cloneLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-NG Leads').getRecordTypeId();
                    cloneLead.ownerId = '00G0G0000071yWZ';
                    cloneLead.Status = 'open';
                    cloneLead.Reason_Not_Converted__c = '';
                    leadstoCreate.add(cloneLead);
                }
            }
        }

        if(!leadstoCreate.isEmpty()){
          insert leadstoCreate;
        }
   }


}
    /*
    public static void cloneLeadObject(List<String> LeadId){
        Lead leadObj = [Select id,Firstname,lastname,company,Pardot_Business_Unit__c,Country,street,city,state,postalCode,Areas_of_Practice__c, Subject__c, Type_of_Business__c,RecordType.Name, Classification__c, Record_Type_Name__c,  
                        email,phone,ISLN__c, Zipcode__c, Firm_Name__c, LeadSource, Description, Campaign_ID__c, Campaign_Name__c, Comments__c,
                        Contact__r.name, County__c, Create_Parent_Account__c, Current_Sequence_ID__c, Current_Sequence_Name__c, Current_Sequence_Status__c, Current_Sequence_Step_Number__c,
                        Current_Sequence_Step_Type__c, Current_Sequence_Task_Due_Date__c, Current_Sequence_User_SFDC_ID__c, DB_Created_Date_without_Time__c, DB_Lead_Age__c, 
                        Goes_By_Name__c, JVCustomerStatus__c, JVOrderStatus__c, JVOrganizationType__c, JVSubType__c, LeadConvertion__c, lead_created_from_contact__c, Lead_Id__c, Lead_Owner_Change_Date__c,
                        Lead_Owner_Number__c, Locations__c, Marketing_Spend__c, MH_Classification__c, MH_Customer_Number__c, MHCustomerStatus__c, MH_Lead_Actively_being_sequenced__c, MH_Lead_Source__c,
                        MHOrderStatus__c, MHOrganizationType__c, MHSubType__c, MN_Classification__c, MN_County__c, MNCustomerStatus__c, M_NG_Classification__c, M_NG_Customer_Status__c, M_NG_Lead_Actively_being_sequenced__c,
                        M_NG_Lead_Source__c, M_NG_Order_Status__c,M_NG_Organization_Type__c , M_NG_Sub_Type__c, MN_Lead_Actively_being_sequenced__c, MN_Lead_Source__c, MNOrderStatus__c, MNOrganizationType__c, MNSubType__c,
                        Organization_Type__c, Title, MobilePhone ,status, DoNotCall, Website, HasOptedOutOfEmail,Salutation, OrgID__c, Org_Sub_Type__c, Product_Preference__c, Reason_Not_Converted__c, Stop_Sequences__c, UL_SF_ID__c, Unqualified_Reason_Description__c, Zipcode__r.Name
                        from Lead
                        where id In: LeadId 
                        //where id In: LeadId AND ( Status = 'Closed - Not Converted' OR  Status = 'Unqualified') 
                        Limit 1];
        Lead cloneLead = leadObj.clone(false,false,false,false);
        cloneLead.id = null;
        //System.debug('cloneLead' + JSON.serialize(cloneLead));
        System.debug('Pardot_Business_Unit__c--> ' + leadObj.Pardot_Business_Unit__c);
        
        if(leadObj.Pardot_Business_Unit__c == 'Martindale-Hubbell' 
            && leadObj.Record_Type_Name__c  != 'M-H lead'
            && (leadObj.Status == 'Closed - Not Converted' || leadObj.Status == 'Unqualified')){
            system.debug('@@@@@@leadObj.Status'+leadObj.Status);
            cloneLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-H lead').getRecordTypeId();
            cloneLead.ownerId = '00G0G000007YPPm';
            cloneLead.Status = 'open';
            
         }else if(leadObj.Pardot_Business_Unit__c == 'Martindale-Nolo' 
                    && leadObj.Record_Type_Name__c  != 'M-N Leads'
                    && (leadObj.Status == 'Closed - Not Converted' || leadObj.Status == 'Unqualified')){
            system.debug('@@@@@@leadObj.Status'+leadObj.Status);
            cloneLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-N Leads').getRecordTypeId();
            cloneLead.arxxusleadassig__Type__c= 'M-N Leads';
            cloneLead.Status = 'open';
            System.debug('cloneLead.arxxusleadassig__Type__c'+cloneLead.arxxusleadassig__Type__c);
            System.debug('cloneLead.Owner.id'+cloneLead.Owner.id);
            
            
        }else if(leadObj.Pardot_Business_Unit__c == 'Martindale-NGage' 
                    && leadObj.Record_Type_Name__c != 'M-NG Leads'
                    && (leadObj.Status == 'Closed - Not Converted' || leadObj.Status == 'Unqualified')){
            system.debug('@@@@@@leadObj.Status'+leadObj.Status);
            cloneLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-NG Leads').getRecordTypeId();
            cloneLead.ownerId = '00G0G0000071yWZ';
            cloneLead.Status = 'open';
        }
        
        else if(leadObj.Pardot_Business_Unit__c == 'Martindale-NGage' 
                    && leadObj.Record_Type_Name__c == 'M-NG Leads'
                    && (leadObj.Status != 'Closed - Not Converted' || leadObj.Status != 'Unqualified')){
            system.debug('@@@@@@_MNGleadObj.Status'+leadObj.Status);
            cloneLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-NG Leads').getRecordTypeId();
            cloneLead.ownerId = '00G0G0000071yWZ';
            cloneLead.Status = 'open';
        }
        
        else if(leadObj.Pardot_Business_Unit__c == 'Martindale-Nolo' 
                    && leadObj.Record_Type_Name__c  == 'M-N Leads'
                    && (leadObj.Status != 'Closed - Not Converted' || leadObj.Status != 'Unqualified')){
            system.debug('@@@@@@_MNleadObj.Status'+leadObj.Status);
            cloneLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-N Leads').getRecordTypeId();
            //cloneLead.arxxusleadassig__Type__c= 'M-N Leads';
            cloneLead.Status = 'open';
            System.debug('cloneLead.arxxusleadassig__Type__c'+cloneLead.arxxusleadassig__Type__c);
            System.debug('cloneLead.Owner.id'+cloneLead.Owner.id);
            
            
        }
        
        else if(leadObj.Pardot_Business_Unit__c == 'Martindale-Hubbell' 
            && leadObj.Record_Type_Name__c  == 'M-H lead'
            && (leadObj.Status != 'Closed - Not Converted' || leadObj.Status != 'Unqualified')){
            system.debug('@@@@@@_MHleadObj.Status'+leadObj.Status);
            cloneLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-H lead').getRecordTypeId();
            cloneLead.ownerId = '00G0G000007YPPm';
            cloneLead.Status = 'open';
            
         }
        insert cloneLead;
    }
    
  
    
}*/
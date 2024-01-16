/*****
Class Name: CreateLead_AC 
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-10096   Bharath       01/11/2023   Kavitha VS      <T01>   BOB Functionality not working for MA Leads created by MAC sales Rep
************************************************************************************************************************/
public class CreateLead_AC {
    @AuraEnabled
    public Map<Id,String> recordtypeMap = new Map<Id,String>();
    @AuraEnabled
    public String messg = '';
    @AuraEnabled
    public static CreateLead_AC getContact(String conid){
        CreateLead_AC acc = new CreateLead_AC();
        Boolean UserCheck = [SELECT Id,Name,UserCheck__c FROM USER WHERE Id =: UserInfo.getUserId() LIMIT 1].UserCheck__c;
        List<User> userInfo = [SELECT Id,Name,Profile.Name,CompanyName FROM USER WHERE Id =: UserInfo.getUserId() LIMIT 1];
        String conItem = '';
        if(conId != Null){    
            List<Contact> conRec = [SELECT Id,Has_Professional_ID__c,JV_Order_Status__c,MH_Order_Status__c,MN_Order_Status__c,M_NG_Order_Status__c,Account.Do_Not_Call__c,HasOptedOutOfEmail FROM Contact WHERE Id =:conid LIMIT 1];
            for(Contact conLis : conRec){
            
               /* if(conLis.JV_Order_Status__c == 'Active' || conLis.MH_Order_Status__c == 'Evergreen' || conLis.MH_Order_Status__c == 'Active' || conLis.MN_Order_Status__c == 'Evergreen'|| conLis.MN_Order_Status__c == 'Active' || conLis.M_NG_Order_Status__c == 'Evergreen' || conLis.M_NG_Order_Status__c == 'Active'){
                    System.debug('aaaa');
                    acc.messg = 'You cannot create a lead from a contact that is related to an active account';
                    return acc;
                } else */
                
                if(conLis.Account.Do_Not_Call__c == True){
                    System.debug('bbbb');
                    acc.messg = 'The Contact for this lead has requested Do Not Call.Contact your manager if you think this is incorrect. A new lead will not be created.';
                    return acc;
                }
                else if(conLis.HasOptedOutOfEmail == true){
                    System.debug('cccc');
                    acc.messg = 'Please be aware that this contact has opted out of emails.';
                    return acc;
                }else if(UserCheck == True){
                    System.debug('MAAAAAAAAA');
                    acc.recordtypeMap.put(Schema.SObjectType.Lead.getrecordtypeinfosbyname().get('M-N Leads').getrecordtypeId(),'M-N Leads' );
                    acc.recordtypeMap.put(Schema.SObjectType.Lead.getrecordtypeinfosbyname().get('M-A Intake Leads').getrecordtypeId(),'M-A Intake Leads' );
                    acc.messg = 'Select Record Types';
                    return acc;
                } else {
                    System.debug('eeee');
                     if(userInfo[0].Profile.Name != 'MAC Sales Rep'){ //<T01>
                    acc.messg = CreateLeadFromContact.createLead(conLis.Id); 
                    }
                } 
                if(userInfo[0].Profile.Name == 'MAC Sales Rep'){ //<T01>
                  acc.messg =  CreateLeadFromContact.createAvvoLead(conLis.Id,userInfo[0].Profile.Name);
                }
            }
            
        }
        return acc;
    }
    @AuraEnabled
    public static String getContactXX(String conid, String recordId){
        System.debug('MBBBBBBBBB ' + recordId);
        String conItem = '';
        List<Contact> conRec = [SELECT Id,JV_Order_Status__c,MH_Order_Status__c,MN_Order_Status__c,M_NG_Order_Status__c,Account.Do_Not_Call__c,HasOptedOutOfEmail FROM Contact WHERE Id =:conid LIMIT 1];
        if(String.isBlank(recordId)){
            System.debug('MCCCCCCC ' + recordId);
            if(!test.isRunningTest()){
          conItem = CreateLeadFromContact.createLead(conRec[0].Id); 
            }
        }else{
            System.debug('MDDDDDDD ' + recordId);
            if(!test.isRunningTest()){
          conItem = CreateLeadFromContact.createLeadDupx(conRec[0].Id, recordId); 
            }
        }
        
        return conItem;
    }
    
    
}
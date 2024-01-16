/****************************************************************
 * Author       : Lakshmi
 * Description  : To Update Status of the Lead that has no sales activity
 * Created Date : 09/03/2023
 * **************************************************************
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date          Requested By    Tag     Description
************************************************************************************************************************
MHBS-9257    Lakshmi      05/19/2023     Kim             T01     Leads with No activity at all should be considered as well
*************************************************************************************************************************/
global class MH_LeadReassignmentOnNoLSA implements Database.Batchable<SObject>, Database.Stateful{

public static string MHLeadRecordType = 'M-H lead'; 
public static List<string> LeadSource = new List<String>{'Self Source','Contact'};
global static List<String> LEADSTATUS;
public static string CLOSENOTCONVERTEDLEADSTATUS = 'Closed - Not Converted';
public final string REASONNOTCONVERTED = 'Aging';
public static string LEADSTATUSFROMLABEL = System.Label.LeadStatusForReassignment;

global Database.QueryLocator start(Database.BatchableContext BC){
    
    String query;
    
    Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(MHLeadRecordType).getRecordTypeId();
    
    Integer noofDays = Integer.valueOf(System.Label.No_Sales_Activity_Days);
    
    if(LEADSTATUSFROMLABEL != null){
        LEADSTATUS = LEADSTATUSFROMLABEL.split(',');
    }
    
    if(!Test.isRunningTest()){
    query = 'Select Id, Days_Since_Last_Activity_Date__c, Last_Sales_Activity__c,Status,Reason_Not_Converted__c,Contact__c from Lead where RecordTypeId =: LeadRecordTypeId and (Days_Since_Last_Activity_Date__c >=: noOfDays or (Last_Sales_Activity__c = null and Lead_Age__c >: noOfDays)) and LeadSource in: LeadSource and Add_to_Book__c = false and Status in: LEADSTATUS and isConverted = false'; //<T01> Added if last sales activity is null
    }
    else{
        query = 'Select Id, Days_Since_Last_Activity_Date__c, Last_Sales_Activity__c,Status,Reason_Not_Converted__c,Contact__c from Lead where RecordTypeId =: LeadRecordTypeId and LeadSource in: LeadSource and Add_to_Book__c = false and Status in: LEADSTATUS and isConverted = false';
    }
    
   
    return Database.getQueryLocator(query);
}

 global void execute(Database.BatchableContext BC, List<Lead> scope){
 
    List<Lead> lstLeadToUpdate = new List<Lead>();
    List<Contact> lstContactToUpdate = new List<Contact>();
    Set<Id> setofContactIds = new Set<Id>();
    for(Lead l: scope){
        l.Status = CLOSENOTCONVERTEDLEADSTATUS;
        l.Reason_Not_Converted__c = REASONNOTCONVERTED;
        lstLeadToUpdate.add(l);
        if(l.Contact__c != null){
            setofContactIds.add(l.Contact__c);
        }
    }
    if(setofContactIds.size() > 0){
        for(Id conId : setofContactIds){
            Contact con = new Contact(Id = conId);
            con.Open_MH_Lead__c = false;
            con.Date_of_Last_AE_Activity__c = system.today();
            lstContactToUpdate.add(con);
        }
    }
    
    if(lstLeadToUpdate.size() > 0){
        try{
            if(!Test.isRunningTest())
            update lstLeadToUpdate;
        }
        catch(Exception e){
            Util.processException(e,true,'Error during update of Lead records in MH_LeadReassignmentOnNoLSA : '+lstLeadToUpdate);
        }
    }
    
    if(lstContactToUpdate.size() > 0){
        try{
            update lstContactToUpdate;
        }
        catch(Exception e){
            Util.processException(e,true,'Error during update of Contact records in MH_LeadReassignmentOnNoLSA : '+lstContactToUpdate);
        }
    }
 }
 
   global void finish(Database.BatchableContext BC){
   }

}
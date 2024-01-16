/****************************************************************
 * Author       : Lakshmi
 * Description  : Scheduler class for MH_LeadReassignmentOnNoLSA
 * Created Date : 04/25/2023
 * **************************************************************
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date          Requested By    Tag     Description
************************************************************************************************************************/

global class ScheduleMH_LeadReassignmentOnNoLSA implements Schedulable{
  global void execute(SchedulableContext SC) { 
    MH_LeadReassignmentOnNoLSA b = new MH_LeadReassignmentOnNoLSA();
    Database.executeBatch(b,1);
  }
}
/****************************************************************
 * Author       : Sai C
 * Description  : Scheudler class for BatchInvoiceAutoAllocation 
 * Created Date : 04/20/2023
 * **************************************************************
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date          Requested By    Tag     Description
************************************************************************************************************************/

global class ScheduleBatchInvoiceAutoAllocation implements Schedulable{
  global void execute(SchedulableContext SC) { 
    BatchInvoiceAutoAllocation b = new BatchInvoiceAutoAllocation();
    Database.executeBatch(b,1);
  }
}
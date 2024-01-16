/* 
* Class Name   : Batch_Update_OrderProds_InvoiceGroup    
* Test Class   : Batch_Update_OrderProds_InvoiceGroupTest
* Description  : Create the batch job update Invoice Group & Invoice Group ID
* Developed By : VR
* Ticket       : MHBS-6933
*  

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHMAC-36		CK		11/11/2022		Jeevan Babu		<T01>	Added additional condition to the query to include M-A Orders as well
************************************************************************************************************************

*/

global  class Batch_Update_OrderProds_InvoiceGroup implements Database.Batchable<Sobject>,Database.Stateful  {
        
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = '';
        {
            query = 'SELECT ID ,blng__InvoiceGrouping__c, blng__InvoiceGroupId__c , blng__InvoiceRunProcessingStatus__c , Order.RecordType.DeveloperName, blng__BillingAccount__r.MH_Cust_Number__c  From OrderItem  ';
            query += ' WHERE ';
            query += ' blng__InvoiceRunProcessingStatus__c!=\'Completed\' AND ';
            query += '( Order.RecordType.DeveloperName=\'MH_Order\' OR Order.RecordType.DeveloperName=\'M_A_Order\' )';//<T01> - Added to include M_A_Order as well
        }
        System.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc,List<OrderItem> scope)
    {
        List<OrderItem> OrderItems = new List<OrderItem>();
        for(OrderItem oi:scope)
        {
            if(oi.blng__InvoiceGrouping__c != 'Invoice Group ID' || oi.blng__InvoiceGroupId__c!=oi.blng__BillingAccount__r.MH_Cust_Number__c)
            {
                oi.blng__InvoiceGrouping__c = 'Invoice Group ID';
                oi.blng__InvoiceGroupId__c = oi.blng__BillingAccount__r.MH_Cust_Number__c;
                OrderItems.add(oi);
            }
        }
        System.debug(OrderItems.size());
        Update OrderItems;
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
}
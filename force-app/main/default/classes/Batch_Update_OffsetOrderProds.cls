/* 
* Class Name   : Batch_Update_OffsetOrderProds 
* Test Class   : Batch_Update_OffsetOrderProdsTest
* Description  : 

*  

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6932    Vishala	   30/09/2022			<T01>   Off set order products billing related fields needs to updated through batch job
************************************************************************************************************************

*/
global  class Batch_Update_OffsetOrderProds implements Database.Batchable<Sobject>,Database.Stateful  {
        
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = '';
        {
            query = 'SELECT ID, blng__InvoiceRunProcessingStatus__c ,blng__InvoiceRunStatusIndex__c,blng__NextBillingDate__c,blng__NextChargeDate__c, Order.RecordType.DeveloperName From OrderItem  ';
            query += ' WHERE ';
            query += ' Status__c=\'Off set\' AND ';
            query += ' blng__InvoiceRunProcessingStatus__c!=\'Completed\' AND ';
            query += ' Order.RecordType.DeveloperName=\'MH_Order\' ';
        }
        System.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc,List<OrderItem> scope)
    {
        List<OrderItem> OrderItems = new List<OrderItem>();
        for(OrderItem oi:scope)
        {
            {
                oi.blng__InvoiceRunProcessingStatus__c = 'Completed';
                oi.blng__InvoiceRunStatusIndex__c = 'Completed';
                oi.blng__NextBillingDate__c = null;
                oi.blng__NextChargeDate__c= null;
                OrderItems.add(oi);
            }
        }
        System.debug(OrderItems.size());
        if(!OrderItems.isEmpty()){
            try{
                update OrderItems;
            }
            catch(Exception e){
                Util.processException(e,true,'Batch_Update_OffsetOrderProds-Error during update of orderItem'+ OrderItems);
            }
        }        
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
}
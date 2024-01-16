global class PaymentTransactionBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        
        String query = 'select id, name,blng__InvoiceDate__c, blng__InvoiceStatus__c, blng__DueDate__c, blng__Action__c ,blng__PaymentStatus__c,(SELECT Id,blng__GatewayStatus__c FROM blng__RequestInvoiceTransactions__r ORDER By CreatedDate DESC LIMIT 1 )'+
            'from blng__Invoice__c where Recordtype.Name = \'MH Invoice\' and blng__InvoiceStatus__c = \'Posted\' and blng__PaymentStatus__c = \'Unpaid\' and blng__CorrectiveAction__c  != null order by blng__DueDate__c desc';
        System.debug('Query ==>>'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<blng__Invoice__c> blngList) {
       
        // process each batch of records

        List<blng__Invoice__c> objToUpdate = new List<blng__Invoice__c>();
        for(blng__Invoice__c obj : blngList)
        {        
           	if(obj.blng__RequestInvoiceTransactions__r <> null && obj.blng__RequestInvoiceTransactions__r.size()>0 &&
               obj.blng__RequestInvoiceTransactions__r[0].blng__GatewayStatus__c == 'Indeterminate'){
                   obj.blng__CorrectiveAction__c = '';
                   objToUpdate.add(obj);
            }
        }
        try {
        	// Update the Account Record
            if(objToUpdate.size() >0){
            	update objToUpdate;
                System.debug('objToUpdate ===>>'+JSON.serialize(objToUpdate));
            }    
        
        } catch(Exception e) {
            System.debug(e);
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
    	// execute any post-processing operations
  }
}
global class BatchProcessRetryFailedTransaction implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts  {
    global String query;
    global set<Id> setofPaymentRunIDs;
    global set<Id> transactionIdsToProcess;
    global string sStatusError = 'Error';
    global string sStatusDeclined = 'Declined';

    /*Below var holds the current failed trasaction*/
    global set<Id> currentFailedTransaction;
    global BatchProcessRetryFailedTransaction(string queryParameter, set<Id> setofPaymentRunIDsParameter, set<Id> transactionIdsToProcessParameter) {
        this.query = queryParameter; 
        this.setofPaymentRunIDs = setofPaymentRunIDsParameter;
        this.transactionIdsToProcess = transactionIdsToProcessParameter;

        //frame the query here
        if(setofPaymentRunIDs != null) {
            query = query + ' WHERE invoiceit_s__Payment_Run__c IN: setofPaymentRunIDs AND (invoiceit_s__Response_Status__c = \''  + sStatusError + '\' OR invoiceit_s__Response_Status__c = \''  + sStatusDeclined + '\')';    
        } else {
            query = query + ' WHERE Id IN: transactionIdsToProcess ';   
        }

        currentFailedTransaction = new set<Id>();
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query is ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<invoiceit_s__Transaction__c> listofFailedTransaction) {
        invoiceit_s__Invoice__c failedInvoiceTransaction;
        list<invoiceit_s__Invoice__c> listfailedInvoiceTransaction = new list<invoiceit_s__Invoice__c>();
        for(invoiceit_s__Transaction__c transactionObj : listofFailedTransaction){
            try { 
                ClassForHandlingAuthorizeDotNet.PaymentResult result = ClassAfterOnPaymentRun.retryFailedTrasactions(transactionObj.Id);

                if(result != null && result.transactionObj != null) {
                    if(result.transactionObj != null) {
                        // add the failed transaction ids
                        if(result.transactionObj.invoiceit_s__Response_Status__c == 'Error' || result.transactionObj.invoiceit_s__Response_Status__c == 'Declined') {
                            currentFailedTransaction.add(result.transactionObj.Id); 
                        }   
                    }   
                }
            }catch(Exception ex) {
                system.debug('\n \n An Exception has occurred : ' + ex.getMessage());
                failedInvoiceTransaction = new invoiceit_s__Invoice__c(id = transactionObj.invoiceit_s__Request_Invoice__c,Exception_Log__c = ex.getMessage() + ' ,Line NO ' + ex.getLineNumber() + ' ,Stack Trace ' + ex.getStackTraceString());
                listfailedInvoiceTransaction.add(failedInvoiceTransaction);
            }
        }
        
        // update the invoice with exception log
        if(!listfailedInvoiceTransaction.isEmpty()){
            update listfailedInvoiceTransaction;
        }
    }

    global void finish(Database.BatchableContext BC) {
        if(currentFailedTransaction.size() > 0) {
            // process the failed transaction ids
            BatchProcessRetryFailedTransaction batch = new BatchProcessRetryFailedTransaction('SELECT Id FROM invoiceit_s__Transaction__c ', null, currentFailedTransaction);
            Id batchId = Database.executeBatch(batch,1);    
        }
    }
}
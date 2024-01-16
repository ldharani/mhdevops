global with sharing class BatchCancelInvoices implements Database.Batchable<sObject>, Database.Stateful{
    global String query;
    global set<id> setOfInvoicesId = new set<id>();
    global BatchCancelInvoices(set<id> setOfInvoicesId){
      this.setOfInvoicesId = setOfInvoicesId;
      System.debug('Selected Invoices is In Batch Process --->'+setOfInvoicesId);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
       query = 'SELECT Name FROM invoiceit_s__Invoice__c WHERE ID IN: setOfInvoicesId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,list<invoiceit_s__Invoice__c> scope){
        invoiceit_s.ControllerCancelInvoice.isButtonClicked = true; 
        invoiceit_s__Invoice__c inv = new invoiceit_s__Invoice__c(id=scope[0].id,invoiceit_s__Invoice_Status__c ='Cancelled');
        update inv;
    
    }
    
    global void finish(Database.BatchableContext BC){
    }
}
public with sharing class InvoiceWrapper {
    public boolean isSelected {get;set;}
    public invoiceit_s__Invoice__c invoices {get;set;}
    
    public InvoiceWrapper() {
        isSelected = false;
        invoices = new invoiceit_s__Invoice__c();    
    }

}
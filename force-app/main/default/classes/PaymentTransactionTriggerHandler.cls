public class PaymentTransactionTriggerHandler {

    public static void updateInvoices(List<blng__PaymentTransaction__c> transactionList,Map<Id,blng__PaymentTransaction__c> oldMap){
        Set<Id> invoiceIds = new Set<Id>(); 
        if(oldMap != null){
            for(blng__PaymentTransaction__c obj :transactionList){
        		blng__PaymentTransaction__c oldObj =   oldMap.get(obj.Id);
                if(obj.blng__GatewayStatus__c != oldObj.blng__GatewayStatus__c && obj.blng__GatewayStatus__c == 'Indeterminate'){
                   invoiceIds.add(obj.blng__RequestInvoice__c); 
                }
            }        
        }else{
            for(blng__PaymentTransaction__c obj :transactionList){
                if(obj.blng__GatewayStatus__c == 'Indeterminate'){
                   invoiceIds.add(obj.blng__RequestInvoice__c); 
                }
            }
        }
        if(invoiceIds <> null){
            updateInvoiceCorrectionRequired(invoiceIds);
        }
    }
    
    public static void updateInvoiceCorrectionRequired(Set<Id> invoiceIds){
       	List<blng__Invoice__c> objList = new List<blng__Invoice__c>();
            for(blng__Invoice__c invoiceObj:[select id, name,blng__InvoiceDate__c,
                          blng__InvoiceStatus__c, blng__DueDate__c, 
                          blng__Action__c ,blng__PaymentStatus__c from blng__Invoice__c 
                          where Recordtype.Name = 'MH Invoice' and blng__InvoiceStatus__c = 'Posted' and blng__PaymentStatus__c = 'Unpaid' and blng__CorrectiveAction__c  != null 
                          AND Id IN:invoiceIds]){
                blng__Invoice__c obj =  new blng__Invoice__c();
                obj.blng__CorrectiveAction__c = '';
                obj.Id = invoiceObj.Id;
                objList.add(obj);
            } 
        SBQQ.TriggerControl.disable();
        	update objList;
        SBQQ.TriggerControl.enable();
        
    }
}
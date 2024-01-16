public with sharing class MDL_Future_InsertPaymentAllocation {

	
  	public static void insertPaymentAllocation(List<Id> paymentId) {
    	List<invoiceit_s__Payment_Allocation__c> list_PaymentAllocation_Insert = new List<invoiceit_s__Payment_Allocation__c>();
    	List<invoiceit_s__Payment__c> list_Payment = new List<invoiceit_s__Payment__c>();
    	
    	list_Payment = [Select Id , Invoice__c , invoiceit_s__Account__c , invoiceit_s__Amount__c,
    					Invoice__r.invoiceit_s__Invoice_Status__c, Invoice__r.invoiceit_s__Unpaid_Amount__c     	
    					from invoiceit_s__Payment__c 
    					where Id in : paymentId and RecordType.DeveloperName = 'MH_Payments'];
    	
    	for(invoiceit_s__Payment__c iterPay : list_Payment){
    		if(iterPay.Invoice__c != null && iterPay.Invoice__r.invoiceit_s__Unpaid_Amount__c > 0){
	    		invoiceit_s__Payment_Allocation__c tempPA = new invoiceit_s__Payment_Allocation__c();
	    		tempPA.invoiceit_s__Payment__c = iterPay.Id ;
	    		tempPA.invoiceit_s__Invoice__c = iterPay.Invoice__c ;
	    		if(iterPay.invoiceit_s__Amount__c <= iterPay.Invoice__r.invoiceit_s__Unpaid_Amount__c)
	    			tempPA.invoiceit_s__Amount__c = iterPay.invoiceit_s__Amount__c ;
	    		else if(iterPay.invoiceit_s__Amount__c > iterPay.Invoice__r.invoiceit_s__Unpaid_Amount__c)
	    			tempPA.invoiceit_s__Amount__c = iterPay.Invoice__r.invoiceit_s__Unpaid_Amount__c ;	
	    		list_PaymentAllocation_Insert.add(tempPA);
    		}
    	}	
    	
    	if(list_PaymentAllocation_Insert.size() > 0)
    		insert list_PaymentAllocation_Insert;		
    	
    	system.debug(' ------ ? ' + list_PaymentAllocation_Insert);	
  	} 
  	
  	public static void deletePaymentAllocation(List<Id> paymentId) {
  		List<invoiceit_s__Payment_Allocation__c> list_PaymentAllocation_Insert = new List<invoiceit_s__Payment_Allocation__c>();
  		
  		list_PaymentAllocation_Insert = [Select Id 
  											from invoiceit_s__Payment_Allocation__c
  											where invoiceit_s__Payment__c in : paymentId];
  		
  		delete 	list_PaymentAllocation_Insert ;								
  	}
}
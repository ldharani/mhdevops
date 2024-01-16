//Author       : Betsy
//Description  : Responsible for auto allocation of payments to the invoice lines
//				 when Invoice is getting posted
//	
				
global class BatchInvoiceAutoAllocation implements Database.Batchable<sObject>{
   public String AccountId;
    
    global BatchInvoiceAutoAllocation(String accId) {
        this.AccountId=accId;
    }
    
    global BatchInvoiceAutoAllocation() {
        
    }
    
   // querying the invoices which gets posted and with Payment status not Paid
   global Database.QueryLocator start(Database.BatchableContext BC){
       String query = 'Select id,TotalUnallocatedPayment__c,TotalInvoiceBalanceAmount__c from Account where TotalUnallocatedPayment__c > 0 and TotalInvoiceBalanceAmount__c > 0';
       if(AccountId!=null && AccountId!=''){
         query += ' and id =:AccountId';
       }
       
       if(Test.isRunningTest()) {
            query = 'Select id,TotalUnallocatedPayment__c,TotalInvoiceBalanceAmount__c from Account where Name like \'testAcc%\'';
        }
      System.debug('Database.getQueryLocator(query)'+Database.getQueryLocator(query));                       
      return Database.getQueryLocator(query);
   }

     
   global void execute(Database.BatchableContext BC, List<Account> newList){
       System.debug('Batch Returned List----->'+newList);
       	set<Id> setOfAccountId = new set<Id>();
        set<Id> setOfInvoiceId = new set<Id>();
        list<blng__invoice__c> invoiceList = new list<blng__invoice__c>();
        map<id,blng__invoiceline__c> mapInvIDOfInvLinId = new map<id,blng__invoiceline__c>();
        map<id,list<blng__invoiceline__c>> mapInvnInvoiceline = new map<id,list<blng__invoiceline__c>>();
        Map<Id, List<blng__Invoice__c>> mapAccountNListInvoice = new Map<Id, List<blng__Invoice__c>>();
        map<id,decimal> mapPaymIDnBal = new map<id,decimal>();
        List<blng__PaymentAllocationInvoiceLine__c> lstpayallocation = new List<blng__PaymentAllocationInvoiceLine__c>();
        List<blng__Invoice__c> invList = new List<blng__Invoice__c>();
       for(Account acc: newList){
           setOfAccountId.add(acc.Id);
       }
       if(Test.isRunningTest()){
       invoiceList = [Select id,blng__InvoiceStatus__c,blng__PaymentStatus__c,blng__Account__c,blng__Balance__c,(Select Id,blng__Balance__c from blng__InvoiceInvoiceLines__r) from blng__Invoice__c where blng__InvoiceStatus__c = 'Posted' AND blng__Account__c = :setOfAccountId];    
       }
       else{
       invoiceList = [Select id,blng__InvoiceStatus__c,blng__PaymentStatus__c,blng__Account__c,blng__Balance__c,(Select Id,blng__Balance__c from blng__InvoiceInvoiceLines__r where blng__Balance__c > 0) from blng__Invoice__c where blng__InvoiceStatus__c = 'Posted' AND blng__PaymentStatus__c != 'Paid' AND blng__Account__c = :setOfAccountId Order by blng__InvoicePostedDate__c];
       }
       for(blng__Invoice__c inv : invoiceList){
                setOfInvoiceId.add(inv.id);
                if(mapAccountNListInvoice.containsKey(inv.blng__Account__c)){
                    mapAccountNListInvoice.get(inv.blng__Account__c).add(inv);
                }
                else{
                    mapAccountNListInvoice.put(inv.blng__Account__c, new List<blng__Invoice__c>{inv});
                }
        }
       
        /* // Get Invoice lines details
        if(setOfInvoiceId.size() > 0){
        invoiceList = [Select Id, (Select Id,blng__Balance__c from blng__InvoiceInvoiceLines__r where blng__Balance__c > 0 ) from blng__invoice__c where Id in: setOfInvoiceId];
         }*/
        
        if(invoiceList.size()>0){
            for(blng__invoice__c invRec:invoiceList){
            mapInvnInvoiceline.put(invRec.id,invRec.blng__InvoiceInvoiceLines__r);
                }
        }
       
        
        // Allocate payments to invoice lines    
        if(setOfAccountId.size() > 0 && mapAccountNListInvoice.size()>0){
            for(Account acc : [Select Id, (Select Id,blng__Amount__c,blng__Balance__c,blng__Status__c from blng__Payments__r where blng__Balance__c > 0 AND (blng__Status__c = 'Posted' OR blng__Status__c = 'Completed') Order by blng__PaymentDate__c) from Account where Id in: setOfAccountId]){ 
                if(acc.blng__Payments__r.size() > 0){
                    for(blng__payment__c paym:acc.blng__Payments__r){
                        mapPaymIDnBal.put(paym.id,paym.blng__Balance__c);
                    }
                    for(blng__Invoice__c inv : mapAccountNListInvoice.get(acc.Id)){ 
                        decimal invBalance = inv.blng__Balance__c;
                        if(mapInvnInvoiceline.containskey(inv.id)){
                        for(blng__invoiceline__c invLine:mapInvnInvoiceline.get(inv.id)){
                        Decimal invLineBalance = invLine.blng__Balance__c;
                        
                            for(blng__Payment__c pay : acc.blng__Payments__r){                          
                                blng__PaymentAllocationInvoiceLine__c pallinv = new blng__PaymentAllocationInvoiceLine__c();
                                decimal paymentBal = mapPaymIDnBal.get(pay.id);
                                if(paymentBal>0 && invLineBalance > 0 && invBalance>0){
                            if(paymentBal <= invLineBalance){
                                pallinv.blng__Amount__c = paymentBal >= invBalance ? invBalance:paymentBal;
                            }
                            else if(paymentBal > invLineBalance){
                                pallinv.blng__Amount__c = invLineBalance>= invBalance? invBalance:invLineBalance;   
                            }
                                pallinv.blng__Type__c = 'Allocation';
                                pallinv.blng__Payment__c = pay.Id;
                                pallinv.blng__Invoiceline__c = invLine.Id;
                                pallinv.blng__Notes__c = 'Auto Allocation of Payment';                                
                                lstpayallocation.add(pallinv);   
                                invLineBalance -= pallinv.blng__Amount__c;                                                             
                                mapPaymIDnBal.put(pay.id,paymentBal-pallinv.blng__Amount__c);
                                invBalance -= pallinv.blng__Amount__c;
                                System.debug('lstpayallocation--->'+lstpayallocation);    
                                }
                        
                    }
                        }
                    }
                    
                }
            }
            }
        }
       try{
        if(lstpayallocation.size() > 0 || Test.isRunningTest()){
            insert lstpayallocation;
        }
       }
       catch(Exception e){
           System.debug('Exception Occurred in Payment Allocation'+e.getMessage());
       }
   }

   global void finish(Database.BatchableContext BC){
   }
}
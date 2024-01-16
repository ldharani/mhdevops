public class MDL_Ctrl_DunningLetter1 {
    public List<invoiceit_s__Invoice__c> invoice {get;set;} 
    public List<invoiceit_s__Invoice__c> invoice2 {get;set;} 
    public List<invoiceit_s__Invoice__c> invoice3 {get;set;} 
    public List<invoiceWrapper> wrapper1 {get;set;} 
    public List<invoiceWrapper> wrapper2 {get;set;} 
    public List<invoiceWrapper> wrapper3 {get;set;}
    public Account  account {get;set;}
    public String   statementDate {get;set;}
    public String   collectorName {get;set;}
    public Decimal  unpaidAmt {get;set;}
    public Decimal  unpaidAmt2 {get;set;}
    public Decimal  unpaidAmt3 {get;set;}
    
    public MDL_Ctrl_DunningLetter1(ApexPages.StandardController controller) {   
        if(ApexPages.currentPage().getParameters().get('id')  != null){
            String accountId = ApexPages.currentPage().getParameters().get('id');
            statementDate = string.valueOf(system.today()); 
            
            account = [Select Id , Name ,MH_Cust_Number__c, Collector__c , AccountNumber ,
                        BillingCity , BillingState , BillingCountry , BillingPostalCode ,    
                        Collector__r.Name ,Collector__r.Phone ,Collector__r.Extension ,     
                        Collector__r.Email , BillingStreet , Hold_dunning_letter_till__c
                        from Account
                        where Id =: accountId and RecordType.DeveloperName = 'MH_Accounts'] ; 
            
            Date dunninghold ;
            if(account.Hold_dunning_letter_till__c != null)
                dunningHold = account.Hold_dunning_letter_till__c;
             
            List<invoiceit_s__Invoice__c> tempInvoiceList = new List<invoiceit_s__Invoice__c>();    
            List<invoiceit_s__Payment__c> tempPaymentList = new List<invoiceit_s__Payment__c>(); 
            
                            
            invoice = new List<invoiceit_s__Invoice__c>(); 
            invoice2 = new List<invoiceit_s__Invoice__c>();
            invoice3 = new List<invoiceit_s__Invoice__c>();
            
            wrapper1 = new List<invoiceWrapper>(); 
            wrapper2 = new List<invoiceWrapper>();
            wrapper3 = new List<invoiceWrapper>();
            
            tempInvoiceList = [Select Id ,Name, invoiceit_s__Invoice_Date__c ,invoiceit_s__Payment_Status__c,   
                                invoiceit_s__Unpaid_Amount__c,  invoiceit_s__Due_Date__c,
                                invoiceit_s__Account__r.MH_Cust_Number__c , 
                                invoiceit_s__Account__r.Hold_dunning_letter_till__c                                 
                                from invoiceit_s__Invoice__c 
                                where invoiceit_s__Account__c =: accountId
                                and RecordType.DeveloperName = 'MH_Invoices'
                                and invoiceit_s__Payment_Status__c != 'Paid'
                                and ( invoiceit_s__Account__r.Hold_dunning_letter_till__c = null or
                                    invoiceit_s__Due_Date__c <=: dunninghold)];
            
            if(tempInvoiceList.size()>0){
                tempPaymentList = [Select Id , Name ,invoiceit_s__Payment_Date__c , invoiceit_s__Unallocated_Amount__c ,
                                    invoiceit_s__Payment_Type__c , Applied_Type__c , invoiceit_s__Account__c ,
                                    invoiceit_s__Account__r.Hold_dunning_letter_till__c 
                                    from invoiceit_s__Payment__c
                                    where   invoiceit_s__Account__c = : accountId
                                    and RecordType.DeveloperName = 'MH_Payments'
                                    and invoiceit_s__Unallocated_Amount__c > 0];
                                    
                for(invoiceit_s__Invoice__c iterInv : tempInvoiceList){
                    if(iterInv.invoiceit_s__Account__r.Hold_dunning_letter_till__c >= iterInv.invoiceit_s__Due_Date__c
                        || iterInv.invoiceit_s__Account__r.Hold_dunning_letter_till__c == null ){
                        if((iterInv.invoiceit_s__Due_Date__c + 30) == system.today()){
                            invoiceWrapper tempWrapper = new invoiceWrapper(IterInv);
                            wrapper1.add(tempWrapper);
                            
                        }   
                        else if((iterInv.invoiceit_s__Due_Date__c + 60) == system.today()){
                            invoiceWrapper tempWrapper = new invoiceWrapper(IterInv);
                            wrapper2.add(tempWrapper);                          
                        }
                        else if((iterInv.invoiceit_s__Due_Date__c + 90) == system.today()){
                            invoiceWrapper tempWrapper = new invoiceWrapper(IterInv);
                            wrapper3.add(tempWrapper);                          
                        }
                    
                        
                    }
                }
                
                for(invoiceit_s__Payment__c iterPay : tempPaymentList){                 
                            invoiceWrapper tempWrapper = new invoiceWrapper(iterPay);
                            wrapper1.add(tempWrapper);                                                  
                            wrapper2.add(tempWrapper);                                                      
                            wrapper3.add(tempWrapper);                                              
                }
                unpaidAmt = 0;
                unpaidAmt2 = 0;
                unpaidAmt3 = 0;
                for(invoiceWrapper inv : wrapper1){
                    if(inv.invoice.invoiceit_s__Unpaid_Amount__c != null)
                        unpaidAmt += inv.invoice.invoiceit_s__Unpaid_Amount__c ;
                }       
                for(invoiceWrapper inv : wrapper2){
                if(inv.invoice.invoiceit_s__Unpaid_Amount__c != null)
                        unpaidAmt2 += inv.invoice.invoiceit_s__Unpaid_Amount__c ;
                }
                for(invoiceWrapper inv : wrapper3){
                if(inv.invoice.invoiceit_s__Unpaid_Amount__c != null)
                        unpaidAmt3 += inv.invoice.invoiceit_s__Unpaid_Amount__c ;
                }
            }   
        }
    }
    
    public class invoiceWrapper{
        public invoiceit_s__Invoice__c          invoice {get;set;}
        public invoiceit_s__Payment__c          payment {get;set;}
        public boolean                          showInvoice {get;set;}
        public boolean                          creditMemo  {get;set;}
        public String                           itemDate  {get;set;}
        public String                           dueDate  {get;set;}
        public  invoiceWrapper(invoiceit_s__Invoice__c inv){
            invoice = new invoiceit_s__Invoice__c();
            payment = new invoiceit_s__Payment__c();        
            invoice = inv;  
            showInvoice = true;
            creditMemo = false;
            if(invoice.invoiceit_s__Invoice_Date__c != null)
                itemDate = string.valueOf(invoice.invoiceit_s__Invoice_Date__c);
            if(invoice.invoiceit_s__Due_Date__c != null)    
                dueDate = string.valueOf(invoice.invoiceit_s__Due_Date__c);             
        }   
        public invoiceWrapper(invoiceit_s__Payment__c pay){
            invoice = new invoiceit_s__Invoice__c();
            payment = new invoiceit_s__Payment__c();
            payment = pay;
            showInvoice = false;
            if(payment.invoiceit_s__Payment_Type__c == 'Adjustment' && payment.Applied_Type__c == 'Credit')
                creditMemo = true;
            else
                creditMemo = false;
            if(payment.invoiceit_s__Payment_Date__c != null)
                itemDate = string.valueOf(payment.invoiceit_s__Payment_Date__c);        
        }
    }
}
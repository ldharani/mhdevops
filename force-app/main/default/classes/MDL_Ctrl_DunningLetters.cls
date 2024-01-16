public class MDL_Ctrl_DunningLetters{

    public String DunningLetterType {get;set;} 
    public String StatementDate {get;set;}    
    public Integer oldestInvoiceStart;
    public Integer oldestInvoiceEnd;   
    public Map<Id, Decimal> Map_AccId_TotalUnpaidAmt {get;set;} 
    public Map<Id, String> Map_AccId_Sequence {get;set;}
    public Map<Account, List<invoiceWrapper>> Map_Acc_Wrapper {get;set;} 
    public Integer SeqN {get;set;} 
    public Map<Id, String> accIdVsBillingContactNameMap{get;set;}
    public String accidsformapCheck {get;set;}
    public boolean billingcontactsMapcheck{get;set;}
    public MDL_Ctrl_DunningLetters(){       
         
        List<Account> list_Acc = new List<Account>();
        List<Account> listaccforBilingcontacts = new List<Account>();
        List<String> List_accId = new List<String>();
        String key;
        String seq;
        Map<Id,invoiceit_s__Invoice__c> map_invoiceId_invoice = new Map<Id,invoiceit_s__Invoice__c>();
        Map<Id,invoiceit_s__Payment__c> map_paymentId_payment = new Map<Id,invoiceit_s__Payment__c>();
        Map_Acc_Wrapper = new Map<Account, List<invoiceWrapper>>();
        Map_AccId_TotalUnpaidAmt = new Map<Id, Decimal>();
        Map_AccId_Sequence = new Map<Id, String>();
        accIdVsBillingContactNameMap = new Map<Id,String>();
        StatementDate = system.today().format();
        accidsformapCheck = '';
         
        if(ApexPages.currentPage().getParameters().get('DunningAccountId')  != null){
            key = ApexPages.currentPage().getParameters().get('DunningAccountId') + '';
        }
        
        if(ApexPages.currentPage().getParameters().get('Seq')  != null ){
            seq = ApexPages.currentPage().getParameters().get('Seq');
            SeqN = Integer.valueOf(ApexPages.currentPage().getParameters().get('Seq'));
        }
        else{
            Seq = '1';
        }
        
        System.debug('letter type ---> ' + key );
                  
        Dunning_Account_ids__c acc_ids ;
        for(Dunning_Account_ids__c temp: [Select Name,Account_Ids__c,Used__c 
                                            from Dunning_Account_ids__c 
                                            where id =: key]){          
                acc_ids = temp;
                acc_ids.Used__c = true;  
                System.debug('@@ Account IDs' +acc_ids );                               
        }
        
        if(acc_ids != null){
            String tempAccId = '';
            tempAccId = acc_ids.Account_Ids__c + '';
            
            if(acc_ids.Name.contains('01-30'))
                DunningLetterType = '1';
            else if(acc_ids.Name.contains('31-60'))
                DunningLetterType = '3';
            else if(acc_ids.Name.contains('>60'))
                DunningLetterType = '4';
           // else if(acc_ids.Name.contains('>120'))
               // DunningLetterType = '4';        
                    
            if(tempAccId.contains(',')){
                List_accId = tempAccId.split(',');
            }
        }                                   
        
       //   system.debug('range ? ' + DunningLetterType + ' ' + acc_ids.Name); 
        list_Acc = [Select Id ,Name ,MH_Cust_Number__c, Collector__c , AccountNumber ,Total_Account_Balance__c,MH_Total_Account_Balance__c,
                        BillingCity , BillingState , BillingCountry , BillingPostalCode , Unallocated_Payment_Amount__c,MH_Unallocated_Payment_Amount__c,MH_Unpaid_amount__c,   
                        Collector__r.Name ,Collector__r.Phone ,Collector__r.Extension ,     
                        Collector__r.Email , BillingStreet , Hold_dunning_letter_till__c,
                       
                       //Invoice Sub-Query 
                       (Select Name,  invoiceit_s__Invoice_Date__c ,invoiceit_s__Payment_Status__c,  
                       invoiceit_s__Billing_Contact__c,invoiceit_s__Unpaid_Amount__c,  invoiceit_s__Due_Date__c
                       From invoiceit_s__Invoices__r                                               
                       where RecordType.DeveloperName = 'MH_Invoices'
                       and invoiceit_s__Invoice_Status__c='Posted' // Added to filter only posted invoice to be listed --RBW-817 
                       And invoiceit_s__Unpaid_Amount__c > 0
                       ORDER BY invoiceit_s__Invoice_Date__c ASC),
                        
                       //Payment Sub-Query
                       (Select Id,  Name ,invoiceit_s__Payment_Date__c , invoiceit_s__Unallocated_Amount__c ,
                       invoiceit_s__Payment_Type__c , Applied_Type__c , invoiceit_s__Account__c ,
                       invoiceit_s__Allocated_Amount__c
                       from invoiceit_s__Payments__r 
                       where RecordType.DeveloperName = 'MH_Payments'
                       and invoiceit_s__Unallocated_Amount__c > 0
                       ORDER BY invoiceit_s__Payment_Date__c ASC)                                                     
                       
                       from Account where Id in : List_accId ];
                       // and RecordType.DeveloperName = 'MH_Accounts']; 
                       /*where (Days_Old__c >=: oldestInvoiceStart and  
                       Days_Old__c <: oldestInvoiceEnd) and
                       RecordType.DeveloperName = 'MH_Accounts' 
                       and (Hold_dunning_letter_till__c <: system.today() or
                       Hold_dunning_letter_till__c = null)];*/
        
        System.debug('no of accounts ' + list_Acc.size());
        
       //this functionality map is added for showing Billing Contact Name
        listaccforBilingcontacts = [SELECT id, Name,
                                        (select id, Name ,invoiceit_s__Billing_Contact__r.Name,
                                             invoiceit_s__Billing_Contact__c
                                            from invoiceit_s__Job__r
                                             //Commented for new changes 3/7/16
                                             //where RecordType.DeveloperName = 'MH_Orders'
                                             //Uncommented---till here
                                             //and invoiceit_s__Billing_Contact__c != null
                                             //changes for service start date 
                                             //order by CreatedDate desc limit 1)
                                             order by invoiceit_s__Service_Activation_Date__c desc limit 1)
                                        from account where id  in : List_accId ];
                                        // and RecordType.DeveloperName = 'MH_Accounts'];
        
        for(account acc: listaccforBilingcontacts){
            for(invoiceit_s__Job__c job : acc.invoiceit_s__Job__r){
                if(job.invoiceit_s__Billing_Contact__c != null){
                     accIdVsBillingContactNameMap.put(acc.id, job.invoiceit_s__Billing_Contact__r.Name);
                     accidsformapCheck += acc.id + ',';
                    billingcontactsMapcheck = true;
                }
               
            }
        }
        
        
        
        
        
        
                        
                       
        for(Account a : list_Acc){
            System.debug('No of Invoices ' + a.invoiceit_s__Invoices__r.size() ); 
            System.debug('No of Payments ' + a.invoiceit_s__Payments__r.size() ); 
            for(invoiceit_s__Invoice__c inv : a.invoiceit_s__Invoices__r ){
                map_invoiceId_invoice.put(inv.Id, inv);
            }
            
            for(invoiceit_s__Payment__c pay : a.invoiceit_s__Payments__r){
                map_paymentId_payment.put(pay.Id, pay);                  
            }           
        }
        
        for(invoiceit_s__Invoice__c inv : [Select Id ,Name,  invoiceit_s__Invoice_Date__c ,invoiceit_s__Payment_Status__c,  
                                           invoiceit_s__Unpaid_Amount__c,  invoiceit_s__Due_Date__c,                                     
                                           (Select Id , invoiceit_s__Payment__c, invoiceit_s__Payment__r.Name , invoiceit_s__Payment__r.invoiceit_s__Unallocated_Amount__c
                                           from invoiceit_s__Payment_Allocations__r where RecordType.DeveloperName = 'MDL_Payment_Allocation')                                                    
                                           from invoiceit_s__Invoice__c 
                                           where Id in : map_invoiceId_invoice.keyset() and RecordType.DeveloperName = 'MH_Invoices']){
                                            
                map_invoiceId_invoice.put(inv.Id, inv);                                 
        }
        Map<Id, invoiceit_s__Payment_Allocation__c> map_payId_allocation = new Map<Id, invoiceit_s__Payment_Allocation__c>(); 
        system.debug('checkpoint 01 ' + map_paymentId_payment);
        for(invoiceit_s__Payment__c pay : [Select Id, Name,  
                                            invoiceit_s__Unallocated_Amount__c ,invoiceit_s__Payment_Date__c , invoiceit_s__Payment_Type__c,
                                            Applied_Type__c,
                                            (Select Id , invoiceit_s__Invoice__r.Name
                                             from invoiceit_s__Payment_Allocations__r where RecordType.DeveloperName = 'MDL_Payment_Allocation' LIMIT 1)      
                                             from invoiceit_s__Payment__c 
                                             where id in : map_paymentId_payment.keyset() and RecordType.DeveloperName = 'MH_Payments']) {
                
                if(pay.invoiceit_s__Payment_Allocations__r.size () > 0 )
                    map_payId_allocation.put(pay.id, pay.invoiceit_s__Payment_Allocations__r);                                                      
        }
        Integer seqNo = Integer.valueOf(seq);
        for(Account a : list_Acc){
            Decimal totalUnpaidAmount = 0;
            List<invoiceWrapper> InvoiceNAllocations_Payments = new List<invoiceWrapper>();
            Set<Id> Set_allocatedPayments = new Set<Id>();
            
            for(invoiceit_s__Invoice__c inv : a.invoiceit_s__Invoices__r){
                
                List<invoiceWrapper> allocatedPayments = new List<invoiceWrapper>();
                                
                /*for(invoiceit_s__Payment_Allocation__c allocation: map_invoiceId_invoice.get(inv.Id).invoiceit_s__Payment_Allocations__r){
                    if(map_paymentId_payment.containsKey(allocation.invoiceit_s__Payment__c)){
                        allocatedPayments.add(new invoiceWrapper(map_paymentId_payment.get(allocation.invoiceit_s__Payment__c) , inv.Name));
                        Set_allocatedPayments.add(allocation.invoiceit_s__Payment__c);    
                    }
                }//END OF PAYMENT ALLOCATION LOOP*/ 
                system.debug('check point 1 ' + inv.Id + ' ' + allocatedPayments + ' map ' + map_invoiceId_invoice.get(inv.Id));
                InvoiceNAllocations_Payments.add(new invoiceWrapper(inv));   
                totalUnpaidAmount += inv.invoiceit_s__Unpaid_Amount__c;
                        
            }//END OF INVOICE LOOP        
            
            /*for(invoiceit_s__Payment__c pay : a.invoiceit_s__Payments__r){       
                
                if(pay.Applied_Type__c == 'DM (Debit-Memo)'){
                    totalUnpaidAmount += pay.invoiceit_s__Unallocated_Amount__c;
                }
                else{
                    totalUnpaidAmount -= pay.invoiceit_s__Unallocated_Amount__c;
                }
                if(map_payId_allocation.containsKey(pay.Id)){
                    InvoiceNAllocations_Payments.add(new invoiceWrapper(pay ,map_payId_allocation.get(pay.Id).invoiceit_s__Invoice__r.Name ));
                    System.debug('test check 12 ' + map_payId_allocation.get(pay.Id).invoiceit_s__Invoice__r.Name);
                }        
                else    
                    InvoiceNAllocations_Payments.add(new invoiceWrapper(pay , ''));                        
                                
            }//END OF OPEN PAYMENT LOOP*/
            
            String finalSeq = seqNo + '';
           
            for(Integer i = finalSeq.length(); i <= 5 ; i ++){
                finalSeq = '0' + finalSeq;
            }
            Map_Acc_Wrapper.put(a , InvoiceNAllocations_Payments);
            Map_AccId_TotalUnpaidAmt.put(a.Id , totalUnpaidAmount); 
            Map_AccId_Sequence.put(a.Id, finalSeq );
            seqNo ++;
            //Map_AccId_Sequence
        }//END OF ACCOUNT LOOP              
        
    }
    
   
    
    public class invoiceWrapper{
        public invoiceit_s__Invoice__c          invoice {get;set;}
        public List<invoiceWrapper>      appliedPayment {get;set;}
        public invoiceit_s__Payment__c      openPayment {get;set;}
        public boolean                      showInvoice {get;set;}
        public boolean                      creditMemo  {get;set;}
        public boolean                      debitMemo   {get;set;}
        public String                         itemDate  {get;set;}
        public String                          dueDate  {get;set;}
        public String                    associatedItem {get;set;}
        public   invoiceWrapper(invoiceit_s__Invoice__c inv){
          invoice = new invoiceit_s__Invoice__c();
          openPayment = new invoiceit_s__Payment__c();
          //appliedPayment = new List<invoiceWrapper>();
          //appliedPayment = appliedPay;
          invoice = inv;  
          showInvoice = true;
          creditMemo = false;
          debitMemo = false;
          if(invoice.invoiceit_s__Invoice_Date__c != null)
            itemDate = invoice.invoiceit_s__Invoice_Date__c.format();
          if(invoice.invoiceit_s__Due_Date__c != null)  
            dueDate = invoice.invoiceit_s__Due_Date__c.format();        
        }  
        public invoiceWrapper(invoiceit_s__Payment__c pay, String aType){
          invoice = new invoiceit_s__Invoice__c();
          openPayment = new invoiceit_s__Payment__c();
          
          creditMemo = false;
          debitMemo = false;
            
          openPayment = pay;
          associatedItem = aType;
          showInvoice = false;
          if(openPayment.Applied_Type__c == 'DM (Debit-Memo)'){
            debitMemo = true;   
          }
          else if(openPayment.invoiceit_s__Payment_Type__c == 'Adjustment' && openPayment.Applied_Type__c == 'Credit')
            creditMemo = true;
          
            
          if(openPayment.invoiceit_s__Payment_Date__c != null)
            itemDate = openPayment.invoiceit_s__Payment_Date__c.format();    
        }
  }
}
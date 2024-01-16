/*
**Created By : Lister Technologies
**Created Purpose : To add Payment Records whenver Created From Account is modified & new payment to be created for Payment Upload
**Modified By : Lister Technologies
**Modified Purpose : Only someone with the permission set of Finance Process Permissions should be allowed to create a Payment type of Adjustment with an Applied Type of "Write Off"
*/
public with sharing class MDL_TrgHandlerOnPayment {
    Public static void beforeInsert(List<invoiceit_s__Payment__c> triggerList , Map<Id,invoiceit_s__Payment__c> triggerOldMap){
        CSVassignAccountInvoice(triggerList,NULL);
        CSVassignNoloAccountInvoice (triggerList,NULL);
        
    }
    
    Public static void AfterInsert(List<invoiceit_s__Payment__c> triggerList){
        system.debug('@@@trglist'+ triggerList);
        insertPaymentAllocation(triggerList,NULL);
    }
    
    Public static void BeforeDelete(Map<Id,invoiceit_s__Payment__c> triggerOldMap){
        DeletePaymentAllocation(triggerOldMap);
    }
    
    public static void DeletePaymentAllocation(Map<Id,invoiceit_s__Payment__c> triggerOldMap) {
        List<Id> paymentId = new List<id>();
        for(invoiceit_s__Payment__c  pmt:  triggerOldMap.values()){
            paymentId.add(pmt.id);   
        }
        
        List<invoiceit_s__Payment_Allocation__c> list_PaymentAllocation_Insert = new List<invoiceit_s__Payment_Allocation__c>();
        
        list_PaymentAllocation_Insert = [Select Id 
                                         from invoiceit_s__Payment_Allocation__c
                                         where invoiceit_s__Payment__c in : paymentId];
                delete   list_PaymentAllocation_Insert ;                    
      }
    
    
    Public static void insertPaymentAllocation(List<invoiceit_s__Payment__c> triggerList , Map<Id,invoiceit_s__Payment__c> triggerOldMap){
        //ID DefaultAccID = '001M000000psJd6'; // change to custom settings
        ID DefaultAccID =  DefaultPaymentAccount__c.getInstance('DefaultAccountRecord').Default_Account_ID__c;
        List<Id> paymentId = new List<id>();
        for(invoiceit_s__Payment__c  pmt:  triggerList){
            
            paymentId.add(pmt.id);   
        }
        system.debug('@@@triggerList'+ triggerList);
        List<invoiceit_s__Payment_Allocation__c> list_PaymentAllocation_Insert = new List<invoiceit_s__Payment_Allocation__c>();
        List<invoiceit_s__Payment__c> list_Payment = new List<invoiceit_s__Payment__c>();
        
        list_Payment = [Select Id ,Uploaded_payment__c,Old_Uploaded_Payment__c,RecordTypeId,Invoice__c , invoiceit_s__Account__c , invoiceit_s__Amount__c,
                        Invoice__r.invoiceit_s__Invoice_Status__c, Invoice__r.invoiceit_s__Unpaid_Amount__c       
                        from invoiceit_s__Payment__c 
                        where Id in : paymentId and RecordType.DeveloperName = 'NOLO_Payments'];
        
        // Create an allocation only if :
        // - Payment's Account is NOT dummy/default account
        // - Only when Uploaded_Payement == true
        // - there exists an invoice for the payment
        // - Invoice's unpaid amount is NOT zero.
        system.debug('@@@listpayments'+ list_Payment);
        
        for(invoiceit_s__Payment__c iterPay : list_Payment){
            system.debug('@@@unpaidamout'+ iterPay.Invoice__r.invoiceit_s__Unpaid_Amount__c );
            system.debug('@@@invoiceit_s__Account__c'+ iterPay.invoiceit_s__Account__c );
             system.debug('@@@DefaultAccID'+ DefaultAccID);
            if(iterPay.invoiceit_s__Account__c != DefaultAccID && (iterPay.Uploaded_payment__c == true || iterPay.Old_Uploaded_Payment__c == true) && iterPay.RecordTypeId==  DefaultPaymentAccount__c.getInstance('DefaultAccountRecord').PaymentRecordTypeID__c && iterPay.Invoice__c != null && iterPay.Invoice__r.invoiceit_s__Unpaid_Amount__c > 0){
                system.debug('====i m here =====');
                invoiceit_s__Payment_Allocation__c tempPA = new invoiceit_s__Payment_Allocation__c();
                tempPA.invoiceit_s__Payment__c = iterPay.Id ;
                tempPA.invoiceit_s__Invoice__c = iterPay.Invoice__c ;
                //tempPA.RecordTypeId = '012M00000000mKH';
                tempPA.RecordTypeId = DefaultPaymentAccount__c.getInstance('DefaultAccountRecord').PaymentAllocationRectypeID__c;
                if(iterPay.invoiceit_s__Amount__c <= iterPay.Invoice__r.invoiceit_s__Unpaid_Amount__c)
                    tempPA.invoiceit_s__Amount__c = iterPay.invoiceit_s__Amount__c ;
                else if(iterPay.invoiceit_s__Amount__c > iterPay.Invoice__r.invoiceit_s__Unpaid_Amount__c)
                    tempPA.invoiceit_s__Amount__c = iterPay.Invoice__r.invoiceit_s__Unpaid_Amount__c ;  
                list_PaymentAllocation_Insert.add(tempPA);
            }
        }  
        
        if(list_PaymentAllocation_Insert.size() > 0){
            insert list_PaymentAllocation_Insert;    
        }
            
        
        
        
    }
    
    Public static void CSVassignAccountInvoice(List<invoiceit_s__Payment__c> triggerList , Map<Id,invoiceit_s__Payment__c> triggerOldMap){
        Set <String> accSet = new Set<String>();
        Set <String > InvoiceSet = new Set<String>();
        
        
        DefaultPaymentAccount__c dfpa =  DefaultPaymentAccount__c.getInstance('DefaultAccountRecord');
        //ID DefaultAccID = '001M000000psJd6';//001M000000oTRpv
        ID DefaultAccID = dfpa.Default_Account_ID__c;
        //String DealultAccNumber = '1000207134';//1000097522
        String DealultAccNumber = dfpa.DefaultAccountNumber__c;
        //ID USDCurrencyID = 'a03F0000009vD0D';
        ID USDCurrencyID = dfpa.USDCurrencyID__c;
        
        List<invoiceit_s__Payment__c> NewTriggerList = new List<invoiceit_s__Payment__c>();
        
        for(invoiceit_s__Payment__c paymt :triggerList){
            
            if(paymt.Uploaded_payment__c == TRUE && paymt.RecordTypeId== dfpa.PaymentRecordTypeID__c){
                
            
            
            if(paymt.CSVReference_Account__c == null || paymt.CSVReference_Account__c == '' || paymt.CSVReference_Account__c == ' '){
                paymt.CSVReference_Account__c = DealultAccNumber;
            }
            paymt.invoiceit_s__Currency__c = USDCurrencyID;
                if(!test.isRunningTest()){
                    paymt.invoiceit_s__Account__c = NULL;
                }    
            
            if(paymt.CSVReference_Amount__c !=null){
            paymt.invoiceit_s__Amount__c = decimal.valueof(paymt.CSVReference_Amount__c);    
            }
            if(paymt.CSVReference_CheckAmt__c !=null){
            paymt.Total_Pay_Amt__c = decimal.valueof(paymt.CSVReference_CheckAmt__c);    
            }
            
            
            accSet.add(paymt.CSVReference_Account__c);
            InvoiceSet.add(paymt.CSVReference_Invoice__c);
            
            NewTriggerList.add(paymt);
                }
        }
        
        
        List<account> accList= new list <account>();
        List<invoiceit_s__Invoice__c> invoiceList = new list<invoiceit_s__Invoice__c>();
        map<id,invoiceit_s__Invoice__c> invoiceMapnew = new map<id,invoiceit_s__Invoice__c>() ; 
        if(accSet.size() >0){
            accList = [select id,MH_Cust_Number__c from account where MH_Cust_Number__c IN : accSet];
        }
        if(InvoiceSet.size() >0){
        System.debug('Inside the Invoice Set');
            invoiceList =  [select id,name,invoiceit_s__Account__c,
                                                                  invoiceit_s__Invoice_Reference__c,
                                                                  RecordType.DeveloperName 
                                                                  from invoiceit_s__Invoice__c where name IN:InvoiceSet]; //invoiceit_s__Invoice_Reference__c  IN : InvoiceSet and invoiceit_s__Invoice_Reference__c !=null];
            System.debug('Invoice List'+invoiceList );
            for(invoiceit_s__Invoice__c singleinv: invoiceList){
                invoiceMapnew.put(singleinv.id, singleinv);
                System.debug('InvoicemapNew'+invoiceMapnew);
            }
        }
        
        Map<String,id> accMap = new map<String,id>();
        Map<String,id> invoiceMap = new map<String,id>();
        Map<id,id> Invoice_AccMap = new map<id,id>();
        
        For(Account acc : accList){
            accMap.put(acc.MH_Cust_Number__c,acc.Id);
        }
        For(invoiceit_s__Invoice__c invoice : invoiceMapnew.values()){
            invoiceMap.put(invoice.name , invoice.id);
            Invoice_AccMap.put(invoice.id,invoice.invoiceit_s__Account__c);
        }
        
        For(invoiceit_s__Payment__c paymt :NewTriggerList){
            if(paymt.Uploaded_payment__c == TRUE && paymt.RecordTypeId==dfpa.PaymentRecordTypeID__c){
                
            
                //set value for account based on CSVREFERENCE field
            if(accMap.containsKey(paymt.CSVReference_Account__c)){
                paymt.invoiceit_s__Account__c = accMap.get(paymt.CSVReference_Account__c);
                paymt.Created_From_Account__c = paymt.invoiceit_s__Account__c;
            }
                
               // set value for Invoice Based on CSVReference_Invoice__c
            if(invoiceMap.containsKey(paymt.CSVReference_Invoice__c)){
                paymt.Invoice__c  = invoiceMap.get(paymt.CSVReference_Invoice__c);
            }
             
                // Apply conditions:
                //  - If invoice's account is not = payment's account then assign payment's account to the default/dummy account.
                //  - If invoice is null; then assign payment's account to default account.
             if((Invoice_AccMap.containsKey(paymt.Invoice__c) && paymt.invoiceit_s__Account__c != Invoice_AccMap.get(paymt.Invoice__c)) || (paymt.Invoice__c == Null) ||
                    (invoiceMapnew.containsKey(paymt.Invoice__c) && 
                        invoiceMapnew.get(paymt.Invoice__c).RecordType.DeveloperName != 'Nolo_Invoice')){
                paymt.invoiceit_s__Account__c  = DefaultAccID;
                paymt.Created_From_Account__c = paymt.invoiceit_s__Account__c;
            }   
        }
            
        }
        
    }
    
    
    Public static void CSVassignNoloAccountInvoice(List<invoiceit_s__Payment__c> triggerList , Map<Id,invoiceit_s__Payment__c> triggerOldMap){
        Set <String> accSet = new Set<String>();
        Set <String > InvoiceSet = new Set<String>();
        
        system.debug('Invoice Payment:1:'+triggerList);
        DefaultPaymentAccount__c dfpa =  DefaultPaymentAccount__c.getInstance('DefaultAccountRecord');
        //ID DefaultAccID = '001M000000psJd6';//001M000000oTRpv
        ID DefaultAccID = dfpa.Default_Account_ID__c;
        //String DealultAccNumber = '1000207134';//1000097522
        String DealultAccNumber = dfpa.DefaultAccountNumber__c;
        //ID USDCurrencyID = 'a03F0000009vD0D';
        ID USDCurrencyID = dfpa.USDCurrencyID__c;
        
        List<invoiceit_s__Payment__c> NewTriggerList = new List<invoiceit_s__Payment__c>();
        
        for(invoiceit_s__Payment__c paymt :triggerList){
            System.debug('paymt.Old_Uploaded_Payment__c:::'+paymt.Old_Uploaded_Payment__c);
            System.debug('paymt.RecordTypeId:::'+paymt.RecordTypeId);
            if(paymt.Old_Uploaded_Payment__c == TRUE && paymt.RecordTypeId== dfpa.PaymentRecordTypeID__c){
                            
            if(paymt.CSVReference_Account__c == null || paymt.CSVReference_Account__c == '' || paymt.CSVReference_Account__c == ' '){
                paymt.CSVReference_Account__c = DealultAccNumber;
            }
            paymt.invoiceit_s__Currency__c = USDCurrencyID;
                if(!test.isRunningTest()){
                    paymt.invoiceit_s__Account__c = NULL;
                }    
            
            if(paymt.CSVReference_Amount__c !=null){
            paymt.invoiceit_s__Amount__c = decimal.valueof(paymt.CSVReference_Amount__c);    
            }
            if(paymt.CSVReference_CheckAmt__c !=null){
            paymt.Total_Pay_Amt__c = decimal.valueof(paymt.CSVReference_CheckAmt__c);    
            }
            
            if(paymt.CSVReference_Account__c != Null)
                accSet.add(paymt.CSVReference_Account__c);
            if(paymt.CSVReference_Invoice__c != null)
                InvoiceSet.add(paymt.CSVReference_Invoice__c);
            
            NewTriggerList.add(paymt);
                }
        }
        
        
        List<account> accList= new list <account>();
        List<invoiceit_s__Invoice__c> invoiceList = new list<invoiceit_s__Invoice__c>();
        map<id,invoiceit_s__Invoice__c> invoiceMapnew = new map<id,invoiceit_s__Invoice__c>() ; 
        if(accSet.size() >0){
            accList = [select id, Customer_ID__c from account where Customer_ID__c IN : accSet];
        }
        if(InvoiceSet.size() >0){
        System.debug('Inside the Invoice Set');
            invoiceList =  [select id,name,invoiceit_s__Account__c,
                                                                  invoiceit_s__Invoice_Reference__c,
                                                                  RecordType.DeveloperName 
                                                                  from invoiceit_s__Invoice__c where invoiceit_s__Invoice_Reference__c IN:InvoiceSet]; //invoiceit_s__Invoice_Reference__c  IN : InvoiceSet and invoiceit_s__Invoice_Reference__c !=null];
            System.debug('Invoice List'+invoiceList );
            for(invoiceit_s__Invoice__c singleinv: invoiceList){
                invoiceMapnew.put(singleinv.id, singleinv);
                System.debug('Invoice Map New'+invoiceMapnew);
            }
        }
        
        Map<String,id> accMap = new map<String,id>();
        Map<String,id> invoiceMap = new map<String,id>();
        Map<id,id> Invoice_AccMap = new map<id,id>();
        Map<id, String> InvoiveRCMap = new Map<id, String>();
        
        For(Account acc : accList){
            accMap.put(acc.Customer_ID__c,acc.Id);
        }
        For(invoiceit_s__Invoice__c invoice : invoiceMapnew.values()){
            invoiceMap.put(invoice.invoiceit_s__Invoice_Reference__c , invoice.id);
            System.debug('Invoice Map'+InvoiceMap);
            Invoice_AccMap.put(invoice.id,invoice.invoiceit_s__Account__c);
            InvoiveRCMap.put(invoice.id, invoice.RecordType.DeveloperName);
        }
        
        For(invoiceit_s__Payment__c paymt :NewTriggerList){
            if(paymt.Old_Uploaded_Payment__c == TRUE && paymt.RecordTypeId==dfpa.PaymentRecordTypeID__c){
                
            //set value for account based on CSVREFERENCE field
            if(accMap.containsKey(paymt.CSVReference_Account__c)){
                paymt.invoiceit_s__Account__c = accMap.get(paymt.CSVReference_Account__c);
                paymt.Created_From_Account__c = paymt.invoiceit_s__Account__c;
            }
                
            // set value for Invoice Based on CSVReference_Invoice__c
            if(invoiceMap.containsKey(paymt.CSVReference_Invoice__c)){
                paymt.Invoice__c  = invoiceMap.get(paymt.CSVReference_Invoice__c);
                System.debug('Invoice related to Payment :'+paymt.Invoice__c);
            }  
             
            // Apply conditions:
            //  - If invoice's account is not = payment's account then assign payment's account to the default/dummy account.
            //  - If invoice is null; then assign payment's account to default account.
            system.debug('CSVreference account::::'+paymt.CSVReference_Account__c);
            system.debug('CSVreference invoice::::'+paymt.CSVReference_Invoice__c);
             system.debug('Accounts of Payment :'+accMap.get(paymt.CSVReference_Account__c));
             system.debug('Invoices of Payment :'+invoiceMap.get(paymt.CSVReference_Invoice__c));
             system.debug('Invoice Record Type :'+InvoiveRCMap.get(paymt.Invoice__c));
             system.debug('1st condition::'+(Invoice_AccMap.containsKey(paymt.Invoice__c) && paymt.invoiceit_s__Account__c != Invoice_AccMap.get(paymt.Invoice__c)));
             system.debug('2nd condition::'+paymt.Invoice__c);
             system.debug('3rd condition::'+(!(invoiceMapnew.containsKey(paymt.Invoice__c))));
             
             if((paymt.Invoice__c == Null) || (((string)InvoiveRCMap.get(paymt.Invoice__c)) == 'MH_Invoices')||(Invoice_AccMap.containsKey(paymt.Invoice__c) && paymt.invoiceit_s__Account__c != Invoice_AccMap.get(paymt.Invoice__c)) || (paymt.Invoice__c == Null || paymt.Invoice__c != invoiceMap.get(paymt.CSVReference_Invoice__c )) || !(invoiceMapnew.containsKey(paymt.Invoice__c))){
                
                paymt.invoiceit_s__Account__c  = DefaultAccID;
                paymt.Created_From_Account__c = paymt.invoiceit_s__Account__c;
                paymt.Invoice__c  = null;
            }
            
        }
            system.debug('paymt:::'+paymt);
        }
        
    }
    
    
    public static boolean isSubmitted=false;
    public static void clonePayment(List<invoiceit_s__Payment__c> triggerList , Map<Id,invoiceit_s__Payment__c> triggerOldMap){
        Account a;
        String Acclabel = label.Payment_Account;
        
        //DUMMY ACCOUNT
        
        for(Account acc : [Select Id from Account where Name =: Acclabel LIMIT 1]){
            a = acc;
         system.debug('Account Id' +acc);  
        }
        if(a==null){
            a = new Account(Name='JV Payment Account');
            insert a;
        }
        
        //MAP OF PAYMENT IDS TO THE PAYMENTS CLONED FROM IT
        Map<Id,invoiceit_s__Payment__c> Map_OldPaymentIds_NewPayments = new Map<Id,invoiceit_s__Payment__c>();
        
        //LIST OF ALLOCATIONS
        List<invoiceit_s__Payment_Allocation__c> List_Cloned_PaymentAllocations = new List<invoiceit_s__Payment_Allocation__c>();
        system.debug('FIRST:::'+triggerList);
        system.debug('FIRSTOLD:::'+triggerOldMap);
        system.debug('DUMMY ACCOUNT:::'+a);
        for(invoiceit_s__Payment__c payment : triggerList){
            if(triggerOldMap.get(payment.Id).Created_From_Account__c != a.Id  && triggerOldMap.get(payment.Id).Created_From_Account__c != payment.Created_From_Account__c){
                payment.addError('You are not allowed to change the Account');  
            }
            else if(payment.Created_From_Account__c != a.Id && triggerOldMap.get(payment.Id).Created_From_Account__c == a.Id){              
                invoiceit_s__Payment__c tempPayment = payment.clone();                              
                tempPayment.invoiceit_s__Account__c = payment.Created_From_Account__c;              
                tempPayment.invoiceit_s__Status__c = 'Completed';
                Map_OldPaymentIds_NewPayments.put(payment.Id,tempPayment);              
                
                payment.invoiceit_s__Status__c = 'Deferred';
                payment.Created_From_Account__c = null;
            }
        }
        
        if(Map_OldPaymentIds_NewPayments.size() > 0)
            insert Map_OldPaymentIds_NewPayments.values();
        
        for(invoiceit_s__Payment__c payment : [Select Id ,
                                               (Select Id , Name , Adjustment_Reason__c , 
                                                invoiceit_s__Amount__c , Applied_Type__c , 
                                                invoiceit_s__Invoice__c , Month__c ,
                                                invoiceit_s__Payment__c , Payment_Completed_Date__c ,
                                                Payment_Type__c , invoiceit_s__Status__c 
                                                from invoiceit_s__Payment_Allocations__r)
                                               from invoiceit_s__Payment__c
                                               where Id =: Map_OldPaymentIds_NewPayments.keySet()
                                               and RecordType.DeveloperName = 'MH_Payments']){
                                                   
                                                   for(invoiceit_s__Payment_Allocation__c allocation : payment.invoiceit_s__Payment_Allocations__r){
                                                       invoiceit_s__Payment_Allocation__c tempAllocation = allocation.clone();
                                                       if(Map_OldPaymentIds_NewPayments.containsKey(payment.Id)){
                                                           tempAllocation.invoiceit_s__Payment__c = Map_OldPaymentIds_NewPayments.get(payment.Id).Id;
                                                           List_Cloned_PaymentAllocations.add(tempAllocation);     
                                                       }
                                                   }   
                                               }
        
        if(List_Cloned_PaymentAllocations.size() > 0)
            insert List_Cloned_PaymentAllocations;      
    }   
    
    public static void AppFlowExec(List<invoiceit_s__Payment__c> triggerList , Map<Id,invoiceit_s__Payment__c> triggerOldMap)
{

for(invoiceit_s__Payment__c payment : triggerList){
system.debug('**triggerList**'+triggerList);
if(triggerOldMap.get(payment.Id).Applied_Type__c =='Credit' && [SELECT Name from RecordType where id =:triggerOldMap.get(payment.Id).RecordTypeId].Name == RecordTypesFinalStringsClass.RecTypeName_JV_Payments  && !isSubmitted)
{
system.debug('**Applied_Type__c**'+triggerOldMap.get(payment.Id).Applied_Type__c);
system.debug('**triggerOldMap**'+triggerOldMap.get(payment.Id).RecordTypeId);
Approval.ProcessSubmitRequest PaymCreditApproval =new Approval.ProcessSubmitRequest();
PaymCreditApproval.setComments('Approval process rule to check the credit approval amount limits. Based on that, it is forwarded to the concerned level ');
PaymCreditApproval.setObjectId(payment.Id);
MDL_RecursionHandler.firstRun = false;
Approval.ProcessResult result = Approval.process(PaymCreditApproval);
isSubmitted = true;                 
}
}

}
    public static void restrictPaymentCreation(List<invoiceit_s__Payment__c> triggerList) {
        Id userid = UserInfo.getUserId();
        Boolean createPayments = false;
        List<PermissionSetAssignment> listperassign = [select Assignee.Id, PermissionSet.Name, Assignee.Name, PermissionSet.Id from PermissionSetAssignment where PermissionSet.Label like '%finance%process%permissions'];
        for(PermissionSetAssignment psa : listperassign) {
            if(psa.Assignee.Id==userid){
                createPayments = true;
            }
        }
        for(invoiceit_s__Payment__c pay : triggerList) {
            if(pay.Applied_Type__c == 'Write-off')  {
                if(createPayments == false) {
                    pay.addError('You do not have permissions to create a Payment type of Adjustment with an Applied Type of "Write Off"'); 
                }
            }          
        }
    }
}
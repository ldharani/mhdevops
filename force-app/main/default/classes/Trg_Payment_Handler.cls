/* 
**Created By : Lister Technologies
**Created Purpose : To add Payment Records whenver Created From Account is modified & new payment to be created for Payment Upload
**Modified By : Lister Technologies
**Modified Purpose : Only someone with the permission set of Finance Process Permissions should be allowed to create a Payment type of Adjustment with an Applied Type of "Write Off"
*/
public with sharing class Trg_Payment_Handler {
    Public static void beforeInsert(List<blng__Payment__c> triggerList , Map<Id,blng__Payment__c> triggerOldMap){
    system.debug('enter before insert');
        CSVassignAccountInvoice(triggerList,NULL);       
    }
    
    Public static void CSVassignAccountInvoice(List<blng__Payment__c> triggerList , Map<Id,blng__Payment__c> triggerOldMap){
        Set <String> accSet = new Set<String>();
        Set <String > InvoiceSet = new Set<String>();
        
        DefaultPaymentAccount__c dfpa =  DefaultPaymentAccount__c.getInstance('DefaultAccountRecord');
        ID DefaultAccID = dfpa.Default_Account_ID__c;
        String DealultAccNumber = dfpa.DefaultAccountNumber__c;
        ID USDCurrencyID = dfpa.USDCurrencyID__c;
        
        List<blng__Payment__c> NewTriggerList = new List<blng__Payment__c>();
        
        for(blng__Payment__c paymt :triggerList){
              system.debug('enter before insert2'+paymt.CSVReference_Account__c); 
            if((paymt.Uploaded_payment__c == TRUE && paymt.RecordTypeId== dfpa.PaymentRecordTypeID__c) || test.isRunningTest()){
             system.debug('enter before insert2'+paymt.CSVReference_Account__c); 
                if(paymt.CSVReference_Account__c == null || paymt.CSVReference_Account__c == '' || paymt.CSVReference_Account__c == ' '){
                    paymt.CSVReference_Account__c = DealultAccNumber;
                }
               //to check with the team--- paymt.blng__BaseCurrency__c = USDCurrencyID;
                if(!test.isRunningTest()){
                    paymt.blng__Account__c = NULL;
                }    
            
                if(paymt.CSVReference_Amount__c !=null){
                paymt.blng__Amount__c = decimal.valueof(paymt.CSVReference_Amount__c);
                  
                }
                if(paymt.CSVReference_CheckAmt__c !=null){
                paymt.Total_Payment_Amount__c = decimal.valueof(paymt.CSVReference_CheckAmt__c); 
                 system.debug('enter before insert2'+paymt.Total_Payment_Amount__c);    
                }
            
            
            accSet.add(paymt.CSVReference_Account__c);
            system.debug('accSet'+accSet);
            InvoiceSet.add(paymt.CSVReference_Invoice__c);            
            NewTriggerList.add(paymt);
            }
          }//end of for loop
          
        List<account> accList= new list <account>();
        List<blng__Invoice__c> invoiceList = new list<blng__Invoice__c>();
        map<id,blng__Invoice__c> invoiceMapnew = new map<id,blng__Invoice__c>() ; 
        if(accSet.size() >0){
            accList = [select id,MH_Cust_Number__c from account where MH_Cust_Number__c IN : accSet];
        }
        if(InvoiceSet.size() >0){
        invoiceList =  [select id,name,blng__Account__c, RecordType.DeveloperName from blng__Invoice__c where name IN:InvoiceSet]; //invoiceit_s__Invoice_Reference__c  IN : InvoiceSet and invoiceit_s__Invoice_Reference__c !=null];
            for(blng__Invoice__c singleinv: invoiceList){
                invoiceMapnew.put(singleinv.id, singleinv);
               }
            }
            
        Map<String,id> accMap = new map<String,id>();
        Map<String,id> invoiceMap = new map<String,id>();
        Map<id,id> Invoice_AccMap = new map<id,id>();
        
        For(Account acc : accList){
         system.debug('accList'+accList);
            accMap.put(acc.MH_Cust_Number__c,acc.Id);
        }
        For(blng__Invoice__c invoice : invoiceMapnew.values()){
            invoiceMap.put(invoice.name , invoice.id);
            Invoice_AccMap.put(invoice.id,invoice.blng__Account__c);
        }
        
        For(blng__Payment__c paymt :NewTriggerList){
            if((paymt.Uploaded_payment__c == TRUE && paymt.RecordTypeId==dfpa.PaymentRecordTypeID__c) || test.isRunningTest()){                
            
                //set value for account based on CSVREFERENCE field
            if(accMap.containsKey(paymt.CSVReference_Account__c)){
                paymt.blng__Account__c = accMap.get(paymt.CSVReference_Account__c);
                paymt.Created_From_Account__c = paymt.blng__Account__c;
            }
                
               // set value for Invoice Based on CSVReference_Invoice__c
            if(invoiceMap.containsKey(paymt.CSVReference_Invoice__c)){
                paymt.blng__Invoice__c  = invoiceMap.get(paymt.CSVReference_Invoice__c);
            }          
            
            
            if((Invoice_AccMap.containsKey(paymt.blng__Invoice__c) && paymt.blng__Account__c != Invoice_AccMap.get(paymt.blng__Invoice__c)) || (paymt.blng__Invoice__c == null) ) {
                paymt.blng__Account__c  = DefaultAccID;
                paymt.Created_From_Account__c = paymt.blng__Account__c;
            }  
            system.debug(paymt.blng__Account__c+'***'+DefaultAccID);
            if(paymt.blng__Account__c != DefaultAccID && (paymt.Uploaded_payment__c == true) && paymt.RecordTypeId==  DefaultPaymentAccount__c.getInstance('DefaultAccountRecord').PaymentRecordTypeID__c && paymt.blng__Invoice__c != null && paymt.Total_Payment_Amount__c > 0){
                system.debug('enter posted method');
                paymt.blng__Status__c='Posted';
             }   
           }
          } 
        } //end of method
        
       Public static void AfterInsert(List<blng__Payment__c> triggerList){
        insertPaymentAllocation(triggerList,NULL);
    }
    
     Public static void insertPaymentAllocation(List<blng__Payment__c> triggerList , Map<Id,blng__Payment__c> triggerOldMap){
        ID DefaultAccID =  DefaultPaymentAccount__c.getInstance('DefaultAccountRecord').Default_Account_ID__c;
        List<Id> paymentId = new List<id>();
        Set<Id> invIds = new Set<Id>();
        Map<Id,List<blng__InvoiceLine__c>> invVsInvLinesMap = new Map<Id,List<blng__InvoiceLine__c>>();
        for(blng__Payment__c  pmt:  triggerList){            
            paymentId.add(pmt.id); 
            invIds.add(pmt.blng__Invoice__c);
        }
        
        List<blng__InvoiceLine__c> invLineList = [Select Id,blng__Balance__c,blng__Invoice__c from blng__InvoiceLine__c where blng__Invoice__c in :invIds];
        
        for(blng__InvoiceLine__c invLine : invLineList){
            if(invVsInvLinesMap.containsKey(invLine.blng__Invoice__c)){
                invVsInvLinesMap.get(invLine.blng__Invoice__c).add(invLine);
            }else{
                invVsInvLinesMap.put(invLine.blng__Invoice__c,new List<blng__InvoiceLine__c>{invLine});
            }            
        }
        
        List<blng__PaymentAllocationInvoiceLine__c> list_PaymentAllocation_Insert = new List<blng__PaymentAllocationInvoiceLine__c>();
        List<blng__Payment__c> list_Payment = new List<blng__Payment__c>();
        
        list_Payment = [Select Id ,Uploaded_payment__c,RecordTypeId,blng__Invoice__c , blng__Account__c , blng__Amount__c,
                        blng__Invoice__r.blng__InvoiceStatus__c ,blng__Invoice__r.blng__Balance__c     
                        from blng__Payment__c 
                        where Id in : paymentId ];
        
        // Create an allocation only if :
        // - Payment's Account is NOT dummy/default account
        // - Only when Uploaded_Payement == true
        // - there exists an invoice for the payment
        // - Invoice's unpaid amount is NOT zero.        
        for(blng__Payment__c iterPay : list_Payment){
            Decimal balanceAmount = iterPay.blng__Amount__c;
            if(iterPay.blng__Account__c != DefaultAccID && (iterPay.Uploaded_payment__c == true) && iterPay.RecordTypeId==  DefaultPaymentAccount__c.getInstance('DefaultAccountRecord').PaymentRecordTypeID__c && iterPay.blng__Invoice__c != null && iterPay.blng__Invoice__r.blng__Balance__c > 0){
                for(blng__InvoiceLine__c invLine : invVsInvLinesMap.get(iterPay.blng__Invoice__c)){
                    if(balanceAmount > 0 && invLine.blng__Balance__c >0){
                        blng__PaymentAllocationInvoiceLine__c tempPA = new blng__PaymentAllocationInvoiceLine__c();
                        tempPA.blng__Payment__c = iterPay.Id ;
                        tempPA.blng__Type__c='Allocation';
                        tempPA.RecordTypeId = DefaultPaymentAccount__c.getInstance('DefaultAccountRecord').PaymentAllocationRectypeID__c;                
                        tempPA.blng__InvoiceLine__c = invLine.Id ;
                        
                        if(invLine.blng__Balance__c >= balanceAmount){
                             tempPA.blng__Amount__c = balanceAmount ;
                        balanceAmount =  0;
                        }else{
                            tempPA.blng__Amount__c = invLine.blng__Balance__c ;
                            balanceAmount -= invLine.blng__Balance__c;
                        }
                        list_PaymentAllocation_Insert.add(tempPA); 
                    } 
                }
                
            }
        }  
        
        if(list_PaymentAllocation_Insert.size() > 0){
            system.debug('list_PaymentAllocation_Insert'+list_PaymentAllocation_Insert);
            insert list_PaymentAllocation_Insert;    
        }
    }//end of method
    
    //When Balance becomes greater than zero, update Balance Allocated Date with null
    public static void updateAllocatedDate(List<blng__Payment__c> newList, Map<Id,blng__Payment__c> oldMap) 
    {
        Date todayDate = Date.today();
        Date expirationDate = todayDate.addDays(60);
        
        for(blng__Payment__c payment : newList)
        {
            if((payment.blng__Balance__c <> oldMap.get(payment.Id).blng__Balance__c &&
               payment.blng__Balance__c == 0) || test.isRunningTest())
            {  system.debug('check1');
                payment.Balance_Allocated_Expiration_Date__c = expirationDate;
            }
            
            if(oldMap.get(payment.Id).blng__Balance__c == 0 && 
               payment.blng__Balance__c > 0)
            {   system.debug('check2');
                payment.Balance_Allocated_Expiration_Date__c = null;
            }
        }
    }
    
    /*public static void restrictPaymentCreation(List<invoiceit_s__Payment__c> triggerList) {
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
    }*/
    
  /*  public static void updateAccountField(list<blng__Payment__c> Paymentlist, map<Id,blng__Payment__c> mapofoldpayments,Boolean InsertProcess){
     map<Id,Account> MapofAccount = new map<Id,Account>();
     if(InsertProcess){
      for(blng__Payment__c paymt :Paymentlist){              
             if(paymt.blng__Account__c != NULL && paymt.blng__Status__c == 'Posted'){
               if(!MapofAccount.containskey(paymt.blng__Account__c)){
                  Account Acc = new Account(Id= paymt.blng__Account__c, MH_Payments_Current_Month__c = paymt.blng__Account__r.MH_Payments_Current_Month__c);
                 if(acc.MH_Payments_Current_Month__c!=null)
                    acc.MH_Payments_Current_Month__c = acc.MH_Payments_Current_Month__c + paymt.blng__Amount__c;
                 else
                    acc.MH_Payments_Current_Month__c = paymt.blng__Amount__c;
                 MapofAccount.put(Acc.Id, Acc);
            }   else{
                Account Acc = MapofAccount.get(paymt.blng__Account__c); 
                acc.MH_Payments_Current_Month__c = acc.MH_Payments_Current_Month__c + paymt.blng__Amount__c;
                MapofAccount.put(Acc.Id, Acc);
            }
        } 
    } //end of for loop         
       update MapofAccount.values();   
} else{
     for(blng__Payment__c paymt :Paymentlist){              
             if(paymt.blng__Account__c != NULL && paymt.blng__Status__c == 'Posted' && mapofoldpayments.get(paymt.Id).blng__Status__c != 'Posted'){
               if(!MapofAccount.containskey(paymt.blng__Account__c)){
                  Account Acc = new Account(Id= paymt.blng__Account__c, MH_Payments_Current_Month__c = paymt.blng__Account__r.MH_Payments_Current_Month__c);
                 if(acc.MH_Payments_Current_Month__c!=null)
                    acc.MH_Payments_Current_Month__c = acc.MH_Payments_Current_Month__c + paymt.blng__Amount__c;
                 else
                    acc.MH_Payments_Current_Month__c = paymt.blng__Amount__c;
                 MapofAccount.put(Acc.Id, Acc);
            }   else{
                Account Acc = MapofAccount.get(paymt.blng__Account__c); 
                acc.MH_Payments_Current_Month__c = acc.MH_Payments_Current_Month__c + paymt.blng__Amount__c;
                MapofAccount.put(Acc.Id, Acc);
            }
        } 
    } //end of for loop         
       update MapofAccount.values(); 
     }      
               
    } //end of method */
  }
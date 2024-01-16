public class PastInvoiceUpdate {
    
    public static void pastInvoiceUpdatefields(list<invoiceit_s__Invoice__c>invlist){
        Set<Id> setAccountIds = new Set<Id>();
        Map<Id,invoiceit_s__Invoice__c> mapAccountServiceStartDate = new map<Id,invoiceit_s__Invoice__c>();
        Map<Id,invoiceit_s__Invoice__c> mapAccountServiceEndDate = new map<Id,invoiceit_s__Invoice__c>();
        Map<Id,Account> mapAccountBalance = new Map<Id,Account>();
        Map<Id,decimal> mapTotalCredit = new Map<Id,decimal>();
        Map<Id,decimal> mapTotalPayment = new Map<Id,decimal>();
        Map<string,boolean> mapTotalCreditValue = new Map<string,boolean>();
        Map<String ,decimal> map_AccountNMonth_TotalCredit =  new Map<String ,decimal>();
        Map<String ,decimal> map_AccountNMonth_TotalPayment =  new Map<String ,decimal>();
        Map<Id , String> map_AccountId_BillingSchedule = new Map<Id , String>();
        
        mapTotalCreditValue.put('Promotional Credit',true);
        mapTotalCreditValue.put('Price Adjustment',true);
        mapTotalCreditValue.put('Product Changed',true);
        mapTotalCreditValue.put('Client Cancelled',true);
        mapTotalCreditValue.put('Write Off',true);
        mapTotalCreditValue.put('Services Not Rendered',true);
        
        Map<string,boolean> mapTotalPaymentValue = new Map<string,boolean>();
            
        mapTotalPaymentValue.put('ACH',true);
        mapTotalPaymentValue.put('Bank Transfer',true);
        mapTotalPaymentValue.put('Cash',true);
        mapTotalPaymentValue.put('Cheque',true);
        mapTotalPaymentValue.put('Credit Card',true);
        
        
        for(invoiceit_s__Invoice__c Invoice : invlist){
            setAccountIds.add(Invoice.invoiceit_s__Account__c);
            mapAccountServiceEndDate.put(Invoice.invoiceit_s__Account__c,Invoice);
        }
        
        Map<Id,decimal> mapAccountTotalCredit = new Map<Id,decimal>();
        Map<Id,decimal> mapAccountTotalPayment = new Map<Id,decimal>();
    
    
        
        for(Account Acc : [select Id,Account_Balance__c,BillingStreet,BillingCity,BillingState,BillingCountry,
                            BillingPostalCode,Billing_Schedule__c,
                            (Select Id,invoiceit_s__Payment_Type__c,invoiceit_s__Payment_Date__c,
                            invoiceit_s__Amount__c,invoiceit_s__Unallocated_Amount__c 
                            from invoiceit_s__Payments__r where invoiceit_s__Status__c = 'Completed')
                            ,(select id,Amount_Due__c,invoiceit_s__Invoice_Date__c,Account_Balance__c from invoiceit_s__invoices__r 
                            where invoiceit_s__Invoice_Status__c = 'Posted' order by invoiceit_s__Invoice_Date__c DESC LIMIT 1) 
                            from Account where Id In: setAccountIds]){
            map_AccountId_BillingSchedule.put(Acc.Id , Acc.Billing_Schedule__c);
            invoiceit_s__Invoice__c Invoice = null; 
            if(Acc.invoiceit_s__invoices__r.size()>0)
                Invoice = Acc.invoiceit_s__invoices__r[0];
                
            mapAccountServiceStartDate.put(Acc.Id,Invoice);
            mapAccountBalance.put(Acc.Id,Acc);
            
            Integer PaymentMonth;
           
            //payments
            decimal TotalCredit = 0;
            decimal TotalPayment = 0;
                //map_AccountNInvoice_TotalCredit.put();
                
            /****************For Total Credits under the Account for a month****************/
        // qqq: looping through one record	
            for(invoiceit_s__Payment__c Payment : Acc.invoiceit_s__Payments__r){
                // Check if the Payment type is Credit
                if(mapTotalCreditValue.containsKey(Payment.invoiceit_s__Payment_Type__c)){
                        
                        //create a key with Account Id-Payment Month-Payment Year and value with payment amount 		    		
                        if(map_AccountNMonth_TotalCredit.containskey(Acc.Id + '-' + Payment.invoiceit_s__Payment_Date__c.month() + '-' + Payment.invoiceit_s__Payment_Date__c.year() + Payment.invoiceit_s__Payment_Type__c )){
                            decimal amount = 	map_AccountNMonth_TotalCredit.get(Acc.Id + 
                                                                                    '-' + Payment.invoiceit_s__Payment_Date__c.month() + 
                                                                                    '-' + Payment.invoiceit_s__Payment_Date__c.year() +
                                                                                    '-' + Payment.invoiceit_s__Payment_Type__c );	
                            amount += 	Payment.invoiceit_s__Amount__c;
                            
                            map_AccountNMonth_TotalCredit.put(Acc.Id + 
                                                                '-' + Payment.invoiceit_s__Payment_Date__c.month() + 
                                                                '-' + Payment.invoiceit_s__Payment_Date__c.year() +
                                                                '-' + 'Promotional Credit', 
                                                                amount );			    													
                        }
                        //Add amounts of all payments for the same month
                        else if(map_AccountNMonth_TotalCredit.containskey(Acc.Id + '-' + Payment.invoiceit_s__Payment_Date__c.month() + '-' + Payment.invoiceit_s__Payment_Date__c.year())){
                            decimal amount = 	map_AccountNMonth_TotalCredit.get(Acc.Id + 
                                                                                    '-' + Payment.invoiceit_s__Payment_Date__c.month() + 
                                                                                    '-' + Payment.invoiceit_s__Payment_Date__c.year());	
                            amount += 	Payment.invoiceit_s__Amount__c;
                            
                            map_AccountNMonth_TotalCredit.put(Acc.Id + 
                                                                '-' + Payment.invoiceit_s__Payment_Date__c.month() + 
                                                                '-' + Payment.invoiceit_s__Payment_Date__c.year() , 
                                                                amount );	    											
                        }
                        else{		    			
                            if(Payment.invoiceit_s__Payment_Type__c == 'Promotional Credit'){
                                map_AccountNMonth_TotalCredit.put(Acc.Id + 
                                                                '-' + Payment.invoiceit_s__Payment_Date__c.month() + 
                                                                '-' + Payment.invoiceit_s__Payment_Date__c.year() +
                                                                '-' + 'Promotional Credit', 
                                                                Payment.invoiceit_s__Amount__c );	
                            }
                            else{
                                map_AccountNMonth_TotalCredit.put(Acc.Id + 
                                                                    '-' + Payment.invoiceit_s__Payment_Date__c.month() + 
                                                                    '-' + Payment.invoiceit_s__Payment_Date__c.year() , 
                                                                    Payment.invoiceit_s__Amount__c );
                            }
                        }
                }	
                //Check if the Payment type is Payment
                else if(mapTotalPaymentValue.containsKey(Payment.invoiceit_s__Payment_Type__c)){
                        //Add amounts of all payments for the same month
                        if(map_AccountNMonth_TotalPayment.containskey(Acc.Id + '-' + Payment.invoiceit_s__Payment_Date__c.month() + '-' + Payment.invoiceit_s__Payment_Date__c.year())){
                            decimal amount = 	map_AccountNMonth_TotalPayment.get(Acc.Id + 
                                                                                    '-' + Payment.invoiceit_s__Payment_Date__c.month() + 
                                                                                    '-' + Payment.invoiceit_s__Payment_Date__c.year());	
                            amount += 	Payment.invoiceit_s__Amount__c;
                            
                            map_AccountNMonth_TotalPayment.put(Acc.Id + 
                                                                '-' + Payment.invoiceit_s__Payment_Date__c.month() + 
                                                                '-' + Payment.invoiceit_s__Payment_Date__c.year() , 
                                                                amount );	    											
                        }
                        //create a key with Account Id-Payment Month-Payment Year and value with payment amount 
                        else{
                            
                            map_AccountNMonth_TotalPayment.put(Acc.Id + 
                                                                '-' + Payment.invoiceit_s__Payment_Date__c.month() + 
                                                                '-' + Payment.invoiceit_s__Payment_Date__c.year() , 
                                                                Payment.invoiceit_s__Amount__c );
                        }			
                }													
            }
            for(invoiceit_s__Payment__c Payment : Acc.invoiceit_s__Payments__r){
                
                //if(Payment.invoiceit_s__Payment_Date__c != null && Payment.invoiceit_s__Payment_Date__c.month()
                if(mapTotalCreditValue.containsKey(Payment.invoiceit_s__Payment_Type__c))
                    TotalCredit += Payment.invoiceit_s__Amount__c;
                else if(mapTotalPaymentValue.containsKey(Payment.invoiceit_s__Payment_Type__c))
                    TotalPayment += Payment.invoiceit_s__Amount__c;
            }
            mapAccountTotalCredit.put(Acc.Id,TotalCredit);
            mapAccountTotalPayment.put(Acc.Id,TotalPayment);
        }
        
        
         
        for(invoiceit_s__Invoice__c Inv :   [select Id,invoiceit_s__Account__c,invoiceit_s__Account__r.Billing_Schedule__c,
                                                (Select Id,invoiceit_s__Payment__r.invoiceit_s__Payment_Type__c,
                                                invoiceit_s__Payment__r.invoiceit_s__Payment_Date__c, invoiceit_s__Amount__c ,
                                                invoiceit_s__Payment__r.invoiceit_s__Amount__c
                                                from invoiceit_s__Payment_Allocations__r where invoiceit_s__Payment__r.invoiceit_s__Status__c = 'Completed') 
                                            from invoiceit_s__Invoice__c where Id In: mapAccountServiceStartDate.values()]){
                        
            decimal TotalCredit = 0;
            decimal TotalPayment = 0;
            
            Datetime PreviousDate;
            Datetime CurrentDate;
            
            Integer InvoiceMonth ;
            Integer InvoiceYear;
            if(mapAccountServiceStartDate.containsKey(Inv.invoiceit_s__Account__c) && mapAccountServiceStartDate.get(Inv.invoiceit_s__Account__c) <> null)
                PreviousDate = mapAccountServiceStartDate.get(Inv.invoiceit_s__Account__c).invoiceit_s__Invoice_Date__c;
            if(mapAccountServiceEndDate.containsKey(Inv.invoiceit_s__Account__c)  && mapAccountServiceEndDate.get(Inv.invoiceit_s__Account__c) <> null)
                CurrentDate = mapAccountServiceEndDate.get(Inv.invoiceit_s__Account__c).invoiceit_s__Invoice_Date__c;
            
            InvoiceYear = Currentdate.year();
            if(Inv.invoiceit_s__Account__r.Billing_Schedule__c == 'Advanced'){	
                CurrentDate = CurrentDate.addMonths(-1);
                InvoiceMonth = CurrentDate.month();
                
            }	
            else if(Inv.invoiceit_s__Account__r.Billing_Schedule__c == 'Arrears'){
                InvoiceMonth = CurrentDate.month();	
            }
            for(invoiceit_s__Payment_Allocation__c payAllocation : Inv.invoiceit_s__Payment_Allocations__r){
                //if(payAllocation.invoiceit_s__Payment__r.invoiceit_s__Payment_Date__c >= PreviousDate && payAllocation.invoiceit_s__Payment__r.invoiceit_s__Payment_Date__c <= CurrentDate)
                //{
                if(payAllocation.invoiceit_s__Payment__r.invoiceit_s__Payment_Date__c!=null && 
                    payAllocation.invoiceit_s__Payment__r.invoiceit_s__Payment_Date__c.month() == InvoiceMonth){
                    if(mapTotalCreditValue.containsKey(payAllocation.invoiceit_s__Payment__r.invoiceit_s__Payment_Type__c))
                        TotalCredit += payAllocation.invoiceit_s__Amount__c;
                    else if(mapTotalPaymentValue.containsKey(payAllocation.invoiceit_s__Payment__r.invoiceit_s__Payment_Type__c))
                        TotalPayment += payAllocation.invoiceit_s__Payment__r.invoiceit_s__Amount__c;
                }        
                //}
            }
            
            mapTotalCredit.put(Inv.invoiceit_s__Account__c,TotalCredit);
            mapTotalPayment.put(Inv.invoiceit_s__Account__c,TotalPayment);
        }
    
        //Add Allocated Amount + Account UnAllocated Amount
        for(string AccId: mapAccountTotalCredit.keySet()){
            if(mapTotalCredit.containsKey(AccId))
                mapTotalCredit.put(AccId,mapTotalCredit.get(AccId) + mapAccountTotalCredit.get(AccId) );
        }
        for(string AccId: mapAccountTotalPayment.keySet()){
            if(mapTotalPayment.containsKey(AccId))
                mapTotalPayment.put(AccId,mapTotalPayment.get(AccId) + mapAccountTotalPayment.get(AccId) );
        }
           
        for(invoiceit_s__Invoice__c Invoice : invlist){
        
        
            //Set Previous balance
            if(mapAccountServiceStartDate.containsKey(Invoice.invoiceit_s__Account__c) && mapAccountServiceStartDate.get(Invoice.invoiceit_s__Account__c) <> null){
                //Invoice.Previous_Balance__c = mapAccountServiceStartDate.get(Invoice.invoiceit_s__Account__c).Account_Balance__c;
                //Invoice.Previous_Invoice__c = mapAccountServiceStartDate.get(Invoice.invoiceit_s__Account__c).Id;
            }
            else{
                //Invoice.Previous_Balance__c = 0;
                //Invoice.Previous_Invoice__c = null;
            }
            //set Address fields
            if(mapAccountBalance.containsKey(Invoice.invoiceit_s__Account__c)){
                Account Acc = mapAccountBalance.get(Invoice.invoiceit_s__Account__c);
                Invoice.Street_Address__c = Acc.BillingStreet;
                Invoice.City__c = Acc.BillingCity;
                Invoice.State__c = Acc.BillingState;
                Invoice.Country__c = Acc.BillingCountry;
                Invoice.Zip_Code__c = Acc.BillingPostalCode;
            }
            /* set total credits
            if(mapTotalCredit.ContainsKey(Invoice.invoiceit_s__Account__c))
                Invoice.Total_Credits__c = mapTotalCredit.get(Invoice.invoiceit_s__Account__c);
            else
                Invoice.Total_Credits__c = 0;*/  
             
            /* set total payments
                    if(mapTotalPayment.ContainsKey(Invoice.invoiceit_s__Account__c))
                        Invoice.Total_Payments__c = mapTotalPayment.get(Invoice.invoiceit_s__Account__c);
                    else
                        Invoice.Total_Payments__c = 0;*/
            system.debug('billing schedule --->  ' + map_AccountId_BillingSchedule.get(Invoice.invoiceit_s__Account__c) ) ;            
            system.debug('total credit --->  ' + map_AccountNMonth_TotalCredit ) ;          
            system.debug('total payment --->  ' + map_AccountNMonth_TotalPayment ) ;  
            //set total credits and total payments
            
            if(Invoice.invoiceit_s__Invoice_Date__c != null && map_AccountId_BillingSchedule.containskey(Invoice.invoiceit_s__Account__c) && map_AccountId_BillingSchedule.get(Invoice.invoiceit_s__Account__c) == 'Arrears'){
                    Integer PaymentMonth = system.today().month();  //for test class and cases where invoice date is null
                    Integer PaymentYear  = system.today().year();
                    if(Invoice.invoiceit_s__Invoice_Date__c != null){
                        PaymentMonth = Invoice.invoiceit_s__Invoice_Date__c.month();
                        PaymentYear = Invoice.invoiceit_s__Invoice_Date__c.year();
                        system.debug('comes here 2 ' +Invoice.invoiceit_s__Account__c +'-'+ PaymentMonth + '-' + Invoice.invoiceit_s__Invoice_Date__c.year());
                    }
                    
                    if(map_AccountNMonth_TotalCredit.containsKey(Invoice.invoiceit_s__Account__c + '-' + PaymentMonth + '-' +PaymentYear )){
                        Invoice.Total_Credits__c = map_AccountNMonth_TotalCredit.get(Invoice.invoiceit_s__Account__c + '-' + PaymentMonth + '-' +PaymentYear );
                    }  
                    else if(map_AccountNMonth_TotalCredit.containsKey(Invoice.invoiceit_s__Account__c + '-' + PaymentMonth + '-' +PaymentYear + '-' + 'Promotional Credit')){
                        Invoice.Total_Credits__c = map_AccountNMonth_TotalCredit.get(Invoice.invoiceit_s__Account__c + '-' + PaymentMonth + '-' +PaymentYear + '-' + 'Promotional Credit');	
                    }
                    else{
                        Invoice.Total_Credits__c = 0;	
                    }  
                    
                        
                    if(map_AccountNMonth_TotalPayment.containsKey(Invoice.invoiceit_s__Account__c + '-' + Invoice.invoiceit_s__Invoice_Date__c.month() + '-' +Invoice.invoiceit_s__Invoice_Date__c.year())){
                        Invoice.Total_Payments__c = map_AccountNMonth_TotalPayment.get(Invoice.invoiceit_s__Account__c + '-' + Invoice.invoiceit_s__Invoice_Date__c.month() + '-' +Invoice.invoiceit_s__Invoice_Date__c.year() );	
                    }  
                    else{
                        Invoice.Total_Payments__c = 0;	
                    }
            } 
            
            else if(map_AccountId_BillingSchedule.containskey(Invoice.invoiceit_s__Account__c) && map_AccountId_BillingSchedule.get(Invoice.invoiceit_s__Account__c) == 'Advanced'){
                    system.debug('comes here 1');
                    Integer PaymentMonth = system.today().addMonths(-1).month();  //for test class and cases where invoice date is null
                    Integer PaymentYear  = system.today().year();
                    Integer PaymentMonth_PromCred ; 
                    if(Invoice.invoiceit_s__Invoice_Date__c != null){
                        PaymentMonth = Invoice.invoiceit_s__Invoice_Date__c.addMonths(-1).month();
                        PaymentYear = Invoice.invoiceit_s__Invoice_Date__c.year();
                        system.debug('comes here 2 ' +Invoice.invoiceit_s__Account__c +'-'+ PaymentMonth + '-' + Invoice.invoiceit_s__Invoice_Date__c.year());
                    }	
                    PaymentMonth_PromCred = PaymentMonth + 1;
                    if(map_AccountNMonth_TotalCredit.containsKey(Invoice.invoiceit_s__Account__c + '-' + PaymentMonth + '-' +PaymentYear )){
                        system.debug('working');
                        Invoice.Total_Credits__c = map_AccountNMonth_TotalCredit.get(Invoice.invoiceit_s__Account__c + '-' + PaymentMonth + '-' +PaymentYear );
                        system.debug('working 2 ' + Invoice.Total_Credits__c);
                    }  
                    else if(map_AccountNMonth_TotalCredit.containsKey(Invoice.invoiceit_s__Account__c + '-' + PaymentMonth_PromCred + '-' +PaymentYear + '-' + 'Promotional Credit')){
                        Invoice.Total_Credits__c = map_AccountNMonth_TotalCredit.get(Invoice.invoiceit_s__Account__c + '-' + PaymentMonth_PromCred + '-' +PaymentYear + '-' + 'Promotional Credit');	
                    }
                    else{ 
                        Invoice.Total_Credits__c = 0;	
                    }  
                    
                        
                    if(map_AccountNMonth_TotalPayment.containsKey(Invoice.invoiceit_s__Account__c + '-' + PaymentMonth + '-' +PaymentYear)){
                        Invoice.Total_Payments__c = map_AccountNMonth_TotalPayment.get(Invoice.invoiceit_s__Account__c + '-' + PaymentMonth + '-' +PaymentYear );	
                        system.debug('working 2 ' + Invoice.Total_Payments__c);
                    }  
                    else{
                        Invoice.Total_Payments__c = 0;	
                    }	
            } 
    
        }
    }

}
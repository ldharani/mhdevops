/*
 * Created By : Lister Technologies
 * Created Date : 16-April-2014
 * Created Purpose : Batch Class which will be used to construct reports on Invoices & other related objects 
 * Modified By : Lister Technologies
 * Modified Date : 6-Jan-2015
 * Modifed Purpose : To make the start date for invoices configurable using Custom Setting
 * Test Class : 
 */
global class MDL_Batch_InvoiceReportGenerator implements Database.Batchable<sObject> {
    global String query;
    global String updateString;
    global String strFromDate;
    global String strToDate;
    global Date tDate;
    global Date startDate;
    global Date endDate;
    global Date paymentStartDate;
    global Date paymentEndDate;
    global String emailMsg;
    global List<String> toAddress;
    //global List<Id> lstInvoiceIds;
    public List<invoiceit_s__Invoice__c> lstInvoicesToUpdate;
    public Map<Id,List<invoiceit_s__Invoice_Lines__c>> mapInvoiceIdAndLstInvoiceLines;
    public Map<String,Double> mapInvLineNameNQty; 
    public Set<String> setInvLineNames;
    public Set<Id> setOrderRatePlanIds;
    public MDL_Batch_InvoiceReportGenerator() {
        query ='';
        emailMsg='';
        toAddress = new List<String>();
        //lstInvoiceIds = new List<id>();
        tDate = Date.today();
        //startDate = tDate.addMonths(2).toStartOfMonth();
        Invoice_CSV_Generator__c gen = Invoice_CSV_Generator__c.getValues('Test');
        startDate = gen.Invoice_Test_Date__c;
        //endDate = tDate.addMonths(3).toStartOfMonth().addDays(-1);
        endDate = startDate.addMonths(1).toStartOfMonth().addDays(-1);
        strFromDate = convertDateToUSAFormat(startDate);
        strToDate = convertDateToUSAFormat(endDate);
        paymentStartDate = startDate.addMonths(-1);
        paymentEndDate = endDate.addMonths(-1);
        mapInvoiceIdAndLstInvoiceLines = new Map<Id,List<invoiceit_s__Invoice_Lines__c>>();
        mapInvLineNameNQty = new Map<String,Double>();
        setInvLineNames = new Set<String>();
        setOrderRatePlanIds = new Set<Id>();
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        /*
        String query = 'Select Id,Name,MH_Cust_Number__c,Hold_dunning_letter_till__c,Dunning_Hold_for_30_days__c, '+
                                    'RecordType.DeveloperName , Unpaid_amount__c, '+
                                    
                                    '(Select invoiceit_s__Order__r.invoiceit_s__Total__c, invoiceit_s__Order__r.invoiceit_s__Tax__c, Previous_Balance__c ,' +  
                                    'RecordType.DeveloperName , invoiceit_s__Net_Total__c, '+
                                    'invoiceit_s__Order__r.invoiceit_s__Sub_Total__c, invoiceit_s__Order__r.invoiceit_s__Service_End_Date__c, Total_Credits__c , ' + 
                                    'invoiceit_s__Order__r.invoiceit_s__Service_Activation_Date__c, invoiceit_s__Order__r.invoiceit_s__Discount_Value__c, Total_Payments__c , '+            
                                    'invoiceit_s__Order__r.invoiceit_s__Billing_Contact__c, invoiceit_s__Order__c, invoiceit_s__Order__r.Auth_By_Contact__c,invoiceit_s__Order__r.Auth_By_Contact__r.Name, invoiceit_s__Invoice_Date__c, Account_Balance__c , '+ 
                                    'invoiceit_s__Due_Date__c, invoiceit_s__Amount__c, invoiceit_s__Account__r.BillingPostalCode, invoiceit_s__Account__r.MH_Cust_Number__c , invoiceit_s__Unpaid_Amount__c ,' +
                                    'invoiceit_s__Total_Invoice_Value__c , invoiceit_s__Billing_Contact__c , invoiceit_s__Billing_Contact__r.Name , ' + 
                                    'invoiceit_s__Account__r.BillingState, invoiceit_s__Account__r.BillingCity, invoiceit_s__Account__r.BillingStreet,'+
                                    'invoiceit_s__Account__r.Name,invoiceit_s__Account__r.Primary_Contact__c , invoiceit_s__Account__c,invoiceit_s__Account__r.Total_Account_Balance__c, Name, Invoice_Reporting_Date__c, Invoice_Reporting_Data__c,' +
                                    'invoiceit_s__Discount_Value__c, invoiceit_s__Tax__c, Purchase_Order_Number__c ' +
                                    'From invoiceit_s__Invoices__r ' + 
                                    'where invoiceit_s__Order__r.invoiceit_s__Status__c != \'Cancelled\' ' + 
                                    'and invoiceit_s__Invoice_Date__c >= :startDate and invoiceit_s__Invoice_Date__c <= :endDate ' +
                                    'and invoiceit_s__Unpaid_Amount__c!=0.0'+
                                    'and RecordType.DeveloperName = \'MH_Invoices\') , ' + 
                                     
                                    
                                   
                                    
                                    '(Select Id,Name, invoiceit_s__Payment_Date__c , invoiceit_s__Account__c , invoiceit_s__Account__r.Hold_dunning_letter_till__c , '+
                                    'RecordType.DeveloperName ,invoiceit_s__Payment_Type__c, Applied_Type__c,invoiceit_s__Amount__c '+ 
                                    'from invoiceit_s__Payments__r ' + 
                                    'where invoiceit_s__Payment_Date__c >=:paymentStartDate and invoiceit_s__Payment_Date__c <= :paymentendDate and invoiceit_s__Amount__c!=0.0)' +                                                      //PAYMENT SUB QUERY
                                     
                                    
                                    'from Account ' + //where Id in :listOfAccId;
                                    'where RecordType.DeveloperName = \'MH_Accounts\' ';
        System.debug('today'+tDate+'startDate'+startDate+'endDate'+endDate);
        System.debug('query passed is :'+query);
        */
        
        String query = 'Select Id,Name,MH_Cust_Number__c,Hold_dunning_letter_till__c,Dunning_Hold_for_30_days__c,Unallocated_Payment_Amount__c, '+
                                    'RecordType.DeveloperName , Unpaid_amount__c, '+
                                    
                                    '(Select invoiceit_s__Order__r.invoiceit_s__Total__c, invoiceit_s__Order__r.invoiceit_s__Tax__c, Previous_Balance__c ,' +  
                                    'RecordType.DeveloperName , invoiceit_s__Net_Total__c, '+
                                    'invoiceit_s__Order__r.invoiceit_s__Sub_Total__c, invoiceit_s__Order__r.invoiceit_s__Service_End_Date__c, Total_Credits__c , ' + 
                                    'invoiceit_s__Order__r.invoiceit_s__Service_Activation_Date__c, invoiceit_s__Order__r.invoiceit_s__Discount_Value__c, Total_Payments__c , '+            
                                    'invoiceit_s__Order__r.invoiceit_s__Billing_Contact__c, invoiceit_s__Order__c, invoiceit_s__Order__r.Auth_By_Contact__c,invoiceit_s__Order__r.Auth_By_Contact__r.Name, invoiceit_s__Invoice_Date__c, Account_Balance__c , '+ 
                                    'invoiceit_s__Due_Date__c, invoiceit_s__Amount__c, invoiceit_s__Account__r.BillingPostalCode, invoiceit_s__Account__r.MH_Cust_Number__c , invoiceit_s__Unpaid_Amount__c ,' +
                                    'invoiceit_s__Total_Invoice_Value__c , invoiceit_s__Billing_Contact__c , invoiceit_s__Billing_Contact__r.Name , ' + 
                                    'invoiceit_s__Account__r.BillingState, invoiceit_s__Account__r.BillingCity, invoiceit_s__Account__r.BillingStreet,'+
                                    'invoiceit_s__Account__r.Name,invoiceit_s__Account__r.Primary_Contact__c , invoiceit_s__Account__c,invoiceit_s__Account__r.Total_Account_Balance__c, Name, Invoice_Reporting_Date__c, Invoice_Reporting_Data__c,' +
                                    'invoiceit_s__Discount_Value__c, invoiceit_s__Tax__c, Purchase_Order_Number__c ' +
                                    'From invoiceit_s__Invoices__r ' + 
                                    'where invoiceit_s__Order__r.invoiceit_s__Status__c != \'Cancelled\' ' + 
                                    'and invoiceit_s__Invoice_Date__c = :startDate ' +                                    
                                    'and RecordType.DeveloperName = \'MH_Invoices\') , ' + 
                                     
                                    
                                    /*//'AND (invoiceit_s__Due_Date__c < invoiceit_s__Account__r.Hold_dunning_letter_till__c '+
                                    //'OR invoiceit_s__Account__r.Hold_dunning_letter_till__c = null) ), ' + */
                                    
                                    '(Select Id,Name, invoiceit_s__Payment_Date__c , invoiceit_s__Account__c , invoiceit_s__Account__r.Hold_dunning_letter_till__c , '+
                                    'RecordType.DeveloperName ,invoiceit_s__Payment_Type__c, Applied_Type__c,invoiceit_s__Amount__c,invoiceit_s__Unallocated_Amount__c '+ 
                                    'from invoiceit_s__Payments__r ' + 
                                    'where invoiceit_s__Payment_Date__c >=:paymentStartDate and invoiceit_s__Payment_Date__c <= :paymentendDate and invoiceit_s__Amount__c!=0.0)' +                                                      //PAYMENT SUB QUERY
                                     
                                    
                                    'from Account ' + //where Id in :listOfAccId;
                                    'where RecordType.DeveloperName = \'MH_Accounts\'';
        if(test.isRunningTest()) {
            query += ' and Name like \'%test%\' LIMIT 5';
        }
        System.debug('today'+tDate+'startDate');
        System.debug('query passed is :'+query);
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope) {
    	Map<Id,Decimal> mapAccNPreviousPaymentAmount = new Map<Id,Decimal>();
    	Set<Id> setAccountIDs = new Set<Id>();
        List<Id> lstInvoiceIds = new List<id>();
        lstInvoicesToUpdate = new List<invoiceit_s__Invoice__c>();         
        Set<Id> set_paymentids = new Set<id>();
        Map<Id,String> map_PaymentId_InvoiceName = new Map<Id,String>();
        Map<Id,Decimal> mapAccIdNSumInvUnpaidAmt = new Map<Id,Decimal>();
        Map<Id,Decimal> mapAccIdNSumUnAllocatedAmt = new Map<Id,Decimal>();
        /*
        RBW 943
        2.) We need to identify accounts that have a Payment Method on file, where the Payment Method is both Active and Default.
			2a.) The Payment Method can be either ACH or Credit Card
			2b.) We need to add the following text that reads: "* Your account is on auto-pay, please do not remit a separate payment"
		3.) For accounts that do not have a Payment Method on file, we need to add the following text: " * Make checks payable to Martindale LLC"
        */
        Map<Id,String> Map_Account_PaymentText = new Map<Id, String>(); //Change for 943
        
        for(Account a : scope) { 
        	setAccountIDs.add(a.Id);       	
        	Map_Account_PaymentText.put(a.Id, '* Make checks payable to Martindale LLC'); 
            System.debug('Acc Name'+a.Name+'^^^'+a.Id); 
            for(invoiceit_s__Invoice__c inv : a.invoiceit_s__Invoices__r){                                
                lstInvoiceIds.add(inv.Id);               
            }           
            for(invoiceit_s__Payment__c pay : a.invoiceit_s__Payments__r){
                set_paymentids.add(pay.Id);               
            }           
          
        }       
        
        for(invoiceit_s__Invoice__c inv : [Select invoiceit_s__Unpaid_Amount__c,invoiceit_s__Account__c from invoiceit_s__Invoice__c where invoiceit_s__Invoice_Date__c < :startDate and 
        								invoiceit_s__Invoice_Status__c='Posted' and invoiceit_s__Payment_Status__c!='Paid' and RecordType.DeveloperName = 'MH_Invoices' and invoiceit_s__Account__c in :setAccountIDs]){
        		if(mapAccIdNSumInvUnpaidAmt.containsKey(inv.invoiceit_s__Account__c)){
        			Decimal unpaidAmount = mapAccIdNSumInvUnpaidAmt.get(inv.invoiceit_s__Account__c);
        			unpaidAmount += inv.invoiceit_s__Unpaid_Amount__c;
        			mapAccIdNSumInvUnpaidAmt.put(inv.invoiceit_s__Account__c,unpaidAmount); 
        		}
        		else{
        			mapAccIdNSumInvUnpaidAmt.put(inv.invoiceit_s__Account__c,inv.invoiceit_s__Unpaid_Amount__c);
        		}						
        }
        for(invoiceit_s__Payment__c pay : [Select invoiceit_s__Unallocated_Amount__c,invoiceit_s__Account__c from invoiceit_s__Payment__c where invoiceit_s__Payment_Date__c < :paymentStartDate and 
        				  				invoiceit_s__Amount__c!=0.0 and invoiceit_s__Unallocated_Amount__c!=0.0 and No_of_Payment_Allocations__c=0 and invoiceit_s__Account__c in :setAccountIDs]){
        	if(mapAccIdNSumUnAllocatedAmt.containsKey(pay.invoiceit_s__Account__c)){
    			Decimal unallocAmount = mapAccIdNSumUnAllocatedAmt.get(pay.invoiceit_s__Account__c);
    			unallocAmount += pay.invoiceit_s__Unallocated_Amount__c;
    			mapAccIdNSumUnAllocatedAmt.put(pay.invoiceit_s__Account__c,unallocAmount); 
    		}
    		else{
    			mapAccIdNSumUnAllocatedAmt.put(pay.invoiceit_s__Account__c,pay.invoiceit_s__Unallocated_Amount__c);
    		}
        }
        for(Id accId : setAccountIDs){
        	Decimal invAmount = 0.00;
        	Decimal payAmount = 0.00;
        	if(mapAccIdNSumInvUnpaidAmt.containsKey(accId)){
        		invAmount = mapAccIdNSumInvUnpaidAmt.get(accId);
        	}
        	if(mapAccIdNSumUnAllocatedAmt.containsKey(accId)){
        		payAmount = mapAccIdNSumUnAllocatedAmt.get(accId);
        	}
        	Decimal previousAmount = invAmount - payAmount;
        	mapAccNPreviousPaymentAmount.put(accId,previousAmount);
        }   
     
       	for(invoiceit_s__Invoice_Lines__c invLines : [Select i.invoiceit_s__Total_Line_Amount__c,i.invoiceit_s__Quantity__c, 
                                                        i.invoiceit_s__Product_Name__c, i.invoiceit_s__Invoice__c, i.Id , 
                                                        i.invoiceit_s__Invoice__r.Id,
                                                        i.invoiceit_s__Invoice__r.invoiceit_s__Billing_Contact__r.Name,
                                                        i.invoiceit_s__Product_Rate_Plan_Charge__c , 
                                                        i.invoiceit_s__Job_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__c 
                                                        From invoiceit_s__Invoice_Lines__c i 
                                                        where i.invoiceit_s__Invoice__c in : lstInvoiceIds]) {
            if(!mapInvoiceIdAndLstInvoiceLines.containsKey(invLines.invoiceit_s__Invoice__r.Id)) {
                mapInvoiceIdAndLstInvoiceLines.put(invLines.invoiceit_s__Invoice__r.Id,new List<invoiceit_s__Invoice_Lines__c>{invLines});
            }
            else {
                mapInvoiceIdAndLstInvoiceLines.get(invLines.invoiceit_s__Invoice__r.Id).add(invLines);
            }
        }
        
        for(invoiceit_s__Payment_Allocation__c alloc : [Select Id , invoiceit_s__Invoice__c,invoiceit_s__Invoice__r.Name , 
                                                        invoiceit_s__Payment__c , invoiceit_s__Payment__r.Id
                                                        from invoiceit_s__Payment_Allocation__c
                                                        where invoiceit_s__Payment__c in : set_paymentids]){
                                                        
                    map_PaymentId_InvoiceName.put(alloc.invoiceit_s__Payment__r.Id, alloc.invoiceit_s__Invoice__r.Name);                                                                 
        }                                                
        system.debug('invoice ids are ---> ' + lstInvoiceIds);  
        
        
        
        for(invoiceit_s__Payment_Method__c paymentMethod : [Select Id, invoiceit_s__Payment_Method__c, invoiceit_s__Account__c
        													from invoiceit_s__Payment_Method__c 
        													where invoiceit_s__Account__c in : Map_Account_PaymentText.keyset()
        													and invoiceit_s__Active__c = true
        													and invoiceit_s__Default__c = true]){
        			
        			Map_Account_PaymentText.put(paymentMethod.invoiceit_s__Account__c, '* Your account is on auto-pay, please do not remit a separate payment');													        																	
        }
        
        for(Account a : scope){
           String PS = 'PS';
           String CS = 'CS';
           Decimal total_AdjustmentsPayment = 0.00;
           Decimal total_otherPayments = 0.00;
           Decimal Previous_Balance = 0.00;
           
           Boolean showCS = false;
           Boolean showPS = false;
           //Getting the previous balance for the current invoice
           for(invoiceit_s__Invoice__c inv : a.invoiceit_s__Invoices__r){ 
               if(inv.invoiceit_s__Invoice_Date__c < startDate){
                        system.debug('previous invoice ' + inv.Id); 
                        Previous_Balance += inv.invoiceit_s__Unpaid_Amount__c ;                    
               } 
           }    
           
           
           //Constructing the CS and PS sections
           for(invoiceit_s__Payment__c pay : a.invoiceit_s__Payments__r){                                             
               if(pay.invoiceit_s__Payment_Type__c == 'Adjustment' && pay.Applied_Type__c == 'Credit'){
                   //if(pay.Applied_Type__c == 'Credit' || pay.Applied_Type__c == 'DM (Debit-Memo)'){
                       showCS = true;
                       total_AdjustmentsPayment += pay.invoiceit_s__Amount__c;  
                       CS += '|'+ convertDateToUSAFormat(pay.invoiceit_s__Payment_Date__c) + '|';
                       
                       if(map_PaymentId_InvoiceName.containsKey(pay.Id)){
                          CS += map_PaymentId_InvoiceName.get(pay.Id) ;    
                       }     
                       
                       CS  += '|'+ pay.Name + '|($' + pay.invoiceit_s__Amount__c + ')' ;  
                                   
                   //}
               }  
               else{
                   showPS =true;
                   total_otherPayments += pay.invoiceit_s__Amount__c;
                   PS += '|' + convertDateToUSAFormat(pay.invoiceit_s__Payment_Date__c) + '|' ;
               
                   if(map_PaymentId_InvoiceName.containsKey(pay.Id)){
                      PS += map_PaymentId_InvoiceName.get(pay.Id) ;    
                   }   
                    
                   PS+= '|' + pay.Name +  '|($' + pay.invoiceit_s__Amount__c + ')' ; 
                   
               }   
                   
                                 
           } 
           //Invoice FOR LOOP. COntructing the INVOICE CSV
           for(invoiceit_s__Invoice__c invoice: a.invoiceit_s__Invoices__r){
            mapInvLineNameNQty =  new Map<String,Double>();
            if(invoice.invoiceit_s__Invoice_Date__c >= startDate && invoice.invoiceit_s__Invoice_Date__c <= endDate) {
                Date bpStartDate = invoice.invoiceit_s__Invoice_Date__c.addMonths(-1).toStartOfMonth();
                Date bpEndDate = invoice.invoiceit_s__Invoice_Date__c.toStartOfMonth().addDays(-1);
               
                //MA SECTION
                updateString = 'MA'+'|';           
                System.debug('%%%Invoice COntact Id'+invoice.invoiceit_s__Billing_Contact__c);     
                if(invoice.invoiceit_s__Billing_Contact__c != null) {
                    System.debug('Contact Name for the Invoice :***'+invoice.invoiceit_s__Billing_Contact__r.Name);
                    updateString += invoice.invoiceit_s__Billing_Contact__r.Name;
                }
                updateString += '|'+invoice.invoiceit_s__Account__r.Name;
                updateString += '|';
                if(invoice.invoiceit_s__Account__r.BillingStreet != null)
                    updateString += invoice.invoiceit_s__Account__r.BillingStreet;
                updateString += '|'  ;  
                if(invoice.invoiceit_s__Account__r.BillingCity != null)
                    updateString += invoice.invoiceit_s__Account__r.BillingCity;
                updateString += '|' ;   
                if(invoice.invoiceit_s__Account__r.BillingState != null)
                    updateString += invoice.invoiceit_s__Account__r.BillingState;
                updateString += '|';    
                if(invoice.invoiceit_s__Account__r.BillingPostalCode != null)
                    updateString += invoice.invoiceit_s__Account__r.BillingPostalCode;
                updateString += '\r\n'; 
                
                
                
                //AI Section
                updateString += 'AI'+'|'+invoice.Name+'|'+ convertDateToUSAFormat(invoice.invoiceit_s__Invoice_Date__c)+'|';
                if(invoice.invoiceit_s__Due_Date__c != null)
                    updateString += convertDateToUSAFormat(invoice.invoiceit_s__Due_Date__c) ;
                updateString += '|'  ;    
                if(invoice.invoiceit_s__Account__r.MH_Cust_Number__c != null)
                    updateString += invoice.invoiceit_s__Account__r.MH_Cust_Number__c;   
                updateString += '\r\n';
                
                
                Decimal totalAccBalance = invoice.invoiceit_s__Total_Invoice_Value__c - (total_AdjustmentsPayment + total_otherPayments);
                
                //AM Section
                updateString += 'AM|$' + invoice.invoiceit_s__Account__r.Total_Account_Balance__c +'*';                                                     
                updateString += '\r\n';
                
                
                
                //BP Section
                updateString += 'BP'+'|'+convertDateToUSAFormat(bpStartDate)+'|'+convertDateToUSAFormat(bpEndDate)+'\r\n';
                
                
                
                //PO Section
                if(invoice.Purchase_Order_Number__c != null && invoice.Purchase_Order_Number__c != ''){
                    updateString += 'PO|' + invoice.Purchase_Order_Number__c;
                    updateString += '\r\n';
                }
                
                
                //DS01 Section
                Decimal Difference = invoice.invoiceit_s__Account__r.Total_Account_Balance__c - invoice.invoiceit_s__Total_Invoice_Value__c;
                updateString += 'DS01|';
                //updateString += '($' + Previous_Balance + ')' ;
                //making ds01 as total account balance - current invoice value
                if(mapAccNPreviousPaymentAmount.containsKey(a.Id)){
                	updateString += '$' + mapAccNPreviousPaymentAmount.get(a.Id) ;
                }
                updateString += '|$' + invoice.invoiceit_s__Total_Invoice_Value__c;
                updateString += '|($' + total_AdjustmentsPayment + ')' ;
                updateString += '|$' +invoice.invoiceit_s__Tax__c;
                updateString += '|($' + total_otherPayments + ')' ;                
                updateString += '|$' +invoice.invoiceit_s__Account__r.Total_Account_Balance__c;
                updateString += '\r\n';
                
                
                //AU Section
                if(Map_Account_PaymentText.containsKey(a.Id)){
                	updateString += 'AU|' + Map_Account_PaymentText.get(a.Id);
                	updateString += '\r\n';
                }
                
                //CN Section
                updateString += 'CN|'  ;
                if(invoice.invoiceit_s__Account__r.MH_Cust_Number__c != null)
                        updateString += invoice.invoiceit_s__Account__r.MH_Cust_Number__c;      
                updateString += '\r\n';
                
                
                if(mapInvoiceIdAndLstInvoiceLines.containsKey(invoice.Id)) {
                    for(invoiceit_s__Invoice_Lines__c invLines : mapInvoiceIdAndLstInvoiceLines.get(Invoice.Id)) {
                        if(mapInvLineNameNQty.containsKey(invLines.invoiceit_s__Product_Name__c)) {
                            if(mapInvLineNameNQty.containsKey(invLines.invoiceit_s__Product_Name__c)) {
                                //mapInvLineNameNQty.put(invLines.invoiceit_s__Product_Name__c,invLines.invoiceit_s__Quantity__c);
                                if(!setOrderRatePlanIds.contains(invLines.invoiceit_s__Job_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__c)) {
                                    setOrderRatePlanIds.add(invLines.invoiceit_s__Job_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__c);
                                    Double i = 0;
                                    i = mapInvLineNameNQty.get(invLines.invoiceit_s__Product_Name__c) + invLines.invoiceit_s__Quantity__c;
                                    mapInvLineNameNQty.put(invLines.invoiceit_s__Product_Name__c,i);
                                }                                
                            }
                            else {
                                mapInvLineNameNQty.put(invLines.invoiceit_s__Product_Name__c,invLines.invoiceit_s__Quantity__c);
                                setOrderRatePlanIds.add(invLines.invoiceit_s__Job_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__c);
                            }
                        }
                        else{
                             mapInvLineNameNQty.put(invLines.invoiceit_s__Product_Name__c,invLines.invoiceit_s__Quantity__c);
                             setOrderRatePlanIds.add(invLines.invoiceit_s__Job_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__c);
                        }        
                    }
                } 
                
                
                System.debug('%%%mapInvLinesNQty%%%'+mapInvLineNameNQty);
                System.debug('$$$mapInvoiceIdAndLstInvoiceLines$$$'+mapInvoiceIdAndLstInvoiceLines);
                
                
                
                //MP01 Section
                if(mapInvoiceIdAndLstInvoiceLines.containsKey(Invoice.Id)) {
                    //updateString += 'MP01' + '|';
                    system.debug('check1');
                    setInvLineNames = new Set<String>();
                    for(invoiceit_s__Invoice_Lines__c invLines : mapInvoiceIdAndLstInvoiceLines.get(Invoice.Id)) {
                        system.debug('check2');                        
                        if(mapInvLineNameNQty.containsKey(invLines.invoiceit_s__Product_Name__c) && (!setInvLineNames.contains(invLines.invoiceit_s__Product_Name__c))) {
                            //updateString += invLines.invoiceit_s__Product_Name__c + '|' + invLines.invoiceit_s__Quantity__c + '|' + '$' + invLines.invoiceit_s__Total_Line_Amount__c + '|';
                            setInvLineNames.add(invLines.invoiceit_s__Product_Name__c);
                            updateString += 'MP01' + '|' + invLines.invoiceit_s__Product_Name__c + '|' + mapInvLineNameNQty.get(invLines.invoiceit_s__Product_Name__c) + '|' + '\r\n';
                            system.debug('check3' + Invoice.Id);
                        }
                    }
                } 
                
                system.debug('updateString ' + updateString);
                if(updateString.endsWith('|')) {
                    Integer i = updateString.lastIndexOf('|');
                    updateString = updateString.subString(0,i);
                }
                //updateString += '\r\n'; 
                
                
                
                //CT Section
                updateString +=  'CT'+'|';                                         
                if(invoice.invoiceit_s__Net_Total__c != null)
                    updateString += '$' + invoice.invoiceit_s__Net_Total__c;   //Net Total
                updateString += '|' ;
                if(invoice.invoiceit_s__Tax__c != null)
                    updateString += '$' + invoice.invoiceit_s__Tax__c;   //Taxes
                updateString += '|' ;   
                if(invoice.invoiceit_s__Total_Invoice_Value__c != null)
                    updateString += '$' + invoice.invoiceit_s__Total_Invoice_Value__c; //Grand Total
                updateString += '\r\n';
                //End of CT
                
               
               //if total other payments and total Adjustment Payment are not null
               //if(total_otherPayments != 0.00 || total_AdjustmentsPayment != 0.00) {
               if(a.invoiceit_s__Payments__r.size()>0){
                   //PS Section
                   if(showPS){
                        updateString += PS; 
                        updateString += '\r\n';
                   }     
                   //TP Section
                   if(total_otherPayments > 0){
                        updateString += 'TP|($' + total_otherPayments + ')';
                        updateString += '\r\n';
                   }     
                   //CS Section
                   if(showCS){
                        updateString += CS; 
                        updateString += '\r\n';
                   }     
                   //TC Section
                   if(total_AdjustmentsPayment > 0){
                        updateString += 'TC|($' + total_AdjustmentsPayment + ')'; 
                        updateString += '\r\n';
                   }                    			               	
               }
               
               /*if(Map_Account_PaymentText.containsKey(a.Id))
               			updateString += Map_Account_PaymentText.get(a.Id);
               	*/		
               invoice.Invoice_Reporting_Data__c = updateString;
               invoice.Invoice_Reporting_Date__c = startDate;
               lstInvoicesToUpdate.add(invoice);    
            }
          }   
          
           
      }
        
        
      if(lstInvoicesToUpdate.size() > 0)
            Database.update(lstInvoicesToUpdate);  
        
    }
    
    
    
    //Convert the given date to the US Format , eg. January 1, 2014
    global String convertDateToUSAFormat(Date d){
        
    Integer getday = d.day();
    Integer getmonth = d.month();
    Integer getyear = d.year();
    
    String formattedString;
    
    system.debug('day - ' + getday + ' month - ' + getmonth + ' yaear - ' + getyear);
    Map<Integer,String> monthMap = new Map<Integer,String>();
    monthMap.put(1,'January');
    monthMap.put(2,'February');
    monthMap.put(3,'March');
    monthMap.put(4,'April');
    monthMap.put(5,'May');
    monthMap.put(6,'June');
    monthMap.put(7,'July');
    monthMap.put(8,'August');
    monthMap.put(9,'September');
    monthMap.put(10,'October');
    monthMap.put(11,'November');
    monthMap.put(12,'December');
    
    if(monthMap.containsKey(getMonth))
        formattedString = monthMap.get(getmonth) + ' ' + getday + ', ' + getyear;
    return formattedString;         
    }   
    
    
    global void finish(Database.BatchableContext BC) {
        /*toAddress.add('venkataraman.sriram@listertechnologies.com');
        toAddress.add('suraj.sreekumar@listertechnologies.com');
        emailMsg = 'HI ,'+'\r\n';
        emailMsg += 'Report for the invoices is ready.Kindly go and click on the link below to run the report .'+'\r\n'+'Please use a filter on the report with date as 1st day of Month i.e.(if Month is march select 1st march on the date picker)'+'\r\n';
        emailMsg += 'https://cs8.salesforce.com/00OL0000000agfa';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        mail.setSubject('Monthly Invoice Report Notification');
        mail.setSaveAsActivity(false); 
        mail.setHtmlBody(emailMsg);
        mail.setToAddresses(toAddress);
        Messaging.SendEmail(new Messaging.SingleEmailMessage[] { mail });*/    
    }
}
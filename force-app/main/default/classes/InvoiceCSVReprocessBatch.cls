/*
 * Created By : Lister Technologies
 * Created Date : 21-April-2015
 * Created Purpose : Batch Class which will be used to construct Invoice CSV reporting Data 
 *
 * Modified By : Lister Technologies
 * Modified Date : 19-June-2015
 * Modified Purpose : MHBS-153,MHBS-110
 *
 * Modified By : Lister Technologies
 * Modified Date : 16-July-2015
 * Modified Purpose : MHBS-206
*/ 
global class InvoiceCSVReprocessBatch implements Database.Batchable<sObject>,Database.Stateful{
    global String query;
    global String updateString;
    global Date tDate;
    global Date startDate;
    global Date endDate;
    global Date paymentStartDate;
    global Date paymentEndDate;
    global DateTime timeStamp;
    global String emailMsg;
    global String accToBeIgnored;
    global String invoiceCSVRunName;    
    global Decimal noOfTrials;
    public List<invoiceit_s__Invoice__c> lstInvoicesToUpdate;
    public List<invoiceit_s__Invoice__c> lstPostedInvProcessed;
    public Set<Id> setInvoiceIds;
    public Set<Id> setAccountIds;
    public Map<Id,List<invoiceit_s__Invoice_Lines__c>> mapInvoiceIdAndLstInvoiceLines;
    public Map<String,Double> mapInvLineNameNQty; 
    public Set<Id> setOrderRatePlanIds;
    public Set<String> setInvLineNames;
    public List<Account> lstAccount;
    public Id invoiceRunId;
    public Decimal invoicesGenFromInvRun;
    public Decimal postedInvoicesProcessed; 
    public Decimal invoicesProcessed;
    public Decimal invoicesFailed;
    public InvoiceCSVReprocessBatch(String rName,Decimal trials,Id invRunId,Date invoiceDate) {
        query ='';
        invoiceRunId = invRunId;
        tDate = Date.today();
        Invoice_CSV_Generator__c gen = Invoice_CSV_Generator__c.getValues('Test');
        startDate = invoiceDate;
        endDate = startDate.addMonths(1).toStartOfMonth().addDays(-1);
        paymentStartDate = startDate.addMonths(-1);
        paymentEndDate = paymentStartDate.addMonths(1).toStartOfMonth().addDays(-1);
        invoiceCSVRunName = rName;
        noOfTrials = trials;
        System.debug('***'+invoiceCSVRunName);
        accToBeIgnored = gen.Accounts_to_be_ignored__c;
        if(!(accToBeIgnored.contains('(') && accToBeIgnored.contains(')'))){
          accToBeIgnored = '(\'\')';
        }
        invoicesProcessed = 0;
        invoicesFailed = 0;
        postedInvoicesProcessed = 0;
        for(invoiceit_s__Invoice_Run__c invRun : [Select invoiceit_s__Invoices_Generated__c from invoiceit_s__Invoice_Run__c where Id=:invoiceRunId limit 1]){
            invoicesGenFromInvRun = invRun.invoiceit_s__Invoices_Generated__c;
        }
    }    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Name, Purchase_Order_Number__c, Total_Amount_Due__c,Invoice_Reporting_Data__c,Invoice_Reporting_Date__c,invoiceit_s__Invoice_Run_Created_By__c, invoiceit_s__Invoice_Status__c, invoiceit_s__Account__c, invoiceit_s__Account__r.Name, invoiceit_s__Account__r.MH_Cust_Number__c , invoiceit_s__Account__r.BillingCountry,invoiceit_s__Account__r.BillingStreet, invoiceit_s__Account__r.BillingCity, invoiceit_s__Account__r.BillingState, invoiceit_s__Account__r.BillingPostalCode, invoiceit_s__Billing_Contact__r.Name, CreatedDate ,invoiceit_s__Total_Invoice_Value__c, invoiceit_s__Net_Total__c,invoiceit_s__Invoice_Date__c, invoiceit_s__Due_Date__c , invoiceit_s__Tax__c, DS01__c'+
                                    ' From invoiceit_s__Invoice__c ' + 
                                    'where invoiceit_s__Invoice_Status__c != \'Cancelled\' '  + 
                                    'and invoiceit_s__Invoice_Date__c >= :startDate ' +
                                    'and Invoice_Reporting_Date__c = null and invoiceit_s__Invoice_Run_Created_By__c =: invoiceRunId '+                                                                       
                                    'and RecordType.DeveloperName = \'MH_Invoices\' and invoiceit_s__Account__r.Business_Unit__c!=\'SEED Account\' and invoiceit_s__Account__c not in'+ accToBeIgnored;
        if(test.isRunningTest()) {
            query += ' and invoiceit_s__Account__r.Name like \'%test%InvoiceCSV%\' LIMIT 5';
        }           
        
        System.debug('today'+tDate+'startDate'+startDate);
        System.debug('query passed is :'+query);
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<invoiceit_s__Invoice__c> scope) {
       try{     
            lstInvoicesToUpdate = new List<invoiceit_s__Invoice__c>();
            lstPostedInvProcessed = new List<invoiceit_s__Invoice__c>();
            setAccountIds = new Set<Id>();
            setInvoiceIds = new Set<Id>();
            mapInvoiceIdAndLstInvoiceLines = new Map<Id,List<invoiceit_s__Invoice_Lines__c>>();
            Map<Id,Decimal> mapAccIdNPreviousBalance = new Map<Id,Decimal>();
            Map<Id,Decimal> mapAccIdNCreditsNAdjustments = new Map<Id,Decimal>();
            Map<Id,Decimal> mapAccIdNPaymentsPosted = new Map<Id,Decimal>();
            lstAccount = new List<Account>();
            String invoiceCSVString = '';
            for(invoiceit_s__Invoice__c inv : scope) {
                setAccountIds.add(inv.invoiceit_s__Account__c);
                if(inv.Invoice_Reporting_Date__c == null && inv.invoiceit_s__Invoice_Run_Created_By__c == invoiceRunId && inv.invoiceit_s__Invoice_Date__c == startDate && (inv.invoiceit_s__Invoice_Status__c =='Draft' || (inv.invoiceit_s__Invoice_Status__c=='Posted' && inv.Invoice_Reporting_Data__c == null))) {
                    setInvoiceIds.add(inv.Id);  
                }           
            }
            
            for(Account acc : [Select Id,Name,MH_Cust_Number__c,Hold_dunning_letter_till__c,Dunning_Hold_for_30_days__c,Unallocated_Payment_Amount__c,Do_Not_Contact__c,
                                    RecordType.DeveloperName , Unpaid_amount__c, CreatedDate, 
                                    MH_Total_Payments__c, Posted_Invoices__c,
                                    (Select Name, Purchase_Order_Number__c,Invoice_Reporting_Date__c,invoiceit_s__Invoice_Run_Created_By__c, Total_Amount_Due__c,Invoice_Reporting_Data__c, invoiceit_s__Invoice_Status__c, invoiceit_s__Account__c, invoiceit_s__Account__r.Name, invoiceit_s__Account__r.MH_Cust_Number__c , invoiceit_s__Account__r.BillingCountry,invoiceit_s__Account__r.BillingStreet, invoiceit_s__Account__r.BillingCity, invoiceit_s__Account__r.BillingState, invoiceit_s__Account__r.BillingPostalCode, invoiceit_s__Billing_Contact__r.Name, CreatedDate ,invoiceit_s__Total_Invoice_Value__c, invoiceit_s__Net_Total__c,invoiceit_s__Invoice_Date__c, invoiceit_s__Due_Date__c , invoiceit_s__Tax__c, DS01__c
                                    From invoiceit_s__Invoices__r 
                                    where invoiceit_s__Invoice_Status__c != 'Cancelled'  
                                    and invoiceit_s__Invoice_Date__c >= :startDate                                                                                
                                    and RecordType.DeveloperName = 'MH_Invoices' limit 200),
                                    //Payment Method Subquery
                                    (Select Id, invoiceit_s__Account__c from invoiceit_s__Payment_Methods__r where invoiceit_s__Default__c = true and invoiceit_s__Active__c = true limit 200) , 
                                    //PAYMENT SUB QUERY
                                    (Select Id,Name, invoiceit_s__Payment_Date__c , CreatedDate, invoiceit_s__Account__c , invoiceit_s__Account__r.Hold_dunning_letter_till__c , 
                                    RecordType.DeveloperName ,invoiceit_s__Payment_Type__c, Applied_Type__c,invoiceit_s__Amount__c,invoiceit_s__Unallocated_Amount__c 
                                    from invoiceit_s__Payments__r 
                                    where ((invoiceit_s__Payment_Date__c >=:paymentStartDate and invoiceit_s__Payment_Type__c = 'Adjustment') OR (invoiceit_s__Payment_Type__c != 'Adjustment' and CreatedDate >=:paymentStartDate)) and (invoiceit_s__Amount__c!=0.0) and (invoiceit_s__Status__c = 'Completed') and RecordType.DeveloperName = 'MH_Payments' order by Name limit 200)                                                      
                                    from Account
                                    where RecordType.DeveloperName = 'MH_Accounts' and Id in :setAccountIds]){
                lstAccount.add(acc);                
            }
            
            //query all invoice lines and form a map of invoices and invoice lines
            for(invoiceit_s__Invoice_Lines__c invLines : [Select i.invoiceit_s__Total_Line_Amount__c,i.invoiceit_s__Quantity__c, 
                                                            i.invoiceit_s__Product_Name__c, i.invoiceit_s__Invoice__c, i.Id , 
                                                            i.invoiceit_s__Invoice__r.Id,
                                                            i.invoiceit_s__Invoice__r.invoiceit_s__Billing_Contact__r.Name,
                                                            i.invoiceit_s__Product_Rate_Plan_Charge__c , 
                                                            i.invoiceit_s__Job_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__c 
                                                            From invoiceit_s__Invoice_Lines__c i 
                                                            where i.invoiceit_s__Invoice__c in : setInvoiceIds and RecordType.DeveloperName = 'MDL_Invoice_Line']) {
                if(!mapInvoiceIdAndLstInvoiceLines.containsKey(invLines.invoiceit_s__Invoice__r.Id)) {
                    mapInvoiceIdAndLstInvoiceLines.put(invLines.invoiceit_s__Invoice__r.Id,new List<invoiceit_s__Invoice_Lines__c>{invLines});
                }
                else {
                    mapInvoiceIdAndLstInvoiceLines.get(invLines.invoiceit_s__Invoice__r.Id).add(invLines);
                }
            }
            
            
            for(Account acc : lstAccount) {
                Integer noOfPayments = 0; 
                String PS = '';
                String CS = '';
                Decimal total_AdjustmentsPayment = 0.00;
                Decimal total_otherPayments = 0.00;
                Boolean showCS = false;
                Boolean showPS = false;
                //*****           
                Decimal invAmt = 0.00;
                Decimal payAmt = 0.00;
                Decimal pastInvAmt = 0.00;
                Decimal pastPayAmt = 0.00;
                Decimal prevBalance = 0.00;
                Decimal creditsNAdjustments = 0.00;
                Decimal paymentsPosted = 0.00;
                Decimal totalAmtDue = 0.00;
                String auSectionString = '';
                for(invoiceit_s__Payment_Method__c payMethod : acc.invoiceit_s__Payment_Methods__r) {
                    auSectionString = '* Your account is on auto-pay, please do not remit a separate payment';
                }
                if(auSectionString == '') {
                    auSectionString = '* Make checks payable to Martindale LLC';
                }
                for(invoiceit_s__Invoice__c inv : acc.invoiceit_s__Invoices__r) {
                    if(inv.invoiceit_s__Invoice_Status__c == 'Posted') {
                        invAmt += inv.invoiceit_s__Total_Invoice_Value__c;
                    }
                }
                //payList = new List<PaymentWrapper>(); 
                //payAdjList = new List<PaymentWrapper>();
                for(invoiceit_s__Payment__c pay : acc.invoiceit_s__Payments__r) {
                    noOfPayments++;
                    payAmt += pay.invoiceit_s__Amount__c;
                    System.debug('^^inside payments'+pay.Name);
                    if(pay.invoiceit_s__Payment_Type__c == 'Adjustment' && pay.invoiceit_s__Payment_Date__c >= paymentStartDate && pay.invoiceit_s__Payment_Date__c < startDate) {
                        System.debug('%%adjustments are :'+pay.Id+'=='+pay.invoiceit_s__Amount__c);
                        creditsNAdjustments += pay.invoiceit_s__Amount__c;
                        //payList.add(new PaymentWrapper(pay,pay.invoiceit_s__Payment_Date__c));
                        
                        //for calculating CS
                        //if(pay.Applied_Type__c == 'Credit'){
                            showCS = true;
                            total_AdjustmentsPayment += pay.invoiceit_s__Amount__c;  
                            CS += 'CS|'+ convertDateToUSAFormat(pay.invoiceit_s__Payment_Date__c) + '||'+pay.Name + '|' + formatCSnPSValues(pay.invoiceit_s__Amount__c) + '|'+'\r\n';
                        //}
                        
                    }
                    else if(pay.invoiceit_s__Payment_Type__c != 'Adjustment' && convertCreatedDate(pay.CreatedDate) >= paymentStartDate && convertCreatedDate(pay.CreatedDate) < startDate){
                        System.debug('%%payments are :'+pay.Id+'=='+pay.invoiceit_s__Amount__c);
                        paymentsPosted += pay.invoiceit_s__Amount__c;
                        //payAdjList.add(new PaymentWrapper(pay,Date.valueOf(pay.CreatedDate)));
                        //for calculating PS
                        showPS = true;
                        PS += 'PS|'+ convertDateToUSAFormat(convertCreatedDate(pay.CreatedDate)) + '||' + pay.Name + '|'+ formatCSnPSValues(pay.invoiceit_s__Amount__c)+ '|'+'\r\n';
                    }
                }
                creditsNAdjustments = creditsNAdjustments * (-1);
                paymentsPosted = paymentsPosted * (-1);
                System.debug('adjustment final value::'+creditsNAdjustments+'***payments::'+paymentsPosted);
                pastInvAmt = acc.Posted_Invoices__c - invAmt;
                pastPayAmt = acc.MH_Total_Payments__c - payAmt;
                prevBalance = pastInvAmt - pastPayAmt;
                mapAccIdNPreviousBalance.put(acc.Id,prevBalance);
                mapAccIdNCreditsNAdjustments.put(acc.Id,creditsNAdjustments);
                mapAccIdNPaymentsPosted.put(acc.Id,paymentsPosted);
                for(invoiceit_s__Invoice__c inv : acc.invoiceit_s__Invoices__r) {
                    if(inv.invoiceit_s__Invoice_Status__c=='Posted'){
                        lstPostedInvProcessed.add(inv);
                    }
                    System.debug('inv status is:'+inv.invoiceit_s__Invoice_Status__c+'invoice date is ::'+inv.invoiceit_s__Invoice_Date__c+'inv reporting data::'+inv.Invoice_Reporting_Data__c);
                    if(inv.Invoice_Reporting_Date__c == null && inv.invoiceit_s__Invoice_Run_Created_By__c == invoiceRunId && inv.invoiceit_s__Invoice_Date__c == startDate && (inv.invoiceit_s__Invoice_Status__c =='Draft' || (inv.invoiceit_s__Invoice_Status__c=='Posted' && inv.Invoice_Reporting_Data__c == null))) { //invoices for which Invoice Reporting Data needs to be populated
                        System.debug('invoice to be picked up for populating reporting data:::'+inv);
                        mapInvLineNameNQty = new Map<String,Double>();
                        setOrderRatePlanIds = new Set<Id>();
                        
                        invoiceCSVString = '';
                        //MA Section
                        if(inv.invoiceit_s__Billing_Contact__r.Name != null) {
                            invoiceCSVString += populateMASection(inv.invoiceit_s__Billing_Contact__r.Name, inv.invoiceit_s__Account__r.Name,inv.invoiceit_s__Account__r.BillingStreet, inv.invoiceit_s__Account__r.BillingCity, inv.invoiceit_s__Account__r.BillingState, inv.invoiceit_s__Account__r.BillingPostalCode, inv.invoiceit_s__Account__r.BillingCountry,acc.Do_Not_Contact__c);
                        }
                        else{
                            invoiceCSVString += populateMASection('', inv.invoiceit_s__Account__r.Name,inv.invoiceit_s__Account__r.BillingStreet, inv.invoiceit_s__Account__r.BillingCity, inv.invoiceit_s__Account__r.BillingState, inv.invoiceit_s__Account__r.BillingPostalCode,inv.invoiceit_s__Account__r.BillingCountry, acc.Do_Not_Contact__c);
                        }
                        //AI Section
                        invoiceCSVString += populateAISection(inv.Name,inv.invoiceit_s__Invoice_Date__c,inv.invoiceit_s__Due_Date__c,inv.invoiceit_s__Account__r.MH_Cust_Number__c);
                        
                        //totalAccBalance calculation for AM section and Ds01 section
                        totalAmtDue = mapAccIdNPreviousBalance.get(acc.Id)+inv.invoiceit_s__Net_Total__c+mapAccIdNCreditsNAdjustments.get(acc.Id)+inv.invoiceit_s__Tax__c+mapAccIdNPaymentsPosted.get(acc.Id);
                        
                        //AM Section
                        invoiceCSVString += 'AM|' + formatDS01Values(totalAmtDue) + '*' + '\r\n';
                        
                        //BP Section 
                        invoiceCSVString += 'BP|' + convertDateToUSAFormat(paymentStartDate) + '|' + convertDateToUSAFormat(paymentEndDate) + '\r\n';
                        
                        //PO Section
                        if(inv.Purchase_Order_Number__c != null && inv.Purchase_Order_Number__c != ''){
                            invoiceCSVString += 'PO|' + inv.Purchase_Order_Number__c + '\r\n';
                        }                    
                        
                        //DS01 Section
                        updateString = '';
                        updateString += 'DS01|' + formatDS01Values(mapAccIdNPreviousBalance.get(acc.Id)) + '|' + formatDS01Values(inv.invoiceit_s__Net_Total__c) + '|' + formatDS01Values(inv.invoiceit_s__Tax__c) + '|' + formatDS01Values(mapAccIdNCreditsNAdjustments.get(acc.Id)) + '|' + formatDS01Values(mapAccIdNPaymentsPosted.get(acc.Id)) + '|' + formatDS01Values(totalAmtDue);
                        
                        invoiceCSVString += updateString + '\r\n';
                        
                        //AU Section
                        invoiceCSVString += 'AU|' + auSectionString + '\r\n';
                        
                        //CN Section
                        if(acc.MH_Cust_Number__c != null && acc.MH_Cust_Number__c != '') {
                            invoiceCSVString += 'CN|' + acc.MH_Cust_Number__c + '\r\n';
                        }
                        
                        //MP01 Section
                        
                        if(mapInvoiceIdAndLstInvoiceLines.containsKey(inv.Id)) {
                            for(invoiceit_s__Invoice_Lines__c invLines : mapInvoiceIdAndLstInvoiceLines.get(inv.Id)) {
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
                    
                    
                    
                        //MP01 Section value population
                        if(mapInvoiceIdAndLstInvoiceLines.containsKey(inv.Id)) {
                            //updateString += 'MP01' + '|';
                            system.debug('check1');
                            setInvLineNames = new Set<String>();
                            for(invoiceit_s__Invoice_Lines__c invLines : mapInvoiceIdAndLstInvoiceLines.get(inv.Id)) {
                                system.debug('check2');                        
                                if(mapInvLineNameNQty.containsKey(invLines.invoiceit_s__Product_Name__c) && (!setInvLineNames.contains(invLines.invoiceit_s__Product_Name__c))) {
                                    //updateString += invLines.invoiceit_s__Product_Name__c + '|' + invLines.invoiceit_s__Quantity__c + '|' + '$' + invLines.invoiceit_s__Total_Line_Amount__c + '|';
                                    setInvLineNames.add(invLines.invoiceit_s__Product_Name__c);
                                    invoiceCSVString += 'MP01' + '|' + invLines.invoiceit_s__Product_Name__c + '|' + mapInvLineNameNQty.get(invLines.invoiceit_s__Product_Name__c) + '|' + '\r\n';
                                }
                            }
                        } 
                        
                        //CT Section
                        invoiceCSVString +=  'CT'+'|';                                         
                        if(inv.invoiceit_s__Net_Total__c != null)
                            invoiceCSVString += formatDS01Values(inv.invoiceit_s__Net_Total__c);   //Net Total
                        invoiceCSVString += '|' ;
                        if(inv.invoiceit_s__Tax__c != null)
                            invoiceCSVString += formatDS01Values(inv.invoiceit_s__Tax__c);   //Taxes
                        invoiceCSVString += '|' ;   
                        if(inv.invoiceit_s__Total_Invoice_Value__c != null)
                            invoiceCSVString += formatDS01Values(inv.invoiceit_s__Total_Invoice_Value__c); //Grand Total
                        invoiceCSVString += '\r\n';
                        //End of CT
                        
                        //PS Section
                        if(showPS){
                            invoiceCSVString += PS; 
                        }
                        //TP Section
                       if(showPS){
                            invoiceCSVString += 'TP|' + formatDS01Values(paymentsPosted) + '\r\n';
                       }   
                       //CS Section
                       if(showCS){
                            invoiceCSVString += CS; 
                            //updateString += '\r\n';
                       }    
                       //TC Section
                       if(showCS){
                            invoiceCSVString += 'TC|' + formatDS01Values(creditsNAdjustments) + '\r\n';
                       }
                       // to replace all null in the string to empty string
                        if(invoiceCSVString.contains('null'))
                          invoiceCSVString = invoiceCSVString.replace('null',''); 
                         
                        inv.Invoice_Reporting_Data__c = invoiceCSVString;
                        inv.Invoice_Reporting_Date__c = startDate;
                        inv.DS01__c = updateString;
                        inv.Total_Amount_Due__c = totalAmtDue;
                        lstInvoicesToUpdate.add(inv);
                        System.debug('totalAmtDue'+totalAmtDue);
                    }
                }
            }
            if(lstInvoicesToUpdate.size() > 0) {
                Database.update(lstInvoicesToUpdate);
                invoicesProcessed += lstInvoicesToUpdate.size();
                System.debug('invoicesProcessed'+invoicesProcessed);
            } 
            if(lstPostedInvProcessed.size() > 0){
                postedInvoicesProcessed += lstPostedInvProcessed.size();
                System.debug('postedInvoicesProcessed'+postedInvoicesProcessed);
            }                
       }catch(Exception ex){
            System.debug('exception occurred:'+ex.getMessage());
            List<Invoice_CSV_Run__c> lstInvoiceCSVRunToUpdate = new List<Invoice_CSV_Run__c>();
            for(Invoice_CSV_Run__c invRun : [Select Id,Retry_Error_Description__c,Time_Stamp__c from Invoice_CSV_Run__c where Name= :invoiceCSVRunName and Status__c = 'In Progress']){
                if(invRun.Retry_Error_Description__c == null){
                    invRun.Retry_Error_Description__c = 'Attempt #'+noOfTrials;
                }
                else if(!invRun.Retry_Error_Description__c.contains('Attempt #'+noOfTrials)){
                    invRun.Retry_Error_Description__c += '\r\n'+'Attempt #'+noOfTrials;
                }
                invRun.Retry_Error_Description__c +='\r\n'+'Time Stamp : '+invRun.Time_Stamp__c.format('YYYY-MM-dd HH:mm:ss',UserInfo.getTimeZone().getID())+'\r\n';
                invRun.Retry_Error_Description__c +='Error : '+ex.getMessage()+'\r\n'+'-----------------------------------------------------------------------------'+'\r\n';
                lstInvoiceCSVRunToUpdate.add(invRun);
            }
            if(lstInvoiceCSVRunToUpdate.size() > 0){
                Database.update(lstInvoiceCSVRunToUpdate);
            }            
       }   
    }
    global String formatDS01Values(Decimal amtVal) {
        String formatString = '';
        if(amtVal < 0) {
            formatString = '-$'+Math.abs(amtVal).setScale(2, RoundingMode.HALF_UP);
        }
        else {
            formatString = '$'+ amtVal.setScale(2, RoundingMode.HALF_UP);
        }
        return formatString;
    }
    global String formatCSnPSValues(Decimal amtVal) {
        String formatString = '';
        if(amtVal > 0) {
            formatString = '-$'+Math.abs(amtVal).setScale(2, RoundingMode.HALF_UP);
        }
        else {
            formatString = '$'+ Math.abs(amtVal).setScale(2, RoundingMode.HALF_UP);
        }
        return formatString;
    }
    global String populateMASection(String contactName, String accName, String BillingStreet, String BillingCity, String BillingState, String BillingPostalCode,String BillingCountry,Boolean supressInvoice) {
        String supressInv = '';
        String country = '';
        String nonUSCountry = '';
        if(supressInvoice == false) {
            supressInv = '0';
        }
        else {
            supressInv = '1';
        }
        if(BillingCountry=='USA'){
            country = '';
            nonUSCountry = '';
        }
        //MHBS-206
        if((BillingCountry != '' && BillingCountry != NULL) && BillingCountry!='USA'){
            country = BillingCountry;
            nonUSCountry = 'F';        
        }
        if(contactName != '' && contactName.contains('|'))
            contactName = contactName.replace('|', ' ');
        if(accName.contains('|'))
            accName = accName.replace('|', ' ');
        System.debug('Billing Street1'+ BillingStreet);
        // Change for MHBS-110
        if(BillingStreet!=null && BillingStreet!=''){
            if(BillingStreet.contains('\r\n'))
                BillingStreet = BillingStreet.replace('\r\n',' ');
        }
        System.debug('Billing Street2'+ BillingStreet);
        String maSection = 'MA|'+contactName+'|'+accName+'|'+BillingStreet+'|'+BillingCity+'|'+BillingState+'|'+BillingPostalCode+'|'+country+'|'+supressInv+'|'+nonUSCountry+'\r\n';
        return maSection;
    }
    global String populateAISection(String invoiceName, Date invoiceDate, Date dueDate, String customerNumber) {
        String aiSection = 'AI|'+invoiceName+'|'+ convertDateToUSAFormat(invoiceDate) + '|' + convertDateToUSAFormat(dueDate) + '|' + customerNumber + '\r\n';
        return aiSection;
    }
    //convert created date from GMT to EST
    global Date convertCreatedDate(DateTime dt){
        Date formattedDt = Date.valueOf(dt.format('YYYY-MM-dd HH:mm:ss','America/New_York'));       
        return formattedDt;
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
        List<Invoice_CSV_Run__c> lstInvoiceCSVRunToUpdateFinal = new List<Invoice_CSV_Run__c>();
        String batchFailureReason = '';
        for(AsyncApexJob batch :[Select ExtendedStatus,NumberOfErrors,Status from AsyncApexJob where Id = :BC.getJobId()]){
            if(batch.NumberOfErrors > 0){
                batchFailureReason = batch.ExtendedStatus;
            }
        }
        for(Invoice_CSV_Run__c invRun : [Select Id,Retry_Error_Description__c,No_of_invoices_processed__c,Processed_Posted_Invoices__c from Invoice_CSV_Run__c where Name= :invoiceCSVRunName and Status__c = 'In Progress']){
            if(invRun.No_of_invoices_processed__c!=null)
                invRun.No_of_invoices_processed__c += invoicesProcessed;  
            else
                invRun.No_of_invoices_processed__c = invoicesProcessed;
            if(invRun.Processed_Posted_Invoices__c!=null)        
                invRun.Processed_Posted_Invoices__c += postedInvoicesProcessed; 
            else
                invRun.Processed_Posted_Invoices__c = postedInvoicesProcessed; 
            if(invRun.Retry_Error_Description__c==null || invRun.Retry_Error_Description__c==''){
                if(batchFailureReason==''){
                    invRun.Status__c = 'Completed';                 
                }
                else if(batchFailureReason!=''){
                    invRun.Status__c = 'Completed with Errors';
                    invRun.Retry_Error_Description__c = 'Attempt #'+noOfTrials+'\r\n';
                    invRun.Retry_Error_Description__c += batchFailureReason+'\r\n'+'-----------------------------------------------------------------------------'+'\r\n';
                }
                lstInvoiceCSVRunToUpdateFinal.add(invRun);
            }
            else{
                invRun.Status__c = 'Completed with Errors';
                if(batchFailureReason!=''){
                    if(!invRun.Retry_Error_Description__c.contains('Attempt #'+noOfTrials))
                        invRun.Retry_Error_Description__c += 'Attempt #'+noOfTrials+'\r\n';
                    invRun.Retry_Error_Description__c += batchFailureReason+'\r\n'+'-----------------------------------------------------------------------------'+'\r\n';
                }
                lstInvoiceCSVRunToUpdateFinal.add(invRun);
            }
        }
        if(lstInvoiceCSVRunToUpdateFinal.size() > 0){
            Database.update(lstInvoiceCSVRunToUpdateFinal);
        } 
    }
}
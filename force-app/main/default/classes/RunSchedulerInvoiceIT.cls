global class RunSchedulerInvoiceIT implements Schedulable {

    global void execute(SchedulableContext context) {
        //The context.getTriggerId returns the 18 char salesforce id
        //We have stored the 15 char id in invoiceit_s__Invoice_RunScheduler__c object
        //Truncate the last 3 characters and use them in the query

        String cronId = context.getTriggerId();
        
        if(cronId.Length() == 18) {
            cronId = cronId.substring(0,cronId.length()-3);
        } 
        
        System.debug('context.getTriggerId() ' + cronId);
        invoiceit_s__Invoice_RunScheduler__c invoiceRunSchedulerInvoiceIT = [SELECT invoiceit_s__Type__c, invoiceit_s__Target_Date__c, invoiceit_s__Start_Date__c, Name, 
                                                       invoiceit_s__Minutes__c, invoiceit_s__JobId__c, IsDeleted, invoiceit_s__Invoice_Date__c, 
                                                       Id, invoiceit_s__Hours__c, invoiceit_s__Frequency__c ,invoiceit_s__Invoice_Day_of_week__c,
                                                       invoiceit_s__Invoice_Day_Of_Month__c,invoiceit_s__Target_Day_of_week__c,
                                                       invoiceit_s__Target_Day_Of_Month__c,invoiceit_s__Invoice_Currency__c,Invoicing_Criteria__c,
                                                       invoiceit_s__Automatically_Post_Invoices__c
                                                       FROM invoiceit_s__Invoice_RunScheduler__c 
                                                       WHERE invoiceit_s__JobId__c = : cronId];
        
        Date invoiceDate, targetDate;
        Date todaysDate = system.today();        
        String sInvoiceRunSchedulerInvoiceITType = invoiceRunSchedulerInvoiceIT.invoiceit_s__Type__c;

        if(sInvoiceRunSchedulerInvoiceITType == 'Once') {
            invoiceDate = invoiceRunSchedulerInvoiceIT.invoiceit_s__Invoice_Date__c;
            System.debug('invoiceRunSchedulerInvoiceIT.Invoicing_Criteria__cinvoiceRunSchedulerInvoiceIT.Invoicing_Criteria__c-->'+invoiceRunSchedulerInvoiceIT.Invoicing_Criteria__c);
            if(invoiceRunSchedulerInvoiceIT.Invoicing_Criteria__c == 'Arrears'){
                date targetDateRef = invoiceDate.addMonths(-1);
                targetDate = date.newinstance(targetDateRef.year(), targetDateRef.month(), 1);
                System.debug('If target->'+targetDate);  
            }else{
                //targetDate = invoiceDate; 
                targetDate = date.newinstance(invoiceDate.year(), invoiceDate.month(), 1);
                System.debug('Else target->'+targetDate);   
            }
        } else if(sInvoiceRunSchedulerInvoiceITType == 'Monthly') {
            Integer invoice_dayofmonth = Integer.ValueOf(invoiceRunSchedulerInvoiceIT.invoiceit_s__Invoice_Day_Of_Month__c);
            //Integer target_dayofmonth = Integer.ValueOf(invoiceRunSchedulerInvoiceIT.invoiceit_s__Target_Day_Of_Month__c);
            Integer target_dayofmonth = 1;
            //Check if these days are greater than the last day of the running month. If yes reset these days to last day of the month
            //If the invoice_dayofmonth is 31 and the scheduler is running on 29th, the value will be reset to 29
            Integer daysInMonth = date.daysInMonth(todaysDate.year(), todaysDate.month());
            if(invoice_dayofmonth > daysInMonth) {
                invoice_dayofmonth = daysInMonth;
            }
            if(target_dayofmonth > daysInMonth) {
                target_dayofmonth = daysInMonth;
            }

            invoiceDate = date.newinstance(todaysDate.year(), todaysDate.month(), invoice_dayofmonth);
            if(invoiceRunSchedulerInvoiceIT.Invoicing_Criteria__c == 'Arrears'){
                date targetDateRef = invoiceDate.addMonths(-1);
                targetDate = date.newinstance(targetDateRef.year(), targetDateRef.month(), 1);
            }else{
            
                targetDate = date.newinstance(invoiceDate.year(), invoiceDate.month(), 1);
            }
            
        }

        String orderStatusForInvoicing = (invoiceit_s__Configuration__c.getValues('ORDER_STATUS_FOR_INVOICING').invoiceit_s__String_Value__c);
        String groupBy = (invoiceit_s__Configuration__c.getValues('INVOICE_GROUP_CRITERIA').invoiceit_s__String_Value__c);
        String s = invoiceit_s__Configuration__c.getValues('INVOICEIT_BATCH_JOBS_TO_PROCESS').invoiceit_s__String_Value__c;
        Integer batchSize ; 
        if(s!=null) { 
             batchSize = integer.valueOf(s);   
        }else {
             batchSize = 1;
        }            
        
        String query;

        String targetDateString = targetDate.year() + '-';
        if(targetDate.month() < 10) {
            targetDateString += '0' + targetDate.month() + '-'; 
        } else {
            targetDateString += targetDate.month() + '-';
        }
        if(targetDate.day() < 10) {
            targetDateString += '0' + targetDate.day();
        } else {
            targetDateString += targetDate.day();
        }

        //Depending upon the grouping parameter pass the accountids or the jobids
        if(groupBy == 'ONE_INVOICE_PER_ACCOUNT') 
        {
            query = 'select invoiceit_s__Account__c from invoiceit_s__Job__c'; 
        } else {
            query = 'select id from invoiceit_s__Job__c'; 
        }

        query +=    ' where invoiceit_s__Account__c != null' +
                    ' and invoiceit_s__Service_Activation_Date__c <= '+ targetDateString +
                    ' and(invoiceit_s__Charges_without_a_Charge_Date__c > 0' +  
                    ' or invoiceit_s__Minimum_Next_Charge_Date_For_Product__c <= '+ targetDateString+')'+
                    ' and invoiceit_s__Preferred_Billing_Day__c = \'1\''; 
                    
        //If the order's status field for invoicing is mentioned then use that in the where clause 
        if(orderStatusForInvoicing != null && orderStatusForInvoicing.trim().length() > 0) {
            query += ' and invoiceit_s__Status__c = \'' + orderStatusForInvoicing + '\'';
        }
        
        query += ' and invoiceit_s__CurrencyL__c = \'' + invoiceRunSchedulerInvoiceIT.invoiceit_s__Invoice_Currency__c +'\' AND invoiceit_s__Account__r.Billing_Schedule__c = \''+invoiceRunSchedulerInvoiceIT.Invoicing_Criteria__c+'\' ';
        
        system.debug('This is the query ='+query);        

        invoiceit_s.BatchInvoiceGeneration1 batch = new invoiceit_s.BatchInvoiceGeneration1(query, 
                                                                    groupBy, 
                                                                    invoicedate, 
                                                                    targetdate,
                                                                    invoiceRunSchedulerInvoiceIT.invoiceit_s__Invoice_Currency__c,
                                                                    invoiceRunSchedulerInvoiceIT.Name,
                                                                    invoiceRunSchedulerInvoiceIT.Id);
                                                                    
        ID batchprocessid = Database.executeBatch(batch,batchSize);
    } 
}
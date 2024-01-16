public with sharing class InvoiceSummaryActPDF
{


    public String sInvoiceID{get;set;}
    public String sInvoiceSource{get;set;}
    public Date dDate{get;set;}
    public Date physicalproductDate{get;set;}
    public Date physicalproductDueDate{get;set;}
    public Date physicalproductStartDate{get;set;}
    public Date physicalproductEndDate{get;set;}
    public List<invoiceit_s__Payment__c> payementsList{get;set;}
    public List<invoiceit_s__Payment__c> adjustmentsList{get;set;}
    public double adjustmentTotal {get;set;}
    public double paymentTotal {get;set;}
    public boolean paymentsboolean {get;set;}
    //public invoiceit_s__Invoice__c oInvoice{get;set;}
    public List<invoiceit_s__Payment_Method__c> paymentMethodasDefault{get;set;}
    //public List<String> invoiceLinesList{get;set;}
    //public list<invoiceit_s__Invoice_Lines__c> listInvLI{get;set;}
    public map<string,double>listInvLI{get;set;}
    public InvoiceSummaryActPDF()
    {
        system.debug('invoice id --> ' + sInvoiceID);
        if(sInvoiceID==null){   
            String invid= ApexPages.currentPage().getParameters().get('id');
            sInvoiceID=invid;
        }   
            /*oInvoice = new invoiceit_s__Invoice__c();
            String Invoice = 'SELECT Name,Total_Amount_Due__c,Account_Balance__c,Street_Address__c,City__c,State__c,Zip_Code__c,Previous_Balance__c,Total_Credits__c,Total_Payments__c,Amount_Due__c,invoiceit_s__Invoice_Date__c,invoiceit_s__Account__r.Name,invoiceit_s__Amount__c,invoiceit_s__Tax__c, ';
                Invoice += ' invoiceit_s__Account__r.BillingCity,invoiceit_s__Account__r.BillingState,invoiceit_s__Account__r.BillingPostalCode,invoiceit_s__Due_Date__c,invoiceit_s__Net_Total__c,invoiceit_s__Total_Invoice_Value__c, ';
                Invoice += ' invoiceit_s__Account__r.BillingCountry,invoiceit_s__Account__r.BillingStreet,invoiceit_s__Account__r.invoiceit_s__Payment_Terms__c, NOLO_Payments_Previous_Month__c, NOLO_Credits_Previous_Month__c, ';
                Invoice += ' invoiceit_s__Account__r.Account_Number__c,invoiceit_s__Billing_Contact__r.Name,invoiceit_s__Account__r.Account_Balance__c, invoiceit_s__Account__r.MH_Cust_Number__c, ';
                Invoice += ' invoiceit_s__Order__r.invoiceit_s__Tax__c,invoiceit_s__Order__r.invoiceit_s__Charges_without_a_Charge_Date__c,invoiceit_s__Billing_Contact__r.email, NOLO_Amount_due__c ';
                Invoice += ' from invoiceit_s__Invoice__c WHERE ID=\''+sInvoiceID + '\'';
                ReturnInvoice oInv = new ReturnInvoice (Invoice);
                if([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND status in ('Queued','Processing','Preparing')] < 5)
                    Database.executeBatch(oInv ,4);
                 oInvoice = Database.query(oInv.query); 
            Date invoiceDate = oInvoice.invoiceit_s__Invoice_Date__c;
            Date firstDayOfMonth = invoiceDate.addMonths(-1).toStartOfMonth();
            Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
        }
        paymentsboolean = false;
        
        system.debug('@@@@sInvoiceID' + sInvoiceID);
        adjustmentTotal = 0;
        paymentTotal = 0;
        if(sInvoiceID != null){
            Date invoiceDate = oInvoice.invoiceit_s__Invoice_Date__c;
            Date firstDayOfMonth = invoiceDate.addMonths(-1).toStartOfMonth();
            Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
            Id noloinvpayRecId = Schema.SObjectType.invoiceit_s__Payment__c.RecordTypeInfosByName.get(RecordTypesFinalStringsClass.RecTypeName_MH_Payments).RecordTypeId;
            system.debug('@@@in query'); 
                List<invoiceit_s__Payment__c> allpaymentsList = new List<invoiceit_s__Payment__c>();
                allpaymentsList = [select id, Name,
                                 invoiceit_s__Payment_Date__c,
                                invoiceit_s__Amount__c, invoiceit_s__Invoice__c,
                               invoiceit_s__Payment_Type__c, Invoice__c 
                                from  invoiceit_s__Payment__c
                                 where invoiceit_s__Account__c =:oInvoice.invoiceit_s__Account__c
                                  and invoiceit_s__Status__c = 'Completed'
                                  and RecordTypeId =:noloinvpayRecId 
                                  
                                  and Date_Based_on_Type__c >=: firstDayOfMonth
                                  and Date_Based_on_Type__c <=: lastDayOfMonth];
            adjustmentsList = new List<invoiceit_s__Payment__c>();
             payementsList = new List<invoiceit_s__Payment__c>();
            for(invoiceit_s__Payment__c invpay : allpaymentsList){
                system.debug('@@@in payments');
                if(invpay.invoiceit_s__Payment_Type__c == 'Adjustment'){ 
                    adjustmentsList.add(invpay);
                    adjustmentTotal += invpay.invoiceit_s__Amount__c;
                    paymentsboolean = true;
                    
                }
                else{
                    payementsList.add(invpay);
                    paymentTotal += invpay.invoiceit_s__Amount__c;
                    paymentsboolean = true;
                }
            }
        }
        
        
        paymentMethodasDefault = new List<invoiceit_s__Payment_Method__c>();
        paymentMethodasDefault = [select id,Name,
                                   invoiceit_s__Account__c, invoiceit_s__Default__c
                                    from invoiceit_s__Payment_Method__c
                                      where invoiceit_s__Default__c = true
                                        and invoiceit_s__Account__c =:oInvoice.invoiceit_s__Account__c 
                                       LIMIT 1];
        
        dDate = Date.today();
        physicalproductDate=date.newinstance(2014, 12, 31);
        physicalproductDueDate=physicalproductDate.addDays(10);
        physicalproductStartDate=date.newinstance(2014, 1, 1);
        physicalproductEndDate=date.newinstance(2014, 12, 31);*/
    }
    
    public invoiceit_s__Invoice__c oInvoice { 
        set; 
        get {
                if(sInvoiceID == '' || sInvoiceID == null)
                    return oInvoice;
                
                oInvoice = new invoiceit_s__Invoice__c();
                String Invoice = 'SELECT Name,Total_Amount_Due__c,Account_Balance__c,Street_Address__c,City__c,State__c,Zip_Code__c,Previous_Balance__c,Total_Credits__c,Total_Payments__c,Amount_Due__c,invoiceit_s__Invoice_Date__c,invoiceit_s__Account__r.Name,invoiceit_s__Amount__c,invoiceit_s__Tax__c, ';
                Invoice += ' invoiceit_s__Account__r.BillingCity,invoiceit_s__Account__r.BillingState,invoiceit_s__Account__r.BillingPostalCode,invoiceit_s__Due_Date__c,invoiceit_s__Net_Total__c,invoiceit_s__Total_Invoice_Value__c, ';
                Invoice += ' invoiceit_s__Account__r.BillingCountry,invoiceit_s__Account__r.BillingStreet,invoiceit_s__Account__r.invoiceit_s__Payment_Terms__c, NOLO_Payments_Previous_Month__c, NOLO_Credits_Previous_Month__c, ';
                Invoice += ' invoiceit_s__Account__r.Account_Number__c,invoiceit_s__Billing_Contact__r.Name,invoiceit_s__Account__r.Account_Balance__c, invoiceit_s__Account__r.MH_Cust_Number__c, ';
                Invoice += ' invoiceit_s__Order__r.invoiceit_s__Tax__c,invoiceit_s__Order__r.invoiceit_s__Charges_without_a_Charge_Date__c,invoiceit_s__Billing_Contact__r.email, NOLO_Amount_due__c ';
                Invoice += ' from invoiceit_s__Invoice__c WHERE ID=\''+sInvoiceID + '\'';
                //ReturnInvoice oInv = new ReturnInvoice (Invoice);
                //if([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND status in ('Queued','Processing','Preparing')] < 5)
                    //Database.executeBatch(oInv ,4);
                 //oInvoice = Database.query(oInv.query);
                oInvoice = Database.query(Invoice);
                paymentsboolean = false;
        
        system.debug('@@@@sInvoiceID' + sInvoiceID);
        adjustmentTotal = 0;
        paymentTotal = 0;
        if(sInvoiceID != null){
            Date invoiceDate = oInvoice.invoiceit_s__Invoice_Date__c;
            Date firstDayOfMonth = invoiceDate.addMonths(-1).toStartOfMonth();
            Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
            Id noloinvpayRecId = Schema.SObjectType.invoiceit_s__Payment__c.RecordTypeInfosByName.get(RecordTypesFinalStringsClass.RecTypeName_MH_Payments).RecordTypeId;
            Id MHinvpayRecId = Schema.SObjectType.invoiceit_s__Payment__c.RecordTypeInfosByName.get(RecordTypesFinalStringsClass.RecTypeName_JV_Payments).RecordTypeId;
            
            system.debug('@@@in query'); 
                List<invoiceit_s__Payment__c> allpaymentsList = new List<invoiceit_s__Payment__c>();
                allpaymentsList = [select id, Name,
                                 invoiceit_s__Payment_Date__c,
                                invoiceit_s__Amount__c, invoiceit_s__Invoice__c,
                               invoiceit_s__Payment_Type__c, Invoice__c 
                                from  invoiceit_s__Payment__c
                                 where invoiceit_s__Account__c =:oInvoice.invoiceit_s__Account__c
                                  and invoiceit_s__Status__c = 'Completed'
                                  and (RecordTypeId =:noloinvpayRecId or RecordTypeId =:MHinvpayRecId) 
                                  
                                  and Date_Based_on_Type__c >=: firstDayOfMonth
                                  and Date_Based_on_Type__c <=: lastDayOfMonth];
            adjustmentsList = new List<invoiceit_s__Payment__c>();
             payementsList = new List<invoiceit_s__Payment__c>();
            for(invoiceit_s__Payment__c invpay : allpaymentsList){
                system.debug('@@@in payments');
                if(invpay.invoiceit_s__Payment_Type__c == 'Adjustment'){ 
                    adjustmentsList.add(invpay);
                    adjustmentTotal += invpay.invoiceit_s__Amount__c;
                    paymentsboolean = true;
                    
                }
                else{
                    payementsList.add(invpay);
                    paymentTotal += invpay.invoiceit_s__Amount__c;
                    paymentsboolean = true;
                }
            }
        }
        
        
        paymentMethodasDefault = new List<invoiceit_s__Payment_Method__c>();
        paymentMethodasDefault = [select id,Name,
                                   invoiceit_s__Account__c, invoiceit_s__Default__c
                                    from invoiceit_s__Payment_Method__c
                                      where invoiceit_s__Default__c = true
                                        and invoiceit_s__Account__c =:oInvoice.invoiceit_s__Account__c 
                                       LIMIT 1];
        
        dDate = Date.today();
        physicalproductDate=date.newinstance(2014, 12, 31);
        physicalproductDueDate=physicalproductDate.addDays(10);
        physicalproductStartDate=date.newinstance(2014, 1, 1);
        physicalproductEndDate=date.newinstance(2014, 12, 31);
        return oInvoice;
                 
            }
    }
    
     public Date StartDate{ 
        set; 
        get {
                if(sInvoiceID == '' || sInvoiceID == null)
                    return null;
                
                id nolo_account_recttypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Account).getRecordTypeId();
                invoiceit_s__Invoice__c  Invoice = [SELECT Name,invoiceit_s__Invoice_Date__c,Arrears_Invoice__c , 
                                                           invoiceit_s__Account__r.Billing_Schedule__c,
                                                           invoiceit_s__Account__r.RecordTypeId

                                                           from invoiceit_s__Invoice__c WHERE ID=:sInvoiceID];
                if(Invoice.invoiceit_s__Invoice_Date__c != null){
                    if(Invoice.invoiceit_s__Account__r.RecordTypeId == nolo_account_recttypeId
                              //&& Invoice.invoiceit_s__Account__r.Billing_Schedule__c == 'Arrears'
                              && Invoice.Arrears_Invoice__c == True){
                        return  Invoice.invoiceit_s__Invoice_Date__c.addMonths(-1).toStartOfMonth();
                    }
                  else {
                      return Invoice.invoiceit_s__Invoice_Date__c.toStartOfMonth(); 
                  }                     
               }     
                else
                    return null;
            }
    }
    
    public Date EndDate{ 
        set; 
        get {
                if(sInvoiceID == '' || sInvoiceID == null)
                    return null;
                 id nolo_account_recttypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Account).getRecordTypeId();

                invoiceit_s__Invoice__c  Invoice = [SELECT Name,invoiceit_s__Invoice_Date__c,Arrears_Invoice__c ,
                                                           invoiceit_s__Account__r.Billing_Schedule__c,
                                                           invoiceit_s__Account__r.RecordTypeId
                                                      from invoiceit_s__Invoice__c WHERE ID=:sInvoiceID];                
                if(Invoice.invoiceit_s__Invoice_Date__c != null){
                    if(Invoice.invoiceit_s__Account__r.RecordTypeId == nolo_account_recttypeId 
                    //&& Invoice.invoiceit_s__Account__r.Billing_Schedule__c == 'Arrears'
                    && Invoice.Arrears_Invoice__c   == True){
                       date startDate = Invoice.invoiceit_s__Invoice_Date__c.addMonths(-1).toStartOfMonth();
                       Integer numberOfDays = Date.daysInMonth(startDate.year(), startDate.month());
                       return Date.newInstance(startDate.year(), startDate.month(), numberOfDays);
                    }
                  else {
                      //return Invoice.invoiceit_s__Invoice_Date__c.toStartOfMonth(); 
                      return Invoice.invoiceit_s__Invoice_Date__c.toStartOfMonth().addMonths(1)-1;
                  }                     
               }     
                else
                    return null;
            }
    }
    
    public Decimal dTotalPayment {
        set; 
        get{
                Decimal dTotal = 0;
                Date dStartDate = Date.Today();
                Date dEndDate = Date.Today();
                if(sInvoiceID == '' || sInvoiceID == null)
                    return dTotal.setScale(2) ;
                invoiceit_s__Invoice__c  Invoice1 = [SELECT invoiceit_s__Invoice_Date__c from invoiceit_s__Invoice__c 
                                                    WHERE ID=:sInvoiceID]; 
                if(Invoice1 != null)
                {                                     
                    if(Invoice1.invoiceit_s__Invoice_Date__c != null)
                    {
                        dStartDate = Invoice1.invoiceit_s__Invoice_Date__c.toStartOfMonth();                        
                        dEndDate = Invoice1.invoiceit_s__Invoice_Date__c.toStartOfMonth().addMonths(1)-1;
                    }
                    invoiceit_s__Invoice__c  Invoice = [SELECT invoiceit_s__Account__c
                                                      from invoiceit_s__Invoice__c WHERE ID=:sInvoiceID];
                    
                    if(Invoice  != null)
                    {
                        for(invoiceit_s__Payment__c obj : [SELECT invoiceit_s__Amount__c from invoiceit_s__Payment__c WHERE invoiceit_s__Account__c=:Invoice.invoiceit_s__Account__c AND
                                                           invoiceit_s__Payment_Date__c >=: dStartDate AND invoiceit_s__Payment_Date__c <=: dEndDate])
                            dTotal += obj.invoiceit_s__Amount__c ;
                    }
                    return dTotal.setScale(2) ;
                }
                return dTotal.setScale(2) ;
        }
    }
    
    public Decimal dCreditPayment {
        set; 
        get{
                Decimal dTotal = 0.00;
                if(sInvoiceID == '' || sInvoiceID == null)
                    return dTotal.setScale(2) ;
                    
                invoiceit_s__Invoice__c  Invoice = [SELECT invoiceit_s__Account__c
                                                  from invoiceit_s__Invoice__c WHERE ID=:sInvoiceID];
                
                if(Invoice  != null)
                {
                    for(invoiceit_s__Payment__c obj : [SELECT invoiceit_s__Amount__c from invoiceit_s__Payment__c WHERE invoiceit_s__Account__c=:Invoice.invoiceit_s__Account__c AND invoiceit_s__Payment_Type__c='Promotional Credit'])
                        dTotal += obj.invoiceit_s__Amount__c ;
                }
                return dTotal.setScale(2) ;
        }
    }
    
    //forming map to show quantity added if existed
    public List<String> invoiceLinesList {
        set; 
        
        get {
                system.debug('??? !!! --> ' + sInvoiceID );
                Map<Id,List<invoiceit_s__Invoice_Lines__c>> mapInvoiceIdAndLstInvoiceLines = new Map<Id,List<invoiceit_s__Invoice_Lines__c>>();
                List<String> invoiceLinesListtemp  = new List<String>();
                set<String> invoiceListSet = new Set<String>();
                listInvLI = new map<string,double>();
               for(invoiceit_s__Invoice_Lines__c invLines : [Select i.invoiceit_s__Total_Line_Amount__c,i.invoiceit_s__Quantity__c, 
                                                            i.invoiceit_s__Product_Name__c, i.invoiceit_s__Invoice__c, i.Id , 
                                                            i.invoiceit_s__Invoice__r.Id,
                                                            i.invoiceit_s__Invoice__r.invoiceit_s__Billing_Contact__r.Name,
                                                            i.invoiceit_s__Product_Rate_Plan_Charge__c ,
                                                            i.Product_order__c, 
                                                            i.invoiceit_s__Job_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__c 
                                                            From invoiceit_s__Invoice_Lines__c i 
                                                            where i.invoiceit_s__Invoice__c =: sInvoiceID and RecordType.DeveloperName = 'NOLO_Invoice_Line'
                                                            ORDER By i.Product_order__c ASC]) {
                
                system.debug('@@@@ product order '+invLines.Product_order__c );                                            
                if(!mapInvoiceIdAndLstInvoiceLines.containsKey(invLines.invoiceit_s__Invoice__r.Id)) {
                    mapInvoiceIdAndLstInvoiceLines.put(invLines.invoiceit_s__Invoice__r.Id,new List<invoiceit_s__Invoice_Lines__c>{invLines});
                    system.debug('@@@@ Mapped Inv Lines'+ mapInvoiceIdAndLstInvoiceLines);
                }
                else {
                    mapInvoiceIdAndLstInvoiceLines.get(invLines.invoiceit_s__Invoice__r.Id).add(invLines);
                    system.debug('@@@@ Mapped Invoice Lines values '+ mapInvoiceIdAndLstInvoiceLines);
                }
            }
            
            system.debug('@@@@@@mapInvoiceIdAndLstInvoiceLines'+mapInvoiceIdAndLstInvoiceLines);
             Map<String,Double> mapInvLineNameNQty = new Map<String,Double>();
             Set<Id> setOrderRatePlanIds = new Set<Id>();
             if(mapInvoiceIdAndLstInvoiceLines.containsKey(sInvoiceID)) {
                            for(invoiceit_s__Invoice_Lines__c invLines : mapInvoiceIdAndLstInvoiceLines.get(sInvoiceID)) {
                                system.debug('@@@@@@invLines'+ invLines.id + ' Name: '+invLines.invoiceit_s__Product_Name__c);
                                system.debug('@@@@@@mapInvLineNameNQty'+mapInvLineNameNQty);
                                invoiceListSet.add(invLines.invoiceit_s__Product_Name__c);
                                if(mapInvLineNameNQty.containsKey(invLines.invoiceit_s__Product_Name__c)) {
                                    if(mapInvLineNameNQty.containsKey(invLines.invoiceit_s__Product_Name__c)) {
                                        //mapInvLineNameNQty.put(invLines.invoiceit_s__Product_Name__c,invLines.invoiceit_s__Quantity__c);
                                        if(!setOrderRatePlanIds.contains(invLines.invoiceit_s__Job_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__c)) {
                                            setOrderRatePlanIds.add(invLines.invoiceit_s__Job_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__c);
                                            Double i = 0;
                                            i = mapInvLineNameNQty.get(invLines.invoiceit_s__Product_Name__c) + invLines.invoiceit_s__Quantity__c;
                                            mapInvLineNameNQty.put(invLines.invoiceit_s__Product_Name__c,i);
                                            system.debug('@@@@ Mapped Product '+ mapInvLineNameNQty);
                                        }                                
                                    }
                                    else {
                                        mapInvLineNameNQty.put(invLines.invoiceit_s__Product_Name__c,invLines.invoiceit_s__Quantity__c);
                                        setOrderRatePlanIds.add(invLines.invoiceit_s__Job_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__c);
                                        system.debug('@@@@ Mapped Product  ORPC 1'+ setOrderRatePlanIds);
                                    }
                                }
                                else{
                                     mapInvLineNameNQty.put(invLines.invoiceit_s__Product_Name__c,invLines.invoiceit_s__Quantity__c);
                                     setOrderRatePlanIds.add(invLines.invoiceit_s__Job_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__c);
                                     system.debug('@@@@ Mapped Product  ORPC 2'+ setOrderRatePlanIds);
                                }        
                            }
                        } 
                        
                /*list<invoiceit_s__Invoice_Lines__c> listOfInvoiceLines = [SELECT Name,invoiceit_s__Line_Amount__c,invoiceit_s__Product__r.Name,invoiceit_s__Quantity__c,invoiceit_s__Unit_Price__c,invoiceit_s__Job_Rate_Plan_Charge__r.Name,
                        invoiceit_s__Product__c
                        from invoiceit_s__Invoice_Lines__c 
                        WHERE invoiceit_s__Invoice__c=:sInvoiceID and invoiceit_s__Product_Rate_Plan_Charge__r.Exclude_from_Invoices__c = false];
                map<String, Integer> invlinemap = new map<string,Integer>();
               for(invoiceit_s__Invoice_Lines__c invline : listOfInvoiceLines){
                   if(invlinemap.containsKey(invline.invoiceit_s__Product__r.Name)){
                       Integer quantity = Integer.valueOf(invlinemap.get(invline.invoiceit_s__Product__r.Name) + invline.invoiceit_s__Quantity__c);
                       invlinemap.put(invline.invoiceit_s__Product__r.Name, quantity);
                       
                   }
                   else{
                       invlinemap.put(invline.invoiceit_s__Product__r.Name, Integer.valueOf(invline.invoiceit_s__Quantity__c));
                   }
               }*/
            
                
                listInvLI =  mapInvLineNameNQty ;
                invoiceLinesListtemp.addAll(invoiceListSet);
                return invoiceLinesListtemp;
                //return invlinemap ;
            }
    }
    
    public PageReference send(){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        PageReference pdf =  Page.InvoiceSummaryPhysicalProductPDF;
        pdf.getParameters().put('id',(String)sInvoiceID); 
        pdf.setRedirect(true);
         Blob b;
        // Take the PDF content
               
        try {

          // returns the output of the page as a PDF
          b = pdf.getContent();
    
        // need to pass unit test -- current bug  
        } 
        catch (VisualforceException e) {
           b = Blob.valueOf('Some Text');
        }
       
        String attachmentName = oInvoice.invoiceit_s__Account__r.MH_Cust_Number__c + oInvoice.Name+'.pdf';
        // Create the email attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(attachmentName);
        efa.setBody(b);
        String[] toAddresses;
        if(oInvoice.invoiceit_s__Billing_Contact__r.email !=null){
            toAddresses=new String[]{oInvoice.invoiceit_s__Billing_Contact__r.email};
            email.setSubject('Invoice for Martindale-Hubbell® Law Directory Annual Subscription Product Only');
            email.setToAddresses( toAddresses );
            string body='Hi '+oInvoice.invoiceit_s__Billing_Contact__r.name+', \n\r'+'Attached please find the invoice for your annual Martindale services in the amount of $'+oInvoice.invoiceit_s__Total_Invoice_Value__c+'.  Thank you for your continued business and please contact us if you have any questions or concerns.\n\rBest regards,\n\rMartindale Billing Department\n\rPhone 888-334-7371\n\rbilling@martindalenolo.com'; 
            email.setPlainTextBody(body);
    
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
    
            // Sends the email
            Messaging.SendEmailResult [] r = 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
        }
  
        return (new Pagereference('/'+sInvoiceID)); 
        
        
    }
    public Pagereference cancel(){
    
        Pagereference pg=new Pagereference('/'+sInvoiceID);
        return pg;
    }
    
    public pagereference showpdf(){
        Pagereference pg=new Pagereference('/'+sInvoiceID);
        return pg;   
    }
}
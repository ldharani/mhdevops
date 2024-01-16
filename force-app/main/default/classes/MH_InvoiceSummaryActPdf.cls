public with sharing class MH_InvoiceSummaryActPdf{
    
    
    public String sInvoiceID{get;set;}
    public String sInvoiceSource{get;set;}
    public Date dDate{get;set;}
    public Date physicalproductDate{get;set;}
    public Date physicalproductDueDate{get;set;}
    public Date physicalproductStartDate{get;set;}
    public Date physicalproductEndDate{get;set;}
    public List<blng__Payment__c> payementsList{get;set;}
    public List<blng__CreditNote__c > CreditNoteList{get;set;}
    public List<blng__DebitNote__c > debitnoteList{get;set;}
    public double adjustmentTotal {get;set;}
    public double paymentTotal {get;set;}
    public boolean paymentsboolean {get;set;}
    public List<blng__PaymentMethod__c> paymentMethodasDefault{get;set;}
    public list<wrapProduct> wrapperProductlist{get;set;}
     public map<string,double>listInvLI{get;set;}
     
    public MH_InvoiceSummaryActPdf()
    {
        system.debug('invoice id --> ' + sInvoiceID);
        if(sInvoiceID==null){   
            String invid= ApexPages.currentPage().getParameters().get('id');
            sInvoiceID=invid;
        }   
        
    }
    
    public class wrapProduct {
        public string ProdName {get; set;}
        public double quantity {get; set;}
 
        public wrapProduct(string prod,double quan) {
            ProdName = prod;
            quantity = quan;
        }
    }
    
    public blng__Invoice__c oInvoice { 
        set; 
        get {
            if(sInvoiceID == '' || sInvoiceID == null)
                return oInvoice;
            
            oInvoice = new blng__Invoice__c();
            String Invoice = 'SELECT Name ,Legacy_Total_Amount_Due__c,MH_Balance_Previous_Month__c ,Total_Amount_Due__c,blng__InvoiceDate__c,blng__Account__r.Name,blng__Account__c,blng__TaxAmount__c,MH_Adjustments_Previous_Month__c,blng__Subtotal__c,MH_Debits_Previous_Month__c, ';
            Invoice += ' blng__Account__r.BillingCity,blng__Account__r.BillingState,blng__Account__r.BillingPostalCode,blng__DueDate__c,MH_Payments_Previous_Month__c,blng__TotalAmount__c,MH_Credits_Previous_Month__c, ';
            Invoice += ' blng__Account__r.BillingCountry,blng__Account__r.Previous_Balance__c,blng__Account__r.BillingStreet, Legacy_M_H_Payments_Previous_Month__c, Legacy_M_H_Credits_Previous_Month__c, ';
            Invoice += ' blng__Account__r.Account_Number__c, blng__BillToContact__r.FirstName, blng__BillToContact__r.LastName, blng__Account__r.Account_Balance__c, blng__Account__r.MH_Cust_Number__c ';

            Invoice += ' FROM blng__Invoice__c WHERE ID=\''+sInvoiceID + '\'';
           
            oInvoice = Database.query(Invoice);
            paymentsboolean = false;
            
            system.debug('@@@@sInvoiceID' + sInvoiceID);
            adjustmentTotal = 0;
            paymentTotal = 0;
            if(sInvoiceID != null){
                Date invoiceDate = oInvoice.blng__InvoiceDate__c;
                Date firstDayOfMonth = invoiceDate.addMonths(-1).toStartOfMonth();
                Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
           
             system.debug('@@@in query'); 
                List<blng__Payment__c> allpaymentsList = new List<blng__Payment__c>();
                allpaymentsList = [select id, Name,createddate,
                                   blng__PaymentDate__c,
                                   blng__Amount__c, blng__Invoice__c,
                                   blng__PaymentType__c 
                                   from  blng__Payment__c
                                   where blng__Account__c =:oInvoice.blng__Account__c
                                   and blng__Status__c = 'Posted'
                                  
                                   and createddate >=: firstDayOfMonth
                                   and createddate <=: lastDayOfMonth
                                  ];
                payementsList = new List<blng__Payment__c>();
                CreditNoteList = new list<blng__CreditNote__c>();
                DebitNoteList = new list<blng__DebitNote__c>();
                for(blng__Payment__c invpay : allpaymentsList){
                    system.debug('@@@in payments');
                    
                        payementsList.add(invpay);
                        paymentTotal += invpay.blng__Amount__c;
                        paymentsboolean = true;
                                    }
                 for(blng__CreditNote__c cred:[select id,name, blng__Subtotal__c,blng__creditNoteDate__c from blng__CreditNote__c where blng__Account__c =:oInvoice.blng__Account__c  and blng__Status__c ='Posted' and blng__CreditNoteDate__c >=:firstDayOfMonth  and blng__CreditNoteDate__c <=:lastDayOfMonth]){
                      CreditNoteList.add(cred);             
           } system.debug('CreditNoteList'+CreditNoteList);
                for(blng__DebitNote__c deb:[select id,name, blng__Subtotal__c,blng__DebitNoteDate__c from blng__DebitNote__c where blng__Account__c =:oInvoice.blng__Account__c  and blng__Status__c ='Posted' and blng__DebitNoteDate__c >=:firstDayOfMonth and blng__DebitNoteDate__c <=:lastDayOfMonth]){
                      DebitNoteList.add(deb);     
                } system.debug('DebitNoteList'+DebitNoteList);
                
            }
            
            paymentMethodasDefault = new List<blng__PaymentMethod__c>();
            paymentMethodasDefault = [select id,Name,
                                      blng__Account__c 
                                      ,blng__AutoPay__c
                                      from blng__PaymentMethod__c
                                      where 
                                      blng__AutoPay__c = true and
                                       blng__Account__c =:oInvoice.blng__Account__c 
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
            blng__Invoice__c  Invoice = [SELECT Name,blng__InvoiceDate__c,Total_Amount_Due__c,
                                         //Arrears_Invoice__c , 
                                                blng__Account__r.Billing_Schedule__c,
                                                blng__Account__r.RecordTypeId
                                                
                                                from blng__Invoice__c WHERE ID=:sInvoiceID];
            if(Invoice.blng__InvoiceDate__c != null){
                if(Invoice.blng__Account__r.RecordTypeId == nolo_account_recttypeId
                   && Invoice.blng__Account__r.Billing_Schedule__c == 'Arrears'                  
                  ){
                       return  Invoice.blng__InvoiceDate__c.addMonths(-1).toStartOfMonth();
                   }
                else {
                    return Invoice.blng__InvoiceDate__c.toStartOfMonth(); 
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
            
            blng__Invoice__c  Invoice = [SELECT Name,blng__InvoiceDate__c,Total_Amount_Due__c,
                                         //Arrears_Invoice__c ,
                                                blng__Account__r.Billing_Schedule__c,
                                                blng__Account__r.RecordTypeId
                                                from blng__Invoice__c WHERE ID=:sInvoiceID];                
            if(Invoice.blng__InvoiceDate__c != null){
                if(Invoice.blng__Account__r.RecordTypeId == nolo_account_recttypeId 
                   && Invoice.blng__Account__r.Billing_Schedule__c == 'Arrears'
                   
                  ){
                       date startDate = Invoice.blng__InvoiceDate__c.addMonths(-1).toStartOfMonth();
                       Integer numberOfDays = Date.daysInMonth(startDate.year(), startDate.month());
                       return Date.newInstance(startDate.year(), startDate.month(), numberOfDays);
                   }
                else {
                    return Invoice.blng__InvoiceDate__c.toStartOfMonth().addMonths(1)-1;
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
            blng__Invoice__c  Invoice1 = [SELECT blng__InvoiceDate__c from blng__Invoice__c 
                                                 WHERE ID=:sInvoiceID]; 
            if(Invoice1 != null)
            {                                     
                if(Invoice1.blng__InvoiceDate__c != null)
                {
                    dStartDate = Invoice1.blng__InvoiceDate__c.toStartOfMonth();                        
                    dEndDate = Invoice1.blng__InvoiceDate__c.toStartOfMonth().addMonths(1)-1;
                }
                blng__Invoice__c  Invoice = [SELECT blng__Account__c
                                                    from blng__Invoice__c WHERE ID=:sInvoiceID];
                
                if(Invoice  != null)
                {
                    for(blng__Payment__c obj : [SELECT blng__Amount__c,Id,createddate,blng__Account__c from blng__Payment__c WHERE blng__Account__c=:Invoice.blng__Account__c AND
                                                       createddate >=: dStartDate AND createddate <=: dEndDate])
                        dTotal += obj.blng__Amount__c ;
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
            
            blng__Invoice__c  Invoice = [SELECT blng__Account__c
                                                from blng__Invoice__c WHERE ID=:sInvoiceID];
            
            if(Invoice  != null)
            {
                for(blng__Payment__c obj : [SELECT blng__Amount__c from blng__Payment__c WHERE blng__Account__c=:Invoice.blng__Account__c AND blng__PaymentType__c='Promotional Credit'])
                    dTotal += obj.blng__Amount__c ;
            }
            return dTotal.setScale(2) ;
        }
    }
    
    //forming map to show quantity added if existed
    public list<wrapProduct> invoiceLinesList {
        set; 
        
        get {
            Map<Id,List<blng__InvoiceLine__c>> mapInvoiceIdAndLstInvoiceLines = new Map<Id,List<blng__InvoiceLine__c>>();
            List<String> invoiceLinesListtemp  = new List<String>();
            listInvLI = new map<string,double>();
            set<string> invoiceListSet=new set<string>();
             wrapperProductlist= new list<wrapProduct>();
            for(blng__InvoiceLine__c invLines : [Select 
                                                 blng__Quantity__c, Name, blng__Invoice__c, Id , 
                                                          blng__Invoice__r.blng__BillToContact__r.FirstName,
                                                          blng__Invoice__r.blng__BillToContact__r.LastName, 
                                                          blng__Product__c, blng__Product__r.Name 
                                                          From blng__InvoiceLine__c  
                                                          where blng__Invoice__c =: sInvoiceID 
                                                          ORDER By blng__Product__r.Name ASC
                                                ]) {
                                                           if(!mapInvoiceIdAndLstInvoiceLines.containsKey(invLines.blng__Invoice__r.Id)) {
                                                                  mapInvoiceIdAndLstInvoiceLines.put(invLines.blng__Invoice__r.Id,new List<blng__InvoiceLine__c>{invLines});
                                                                  system.debug('@@@@ Mapped Inv Lines'+ mapInvoiceIdAndLstInvoiceLines);
                                                              }
                                                              else {
                                                                  mapInvoiceIdAndLstInvoiceLines.get(invLines.blng__Invoice__r.Id).add(invLines);
                                                                  system.debug('@@@@ Mapped Invoice Lines values '+ mapInvoiceIdAndLstInvoiceLines);
                                                              }
                                                          }
            
            system.debug('@@@@@@mapInvoiceIdAndLstInvoiceLines'+mapInvoiceIdAndLstInvoiceLines);
            Map<String,Double> mapInvLineNameNQty = new Map<String,Double>();
            Set<Id> setOrderRatePlanIds = new Set<Id>();
            if(mapInvoiceIdAndLstInvoiceLines.containsKey(sInvoiceID)) {
                for(blng__InvoiceLine__c invLines : mapInvoiceIdAndLstInvoiceLines.get(sInvoiceID)) {
                    if(mapInvLineNameNQty.containsKey(invLines.Name)) {
                            Double i = 0;
                                i = mapInvLineNameNQty.get(invLines.Name) + invLines.blng__Quantity__c;
                                mapInvLineNameNQty.put(invLines.Name,i);
                                                             
                        }
                        else {
                            mapInvLineNameNQty.put(invLines.Name,invLines.blng__Quantity__c);
                          
                    }        
                }
            } 
            
            
            invoiceListSet =  mapInvLineNameNQty.keyset() ;
            for(string inv:invoiceListSet){
              wrapperProductlist.add(new wrapProduct(inv,mapInvLineNameNQty.get(inv)));
            }
            //invoiceLinesListtemp.addAll(invoiceListSet);
           // return invoiceLinesListtemp;
            return wrapperProductlist ;
        }
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
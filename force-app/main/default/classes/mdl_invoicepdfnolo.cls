public class mdl_invoicepdfnolo {
     public static void getnoloinvoicefileds(list<invoiceit_s__Invoice__c> invlist){
        
        system.debug('@@@@in getnoloinvoicefileds');
        
        set<id> accountset = new set<id>();
        list<account> acclist = new list<account>();
        list<invoiceit_s__Payment__c> paymtList = new list<invoiceit_s__Payment__c>();
        list<account> acclist_mh = new list<account>(); 
        //double paymentspreviouMonth = 0;
        //double creditspreviousMonth = 0;
        map<id, double> accidVsNOLOPayments = new map<id, double>();
        map<id, double> accidVsNOLOBeforePayments = new map<id, double>();
        map<id, double> accidVsNOLOBeforecredits = new map<id, double>();
        map<id, double> accidVsNOLOBeforedebits = new map<id, double>();
        
        map<id, double> accidVsNOLOcredits = new map<id, double>();
         map<id, double> accidVsMHPayments = new map<id, double>();
        map<id, double> accidVsMHcreditsmap = new map<id, double>();  
        map<id,account> idvsacct          = new map<id,account>();
        map<string, double> accidVsmhcredits  = new map<string, double>();  
        map<id, double> accidVsPrevBalance_Mh = new map<id, double>(); 
        double mhcredit = 0;  
        
        Id noloinvpayRecId = Schema.SObjectType.invoiceit_s__Payment__c.RecordTypeInfosByName.get(RecordTypesFinalStringsClass.RecTypeName_MH_Payments).RecordTypeId;
         Id noloinvRecId = Schema.SObjectType.invoiceit_s__Invoice__c.RecordTypeInfosByName.get(RecordTypesFinalStringsClass.RecTypeName_MH_Invoice).RecordTypeId;
         Id MHinvpayRecId = Schema.SObjectType.invoiceit_s__Payment__c.RecordTypeInfosByName.get(RecordTypesFinalStringsClass.RecTypeName_JV_Payments).RecordTypeId;
         
         
        system.debug('@@@@noloinvRecId' + noloinvpayRecId);
        
        for(invoiceit_s__Invoice__c singleinv : invlist){
            accountset.add(singleinv.invoiceit_s__Account__c);
        }
        system.debug('@@@@accountset' + accountset);
        
        Date invoiceDate = invlist[0].invoiceit_s__Invoice_Date__c;
        Date firstDayOfMonth = invoiceDate.addMonths(-1).toStartOfMonth();
        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
        
        system.debug('@@@invoiceDate'+ invoiceDate);
        system.debug('@@@firstDayOfMonth'+ firstDayOfMonth);
        system.debug('@@@lastDayOfMonth'+ lastDayOfMonth);
        
         //List<aggregateResult> results = [select sum(invoiceit_s__Amount__c) creditamount, invoiceit_s__Account__c 
         //                                   from invoiceit_s__Payment__c 
         //                                     where RecordTypeId =: MHinvpayRecId 
         //                                                 group by invoiceit_s__Account__c ];
        // for (AggregateResult ar : results){
        //     accidVsmhcredits.put(string.valueof(ar.get('invoiceit_s__Account__c')), double.valueof(ar.get('creditamount')));
        // } 
            
        //system.debug('@@@@@accidVsmhcredits' + accidVsmhcredits);         
         
        
        if(accountset != null && !accountset.isEmpty()){
            acclist = [select id, Name,
                           NOLO_Total_Payments__c,All_NOLO_Payments__c,All_NOLO_Credits__c,MH_Total_Payments__c,
                           NOLO_Posted_Invoices__c, Posted_Invoices__c,
                          (select id, Name,
                            invoiceit_s__Amount__c,
                             invoiceit_s__Payment_Type__c,RecordTypeId,Applied_Type__c,
                             Date_Based_on_Type__c
                             from invoiceit_s__Payments__r
                             where invoiceit_s__Status__c = 'Completed')
                           FROM account 
                           where id IN:(accountset)];
                                  //and Date_Based_on_Type__c IN (LAST_MONTH))
                                  //and Date_Based_on_Type__c <: firstDayOfMonth)
                                  //and Date_Based_on_Type__c <=: lastDayOfMonth)
                          
            system.debug('@@@@acclist' + acclist);
            

            for(account acc: acclist){
                
                 double payment_MH      = 0;
                 double credit_MH       = 0;
                 double payment_Nolo    = 0;
                 double credit_Nolo     = 0;
                
                double combined_payment = 0;
                double combined_credits = 0;
                double combined_debits = 0;
                double combined_payment_last_month = 0;
                double combined_credits_last_month = 0;
                    
                if(acc.invoiceit_s__Payments__r !=null){
                   
                    for(invoiceit_s__Payment__c singpayment : acc.invoiceit_s__Payments__r){
                        
                        //calculatin payment and credits for NOLO
                           system.debug('@@singpayment'+ singpayment);
                        
                       /* if(singpayment.RecordTypeId == MHinvpayRecId ){
                            if(singpayment.invoiceit_s__Payment_Type__c != 'Adjustment'){
                                payment_MH += singpayment.invoiceit_s__Amount__c;
                            }
                            else{
                                credit_MH += singpayment.invoiceit_s__Amount__c;
                            }
                        }
                        
                        else{
                            if(singpayment.invoiceit_s__Payment_Type__c != 'Adjustment'){
                                payment_Nolo += singpayment.invoiceit_s__Amount__c;
                            }
                            else{
                                credit_Nolo += singpayment.invoiceit_s__Amount__c;
                            }
                            
                        }*/
                        if(singpayment.Date_Based_on_Type__c < firstDayOfMonth){
                        
                        	if(singpayment.invoiceit_s__Payment_Type__c != 'Adjustment'){
                                combined_payment += singpayment.invoiceit_s__Amount__c;
                        	}else{
                                combined_credits += singpayment.invoiceit_s__Amount__c;
                        	}
                        }
                    	
                        if(singpayment.Date_Based_on_Type__c >= firstDayOfMonth && singpayment.Date_Based_on_Type__c <= lastDayOfMonth){
                        	if(singpayment.invoiceit_s__Payment_Type__c != 'Adjustment'){
                                combined_payment_last_month += singpayment.invoiceit_s__Amount__c;
                                if(singpayment.RecordTypeId == MHinvpayRecId){
                                     payment_MH += singpayment.invoiceit_s__Amount__c;
                                }
                        	} else{
                                combined_credits_last_month += singpayment.invoiceit_s__Amount__c;
                                if(singpayment.RecordTypeId == MHinvpayRecId){
                                     credit_MH += singpayment.invoiceit_s__Amount__c;
                                }
                        	}
                    
                        }
                    }
                  
                }
                
                idvsacct.put(acc.id, acc);
                accidVsNOLOPayments.put(acc.id, combined_payment_last_month);
                accidVsNOLOcredits.put(acc.id, combined_credits_last_month);
                accidVsMHPayments.put(acc.id, payment_MH);
                accidVsMHcreditsmap.put(acc.id, credit_MH);
                
                accidVsNOLOBeforePayments.put(acc.id, combined_payment);
                accidVsNOLOBeforecredits.put(acc.id, combined_credits);
               
                
                
            }
        }
        
       //calculating Previous Balance for MH invoices by using InvoiceCSVBatch Class Reference
          
         accidVsPrevBalance_Mh = getaccidVSprevBalance_MhMap(accountset, invoiceDate);
         
         
         
        system.debug('@@@@accidVsNOLOPayments' + accidVsNOLOPayments);
        system.debug('@@@@accidVsNOLOcredits' + accidVsNOLOcredits);
        system.debug('@@@@accidVsMHPayments' + accidVsMHPayments);
        system.debug('@@@@accidVsMHcreditsmap' + accidVsMHcreditsmap);
        //system.debug('@@@@@ paymentspreviouMonth' + paymentspreviouMonth);
        //system.debug('@@@@@ creditspreviousMonth' + creditspreviousMonth);
        
        for(invoiceit_s__Invoice__c singleinv : invlist){
            if(!singleinv.Prev_Balance_Check__c){
                    
                    Double beforePayments = 0;
                    Double beforeCredits = 0;
                    
                    if(accidVsNOLOPayments.containsKey(singleinv.invoiceit_s__Account__c)){
                        
                            singleinv.NOLO_Payments_Previous_Month__c = accidVsNOLOPayments.get(singleinv.invoiceit_s__Account__c);
                    } 
                
                    if(accidVsMHPayments.containsKey(singleinv.invoiceit_s__Account__c)){
                            singleinv.MH_Payments_Previous_Month__c = accidVsMHPayments.get(singleinv.invoiceit_s__Account__c);
                            
                     }
                    
                    if(accidVsNOLOBeforePayments.containsKey(singleinv.invoiceit_s__Account__c)){
                        
                            beforePayments = accidVsNOLOBeforePayments.get(singleinv.invoiceit_s__Account__c);
                    }                   
                
                    if(accidVsNOLOBeforecredits.containsKey(singleinv.invoiceit_s__Account__c)){
                        
                            beforeCredits = accidVsNOLOBeforecredits.get(singleinv.invoiceit_s__Account__c);
                    }
                	
                    if(accidVsNOLOcredits.containsKey(singleinv.invoiceit_s__Account__c)){
                        
                        
                            singleinv.NOLO_Credits_Previous_Month__c = accidVsNOLOcredits.get(singleinv.invoiceit_s__Account__c);
                    } 
                
                    if(accidVsMHcreditsmap.containsKey(singleinv.invoiceit_s__Account__c)){
                            singleinv.MH_Credits_Previous_Month__c = accidVsMHcreditsmap.get(singleinv.invoiceit_s__Account__c);
                            
                     }
                        
                    System.debug('=======================singleinv.NOLO_Payments_Previous_Month__c'+singleinv.NOLO_Payments_Previous_Month__c);  
                    System.debug('=======================singleinv.NOLO_Credits_Previous_Month__c'+singleinv.NOLO_Credits_Previous_Month__c);     
                
                    system.debug('@@@@singleinv.invoiceit_s__Account__r.NOLO_Posted_Invoices__c' + singleinv.invoiceit_s__Account__r.NOLO_Posted_Invoices__c);
                    system.debug('@@@@singleinv.invoiceit_s__Account__r.NOLO_Total_Payments__c ' + singleinv.invoiceit_s__Account__r.NOLO_Total_Payments__c );
                    system.debug('@@@@singleinv.invoiceit_s__Account__r.All_NOLO_Credits__c ' + singleinv.invoiceit_s__Account__r.All_NOLO_Credits__c );
                    
                    double allNoloPayments = idvsacct.get(singleinv.invoiceit_s__Account__c).All_NOLO_Payments__c;
                    double allMHPayments = idvsacct.get(singleinv.invoiceit_s__Account__c).MH_Total_Payments__c;
                    double allNoloCredit = idvsacct.get(singleinv.invoiceit_s__Account__c).All_NOLO_Credits__c;
                    //double allMHCredit = accidVsmhcredits.containsKey(singleinv.invoiceit_s__Account__c)?
                      //                           accidVsmhcredits.get(singleinv.invoiceit_s__Account__c): 0;
                    //double allMHCredit = idvsacct.get(singleinv.invoiceit_s__Account__c).All_J_V_Credits__c;      
                
                    double NoloPostedInvoices = idvsacct.get(singleinv.invoiceit_s__Account__c).NOLO_Posted_Invoices__c;
                    double MHPostedInvoices = idvsacct.get(singleinv.invoiceit_s__Account__c).Posted_Invoices__c;
                    
                    system.debug('@@@allNoloPayments'+allNoloPayments);
                    system.debug('@@@allNoloPayments'+allNoloCredit);
                    system.debug('@@@allNoloPayments'+NoloPostedInvoices);
                    system.debug('@@@allMHPayments'+allMHPayments);
                    //system.debug('@@@allMHCredit'+allMHCredit);
                    system.debug('@@@MHPostedInvoices'+MHPostedInvoices);
                    system.debug('@@@singleinv.RecordTypeId'+ singleinv.RecordTypeId);
                    system.debug('@@@noloinvRecId'+noloinvRecId);
                    system.debug('@@@DeveloperName'+singleinv.RecordType.DeveloperName);
                	
                	system.debug('@@@beforePayments'+beforePayments);
                	system.debug('@@@beforeCredits'+beforeCredits);
                
                
                    
                    if(singleinv.RecordTypeId == noloinvRecId){
                    
                        
                    System.debug('=============accidVsPrevBalance_Mh.get(singleinv.invoiceit_s__Account__c)'+accidVsPrevBalance_Mh.get(singleinv.invoiceit_s__Account__c));
                         
                    singleinv.Previous_Balance__c = NoloPostedInvoices + MHPostedInvoices - 
                                                          beforePayments -
                                                           beforeCredits ;
                            
                        
                        
                        if(trigger.isUpdate){
                            singleinv.Prev_Balance_Check__c = true;
                        }
                        
                        system.debug('@@@@in inv nolo');
                    }
                    else{
                        //singleinv.Previous_Balance__c = MHPostedInvoices - 
                        //                               allMHPayments -
                        //                                 allMHCredit +
                        //                                  singleinv.MH_Payments_Previous_Month__c +
                        //                                   singleinv.MH_Credits_Previous_Month__c;
                        
                        singleinv.Previous_Balance__c  = (accidVsPrevBalance_Mh.containsKey(singleinv.invoiceit_s__Account__c))?
                                                                 accidVsPrevBalance_Mh.get(singleinv.invoiceit_s__Account__c): 0;
                        if(trigger.isUpdate){
                            singleinv.Prev_Balance_Check__c = true;
                        }
                    }
                    
                    
                   
                    
                    //singleinv.Payments_Previous_Month__c = paymentspreviouMonth;
                    //singleinv.Credit_Previous_Month__c = creditspreviousMonth;
                    
                    system.debug('@@@@singleinv' + singleinv);
                    
                }
            }
            
    }

   
    public static map<id, double> getaccidVSprevBalance_MhMap( set<id> accids, date StartDate){
        
        system.debug('@@@@ in getaccidVSprevBalance_MhMap ');
        map<id, double> accidVSprevBalance_MhMap = new map<id, double>();
        list<account> acclist_MH = new list<account>();
        Date paymentStartDate = startDate.addMonths(-1);
        acclist_MH = [select id, Name , RecordType.DeveloperName,
                              MH_Total_Payments__c, Posted_Invoices__c,
                              (select id, Name , invoiceit_s__Invoice_Status__c,
                                invoiceit_s__Account__c, invoiceit_s__Total_Invoice_Value__c,
                                 invoiceit_s__Invoice_Date__c
                                  from invoiceit_s__Invoices__r
                                   where invoiceit_s__Invoice_Status__c != 'Cancelled'
                                       and invoiceit_s__Invoice_Date__c >= :startDate
                                       and RecordType.DeveloperName = 'MH_Invoices'),
                               (Select Id,Name, invoiceit_s__Payment_Date__c, 
                                 invoiceit_s__Account__c, RecordType.DeveloperName ,
                                  invoiceit_s__Payment_Type__c, Applied_Type__c,
                                   invoiceit_s__Amount__c, CreatedDate
                                    from invoiceit_s__Payments__r
                                     where ((invoiceit_s__Payment_Date__c >=:paymentStartDate and invoiceit_s__Payment_Type__c = 'Adjustment') 
                                              OR (invoiceit_s__Payment_Type__c != 'Adjustment' and CreatedDate >=:paymentStartDate)) 
                                              and (invoiceit_s__Amount__c!=0.0) and (invoiceit_s__Status__c = 'Completed') 
                                               and RecordType.DeveloperName = 'MH_Payments')
                                   from account where id IN:(accids)];
        
         Decimal payAmt = 0.00;
         Decimal invAmt = 0.00;
        Decimal pastInvAmt = 0.00;
        Decimal pastPayAmt = 0.00;
        Decimal prevBalance = 0.00;
        for(account acc: acclist_MH){
            
            for(invoiceit_s__Payment__c pay : acc.invoiceit_s__Payments__r) {
                   
                    payAmt += pay.invoiceit_s__Amount__c;
            }  
            for(invoiceit_s__Invoice__c inv : acc.invoiceit_s__Invoices__r) {
                    if(inv.invoiceit_s__Invoice_Status__c == 'Posted') {
                        invAmt += inv.invoiceit_s__Total_Invoice_Value__c;
                    }
             }
            System.debug('==========Posted Invoices'+acc.Posted_Invoices__c);
            System.debug('===========Inv Amt'+invAmt);
            System.debug('===========pastInvAmt '+pastInvAmt );
            System.debug('===========acc.MH_Total_Payments__c'+acc.MH_Total_Payments__c);
            System.debug('===========payAmt'+payAmt);
            System.debug('=============prevBalance '+prevBalance);
            System.debug('@@@@@@@@@@@@accidVSprevBalance_MhMap'+accidVSprevBalance_MhMap);
            pastInvAmt = acc.Posted_Invoices__c - invAmt;
            pastPayAmt = acc.MH_Total_Payments__c - payAmt;
            prevBalance = pastInvAmt - pastPayAmt;
            accidVSprevBalance_MhMap.put(acc.Id,prevBalance);
        }
        
        
        
        
        return accidVSprevBalance_MhMap;
        
        
        
        
        
        
        
    
    }
    
    
}
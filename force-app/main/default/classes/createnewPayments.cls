// Author      : Akash
// Description : Moving Talend job total functionality here
// database.executeBatch(new createnewPayments(Recordtype DeveloperName), batchSize)
global class createnewPayments implements Database.Batchable<sObject>, Database.Stateful{

  global Map<String,string> globalMap;
  global String ll; 
  global string sequence;
  global String Recordtype_Name;
  //global date startDateq;
  //global date endDateq;  
    
    global createnewPayments(String RecordTypeName){
        globalMap = new Map<String,string>();
        ll ='';
        globalMap.put('header', 'true');
        globalMap.put('footer', 'true');
        globalMap.put('body', '');
        globalMap.put('sequence', '0000001');
        sequence              = globalMap.get('sequence');
        this.Recordtype_Name = RecordTypeName;
        //this.startDateq      = startDate;
        //this.endDateq        = endDate;
    } 
  
   global Database.QueryLocator start(Database.BatchableContext BC){
       
       //system.debug('@@@@startDateq'+startDateq);
       //system.debug('@@@@endDateq'+endDateq);
       system.debug('@@@@Recordtype_Name'+Recordtype_Name);
       String query = 'Select id, Name, invoiceit_s__Account__c, '+
                             ' invoiceit_s__Unpaid_Amount__c '  +
                             'From invoiceit_s__Invoice__c '+
                             'Where invoiceit_s__Unpaid_Amount__c > 0 '+
                               ' And invoiceit_s__Invoice_Status__c = \'Posted\''+ 
                                ' And RecordType.DeveloperName =:Recordtype_Name';//+
                               // ' And Id= \'a0C0U000000El10\''+
                               //   ' LIMIT 250';
                                //' And invoiceit_s__Invoice_Date__c >=:startDateq AND  invoiceit_s__Invoice_Date__c <=:endDateq'
      
       If(test.isRunningTest()){
           query += ' order by CreatedDate desc LIMIT 10';
       }                        
                         
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<invoiceit_s__Invoice__c> invoiceList){
       system.debug('@@@@@@in createnewPayments' + invoiceList);
       Set<String> accids                         = new Set<String>();
       List<account> acclist                      = new List<account>();
       List<invoiceit_s__Payment__c> paymentsList = new List<invoiceit_s__Payment__c>();
       invoiceit_s__Payment__c payment;
       Map<id,List<invoiceit_s__Invoice__c>> accidVsinvoiceList = new Map<id,List<invoiceit_s__Invoice__c>>();
       
       Id currencyId = [select id from invoiceit_s__Currency__c 
                                  where Name='USD' LIMIT 1].id;
       
       system.debug('@@@invoiceList'+invoiceList);
       for(invoiceit_s__Invoice__c invoice : invoiceList){
           if(accidVsinvoiceList.containsKey(invoice.invoiceit_s__Account__c)){
               accidVsinvoiceList.get(invoice.invoiceit_s__Account__c).add(invoice);
           }
           else{
               accidVsinvoiceList.put(invoice.invoiceit_s__Account__c,new List<invoiceit_s__Invoice__c>{invoice});
           }
           
           
       }
       system.debug('@@@accidVsinvoiceList'+accidVsinvoiceList);
       
       if(!accidVsinvoiceList.isEmpty()){
           for(account acc : [select id,MH_Cust_Number__c,
                             (select id,Name,invoiceit_s__Bank_Routing_Code__c,invoiceit_s__Bank_Account_Number__c
                                     From invoiceit_s__Payment_Methods__r
                                      where invoiceit_s__Active__c = true and 
                                            invoiceit_s__Payment_Method__c = 'ACH' and invoiceit_s__Default__c = true)
                              From account
                              where id IN: accidVsinvoiceList.keySet()]){
                system.debug('@@@@in if and for accidVsinvoiceList'+ acc);                  
                if(acc.invoiceit_s__Payment_Methods__r.size() > 0){
                     system.debug('@@@@in if payment method'+ acc.invoiceit_s__Payment_Methods__r[0]);
                     
                     id mhPaymentrecordTypeId = Schema.SObjectType.invoiceit_s__Payment__c.RecordTypeInfosByName.get('M-H Payments').RecordTypeId;
                     
                     for(invoiceit_s__Invoice__c inv : accidVsinvoiceList.get(acc.id)){
                        payment                               = new invoiceit_s__Payment__c();
                        payment.invoiceit_s__Currency__c      =  currencyId; 
                        payment.Invoice__c                    =  inv.id;
                        payment.invoiceit_s__Account__c       =  acc.id;
                        payment.invoiceit_s__Payment_Date__c  =  date.today();
                        payment.invoiceit_s__Payment_Type__c  = 'ACH';
                        payment.invoiceit_s__Amount__c        = inv.invoiceit_s__Unpaid_Amount__c;
                        payment.invoiceit_s__Status__c        = 'Completed';
                        payment.RecordTypeID                    = mhPaymentrecordTypeId ; 
                        
                        paymentsList.add(payment); 
                         
                        //forming global map one element
                         if(globalMap.containsKey(inv.invoiceit_s__Account__c)){
                             Double due = Double.valueOf(globalMap.get(inv.invoiceit_s__Account__c));
                             due       += inv.invoiceit_s__Unpaid_Amount__c;
                             due        = Math.round(due * 100.0) / 100.0;
                             globalMap.put(inv.invoiceit_s__Account__c , string.valueOf(due));
        
                         }
                         else{
                             globalMap.put(inv.invoiceit_s__Account__c , string.valueOf(Math.round(inv.invoiceit_s__Unpaid_Amount__c * 100.0) / 100.0));
                             
                         }
                         
                         String unpaidAmt = '';
                        if(inv.invoiceit_s__Unpaid_Amount__c != null)
                            unpaidAmt = inv.invoiceit_s__Unpaid_Amount__c + '';
                         
                        if(!globalMap.containsKey('totalUnpaidAmount')){
                            globalMap.put('totalUnpaidAmount' , string.valueOf(inv.invoiceit_s__Unpaid_Amount__c));     
                        }
                        else{
                            Double temp = Double.valueOf(globalMap.get('totalUnpaidAmount'));
                            temp        += inv.invoiceit_s__Unpaid_Amount__c;
                            globalMap.put('totalUnpaidAmount' , string.valueOf(temp));      
                        }
                         
                        system.debug('@@@@global map at totalUnpaidAmount'+globalMap); 
                       if((unpaidAmt.length() - unpaidAmt.indexOf('.')) == 2){
                            unpaidAmt += '0';
                        }
                        if(unpaidAmt.contains('.')){
                            unpaidAmt = unpaidAmt.replace('.','');
                        }
                         
                        Integer totalLength2 = unpaidAmt.length();
    
                        
                    for(Integer i = totalLength2; i < 10 ; i++){
                        String temp = unpaidAmt;
                        unpaidAmt = '0'+ temp; 
                    }
                         
                    String pay_routing_withzero = '';
                    if(acc.invoiceit_s__Payment_Methods__r[0].invoiceit_s__Bank_Routing_Code__c != null)
                        pay_routing_withzero = acc.invoiceit_s__Payment_Methods__r[0].invoiceit_s__Bank_Routing_Code__c + '';
    
                    String bankAccNo = '';
                    if(acc.invoiceit_s__Payment_Methods__r[0].invoiceit_s__Bank_Account_Number__c != null)
                        bankAccNo = acc.invoiceit_s__Payment_Methods__r[0].invoiceit_s__Bank_Account_Number__c + '';   
                    
                    Integer AccLength = bankAccNo.length();
    
                    for(Integer i = AccLength; i<17 ; i++){     
                            bankAccNo += ' ';
                    }
                    if(acc.invoiceit_s__Payment_Methods__r[0].invoiceit_s__Bank_Routing_Code__c != null){
                        if(!globalMap.containsKey('TransitRouting')){
                            globalMap.put('TransitRouting' , string.valueOf(Long.valueOf(acc.invoiceit_s__Payment_Methods__r[0].invoiceit_s__Bank_Routing_Code__c)));
                        }
                        else{
                            Long transit = Long.valueOf(globalMap.get('TransitRouting'));
                            transit += Long.valueOf(acc.invoiceit_s__Payment_Methods__r[0].invoiceit_s__Bank_Routing_Code__c);
                            globalMap.put('TransitRouting' , string.valueOf(transit));
                        }
                    }   
                    ll += '627' + pay_routing_withzero;
                    ll += bankAccNo;
                    ll += unpaidAmt + '               ' + acc.MH_Cust_Number__c + '              ' ;
                    ll += '0' + '11100002' + sequence;  
                    ll += '\r\n';     
                    Integer seq = Integer.valueOf(sequence);
                    seq += 1;
    
                    sequence = string.valueOf(seq) + '';
                    for(Integer x = sequence.length(); x<7 ; x++){
                        String temp = sequence;
                        sequence = '0' + temp;
                    }     
                         
                 }                     
                }                 
                            
            }
       }
       
       try{
           system.debug('@@@@paymentsList'+paymentsList);
           Database.SaveResult[] srList = database.insert(paymentsList, false);
           // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }
       }
       catch(Exception e){
           system.debug('@@@Exception'+ e);
       }
    }

   global void finish(Database.BatchableContext BC){
       
        system.debug('@@@@@globalmap'+ globalMap);
       Payment_Bank_Details__c backDetails;
       System.debug('@@@@@Record TYpe'+Recordtype_Name);
       if(Recordtype_Name == 'Nolo_Invoice'){
           backDetails = Payment_Bank_Details__c.getValues('NOLO Details');
       }
       else{
           backDetails = Payment_Bank_Details__c.getValues('MDL Details');
       }
       System.debug('@@@backDetails'+backDetails );
       
        String l            = '';
        /*String bank_routing = '011900254';
        String company_id   = '2942759757';
        String dfi_dallas   = '11100002';*/
        String bank_routing = '011900254'; //backDetails.Bank_Routing__c; //
        String company_id   = '5942759757'; //backDetails.Company_Id__c; //
        String dfi_dallas   = '11100002'; // backDetails.dfi_dallas__c; //  
        String header       = globalMap.get('header') + '';
        String footer       = globalMap.get('footer') + '';
        String body         = globalMap.get('body') + '';
        //String sequence     = globalMap.get('sequence') + '';
       
        DateTime now        = dateTime.now();
       
        String YY = now.year() + '';
        YY  = YY.substring(2,4);
        integer mon   = now.month(); 
        String MM = mon + '' ;
        if(MM.length() < 2)
        {
            String temp = MM;
            MM = '0' + temp;        
        }
       String DD = now.day() + '';              
       if(DD.length() < 2){
            String temp = DD;
            DD = '0' + temp;        
        }
       
       String HH = now.hour() + '';     
       if(HH.length() < 2){
            String temp = HH;
            HH = '0' + temp;        
       }
       
       String Min = now.minute()+ '';
      if(Min.length() < 2){
            String temp = Min;
            Min = '0' + temp;       
      }
      l = '101' + ' ' + bank_routing + company_id + YY + MM + DD + HH + Min;
      l += '1094101BANK OF AMERICA        MARTINDALE HUBBELL             ';     
      l += '\r\n'; 
                                
      l += '5200MARTINDALE HUBBELL  ';
      l +='                ' + company_id;       
      l +='PPDMARTINDALE'+ MM +DD +YY + YY + MM + DD + '   ' + '1' + dfi_dallas + '0000001'; 
      l +='\r\n'; 
       
      body = body + l + ll;
      globalMap.put('body', body);
      globalMap.put('sequence', sequence); 
       
      //need check on this one: akash 
      String totalDebits = globalMap.get('totalUnpaidAmount') !=null?globalMap.get('totalUnpaidAmount'):'0' + '';
       system.debug('@@@@@totalDebits'+totalDebits);
       if((totalDebits.length() - totalDebits.indexOf('.')) == 2){
            totalDebits += '0';
       }
        Double totDebits = Double.valueOf(totalDebits);
        totDebits        = Math.round(totDebits * 100.0) / 100.0;
        totalDebits      = string.valueOf(totDebits);
        if((totalDebits.length() - totalDebits.indexOf('.')) == 2){
            totalDebits += '0';
        }
       System.debug('@@@@@@typecasted value of totalDebits is ::'+totDebits+'%%%'+totalDebits);
       
        //need check on this one: akash
        String totalTransit = globalMap.get('TransitRouting')!=null?globalMap.get('TransitRouting'):'0' + '';
        Integer index = totalTransit.length();
         System.debug('@@@@@index'+index);
       if(index > 10){  
            totalTransit = totalTransit.substring(index - 10);
            System.debug('@@@@@totalTransitSubString'+totalTransit);
        }
        else{
            for(Integer i = index; i < 10; i++){
                String temp = totalTransit;
                totalTransit = '0' + temp;
            }
        }    
        if(totalDebits.contains('.')){
            totalDebits = totalDebits.replace('.','');
        }
            
        for(Integer i = totalDebits.length(); i<12 ; i++){
            String temp = totalDebits;
            totalDebits = '0' + temp; 
        }
            
        String data = globalMap.get('body') + '' ;
        String seq = globalMap.get('sequence') + '';
        Integer s = Integer.valueOf(seq);
        s -= 1;
        seq = s + '';
        String seq_sixDigit = s + '';
        String seq_sevenDigit = s + '';    
        for(Integer i = seq.length(); i<6 ; i++){
            String temp = seq_sixDigit;
            seq_sixDigit = '0' + temp; 
        }
        for(Integer i = seq.length(); i<7 ; i++){
            String temp = seq_sevenDigit;
            seq_sevenDigit = '0' + temp; 
        }
        for(Integer i = seq.length(); i<8 ; i++){
            String temp = seq;
            seq = '0' + temp; 
        }    
        
       
        data += '8200'+ seq_sixDigit + totalTransit;
        data += totalDebits;
        data += '000000000000'; //total credit
        data += company_id + '                         ';
        data += dfi_dallas + seq_sevenDigit;
        data += '\r\n'; 

    
        data += '9' + '000001' + '000001' + seq;
        data += totalTransit;
        data += totalDebits;
        data += '000000000000'; //Total Credit
        data += '                                       '; //39 blanks  
        data += '\r\n';    
         
       System.debug('@@@@Total Transit value is::'+totalTransit);
       System.debug('@@@@Total Debit value is::'+totalDebits);
        for(Integer i = 0; i < 4; i++){
            data += '9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999';
            data += '\r\n';
        }

       //creating document here
       Document d       = new Document(); 
       d.Name           = 'MDL Bank File '+system.now(); 
       String myContent = data; 
       d.Body           = Blob.valueOf(myContent); 
       d.ContentType    = 'text/plain';
       d.FolderId       = [select id,Name from Folder where Name='MDL ACH Bank Files'].id;
       d.Type           = 'txt';
       insert d;
       system.debug('@@@@Final Data'+data);
       
       
         
   }
}
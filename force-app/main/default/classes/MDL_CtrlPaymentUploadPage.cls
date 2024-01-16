/*
**Created By : Lister Technologies
**Purpose : To Upload Payment File and Insert them into Upload Payment Object
**Created Date : 27/05/14
**Test Class :  
**
** Modified by : Lister Technologies
** Purpose : RBW-1023
** Modified Date : 25/03/2015
*/
public with sharing class MDL_CtrlPaymentUploadPage {
    public Transient Blob contentFile{get;set;}
    public string nameFile{get;set;}
    public boolean showNextButton{get;set;}
    public List<invoiceit_s__Payment__c> paymentToUpload;
    public Map<String,String> mapAccountID;
    public Map<String,String> mapInvoiceID;
    public Map<String,String> mapPayment;
    public Map<String,String> mapInvoiceAmount;
    public List<String> accountListFromCSV;
    public List<String> invoiceListFromCSV;
    public Map<String,Id> mapInvoiceNameToAccountId;
    public String FileSource {get;set;} 
    public List<Selectoption> AvailableFileSources {get;set;}     
    public MDL_CtrlPaymentUploadPage() {
        AvailableFileSources = new List<SelectOption>();
        AvailableFileSources.add(new Selectoption('Bank Of America' , 'Bank Of America')); 
        AvailableFileSources.add(new Selectoption('CitiBank' , 'CitiBank')); 
        FileSource = 'Bank Of America';
        contentFile = null;
        nameFile = '';
        showNextButton = false;
        paymentToUpload = new List<invoiceit_s__Payment__c>();
        mapInvoiceNameToAccountId = new Map<String,Id>();       
        mapAccountID= new Map<String,String>();
        mapInvoiceID = new Map<String,String>();
        mapPayment = new Map<String,String>();
        mapInvoiceAmount = new Map<String,String>();
        accountListFromCSV = new List<String>();
        invoiceListFromCSV = new List<String>();
    }
    public Pagereference insertFile() {
        try{
            system.debug('File source --- > ' + FileSource) ;
            list<list<string>> parsedCSV;
            if(contentFile==null){
                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Please upload a file and then save...!');
                    ApexPages.addMessage(errormsg);
            }
            else if(FileSource == 'Bank Of America'){
                String fileString = contentFile.toString();
                system.debug('file type -- > ' + fileString);
                parsedCSV = parseCSV(fileString,true);
                system.debug(' 1st column of uploaded file is::: '  + parsedCSV[0]); 
                for (List<String> inputvalues : parsedCSV){
                    accountListFromCSV.add(inputvalues[1].replaceAll('"',''));                
                    system.debug('list of values -- > ' + inputvalues);
                    invoiceListFromCSV.add(inputValues[6].replaceAll('"',''));
                    
                }
                for(invoiceit_s__Invoice__c inv : [select Name,invoiceit_s__Total_Invoice_Value__c,invoiceit_s__Account__c, invoiceit_s__Invoice_Reference__c 
                                                    from invoiceit_s__Invoice__c where Name in :invoiceListFromCSV and RecordType.DeveloperName = 'MH_Invoices']) {
                    mapInvoiceAmount.put(inv.Name,inv.Id);
                    if(inv.invoiceit_s__Account__c != null)
                        mapInvoiceNameToAccountId.put(inv.Name,inv.invoiceit_s__Account__c);
                }
                //accountListFromCSV.add('50000122000');
                System.debug('Acc List From CSV '+accountListFromCSV);
                System.debug('Invoice List from CSV $$$'+invoiceListFromCSV);               
            }
            else {
                String fileString = contentFile.toString();
                system.debug('file type -- > ' + fileString);
                parsedCSV = parseCSV(fileString,true);
                system.debug(' 1st column of uploaded file is::: '  + parsedCSV[0]); 
                for (List<String> inputvalues : parsedCSV){
                    accountListFromCSV.add(inputvalues[0].replaceAll('"',''));
                    if(inputvalues.size() >= 8){
                        system.debug('list of values -- > ' + inputvalues);
                        invoiceListFromCSV.add(inputValues[7].replaceAll('"',''));
                    }   
                }
                for(invoiceit_s__Invoice__c inv : [select Name,invoiceit_s__Total_Invoice_Value__c,invoiceit_s__Account__c, invoiceit_s__Invoice_Reference__c 
                                                    from invoiceit_s__Invoice__c where invoiceit_s__Invoice_Reference__c in :invoiceListFromCSV and RecordType.DeveloperName = 'MH_Invoices']) {
                    mapInvoiceAmount.put(inv.invoiceit_s__Invoice_Reference__c,inv.Id);
                    if(inv.invoiceit_s__Account__c != null)
                        mapInvoiceNameToAccountId.put(inv.invoiceit_s__Invoice_Reference__c,inv.invoiceit_s__Account__c);
                }
                //accountListFromCSV.add('50000122000');
                System.debug('Acc List From CSV '+accountListFromCSV);
                System.debug('Invoice List from CSV $$$'+invoiceListFromCSV);            
            }
            
            for(Account acc: [Select Id,Name,MH_Cust_Number__c from Account where MH_Cust_Number__c in : accountListFromCSV and RecordType.DeveloperName = 'MH_Accounts']) {
                    mapAccountID.put(acc.MH_Cust_Number__c,acc.id);
            }
            
            insertDataIntoPayment(parsedCSV);  
            return null;
        }catch(Exception ex) {
            System.debug('exception::'+ex.getMessage());
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage() + '. An error has occured. Please check the file format before uploading them ');
            ApexPages.addMessage(errormsg);
            return null;
        }        
    }
    public static List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
        List<List<String>> allFields = new List<List<String>>();
    
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        system.debug('contents1 --> ' + contents);
        contents = contents.replaceAll('""','DBLQT');
        system.debug('contents2 --> ' + contents);
        List<String> lines = new List<String>();
        try {
           
            lines = contents.split('\r'); 
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        system.debug('contents3 --> ' + lines);
        Integer num = 0;
        for(String line: lines) {
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');  
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field: fields) {
                field = field.replace('\n','');
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }
            
            allFields.add(cleanFields);
        }
        if (skipHeaders) allFields.remove(0);
         return allFields; 
    }
    public void insertDataIntoPayment(list<list<string>> parsedCSV) {
            invoiceit_s__Payment__c payment;
            Date myDate,myDate1;
            String dateMonth,dateDay,dateYear,dateMonth1,dateDay1,dateYear1;
            List<String> dateTemp=null;
            List<String> dateTemp1 = null;//for Bank Deposit Date
            
            system.debug('File source --- > ' + FileSource) ;
            
            
            invoiceit_s__Currency__c cur = new invoiceit_s__Currency__c();
            cur = [Select Name from invoiceit_s__Currency__c where Name = 'USD' LIMIT 1];
            if(cur.Name == null) {
                cur = new invoiceit_s__Currency__c();
                cur.Name = 'USD';
                cur.invoiceit_s__Currency_Symbol__c = '$';
                cur.invoiceit_s__Currency_Name__c = 'Dollar';
                Database.insert(cur);
            }
            
            
            
            
            Account a = new Account(); 
            String Acclabel1 = label.Payment_Account;
            for(Account a1 : [Select Id from Account where Name =: Acclabel1 LIMIT 1]) {
                a = a1;
            }
            if(a.Id == null){
                a = new Account();
                a.Name = 'JV Payment Account';
                insert a;                       
            }               
            
            
            
            Savepoint sp = Database.setSavepoint();
            try{
/****************************check the source of the file *******************************/          
            if(FileSource == 'CitiBank'){
                    for (List<String> inputvalues : parsedCSV){
                        
                            payment = new invoiceit_s__Payment__c();
                            payment.invoiceit_s__Status__c = 'Completed';
                            
                            System.debug('size****'+inputValues.size());
                            System.debug('amount values are :::'+inputValues[2]+'$$$'+inputValues[4]);
                            String rawInfo = '';
                            for(String strn : inputvalues){
                              rawInfo += strn.replaceAll('"','')+'|';
                            }   
                            payment.Raw_Info__c = rawInfo;
                            payment.Uploaded_Payment__c = true;
                            
                            payment.invoiceit_s__Currency__c = cur.Id;
                            //payment.CSV_Account_No__c=inputvalues[4].replaceAll('"','');
                            
                            //payment.CSV_Invoice_No__c=inputvalues[5].replaceAll('"','');
                            
                            //payment.Raw_Info__c=inputvalues[0].replaceAll('"','')+'|'+inputvalues[1].replaceAll('"','')+'|'+inputvalues[2].replaceAll('"','')+'|'+inputvalues[3].replaceAll('"','')+'|'+inputvalues[4].replaceAll('"','')+'|'+inputvalues[5].replaceAll('"','');
                                                
                            //payment.Payment_Amount__c= Decimal.valueof(inputvalues[1].replaceAll('"','')); 
                            payment.invoiceit_s__Amount__c = Decimal.valueof(inputvalues[2].replaceAll('"','').replaceAll(',','')); 
                            
                            payment.Total_Pay_Amt__c = Decimal.valueOf(inputvalues[4].replaceAll('"','').replaceAll(',','')); 
                            
                            dateTemp=inputvalues[1].replaceAll('"','').split('/');
                            
                            dateTemp1 = inputvalues[6].replaceAll('"','').split('/');
                            
                            try{
                                System.debug('dateTemp***size:::'+dateTemp.size());
                            if(dateTemp.size() == 3){
                                
                                dateMonth=dateTemp[0];
                                dateDay=dateTemp[1];
                                dateYear=dateTemp[2];
                                if(Integer.valueOf(dateMonth)<=12) {
                                    myDate = Date.newInstance(Integer.valueOf(dateYear),Integer.valueOf(dateMonth),Integer.valueOf(dateDay));                    
                                    //payment.invoiceit_s__Payment_Date__c = myDate ;
                                    System.debug('$$Date is'+myDate);
                                }
                            }   
                            }
                            catch(exception e){
                                ApexPages.Message text1 = new ApexPages.Message(ApexPages.severity.INFO,'WRONG DATE');
                                ApexPages.addMessage(text1);    
                            }
                            try{
                                if(dateTemp1.size() == 3){
                                    dateMonth1=dateTemp1[0];
                                    dateDay1=dateTemp1[1];
                                    dateYear1=dateTemp1[2];
                                    if(Integer.valueOf(dateMonth1)<=12) {
                                        myDate1 = Date.newInstance(Integer.valueOf(dateYear1),Integer.valueOf(dateMonth1),Integer.valueOf(dateDay1));                    
                                        payment.Bank_Deposit_Date__c = myDate1 ;
                                        payment.invoiceit_s__Payment_Date__c = myDate1 ;
                                        System.debug('$$Date111 is'+myDate1);
                                    }
                                }   
                            }
                            catch(exception e){
                                ApexPages.Message text1 = new ApexPages.Message(ApexPages.severity.INFO,'WRONG Bank Deposit DATE');
                                ApexPages.addMessage(text1);    
                            }                                    
                            
                            
                            if(inputvalues[5].replaceAll('"','') == 'Cheque' || inputvalues[5].replaceAll('"','') == 'Check') {
                                payment.invoiceit_s__Cheque_Date__c = myDate;
                                payment.invoiceit_s__Cheque_Number__c= inputvalues[3].replaceAll('"','');
                                payment.invoiceit_s__Bank_Name__c = 'Citibank';
                            }
                            
                            if(inputValues[5].replaceAll('"','') == 'Cheque' || inputValues[5].replaceAll('"','') == 'Check'){
                                payment.invoiceit_s__Payment_Type__c = 'Cheque';
                            }
                            else{
                                payment.invoiceit_s__Payment_Type__c = inputValues[5].replaceAll('"','');
                            }
                            //payment.Payment_Method__c= inputvalues[3].replaceAll('"','');
                            //payment.invoiceit_s__Payment_Type__c = inputvalues[5].replaceAll('"','');
                            system.debug('----mh cust no1 ' + inputvalues[0]);
                            system.debug('----mh cust no2 ' + mapAccountID);
                            
                            if(mapAccountID.containsKey(inputvalues[0])){
                                if(mapAccountID.get(inputvalues[0])!=null && mapAccountID.get(inputvalues[0]).length()>=15) {
                                      payment.invoiceit_s__Account__c = mapAccountID.get(inputvalues[0]);
                                      payment.Created_From_Account__c = mapAccountID.get(inputvalues[0]);
                                }
                                /*else if(inputvalues[4]=='' && mapAccountID.get(inputvalues[4])==null){
                                      payment.invoiceit_s__Account__c =null;
                                }*/                     
                            } 
                            //RBW-1023 
                            else if(inputValues.size() >= 8){  
                                if(mapInvoiceNameToAccountId.containsKey(inputValues[7]) && (inputvalues[0]=='' || inputvalues[0]==null)){
                                    
                                        payment.invoiceit_s__Account__c = mapInvoiceNameToAccountId.get(inputValues[7]);
                                        payment.Created_From_Account__c = mapInvoiceNameToAccountId.get(inputValues[7]);    
                                    
                                }
                                else{
                                        payment.invoiceit_s__Account__c = a.Id;
                                        payment.Created_From_Account__c = a.Id;    
                                }
                            }    
                            else{
                                      payment.invoiceit_s__Account__c = a.Id;
                                      payment.Created_From_Account__c = a.Id;
                            }
                            //RBW-1023
                            if(mapAccountID.containsKey(inputvalues[0]) || inputvalues[0]=='' || inputvalues[0]==null){
                                if(inputValues.size() >= 8){ 
                                    if(mapInvoiceAmount.containskey(inputValues[7])){                           
                                        if(mapInvoiceAmount.get(inputValues[7])!=null && mapInvoiceAmount.get(inputValues[7]).length()>=15 && inputValues.size() <= 8) {
                                          payment.Invoice__c=mapInvoiceAmount.get(inputValues[7]);
                                        }
                                        else {
                                          payment.Invoice__c= null;
                                        }
                                    }
                                }  
                                else{
                                    payment.Invoice__c= null;                           
                                }
                            }
                            else{
                                payment.Invoice__c= null;                           
                            }
                            /*if(mapPayment.get(inputvalues[0])!=null && mapPayment.get(inputvalues[0]).length()>=15) {
                              payment.Payment_Number__c=mapPayment.get(inputvalues[0]);
                            }
                            else {
                              payment.Payment_Number__c= null;
                            }
                            if(mapInvoiceAmount.get(inputValues[7])!=null && inputValues[8] == null) {
                              payment.Invoice__c=mapInvoiceAmount.get(inputValues[7]);
                            }
                            else {
                              payment.Invoice__c= null;
                            }*/ 
                            payment.FileName__c = nameFile;//+String.valueOf(Datetime.now());
                            System.debug('Name of file is ::'+payment.FileName__c);
                            paymentToUpload.add(payment);
                    }
            }
            
            else if(FileSource == 'Bank Of America'){
                    for (List<String> inputvalues : parsedCSV){
                            
                            payment = new invoiceit_s__Payment__c();
                            payment.invoiceit_s__Status__c = 'Completed';
                            payment.FileName__c = nameFile;
                            System.debug('total list ---> ' + parsedCSV);
                            
                            //MAKE UPLOAD PAYMENT TRUE (FOR VALIDATION PURPOSE)
                            payment.Uploaded_Payment__c = true;
                            
                            
                            //CURRENCY
                            payment.invoiceit_s__Currency__c = cur.Id;
                            
                            
                            //RAW DATA
                            String rawInformation = '';
                            for(String Svalues : inputValues){
                                system.debug('total list 2 ' + Svalues );
                                rawInformation += Svalues.replaceAll('"','')+'|';
                            }
                            payment.Raw_Info__c = rawInformation;
                            
                            //PAYMENT TYPE
                            if(inputValues[0].replaceAll('"','') == 'Cheque' || inputValues[0].replaceAll('"','') == 'Check'){
                                payment.invoiceit_s__Payment_Type__c = 'Cheque';
                            }
                            else{
                                payment.invoiceit_s__Payment_Type__c = inputValues[0].replaceAll('"','');
                            }
                            
                            //Assign ACCOUNT to the PAYMENT
                            if(mapAccountID.containsKey(inputvalues[1])){
                                //RBW-1023
                                if(mapAccountID.get(inputvalues[1])!=null && mapAccountID.get(inputvalues[1]).length()>=15) {
                                      payment.invoiceit_s__Account__c = mapAccountID.get(inputvalues[1]);
                                      payment.Created_From_Account__c = mapAccountID.get(inputvalues[1]);
                                }   
                            }
                            else if(mapInvoiceNameToAccountId.containsKey(inputValues[6]) && (inputValues[1]==null || inputValues[1]=='')){
                                        payment.invoiceit_s__Account__c = mapInvoiceNameToAccountId.get(inputValues[6]);
                                        payment.Created_From_Account__c = mapInvoiceNameToAccountId.get(inputValues[6]);    
                            }    
                            else{
                                      payment.invoiceit_s__Account__c = a.Id;
                                      payment.Created_From_Account__c = a.Id;
                            }
                            
                            
                            //BANK DEPOSIT DATE
                            dateTemp1 = inputvalues[2].replaceAll('"','').split('/');
                            Date depositDate;
                            try{
                                if(dateTemp1.size() == 3){
                                    dateMonth1=dateTemp1[0];
                                    dateDay1=dateTemp1[1];
                                    dateYear1=dateTemp1[2];
                                    depositDate = Date.newInstance(Integer.valueOf(dateYear1),Integer.valueOf(dateMonth1),Integer.valueOf(dateDay1));                    
                                    payment.Bank_Deposit_Date__c = depositDate ;
                                    payment.invoiceit_s__Payment_Date__c = depositDate ;                                                                                            
                                }
                                else{
                                    ApexPages.Message text1 = new ApexPages.Message(ApexPages.severity.INFO,'WRONG DATE');
                                    ApexPages.addMessage(text1);  
                                }                               
                            }
                            catch(exception e){
                                ApexPages.Message text1 = new ApexPages.Message(ApexPages.severity.INFO,'WRONG DATE');
                                ApexPages.addMessage(text1);    
                            }
                            
                            
                            //CHEQUE NUMBER , DATE AND BANK NAME - FOR PAYMENT TYPE "Cheque" ONLY                 
                            system.debug('payment type -- > ' + inputvalues[0].replaceAll('"',''));           
                            if(inputvalues[0].replaceAll('"','') == 'Cheque' || inputvalues[0].replaceAll('"','') == 'Check') {                                 
                                    payment.invoiceit_s__Cheque_Date__c = depositDate;
                                    system.debug('check number --> ' + inputvalues[7].replaceAll('"',''));
                                    payment.invoiceit_s__Cheque_Number__c= inputvalues[7].replaceAll('"','');
                                    payment.invoiceit_s__Bank_Name__c = 'Bank of America';
                            }
                            
                                                                         
                            
                            //Assign INVOICE to the PAYMENT  
                            //RBW-1023 
                            if(mapAccountID.containsKey(inputvalues[1]) || inputValues[1]=='' || inputValues[1]==null){                         
                                if(mapInvoiceAmount.containskey(inputValues[6])){                           
                                    if(mapInvoiceAmount.get(inputValues[6])!=null && mapInvoiceAmount.get(inputValues[6]).length()>=15) {
                                      payment.Invoice__c=mapInvoiceAmount.get(inputValues[6]);
                                    }
                                    else {
                                      payment.Invoice__c= null;
                                    }
                                }
                                else{
                                    payment.Invoice__c= null;                           
                                }
                            }                            
                            else{
                                payment.Invoice__c= null;                           
                            }
                            
                            
                            //INVOICE IT AMOUNT
                            payment.invoiceit_s__Amount__c = Decimal.valueof(inputvalues[3].replaceAll('"','').replaceAll(',','')); 
                            
                            
                            //TOTAL PAY AMOUNT
                            payment.Total_Pay_Amt__c = Decimal.valueOf(inputvalues[4].replaceAll('"','').replaceAll(',','')); 
                            
                            
                            paymentToUpload.add(payment);
                            
                            
                    }   
            }
            }
            catch(Exception e){
                ApexPages.Message text1 = new ApexPages.Message(ApexPages.severity.Error,'There is some error in the payment file. Please check if you have selected the right format');
                ApexPages.addMessage(text1);
                Database.rollback(sp);    
                return;
            }
            try{
                List<Id> paymentIdsForFuture = new List<Id>();
                if(paymentToUpload.size() > 0){
                    Database.insert(paymentToUpload);
                    ApexPages.Message text1 = new ApexPages.Message(ApexPages.severity.INFO,'Payments have been successfully uploaded');
                    ApexPages.addMessage(text1);
                }   
                else{
                    ApexPages.Message text1 = new ApexPages.Message(ApexPages.severity.ERROR,'NO PAYMENTS HAVE BEEN UPLOADED');
                    ApexPages.addMessage(text1);
                } 
                for(invoiceit_s__Payment__c pay :  paymentToUpload){
                    paymentIdsForFuture.add(pay.Id);
                }
                MDL_Future_InsertPaymentAllocation.insertPaymentAllocation(paymentIdsForFuture);
                System.debug('paymentToUPload is ***'+paymentToUpload+'^^^'+paymentToUpload.size());
                showNextButton = true;
                
            }
            catch (Exception e)
            {
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() + '. An error has occured. Please check if you have selected the right format ');
                ApexPages.addMessage(errormsg);
                Database.rollback(sp);
                return;
            }
    }
    public Pagereference goToEditPaymentPage() {
        
        return new Pagereference('/apex/MDL_EditPaymentPage?fileName='+nameFile);
    }
}
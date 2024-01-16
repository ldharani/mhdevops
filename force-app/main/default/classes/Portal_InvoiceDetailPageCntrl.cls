/*********************************************************************************
Created By : Lister Technologies

Created Purpose : This class is a controller class for MDL invoice detail page 
Modified by : Lister Technologies
Modified Purpose : MHBS-173
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************    
MHBS-8823    Lakshmi      05/17/2023    Lori            T01     Change sort of open invoices in Portal
*************************************************************************************************************************/
public without sharing class  Portal_InvoiceDetailPageCntrl {

    public String custNo {get;set;}
    public boolean baseURL {get;set;}
    public String formSubmitCSCURL {get;set;}
    public String token {get;set;}
    public boolean displayPage {get;set;}   
    public string accName = '';
    public Map<String,String> entireHeader {get; set;} 
    public String baseCSCURL {get;set;}
    public String sessionId {get;set;}
    public Account account{get;set;}
    public static string todeleteInvId{get;set;} 
    public String selectedTab { get; set; }
    public id invoiceid{get;set;}
    public string customerno{get;set;}
    public String selectedFilterMonth{get;set;}  
    public static set<id> idsetforinvpaymentforaccount;
    public static set<id> idsetforinvpaymentforaccount1;
    public String SMB_URL{get;set;}
    public String CSC_URL{get;set;}
    public boolean CSC{get;set;}
    public boolean SMB{get;set;}
    public String urlValue{get;set;}
    public String domain{get;set;}
    public boolean isSMB{get;set;}
    public boolean isValidPage{get;set;}
    public String smbrowtoken {get;set;}
    public String smbtoken {get;set;}
    
    
    public static boolean CheckinvIdVSinvPaymntList{get;set;}  
    
    public static boolean CheckidvsPaymentAllocations{get;set;}
    //account id fetching from url
    public static Id accountId;
    
    //invoices related to account irrespective of status
    public static list<blng__Invoice__c > accInvcsList {get;set;}
    
    //invoices related to account  status upaid
    public static list<blng__Invoice__c > accUnpaidInvcsList {get;set;}
    
    //map to show payments for invoices using + symbol
    public static map<id, List<blng__Payment__c>>  invIdVSinvPaymntList {get;set;}
    
    public static map<string,blng__PaymentAllocationInvoice__c> idvsPaymentAllocations {get;set;}
    
    //commaseperated to key to avoid null pointer exception when key not present in above map
    public static string commaSeperatedInvKeys {get;set;}
    
    public static string commaSeperatedInvKeysallocations{get;set;}
    
    //payments related to account for which invoice is not present
    public static list<blng__Payment__c > InvPaymentListforAccount {get;set; }
    
    //public static list<blng__Payment__c > InvPaymentList {get;set; }
    
    public List<InvoicePaymentWrapper> InvoicPaymentWrapperList{get;set; }
    
    //CreditCard List for My Payment Type Tab  
    public static List<blng__PaymentMethod__c>  creditCardList{get;set;}
    
    //BankTransfer List for My Payment Type Tab  
    public static List<blng__PaymentMethod__c>  bankTransferList{get;set;}
   
    public Portal_InvoiceDetailPageCntrl()
    {
       CSC_token__c csc_token = CSC_token__c.getValues('ExpectedToken');
        String actual_token = csc_token.Actual_Token__c;
        String actual_domain = csc_token.Actual_Domain__c;
        baseCSCURL = csc_token.Base_URL__c;
        formSubmitCSCURL = csc_token.Form_Submit_URL__c;
        System.debug('actual_token'+actual_token);        
        sessionId = ApexPages.currentPage().getParameters().get('sessionId');
        //custNo = ApexPages.currentPage().getParameters().get('c');
        token = ApexPages.currentPage().getHeaders().get('Authorization');
        smbrowtoken = ApexPages.currentPage().getHeaders().get('SMB_Authorization');
        if(smbrowtoken!=null){
            smbtoken = smbrowtoken.remove('Bearer '); 
        }
        domain = ApexPages.currentPage().getHeaders().get('RefDomain'); 
        entireHeader = ApexPages.currentPage().getHeaders();
        /*****************sai : 22/08/2018**********************************************************************/
        //getting authorization header for Integration
        isValidPage = false;
        String smbAuthorizationToken='';
        //commented
        system.debug('SMB Authorization token'+ApexPages.currentPage().getHeaders().get('SMB_Authorization'));
        system.debug('Full header');
        system.debug('SMB Authorization token'+ApexPages.currentPage().getHeaders());
        if(ApexPages.currentPage().getHeaders().get('Authorization') != null){
           smbAuthorizationToken = ApexPages.currentPage().getHeaders().get('SMB_Authorization');
          
           // Now making a get callout to check the page validation
        
            string endpoint = system.Label.PayNow_Endpoint;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPoint);
            request.setMethod('GET');
            request.setHeader('Authorization', smbAuthorizationToken);
            request.setHeader('Host','login.martindalenolo.com');
            request.setHeader('Content-Type','application/json');
            request.setHeader('accept','application/json');
            
            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            if(response.getStatusCode() == 302){
                request.setEndpoint(response.getHeader('Location'));
                response = new Http().send(request);
            }
            
             if (response.getStatusCode() == 200) {
                 isValidPage = True;
                 
                // Deserialize the JSON string into collections of primitive data types.
                Map<String, Object> finalresults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                system.debug('@@@@@final response'+ response.getBody());
             } 
            else{
                system.debug('@@@response status'+ response.getStatus());
                system.debug('@@@response status'+ response.getStatusCode());
                system.debug('@@@response status'+ response.getBody());
            }
        
        } 
        if(ApexPages.currentPage().getHeaders().get('UID') != null)
            System.debug('Header value uid****'+ApexPages.currentPage().getHeaders().get('UID'));
        entireHeader = ApexPages.currentPage().getHeaders();        
        
        displayPage=true;       
         customerno = ApexPages.currentPage().getParameters().get('c');
        
       if(customerno != null){
            accountId = [select id, name 
                           from account
                            where MH_Cust_Number__c =:customerno].id;
            system.debug('@@@accountId'+ accountId);
        }
        
      
        if(entireHeader.containsKey('RefDomain')){
            isSMB = true;
        }
        else{
            isSMB = false;
        }

 
        if (accountId != null)
        {
            system.debug('@@getting account');
            invoiceAndPayments(accountId);
            paymentAndAccount(accountId);
            
            genrateWrapperList(accInvcsList,InvPaymentListforAccount);
            upaidInvoice(accountId);
            myPaymentTypes(accountId);
        }
        
        selectedTab = ApexPages.currentPage().getParameters().get('tab');
        if (selectedTab == null) {
            System.debug('inside if');
            selectedTab = 'invoiceTabPanel';
            System.debug('selected tab');
        }
        else {
            System.debug('inside else');
        }
    }
    
    public List<SelectOption> getselectedFilterMonthItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('0','All'));
        options.add(new SelectOption('1', 'Last Month'));
        options.add(new SelectOption('3','Last 3 Months'));
        options.add(new SelectOption('6','Last 6 Months'));
        options.add(new SelectOption('9','Last 9 Months'));
        options.add(new SelectOption('12','Last 12 Months'));
        return options;
    }
    
    
    public void fliterInvoicePayment()
    {
        system.debug('@@@in fliterInvoicePayment');
        system.debug('@@@selectedFilterMonth' + selectedFilterMonth);
        Date todayDate = date.today();
        Date lastDate ;
        string customernoinv = ApexPages.currentPage().getParameters().get('c');
        if(customerno != null){
            accountId = [select id, name 
                           from account
                            where MH_Cust_Number__c =:customerno].id;
            system.debug('@@@accountId'+ accountId);
        }
        
        if(selectedFilterMonth == '0')
        {   system.debug('enter month filter');
         if(accountId != null)
            { invoiceAndPayments(accountId);
                 paymentAndAccount(accountId);
                genrateWrapperList(accInvcsList,InvPaymentListforAccount);
            }
        }
        else  if(selectedFilterMonth == '1')
        { system.debug('enter month filter1');
            lastDate = todayDate.addMonths(-1);
            system.debug('@@@@in month condition');
            system.debug('@@@accountId'+ accountId);
            
            if(accountId != null)
            {   invoiceAndPaymentsFilter(accountId, todayDate, lastDate );
                paymentAndAccountFilter(accountId, todayDate, lastDate );                
                genrateWrapperList(accInvcsList,InvPaymentListforAccount) ;               
            }
        }
        
        else  if(selectedFilterMonth == '3')
        { system.debug('enter month filter2');
            lastDate = todayDate.addMonths(-3);
            if(accountId != null)
            {
                invoiceAndPaymentsFilter(accountId, todayDate, lastDate );
                 paymentAndAccountFilter(accountId, todayDate, lastDate );
                genrateWrapperList(accInvcsList,InvPaymentListforAccount);
            }
        }
        
        else  if(selectedFilterMonth == '6')
        { system.debug('enter month filter6');
            lastDate = todayDate.addMonths(-6);
            if(accountId != null)
            {
                invoiceAndPaymentsFilter(accountId, todayDate, lastDate );
                paymentAndAccountFilter(accountId, todayDate, lastDate );
                genrateWrapperList(accInvcsList,InvPaymentListforAccount);
            }
        }
        
        else  if(selectedFilterMonth == '9')
        {   system.debug('enter month filter7');
            if(accountId != null)
            {
                lastDate = todayDate.addMonths(-9);
                invoiceAndPaymentsFilter(accountId, todayDate, lastDate );
                paymentAndAccountFilter(accountId, todayDate, lastDate );
                genrateWrapperList(accInvcsList,InvPaymentListforAccount);
            }
        }
        else  if(selectedFilterMonth == '12')
        { system.debug('enter month filter12');
            lastDate = todayDate.addMonths(-12);
            if(accountId != null)
            { 
                invoiceAndPaymentsFilter(accountId, todayDate, lastDate );
                paymentAndAccountFilter(accountId, todayDate, lastDate );
                genrateWrapperList(accInvcsList,InvPaymentListforAccount);
            }
        }
        
    }
    
    //sign out logic
    public PageReference signOut()
    { PageReference pageRef = null;
        string logoutURL = '';
        logoutURL = system.label.SMB_MainURL +'/site/logout';
       
        pageRef = new PageReference(logoutURL);
        pageRef.setRedirect(true);
        return pageRef;    
    }
    
   
    public void paymentAndAccount(id accid)
    {
        system.debug('@@accountId in paymentAndAccount'+ accountId);
        account = new Account();
        
        InvPaymentListforAccount =  new list<blng__Payment__c>();
        InvoicPaymentWrapperList =  new list<InvoicePaymentWrapper>();
        
        //getting account and its payments for which invoice = null
        account  = [Select Id,Name, AccountBalanceAmount__c, MH_Cust_Number__c,
                    (select id, Name, Total_Payment_Amount__c,blng__Invoice__c, 
                     blng__Status__c ,
                     blng__PaymentType__c,
                     blng__PaymentDate__c,
                     blng__Amount__c                    
                     from blng__Payments__r 
                     where blng__Invoice__c = null
                      order by blng__PaymentDate__c DESC)
                    From Account where Id =: accid ];
        system.debug('@@@account in paymentAndAccount'+ account);
        
        //if any payments present in above query assign to a list to show
        if(account.blng__Payments__r.size() > 0){
            system.debug('@@@@account.Payments'+ account.blng__Payments__r);
            //InvPaymentListforAccount = account.Payments;
            for(blng__Payment__c payment : account.blng__Payments__r){
                system.debug('@@@idsetforinvpaymentforaccount in 1st'+ idsetforinvpaymentforaccount);
                if(!idsetforinvpaymentforaccount.contains(payment.id)){
                    InvPaymentListforAccount.add(payment);
                }
            }
                
            system.debug('@@@@InvPaymentListforAccount'+ InvPaymentListforAccount);
            system.debug('@@@@InvPaymentListforAccount.size'+ InvPaymentListforAccount.size());
        }
        
    }
    //creating invoice with no payments and invoice with payments
    public static void invoiceAndPayments(id accid){
        accInvcsList = new list<blng__Invoice__c >();
        idsetforinvpaymentforaccount = new set<id>();
        idsetforinvpaymentforaccount1 = new set<id>();
        list<blng__Payment__c > InvPaymentList =  new list<blng__Payment__c>();
        set<id> invoiceids = new set<id>();
        invIdVSinvPaymntList = new map<id, List<blng__Payment__c>>();
        
        //map invoice id + payemnt id VS payment allocations
         idvsPaymentAllocations = new  map<string,blng__PaymentAllocationInvoice__c>();
        
        
        //map form from payment allocations
        map<id,list<id>> paymentidVsinvid = new map<id,list<id>>();
        //invoice for account 
        accInvcsList = [Select Id, blng__Balance__c, 
                        blng__PaymentsAgainstInvoice__c, blng__TotalAmount__c,
                        blng__Payments__c, blng__PaymentStatus__c, 
                        blng__InvoiceDate__c, blng__DueDate__c, 
                        Name,IsDataLoaded__c,RecordType.developerName,
                        (select id, Name, 
                            blng__Payment__c, blng__Invoice__c,
                             blng__Payment__r.blng__Invoice__c,blng__Amount__c 
                              from
                              blng__PaymentInvoiceAllocations__r
                               where blng__Payment__r.blng__Invoice__c = null)
                        From blng__Invoice__c 
                        where blng__Account__c =: accid
                        and blng__InvoiceStatus__c = 'Posted'
                        order by CreatedDate ASC]; //<T01>
        
        system.debug('@@@accInvcsList'+ accInvcsList);
        
        //map for invoice vs list of its payments
        if(!accInvcsList.isEmpty()){
            //invoiceids = new map<id, blng__Invoice__c>(accInvcsList).keySet();
            for(blng__Invoice__c inv : accInvcsList){
                invoiceids.add(inv.id);
                
                //forming paymentidVsinvid map from payment allocations to from relationship between
                //payments and invoices for which payment doesn't connect to invoice directly
                //they r connected through payment allocations
                for(blng__PaymentAllocationInvoice__c inpaymentallocation : inv.blng__PaymentInvoiceAllocations__r){
                    idvsPaymentAllocations.put(string.valueOf(inpaymentallocation.blng__Invoice__c) + string.valueOf(inpaymentallocation.blng__Payment__c), inpaymentallocation);
                    if(paymentidVsinvid.containsKey(inpaymentallocation.blng__Payment__c)){
                        paymentidVsinvid.get(inpaymentallocation.blng__Payment__c).add(inpaymentallocation.blng__Invoice__c);
                    }
                    else{
                        paymentidVsinvid.put(inpaymentallocation.blng__Payment__c, new list<id>{inpaymentallocation.blng__Invoice__c});
                    }
                    
                }
            }
            
            system.debug('@@@@idvsPaymentAllocations'+ idvsPaymentAllocations);
            commaSeperatedInvKeysallocations = '';
            if(idvsPaymentAllocations != null && idvsPaymentAllocations.size() > 0 ){
                for(String invpayid : idvsPaymentAllocations.keySet()){
                    commaSeperatedInvKeysallocations +=  invpayid + ',';
                    
                }
                
                CheckidvsPaymentAllocations = true;
            }
            system.debug('@@@@commaSeperatedInvKeysallocations' + commaSeperatedInvKeysallocations);
            
            system.debug('@@@@paymentidVsinvid' + paymentidVsinvid);
            
           String queryString = 'select id, Name, blng__Invoice__c,'+
                              ' blng__PaymentDate__c,'+
                              ' blng__AllocatedtoInvoices__c,'+ 
                              ' Total_Payment_Amount__c,blng__Amount__c,'+
                              ' blng__PaymentType__c' +
                              ' from blng__Payment__c' +
                              ' where blng__Account__c =: accid'+
                              ' and (blng__Invoice__c IN :invoiceids';
            set<id> keys = new set<id>();
            if(!paymentidVsinvid.isEmpty() && paymentidVsinvid != null){
                keys = paymentidVsinvid.keySet();
            }
            
            if(!keys.isEmpty() && keys !=null){
                queryString += ' OR ID IN:keys)';
            }
            else{
                 queryString += ')';
            }
            system.debug('@@@keys'+ keys);
            system.debug('@@@queryString'+ queryString);
           
            InvPaymentList = database.query(queryString);
            
            //forming invoice id Vs payments list map
            for(blng__Payment__c singlePaymt : InvPaymentList){
                system.debug('@@@@ in invIdVSinvPaymntList map'+ singlePaymt.blng__Invoice__c);
                
                if(invIdVSinvPaymntList.containsKey(singlePaymt.blng__Invoice__c)){
                        if(singlePaymt.blng__Invoice__c != null){
                            invIdVSinvPaymntList.get(singlePaymt.blng__Invoice__c).add(singlePaymt);
                        }
                    else{
                        if(paymentidVsinvid.containsKey(singlePaymt.id)){
                            for(id invid : paymentidVsinvid.get(singlePaymt.id)){
                                if(invIdVSinvPaymntList.containsKey(invid)){
                                    invIdVSinvPaymntList.get(invid).add(singlePaymt);
                                }
                                else{
                                    invIdVSinvPaymntList.put(invid, new list<blng__Payment__c>{singlePaymt});
                                }
                            }
                           
                        }
                    }
                }
               
                
                else{
                    if(singlePaymt.blng__Invoice__c != null){
                        system.debug('@@creating first invoice for map'+ singlePaymt.blng__Invoice__c);
                        invIdVSinvPaymntList.put(singlePaymt.blng__Invoice__c, new list<blng__Payment__c>{singlePaymt});
                    }
                    else{
                        if(paymentidVsinvid.containsKey(singlePaymt.id)){
                             system.debug('@@creating first invoice for map'+ singlePaymt.blng__Invoice__c);
                            for(id invid : paymentidVsinvid.get(singlePaymt.id)){
                                if(invIdVSinvPaymntList.containsKey(invid)){
                                    invIdVSinvPaymntList.get(invid).add(singlePaymt);
                                }
                                else{
                                    invIdVSinvPaymntList.put(invid, new list<blng__Payment__c>{singlePaymt});
                                }
                            }
                           }
                    }
                    
                }
                
            }
            system.debug('@@@@invIdVSinvPaymntList'+ invIdVSinvPaymntList);
            //creating comma seperated key for those invoices for which payments are peresent to avoi
            //null pointer exception in vf page
            commaSeperatedInvKeys = '';
            if(invIdVSinvPaymntList != null && invIdVSinvPaymntList.size() > 0 ){
                for(String invid : invIdVSinvPaymntList.keySet()){
                    commaSeperatedInvKeys +=  invid + ',';
                    for(blng__Payment__c singleinvpay: invIdVSinvPaymntList.get(invid)){
                        idsetforinvpaymentforaccount.add(singleinvpay.id);
                    }
                }
                idsetforinvpaymentforaccount1 = idsetforinvpaymentforaccount;
                CheckinvIdVSinvPaymntList = true;
            }
            system.debug('@@@map Keyset' + invIdVSinvPaymntList.keySet());
            system.debug('@@@idsetforinvpaymentforaccount in 2nd'+ idsetforinvpaymentforaccount);  
            
        }
    }
    
    public void paymentAndAccountFilter(id accid, Date todayDate, Date lastDate)
    {
        
        system.debug('@@accountId' + accountId);
        account = new Account();
        system.debug('@@@todayDate'+ todayDate);
        system.debug('@@@todayDate'+ lastDate);
        InvPaymentListforAccount =  new list<blng__Payment__c>();
        InvoicPaymentWrapperList =  new list<InvoicePaymentWrapper>();
        
        
        //getting account and its payments for which invoice = null
        account  = [Select Id,Name, AccountBalanceAmount__c,
                    (select id, Name, Total_Payment_Amount__c, 
                     blng__Status__c ,
                     blng__PaymentType__c,
                     blng__Amount__c,
                     blng__PaymentDate__c
                     from blng__Payments__r 
                     where blng__Invoice__c = null and blng__PaymentDate__c >= : lastDate and blng__PaymentDate__c <= : todayDate 
                         order by blng__PaymentDate__c DESC)
                    From Account where Id =: accountId ];
        
        //if any payments present in above query assign to a list to show
        if(account.blng__Payments__r.size() > 0){
            system.debug('@@@@account.Payments'+ account.blng__Payments__r);
            //InvPaymentListforAccount = account.Payments;
            system.debug('@@@idsetforinvpaymentforaccount1 in 1st filter'+ idsetforinvpaymentforaccount);
                for(blng__Payment__c payment : account.blng__Payments__r){
                    system.debug('@@@idsetforinvpaymentforaccount1 in 1st in filter'+ idsetforinvpaymentforaccount);
                    
                        if(!idsetforinvpaymentforaccount.contains(payment.id)){
                            InvPaymentListforAccount.add(payment);
                        }
                    
                    
               }  
            system.debug('@@@@InvPaymentListforAccount'+ InvPaymentListforAccount);
            system.debug('@@@@InvPaymentListforAccount.size'+ InvPaymentListforAccount.size());
        }
        
    }
    //creating invoice with no payments and invoice with payments
    public static void invoiceAndPaymentsFilter(id accid,Date todayDate, Date lastDate){
        accInvcsList = new list<blng__Invoice__c >();
        
        //again calling done to form idsetforinvpaymentforaccount to avoid payments which are already 
        //present invoices
        invoiceAndPayments(accid);
         system.debug('@@@todayDate in invoice '+ todayDate);
        system.debug('@@@todayDate in invoice'+ lastDate);
        list<blng__Payment__c > InvPaymentList =  new list<blng__Payment__c>();
        set<id> invoiceids = new set<id>();
        invIdVSinvPaymntList = new map<id, List<blng__Payment__c>>();
        idvsPaymentAllocations = new  map<string,blng__PaymentAllocationInvoice__c>();
        
        
        //map form from payment allocations
        map<id,list<id>> paymentidVsinvid = new map<id,list<id>>();
        
        //invoice for account 
        accInvcsList = [Select Id, blng__Balance__c, 
                        blng__PaymentsAgainstInvoice__c, blng__TotalAmount__c,
                        blng__Payments__c, blng__PaymentStatus__c, 
                        blng__InvoiceDate__c, blng__DueDate__c, 
                        Name,IsDataLoaded__c,RecordType.developerName,

                        (select id, Name, 
                            blng__Payment__c, blng__Invoice__c,
                              blng__Amount__c 
                              from
                              blng__PaymentInvoiceAllocations__r
                               where blng__Payment__r.blng__Invoice__c = null)
                        From blng__Invoice__c 
                        where blng__Account__c =: accid
                        and blng__InvoiceDate__c >=: lastDate and blng__InvoiceDate__c <=: todayDate
                        and blng__InvoiceStatus__c = 'Posted'
                        order by CreatedDate ASC]; //<T01>
       
                    //map for invoice vs list of its payments
        if(!accInvcsList.isEmpty()){
            //invoiceids = new map<id, blng__Invoice__c>(accInvcsList).keySet();
            for(blng__Invoice__c inv : accInvcsList){
                invoiceids.add(inv.id);
                
                //forming paymentidVsinvid map
                for(blng__PaymentAllocationInvoice__c inpaymentallocation : inv.blng__PaymentInvoiceAllocations__r){
                   idvsPaymentAllocations.put(string.valueOf(inpaymentallocation.blng__Invoice__c) + string.valueOf(inpaymentallocation.blng__Payment__c), inpaymentallocation);
                    if(paymentidVsinvid.containsKey(inpaymentallocation.blng__Payment__c)){
                        paymentidVsinvid.get(inpaymentallocation.blng__Payment__c).add(inpaymentallocation.blng__Invoice__c);
                    }
                    else{
                        paymentidVsinvid.put(inpaymentallocation.blng__Payment__c, new list<id>{inpaymentallocation.blng__Invoice__c});
                    }
                }
            }
            
             system.debug('@@@@idvsPaymentAllocations'+ idvsPaymentAllocations);
            commaSeperatedInvKeysallocations = '';
            if(idvsPaymentAllocations != null && idvsPaymentAllocations.size() > 0 ){
                for(String invpayid : idvsPaymentAllocations.keySet()){
                    commaSeperatedInvKeysallocations +=  invpayid + ',';
                    
                }
                
                CheckidvsPaymentAllocations = true;
            }
            system.debug('@@@@commaSeperatedInvKeysallocations' + commaSeperatedInvKeysallocations);
            
            system.debug('@@@@paymentidVsinvid' + paymentidVsinvid);
            
            
            
           String queryString = 'select id, Name, blng__Invoice__c,'+
                              ' blng__PaymentDate__c,'+
                              ' blng__AllocatedtoInvoices__c,'+ 
                              ' Total_Payment_Amount__c,blng__Amount__c,'+
                              ' blng__PaymentType__c' +
                              ' from blng__Payment__c' +
                              ' where blng__Account__c =: accid'+
                              ' and (blng__Invoice__c IN :invoiceids';
            set<id> keys = new set<id>();
            if(!paymentidVsinvid.isEmpty() && paymentidVsinvid != null){
                keys = paymentidVsinvid.keySet();
            }
            
            if(!keys.isEmpty() && keys !=null){
                queryString += ' OR ID IN:keys)';
            }
            else{
                 queryString += ')';
            }
            system.debug('@@@keys'+ keys);
            system.debug('@@@queryString'+ queryString);
           
            
            InvPaymentList = database.query(queryString);
            system.debug('@@@@InvPaymentList in filter'+ InvPaymentList);
            
            //forming invoice id Vs payments list map
            for(blng__Payment__c singlePaymt : InvPaymentList){
                system.debug('@@@@ in invIdVSinvPaymntList map'+ singlePaymt.blng__Invoice__c);
                
                if(invIdVSinvPaymntList.containsKey(singlePaymt.blng__Invoice__c)){
                        if(singlePaymt.blng__Invoice__c != null){
                            invIdVSinvPaymntList.get(singlePaymt.blng__Invoice__c).add(singlePaymt);
                        }
                    else{
                        if(paymentidVsinvid.containsKey(singlePaymt.id)){
                              for(id invid : paymentidVsinvid.get(singlePaymt.id)){
                                if(invIdVSinvPaymntList.containsKey(invid)){
                                    invIdVSinvPaymntList.get(invid).add(singlePaymt);
                                }
                                else{
                                    invIdVSinvPaymntList.put(invid, new list<blng__Payment__c>{singlePaymt});
                                }
                            }
                        }
                    }
                }
               
                
                else{
                    if(singlePaymt.blng__Invoice__c != null){
                        system.debug('@@creating first invoice for map'+ singlePaymt.blng__Invoice__c);
                        invIdVSinvPaymntList.put(singlePaymt.blng__Invoice__c, new list<blng__Payment__c>{singlePaymt});
                    }
                    else{
                        if(paymentidVsinvid.containsKey(singlePaymt.id)){
                             system.debug('@@creating first invoice for map'+ singlePaymt.blng__Invoice__c);
                             for(id invid : paymentidVsinvid.get(singlePaymt.id)){
                                if(invIdVSinvPaymntList.containsKey(invid)){
                                    invIdVSinvPaymntList.get(invid).add(singlePaymt);
                                }
                                else{
                                    invIdVSinvPaymntList.put(invid, new list<blng__Payment__c>{singlePaymt});
                                }
                            }
                        }
                    }
                    
                }
                
            }
            system.debug('@@@@invIdVSinvPaymntList'+ invIdVSinvPaymntList);
            
            //creating comma seperated key for those invoices for which payments are peresent to avoi
            //null pointer exception in vf page
            commaSeperatedInvKeys = '';
            if(invIdVSinvPaymntList != null &&  invIdVSinvPaymntList.size() > 0 ){
                for(String invid : invIdVSinvPaymntList.keySet()){
                    commaSeperatedInvKeys +=  invid + ',';
                     
                }
                
                CheckinvIdVSinvPaymntList = true;
            }
            system.debug('@@@commaSeperatedInvKeys in filter'+ commaSeperatedInvKeys);
            system.debug('@@@map Keyset' + invIdVSinvPaymntList.keySet());
            
        }
    }
    public void genrateWrapperList(List<blng__Invoice__c> invoiceList,List<blng__Payment__c> paymentList)
    {
        
        List<blng__Invoice__c> lstPaidInvoices = new List<blng__Invoice__c>();
        //T01 => Add only the unpaid or partially paid invoices to the wrapper first
        for(blng__Invoice__c inv : invoiceList)
        {            
            if(inv.blng__PaymentStatus__c != 'Paid'){
                String invoiceName ='';
                //if(invoiceList[i].IsDataLoaded__c == 'Y' && invoiceList[i].RecordType.developerName == RecordTypesFinalStringsClass.RecTypeName_MH_Invoice){
                    invoiceName = inv.Name;
                /*}
               else{
                    invoiceName = string.valueOf(invoiceList[i].Name);
                }*/
                if(inv.RecordType.developerName == 'MH_Invoice' && inv.blng__TotalAmount__c > 0){
                    
                    InvoicPaymentWrapperList.add(new InvoicePaymentWrapper(inv.Id,
                                                                       'Invoice', 
                                                                       invoiceName,
                                                                       inv.blng__InvoiceDate__c,
                                                                       String.valueOf(inv.blng__TotalAmount__c),
                                                                       String.valueOf(inv.blng__Payments__c),
                                                                       String.valueOf(inv.blng__Balance__c),
                                                                       String.valueOf(inv.blng__PaymentStatus__c),
                                                                       'Credit Card',
                                                                       String.valueOf(inv.RecordType.developerName),
                                                                       String.valueOf(inv.IsDataLoaded__c)));
                }
            } 
            else{
                system.debug('Paid Invoice==>'+inv);
                lstPaidInvoices.add(inv);
            }           
            
        }
        
        if(lstPaidInvoices.size() > 0){            
            Integer i = lstPaidInvoices.size()-1;
            system.debug('Length=='+lstPaidInvoices.size());
            //T01 -> Add the Paid Invoices after the unpaid or partially paid invoices
            for(blng__Invoice__c inv: lstPaidInvoices) //<T01>
            {
                                  
                String invoiceName ='';
                //if(invoiceList[i].IsDataLoaded__c == 'Y' && invoiceList[i].RecordType.developerName == RecordTypesFinalStringsClass.RecTypeName_MH_Invoice){
                    invoiceName = lstPaidInvoices[i].Name;
                /*}
               else{
                    invoiceName = string.valueOf(invoiceList[i].Name);
                }*/
                if(lstPaidInvoices[i].RecordType.developerName == 'MH_Invoice' && lstPaidInvoices[i].blng__TotalAmount__c > 0){
                    
                    InvoicPaymentWrapperList.add(new InvoicePaymentWrapper(lstPaidInvoices[i].Id,
                                                                       'Invoice', 
                                                                       invoiceName,
                                                                       lstPaidInvoices[i].blng__InvoiceDate__c,
                                                                       String.valueOf(lstPaidInvoices[i].blng__TotalAmount__c),
                                                                       String.valueOf(lstPaidInvoices[i].blng__Payments__c),
                                                                       String.valueOf(lstPaidInvoices[i].blng__Balance__c),
                                                                       String.valueOf(lstPaidInvoices[i].blng__PaymentStatus__c),
                                                                       'Credit Card',
                                                                       String.valueOf(lstPaidInvoices[i].RecordType.developerName),
                                                                       String.valueOf(lstPaidInvoices[i].IsDataLoaded__c)));
                }
                            
                i= i-1;
            }
        }
        //<T01> Changes End
       
        system.debug('@@@@InvoicPaymentWrapperList'+ InvoicPaymentWrapperList);
        
    }
    
    
    public static void upaidInvoice(id accid){
        accUnpaidInvcsList = new list<blng__Invoice__c >();
        
        //unpaid invoice for account 
        accUnpaidInvcsList = [Select Id,blng__Balance__c, 
                              blng__PaymentsAgainstInvoice__c, blng__TotalAmount__c,
                              blng__Payments__c, blng__PaymentStatus__c, 
                              blng__InvoiceDate__c, blng__DueDate__c, 
                              Name,IsDataLoaded__c,RecordType.developerName 
                              From blng__Invoice__c 
                              where blng__Account__c =: accid and (blng__PaymentStatus__c = 'Unpaid' OR
                                                                           blng__PaymentStatus__c = 'Partially Paid')
                              and blng__InvoiceStatus__c = 'Posted'
                              
                              order by CreatedDate ASC]; //<T01
                              system.debug('accUnpaidInvcsList'+accUnpaidInvcsList);
    }
    
    public class InvoicePaymentWrapper{
        
        public blng__Payment__c payment{get;set;}
        public blng__Invoice__c invoice{get;set;}
        public Id Ipid{get;set;}
        public String IPType{get;set;}
        public String Name{get;set;}
        public Date IPDate{get;set;}
        public String TotalInvoiceValue{get;set;}
        public String TotalPayment{get;set;}
        public String UnPaidAmount{get;set;}
        public String PaymentStatus{get;set;}
        public String PaymentType{get;set;}
        public String RecordTypeName{get;set;}
        public String isdataLoaded{get;set;}
        // Wrapper class constructor
        
        public InvoicePaymentWrapper(id Ipid,String IPType,String Name,Date IPDate,String TotalInvoiceValue,String TotalPayment,String UnPaidAmount,String PaymentStatus,String PaymentType,String RecordTypeName,String isdataLoaded){
            
            this.Ipid=Ipid;
            this.IPType=IPType;
            this.Name=Name;
            this.IPDate=IPDate;
            this.TotalInvoiceValue=TotalInvoiceValue;
            this.TotalPayment=TotalPayment;
            this.PaymentStatus=PaymentStatus;
            this.UnPaidAmount=UnPaidAmount;
            this.PaymentType=PaymentType;
            this.RecordTypeName = RecordTypeName;
            this.isdataLoaded =isdataLoaded;
            
        }
        
    }
    
    public static void myPaymentTypes(id accid){
        
        creditCardList = new List<blng__PaymentMethod__c>();
        bankTransferList = new List<blng__PaymentMethod__c>();
        List<blng__PaymentMethod__c> localcreditCardList = new List<blng__PaymentMethod__c>();

        
        //Get Credit Card list for account 
        localcreditCardList = [Select Id,blng__Nameoncard__c,blng__AutoPay__c,blng__Active__c, blng__CardType__c, blng__CardNumber__c, 
                                                            blng__CardExpirationYear__c, blng__CVV__c, blng__CardExpirationMonth__c, blng__Account__c,blng__BillingFax__c, blng__Account__r.Name,
                                                            blng__BillingPhone__c,blng__BillingZipPostal__c,blng__BillingStateProvince__c,blng__BillingAddress__c,blng__BillingCity__c,
                                                            blng__BillingCompany__c,blng__BillingCountry__c,blng__BillingEmail__c,blng__BillingFirstName__c,blng__BillingLastName__c,
                                                            blng__PaymentGateway__c,blng__BankAccountName__c,blng__BankName__c,blng__BankRoutingCode__c,blng__BankAccountType__c,(select id, Name,
                                              blng__ResponseStatus__c,
                                              createdDate
                                              From blng__PaymentMethodTransactions__r
                                              order by createdDate DESC LIMIT 1 ),
                                                            blng__BankAccountNumber__c
                                                            From blng__PaymentMethod__c
                                     
                                      where blng__Account__c =: accid and blng__PaymentType__c = 'Credit Card'];
        for(blng__PaymentMethod__c paymentMethod :localcreditCardList  ){
           if((paymentMethod.blng__PaymentMethodTransactions__r == null || 
           paymentMethod.blng__PaymentMethodTransactions__r.size() == 0) && (paymentMethod.blng__Active__c == true)){
               creditCardList.add(paymentMethod );
           }
            else if((paymentMethod.blng__Active__c == true) && paymentMethod.blng__PaymentMethodTransactions__r.size() > 0 && paymentMethod.blng__PaymentMethodTransactions__r[0].blng__ResponseStatus__c =='Approved'){
                creditCardList.add(paymentMethod ); 
            }
        }                              
        
        bankTransferList = [Select Id,  Name , blng__BankAccountName__c,blng__BankName__c,blng__BankRoutingCode__c,blng__BankAccountType__c, 
                            blng__BankAccountNumber__c,blng__AutoPay__c,
                            blng__Account__c 
                            From blng__PaymentMethod__c 
                            where blng__Account__c =: accid and blng__PaymentType__c = 'ACH'];
        
        
    }
    
    public void deleteInvoice(){
        
        /*system.debug('@@@@todeleteInvId'+ todeleteInvId);
        blng__PaymentMethod__c singleInv = [select id 
                                                    from blng__PaymentMethod__c
                                                    where id =: todeleteInvId
                                                   ];
        
        delete singleInv;
        PageReference mainPage = Page.MDL_invoice_detail_page;
        mainPage.setRedirect(true);
        mainPage.getParameters().put('id',accountId);
        return mainPage;*/
        //return null;
        
    }
    
    @RemoteAction
    public static void deleteinv(Id invid) {
        delete new blng__PaymentMethod__c(Id = invid);
    }
    
     @RemoteAction
    public static pageReference downloadinv(Id invid) {
       
        system.debug('@@in downloadinv');
        String folderurl = '';
        
        //calling webservice class to get url
        folderurl =  Portal_createInvoiceFolderPath.createInvoiceFolderPath(invid);
        if(folderurl !=''){
            PageReference ref = new PageReference(folderurl);
            ref.setRedirect(true);
            system.debug('@@@@folderurl in class'+ folderurl);
            return ref;
        }
        else{
            return null;
        }
    }
   
     public PageReference openHelp(){
         List<Document> lstDocument = [Select id, Name from Document where Name = 'CSC Pay Now Help 9.4.15' limit 1];
         PageReference ret = null;
       string helpURL = '';
       
            helpURL = system.label.SMB_Portal +'/servlet/servlet.FileDownload?file='+lstDocument[0].Id;
       
        ret = new PageReference(helpURL);
        ret.setRedirect(true);
        return ret ;  
    }
}
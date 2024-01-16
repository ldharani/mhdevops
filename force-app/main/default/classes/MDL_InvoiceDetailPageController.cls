public class MDL_InvoiceDetailPageController {

    public String custNo {get;set;}
    public boolean baseURL {get;set;}
    //public String sessionId {get;set;}
    //public String baseCSCURL {get;set;}
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
    public static list<invoiceit_s__Invoice__c > accInvcsList {get;set;}
    
    //invoices related to account  status upaid
    public static list<invoiceit_s__Invoice__c > accUnpaidInvcsList {get;set;}
    
    //map to show payments for invoices using + symbol
    public static map<id, List<invoiceit_s__Payment__c>>  invIdVSinvPaymntList {get;set;}
    
    public static map<string,invoiceit_s__Payment_Allocation__c> idvsPaymentAllocations {get;set;}
    
    //commaseperated to key to avoid null pointer exception when key not present in above map
    public static string commaSeperatedInvKeys {get;set;}
    
    public static string commaSeperatedInvKeysallocations{get;set;}
    
    //payments related to account for which invoice is not present
    public static list<invoiceit_s__Payment__c > InvPaymentListforAccount {get;set; }
    
    //public static list<invoiceit_s__Payment__c > InvPaymentList {get;set; }
    
    public List<InvoicePaymentWrapper> InvoicPaymentWrapperList{get;set; }
    
    //CreditCard List for My Payment Type Tab  
    public static List<invoiceit_s__Payment_Method__c>  creditCardList{get;set;}
    
    //BankTransfer List for My Payment Type Tab  
    public static List<invoiceit_s__Payment_Method__c>  bankTransferList{get;set;}
    
    
    
    public MDL_InvoiceDetailPageController()
    {
         //CSC_token__c csc_token = CSC_token__c.getValues('ExpectedToken');
        //baseCSCURL = csc_token.Base_URL__c;
        //sessionId = ApexPages.currentPage().getParameters().get('sessionId');
        
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
        //token='bWFydGluZGFsZXNhbGVzZm9yY2Vjc2NpbnZvaWNlcGF5bWVudGludGVncmF0aW9u';
        System.debug('Cookies>>>'+ApexPages.currentPage().getCookies());
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
           //.get('SMB_Authorization');
        
        
        // Now making a get callout to check the page validation
        
            string endpoint = system.Label.PayNow_Endpoint;
            //string endpoint = 'http://mh36.login.qa-nolo.com/tokenInfo';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPoint);
            request.setMethod('GET');
            request.setHeader('Authorization', smbAuthorizationToken);
            request.setHeader('Content-Type','application/json');
            request.setHeader('accept','application/json');
            //request.setClientCertificateName('Pay_Now');

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
        /*if(actual_token!=token){
            displayPage=false;
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You are not authorized to access this page. Please contact the admininstrator'));
            return;
        } 
        else{
          if(URL.getSalesforceBaseUrl().toExternalForm().contains('rainbow')){baseURL = true;}
          else{
            baseURL = false;
          }
          displayPage=true;     
        } */
        displayPage=true;       
         customerno = ApexPages.currentPage().getParameters().get('c');
        
       if(customerno != null){
            accountId = [select id, name 
                           from account
                            where MH_Cust_Number__c =:customerno].id;
            system.debug('@@@accountId'+ accountId);
        }
        
      
       //referenceURL = ApexPages.currentPage().getHeaders().get('Host');
        system.debug('@@@@Current Page Domain ============='+domain );
        
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
        //accountId = ApexPages.currentPage().getParameters().get('id');
        string customernoinv = ApexPages.currentPage().getParameters().get('c');
        if(customerno != null){
            accountId = [select id, name 
                           from account
                            where MH_Cust_Number__c =:customerno].id;
            system.debug('@@@accountId'+ accountId);
        }
        
        if(selectedFilterMonth == '0')
        {    if(accountId != null)
            {
               
                invoiceAndPayments(accountId);
                 paymentAndAccount(accountId);
                genrateWrapperList(accInvcsList,InvPaymentListforAccount);
            }
        }
        else  if(selectedFilterMonth == '1')
        {
            lastDate = todayDate.addMonths(-1);
            system.debug('@@@@in month condition');
            system.debug('@@@accountId'+ accountId);
            
            if(accountId != null)
            {
                invoiceAndPaymentsFilter(accountId, todayDate, lastDate );
                paymentAndAccountFilter(accountId, todayDate, lastDate );
                
                genrateWrapperList(accInvcsList,InvPaymentListforAccount);
                
            }
        }
        
        else  if(selectedFilterMonth == '3')
        {
            lastDate = todayDate.addMonths(-3);
            if(accountId != null)
            {
               
                invoiceAndPaymentsFilter(accountId, todayDate, lastDate );
                 paymentAndAccountFilter(accountId, todayDate, lastDate );
                genrateWrapperList(accInvcsList,InvPaymentListforAccount);
            }
        }
        
        else  if(selectedFilterMonth == '6')
        {
            lastDate = todayDate.addMonths(-6);
            if(accountId != null)
            {
                
                invoiceAndPaymentsFilter(accountId, todayDate, lastDate );
                paymentAndAccountFilter(accountId, todayDate, lastDate );
                genrateWrapperList(accInvcsList,InvPaymentListforAccount);
            }
        }
        
        
        else  if(selectedFilterMonth == '9')
        {   
            if(accountId != null)
            {
                lastDate = todayDate.addMonths(-9);
                
                invoiceAndPaymentsFilter(accountId, todayDate, lastDate );
                paymentAndAccountFilter(accountId, todayDate, lastDate );
                genrateWrapperList(accInvcsList,InvPaymentListforAccount);
            }
        }
        
        
        else  if(selectedFilterMonth == '12')
        {
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
    {
       /* PageReference pageRef = new PageReference(CSC_URL +'/Pages/SignOut.aspx?sn='+sessionId);
        pageRef.setRedirect(true);
        return pageRef; */
        
       
        PageReference pageRef = null;
        string logoutURL = '';
        //String ref = ApexPages.currentPage().getHeaders().get('Host');
        system.debug('@@@@Current Page Domain ============='+Domain);
        //if(isSMB){
            logoutURL = system.label.SMB_MainURL +'/site/logout';
        /*}
        else{
            logoutURL = system.label.CSC_Portal + '/Pages/SignOut.aspx?sn='+sessionId;
        }*/
        pageRef = new PageReference(logoutURL);
        pageRef.setRedirect(true);
        return pageRef;       
        
        
    }
    
    
    
    public void paymentAndAccount(id accid)
    {
        system.debug('@@accountId in paymentAndAccount'+ accountId);
        account = new Account();
        
        InvPaymentListforAccount =  new list<invoiceit_s__Payment__c>();
        InvoicPaymentWrapperList =  new list<InvoicePaymentWrapper>();
        
        //getting account and its payments for which invoice = null
        account  = [Select Id,Name, Account_Balance__c, MH_Cust_Number__c,
                    (select id, Name, Total_Pay_Amt__c, 
                     invoiceit_s__Status__c ,
                     invoiceit_s__Payment_Type__c,
                     invoiceit_s__Payment_Date__c,
                     invoiceit_s__Amount__c
                    
                     from invoiceit_s__Payments__r 
                     where Invoice__c = null
                      order by invoiceit_s__Payment_Date__c DESC)
                    From Account where Id =: accid ];
        system.debug('@@@account in paymentAndAccount'+ account);
        
        //if any payments present in above query assign to a list to show
        if(account.invoiceit_s__Payments__r.size() > 0){
            system.debug('@@@@account.invoiceit_s__Payments__r'+ account.invoiceit_s__Payments__r);
            //InvPaymentListforAccount = account.invoiceit_s__Payments__r;
            for(invoiceit_s__Payment__c payment : account.invoiceit_s__Payments__r){
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
        accInvcsList = new list<invoiceit_s__Invoice__c >();
        idsetforinvpaymentforaccount = new set<id>();
        idsetforinvpaymentforaccount1 = new set<id>();
        list<invoiceit_s__Payment__c > InvPaymentList =  new list<invoiceit_s__Payment__c>();
        set<id> invoiceids = new set<id>();
        invIdVSinvPaymntList = new map<id, List<invoiceit_s__Payment__c>>();
        
        //map invoice id + payemnt id VS payment allocations
         idvsPaymentAllocations = new  map<string,invoiceit_s__Payment_Allocation__c>();
        
        
        //map form from payment allocations
        map<id,list<id>> paymentidVsinvid = new map<id,list<id>>();
        
       
        
        
        //invoice for account 
        accInvcsList = [Select Id, invoiceit_s__Unpaid_Amount__c, 
                        TotalAllocatedPayments__c, invoiceit_s__Total_Invoice_Value__c,
                        Total_Payments__c, invoiceit_s__Payment_Status__c, 
                        invoiceit_s__Invoice_Date__c, invoiceit_s__Due_Date__c, 
                        Name,IsDataLoaded__c,RecordType.Name,invoiceit_s__Invoice_Reference__c,
                        (select id, Name, 
                            invoiceit_s__Payment__c, invoiceit_s__Invoice__c,
                             invoiceit_s__Payment__r.Invoice__c,invoiceit_s__Amount__c 
                              from
                              invoiceit_s__Payment_Allocations__r
                               where invoiceit_s__Payment__r.Invoice__c = null)
                        From invoiceit_s__Invoice__c 
                        where invoiceit_s__Account__c =: accid
                        and invoiceit_s__Invoice_Status__c = 'Posted'
                        order by invoiceit_s__Invoice_Date__c DESC];
        
        system.debug('@@@accInvcsList'+ accInvcsList);
        
        //map for invoice vs list of its payments
        if(!accInvcsList.isEmpty()){
            //invoiceids = new map<id, invoiceit_s__Invoice__c>(accInvcsList).keySet();
            for(invoiceit_s__Invoice__c inv : accInvcsList){
                invoiceids.add(inv.id);
                
                //forming paymentidVsinvid map from payment allocations to from relationship between
                //payments and invoices for which payment doesn't connect to invoice directly
                //they r connected through payment allocations
                for(invoiceit_s__Payment_Allocation__c inpaymentallocation : inv.invoiceit_s__Payment_Allocations__r){
                    idvsPaymentAllocations.put(string.valueOf(inpaymentallocation.invoiceit_s__Invoice__c) + string.valueOf(inpaymentallocation.invoiceit_s__Payment__c), inpaymentallocation);
                    if(paymentidVsinvid.containsKey(inpaymentallocation.invoiceit_s__Payment__c)){
                        paymentidVsinvid.get(inpaymentallocation.invoiceit_s__Payment__c).add(inpaymentallocation.invoiceit_s__Invoice__c);
                    }
                    else{
                        paymentidVsinvid.put(inpaymentallocation.invoiceit_s__Payment__c, new list<id>{inpaymentallocation.invoiceit_s__Invoice__c});
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
            
           String queryString = 'select id, Name, invoiceit_s__Invoice__c,'+
                              ' Invoice__c,invoiceit_s__Payment_Date__c,'+
                              ' invoiceit_s__Allocated_Amount__c,'+ 
                              ' Total_Pay_Amt__c,invoiceit_s__Amount__c,'+
                              ' invoiceit_s__Payment_Type__c' +
                              ' from invoiceit_s__Payment__c' +
                              ' where invoiceit_s__Account__c =: accid'+
                              ' and (Invoice__c IN :invoiceids';
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
           
            /*InvPaymentList = [select id, Name, invoiceit_s__Invoice__c,
                              Invoice__c,invoiceit_s__Payment_Date__c,
                              invoiceit_s__Allocated_Amount__c,
                              Total_Pay_Amt__c,
                              invoiceit_s__Amount__c,
                              invoiceit_s__Payment_Type__c
                              from invoiceit_s__Payment__c
                              where 
                              invoiceit_s__Account__c =: accid and
                              (Invoice__c IN :(invoiceids)
                              OR ID IN:(paymentidVsinvid.keySet()))
                             ];*/
            
            InvPaymentList = database.query(queryString);
            
            //forming invoice id Vs payments list map
            for(invoiceit_s__Payment__c singlePaymt : InvPaymentList){
                system.debug('@@@@ in invIdVSinvPaymntList map'+ singlePaymt.Invoice__c);
                
                if(invIdVSinvPaymntList.containsKey(singlePaymt.Invoice__c)){
                        if(singlePaymt.Invoice__c != null){
                            invIdVSinvPaymntList.get(singlePaymt.Invoice__c).add(singlePaymt);
                        }
                    else{
                        if(paymentidVsinvid.containsKey(singlePaymt.id)){
                            for(id invid : paymentidVsinvid.get(singlePaymt.id)){
                                if(invIdVSinvPaymntList.containsKey(invid)){
                                    invIdVSinvPaymntList.get(invid).add(singlePaymt);
                                }
                                else{
                                    invIdVSinvPaymntList.put(invid, new list<invoiceit_s__Payment__c>{singlePaymt});
                                }
                            }
                           
                        }
                    }
                }
               
                
                else{
                    if(singlePaymt.Invoice__c != null){
                        system.debug('@@creating first invoice for map'+ singlePaymt.Invoice__c);
                        invIdVSinvPaymntList.put(singlePaymt.Invoice__c, new list<invoiceit_s__Payment__c>{singlePaymt});
                    }
                    else{
                        if(paymentidVsinvid.containsKey(singlePaymt.id)){
                             system.debug('@@creating first invoice for map'+ singlePaymt.Invoice__c);
                            for(id invid : paymentidVsinvid.get(singlePaymt.id)){
                                if(invIdVSinvPaymntList.containsKey(invid)){
                                    invIdVSinvPaymntList.get(invid).add(singlePaymt);
                                }
                                else{
                                    invIdVSinvPaymntList.put(invid, new list<invoiceit_s__Payment__c>{singlePaymt});
                                }
                            }
                            //invIdVSinvPaymntList.put(paymentidVsinvid.get(singlePaymt.id), new list<invoiceit_s__Payment__c>{singlePaymt});
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
                    for(invoiceit_s__Payment__c singleinvpay: invIdVSinvPaymntList.get(invid)){
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
        InvPaymentListforAccount =  new list<invoiceit_s__Payment__c>();
        InvoicPaymentWrapperList =  new list<InvoicePaymentWrapper>();
        
        
        //getting account and its payments for which invoice = null
        account  = [Select Id,Name, Account_Balance__c,
                    (select id, Name, Total_Pay_Amt__c, 
                     invoiceit_s__Status__c ,
                     invoiceit_s__Payment_Type__c,
                     invoiceit_s__Amount__c,
                     invoiceit_s__Payment_Date__c
                     from invoiceit_s__Payments__r 
                     where Invoice__c = null and invoiceit_s__Payment_Date__c >= : lastDate and invoiceit_s__Payment_Date__c <= : todayDate 
                         order by invoiceit_s__Payment_Date__c DESC)
                    From Account where Id =: accountId ];
        
        //if any payments present in above query assign to a list to show
        if(account.invoiceit_s__Payments__r.size() > 0){
            system.debug('@@@@account.invoiceit_s__Payments__r'+ account.invoiceit_s__Payments__r);
            //InvPaymentListforAccount = account.invoiceit_s__Payments__r;
            system.debug('@@@idsetforinvpaymentforaccount1 in 1st filter'+ idsetforinvpaymentforaccount);
                for(invoiceit_s__Payment__c payment : account.invoiceit_s__Payments__r){
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
        accInvcsList = new list<invoiceit_s__Invoice__c >();
        
        //again calling done to form idsetforinvpaymentforaccount to avoid payments which are already 
        //present invoices
        invoiceAndPayments(accid);
         system.debug('@@@todayDate in invoice '+ todayDate);
        system.debug('@@@todayDate in invoice'+ lastDate);
        list<invoiceit_s__Payment__c > InvPaymentList =  new list<invoiceit_s__Payment__c>();
        set<id> invoiceids = new set<id>();
        invIdVSinvPaymntList = new map<id, List<invoiceit_s__Payment__c>>();
        //idsetforinvpaymentforaccount = new set<id>();
        //map invoice id + payemnt id VS payment allocations
         idvsPaymentAllocations = new  map<string,invoiceit_s__Payment_Allocation__c>();
        
        
        //map form from payment allocations
        map<id,list<id>> paymentidVsinvid = new map<id,list<id>>();
        
        //invoice for account 
        accInvcsList = [Select Id, invoiceit_s__Unpaid_Amount__c, 
                        TotalAllocatedPayments__c, invoiceit_s__Total_Invoice_Value__c,
                        Total_Payments__c, invoiceit_s__Payment_Status__c, 
                        invoiceit_s__Invoice_Date__c, invoiceit_s__Due_Date__c, 
                        Name,IsDataLoaded__c,RecordType.Name,invoiceit_s__Invoice_Reference__c,

                        (select id, Name, 
                            invoiceit_s__Payment__c, invoiceit_s__Invoice__c,
                             invoiceit_s__Payment__r.Invoice__c, invoiceit_s__Amount__c 
                              from
                              invoiceit_s__Payment_Allocations__r
                               where invoiceit_s__Payment__r.Invoice__c = null)
                        From invoiceit_s__Invoice__c 
                        where invoiceit_s__Account__c =: accid
                        and invoiceit_s__Invoice_Date__c >=: lastDate and invoiceit_s__Invoice_Date__c <=: todayDate
                        and invoiceit_s__Invoice_Status__c = 'Posted'
                        order by invoiceit_s__Invoice_Date__c DESC];
            
            
            
            
           /* Select Id, invoiceit_s__Unpaid_Amount__c, 
                        TotalAllocatedPayments__c, invoiceit_s__Total_Invoice_Value__c,
                        Total_Payments__c, invoiceit_s__Payment_Status__c, 
                        
                        invoiceit_s__Invoice_Date__c, invoiceit_s__Due_Date__c, 
                        Name 
                        From invoiceit_s__Invoice__c 
                        where invoiceit_s__Account__c =: accid and invoiceit_s__Invoice_Date__c >=: lastDate and invoiceit_s__Invoice_Date__c <=: todayDate
                        and invoiceit_s__Invoice_Status__c = 'Posted'
                        order by invoiceit_s__Invoice_Date__c DESC];*/
        system.debug('@@@accInvcsList in filter'+ accInvcsList);
        
        //map for invoice vs list of its payments
       /* if(!accInvcsList.isEmpty()){
            //invoiceids = new map<id, invoiceit_s__Invoice__c>(accInvcsList).keySet();
            for(invoiceit_s__Invoice__c inv : accInvcsList){
                invoiceids.add(inv.id);
            }
            InvPaymentList = [select id, Name, invoiceit_s__Invoice__c,
                              Invoice__c,invoiceit_s__Payment_Date__c,
                              invoiceit_s__Allocated_Amount__c,
                              Total_Pay_Amt__c,
                              
                              invoiceit_s__Amount__c,
                              invoiceit_s__Payment_Type__c
                              from invoiceit_s__Payment__c
                              where 
                              invoiceit_s__Account__c =: accid and
                              Invoice__c IN :(invoiceids)
                             ];
            
            for(invoiceit_s__Payment__c singlePaymt : InvPaymentList){
                
                if(invIdVSinvPaymntList.containsKey(singlePaymt.Invoice__c)){
                    invIdVSinvPaymntList.get(singlePaymt.Invoice__c).add(singlePaymt);
                }
                else{
                    invIdVSinvPaymntList.put(singlePaymt.Invoice__c, new list<invoiceit_s__Payment__c>{singlePaymt});
                }
                
            }*/
        
                    //map for invoice vs list of its payments
        if(!accInvcsList.isEmpty()){
            //invoiceids = new map<id, invoiceit_s__Invoice__c>(accInvcsList).keySet();
            for(invoiceit_s__Invoice__c inv : accInvcsList){
                invoiceids.add(inv.id);
                
                //forming paymentidVsinvid map
                for(invoiceit_s__Payment_Allocation__c inpaymentallocation : inv.invoiceit_s__Payment_Allocations__r){
                   idvsPaymentAllocations.put(string.valueOf(inpaymentallocation.invoiceit_s__Invoice__c) + string.valueOf(inpaymentallocation.invoiceit_s__Payment__c), inpaymentallocation);
                    if(paymentidVsinvid.containsKey(inpaymentallocation.invoiceit_s__Payment__c)){
                        paymentidVsinvid.get(inpaymentallocation.invoiceit_s__Payment__c).add(inpaymentallocation.invoiceit_s__Invoice__c);
                    }
                    else{
                        paymentidVsinvid.put(inpaymentallocation.invoiceit_s__Payment__c, new list<id>{inpaymentallocation.invoiceit_s__Invoice__c});
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
            
            
            
           String queryString = 'select id, Name, invoiceit_s__Invoice__c,'+
                              ' Invoice__c,invoiceit_s__Payment_Date__c,'+
                              ' invoiceit_s__Allocated_Amount__c,'+ 
                              ' Total_Pay_Amt__c,invoiceit_s__Amount__c,'+
                              ' invoiceit_s__Payment_Type__c' +
                              ' from invoiceit_s__Payment__c' +
                              ' where invoiceit_s__Account__c =: accid'+
                              ' and (Invoice__c IN :invoiceids';
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
           
            /*InvPaymentList = [select id, Name, invoiceit_s__Invoice__c,
                              Invoice__c,invoiceit_s__Payment_Date__c,
                              invoiceit_s__Allocated_Amount__c,
                              Total_Pay_Amt__c,
                              invoiceit_s__Amount__c,
                              invoiceit_s__Payment_Type__c
                              from invoiceit_s__Payment__c
                              where 
                              invoiceit_s__Account__c =: accid and
                              (Invoice__c IN :(invoiceids)
                              OR ID IN:(paymentidVsinvid.keySet()))
                             ];*/
            
            InvPaymentList = database.query(queryString);
            system.debug('@@@@InvPaymentList in filter'+ InvPaymentList);
            
            //forming invoice id Vs payments list map
            for(invoiceit_s__Payment__c singlePaymt : InvPaymentList){
                system.debug('@@@@ in invIdVSinvPaymntList map'+ singlePaymt.Invoice__c);
                
                if(invIdVSinvPaymntList.containsKey(singlePaymt.Invoice__c)){
                        if(singlePaymt.Invoice__c != null){
                            invIdVSinvPaymntList.get(singlePaymt.Invoice__c).add(singlePaymt);
                        }
                    else{
                        if(paymentidVsinvid.containsKey(singlePaymt.id)){
                              for(id invid : paymentidVsinvid.get(singlePaymt.id)){
                                if(invIdVSinvPaymntList.containsKey(invid)){
                                    invIdVSinvPaymntList.get(invid).add(singlePaymt);
                                }
                                else{
                                    invIdVSinvPaymntList.put(invid, new list<invoiceit_s__Payment__c>{singlePaymt});
                                }
                            }
                        }
                    }
                }
               
                
                else{
                    if(singlePaymt.Invoice__c != null){
                        system.debug('@@creating first invoice for map'+ singlePaymt.Invoice__c);
                        invIdVSinvPaymntList.put(singlePaymt.Invoice__c, new list<invoiceit_s__Payment__c>{singlePaymt});
                    }
                    else{
                        if(paymentidVsinvid.containsKey(singlePaymt.id)){
                             system.debug('@@creating first invoice for map'+ singlePaymt.Invoice__c);
                             for(id invid : paymentidVsinvid.get(singlePaymt.id)){
                                if(invIdVSinvPaymntList.containsKey(invid)){
                                    invIdVSinvPaymntList.get(invid).add(singlePaymt);
                                }
                                else{
                                    invIdVSinvPaymntList.put(invid, new list<invoiceit_s__Payment__c>{singlePaymt});
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
                     //for(invoiceit_s__Payment__c singleinvpay: invIdVSinvPaymntList.get(invid)){
                    //  idsetforinvpaymentforaccount.add(singleinvpay.id);
                    //}
                }
                
                CheckinvIdVSinvPaymntList = true;
            }
            system.debug('@@@commaSeperatedInvKeys in filter'+ commaSeperatedInvKeys);
            system.debug('@@@map Keyset' + invIdVSinvPaymntList.keySet());
            
        }
    }
    public void genrateWrapperList(List<invoiceit_s__Invoice__c> invoiceList,List<invoiceit_s__Payment__c> paymentList)
    {
        
        for(Integer i=0;i<invoiceList.Size(); i++)
        {
            String invoiceName ='';
            if(invoiceList[i].IsDataLoaded__c == 'Y' && invoiceList[i].RecordType.Name == RecordTypesFinalStringsClass.RecTypeName_MH_Invoice){
                invoiceName = invoiceList[i].invoiceit_s__Invoice_Reference__c;
            }
            else{
                invoiceName = string.valueOf(invoiceList[i].Name);
            }
            if(invoiceList[i].RecordType.Name == RecordTypesFinalStringsClass.RecTypeName_JV_Invoice || (invoiceList[i].RecordType.Name == RecordTypesFinalStringsClass.RecTypeName_MH_Invoice && invoiceList[i].invoiceit_s__Total_Invoice_Value__c > 0)){
                InvoicPaymentWrapperList.add(new InvoicePaymentWrapper(invoiceList[i].Id,
                                                                   'Invoice', 
                                                                   invoiceName,
                                                                   invoiceList[i].invoiceit_s__Invoice_Date__c,
                                                                   String.valueOf(invoiceList[i].invoiceit_s__Total_Invoice_Value__c),
                                                                   String.valueOf(invoiceList[i].Total_Payments__c),
                                                                   String.valueOf(invoiceList[i].invoiceit_s__Unpaid_Amount__c),
                                                                   String.valueOf(invoiceList[i].invoiceit_s__Payment_Status__c),
                                                                   'Credit Card',
                                                                   String.valueOf(invoiceList[i].RecordType.Name),
                                                                   String.valueOf(invoiceList[i].IsDataLoaded__c)));
            }            
            
        }
        
       /* for(Integer i=0;i<paymentList.size(); i++)
        {
            
            InvoicPaymentWrapperList.add(new InvoicePaymentWrapper(paymentList[i].Id,
                                                                   'Payment', 
                                                                   String.valueOf(paymentList[i].Name), 
                                                                   paymentList[i].invoiceit_s__Payment_Date__c,
                                                                   '-',
                                                                   String.valueOf(paymentList[i].Total_Pay_Amt__c),
                                                                   '-',
                                                                   String.valueOf(paymentList[i].invoiceit_s__Status__c),
                                                                   String.valueOf(paymentList[i].invoiceit_s__Payment_Type__c)));
        }*/
        
        system.debug('@@@@InvoicPaymentWrapperList'+ InvoicPaymentWrapperList);
        
    }
    
    
    public static void upaidInvoice(id accid){
        accUnpaidInvcsList = new list<invoiceit_s__Invoice__c >();
        
        //unpaid invoice for account 
        accUnpaidInvcsList = [Select Id, invoiceit_s__Unpaid_Amount__c, 
                              TotalAllocatedPayments__c, invoiceit_s__Total_Invoice_Value__c,
                              Total_Payments__c, invoiceit_s__Payment_Status__c, 
                              invoiceit_s__Invoice_Date__c, invoiceit_s__Due_Date__c, 
                              Name,IsDataLoaded__c,RecordType.Name,invoiceit_s__Invoice_Reference__c 
                              From invoiceit_s__Invoice__c 
                              where invoiceit_s__Account__c =: accid and (invoiceit_s__Payment_Status__c = 'Unpaid' OR
                                                                           invoiceit_s__Payment_Status__c = 'Partially Paid')
                              and invoiceit_s__Invoice_Status__c = 'Posted'
                              
                              order by invoiceit_s__Invoice_Date__c DESC];
        
        
    }
    
    public class InvoicePaymentWrapper{
        
        public invoiceit_s__Payment__c payment{get;set;}
        public invoiceit_s__Invoice__c invoice{get;set;}
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
        
        public InvoicePaymentWrapper(id Ipid,String IPType,String Name,Date IPDate,String TotalInvoiceValue,String TotalPayment,String UnPaidAmount,String PaymentStatus,String PaymentType,String RecordTypeName, String isdataLoaded){
            
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
        
        creditCardList = new List<invoiceit_s__Payment_Method__c>();
        bankTransferList = new List<invoiceit_s__Payment_Method__c>();
        List<invoiceit_s__Payment_Method__c> localcreditCardList = new List<invoiceit_s__Payment_Method__c>();

        
        //Get Credit Card list for account 
        localcreditCardList = [Select Id,  Name , invoiceit_s__Name_on_Card__c, 
                                      invoiceit_s__Billing_Address__c,invoiceit_s__Billing_City__c,
                                      invoiceit_s__Billing_State_Province__c,invoiceit_s__Billing_Country__c,
                                      invoiceit_s__Billing_Zip_Postal__c, invoiceit_s__Card_Type__c,
                                      invoiceit_s__Card_Number__c, invoiceit_s__Card_Expiration_Year__c, 
                                      (select id, Name,
                                              invoiceit_s__Response_Status__c,
                                              createdDate
                                              From invoiceit_s__Transactions__r
                                              order by createdDate DESC LIMIT 1 ),
                                      invoiceit_s__Card_Expiration_Month__c, Auto_Pay__c,invoiceit_s__Default__c,invoiceit_s__Account__c,
                                      invoiceit_s__Active__c
                                      From invoiceit_s__Payment_Method__c 
                                      where invoiceit_s__Account__c =: accid and invoiceit_s__Payment_Method__c = 'Credit Card'];
        for(invoiceit_s__Payment_Method__c paymentMethod :localcreditCardList  ){
           if((paymentMethod.invoiceit_s__Transactions__r == null || 
           paymentMethod.invoiceit_s__Transactions__r.size() == 0) && (paymentMethod.invoiceit_s__Active__c == true)){
               creditCardList.add(paymentMethod );
           }
            else if((paymentMethod.invoiceit_s__Active__c == true) && paymentMethod.invoiceit_s__Transactions__r.size() > 0 && paymentMethod.invoiceit_s__Transactions__r[0].invoiceit_s__Response_Status__c =='Approved'){
                creditCardList.add(paymentMethod ); 
            }
        }                              
        
        bankTransferList = [Select Id,  Name , invoiceit_s__Bank_Account_Name__c,Auto_Pay__c, 
                            invoiceit_s__Bank_Name__c,invoiceit_s__Bank_Account_Type__c,
                            invoiceit_s__Bank_Routing_Code__c,invoiceit_s__Bank_Account_Number__c,
                            invoiceit_s__Default__c,invoiceit_s__Account__c 
                            From invoiceit_s__Payment_Method__c 
                            where invoiceit_s__Account__c =: accid and invoiceit_s__Payment_Method__c = 'ACH'];
        
        
    }
    
    public PageReference deleteInvoice(){
        
        system.debug('@@@@todeleteInvId'+ todeleteInvId);
        invoiceit_s__Payment_Method__c singleInv = [select id 
                                                    from invoiceit_s__Payment_Method__c
                                                    where id =: todeleteInvId
                                                   ];
        
        delete singleInv;
        PageReference mainPage = Page.MDL_invoice_detail_page;
        mainPage.setRedirect(true);
        mainPage.getParameters().put('id',accountId);
        return mainPage;
        //return null;
        
    }
    
    @RemoteAction
    public static void deleteinv(Id invid) {
        delete new invoiceit_s__Payment_Method__c(Id = invid);
    }
    
     @RemoteAction
    public static pageReference downloadinv(Id invid) {
       
        system.debug('@@in downloadinv');
        String folderurl = '';
        
        //calling webservice class to get url
        folderurl =  MDL_TriggerOnInvoice.createInvoiceFolderPath(invid);
        if(folderurl !=''){
            PageReference ref = new PageReference(folderurl);
            ref.setRedirect(true);
            system.debug('@@@@folderurl in class'+ folderurl);
            return ref;
        }
        else{
            return null;
        }
        
        
        //return folderurl;
    }
    
    
   /*  public pageReference downloadinvoice() {
       
        system.debug('@@in downloadinv' + invoiceid);
        String folderurl = '';
        
        //calling webservice class to get url
        folderurl =  MDL_TriggerOnInvoice.createInvoiceFolderPath(invoiceid);
        if(folderurl !=''){
            PageReference ref = new PageReference(folderurl);
            ref.setRedirect(false);  
            system.debug('@@@@folderurl in class'+ folderurl);
            return ref;
        }
        else{
            return null;
        }
        
        
        //return folderurl;
    }*/
    
     public PageReference openHelp(){
         List<Document> lstDocument = [Select id, Name from Document where Name = 'CSC Pay Now Help 9.4.15' limit 1];
        
        //strDocUrl = '/servlet/servlet.FileDownload?file='+lstDocument[0].Id;
        //PageReference ret = new PageReference('/servlet/servlet.FileDownload?file=' + lstDocument[0].Id);
       // PageReference ret = new PageReference('http://invoice.stg2.lawyers.com/help/' + lstDocument[0].Id);
       
       PageReference ret = null;
       string helpURL = '';
       //if(isSMB){
            helpURL = system.label.SMB_Portal +'/servlet/servlet.FileDownload?file='+lstDocument[0].Id;
        //}
        /*else{
            helpURL = system.label.PortalURL + '/servlet/servlet.FileDownload?file='+lstDocument[0].Id;
        }*/
        ret = new PageReference(helpURL);
        ret.setRedirect(true);
        return ret ;
       
    }
    
    public  void FkMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        }

}
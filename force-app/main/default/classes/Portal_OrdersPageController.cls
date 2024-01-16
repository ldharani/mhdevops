public  class Portal_OrdersPageController { 
    public String custNo {get;set;}
    public boolean baseURL {get;set;}
    public String formSubmitCSCURL {get;set;}
    public String token {get;set;}
    public boolean displayPage {get;set;}   
    public Map<String,String> entireHeader {get; set;} 
    public String baseCSCURL {get;set;}
    public String sessionId {get;set;}
    public Account account{get;set;}    
    public string customerno{get;set;}
    public String orderNumber{get;set;}
    public boolean isSMB{get;set;}
    public Id accountId{get;set;}
    public integer offsetno;
    private integer noofRecords;
    private integer counter = 0; //keeps track of the offset
    private integer list_size = 10; //sets the page size or number of rows
    private integer total_size; //used to show user the total size of the list
    private integer startNo=0;//used to control the starting number of record in the table.
    private integer endNo;//used to control the ending number of record in the table
    private string selectedSize;//used to select the number of records.    private list<invoiceit_s__Job__c> totord = new list<invoiceit_s__Job__c>();
    private list<order> totord = new list<order>();
    private list<order> ord = new list<order>();
    public boolean isValidPage{get;set;}
    public String smbrowtoken {get;set;}
    public String smbtoken {get;set;}
    
    public Portal_OrdersPageController() {
        CSC_token__c csc_token = CSC_token__c.getValues('ExpectedToken');
        String actual_token = csc_token.Actual_Token__c;
        baseCSCURL = csc_token.Base_URL__c;
        formSubmitCSCURL = csc_token.Form_Submit_URL__c;
        System.debug('actual_token'+actual_token);        
        sessionId = ApexPages.currentPage().getParameters().get('sessionId');
        system.debug('Session id: ' + sessionid);
        token = ApexPages.currentPage().getHeaders().get('Authorization');
        
        smbrowtoken = ApexPages.currentPage().getHeaders().get('SMB_Authorization');
        if(smbrowtoken!=null){
            smbtoken = smbrowtoken.remove('Bearer '); 
        }
        
        if(ApexPages.currentPage().getHeaders().get('UID') != null)
            System.debug('Header value uid****'+ApexPages.currentPage().getHeaders().get('UID'));
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

        if(entireHeader.containsKey('RefDomain')){
            isSMB = true;
        }
        else{
            isSMB = false;
        }
        
        displayPage=true;       
        customerno = ApexPages.currentPage().getParameters().get('c');
        system.debug('Customer No: ' + customerno);
        if(customerno != null){
            account = [select id, name 
                       from account
                       where MH_Cust_Number__c =:customerno];
           
           if (account == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, customerno + 'Customer does not exist in our system'));
                return;
            }

            accountid = account.id;
            system.debug('@@@accountId'+ accountId);
            
        }
        
        if (accountid == null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, customerno + 'Customer does not exist in our system'));
        
        for (Order o : [select id, name,ordernumber, EffectiveDate, EndDate, Auth_By_Contact__r.FirstName, Auth_By_Contact__r.LastName  
                                      from Order where AccountId = :accountId  and Status__c not in ('Cancelled', 'Expired') order by name desc])
        {
               if (o.EndDate == null || o.EndDate > o.EffectiveDate )
                totord.add(o);
        }  
        total_size = totord.size();
        Beginning();
        
    }
    
    public PageReference signOut()
    {
        PageReference pageRef = null;
        string logoutURL = '';
        if(isSMB){
            logoutURL = system.label.SMB_MainURL +'/site/logout';
        }
        else{
            logoutURL = system.label.CSC_Portal+ '/Pages/SignOut.aspx?sn='+sessionId;
        }
        pageRef = new PageReference(logoutURL);
        pageRef.setRedirect(true);
        return pageRef;
        
    }
    
    public list<order> getOrders(){
        return ord;
    }
    
    public void addtoList() {        
        ord = new List < order> ();
        system.debug('AddtoList: ' + ' Startno: ' + startno + ' endno: ' + endno);
        if (totord.size() > 0 )
        {
            for (Integer i = startNo; i < endNo; i++) {
             ord.add(totord.get(i));
            }
        }
    }
 
    public integer getTotal_size() { //Getter method
        return total_size;
    }

    public void setTotal_size(integer total_size) { //Setter method
        this.total_size = total_size;
    }   
    
    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        startNo = 0;
        if (total_size < list_Size) {
            endNo = total_size;
        } else {
            endNo = list_size;
        }
        system.debug('Beginning: ' + startno + ' counter: ' + counter + ' endno: ' + endno);
        addtoList();
        
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        counter -= list_size;
        if ((startNo - list_size) >= 0) 
            startNo = startNo - list_size;
        endNo = counter + list_size;
        
        system.debug('Previous: ' + startno + ' counter: ' + counter + ' endno: ' + endno);
        addtoList();
        
        return null;
    }
    
    public PageReference Next() { //user clicked next button
        counter += list_size;
        startNo = counter;
        
        Integer currentPageNo = getPageNumber();
        Integer lastPageNo = getTotalPages();
        
        if (currentPageNo == lastPageNo) {
            endNo = total_size;
        } else {
            endNo = counter + list_size;
        }
        system.debug('Next: ' + startno + ' counter: ' + counter + ' endno: ' + endno);
        addtoList();
        
        return null;
    }
    
    public PageReference End() { //user clicked end
        counter = total_size - math.mod(total_size, list_size);
        startNo = counter ;
        endNo = total_size;
        
        system.debug('total_size ' + total_size);
        system.debug('list_size ' + list_size);
        system.debug('counter ' + counter);
        system.debug('Next: ' + startno + ' counter: ' + counter + ' endno: ' + endno);
        addtoList();
        
        return null;
    }    
    
    public List<SelectOption> getpaginationOptions(){
        List<SelectOption> paginationOptions = new List<SelectOption>();
         paginationOptions.add(new SelectOption('5','5'));
       paginationOptions.add(new SelectOption('10','10'));
        paginationOptions.add(new SelectOption('25','25'));
        paginationOptions.add(new SelectOption('50','50'));
        paginationOptions.add(new SelectOption('100','100'));
        paginationOptions.add(new SelectOption('200','200'));
        
        return paginationOptions;
    }      
    
    public PageReference SelectedCountSize() {
        list_size = Integer.valueof(selectedSize);
        Beginning();
        return null;
    }
    public Integer getPageNumber() {
        return counter / list_size + 1;
    }
    
    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) > 0) {
            return total_size / list_size + 1;
        } else {
            return (total_size / list_size);
        }
    }
    
    public Boolean getDisablePrevious() {
        //this will disable the previous and beginning buttons
        if (counter > 0) return false;
        else return true;
    }
    
    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + list_size < total_size) return false;
        else return true;
    }
    
    public integer getstartNo() { //Getter method
        return startNo;
    }
    
    public void setstartNo(integer startNo) { //Setter method
        this.startNo = startNo;
    }
    public integer getendNo() { //Getter method
        return endNo;
    }
    
    public string getselectedSize() { //Getter method
        return selectedSize;
    }
    
    public void setselectedSize(string selectedSize) { //Setter method
        this.selectedSize = selectedSize;
    }
    public void setendNo(integer endNo) { //Setter method
        this.endNo = endNo;
    }
}
public class OrderDetailsPageController { 
    public String custNo {get;set;}
    public boolean baseURL {get;set;}
    //public String sessionId {get;set;}
    //public String baseCSCURL {get;set;}
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
//    public String OrderPageUrl{get;set;}
    public Id accountId{get;set;}
    public integer offsetno;
    private integer noofRecords;
    private integer counter = 0; //keeps track of the offset
    private integer list_size = 10; //sets the page size or number of rows
    private integer total_size; //used to show user the total size of the list
    private integer startNo=0;//used to control the starting number of record in the table.
    private integer endNo;//used to control the ending number of record in the table
    private string selectedSize;//used to select the number of records.
    list<Products> orddet = new list<Products>();
    private list<Products> totdet = new list<Products>();
    private  list<invoiceit_s__Job_Rate_Plan_Charge__c> orpc;
    public OrderDetailsPageController() {
        CSC_token__c csc_token = CSC_token__c.getValues('ExpectedToken');
        String actual_token = csc_token.Actual_Token__c;
        baseCSCURL = csc_token.Base_URL__c;
        formSubmitCSCURL = csc_token.Form_Submit_URL__c;
        System.debug('actual_token'+actual_token);        
        sessionId = ApexPages.currentPage().getParameters().get('sessionId');
        //custNo = ApexPages.currentPage().getParameters().get('c');
        token = ApexPages.currentPage().getHeaders().get('Authorization');
        //token='bWFydGluZGFsZXNhbGVzZm9yY2Vjc2NpbnZvaWNlcGF5bWVudGludGVncmF0aW9u';
        System.debug('Cookies>>>'+ApexPages.currentPage().getCookies());
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
        
        if(entireHeader.containsKey('RefDomain')){
            isSMB = true;
        }
        else{
            isSMB = false;
        }
        
        displayPage=true;       
         customerno = ApexPages.currentPage().getParameters().get('c');
        if(customerno != null){
            account = [select id, name 
                           from account
                            where MH_Cust_Number__c =:customerno];
            accountid = account.id;
            system.debug('@@@accountId'+ accountId);
        }
//        accountid = ApexPages.currentPage().getParameters().get('Id');

        system.debug('Account id' + accountid);
//        OrderPageUrl = '/apex/OrderConfirmationPage?c=' + customerno;
//        system.debug('OrderPageUrl: ' + OrderPageUrl);
        String attribName;
        String ProdName;
        Integer Cnt;
//        list<String> Attriblist = new list<string>{ 'Service State', 'Service City', 'XRef State', 'XRef City', 'State', 'City', 'County', 'AOP', 'Preferred Banner Placements AOP', 'Preferred State Links AOP', 'Preferred National Links AOP', 'Preferred State Results AOP', 'Preferred Martindale.com Results AOP', 'Preferred City Results AOP', 'Preferred County Results AOP', 'Preferred National Results AOP'};
        list<String> Attriblist = new list<string>{ 'Service State', 'Service City', 'XRef State', 'XRef City', 'Xref Service Account Name','State', 'City', 'County', 'AOP', 'Preferred Banner Placements AOP', 'Preferred State Links AOP', 'Preferred National Links AOP', 'Preferred State Results AOP', 'Preferred Martindale.com Results AOP', 'Preferred City Results AOP', 'Preferred County Results AOP', 'Preferred National Results AOP'};
        id ordid = ApexPages.currentPage().getParameters().get('ordId');
        customerno = ApexPages.currentPage().getParameters().get('c');
//        OrderPageUrl = ApexPages.currentPage();
         orderNumber = [select name from invoiceit_s__Job__c where id = :ordid].name;

        try{
        List<Order_Charge_Attribute__c> ordService = [select  Attribute_Name__c,  Order_Rate_Plan_Charge__c,  String_value__c, picklist_value__c, 
                                          Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__c,
                                          Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.name
                                          from Order_Charge_Attribute__c  
                                          where Order_Rate_Plan_Charge__r.invoiceit_s__Order__c = :ordid 
                                          and Attribute_Name__c in :AttribList order by Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.name, Order_Rate_Plan_Charge__c, attribute_name__c desc];
                    
        for (invoiceit_s__Job_Product__c o : [ select id, invoiceit_s__Product__c, invoiceit_s__Product__r.name from invoiceit_s__Job_Product__c where invoiceit_s__Job__c = :ordid order by invoiceit_s__Product__r.name])
        {
            products p = new products();
            p.productName = o.invoiceit_s__Product__r.name;
            p.prodid = o.invoiceit_s__Product__c;
            p.id = o.id;
            totdet.add(p);
        }
        CheckandInsertProducts(ordService);
//        totdet.sort();
        total_size = totdet.size();
        Beginning();
        }
        catch(exception e)
        {
            system.debug('Error Rama: '+e.getMessage() + ' line number: ' + e.getLineNumber());
        }

    }
    
     public PageReference signOut()
    {
        PageReference pageRef = null;
        string logoutURL = '';
        //system.debug('@@@@Current Page Domain ============='+Domain);
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
        
    public integer getTotal_size() { //Getter method
        return total_size;
    }

    public void setTotal_size(integer total_size) { //Setter method
        this.total_size = total_size;
    }        
    public list<Products> getOrderDetails(){
          return orddet;
    }


    public class Products {
        public string productName{get;set;}
        public string prodid{get;set;}
        public string id{get;set;}
        public list<OrderAttributeCount> oac {get;set;}
      
   }
    
    public class OrderAttributeCount {
        public string attribname{get;set;}
        public string attribvalue{get;set;}                
     } 
    
    public void CheckandInsertProducts(list<Order_Charge_Attribute__c> Ordprod){
        for (Products p : totdet)
        {
            list<OrderAttributeCount> oa = new list<OrderAttributeCount>();     
            for (Order_Charge_Attribute__c o: ordprod)
            {
//                if(p.prodid == o.Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__c)
                if(p.id == o.Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c)
                {
                    OrderAttributeCount ora = new OrderAttributeCount();
                    
                    ora.attribname = o.Attribute_Name__c;
                    ora.attribname = ora.attribname.replace('Xref', 'Cross Reference');
                    if (o.string_value__c != null) 
                        ora.attribvalue = o.string_value__c;
                    else if (o.picklist_value__c != null)
                        ora.attribvalue = o.picklist_value__c;
                    if (ora.attribvalue != null && ora.attribvalue != '--None--')
                        oa.add(ora);
                }
            }
            p.oac = oa;
        }
//        system.debug('Total Products: ' + totdet);
    }
        
    public void addtoList() {
        
        orddet = new List < Products> ();
        system.debug('AddtoList: ' + ' Startno: ' + startno + ' endno: ' + endno);
        if (totdet.size() > 0 )
        {
            for (Integer i = startNo; i < endNo; i++) {
                orddet.add(totdet.get(i));
            }
        }
    }

    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        startNo = 0;
        if (total_size < list_Size) {
            endNo = total_size;
        } else {
            endNo = list_size;
        }
//        system.debug('Beginning: ' + startno + ' counter: ' + counter + ' endno: ' + endno);
         addtoList();

        return null;
    }
    
     public PageReference Previous() { //user clicked previous button
        counter -= list_size;
        if ((startNo - list_size) >= 0)
            startNo = startNo - list_size;
        endNo = counter + list_size;

//        system.debug('Previous: ' + startno + ' counter: ' + counter + ' endno: ' + endno);
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
        // counter = 0;
        counter = total_size - math.mod(total_size, list_size);
        startNo = counter ;
        endNo = total_size;

        system.debug('total_size ' + total_size);
        system.debug('list_size ' + list_size);
        system.debug('counter ' + counter);
//        system.debug('Next: ' + startno + ' counter: ' + counter + ' endno: ' + endno);
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
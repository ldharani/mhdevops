/*********************************************************************************
Created By : Lister Technologies

Created Purpose : This class is a controller class for MDL_invoice_detail_page
          where all the 'unpaid' and 'posted' invoices of the user account
          are displayed.
**********************************************************************************/
public class MDL_Invoice_detail_controller {
    public List<invoiceit_s__Invoice__c> invoices = new List<invoiceit_s__Invoice__c>();
    public String custNo {get;set;}
    public boolean baseURL {get;set;}
    public String sessionId {get;set;}
    public String baseCSCURL {get;set;}
    public String formSubmitCSCURL {get;set;}
    public String token {get;set;}
    public boolean displayPage {get;set;}   
    public string accName = '';
    public Map<String,String> entireHeader {get; set;}   
    public MDL_Invoice_detail_controller(){
        CSC_token__c csc_token = CSC_token__c.getValues('ExpectedToken');
        String actual_token = csc_token.Actual_Token__c;
        baseCSCURL = csc_token.Base_URL__c;
        formSubmitCSCURL = csc_token.Form_Submit_URL__c;
        System.debug('actual_token'+actual_token);        
        sessionId = ApexPages.currentPage().getParameters().get('sessionId');
        custNo = ApexPages.currentPage().getParameters().get('c');
        token = ApexPages.currentPage().getHeaders().get('Authorization');
        //token='bWFydGluZGFsZXNhbGVzZm9yY2Vjc2NpbnZvaWNlcGF5bWVudGludGVncmF0aW9u';
        System.debug('Cookies>>>'+ApexPages.currentPage().getCookies());
        if(ApexPages.currentPage().getHeaders().get('UID') != null)
            System.debug('Header value uid****'+ApexPages.currentPage().getHeaders().get('UID'));
        entireHeader = ApexPages.currentPage().getHeaders();        
        if(actual_token!=token){
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
        }        
    }
    public List<invoiceit_s__Invoice__c> getInvoices(){
        invoices = [Select i.Id,i.invoiceit_s__Unpaid_Amount__c,i.TotalAllocatedPayments__c, i.invoiceit_s__Total_Invoice_Value__c,i.Total_Payments__c, i.invoiceit_s__Payment_Status__c, i.invoiceit_s__Invoice_Date__c, i.invoiceit_s__Due_Date__c, i.Name From invoiceit_s__Invoice__c i 
                   where invoiceit_s__Account__r.MH_Cust_Number__c =:custNo and i.invoiceit_s__Payment_Status__c!= 'Paid' and i.invoiceit_s__Invoice_Status__c='Posted' order by i.invoiceit_s__Invoice_Date__c DESC limit 20];
        system.debug('&&&&'+invoices);
          if(invoices.size() == 0){ 
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,''+'No records to Display'));
            return null;
          }
          else{  
            return invoices; 
          }                
    }  
    public void setInvoices(){
        this.invoices = invoices;
    }
    public string getAccName(){
        for(Account acc : [select Name from Account where MH_Cust_Number__c = :custNo limit 1]){
            accName = acc.Name;
        }
        return accName;     
    }
    public void setAccName(){
        this.accName = accName;
    }
   
}
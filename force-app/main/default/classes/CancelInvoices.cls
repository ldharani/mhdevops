public class CancelInvoices {
    //default page size
    private static final Integer PAGE_SIZE = integer.valueOf(invoiceit_s__Configuration__c.getValues('NAVIGATION_CONFIGURATION').invoiceit_s__Number_Value__c);    
    invoiceit_s__Invoice_Run__c invoiceRun ; 
    public String invoiceRunName{get;set;}
    invoiceit_s__Invoice_Run__c invoiceRunRecord;       
    //pagination information
    public Integer page{get;set;}
    public Integer totalRecords{get;set;}
    public Integer totalPages{get;set;}
    public Integer startIdx{get;set;}
    public Integer endIdx{get;set;}
    public List<InvoiceWrapper> tRecords{get;set;}
    
    public CancelInvoices(ApexPages.StandardController controller)
    {
        invoiceRun = (invoiceit_s__Invoice_Run__c) controller.getRecord(); 
        invoiceRunRecord = [SELECT Id,Name FROM invoiceit_s__Invoice_Run__c WHERE Id =:invoiceRun.id]; 
        invoiceRunName = invoiceRunRecord.Name; 
        //init variable
        this.tRecords = new List<InvoiceWrapper>();
        
        //set initial page
        this.page = 1;
        
        //load records
        getInvoices();
                
    }   
    public Pagereference invoiceSelected(){        
        set<id> setOfInvoice = new set<id>();
        for(InvoiceWrapper invoiceWra : tRecords){
            if(invoiceWra.isSelected){                   
                setOfInvoice.add(invoiceWra.invoices.id);               
            }            
        }        
        if(setOfInvoice.size()>0){
            BatchCancelInvoices b = new BatchCancelInvoices(setOfInvoice);
            database.executebatch(b,1);
        }else{
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'There are no Invoices selected...'));            
        }
        return new PageReference('/' + invoiceRun.id);        
    } 
    Public Pagereference allInvoice(){
        map<Id, invoiceit_s__Invoice__c> mapOfInvoices = new map<Id, invoiceit_s__Invoice__c>([SELECT Id,invoiceit_s__Invoice_Run_Created_By__c,invoiceit_s__Invoice_State__c,invoiceit_s__Invoice_Status__c,Name,invoiceit_s__Amount__c,invoiceit_s__Account__r.Name,invoiceit_s__Invoice_Date__c FROM invoiceit_s__Invoice__c  WHERE invoiceit_s__Invoice_Status__c != 'Cancelled' AND invoiceit_s__Invoice_Status__c != 'Posted' AND invoiceit_s__Invoice_Run_Created_By__c=:invoiceRun.ID ORDER BY Name]);
        if(mapOfInvoices.size()>0){                    
            BatchCancelInvoices b = new BatchCancelInvoices(mapOfInvoices.keyset());
            database.executebatch(b,1);
        }else{             
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'There are no Invoices to display..... '));
        }
        return new PageReference('/' + invoiceRun.id);  
    }
    public void doNext(){
        
        if(getHasNext()){
            this.page++;
            getInvoices();
        }
 
    }
    

    public void doPrevious(){
        
        if(getHasPrevious()){
            this.page--;
            getInvoices();
        }
                
    }
    

    public Boolean getHasPrevious(){
        if(this.page>1){
            return true;
        }
        else{
            return false;
        }
    }

    public Boolean getHasNext(){
        if(this.page<this.totalPages){
            return true;
        }
        else{
            return false;
        }
    }
    public void getInvoices(){
        
        //calculate range of records for capture
        this.startIdx = (this.page-1)*PAGE_SIZE;
        this.endIdx = this.page*PAGE_SIZE;
        this.totalRecords = 0;
        
        //clear container for records displayed
        this.tRecords.clear();
                
        //if(invoiceRun.ID != null) {
        //cycle through
        for(invoiceit_s__Invoice__c c : [SELECT Id,invoiceit_s__Invoice_Run_Created_By__c,invoiceit_s__Invoice_State__c,invoiceit_s__Invoice_Status__c,Name,invoiceit_s__Amount__c,invoiceit_s__Account__r.Name,invoiceit_s__Invoice_Date__c FROM invoiceit_s__Invoice__c  WHERE invoiceit_s__Invoice_Status__c != 'Cancelled' AND invoiceit_s__Invoice_Status__c != 'Posted' AND invoiceit_s__Invoice_Run_Created_By__c=:invoiceRun.ID]){
        
            //capture records within the target range
            if(this.totalRecords>=this.startIdx && this.totalRecords<this.endIdx){   
           
                this.tRecords.add( new InvoiceWrapper(c, false) );
            }
            
            //count the total number of records
            this.totalRecords++;
        
        }
        //}
        
        //calculate total pages
        Decimal pages = Decimal.valueOf(this.totalRecords);
        pages = pages.divide(Decimal.valueOf(PAGE_SIZE), 2);
        this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
        
        //adjust start index e.g. 1, 11, 21, 31
        this.startIdx++;
        
        
        //adjust end index
        if(this.endIdx>this.totalRecords){
            this.endIdx = this.totalRecords;
        }

    }
    public with sharing class InvoiceWrapper{
        
        public invoiceit_s__Invoice__c invoices{get;set;}
        public Boolean IsSelected{get;set;}
        
        public InvoiceWrapper(invoiceit_s__Invoice__c c, Boolean s){
            this.invoices=c;
            this.IsSelected=s;
        }
        
    }    
}
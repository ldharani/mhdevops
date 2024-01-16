public class virtualTerminalTestinvoices {
    
    public List<invoiceit_s__Invoice__c> invlist{get;set;}
    public id accid{get;set;}
    
    public virtualTerminalTestinvoices(){
        invlist = new List<invoiceit_s__Invoice__c>();
        accid = ApexPages.currentPage().getParameters().get('accountId');
        if(accid != null){
            invlist = [select id, Name,invoiceit_s__Unpaid_Amount__c ,
                                  invoiceit_s__Invoice_Status__c,
                                  invoiceit_s__Account__c, RecordType.Name,
                                  invoiceit_s__Invoice_Date__c,
                                  invoiceit_s__Net_Total__c,
                                  invoiceit_s__Amount__c
                                  from invoiceit_s__Invoice__c
                                  where invoiceit_s__Account__c =:accid 
                                  and invoiceit_s__Invoice_Status__c = 'Posted'
                                  and invoiceit_s__Unpaid_Amount__c > 0 Order by invoiceit_s__Invoice_Date__c ASC ];
        }
    }

}
/*Requirement
    Create a batch class which picks the list of accounts who is satisfying the below condition

    Invoice Status = Posted
    Invoice Date = 1st day of present month.
    Invoice record Type -- JV Invoice.
    Business Unit -- JV
    Migration Status -- Pending MH Migration
    
    
    After receiving the list of account, change the below mentioned flags on Account level.
    Default Gateway -- Nolo Test Gateway
    Legal Entity -- M-H Taxable / M-H Non-Taxable  
    Invoice Delivery Type -- Print & Email
    Billing Schedule -- Advanced
    Account Record Type -- M-H Account
    Business Unit -- Martindale-Hubbell
    Migration Status -- MH Migration Completed
    Payment terms -- Net 10
    <--Collector --    Linda Guzman-->
    Dunning Hold -- True
    Dunning Hold Date -- Set Date
  //Done by Sai :Changes made for New Record type changes MHBS-995
*/
    
global class mdl_BatchtochangeAccountfields implements Database.Batchable<sObject> {
    
     global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('@@@in start');
          
        // forming date filed for filter
        Date forFilterInv = date.newInstance(date.today().year(), date.today().month(), 01);
        String jvinvoiceRectype =  RecordTypesFinalStringsClass.RecTypeName_JV_Invoice;
        system.debug('@@@forFilterInv'+forFilterInv);
        string query = 'select Id, Name,'+ 
                                              ' (select id, invoiceit_s__Invoice_Status__c,'+
                                                   ' invoiceit_s__Invoice_Date__c,'+
                                                   ' RecordType.Name'+
                                                   ' from invoiceit_s__Invoices__r'+
                                                   ' where invoiceit_s__Invoice_Status__c = \'Posted\''+
                                                   ' and invoiceit_s__Invoice_Date__c =: forFilterInv'+
                                                   ' and RecordType.Name = :jvinvoiceRectype),'+
                                           ' Legal_Entity__c, invoiceit_s__Invoice_Delivery_Type__c,'+
                                           ' Billing_Schedule__c, RecordTypeId,'+
                                           ' Business_Unit__c'+ 
                                           ' from account'+ 
                                           ' where MH_Cust_Number__c !=null'+
                                           ' and Business_Unit__c = \'JV\''+
                                           ' and Migration_Status__c= \'Pending MH Migration\'' ; 
         if(test.isRunningTest()){
             query += ' order by CreatedDate DESC Limit 5';
         }
         
        return Database.getQueryLocator(query); 
       
       }
    
       global void execute(Database.BatchableContext BC, List<account> accList){
        
            System.debug('@@@@Start  Execution');
            system.debug('@@@@@accList' + accList);
           id recordtypid_nolo = [Select Id 
                                 From RecordType 
                                 where sobjecttype = 'Account' 
                                 and DeveloperName = 'Nolo_Account'].id;
                                 //user u = [select id, Name from User where Name = 'Linda Guzman' ];
           for(account acc : accList){
               if(acc.invoiceit_s__Invoices__r.size() >0  && acc.invoiceit_s__Invoices__r !=null){
                  
                   if(acc.Legal_Entity__c != null){
                       if(acc.Legal_Entity__c == 'JV Taxable'){
                           acc.Legal_Entity__c = 'M-H Taxable';
                       }
                       else if(acc.Legal_Entity__c == 'JV Non-Taxable'){
                           acc.Legal_Entity__c = 'M-H Non-Taxable';
                       }
                   }
                  
                   acc.invoiceit_s__Invoice_Delivery_Type__c = 'Email & Print';
                   acc.Billing_Schedule__c = 'Advanced';
                   acc.RecordTypeId = recordtypid_nolo;
                  //acc.invoiceit_s__Payment_Terms__c = 'Net 10';
                   acc.Business_Unit__c = 'Martindale-Hubbell';
                   acc.Migration_Status__c = 'MH Migration Completed';
                   acc.invoiceit_s__Gateway__c = system.Label.Nolo_Test_Gateway;
                   //acc.Collector__c = u.id;
                   acc.Dunning_Hold__c = TRUE;
                   acc.Hold_dunning_letter_till__c= date.today();
               }
           }
           try{
               update acclist;
           }
           catch(exception e){
               system.debug('@@@@exception'+ e);
           }
           
        
      }
    
    global void finish(Database.BatchableContext BC){
    
        List<String> toAddresses = new list<string> ();
        toAddresses.add('sfdcsystemautomation@martindale.com');
        genericUtilityClass.sendEmails(toAddresses, 'Convert Pending MH Migration Accounts to MH Migration Completed');
        
    }

}
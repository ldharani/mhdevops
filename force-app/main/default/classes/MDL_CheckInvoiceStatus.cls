/*
** Created by       : Lister Technologies
** Created Purpose  : To set Account Credit Status to Past Due or Good standing based on certain criteria 
** Test class : MDL_Test_CheckInvoiceStatus.cls
*/
global class MDL_CheckInvoiceStatus implements Database.Batchable <SObject>,Database.Stateful  {

    private String accQuery = '';
    public Date dueDate;
    public List<Account> lstAccsToBeUpdated;
    
    global MDL_CheckInvoiceStatus() {
        dueDate = Date.today().addDays(-90);        
    }
    
    //Start Method which retrieves the invoice records 
    global Database.QueryLocator start(Database.BatchableContext BC) {
    
        accQuery = 'Select Id, Credit_Status__c, Credit_Sub_Status__c , Total_Account_Balance__c , (Select Id from invoiceit_s__Invoices__r where invoiceit_s__Invoice_Status__c = \'Posted\' and invoiceit_s__Payment_Status__c != \'Paid\' and invoiceit_s__Invoice_Date__c < : dueDate LIMIT 1) from Account where Credit_Status__c != \'Bad Debt\'  and Finance_Class__c != \'Agency\' and (RecordType.DeveloperName =\'MH_Accounts\' or RecordType.DeveloperName =\'Nolo_Account\')';        
        if(test.isRunningTest()) {
            accQuery += ' and Name like \'%test%InvStatus%\' LIMIT 5';          
        }
        System.debug('accQuery------------->'+accQuery);
        return Database.getQueryLocator(accQuery);
        
    }

    global void execute(Database.BatchableContext BC, List <Account> accList) {
        lstAccsToBeUpdated = new List<Account>();
        for(Account acc: accList) {
            if(acc.invoiceit_s__Invoices__r.size() == 0 || acc.Total_Account_Balance__c < 10.00 ) {
                //no invoices have a due date which is 60 days past, hence account credit status can be set to good standing
                acc.Credit_Status__c = 'Good Standing';
                acc.Credit_Sub_Status__c = '';
                lstAccsToBeUpdated.add(acc);
            }
            else {
                //atleast 1 invoice has a due date which is 60 days past, hence account credit status can be set to past due
                acc.Credit_Status__c = 'Past Due';
                lstAccsToBeUpdated.add(acc);
            }           
        }
        if(lstAccsToBeUpdated.size() > 0) {
            Database.update(lstAccsToBeUpdated);
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}
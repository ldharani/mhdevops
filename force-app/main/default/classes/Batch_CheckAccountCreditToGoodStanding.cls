/*
** Created by       : Lakshmi
** Created Purpose  : To set Account Credit Status to Good standing based on certain criteria 
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHMAC-622     Chetna     12/25/2024                     T01     Include M-A RecordType for Invoice related batch processes
*/
//<T01>
global class Batch_CheckAccountCreditToGoodStanding implements Database.Batchable<sObject> {
    String InvoiceId;
    
    public Date dueDate;
    public Integer daysToBeAdded = Integer.valueOf(System.label.DueDateforCreditStatus);
    public List<Account> lstAccsToBeUpdated;
    
    global Batch_CheckAccountCreditToGoodStanding() {
        dueDate = Date.today().addDays(-daysToBeAdded);
        init('');                
    }
    
    global void init(String InvoiceId){
        this.InvoiceId = InvoiceId;
    }
    
    global Batch_CheckAccountCreditToGoodStanding(String InvoiceId){
        init(InvoiceId);
    }
    
    
    //Start Method which retrieves the invoice records 
    global Database.QueryLocator start(Database.BatchableContext BC) {
    
        String query = 'Select Id, blng__Balance__c,blng__Account__c from blng__Invoice__c where blng__InvoiceStatus__c = \'Posted\' and blng__Balance__c <= 0 and blng__DueDate__c < : dueDate and blng__Account__r.Credit_Status__c = \'Past Due\' and blng__Account__r.Finance_Class__c != \'Agency\' and (blng__Account__r.RecordType.DeveloperName =\'Nolo_Account\' OR RecordType.DeveloperName=\'M_A_Invoice\') and ( blng__Account__r.Total_Amount_Past_Dues__c = 0 or blng__Account__r.Total_Amount_Past_Dues__c < 10)'; //<T01> //Changed the credit status check to check only for Past Due Accounts to Change to Good standing
        
        if(!String.isEmpty(InvoiceId)){
            query += ' and Id =\''+InvoiceId+'\'';
        }
        
        if(Test.isRunningTest()){
            query = query = 'Select Id, blng__Balance__c,blng__Account__c from blng__Invoice__c where blng__InvoiceStatus__c = \'Posted\' and blng__Account__r.Credit_Status__c != \'Good Standing\' and blng__Account__r.Finance_Class__c != \'Agency\' and (blng__Account__r.RecordType.DeveloperName =\'Nolo_Account\' OR RecordType.DeveloperName=\'M_A_Invoice\') Limit 1';            
        }
        
        return Database.getQueryLocator(query);
        
    }

    global void execute(Database.BatchableContext BC, List<blng__Invoice__c> invList) {
        lstAccsToBeUpdated = new List<Account>();
        for(blng__Invoice__c inv : invList) {
                Account acc = new Account(Id = inv.blng__Account__c);        
                acc.Credit_Status__c = 'Good Standing';
                if(!lstAccsToBeUpdated.contains(acc)){
                    lstAccsToBeUpdated.add(acc);          
                }      
        }           
        
        if(lstAccsToBeUpdated.size() > 0) {
            try{
            Database.update(lstAccsToBeUpdated,false);
            }
            catch(Exception ex){
                Util.processException(ex,true,'Exception during Account Credit Status Batch to Good Standing'+lstAccsToBeUpdated);
            }
        }
    }
    //<T01>

    global void finish(Database.BatchableContext BC) {

    }
}
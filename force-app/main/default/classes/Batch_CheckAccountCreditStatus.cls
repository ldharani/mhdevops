/*
** Created by       : IJ
** Created Purpose  : To set Account Credit Status to Past Due or Good standing based on certain criteria 
** Modification     : Modified the batch to pick up MH accounts(developerName = 'Nolo_Account') instead of JV accounts
** Test class :  
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-8965    Lakshmi    13/06/2023                      T01     Optimize the account credit status
MHMAC-622     Chetna     12/25/2024                     T02     Include M-A RecordType for Invoice related batch processes
*/
//<T01>
global class Batch_CheckAccountCreditStatus implements Database.Batchable<sObject> {
    String InvoiceId;
    
    public Date dueDate;
    public Integer daysToBeAdded = Integer.valueOf(System.label.DueDateforCreditStatus);
    public List<Account> lstAccsToBeUpdated;
    
    global Batch_CheckAccountCreditStatus() {
        dueDate = Date.today().addDays(-daysToBeAdded);
        init('');                
    }
    
    global void init(String InvoiceId){
        this.InvoiceId = InvoiceId;
    }
    
    global Batch_CheckAccountCreditStatus(String InvoiceId){
        init(InvoiceId);
    }
    
    
    //Start Method which retrieves the invoice records 
    global Database.QueryLocator start(Database.BatchableContext BC) {
    
        String query = 'Select Id, blng__Balance__c,blng__Account__c from blng__Invoice__c where blng__InvoiceStatus__c = \'Posted\' and blng__Balance__c > 0 and blng__DueDate__c < : dueDate and blng__Account__r.Credit_Status__c = \'Good Standing\' and blng__Account__r.Finance_Class__c != \'Agency\' and (blng__Account__r.RecordType.DeveloperName =\'Nolo_Account\' OR RecordType.DeveloperName=\'M_A_Invoice\') and blng__Account__r.Total_Amount_Past_Dues__c > 10'; //<T02> //Changed the credit status check to check only for Good Standing Accounts to Change to Past Due
        
        if(!String.isEmpty(InvoiceId)){
            query += ' and Id =\''+InvoiceId+'\'';
        }
        
        if(Test.isRunningTest()){
            query = query = 'Select Id, blng__Balance__c,blng__Account__c from blng__Invoice__c where blng__InvoiceStatus__c = \'Posted\' and blng__Account__r.Credit_Status__c != \'Past Due\' and blng__Account__r.Finance_Class__c != \'Agency\' and blng__Account__r.RecordType.DeveloperName =\'Nolo_Account\' Limit 1';            
        }
        
        return Database.getQueryLocator(query);
        
    }

    global void execute(Database.BatchableContext BC, List<blng__Invoice__c> invList) {
        lstAccsToBeUpdated = new List<Account>();
        for(blng__Invoice__c inv : invList) {
                Account acc = new Account(Id = inv.blng__Account__c);        
                acc.Credit_Status__c = 'Past Due';
                if(!lstAccsToBeUpdated.contains(acc)){
                    lstAccsToBeUpdated.add(acc);          
                }                   
        }           
        
        if(lstAccsToBeUpdated.size() > 0) {
            try{
            Database.update(lstAccsToBeUpdated,false);
            }
            catch(Exception ex){
                Util.processException(ex,true,'Exception during Account Credit Status Batch'+lstAccsToBeUpdated);
            }
        }
    }
    //<T01>

    global void finish(Database.BatchableContext BC) {
        Database.executebatch(new Batch_CheckAccountCreditToGoodStanding(), 200);
    }
}
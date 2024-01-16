// Author              : Sai
// Description         : batch to account customer Status to New to existing int the following condition
//                     : customer status = new
//                     : and acquisition or reacquistiondate are greater than 12 months from setting
global with sharing class MDL_BatchNewtoExistingStatus implements Database.Batchable<sObject>{
    global String query;
    public Date twelvemonthsDate;
    public Date thirteenmonthsDate;
   
    global Database.QueryLocator start(Database.BatchableContext BC){
       query = 'SELECT id, Name, '+
                ' Customer_Status__c, Acquisition_date__c, '+
                ' Re_acquisition_date__c, MH_Cust_Number__c '+
                ' from account '+
                ' where Customer_Status__c = \'New\'' ;
        
        if(test.isRunningTest()){
            query +=' LIMIT 5';
        }
        system.debug('@@@@query'+ query);             
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,list<account> acclist){
        List<account> accstoUpdate = new List<account>();
        for(account acc: acclist){
           // if(acc.MH_Cust_Number__c.startswith('10')){
                if((acc.Re_acquisition_date__c!= null 
                       //&& date.today().addmonths(-13)                  <= acc.Re_acquisition_date__c 
                       && date.today().year()                  > acc.Re_acquisition_date__c.year())
                     || (acc.Re_acquisition_date__c == null
                           //&& date.today().addmonths(-13)              <= acc.Acquisition_date__c 
                           && date.today().year()              > acc.Acquisition_date__c.year())){
                        acc.Customer_Status__c = 'Existing';
                        accstoUpdate.add(acc);
                   }
                
           // }
        }
        
        if(accstoUpdate.size() > 0){
            try{
                update accstoUpdate;
            }
            catch(exception e){
                system.debug('@@@exception'+ e);
            }
        }
    
    }
    
    global void finish(Database.BatchableContext BC){
    }
}
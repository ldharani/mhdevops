/*
** Created by       : IJ
** Created Purpose  : To set the Quote as Evergreen after the contract has been made Evergreen
** Test class :  */

global class Batch_SetQuoteasAutoEvergreen implements Database.Batchable <SObject>,Database.Stateful  {
//Start Method which retrieves the invoice records 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strQuery;
       
         Integer mnth = System.Today().MOnth();
        Integer yr = System.Today().Year();
       /* List<String> contractNameslist = System.Label.ContractsList_Autoevergreen.split(',');
        system.debug('contractNameslist : '+contractNameslist);
         if(!contractNameslist.contains('null')){ */
           strQuery= 'Select Id,Status__c,SBQQ__Quote__c,IsAutoEvergreenBatch__c,AutoEvergreen_Failure_Reason__c,Marketing_Contact__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Status__c ,EndDate,AccountId,Account.Credit_Status__c,Account.BillingCountry,Account.Sub_Type__c,SBQQ__RenewalOpportunity__c,SBQQ__Order__c from contract where Status__c = \'Evergreened\' and Account.Credit_Status__c = \'Good Standing\' and Do_Not_Renew__c=false and Account.BillingCountry=\'USA\' and recordtype.developername=\'MH_Contract\' and Account.Sub_Type__c=\'Small Law\' and SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Status__c!=\'Closed Won\' and CALENDAR_MONTH(EndDate) = :mnth and CALENDAR_YEAR(EndDate) = :yr and IsAutoEvergreenBatch__c=true'; 
       /* }else{
           strQuery = 'Select Id,Status__c,SBQQ__Quote__c,IsAutoEvergreenBatch__c,AutoEvergreen_Failure_Reason__c,Marketing_Contact__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Status__c ,EndDate,AccountId,Account.Credit_Status__c,Account.BillingCountry,Account.Sub_Type__c,SBQQ__RenewalOpportunity__c,SBQQ__Order__c from contract where Status__c = \'Evergreened\' and Account.Credit_Status__c = \'Good Standing\' and Do_Not_Renew__c=false and Account.BillingCountry=\'USA\' and recordtype.developername=\'MH_Contract\' and Account.Sub_Type__c=\'Small Law\' and SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Status__c!=\'Closed Won\' and CALENDAR_MONTH(EndDate) = :mnth and CALENDAR_YEAR(EndDate) = :yr and ContractNumber in : contractNameslist  and IsAutoEvergreenBatch__c=true';  
        } */
        
        system.debug(strQuery+'strQuery');
       if(test.isRunningTest()) {
           strQuery= 'Select Id,Status__c,SBQQ__RenewalOpportunity__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c,AutoEvergreen_Failure_Reason__c from contract';           
        }
        
        return Database.getQueryLocator(strQuery);
        
    }

    global void execute(Database.BatchableContext BC, List <Contract> ContractsList) {
      
        list<Id> listofquoteIds = new list<Id>();
        list<id> RenewalOppIds = new list<Id>();
        list<contract> contracterrlist=new list<contract>();
        list<Opportunity> updateOpplist= new list<Opportunity>();
        list<SBQQ__Quote__c> Updatequotelist= new list<SBQQ__Quote__c>();
        list<SBQQ__Quote__c> Updatequotelist1= new list<SBQQ__Quote__c>();
        list<SBQQ__QuoteLine__c> updateQuoteline = new list<SBQQ__QuoteLine__c>();
        Auto_Evergreen_Process__c autoEvergreen = Auto_Evergreen_Process__c.getValues('Auto Evergreen Process');
        
        for(Contract obj: ContractsList){
          RenewalOppIds.add(obj.SBQQ__RenewalOpportunity__c);
          listofquoteIds.add(obj.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c); 
            if(obj.AutoEvergreen_Failure_Reason__c!=null){
                obj.AutoEvergreen_Failure_Reason__c=null;
                contracterrlist.add(obj);
            }
        } 
       
        if(!autoEvergreen.MarkQuoteasClosedWon__c){
        for(Opportunity opp:[select Name,Id,SBQQ__PrimaryQuote__c,SBQQ__PrimaryQuote__r.SBQQ__Status__c,SBQQ__RenewedContract__r.IsAutoEvergreenBatch__c from Opportunity where id in: RenewalOppIds and  ( NOT Name like '%Auto-Evergreen%') and SBQQ__PrimaryQuote__r.SBQQ__Status__c!='Closed Won' and SBQQ__RenewedContract__r.IsAutoEvergreenBatch__c=true]){
        opp.Name = Opp.Name.replace('Evergreen','Auto-Evergreen');
        updateOpplist.add(opp);
        system.debug('enter update 4 opp Id'+opp.Id);
        }
        
        
        for(SBQQ__Quote__c quote: [select Id,SBQQ__Status__c,Reason_Won_Lost__c,SBQQ__EndDate__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Marketing_Contact__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Bill_To_Contact__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Primary_Contact__c from SBQQ__Quote__c where id in:listofquoteIds and SBQQ__Ordered__c!=true]){
        quote.Marketing_Contact__c=quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Marketing_Contact__c;
        quote.Billing_Contact__c=quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Bill_To_Contact__c;
        quote.SBQQ__PrimaryContact__c=quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Primary_Contact__c;
        quote.SBQQ__Ordered__c=true;  
        Updatequotelist.add(quote);  
         system.debug('enter update 1 quote'+quote);   
        } 
       }
      
        
        if(autoEvergreen.MarkQuoteasClosedWon__c){
        for(SBQQ__Quote__c quote: [select Id,SBQQ__Status__c,SBQQ__Ordered__c,Reason_Won_Lost__c,SBQQ__EndDate__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Marketing_Contact__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Bill_To_Contact__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Primary_Contact__c from SBQQ__Quote__c where id in:listofquoteIds and SBQQ__Status__c!='Closed Won']){
        quote.SBQQ__Status__c = 'Closed Won';
        quote.Reason_Won_Lost__c = 'Auto Evergreen';  
            
        Updatequotelist1.add(quote);
        system.debug('enter update 2 quote'+quote.Id);      
        }  }
            Savepoint sp =  Database.setSavepoint();
        try{
            if(contracterrlist.size()>0){
              update contracterrlist;
            }system.debug('contracterrlist'+contracterrlist);
           if(!autoEvergreen.MarkQuoteasClosedWon__c){ 
               Update updateOpplist ;  
               update Updatequotelist ;
           } 
           if(autoEvergreen.MarkQuoteasClosedWon__c){
            update Updatequotelist1;
           }
        }catch(Exception e){
            Database.rollback(sp);
            list<Contract> failurecontract=new list<Contract>();
             for(Contract obj: ContractsList){
                 if(e.getmessage().length() > 255){
                 obj.AutoEvergreen_Failure_Reason__c =e.getmessage().abbreviate(255);
                 }else{
                     obj.AutoEvergreen_Failure_Reason__c =e.getmessage();
                 }
                 failurecontract.add(obj);
             } system.debug('failurecontract'+failurecontract);
            update failurecontract;
        }   
        
    }

    global void finish(Database.BatchableContext BC) {
        
    }

}
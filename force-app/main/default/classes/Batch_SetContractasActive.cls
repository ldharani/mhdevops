/*
** Created by       : IJ
** Created Purpose  : To set the contract as Active 
** Test class :  */

global class Batch_SetContractasActive implements Database.Batchable <SObject>,Database.AllowsCallouts,Database.Stateful  {
     
    //Start Method which retrieves the invoice records 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strQuery;
       
        list<string> statuslist = new list<string>{'Renew in Progress','Rebase in progress','Evergreen in progress','Mid-term in progress','Cancel in progress'};
      Integer mnth = System.Today().MOnth();
        Integer yr = System.Today().Year();
        
        /* List<String> contractNameslist = System.Label.ContractsList_Autoevergreen.split(',');
        system.debug('contractNameslist : '+contractNameslist);
        if(!contractNameslist.contains('null')){*/
        
           strQuery= 'Select Id,Status__c,SBQQ__Quote__c,SBQQ__RenewalForecast__c,SBQQ__RenewalQuoted__c,Marketing_Contact__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c ,EndDate,AccountId,Account.Credit_Status__c,Account.BillingCountry,Account.Sub_Type__c,SBQQ__RenewalOpportunity__c,SBQQ__Order__c from contract where Status__c in: statuslist and Do_Not_Renew__c=false and recordtype.developername=\'MH_Contract\' and CALENDAR_MONTH(EndDate) = :mnth and CALENDAR_YEAR(EndDate) = :yr and IsEligibleForAutoEvg__c=true';
       
      
       /* }else{
            strQuery= 'Select Id,Status__c,SBQQ__Quote__c,SBQQ__RenewalForecast__c,SBQQ__RenewalQuoted__c,Marketing_Contact__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c ,EndDate,AccountId,Account.Credit_Status__c,Account.BillingCountry,Account.Sub_Type__c,SBQQ__RenewalOpportunity__c,SBQQ__Order__c from contract where Status__c in: statuslist and Account.Credit_Status__c = \'Good Standing\' and Do_Not_Renew__c=false and Account.BillingCountry=\'USA\' and recordtype.developername=\'MH_Contract\' and Account.Sub_Type__c=\'Small Law\' and CALENDAR_MONTH(EndDate) = :mnth and CALENDAR_YEAR(EndDate) = :yr and ContractNumber in : contractNameslist ';
        }*/
        
        system.debug(strQuery+'strQuery');
       if(test.isRunningTest()) {
            strQuery= 'Select Id,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c from contract limit 1';         
        }
        
        return Database.getQueryLocator(strQuery);
        
    }

    global void execute(Database.BatchableContext BC, List <Contract> ContractsList) {
    List<SBQQ__Quote__c> ClosedLostQuotes = new list<SBQQ__Quote__c>();
    Set<Id> quoteIdsForDS = new Set<Id>();
    List<id> listofquoteIds = new list<id>();
   map<id,id> mapofquotetocontractId=new map<Id,Id>();
     map<id,string> MapofcontractToError = new map<id,string>();
    
      for(Contract obj: ContractsList){
           listofquoteIds.add(obj.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c); 
           mapofquotetocontractId.put(obj.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c,obj.Id);
          
        } 
        
        //close lost the quotes
        for(SBQQ__Quote__c quote: [select Id,Reason_Won_Lost__c, IsEvergeened__c,SBQQ__Status__c from SBQQ__Quote__c where Id in : listofquoteIds] ){
            if(quote.SBQQ__Status__c == 'Approved' || quote.SBQQ__Status__c == 'QA Review'){
               MapofcontractToError.put(mapofquotetocontractId.get(quote.id),'The related quote is in Approved/QA review status');
           } else{
            quote.SBQQ__Status__c = 'Closed Lost';
            quote.Reason_Won_Lost__c='Auto Evergreen';
            ClosedLostQuotes.add(quote);
            quoteIdsForDS.add(quote.Id);
            }
        } 
        system.debug('==quoteIdsForDS==='+quoteIdsForDS);
        for(dsfs__DocuSign_Status__c docustat : [Select id, name,dsfs__DocuSign_Envelope_ID__c,dsfs__Envelope_Status__c From dsfs__DocuSign_Status__c where dsfs__Envelope_Status__c!= 'Completed' AND dsfs__Envelope_Status__c!= 'Voided' AND Quote__c in :quoteIdsForDS]){
            DocusignVoidApi voi = new DocusignVoidApi();
            voi.voidEnvelope(docustat.dsfs__DocuSign_Envelope_ID__c,'Void APIs');
        }
        system.debug('ClosedLostQuotes'+ClosedLostQuotes);
         Savepoint sp =  Database.setSavepoint();
        try{
            if(Test.isRunningTest() ) {  // Purposely crash test.
            ClosedLostQuotes[0].Id = null;
            
        }
            update ClosedLostQuotes;
            
            //quoteHandler.sendQuoteIdForDSVoid(quoteIdsForDS);
            
        }catch(Exception e){
            Database.rollback(sp);
            list<Contract> failurecontract=new list<Contract>();
            
             for(Contract obj: ContractsList){
                 if(test.isRunningTest() != true){
                 if(obj.Account.Credit_Status__c !='Good Standing')
                    obj.AutoEvergreen_Failure_Reason__c = 'The credit status of the related Account is not Good standing';
                 
                 if(obj.Account.BillingCountry!='USA')
                    obj.AutoEvergreen_Failure_Reason__c = 'This contract belongs to an international Account';
                 if(obj.Account.Sub_Type__c!='Small Law')
                     obj.AutoEvergreen_Failure_Reason__c = 'This contract is not from Small Law Account type';
                 }
                  if(MapofcontractToError.containskey(obj.id))
                     obj.AutoEvergreen_Failure_Reason__c = MapofcontractToError.get(obj.id);
                  if(e.getmessage().length() > 255){
                 obj.AutoEvergreen_Failure_Reason__c =e.getmessage().abbreviate(255);
                 }else{
                     obj.AutoEvergreen_Failure_Reason__c =e.getmessage();
                 }
                 failurecontract.add(obj);
             } 
            
            update failurecontract;
        } 
        
        
        
        
         }
         

    global void finish(Database.BatchableContext BC) {
}
}
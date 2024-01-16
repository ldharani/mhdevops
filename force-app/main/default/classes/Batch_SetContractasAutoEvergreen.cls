/*
** Created by       : IJ
** Created Purpose  : To set the contract as Evergreen 
** Test class :  */

global class Batch_SetContractasAutoEvergreen implements Database.Batchable <SObject>,Database.Stateful  {

    //Start Method which retrieves the invoice records 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strQuery;
        list<string> statuslist = new list<string>{'Active'};
           Integer mnth = System.Today().MOnth();
        Integer yr = System.Today().Year();
       /* List<String> contractNameslist = System.Label.ContractsList_Autoevergreen.split(',');
        system.debug('contractNameslist : '+contractNameslist);
        if(!contractNameslist.contains('null')){*/
        
        strQuery= 'Select Id,Status__c,SBQQ__Quote__c,IsAutoEvergreenBatch__c,AutoEvergreen_Failure_Reason__c,SBQQ__RenewalForecast__c,SBQQ__RenewalQuoted__c,Marketing_Contact__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c ,EndDate,AccountId,Account.Credit_Status__c,Account.BillingCountry,Account.Sub_Type__c,SBQQ__RenewalOpportunity__c,SBQQ__Order__c from contract where  Status__c in: statuslist and Account.Credit_Status__c = \'Good Standing\' and Do_Not_Renew__c=false and Account.BillingCountry=\'USA\' and recordtype.developername=\'MH_Contract\' and Account.Sub_Type__c=\'Small Law\' and CALENDAR_MONTH(EndDate) = :mnth and CALENDAR_YEAR(EndDate) = :yr and IsEligibleForAutoEvg__c=true';
       /* }else{
        strQuery= 'Select Id,Name,Status__c,SBQQ__Quote__c,IsAutoEvergreenBatch__c,AutoEvergreen_Failure_Reason__c,SBQQ__RenewalForecast__c,SBQQ__RenewalQuoted__c,Marketing_Contact__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c ,EndDate,AccountId,Account.Credit_Status__c,Account.BillingCountry,Account.Sub_Type__c,SBQQ__RenewalOpportunity__c,SBQQ__Order__c from contract where Status__c in :statuslist and Account.Credit_Status__c = \'Good Standing\' and Do_Not_Renew__c=false and Account.BillingCountry=\'USA\' and recordtype.developername=\'MH_Contract\' and Account.Sub_Type__c=\'Small Law\' and CALENDAR_MONTH(EndDate) = :mnth and CALENDAR_YEAR(EndDate) = :yr and ContractNumber in:contractNameslist';
        
        
      }system.debug(strQuery+'strQuery'); */
      
       if(test.isRunningTest()) {
                strQuery= 'Select Id,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c,SBQQ__Order__c from contract limit 1';           
        }
        
        return Database.getQueryLocator(strQuery);
        
    }

    global void execute(Database.BatchableContext BC, List <Contract> ContractsList) {
        system.debug('scope : '+ContractsList);
    list<Id> LostContractIds = new list<Id>();
    List<SBQQ__Quote__c> ClosedLostQuotes = new list<SBQQ__Quote__c>();
    List<Contract> updateContracts = new list<Contract>();
    //list<Id> EvergreenedIds = new list<id>();
    list<Order> updateOrders = new list<Order>();
    list<orderItem> updateOrderItems = new list<Orderitem>();
    list<SBQQ__Subscription__c> updateSubs = new list<SBQQ__Subscription__c>();
    list<Id> orderids = new list<Id>();
    List<id> listofquoteIds = new list<id>();
    Set<Id> contractsWithCCProd = new Set<Id>();
    
          
        //update subscriptions
        
        for(SBQQ__Subscription__c obj:[select Id,SBQQ__Product__r.Name,SBQQ__Contract__c,Status__c from SBQQ__Subscription__c where SBQQ__Contract__c in:ContractsList and Status__c = 'Active']){
            if(obj.SBQQ__Product__r.Name == 'Custom Content'){
                contractsWithCCProd.add(obj.SBQQ__Contract__c);
            }else{
            obj.Status__c= 'Renewed';
           updateSubs.add(obj);
            }
        } system.debug('updateSubs'+updateSubs);
        
        
        //update contracts to create opportunity
        for(Contract obj: ContractsList){
            if(contractsWithCCProd.contains(obj.Id) == false){
            obj.SBQQ__RenewalForecast__c=true;
            obj.SBQQ__RenewalQuoted__c=true;
            obj.Status__c = 'Evergreened';
            obj.IsAutoEvergreenBatch__c=true;
            obj.IsEvergeened__c = true;
           // EvergreenedIds.add(obj.Id);
            orderids.add(obj.SBQQ__Order__c);
         updateContracts.add(obj);
            }
        } 
        
        //update orders
        for(Order obj : [select Id,Status__c from order where Id in :orderids]){
         obj.Status__c='Evergreened';
         updateOrders.add(obj);
         //orderids.add(obj.Id);
        } system.debug('orderids'+orderids);
            
        
        //update Orderitem
        for(orderItem obj:[select id,SBQQ__Contract__c,Status__c from orderItem where OrderId in :orderids]){
           obj.Status__c='Renewed';
           updateOrderItems.add(obj);
        } 
        
        
        Savepoint sp =  Database.setSavepoint();
        try{
            update updateContracts; 
           update updateOrders;
           update updateOrderItems;
           update updateSubs;
        }catch(Exception e){
            Database.rollback(sp);
            list<Contract> failurecontract=new list<Contract>();
             for(Contract obj: ContractsList){
              if(contractsWithCCProd.contains(obj.Id))
                 obj.AutoEvergreen_Failure_Reason__c = 'The quote of this contract contains custom content product';
              if(e.getmessage().length() > 255){
                 obj.AutoEvergreen_Failure_Reason__c =e.getmessage().abbreviate(255);
                 }else{
                     obj.AutoEvergreen_Failure_Reason__c =e.getmessage();
                 }
                 failurecontract.add(obj);
             } update failurecontract;
        }
         }
         

    global void finish(Database.BatchableContext BC) {
}
}
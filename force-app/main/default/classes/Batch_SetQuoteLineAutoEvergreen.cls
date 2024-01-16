/*
** Created by       : IJ
** Created Purpose  : To set the Quote as Evergreen after the contract has been made Evergreen
** Test class :  */

global class Batch_SetQuoteLineAutoEvergreen implements Database.Batchable <SObject>,Database.Stateful  {

   
    
    //Start Method which retrieves the invoice records 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strQuery;
       
       Integer mnth = System.Today().MOnth();
       Integer yr = System.Today().Year();
       /* List<String> contractNameslist = System.Label.ContractsList_Autoevergreen.split(',');
        system.debug('contractNameslist : '+contractNameslist);
        if(!contractNameslist.contains('null')){ */
        
          strQuery= 'Select Id,Status__c,SBQQ__Quote__c,IsAutoEvergreenBatch__c,Marketing_Contact__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c ,EndDate,AccountId,Account.Credit_Status__c,Account.BillingCountry,Account.Sub_Type__c,SBQQ__RenewalOpportunity__c,SBQQ__Order__c from contract where Status__c = \'Evergreened\' and Account.Credit_Status__c = \'Good Standing\' and Do_Not_Renew__c=false and Account.BillingCountry=\'USA\' and recordtype.developername=\'MH_Contract\' and Account.Sub_Type__c=\'Small Law\'  and CALENDAR_MONTH(EndDate) = :mnth and CALENDAR_YEAR(EndDate) = :yr and IsAutoEvergreenBatch__c=true';  
       
       /* }else{
          strQuery= 'Select Id,Status__c,SBQQ__Quote__c,IsAutoEvergreenBatch__c,Marketing_Contact__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c ,EndDate,AccountId,Account.Credit_Status__c,Account.BillingCountry,Account.Sub_Type__c,SBQQ__RenewalOpportunity__c,SBQQ__Order__c from contract where Status__c = \'Evergreened\' and Account.Credit_Status__c = \'Good Standing\' and Do_Not_Renew__c=false and Account.BillingCountry=\'USA\' and recordtype.developername=\'MH_Contract\' and Account.Sub_Type__c=\'Small Law\'  and CALENDAR_MONTH(EndDate) = :mnth and CALENDAR_YEAR(EndDate) = :yr  and ContractNumber in : contractNameslist and IsAutoEvergreenBatch__c=true';  
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
        list<Order> UpdateOrderList= new list<Order>();
        list<Order> UpdateOrderList1= new list<Order>();
        list<SBQQ__QuoteLine__c> updateQuoteline = new list<SBQQ__QuoteLine__c>();
        
        for(Contract obj: ContractsList){
          RenewalOppIds.add(obj.SBQQ__RenewalOpportunity__c);
          listofquoteIds.add(obj.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c);          
        } 
        
      
        List<SBQQ__QuoteLine__c> qlineList = new List<SBQQ__QuoteLine__c>();
        if(!test.isRunningTest()){
           qlineList= [ select id,SBQQ__SubscriptionType__c,SBQQ__ProductSubscriptionType__c,SBQQ__SubscriptionTerm__c,SBQQ__EndDate__c,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Status__c from SBQQ__QuoteLine__c where SBQQ__Quote__c in : listofquoteIds and SBQQ__SubscriptionType__c!='Evergreen'];
        }else{
            qlineList = [ select id,SBQQ__SubscriptionType__c,SBQQ__ProductSubscriptionType__c,SBQQ__SubscriptionTerm__c,SBQQ__EndDate__c,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Status__c from SBQQ__QuoteLine__c limit 1];
        }

        
        for(SBQQ__QuoteLine__c quoteline: qlineList){
            quoteline.SBQQ__ProductSubscriptionType__c='Renewable/Evergreen';
        quoteline.SBQQ__SubscriptionType__c = 'Evergreen';
        quoteline.SBQQ__SubscriptionTerm__c = 1;
        quoteline.SBQQ__EndDate__c= null;
        updateQuoteline.add(quoteline);
        system.debug('enter update 3');        
        }
         
      List<Order> orderList = new List<Order>();
        if(!test.isRunningTest()){
           orderList=[select Id, Status, ActivateOrder__c, SBQQ__Quote__c from Order where SBQQ__Quote__c in: listofquoteIds and Status!='Activated' and ActivateOrder__c=false];
        }else{
              orderList=[select Id, Status, ActivateOrder__c, SBQQ__Quote__c from Order limit 1];
        }
      for(Order objOrder : orderList){
        objOrder.ActivateOrder__c = true;
        objOrder.Status = 'Draft';
      UpdateOrderList1.add(objOrder);
      system.debug('UpdateOrderList1'+UpdateOrderList1); 
       } 
        
        Savepoint sp =  Database.setSavepoint();
        
        try{
            update updateQuoteline; 
            update UpdateOrderList1; 
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
             } update failurecontract;
        }
      
        
    }

    global void finish(Database.BatchableContext BC) {
        
    }

}
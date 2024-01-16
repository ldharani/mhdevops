global class ExistingAccountsOrderStatusHandlBatch implements Database.Batchable<sObject>  {
    
     global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('@@@in start');
             string mainquery = '';
             string query = 'select Id, Name,' + 
                                   ' MH_Cust_Number__c, Order_Status__c,Acquisition_date__c,'+
                                   ' Customer_Status__c, Organization_Type__c, '+
                                   ' Re_acquisition_date__c, Loss_Date__c '+
                                   ' from account'+
                                   ' where MH_Cust_Number__c !=null'+
                                   ' and Organization_Type__c !=null'+
                                   //' and (Organization_Type__c = \'Law Firm\' OR Organization_Type__c = \'Corporation\')'+
                                   ' and Customer_Status__c = null';
             
             /*return Database.getQueryLocator([select Id, Name,  
                                           MH_Cust_Number__c, Order_Status__c,
                                           Customer_Status__c, Organization_Type__c
                                           from account 
                                            where MH_Cust_Number__c !=null
                                             //and Order_Status__c = null  : removed to avoid customer status pblm
                                             and Customer_Status__c = null
                                             and (Organization_Type__c = 'Law Firm'
                                                   OR Organization_Type__c = 'Corporation')
                                                ]);*/
                 
         if(test.isRunningTest()){
             query = query.remove('and Customer_Status__c = null');
             query +=  '  order by CreatedDate DESC LIMIT 200';              
           

         }
         system.debug('@@@@query'+ query);
          
         
         return Database.getQueryLocator(query);
        
        
       }
    
     global void execute(Database.BatchableContext BC, List<account> accList){
        
            System.debug('@@@@Start  Execution');
            system.debug('@@@@ acclist'+ acclist);
            ExistingAcctsOrderStatusHandling.orderStatusHandlingforExistingaccts(accList);
    
        
      }
    
    global void finish(Database.BatchableContext BC){
        
    }
    

}
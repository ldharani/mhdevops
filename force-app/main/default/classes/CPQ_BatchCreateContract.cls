global class CPQ_BatchCreateContract implements Database.Batchable<sObject> {
     
     global Set<id> Orderids ;  
     
     global CPQ_BatchCreateContract (Set<id> ord){
      
      system.debug(' @@@@@ In constructor list : '+Ord);
      Orderids  = Ord;
      
       
     }
     
     global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('@@@in start');
        system.debug(' @@@@@ In start list : '+Orderids);
         //Set<id> newords = new Set<id>();  

        
     //  newords = Orderids; 
        string query = 'Select Id,Status,IsDataLoaded__c ,IsRebaseAmend__c ,SBQQ__Quote__r.IsDataLoaded__c, Type,Created_from_Order__c,Opportunity.SBQQ__RenewedContract__c,'+ 
                        'Opportunity.SBQQ__RenewedContract__r.SBQQ__Order__r.Status__c, Opportunity.SBQQ__RenewedContract__r.SBQQ__Order__c,'+
                        'Opportunity.SBQQ__AmendedContract__c,Opportunity.SBQQ__RenewedContract__r.Status__c,Opportunity.SBQQ__AmendedContract__r.IsRebased__c,SBQQ__Contracted__c,SBQQ__Quote__c FROM Order where ID IN:Orderids';
                        
                                                                      
                                              
                         
                       
                                                  
                                                  
         if(test.isRunningTest()){
             query += ' order by CreatedDate DESC Limit 5';
         }
         
        return Database.getQueryLocator(query); 
       
       }
    
       global void execute(Database.BatchableContext BC, List<Order > OrderList){
            Set<Id> setquoteIds = new Set<Id>();  
            System.debug('@@@@Start  Execution');
            system.debug('@@@@@OrderList' + OrderList);
          
                                 //user u = [select id, Name from User where Name = 'Linda Guzman' ];
           for(Order  Ord: OrderList){
               
               
          // if(Ord.IsDataLoaded__c =='Y'){
                                  
                     system.debug('@@@@@if ' + Ord.IsDataLoaded__c);
                      //Qte.SBQQ__Status__c ='Closed Won';
                      //Ord.Status = 'Activated';
                      Ord.SBQQ__Contracted__c = true;
                    
                  
                 //  }
                   
                   
                   
           }
           try{
               
               system.debug('@@@@@ OrderList update ' + OrderList);
               
               
                   
                   if(!OrderList.isEmpty()){
                       
                       system.debug('@@@@@ OrderList update ' + OrderList);
                       //update OrderList;
                       Database.update(OrderList);
                     
    
                   }
           
              
              
           }
           catch(exception e){
           
               system.debug('@@@@exception'+ e);
           }
           
        
      }
    
    global void finish(Database.BatchableContext BC){
    
        
        
    }

}
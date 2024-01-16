global class CPQ_BatchCreateOrderContract implements Database.Batchable<sObject>, Database.Stateful {
    
     global Set<id> newOrderids ;  
     global Database.QueryLocator start(Database.BatchableContext BC){
        newOrderids = new Set<id>();
        system.debug('@@@in start');
          
        
       
        string query = 'select Id, Name,'+ 
                                            'SBQQ__Ordered__c,SBQQ__Status__c,SBQQ__Primary__c,IsDataLoaded__c FROM SBQQ__Quote__c Where SBQQ__Ordered__c = False and IsDataLoaded__c =\'Y\' and Legacy_Order_Number_Sequence__c = 93 ';
                                            //(Legacy_Order_Number_Sequence__c = 1 OR Legacy_Order_Number_Sequence__c = 0 )';
                                            //Where IsDataLoaded__c =\'Y\'';
                                              
                                              
                                                   //SBQQ__Ordered__c ='False' and
                                                   
                                                  
                                                  
         if(test.isRunningTest()){
             query += ' order by CreatedDate DESC Limit 5';
         }
         
        return Database.getQueryLocator(query); 
       
       }
    
       global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c > QuoteList){
            Set<Id> setquoteIds = new Set<Id>();
            List<Order> Listoforders= new list<Order>();  
            System.debug('@@@@Start  Execution');
            system.debug('@@@@@QuoteList' + QuoteList);
          
                                 //user u = [select id, Name from User where Name = 'Linda Guzman' ];
           for(SBQQ__Quote__c Qte : QuoteList){
               
               
           if(Qte.IsDataLoaded__c =='Y'){
                                  
                     system.debug('@@@@@if ' + Qte.IsDataLoaded__c);
                      //Qte.SBQQ__Status__c ='Closed Won';
                      Qte.SBQQ__Ordered__c = true;
                      setquoteIds.add(Qte.id);    
                  
                   }
                   
                   
                   
           }
           try{
               
               //system.debug('@@@@@update ' + Trueupdate);
               
               
                   
                   if(!QuoteList.isEmpty()){
                       Database.update(QuoteList);
                      //quoteHandler.activateOrderfromQuote(setquoteIds);  
    
                   }
                   
                   
                 system.debug(' @@@@@ In Active Order  Update: ' );
                 for(Order ordr : [Select Id,Status,IsDataLoaded__c ,IsRebaseAmend__c ,SBQQ__Quote__r.IsDataLoaded__c, Type,Created_from_Order__c,Opportunity.SBQQ__RenewedContract__c,
                         Opportunity.SBQQ__RenewedContract__r.SBQQ__Order__r.Status__c, Opportunity.SBQQ__RenewedContract__r.SBQQ__Order__c,
                         Opportunity.SBQQ__AmendedContract__c,Opportunity.SBQQ__RenewedContract__r.Status__c,Opportunity.SBQQ__AmendedContract__r.IsRebased__c,SBQQ__Contracted__c,SBQQ__Quote__c FROM Order where SBQQ__Quote__c in :setquoteIds]){
                
                     if (ordr.SBQQ__Quote__r.IsDataLoaded__c == 'Y'){
                         system.debug(' @@@@@ In dataload Order  Update: ' );
                         //ordr.Status = 'Activated';
                         Listoforders.add(ordr);
                         newOrderids.add(ordr.id);
                 
                         }
                   
                 }
                 system.debug(' @@@@@ In dataload Order  newOrderids: '+newOrderids );
                  
                /* if(!Listoforders.isEmpty()){
                    
                     system.debug(' @@@@@ Order Update: ' + Listoforders);
                     update Listoforders;        
                 }*/
              
              
           }
           catch(exception e){
           
               system.debug('@@@@exception'+ e);
           }
           
        
      }
    
    global void finish(Database.BatchableContext BC){
    
        if(!Test.isRunningTest()){
             system.debug(' @@@@@ In Finish : '+newOrderids );
            Id batchJobId = database.executeBatch(new CPQ_BatchCreateContract (newOrderids),1);
            //Id batchJobId = database.executeBatch(new CPQ_BatchCreateContract (),5);
            }
        
        
    }

}
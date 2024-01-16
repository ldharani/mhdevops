//Author       : Sai
//Description  : Responsible for changing Order Status on account at every month end
//               which process by taking all orders for which service end data is month end date
//               and status is cancelled

global class BatchChangeaccountOrderStatusCancelled implements Database.Batchable<sObject>{

  
    
   // querying the orders for which status = cancelled 
   // and service end date = today as this class scheduled at every month end
   global Database.QueryLocator start(Database.BatchableContext BC){
      //Integer month = Date.today().month();
       //Date startDate = System.Date.today().toStartOfMonth(); 
      //Date endDate = startDate.addMonths(1).addDays(-1);
      Integer numberOfDays = Date.daysInMonth(date.today().year(), date.today().month()-1);
        Date lastDayOfprevMonth = Date.newInstance(date.today().year(), date.today().month()-1, numberOfDays);
       
      String query = 'Select id, Name, '+
                            ' invoiceit_s__Status__c,invoiceit_s__Service_End_Date__c, '+
                            ' invoiceit_s__Account__c From invoiceit_s__Job__c '+
                            ' Where (invoiceit_s__Status__c = \'Cancelled\'OR invoiceit_s__Status__c = \'Expired\') '+
                            ' AND invoiceit_s__Service_End_Date__c =: lastDayOfprevMonth';
       if(Test.isRunningTest()) {
            query += ' order by CreatedDate DESC LIMIT 5';
        }
                             
      return Database.getQueryLocator(query);
   }

     
   global void execute(Database.BatchableContext BC, List<invoiceit_s__Job__c> orderList){
       
       set<string> accids      = new set<String>();
       List<account> acclist   = new List<account>();
       List<account> accListToUpdate   = new List<account>();
       Set<Account> accSet = new Set<Account>();
      // Date startDate = System.Date.today().toStartOfMonth(); 
      //Date endDate = startDate.addMonths(1).addDays(-1);
       Integer numberOfDays = Date.daysInMonth(date.today().year(), date.today().month()-1);
        Date lastDayOfprevMonth = Date.newInstance(date.today().year(), date.today().month()-1, numberOfDays);
       system.debug('@@@endDate'+ lastDayOfprevMonth);
       
       //getting account ids
       accids    = genericUtilityClass.formingsetIDsfromList(orderList,'invoiceit_s__Account__c');
       system.debug('@@@accids'+ accids);
       List<invoiceit_s__Job__c> queriedorders = new List<invoiceit_s__Job__c>();
       List<Account> accountList = new list<Account>();
       map<id,list<invoiceit_s__Job__c>> accidVsorders = new map<id,list<invoiceit_s__Job__c>>();
       if(accids.size() > 0){
           for(account acc : [select id, Name, Order_Status__c,
                                     (select id, Name,
                                             invoiceit_s__Status__c
                                             From invoiceit_s__Job__r 
                                             where invoiceit_s__Status__c = 'Active' OR
                                                   invoiceit_s__Status__c = 'Evergreen' OR
                                                   (invoiceit_s__Status__c = 'Cancelled' AND invoiceit_s__Service_End_Date__c >:lastDayOfprevMonth  )
                                                    LIMIT 1)
                                     From Account 
                                      Where Id IN: accids]){
                 
                  system.debug('@@@acc.invoiceit_s__Job__r.size()'+ acc.invoiceit_s__Job__r.size());   
                   
                if(acc.invoiceit_s__Job__r.size() == 0){
                    for(invoiceit_s__Job__c o : orderList){
                        if(o.invoiceit_s__Status__c == 'Cancelled'){
                            acc.Order_Status__c = 'Cancelled';
                        }else if(o.invoiceit_s__Status__c == 'Expired'){
                            acc.Order_Status__c = 'Expired';
                        }
                        //acc.Order_Status__c = 'InActive';
                        acclist.add(acc);
                    }       
                }
                  
                 
            }
 
       }
        accSet.addAll(acclist);      
        System.debug('========Account Set to update====='+accSet); 
        accListToUpdate.addAll(accSet);
         System.debug('========Account List to update====='+accListToUpdate);
           try{
           if(accListToUpdate.size() > 0){
               update accListToUpdate;
           }
       }
       catch(exception ex){
           system.debug('@@@@ Exception'+ ex);
       }
   
       
       
   }

   global void finish(Database.BatchableContext BC){
   }
}
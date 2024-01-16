global class BatchupdatePaymentmethod implements Database.Batchable<sObject> {
    
     global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('@@@in start');
          
        // forming date filed for filter
        Date forFilterInv = date.newInstance(date.today().year(), date.today().month(), 01);
        String jvinvoiceRectype =  RecordTypesFinalStringsClass.RecTypeName_JV_Invoice;
        system.debug('@@@forFilterInv'+forFilterInv);
        Date currentday= system.today();
        string query = 'select Id, Name,'+ 
                                              '  invoiceit_s__Payment_Method__c,'+
                                                   ' invoiceit_s__Account__c,Auto_Pay__c,invoiceit_s__Default__c,'+
                                                   ' RecordType.Name'+                                                  
                                                   ' from invoiceit_s__Payment_Method__c'+ 
                                                   ' where  Autopay_Updated_Date__c =: currentday';
                                                   //' where id = \'a0L03000001EqVd\'';
                                                   
                                                  
                                                  
         if(test.isRunningTest()){
             query += ' order by CreatedDate DESC Limit 5';
         }
         
        return Database.getQueryLocator(query); 
       
       }
    
       global void execute(Database.BatchableContext BC, List<invoiceit_s__Payment_Method__c> PMList){
            list <invoiceit_s__Payment_Method__c > Trueupdate = new list <invoiceit_s__Payment_Method__c >();
            list <invoiceit_s__Payment_Method__c > falseupdate = new list <invoiceit_s__Payment_Method__c >();
            System.debug('@@@@Start  Execution');
            system.debug('@@@@@PMList' + PMList);
          
                                 //user u = [select id, Name from User where Name = 'Linda Guzman' ];
           for(invoiceit_s__Payment_Method__c PM : PMList){
               
               
           if(PM.Auto_Pay__c == True && PM.invoiceit_s__Default__c == false){
                                  
                     system.debug('@@@@@if ' + PM.Auto_Pay__c);
                      PM.invoiceit_s__Default__c = True;
                      Trueupdate.add(PM);
                      
                  
                   }
                   
                   
             else if(PM.Auto_Pay__c == false && PM.invoiceit_s__Default__c == True ){
                     
                       system.debug('@@@@@ else if ' + PM.Auto_Pay__c);           
                     
                      PM.invoiceit_s__Default__c = false;
                      
                   falseupdate.add(PM);
                   }               
           }
           try{
               system.debug('@@@@@update ' + falseupdate);
               system.debug('@@@@@update ' + Trueupdate);
               
               for(invoiceit_s__Payment_Method__c PM : PMList){
                   
                   if(!falseupdate.isEmpty()){
                       Database.update(falseupdate);
    
                   }
               }
               
               
               if(!Trueupdate.isEmpty()){
                  Database.update(Trueupdate);
                  // update PMList;

               }
              
           }
           catch(exception e){
           
               system.debug('@@@@exception'+ e);
           }
           
        
      }
    
    global void finish(Database.BatchableContext BC){
    
        
        
    }

}
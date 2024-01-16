public with sharing class ClassAfterOnInvoiceRun {
  
  public void handleBeforerOnJob(map<Id,invoiceit_s__Invoice_Run__c> newMap, map<Id,invoiceit_s__Invoice_Run__c> oldMap) 
  {
    invoiceit_s__Invoice_Run__c invRunOld;
      set<Id> setofRun = new set<Id>();
      string sQuery = '';
      
      for(invoiceit_s__Invoice_Run__c invRun : newMap.values()) {
          invRunOld = oldMap.get(invRun.Id);
          if((invRun.invoiceit_s__Status__c != invRunOld.invoiceit_s__Status__c) 
              && (invRun.invoiceit_s__Status__c == 'Completed' || invRun.invoiceit_s__Status__c == 'Completed with errors')
              ) {
              setofRun.add(invRun.Id);
          }
      }
      
      if(!setofRun.isEmpty()) {
      String cronExpr = null;
                  String jobId  = null;           
                  Integer hours =  system.now().Hour();
                  Integer minutes = system.now().Minute() + 1;            
                  Integer seconds = 0;
                  Integer dayOfMonth = system.today().day();
                  Integer month =  system.today().month(); 
                  Integer year =  system.today().year();
                  String space = ' ';
                  String questionMark = '?';
                  String repeat  = '*';
                  String comma = ',';
  
      cronExpr = seconds+ space  + minutes+ space + hours + space +dayOfMonth+ space +month +space+ questionMark + space+  year;  
      System.schedule('BatchProcessArrearsInvoice '+system.now(),cronExpr,new RunScheduler(setofRun));
      }
  }
}
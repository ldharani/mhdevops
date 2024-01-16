global class MDL_BatchAutomateEvergreenoppClosedLost implements Database.Batchable<sObject>,Database.AllowsCallouts {

    public Set<Id> orderIds;
    global MDL_BatchAutomateEvergreenoppClosedLost(Set<Id> orderIdsgot){
        this.orderIds = orderIdsgot;

    }


     global Database.QueryLocator start(Database.BatchableContext BC) {
      
        String query = 'Select '+getObjectFields('invoiceit_s__Job__c')+' from invoiceit_s__Job__c where id IN:orderIds ';
        System.debug('Checking the Record Type'+query);
        if(Test.isRunningTest()){
            query += ' and invoiceit_s__Account__r.Name like \'%testAcc%\' LIMIT 5';
        }
        system.debug('@@@@query'+ query);
        return Database.getQueryLocator(query);
    }

      global void execute(Database.BatchableContext BC, List<invoiceit_s__Job__c> scope) {

        MDL_BatchAutoEvergreenHandler.OppsClosedLostWhenOppIsClosedWon(scope);
      }
     
      public static String getObjectFields(String objectName) {
        String sQuery = '';
        Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for(Schema.SObjectField column: objectFieldMap.values()) {
            sQuery += column+', ';
        }
        sQuery = sQuery.substring(0, sQuery.length()-2);
        sQuery += ' ';
        return sQuery;
        
         }
         
       global void finish(Database.BatchableContext BC) {

         Boolean dontExecute = false;
        for(AsyncApexJob batch :[Select ExtendedStatus,NumberOfErrors,Status,JobItemsProcessed,TotalJobItems from AsyncApexJob where Id = :BC.getJobId()]){         
            if(batch.TotalJobItems==batch.NumberOfErrors){
                dontExecute = true;
            }
        }
        if(dontExecute==false){
          MDL_BatchSendXMLAutomateEvergreenProcess b = new MDL_BatchSendXMLAutomateEvergreenProcess(Date.Today());
          Database.executeBatch(b,9);
         } 
       }


}
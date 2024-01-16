public with sharing class IIT_ControllerInvoiceRun {
   public invoiceit_s__Invoice_Run__c runObj {get;set;}
   public IIT_ControllerInvoiceRun(ApexPages.StandardController stdController) {
      runObj = (invoiceit_s__Invoice_Run__c )stdController.getrecord();
      runObj = [SELECT Id,Name FROM invoiceit_s__Invoice_Run__c  WHERE ID =:runObj.Id ];
   }
   
   
   public pagereference isExecuteBatch(){
     string sQuery = 'SELECT Name FROM invoiceit_s__Invoice__c where invoiceit_s__Invoice_Run_Created_By__c =\'' +runObj.Id+ '\' And invoiceit_s__Invoice_Status__c = \'Draft\'';
     IIT_BatchInvoiceStatusUpdate  b = new IIT_BatchInvoiceStatusUpdate(sQuery );
     database.executebatch(b);
     Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'Batch job has been started, the invoice will posted soon'));
     return null;
   
   }
}
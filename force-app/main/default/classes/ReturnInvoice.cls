global class ReturnInvoice implements Database.Batchable<sObject>
{
    global final String Query;

    global ReturnInvoice (String q)
    {
       Query=q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
       return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,List<sObject> scope)
    {
          List <invoiceit_s__Invoice__c> modifiedContacts = new list<invoiceit_s__Invoice__c>();
          for(Sobject s : scope)
          {
              invoiceit_s__Invoice__c  a = (invoiceit_s__Invoice__c)s;
              modifiedContacts.add(a);
          }
          //update modifiedContacts;
    }

    global void finish(Database.BatchableContext BC)
    {
    }
}
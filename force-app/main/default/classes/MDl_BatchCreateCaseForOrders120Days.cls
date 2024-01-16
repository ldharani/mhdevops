global class MDl_BatchCreateCaseForOrders120Days implements Database.Batchable<sObject> {
    global String query;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date renewDate = Date.today().addMonths(4).toStartOfMonth().addDays(-1);
        String query =  'Select i.Id,i.invoiceit_s__Account__r.OwnerId,i.invoiceit_s__Account__r.Owner.Name, i.invoiceit_s__Account__r.Name,'+
                        'i.invoiceit_s__Account__c,i.invoiceit_s__Shipping_Contact__c From invoiceit_s__Job__c i where i.invoiceit_s__Service_End_Date__c = : renewDate';
        if(Test.isRunningTest()) {
            query += ' LIMIT 5';
        }
        return Database.getQueryLocator(query); 
    }
    global void execute(Database.BatchableContext BC, List<invoiceit_s__Job__c> scope) {
        List<Case> lstCases = new List<Case>();
        RecordType r = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType = 'Case' and r.Name = 'MDL Oppty Renew' LIMIT 1];
        for(invoiceit_s__Job__c job : scope) {
            Case c = new Case();
            c.AccountId = job.invoiceit_s__Account__c;
            c.RecordTypeId = r.Id;
            c.Subject = 'Subscription Renewal for '+job.invoiceit_s__Account__r.Name;
            c.Description = 'Account is due for renewal within 120 days';
            c.Priority = 'Medium';
            c.Area__c = 'Opportunity';
            c.Sub_Area__c = 'Renewal';
            c.Parent_Order__c = job.Id;
            c.ContactId = job.invoiceit_s__Shipping_Contact__c;
            c.OwnerId = job.invoiceit_s__Account__r.OwnerId;
            lstCases.add(c);
        }
        if(lstCases.size() > 0) {
            Database.insert(lstCases);
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}
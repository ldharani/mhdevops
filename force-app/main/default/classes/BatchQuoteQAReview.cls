global class BatchQuoteQAReview implements Database.Batchable<Sobject>,Database.Stateful {
	List<SBQQ__Quote__c> quotesToBeUpdated = new List<SBQQ__Quote__c>();
    Date startOfMonth = Date.today().toStartOfMonth();
	Date startOfNextMonth = startOfMonth.addMonths(1);
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        //get all quotes with qa review and start date belonging to current month
        String testQuery = 'select id,name,SBQQ__Status__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Opportunity2__r.name,SBQQ__SubscriptionTerm__c FROM SBQQ__Quote__c limit 1 ';
        String query='select id,name,SBQQ__Status__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Opportunity2__r.name,SBQQ__SubscriptionTerm__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c=\'QA Review\' AND  SBQQ__StartDate__c >= :startOfMonth AND SBQQ__StartDate__c < :startOfNextMonth  ';
       	if(!test.isRunningTest())
        	return Database.getQueryLocator(query);
        else
            return Database.getQueryLocator(testQuery);
    }
    
    global void execute(Database.BatchableContext bc,List<SBQQ__Quote__c> scope)
    {        
        System.debug('SCOPE'+scope.size());
        System.debug('SCOPE'+scope); 
        for(SBQQ__Quote__c quote:scope )
        {
            Date addSubTermMonths = startOfNextMonth.addMonths(Integer.valueOf(quote.SBQQ__SubscriptionTerm__c)); 
            quote.SBQQ__StartDate__c = startOfNextMonth;
            if(!quote.SBQQ__Opportunity2__r.name.startsWith('Mid-Term for Contract'))
            {
                quote.SBQQ__EndDate__c = addSubTermMonths;
            }	
            quotesToBeUpdated.add(quote); 
        }

        if(!quotesToBeUpdated.isEmpty())
        {
            update quotesToBeUpdated;
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
   
}
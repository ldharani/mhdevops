public class Update_Dates_ForQuotesInQAReview {
	public Update_Dates_ForQuotesInQAReview()
    {
        List<SBQQ__Quote__c> quotesToBeUpdated = new List<SBQQ__Quote__c>();
   
        Date startOfMonth = Date.today().toStartOfMonth();
		Date startOfNextMonth = startOfMonth.addMonths(1); 
        List<SBQQ__Quote__c> quoteList = [select id,name,SBQQ__Status__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Opportunity2__r.name,SBQQ__SubscriptionTerm__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='QA Review' AND  SBQQ__StartDate__c >= :startOfMonth AND SBQQ__StartDate__c < :startOfNextMonth];
   		
        for(SBQQ__Quote__c quote:quoteList )
        {
            if(quote.SBQQ__SubscriptionTerm__c!=null){
            Date addSubTermMonths = startOfNextMonth.addMonths(Integer.valueOf(quote.SBQQ__SubscriptionTerm__c)); 
            quote.SBQQ__StartDate__c = startOfNextMonth;
            if(!quote.SBQQ__Opportunity2__r.name.startsWith('Mid-Term for Contract'))
            {
                quote.SBQQ__EndDate__c = addSubTermMonths;
            }	
            quotesToBeUpdated.add(quote); 
            }
        }

        if(!quotesToBeUpdated.isEmpty())
        {
            System.debug('quotesToBeUpdated'+quotesToBeUpdated);
            update quotesToBeUpdated;
        }
    }
}
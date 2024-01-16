public with sharing class MDL_NewOpportunityPageCtrl {
	private ApexPages.StandardController standardController;
	public MDL_NewOpportunityPageCtrl(ApexPages.StandardController standardController){
		this.standardController = standardController;
	}
	public pageReference redirectPage(){
		String accountId = ApexPages.currentPage().getParameters().get('accId');
		String recordTypeId;
		
		Schema.DescribeSObjectResult r = Opportunity.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
		for(RecordType rt : [Select Id from RecordType where DeveloperName = 'MH_Opportunity']){
			recordTypeId = rt.Id;
		}
		String pageRefConstruct;
		pageRefConstruct = '/'+keyPrefix;
		if(accountId != null){
			pageRefConstruct += '/e?retURL=%2F'+accountId;
		}
		else{
			pageRefConstruct += '/e?retURL=%2F'+keyPrefix+'%2Fo';
		}
		if(accountId != null)
            pageRefConstruct += '&accid='+accountId;
        if(recordTypeId != null)
            pageRefConstruct += '&RecordType='+recordTypeId;            
        pageRefConstruct += '&nooverride=1';
        
        return new Pagereference(pageRefConstruct);
	}
}
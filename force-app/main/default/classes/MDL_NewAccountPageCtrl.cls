public with sharing class MDL_NewAccountPageCtrl {
	private ApexPages.StandardController standardController;
	public MDL_NewAccountPageCtrl(ApexPages.StandardController standardController){
		this.standardController = standardController;
	}
	public pageReference redirectPage(){
		String recordTypeId;
		
		Schema.DescribeSObjectResult r = Account.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
		for(RecordType rt : [Select Id from RecordType where DeveloperName = 'MH_Accounts']){
			recordTypeId = rt.Id;
		}
		String pageRefConstruct;
		pageRefConstruct = '/'+keyPrefix+'/e?retURL=%2F'+keyPrefix+'%2Fo';
        if(recordTypeId != null)
            pageRefConstruct += '&RecordType='+recordTypeId;            
        pageRefConstruct += '&nooverride=1';
        
        return new Pagereference(pageRefConstruct);
	}
}
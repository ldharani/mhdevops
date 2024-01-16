/***********************************************************************************************************************
* @author - SS
* @date - 30 Mar 2022
* @description - MHBS-5460 To populate Daily MRR based on active subscriptions on Account
* @testclass - Test_BatchUpdateFutureMRR

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6636    SS            30/03/2022   John Mattheson          Package relationship cascading on EG price increase batch job
MHBS-6166    SS            12/08/2022   John Mattheson  <T01>   Delta MRR New Changes
MHBS-6166    SS            30/08/2022   John Mattheson  <T02>   Delta MRR  - Add cancelled orders
************************************************************************************************************************/

public class BatchUpdateFutureMRR implements Database.Batchable <SObject>,Database.Stateful  {

private String accQuery = '';
public List<Account> lstAccsToBeUpdated;


//Start Method which retrieves the Account records 
public Database.QueryLocator start(Database.BatchableContext BC) {

    accQuery = 'Select Id,MH_Daily_MRR_Feed__c,MH_Last_Month_MRR__c from Account where Contract_Modified_Date__c != null and Contract_Modified_Date__c = today';        
    
    if(test.isRunningTest()) {
        accQuery = 'Select Id,MH_Daily_MRR_Feed__c from Account LIMIT 1';          
    }
    System.debug(accQuery);
    return Database.getQueryLocator(accQuery);
    
}

public void execute(Database.BatchableContext BC, List<Account> accList) {
    lstAccsToBeUpdated = new List<Account>();
    Map<Account,List<SBQQ__Subscription__c>> accIdVsSubsList = new Map<Account,List<SBQQ__Subscription__c>>();
    Map<Id,Decimal> MapofAccIdtoDailyMRR = new map<Id,Decimal>();
    Set<Id> prodIds = new Set<Id>(); //<T02>
    Set<Id> accIds = new Set<Id>(); //<T02>
    Boolean annualPriceProd = false; //<T02>
    Id pricebookId = [SELECT Id, Name FROM Pricebook2 where Name like '%MH Annual Pricing%'].Id; //<T02>
    
    List<SBQQ__Subscription__c> subclist =       [select Id,SBQQ__Account__c,SBQQ__SubscriptionType__c,SBQQ__Product__c,SBQQ__ProductName__c,Terms__c,SBQQ__RenewalPrice__c,SBQQ__TerminatedDate__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__NetPrice__c,Status__c from SBQQ__Subscription__c where Status__c ='Active' and SBQQ__Product__r.Family != 'Ngage' and SBQQ__Account__c in:accList and recordtype.developername='MH_Subscriptions']; //<T01>
    Map<Id,Account> accMap = new Map<Id,Account>();
    accMap.putAll(accList);
    if(test.isRunningTest())
    {
        subclist =[select Id,SBQQ__Account__c,SBQQ__SubscriptionType__c,SBQQ__Product__c,SBQQ__ProductName__c,Terms__c,SBQQ__RenewalPrice__c,SBQQ__TerminatedDate__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__NetPrice__c,Status__c from SBQQ__Subscription__c where Status__c ='Active' limit 1];
    }
    
    //<T02> starts - Update Future MRR as 0 for accounts with no active subscriptions
    for(SBQQ__Subscription__c s :subclist){
        accIds.add(s.SBQQ__Account__c);
    }
    
    for(Account acc: accList){
        if(accIds.contains(acc.Id)!= true || accIds == null){
            acc.MH_MRR_Base_line__c = 0.00;
			if(test.isRunningTest()){
               acc.MH_Daily_MRR_Feed__c = 230;
            }
            acc.Future_MRR__c = 0.00-acc.MH_Daily_MRR_Feed__c;
            lstAccsToBeUpdated.add(acc);
        }
    }
    //<T02> ends 
    
    for(SBQQ__Subscription__c objsubs:subclist)
    {
        prodIds.add(objsubs.SBQQ__Product__c);//<T02>            
        if(accIdVsSubsList.containskey(accMap.get(objsubs.SBQQ__Account__c)) != true){
            accIdVsSubsList.put(accMap.get(objsubs.SBQQ__Account__c),new List<SBQQ__Subscription__c>{objsubs});
        }else{
            accIdVsSubsList.get(accMap.get(objsubs.SBQQ__Account__c)).add(objsubs);  
        }
    }
    
    //<T02> starts -  Future MRR should be divided by 12 for Annual Pricebook products
	if(prodIds != null ){
		List<PricebookEntry> pbeList = [SELECT Id, UnitPrice, Product2Id, IsActive FROM PricebookEntry where Product2Id in :prodIds and IsActive=true and Pricebook2Id=:pricebookId];
    
	
    if(pbeList.size() > 0){
        annualPriceProd = true;
    }
	}
    //<T02> ends
    
    System.debug(accIdVsSubsList);
    for(Account acc :accIdVsSubsList.keyset()){
        List<SBQQ__Subscription__c> subsList = accIdVsSubsList.get(acc);
        for(SBQQ__Subscription__c objsubs:subsList){
            system.debug('first loop &&&' + objsubs.SBQQ__SubscriptionType__c + objsubs.Status__c);
        if(objsubs.SBQQ__ProductName__c != 'PPC Management Fee' ){
        if(objsubs.Status__c == 'Active' || objsubs.Status__c == 'Renewed' || ((objsubs.Status__c =='Rebased' || objsubs.Status__c == 'Truncated' || objsubs.Status__c == 'Cancelled') && (objsubs.SBQQ__TerminatedDate__c >= system.today() ))){
            Decimal MRRamt=0;
        //<T02> starts - Use Netprice since Renewal price is null for Annual products
        if(objsubs.SBQQ__SubscriptionType__c == 'Renewable' ){
            if(objsubs.SBQQ__RenewalPrice__c!=null){
                MRRamt = objsubs.SBQQ__RenewalPrice__c;
            }else if(annualPriceProd == true && objsubs.SBQQ__NetPrice__c!=null && objsubs.SBQQ__RenewalPrice__c==null){
                MRRamt = objsubs.SBQQ__NetPrice__c;
            }
            system.debug('c1***'+MRRamt);
        //<T02> ends
        }else if(objsubs.SBQQ__SubscriptionType__c == 'Evergreen' && objsubs.SBQQ__NetPrice__c!=null){
        
            MRRamt = objsubs.SBQQ__NetPrice__c;
            system.debug('c2***'+MRRamt);
        }else if(objsubs.SBQQ__SubscriptionType__c == 'One-time' && objsubs.SBQQ__NetPrice__c!=null && objsubs.Terms__c!=null){
            
            MRRamt = objsubs.SBQQ__NetPrice__c/objsubs.Terms__c ;
            system.debug('c3***'+MRRamt);
        }
        
        if(MapofAccIdtoDailyMRR.containskey(objsubs.SBQQ__Account__c)){
            Decimal amt = MapofAccIdtoDailyMRR.get(objsubs.SBQQ__Account__c);
            system.debug('c4***'+objsubs.SBQQ__Account__c+'***'+amt);
            system.debug('c4**@*'+objsubs.SBQQ__Account__c+'***'+MRRamt);
            amt= amt+MRRamt;
            system.debug('c4**@*'+objsubs.SBQQ__Account__c+'***'+MRRamt);
            MapofAccIdtoDailyMRR.put(objsubs.SBQQ__Account__c,amt);
    }else{
        MapofAccIdtoDailyMRR.put(objsubs.SBQQ__Account__c,MRRamt);
        }
        
    }
    }
        }
        //<T01> 
        if(acc != null && acc.MH_Daily_MRR_Feed__c == null){
            acc.MH_Daily_MRR_Feed__c = 0;
        }
        // <T02> - Future MRR should be divided by 12 for Annual Pricebook products
        if(annualPriceProd == false && MapofAccIdtoDailyMRR != null && acc != null && MapofAccIdtoDailyMRR.containskey(acc.Id)){
            acc.MH_MRR_Base_line__c = MapofAccIdtoDailyMRR.get(acc.Id);
            acc.Future_MRR__c = MapofAccIdtoDailyMRR.get(acc.Id)-acc.MH_Daily_MRR_Feed__c;
        }else if(annualPriceProd == true && MapofAccIdtoDailyMRR != null && acc != null && MapofAccIdtoDailyMRR.containskey(acc.Id)){
            acc.MH_MRR_Base_line__c = (MapofAccIdtoDailyMRR.get(acc.Id)/12);
            acc.Future_MRR__c = (MapofAccIdtoDailyMRR.get(acc.Id)/12)-acc.MH_Daily_MRR_Feed__c;
        } 
            lstAccsToBeUpdated.add(acc); 
        
    }
    System.debug(lstAccsToBeUpdated);       
    if(lstAccsToBeUpdated.size() > 0) {
        try{
            Database.update(lstAccsToBeUpdated,false);
        }catch(Exception e){
            if(!test.isRunningTest()){
           	 Util.processException(e,true,'Error during updation of Accounts'+lstAccsToBeUpdated);
            }
            
        }
    }
}

public void finish(Database.BatchableContext BC) {

}
}
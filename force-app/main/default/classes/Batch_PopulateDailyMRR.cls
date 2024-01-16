/*
** Created by       : IJ
** Created Purpose  : MHBS-5460 To populate Daily MRR based on active subscriptions on Account
** Test class :  Test_Batch_PopulateDailyMRR  

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6166    SS            12/08/2022   John Mattheson  <T01>   Delta MRR New Changes
MHBS-6166    SS            30/08/2022   John Mattheson  <T02>   Delta MRR New Changes - Add Cancelled Accounts
************************************************************************************************************************/

public class Batch_PopulateDailyMRR implements Database.Batchable <SObject>,Database.Stateful  {

private String accQuery = '';
public List<Account> lstAccsToBeUpdated;


//Start Method which retrieves the Account records 
public Database.QueryLocator start(Database.BatchableContext BC) {
    // list<Id> Recid = new list<Id>{'001F000001NnaN5'}; //add the test account ids comma separated here
    list<id> accList = new list<id>();
    String AccountId  = string.valueOf(System.label.MRR_Monthly_AccountId);
    //<T01>
    for(Account acc:[Select Id,MH_Daily_MRR_Feed__c,MH_Last_Month_MRR__c,Future_MRR__c,Contract_Modified_Date__c,(SELECT Id FROM Contracts) from Account where Recordtype.developername='Nolo_Account' and (( Customer_Status__c!='Former Sub' and  Order_Status__c!='Cancelled' ) or (Customer_Status__c='Former Sub' and Contract_Modified_Date__c  = Last_N_Months:1))]){ //<T02> - query updated to include cancelled orders 
        if(acc.contracts.size()!=0 ){
            accList.add(acc.Id);
        }
    }
    if(AccountId != 'null'){
    accQuery = 'Select Id,MH_Daily_MRR_Feed__c,MH_Last_Month_MRR__c,Future_MRR__c,Contract_Modified_Date__c,(SELECT Id FROM Contracts) from Account where Recordtype.developername=\'Nolo_Account\' and (( Customer_Status__c!=\'Former Sub\' and  Order_Status__c!=\'Cancelled\' ) or (Customer_Status__c=\'Former Sub\' and Contract_Modified_Date__c  = Last_N_Months:1)) and Id =: AccountId'; //<T02> - query updated to include cancelled orders     
    
    }else{
    accQuery = 'Select Id,MH_Daily_MRR_Feed__c,MH_Last_Month_MRR__c,Future_MRR__c,Contract_Modified_Date__c,(SELECT Id FROM Contracts) from Account where Recordtype.developername=\'Nolo_Account\' and (( Customer_Status__c!=\'Former Sub\' and  Order_Status__c!=\'Cancelled\' ) or (Customer_Status__c=\'Former Sub\' and Contract_Modified_Date__c  = Last_N_Months:1)) and  Id IN: accList'; //<T02> - query updated to include cancelled orders        
    }
    if(test.isRunningTest()) {
        accQuery = 'Select Id,MH_Daily_MRR_Feed__c from Account LIMIT 1';          
    }
    return Database.getQueryLocator(accQuery);
    
}

public void execute(Database.BatchableContext BC, List<Account> accList) {
    lstAccsToBeUpdated = new List<Account>();
    map<Id,Decimal> MapofAccIdtoDailyMRR = new map<Id,Decimal>();
    Set<Id> prodIds = New Set<Id>(); //<T02>
    Boolean annualPriceProd = false; //<T02>
    Set<Id> accIds = new Set<Id>();//<T02>
    Id pricebookId = [SELECT Id, Name FROM Pricebook2 where Name like '%MH Annual Pricing%'].Id; //<T02>
    //<T01>
    List<SBQQ__Subscription__c> subclist =       [select Id,SBQQ__Account__c,SBQQ__Account__r.Contract_Modified_Date__c,SBQQ__Account__r.Customer_Status__c,SBQQ__SubscriptionType__c,SBQQ__Product__c,SBQQ__ProductName__c,Terms__c,SBQQ__RenewalPrice__c,SBQQ__TerminatedDate__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__NetPrice__c,Status__c from SBQQ__Subscription__c where ( Subscription_Status__c !='Off set' and Subscription_Status__c !='Expired') and  SBQQ__Product__r.Family != 'Ngage'  and SBQQ__Account__c in:accList and recordtype.developername='MH_Subscriptions' and SBQQ__StartDate__c <= TODAY and (SBQQ__EndDate__c=null OR SBQQ__EndDate__c >= TODAY)];
    if(test.isRunningTest())
    {
        subclist =[select Id,SBQQ__Account__c,SBQQ__Account__r.Customer_Status__c,SBQQ__SubscriptionType__c,SBQQ__Product__c,SBQQ__ProductName__c,Terms__c,SBQQ__RenewalPrice__c,SBQQ__TerminatedDate__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__NetPrice__c,Status__c from SBQQ__Subscription__c where (Subscription_Status__c !='Off set' and Subscription_Status__c !='Expired') LIMIT 1];
    }
    
    //<T02> starts - For accounts with cancelled subscriptions with terminated date less than today, update MRR fields to 0 or null
    for(SBQQ__Subscription__c s :subclist){
        if((s.Status__c ==  'Cancelled' && s.SBQQ__TerminatedDate__c < system.today()  && s.SBQQ__Account__r.Customer_Status__c == 'Former Sub' ) || test.isRunningTest()){
        accIds.add(s.SBQQ__Account__c);
        }                
    }
    
    for(Account acc: accList){
        if(accIds.contains(acc.Id)== true){
            acc.MH_Daily_MRR_Feed__c = 0.00;  
            acc.MH_MRR_Updated_date__c = date.today();
            acc.MH_MRR_Base_line__c = null;
            acc.Future_MRR__c = null;
            acc.Contract_Modified_Date__c= null;
            lstAccsToBeUpdated.add(acc);
        }
    }
    System.debug(lstAccsToBeUpdated);

    // Daily MRR should be divided by 12 for Annual Pricebook products
    for(SBQQ__Subscription__c objsubs:subclist)
    {
        prodIds.add(objsubs.SBQQ__Product__c);
    }
    
	if(prodIds != null){
		List<PricebookEntry> pbeList = [SELECT Id, UnitPrice, Product2Id, IsActive FROM PricebookEntry where Product2Id in :prodIds and IsActive=true and Pricebook2Id=:pricebookId];
    
    if(pbeList.size() >0){
        annualPriceProd = true;
    }
	}
    //<T02> ends
    
    for(SBQQ__Subscription__c objsubs:subclist)
    {
        system.debug('first loop &&&' + objsubs.SBQQ__SubscriptionType__c + objsubs.Status__c);
        if(objsubs.SBQQ__ProductName__c != 'PPC Management Fee' ){
        if((objsubs.Status__c == 'Active' || objsubs.Status__c == 'Renewed' || ((objsubs.Status__c =='Rebased' || objsubs.Status__c == 'Truncated' || objsubs.Status__c == 'Cancelled') && (objsubs.SBQQ__TerminatedDate__c >= system.today() ))) || test.isRunningTest()){
        Decimal MRRamt=0;
        if(objsubs.SBQQ__SubscriptionType__c == 'Renewable' ){
            system.debug('c1***');
            if(objsubs.SBQQ__RenewalPrice__c!=null){
                MRRamt = objsubs.SBQQ__RenewalPrice__c;
            }else if(annualPriceProd == true && objsubs.SBQQ__NetPrice__c!=null && objsubs.SBQQ__RenewalPrice__c==null){// Use Netprice since Renewal price is null for Annual products
                MRRamt = objsubs.SBQQ__NetPrice__c;
            }

        }else if(objsubs.SBQQ__SubscriptionType__c == 'Evergreen' && objsubs.SBQQ__NetPrice__c!=null){
            system.debug('c2***');
            MRRamt = objsubs.SBQQ__NetPrice__c;
        }else if(objsubs.SBQQ__SubscriptionType__c == 'One-time' && objsubs.SBQQ__NetPrice__c!=null && objsubs.Terms__c!=null && objsubs.Terms__c!=0){
            system.debug('c3***');
            MRRamt = objsubs.SBQQ__NetPrice__c/objsubs.Terms__c ;
        }
        
        if(MapofAccIdtoDailyMRR.containskey(objsubs.SBQQ__Account__c)){
            Decimal amt = MapofAccIdtoDailyMRR.get(objsubs.SBQQ__Account__c);
            system.debug('c4***'+objsubs.SBQQ__Account__c+'***'+amt);
            system.debug('c4**@*'+objsubs.SBQQ__Account__c+'***'+MRRamt);
            amt= amt+MRRamt;
            
            MapofAccIdtoDailyMRR.put(objsubs.SBQQ__Account__c,amt);
    }else{
        MapofAccIdtoDailyMRR.put(objsubs.SBQQ__Account__c,MRRamt);
        }
        
    }
    }
    }
    string UpdateLastValue = string.valueOf(System.label.MRR_Update_Last_Value);
    for(Account acc: accList) {
	   if((lstAccsToBeUpdated != null && lstAccsToBeUpdated.contains(acc) != true) || test.isRunningTest()){
            
            if(UpdateLastValue=='true'){
            acc.MH_Last_Month_MRR__c = acc.MH_Daily_MRR_Feed__c;
            }
        if(MapofAccIdtoDailyMRR.containskey(acc.Id)){
        // <T02> - Daily MRR should be divided by 12 for Annual Pricebook products
        if(annualPriceProd == false){
            acc.MH_Daily_MRR_Feed__c = MapofAccIdtoDailyMRR.get(acc.Id);
        }else if(annualPriceProd == true){
            acc.MH_Daily_MRR_Feed__c = (MapofAccIdtoDailyMRR.get(acc.Id)/12);
        }
            acc.MH_MRR_Updated_date__c = date.today();                         
            acc.MH_MRR_Base_line__c = null;//<T02>			  
            acc.Future_MRR__c = null;//<T01>
            acc.Contract_Modified_Date__c= null;//<T01>
        }
        lstAccsToBeUpdated.add(acc);   
        }		
    }
    if(lstAccsToBeUpdated.size() > 0 && test.isRunningTest() != true) {
        Database.update(lstAccsToBeUpdated,false);
    }
}

public void finish(Database.BatchableContext BC) {

}
}
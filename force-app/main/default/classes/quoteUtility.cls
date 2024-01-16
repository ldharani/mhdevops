public class quoteUtility { 
    Public Static   List<SBQQ__Quote__c > ListofQuotes= new list<SBQQ__Quote__c >();
    Public Static List<blng__PaymentGateway__c> paymntGateWay = new List<blng__PaymentGateway__c>();
    
    public static List<SBQQ__Quote__c> createOrderfromQuote(List<SBQQ__Quote__c> quoteLst){
        if(ListofQuotes.size() == 0){
            ListofQuotes = [Select id,SBQQ__Ordered__c ,SBQQ__PriceBook__c,Cancelled__c,SBQQ__StartDate__c,IsDataLoaded__c,SBQQ__Type__c ,Recordtype.developerName, SBQQ__Status__c,SBQQ__Primary__c FROM SBQQ__Quote__c Where Id in : quoteLst and SBQQ__Ordered__c = False];
        system.debug('@@@ ListofQuotes '+ListofQuotes );
        
        }
        return ListofQuotes; 
    }
    Public Static List<blng__PaymentGateway__c> getPaymntGateWay(){
        if(paymntGateWay.size() == 0){
            paymntGateWay = [select id, name, blng__Active__c  from blng__PaymentGateway__c 
                                                         where name='Nolo Gateway' AND blng__Active__c = TRUE];
        }
        return paymntGateWay;
    }
    
    public static List<SBQQ__Quote__c> getOppName(List<SBQQ__Quote__c> quoteLst){
        if(ListofQuotes.size() == 0){
            ListofQuotes = [Select id,SBQQ__Opportunity2__r.Name FROM SBQQ__Quote__c Where Id in : quoteLst];
        system.debug('@@@ ListofQuotes '+ListofQuotes );
        
        }
        return ListofQuotes; 
    }
    
}
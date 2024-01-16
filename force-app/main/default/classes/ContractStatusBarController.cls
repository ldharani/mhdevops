public class ContractStatusBarController {
    
    @AuraEnabled
    public static string getcontractstatus(string contrId){
        Id Contractid ; 
        Contractid = contrId;  
        string quoteId = '';
        List<Contract> contractsList = new List<Contract>();
        contractsList = [select Id, SBQQ__RenewalOpportunity__c,
                          SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c 
                          From Contract
                           Where SBQQ__RenewalOpportunity__c != NULL
                             AND SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c != NULL 
                              LIMIT 1];
        if(!contractsList.isEmpty()){
            quoteId = contractsList[0].SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c;
          
        }
            return quoteId;  
        
    }
    
    @AuraEnabled
    public static string getcontractstatusaction(string contrId){
        List<Contract> contractsList = new List<Contract>();
        contractsList = [select Id, Status__c 
                          From Contract where Id =: contrId
                              LIMIT 1];
        if(!contractsList.isEmpty()){
            if(contractsList[0].Status__c.containsIgnoreCase('in progress')){
                return 'Active';
            }
            return contractsList[0].Status__c;
        }
        return null;
    }

}
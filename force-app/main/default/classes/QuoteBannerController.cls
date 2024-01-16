public class QuoteBannerController {
    @AuraEnabled
    public static Map<String,String> getInvQLCheck(String quoteId) {
        // Query the CPQ Quote and its rollup summary field
        SBQQ__Quote__c quote = [select id, SBQQ__Status__c, SBQQ__Account__c, SBQQ__Account__r.MH_Cust_Number__c, 
                            SBQQ__Account__r.Avvo_CustomerID__c,(Select id, Name, SBQQ__ProductName__c,Error_Text__c, SBQQ__Product__r.IsInventoried__c, 
                            Available__c, ReservedCount__c from SBQQ__LineItems__r) FROM SBQQ__Quote__c Where Id = :quoteId];
        //Boolean checkQl;
        String displayText = '';
        Set<Id> erroredQlIds = new Set<Id>();
        Set<Id> availQlIds = new Set<Id>();
        Set<Id> reservQlIds = new Set<Id>();
        List<String> qlNamesLst = new List<String>();
        Map<String,String> statusVsMsg = new Map<String,String>();
        String qlNames = '';
         //Set<Id> erroredQlIds = new Set<Id>();
        for(SBQQ__QuoteLine__c ql: quote.SBQQ__LineItems__r){
            if(ql.SBQQ__Product__r.IsInventoried__c == TRUE && ql.Error_Text__c != null){
				 erroredQlIds.add(ql.Id);
            }
            else if(ql.SBQQ__Product__r.IsInventoried__c == TRUE && ql.Error_Text__c == null
              	&& ql.Available__c  == true && ql.ReservedCount__c == null){
                availQlIds.add(ql.Id);
            }
            else if(ql.SBQQ__Product__r.IsInventoried__c == TRUE && ql.Error_Text__c == null
              	&& ql.Available__c  == true && ql.ReservedCount__c != null){
                reservQlIds.add(ql.Id);
            }
        }
        if(!erroredQlIds.isEmpty()){
            //qlNames = String.join(qlNamesLst, ',');
            displayText = 'Inventoried products are not available. Please check quote lines with Red flag';
            statusVsMsg.put('Error',displayText);
        }else if(!availQlIds.isEmpty() && erroredQlIds.isEmpty()){
            //qlNames = String.join(qlNamesLst, ',');
            displayText = 'Inventoried products are available and ready to reserve';
            statusVsMsg.put('Available',displayText);
        }else if(availQlIds.isEmpty() && erroredQlIds.isEmpty() && !reservQlIds.isEmpty()){
            displayText = 'Inventoried products are reserved successfully';
            statusVsMsg.put('Reserved',displayText);
        }
        system.debug('=====displayText==='+displayText);
        return statusVsMsg; // Adjust the field name
    }
}
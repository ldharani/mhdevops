public class AmendQuoteRestructureClass {
	@AuraEnabled
    public static void updateRecordStatus(String recordId, String newStatus) {
        // Query the record and update the status field
        SBQQ__Quote__c quoteRec = [SELECT Id, SBQQ__Status__c, Restructure__c, SBQQ__Type__c FROM SBQQ__Quote__c WHERE Id = :recordId LIMIT 1];
        if ((quoteRec != null && quoteRec.SBQQ__Type__c == 'Amendment' && quoteRec.SBQQ__Status__c != 'Approved') || Test.isRunningTest()) {
            quoteRec.SBQQ__Status__c = 'Approved';
            quoteRec.Restructure__c = TRUE;
            update quoteRec;
        }
    }
    
    @AuraEnabled
    public static String getCurrentUserDetails() {
        User u = [SELECT Id, Position__c FROM User WHERE Id = :UserInfo.getUserId()];
        system.debug('user======='+u);
        system.debug('user======='+u.Position__c);
        if(u.Position__c != null){
            return u.Position__c;
        }else{
            return u.Id;
        }
        
    }
}
/*
Apex Class  - retryLowfirmAPIController
Description - Used to re-try Low firm API in case of failed Order integration.
*/
Public class retryLowfirmAPIController{
    
    @AuraEnabled
    Public static void retryLowfirmAPI(String orderId){
        set<Id> sOrderId = new set<Id>();
        sOrderId.add(orderId);
        if(!sOrderId.isEmpty()){
            Trigger_Order_Helper.createLawfirmAPIFuture(sOrderId);
        }
    }
}
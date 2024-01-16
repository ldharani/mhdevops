public class OrderUtility {
    Public Static   List<Order> ListofOrders= new list<Order>();
    Public Static   List<Order> ListofXMLOrders= new list<Order>();
    Set<Id> setquoteIds = new Set<Id>(); 
    Set<Id> orderIds = new Set<Id>();
    
    public static Map<Id,Order> ordMap = new Map<Id,Order>();
    public static Map<Id,Order> getOrderCustomerNumber( Set<Id> ordIds){
        System.debug('Inside getOrderCustomerNumber');
        Id MNGOrderRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Ngage Order').getRecordTypeId();
        System.debug('Inside getOrderCustomerNumber' +ordIds);
         System.debug('Inside getOrderCustomerNumber' +MNGOrderRecTypeId);
        if(ordMap.size() == 0){
            ordMap = new Map<Id,Order>([Select Id,CustomerNumber__c,AccountId from order where id in :ordIds 
                                        AND RecordTypeID !=: MNGOrderRecTypeId]);
            System.debug('ordMap ' + ordMap);
        }
        return ordMap; 
    }
    public static  List<Order>  OrderQuoteids( Set<Id> setquoteIds ){
        if(ListofOrders.size() == 0){
            ListofOrders = [Select Id,Status,IsDataLoaded__c ,IsRebaseAmend__c ,SBQQ__Quote__r.SBQQ__EndDate__c,SBQQ__Quote__r.IsDataLoaded__c, Type,Created_from_Order__c,Opportunity.SBQQ__RenewedContract__c,
                          Opportunity.SBQQ__RenewedContract__r.SBQQ__Order__r.Status__c, Opportunity.SBQQ__RenewedContract__r.SBQQ__Order__c,
                          Opportunity.SBQQ__AmendedContract__c,Opportunity.SBQQ__RenewedContract__r.Status__c,Opportunity.SBQQ__AmendedContract__r.IsRebased__c,SBQQ__Contracted__c,SBQQ__Quote__c FROM Order where SBQQ__Quote__c in :setquoteIds];
        system.debug('@@@ ListofOrders'+ListofOrders);
        
        }
        return ListofOrders; 
    }
    
    
     public static  List<Order>  orderXMLids( Set<Id> orderIds ){
        if(ListofXMLOrders.size() == 0){
            ListofXMLOrders = [Select Id, IsXMLSent__c  From Order where Id in : orderIds AND IsXMLSent__c = False];
        system.debug('@@@ ListofXMLOrders'+ListofXMLOrders);
        
        }
        return ListofXMLOrders; 
    }
    
}
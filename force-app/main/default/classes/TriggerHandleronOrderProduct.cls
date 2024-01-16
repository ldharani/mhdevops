public class TriggerHandleronOrderProduct {
    public static void productSINGeneration(List<OrderItem> ordProdLst){
        List<SBQQ__QuoteLine__c > quoteLineLst = new List<SBQQ__QuoteLine__c>();
        List<OrderItem> UpdateOrdrProds = new List<OrderItem>();
        List<OrderItem> allOrdProds = [select id,SIN__c,OrderId,SBQQ__QuoteLine__c, 
                                        Order.CustomerNumber__c,Product2.ProductCode FROM 
                                        OrderItem WHERE ID IN:ordProdLst];
        system.debug('==allOrdProds=='+allOrdProds);        
        for(OrderItem op: allOrdProds){
            system.debug('==op.Order.CustomerNumber__c=='+op.Order.CustomerNumber__c);
            if(op.SIN__c == NULL){
                op.SIN__c = op.Order.CustomerNumber__c+'.'+
                            op.Product2.ProductCode+'.'+
                            op.Id;
                UpdateOrdrProds.add(op);
            }
        }
        if(!UpdateOrdrProds.isEmpty()){
           update UpdateOrdrProds; 
        }
    }
    /*
    public static void updateTruncateRebaseStatus(List<OrderItem> ordProdLst){
    
        List<OrderItem> UpdateOrdrProds = new List<OrderItem>();
        Map<Id, OrderItem> ordrprodMap = new Map<Id, OrderItem>();
        List<OrderItem> allOrdProds = [select id,SIN__c,OrderId,Quantity,SBQQ__QuoteLine__c,SBQQ__RevisedOrderProduct__r.Status__c , Status__c,SBQQ__RevisedOrderProduct__c,SBQQ__TerminatedDate__c 
                                         FROM 
                                        OrderItem WHERE ID IN:ordProdLst];
                                        
        system.debug('==List of order Products=='+allOrdProds); 
        
        if(!allOrdProds.isEmpty()){
           for(OrderItem ordprod: allOrdProds){
           //ordprod.SIN__c != NULL &&
           system.debug('==All Products =='+ordprod.Quantity);
           
            if( ordprod.SBQQ__RevisedOrderProduct__c != NULL  ){
            //&& ordprod.SBQQ__TerminatedDate__c != NUll ){
                system.debug('== Order product Quantity=='+ordprod.Quantity);
                If(ordprod.Quantity < 0){
                    system.debug('==In truncated update');
                   ordprod.SBQQ__RevisedOrderProduct__r.Status__c = 'Truncated' ;
                    UpdateOrdrProds.add(ordprod);
                }
                
                 for(OrderItem ordprd: UpdateOrdrProds){
                    ordrprodMap.put(ordprd.Id, ordprd);
                 }
                
                
            }
        }
        //if(!UpdateOrdrProds.isEmpty()){
        
        //system.debug('==update on order products =='+UpdateOrdrProds); 
        //   Database.update(UpdateOrdrProds); 
       // }
       
        if(!ordrprodMap.values().isEmpty()){
            update ordrprodMap.values();            
        }
    }
        
          
    
    }*/
}
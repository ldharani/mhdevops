public class ChatOrderHelper {
    
    public static void chatorderManagement(List<invoiceit_s__Job__c > orderList){
        
        Set<Id> parentOptyIds                           = new Set<Id>();
        Map<Id,Id> optyIdVsParentId                     = new Map<Id,Id>();
        Map<Id,invoiceit_s__Job__c> parentoptyIdVsOrder = new Map<Id,invoiceit_s__Job__c>();
       
        for(invoiceit_s__Job__c order: orderList){
            if(order.invoiceit_crmx__Opportunity__c != NULL){
                parentOptyIds.add(order.invoiceit_crmx__Opportunity__c);
            } 
        }
        System.debug('@@@@@@@@@@@@@@@parentOptyIds'+parentOptyIds);

        if(!parentOptyIds.isEmpty()){
            for(Opportunity opp : [select id, Parent_Opportunity__c from opportunity 
                               where id IN:parentOptyIds AND Parent_Opportunity__c != NULL]){
             optyIdVsParentId.put(opp.id,opp.Parent_Opportunity__c);                        
           }
        }
        
        
        if(!optyIdVsParentId.isEmpty()){
            for(invoiceit_s__Job__c order : [select id, invoiceit_crmx__Opportunity__c
                                                    From invoiceit_s__Job__c 
                                             where invoiceit_crmx__Opportunity__c IN:optyIdVsParentId.values()]){
                 parentoptyIdVsOrder.put(order.invoiceit_crmx__Opportunity__c,order);                                
             }
        }
        System.debug('@@@@@@@@@@@@@@@parentoptyIdVsOrder'+parentoptyIdVsOrder);
        System.debug('@@@@@@@@@@@@@@@optyIdVsParentId'+optyIdVsParentId);

        
        
        for(invoiceit_s__Job__c order: orderList){
            if(order.invoiceit_crmx__Opportunity__c != NULL){
                if(optyIdVsParentId.containsKey(order.invoiceit_crmx__Opportunity__c)){
                    Id tempId = optyIdVsParentId.get(order.invoiceit_crmx__Opportunity__c);
                    System.debug('@@@@@@@@@@@@@@@tempId '+tempId );

                    if(parentoptyIdVsOrder.containsKey(tempId)){
                        order.Parent_Order__c = parentoptyIdVsOrder.get(tempId).Id;
                    }
                     System.debug('@@@@@@@@@@@@@@@order.Parent_Order__c'+order.Parent_Order__c);
                }
            }
        }
        
        
        
        
        
        
    }

}
public class ChatProductOCTriggerHandler {
    
    public static void attributeRelationship(List<Chat_Product_Opportunity_Charge__c> corpcList){
        
       system.debug('@@@@ In attributeRelationship');
        Set<Id>chargeIds   = new Set<Id>();
        //List<Opportunity_Charge_Attribute__c> attribstoUpdate = new List<Opportunity_Charge_Attribute__c>();
        Map<id,Opportunity_Charge_Attribute__c>attribstoUpdate  = new Map<id,Opportunity_Charge_Attribute__c>();
        for(Chat_Product_Opportunity_Charge__c corpc:corpcList ){
            chargeIds.add(corpc.Chat_Product_Opp_Rate_Plan_Charge__c);
            chargeIds.add(corpc.Chat_Usage_Opp_Rate_Plan_Charge__c);
            
        }
        
        system.debug('@@@chargeIds'+chargeIds);
        If(!chargeIds.isEmpty()){
            
        
             Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> orpcMap = 
                 new Map<id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>([select id,name,
                              (select id,Name,ParentOpportunityChargeAttribute__c
                                   From Opportunity_Charge_Attributes__r
                                 where (Attribute_Name__c = 'URL' OR Attribute_Name__c = 'Domain Name'
                                        ))
                               From invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                                                                              where id IN:chargeIds ]);
                                         // AND invoiceit_crmx__Accounting_Code__c != '11006']);
            system.debug('@@@orpcMap'+orpcMap);
            for(Chat_Product_Opportunity_Charge__c corpc:corpcList ){
               
               
                Opportunity_Charge_Attribute__c urlAttributeChild = new Opportunity_Charge_Attribute__c();
                 Opportunity_Charge_Attribute__c urlAttributeparent = new Opportunity_Charge_Attribute__c();
                 if(corpc.Chat_Product_Opp_Rate_Plan_Charge__c != NULL ){
                    //  system.debug('@@@@@orpcMap.get(corpc.Chat_Product_Opp_Rate_Plan_Charge__c).Opportunity_Charge_Attributes__r'+orpcMap.get(corpc.Chat_Product_Opp_Rate_Plan_Charge__c).Opportunity_Charge_Attributes__r);
                    If(orpcMap.containskey(corpc.Chat_Product_Opp_Rate_Plan_Charge__c) &&
                        orpcMap.get(corpc.Chat_Product_Opp_Rate_Plan_Charge__c).Opportunity_Charge_Attributes__r != NULL
                         && orpcMap.get(corpc.Chat_Product_Opp_Rate_Plan_Charge__c).Opportunity_Charge_Attributes__r.size()>0){
                        system.debug('@@@@@orpcMap.get(corpc.Chat_Product_Opp_Rate_Plan_Charge__c).Opportunity_Charge_Attributes__r'+
                                    orpcMap.get(corpc.Chat_Product_Opp_Rate_Plan_Charge__c).Opportunity_Charge_Attributes__r);
                       urlAttributeparent = orpcMap.get(corpc.Chat_Product_Opp_Rate_Plan_Charge__c).Opportunity_Charge_Attributes__r[0];
                        system.debug('@@@@urlAttributeparent'+urlAttributeparent);
                    }
                    
                    
                }
                if(corpc.Chat_Usage_Opp_Rate_Plan_Charge__c != NULL ){
                     system.debug('@@@@@orpcMap.get(corpc.Chat_Usage_Opp_Rate_Plan_Charge__c).Opportunity_Charge_Attributes__r'+orpcMap.get(corpc.Chat_Usage_Opp_Rate_Plan_Charge__c).Opportunity_Charge_Attributes__r);
                    If(orpcMap.containskey(corpc.Chat_Usage_Opp_Rate_Plan_Charge__c) &&
                        orpcMap.get(corpc.Chat_Usage_Opp_Rate_Plan_Charge__c).Opportunity_Charge_Attributes__r != NULL
                         && orpcMap.get(corpc.Chat_Usage_Opp_Rate_Plan_Charge__c).Opportunity_Charge_Attributes__r.size()>0 ){
                       urlAttributeChild = orpcMap.get(corpc.Chat_Usage_Opp_Rate_Plan_Charge__c).Opportunity_Charge_Attributes__r[0];
                            if(urlAttributeparent.id != NULL){
                                 urlAttributeChild.ParentOpportunityChargeAttribute__c = urlAttributeparent.id;
                            attribstoUpdate.put(urlAttributeChild.id,urlAttributeChild);
                            }
                       
                    }
                }
                
               
             
                
                
            }
             
            
              
        }   
        
        if(!attribstoUpdate.isEmpty()){
            update attribstoUpdate.values();
        }
                          
        
        
        
    }
    

}
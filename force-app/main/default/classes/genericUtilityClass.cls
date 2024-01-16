public class genericUtilityClass {
    
    public static set<String> formingsetIDsfromList(List<Sobject> genericList, String fieldForSet){
        
        Set<String> requiredSet = new Set<String>();
       
        for(Sobject iter : genericList){
            if(iter.get(fieldForSet) != null){
                requiredSet.add(String.valueOf(iter.get(fieldForSet))); 
            }
            
        }
        return requiredSet;  
    }
    
    
    public static void sendEmails(List<String> emailaddresses, String ClassName){
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String subject ='Status of Batch Process '+ ClassName ;
        String body    = 'Batch Process which ' + ClassName + ' is Completed';
        email.setSubject(subject);
        email.setToAddresses( emailaddresses );
        email.setPlainTextBody(body);
        if(!test.isRunningTest()){
                  Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
       }  
    }
    
    
     public static void insertIntoOppChat(Opportunity opportunity, id orderid)
    { 
        list<Chat_Product_Opportunity_Charge__c> coprc = new list<Chat_Product_Opportunity_Charge__c>();
        list<Chat_Product_Order_Charge__c> corc = new list<Chat_Product_Order_Charge__c>();
        list<invoiceit_crmx__Opportunity_Product__c> oppprod = new list<invoiceit_crmx__Opportunity_Product__c>();
  //      map<id, id> opprpc = new map<id,id>();
        map<id, invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> opprpc = new map<id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
       
        system.debug('@@@ Opportunity id: ' + Opportunity.id);
        system.debug('Order id: ' + orderid + ' Opportunity: ' + opportunity.id);
          corc = [select id, 
                  Chat_Product_Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__c, 
                  Chat_Product_Order_Rate_Plan_Charge__c,Chat_Usage_Order_Rate_Plan_Charge__c 
                  from Chat_Product_Order_Charge__c 
                  where Chat_Product_Order_Rate_Plan_Charge__r.invoiceit_s__Order__c  = :orderid 
                          or 
                  Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Order__c = :orderid];
          set<Id> orderrateplanChargeIds                            =  new Set<Id>();
        Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> oppIdVSorpc = new Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c>();
        for(Chat_Product_Order_Charge__c c:corc){
            orderrateplanChargeIds.add(c.Chat_Product_Order_Rate_Plan_Charge__c);
            orderrateplanChargeIds.add(c.Chat_Usage_Order_Rate_Plan_Charge__c);
        }
        
        System.debug('Corc: ' + corc + ' Order id: ' + orderid + ' Opportunity id: ' + opportunity.id);
        if(corc.isempty() || corc.size() <= 0 ) return;
        for (invoiceit_crmx__Opportunity_Rate_Plan_Charge__c p: [select id, Created_From_Charge__c, 
                                        invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c,  
                                        invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__c 
                                        from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c 
                                        where Created_From_Charge__c IN:orderrateplanChargeIds
                                        //where invoiceit_crmx__Opportunity__c = :opportunity.id 
                                        and Created_From_Charge__r.invoiceit_s__Status__c not in ('Cancelled', 'Expired')])
                                            opprpc.put(p.Created_From_Charge__c, p);

        system.debug('corc: ' + corc + ' opprpc: ' + opprpc);        
        system.debug('Chat records: ' + coprc + ' order: ' + orderid );
        if(!orderrateplanChargeIds.isEmpty()){
               for (Chat_Product_Order_Charge__c c:corc)
                {
                    Chat_Product_Opportunity_Charge__c corc1 = new Chat_Product_Opportunity_Charge__c();
                    if (opprpc.get(c.Chat_Product_Order_Rate_Plan_Charge__c) != null)
                    {
                        corc1.Chat_Product_Opp_Rate_Plan_Charge__c = opprpc.get(c.Chat_Product_Order_Rate_Plan_Charge__c).id;
                    }
                    if(opprpc.get(c.Chat_Usage_Order_Rate_Plan_Charge__c) != null)
                        corc1.Chat_Usage_Opp_Rate_Plan_Charge__c = opprpc.get(c.Chat_Usage_Order_Rate_Plan_Charge__c).id;
                    if (corc1.Chat_Usage_Opp_Rate_Plan_Charge__c != null)
                    {
                      coprc.add(corc1);
                        if(opprpc.containsKey(c.Chat_Product_Order_Rate_Plan_Charge__c)){
                              oppprod.add(new invoiceit_crmx__Opportunity_Product__c(id = opprpc.get(c.Chat_Product_Order_Rate_Plan_Charge__c).invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, Is_Chat_Option_Shown__c='Yes'));
                    
                        }
                    }
                }
         }
        system.debug('@@@ coprc: ' + coprc);
        /*if (!coprc.isempty())
            insert coprc;
        
        system.debug('Chat Product List: ' + oppprod);
        if (!oppprod.isEmpty())
            update oppprod;*/
            
        if (!coprc.isempty())
            insert coprc;
        
        system.debug('Chat Product List: ' + oppprod);
        Map<Id,invoiceit_crmx__Opportunity_Product__c> oppprodMap = new Map<Id,invoiceit_crmx__Opportunity_Product__c>();
        if (!oppprod.isEmpty()){
            for(invoiceit_crmx__Opportunity_Product__c opprd : oppprod){
                oppprodMap.put(opprd.id,opprd);
            }
            //Map<Id,invoiceit_crmx__Opportunity_Product__c> oppprodMap = new Map<Id,invoiceit_crmx__Opportunity_Product__c>(oppprod);
             update oppprodMap.values();
        }
        
    }
    
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
    }

}
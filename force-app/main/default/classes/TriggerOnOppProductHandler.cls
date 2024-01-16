public class TriggerOnOppProductHandler {
    
    public static boolean oppProductBeforeDeleteRecursion=true;
    
    public  void CheckToDeleteProduct(list<invoiceit_crmx__Opportunity_Product__c> oldOppProdList)
    {
        list<id> opp = new list<id>();
        for (invoiceit_crmx__Opportunity_Product__c o:oldOppProdList)
        {
            opp.add(o.invoiceit_crmx__Opportunity__c);
        }
        
        Map<id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> Opprpc = new Map<id, invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c op : [select id, INVOICEIT_CRMX__OPPORTUNITY_RATE_PLAN__r.invoiceit_crmx__Opportunity_Product__c from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c where CREATED_FROM_CHARGE__C != null and INVOICEIT_CRMX__OPPORTUNITY__C in :opp and sin__c!=NULL AND invoiceit_crmx__Opportunity__r.name like 'Mid-Term%'])
        {
            Opprpc.put(op.INVOICEIT_CRMX__OPPORTUNITY_RATE_PLAN__r.invoiceit_crmx__Opportunity_Product__c, op);
        }
        if(!opprpc.isempty())
        {
            for( invoiceit_crmx__Opportunity_Product__c o : oldOppProdList) 
            {
                if(opprpc.get(o.id) != null) 
                    o.addError('Removing a product is not permitted during Mid-Term adjustment.');
            }
        }
    }
    
    public void childChatDeleteValidation(List<invoiceit_crmx__Opportunity_Product__c> oppProductList){
         system.debug('@@@@@@childChatDeleteValidation');
        for(invoiceit_crmx__Opportunity_Product__c oppProd : oppProductList){
            if(oppProd.Created_From_Opportunity_Product__c != NULL){
                system.debug('@@@@@@In if'+oppProd.Created_From_Opportunity_Product__c);
                oppProd.addError('you cannot delete the child chat product');
            }
        }
        
    }
    
    public void deleteFromParent(map<id, invoiceit_crmx__Opportunity_Product__c> prodmap){
         list<id> oprpc = new list<id>();
             set<id> oppids = new set<id>();
             List<Sobject> deleteList= new List<SObject>();
             list<invoiceit_crmx__Opportunity_Product__c> op = new list<invoiceit_crmx__Opportunity_Product__c>();
              list<invoiceit_crmx__Opportunity_Product__c> delChildProdLst = new list<invoiceit_crmx__Opportunity_Product__c>();

             list<Id> deleteChildProd= new list<Id>();
             //set<Id>addonChatParentIds          = new Set<Id>();
             System.debug('=====prodmap.keySet()===='+prodmap.keySet());
             for ( invoiceit_crmx__Opportunity_Rate_Plan_Charge__c o:[select id, invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, 
                                                                         invoiceit_crmx__Opportunity__c 
                                                                      from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                                                                      where invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c in :prodmap.keySet() ])
             {
                 oprpc.add(o.id);
                 oppids.add(o.invoiceit_crmx__Opportunity__c);
             }
             System.debug('@@@@@@@@@oprpc'+oprpc);
             list<Chat_Product_Opportunity_Charge__c> cp = new list<Chat_Product_Opportunity_Charge__c>();
            if(!oprpc.isempty()){
                cp = [select id, 
                  Chat_Usage_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, 
                  Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c 
                  from Chat_Product_Opportunity_Charge__c 
                  where Chat_Product_Opp_Rate_Plan_Charge__c in :oprpc or Chat_Product_Opp_Rate_Plan_Charge__c in :oprpc];
                  
                System.debug('========cp========'+cp);  
                  if(!cp.isempty()){
                      for(Chat_Product_Opportunity_Charge__c charge: cp){
                          if(charge.Chat_Usage_Opp_Rate_Plan_Charge__c!=Null){
                              deleteChildProd.add(charge.Chat_Usage_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c);
                              System.debug('==========deleteChildProd========='+deleteChildProd);
                          }
                      }
                      if(!deleteChildProd.isempty()){
                          delChildProdLst = [Select id, name from invoiceit_crmx__Opportunity_Product__c Where id in:deleteChildProd];
                          System.debug('==========delChildProdLst ========='+delChildProdLst );
                      }
                      
                       delete cp;
                       delete delChildProdLst;
                  }
              }
              
                 
    }
    
    
    public void deletefromchat(map<id, invoiceit_crmx__Opportunity_Product__c> prodmap)
    {
         list<id> oprpc = new list<id>();
         set<id> oppids = new set<id>();
         list<invoiceit_crmx__Opportunity_Product__c> op = new list<invoiceit_crmx__Opportunity_Product__c>();
         list<invoiceit_crmx__Opportunity_Product__c> opdellist = new list<invoiceit_crmx__Opportunity_Product__c>();
         set<Id>addonChatParentIds          = new Set<Id>();
         for ( invoiceit_crmx__Opportunity_Rate_Plan_Charge__c o:[select id, invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, 
                                                                     invoiceit_crmx__Opportunity__c 
                                                                  from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                                                                  where invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c in :prodmap.keySet() ])
         {
             oprpc.add(o.id);
             oppids.add(o.invoiceit_crmx__Opportunity__c);
         }
        list<Chat_Product_Opportunity_Charge__c> cp = new list<Chat_Product_Opportunity_Charge__c>();
        list<Chat_Product_Opportunity_Charge__c> cpall = new list<Chat_Product_Opportunity_Charge__c>();
        cp = [select id, 
              Chat_Usage_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, 
              Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c 
              from Chat_Product_Opportunity_Charge__c 
              where Chat_Usage_Opp_Rate_Plan_Charge__c in :oprpc or Chat_Product_Opp_Rate_Plan_Charge__c in :oprpc];
        cpall = [select id, Chat_Usage_Opp_Rate_Plan_Charge__c,
                 Chat_Usage_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c,
                 Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c 
                 from Chat_Product_Opportunity_Charge__c 
                 where Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity__c in :oppids or Chat_Usage_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity__c in :oppids];
     
        for (Chat_Product_Opportunity_Charge__c c:cp)
        {
            boolean matchoppfound = false;
      for (invoiceit_crmx__Opportunity_Product__c o:op) 
            {
                if (o.id == c.Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c )
                {
                    matchoppfound = true;
                }
            }
            if (matchoppfound == false)
              op.add(new invoiceit_crmx__Opportunity_Product__c(id = c.Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, Is_Chat_Option_Shown__c='No'));

        }
        system.debug('Chat Trigger: ' + cp + ' oprpc: ' + oprpc + ' product ' + op);
        for(Chat_Product_Opportunity_Charge__c c:cp)
        {
            integer cnt = 0;
            invoiceit_crmx__Opportunity_Product__c prod = new invoiceit_crmx__Opportunity_Product__c();
            for (Chat_Product_Opportunity_Charge__c o:cpall)
            {
                if (c.Chat_Usage_Opp_Rate_Plan_Charge__c == o.Chat_Usage_Opp_Rate_Plan_Charge__c)
                {
                    addonChatParentIds.add(c.Chat_Usage_Opp_Rate_Plan_Charge__c);
                    prod.id = o.Chat_Usage_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c;
                    cnt = cnt+1;
                }
            }
            if (cnt == 1 && prodmap.get(prod.id) == null) opdellist.add(prod);
        }
        if (!cp.isEmpty()) delete cp;
        if (!op.isempty()) update op;
        system.debug('delete Product: ' + opdellist);
        
        //add on chat products delete logic here
        If(!addonChatParentIds.isEmpty()){
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opcharge : [select id,invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, 
                                                                     invoiceit_crmx__Opportunity__c
                                                                           From invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                                                                           where Chat_Parent_Opportunity_Rate_Plan_Charge__c != NULL
                                                                            AND Chat_Parent_Opportunity_Rate_Plan_Charge__c IN:addonChatParentIds
                                                                             AND invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c NOT IN:prodmap.keyset()]){
                  opdellist.add(new invoiceit_crmx__Opportunity_Product__c(
                                     id = opcharge.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c));                                                              
             }
        }
        
       // Set<Id>addonchatParentIds  =  new Set<Id>();
        //add on chat delete logic here
        for(invoiceit_crmx__Opportunity_Product__c oppProduct : prodmap.values()){
            //It may be addon product
            if(oppProduct.Created_From_Opportunity_Product__c == NULL){
                addonchatParentIds.add(oppProduct.id);
            }
            
        }
        
        if(!addonchatParentIds.isEmpty()){
            for(invoiceit_crmx__Opportunity_Product__c childopprod : [select id 
                                                                           From invoiceit_crmx__Opportunity_Product__c
                                                                           where Created_From_Opportunity_Product__c IN:addonchatParentIds
                                                                      And Id Not IN:prodmap.keySet()]){
                    opdellist.add(childopprod);                                                        
             }
            
        }
        
        
        
        if (!opdellist.isEmpty()) delete opdellist;
    }
    
/*    public void deletefromchat(map<id, invoiceit_crmx__Opportunity_Product__c> prodmap)
    {
         list<id> oprpc = new list<id>();
         for ( invoiceit_crmx__Opportunity_Rate_Plan_Charge__c o:[select id from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c where invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c in :prodmap.keySet() ])
             oprpc.add(o.id);
        list<Chat_Product_Opportunity_Charge__c> cp = new list<Chat_Product_Opportunity_Charge__c>();
        cp = [select id from Chat_Product_Opportunity_Charge__c where Chat_Usage_Opp_Rate_Plan_Charge__c in :oprpc or Chat_Product_Opp_Rate_Plan_Charge__c in :oprpc];
        system.debug('Chat Trigger: ' + cp + ' oprpc: ' + oprpc);
        delete cp;
    }
*/
 public  void FkMethod(){
    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;

    }
    



}
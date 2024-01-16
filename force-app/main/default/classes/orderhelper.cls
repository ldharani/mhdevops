Public class orderhelper{

    /*
    Change History 
    ************************************************************************************************************************
    Jira         ModifiedBy    Date         Requested By    Tag     Description
                 Sai C         06/20/2022   John Mattheson          Fix for Order XML issue on Prod
                 
     MHBS-9310   Sai C         06/20/2023   John Mattheson  <T02>   Getting Multiple Invalid Salesforce Order Creation Request 
                                                                    with Product Code as PROMOFEE
     
    ************************************************************************************************************************/

    public  static void orderXMLhelper(List<OrderItem> orderproducts, map<Id,OrderItem> oldMap){
        
        system.debug('@@@@ In OrderXMLhelper'); 
        Set<Id> orderprodIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        List<order> updateord = new List<order>();
        List<order> Orderlist  = new List<order>(); 
        map<id,order> ordermap = new  map<id,order>();
        
        for(OrderItem op: orderproducts){
            
          //  If(op.Attribute_Relationship__c != null || op.Order.Pricebook2.Name == '4. Martindale-Avvo Price Book'){
          //If(op.id != null){
          If(op.id != null && op.Product_Code_value__c != 'PROMOFEE'){ //<T02>   
              orderIds.add(op.OrderId);
            }
        
        }
        
        if(!orderIds.isEmpty()){
               ordermap = new  map<id,order>([Select Id, Status__c ,Modified_XML__c,IsXMLSent__c  From Order where Id in : orderIds AND Modified_XML__c = False AND (IsXMLSent__c = False Or Status__c ='Rebased' OR Status__c ='Midtermed') AND Status__c !='Modified' AND Status__c !=' Off set' 
               AND Status__c != null AND Status__c != '']);
               
        
        }
        
        
        for(OrderItem op: orderproducts){
            system.debug('@@@@ New map'+op.Attribute_Relationship__c); 
            system.debug('@@@@ Old map'+oldmap.get(op.Id).Attribute_Relationship__c); 
            
           // If(op.Attribute_Relationship__c != null && !ordermap.isEmpty() && ordermap.containskey(op.OrderId)){
              If(!ordermap.isEmpty() && ordermap.containskey(op.OrderId)){

                  order temporder = ordermap.get(op.OrderId);
                  
          
          //  && op.Attribute_Relationship__c!= oldmap.get(op.Id).Attribute_Relationship__c){
              //  orderprodIds.add(op.Id);
              system.debug('@@@@ op.OrderId'+op.OrderId);
              //&& op.OrderId != NULL && temporder.IsXMLSent__c == false 
                //if ((op.OrderId != null ) || (op.Status__c != oldmap.get(op.Id).Status__c  && (op.Status__c == 'Cancelled' || op.Status__c == 'Expired' || (op.Status__c == 'Truncated' && op.EndDate < Date.today())))){
                  if ((op.OrderId != null  && op.Product_Code_value__c != 'PROMOFEE') ){//<T02> 

                     orderprodIds.add(op.Id);
                     orderIds.add(op.OrderId);
                     system.debug('@@@@ op.OrderId'+op.OrderId);
                     temporder.IsXMLSent__c = True;
                     updateord.add(temporder);
                    }
                    
                  if ((op.OrderId != null && op.Status__c == 'Truncated') ){
                     temporder.Modified_XML__c= True;
                     updateord.add(temporder);
                     system.debug('@@@@ updated Modified Order '+updateord);
                     }
            }
        
            if(op.Status__c != oldmap.get(op.Id).Status__c  && (op.Status__c == 'Cancelled' || op.Status__c == 'Expired' || op.Status__c == 'Truncated' )){
                
                orderprodIds.add(op.Id);
              //  temporder.Modified_XML__c= True;
                system.debug('@@@@ Cancel/truncate Order Products'+orderprodIds);
            }
          
          system.debug('@@@@ Before Order Prod with blank status '+orderprodIds);
           if((op.Status__c == 'Off set' && op.UpgradedDowngraded__c == False ) || op.Status__c == 'Renewed' || op.Status__c == null ||  op.Status__c == 'Rebased' || op.Status__c == 'Modified' || op.Status__c == ''){
           
               orderprodIds.remove(op.Id);
                system.debug('@@@@ Order Prod with blank status '+orderprodIds);
           }
          
        }
        
              
        for(Order ord : updateord){
        
            ordermap.put(ord.Id,ord);
        }
        
        if(!ordermap.isEmpty()){
            system.debug('@@@@ In ordermap'+ordermap); 
            update ordermap.values();
        }
        
      //  }
        
       
     if((!orderprodIds.isEmpty() ) && !test.isrunningtest()){
        system.debug('@@@@ In Order Request'+orderprodIds); 
        
        CPQ_MDL_Integration_Vim_Efs.OrderRequest(orderprodIds);
   
        
    }
    
     //if(!updateord.isempty()){
              //  update updateord;
            //}

    }
    
    
    public static void CreateContract(List<Order> newList, Map<Id, Order> oldMap){
        set<Id> sOrderId = new set<Id>();
        for(Order o: newList){
            if(o.Status == 'Activated' && (o.Status != oldMap.get(o.Id).Status )){
                system.debug('@@@@ In Contract Creation'+o.Status); 
                sOrderId.add(o.Id);
            }
        }
        if(!sOrderId.isEmpty()){
        
            List<Order> lstOrderUpdate = [SELECT Id, Status__c,SBQQ__Quote__r.SBQQ__EndDate__c FROM Order WHERE Id IN: sOrderId AND IsRebaseAmend__c = true];
            for(Order objOrder: lstOrderUpdate){
                //objOrder.EndDate = objOrder.SBQQ__Quote__r.SBQQ__EndDate__c;
                //objOrder.Status = Constant.ORDER_STATUS_ACTIVATED;
                objOrder.SBQQ__Contracted__c = TRUE;
               // objOrder.blng__BillingDayOfMonth__c = '1';
            }
            system.debug('@@@@ Contract Creation update '+lstOrderUpdate); 
            update lstOrderUpdate;
        }
    }// END OF METHOD - CreateContract
}
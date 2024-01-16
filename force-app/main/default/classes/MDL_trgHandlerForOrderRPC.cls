/*
**Modified By : Lister Technologies
**Modified Date : 14/8/14
**Modified Reason : To include date logic for Renew - Subscription Product : Fulfillment Dates(change done on checkRecalculateOnOrder function) - Code commented not being used

**Modified By : Lister Technologies
**Modified Date : 16/1/15
**Modified Reason : to create case during Mid Term Adjustment
**
**Modified By : Lister Technologies
**Modified Date : 13/7/15
**Modified Reason : MHBS-80
*/
public with sharing class MDL_trgHandlerForOrderRPC {
    
    public static boolean liveDateRecursion = true;
    
  
  public static void  eventsForCharges(List<invoiceit_s__Job_Rate_Plan_Charge__c> triggerList , String username) {
        
        List<invoiceit_s__Job_Rate_Plan_Charge__c> list_orderCharges = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        List<invoiceit_s__Job_Product__c> list_orderProducts = new List<invoiceit_s__Job_Product__c>(); 
        List<Chat_Product_Order_Charge__c> List_chat_Prod_Ord_Charge = new List<Chat_Product_Order_Charge__c>();     
        
        Set<id> OrderChargesId = new Set<Id>();
        Set<id> OrderAutoEvergreenChargesId = new Set<Id>();
        Set<id> setOrderChargeIds = new Set<Id>();
        List<id> ListOfOrderChargeAttribute = new List<Id>();
        List<id> ListOfAutoEvergreenOrderChargeAttribute = new List<Id>();
                
        Map<Id , String> Map_OrderProductId_SIN = new Map<Id , String>();
        Map<Id , String> Map_OrderId_InventoryId = new Map<Id , String>();
        Map<Id , String> Map_OrderId_OppProdId = new Map<Id , String>();
        Map<Id , Boolean> Map_OrderProductId_IsAddOnFeature = new Map<Id , Boolean>();
        Map<Id , String> Map_OrderProductId_createdFromOppProdID = new Map<Id , String>();
        Map<Id , String> Map_OppProdID_OrdProdID = new Map<Id , String>();

                
        for(invoiceit_s__Job_Rate_Plan_Charge__c charges : triggerList){
            OrderChargesId.add(charges.id);
            //System.debug('========OrderChargesId=========='+OrderChargesId);
        }
                
        
        list_orderCharges = [Select Id, invoiceit_s__Charge_Code__c ,  invoiceit_s__Accounting_Code__c ,   Terms_Months__c ,Type__c,Shippable__c,
                            Opportunity_Rate_Plan_Charge__c , Opportunity_Rate_Plan_Charge__r.SIN__c , Opportunity_Rate_Plan_Charge__r.Chat_ID__c,
                            Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id,
                            Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.InventoryId__c,
                            Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.IsAddOnFeature__c,
                            Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_Opportunity_Product__c,                                                       
                            Opportunity_Rate_Plan_Charge__r.Created_From_Charge__c, Opportunity_Rate_Plan_Charge__r.Terms_Months__c , 
                            Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.SIN__c , SIN__c ,Chat_ID__c, Billing_Start_Date1__c,
                            Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.invoiceit_s__Service_End_Date__c ,
                            Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.Terms_Months__c ,RecordType.DeveloperName,
                            Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.Chat_ID__c,Opportunity_Rate_Plan_Charge__r.Live_Date__C,
                            Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.Product_Provisioning__c,
                            Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.Fulfilment_Start_Date__c,
                            Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.Fulfilment_End_Date__c,
                            Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,
                            Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Sin_Number__c , 
                            Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Product_SIN__c,
                            invoiceit_s__Product_Rate_Plan_Charge__r.invoiceit_s__Price_Type__c , invoiceit_s__Order__c ,   
                            invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.Id ,
                            invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c,invoiceit_s__Sequence_No__c,
                            invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id,Opportunity_Rate_Plan_Charge__r.IsAddOnFeature__c,Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c,
                            invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.invoiceit_s__Account__r.MH_Cust_Number__c,
                            invoiceit_s__Order__r.invoiceit_crmx__Opportunity__r.Name,invoiceit_s__Order__r.invoiceit_crmx__Opportunity__r.Quote_Type__c,invoiceit_s__Order__r.invoiceit_crmx__Opportunity__r.Reason_Won_Lost__c,
                            (Select Id From Order_Charge_Attributes__r where (RecordType.DeveloperName = 'MDL_Order_Charge_Attribute' or RecordType.DeveloperName = 'Nolo_Order_Charge_Attribute')) 
                            from invoiceit_s__Job_Rate_Plan_Charge__c 
                            where id in : OrderChargesId
                            and (RecordType.DeveloperName = 'MDL_Order_Rate_Plan_Charge' or RecordType.DeveloperName = 'Nolo_Order_Rate_Plan_Charge' or RecordType.DeveloperName ='M_N_Order_Rate_Plan_Charge' or RecordType.DeveloperName ='M_NG_Order_Rate_Plan_Charge')];
        
        //System.debug('=======list_orderCharges========='+list_orderCharges);
        for(invoiceit_s__Job_Rate_Plan_Charge__c order_charge : list_orderCharges){
                if(order_charge.Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.Product_Provisioning__c=='Manual Fulfillment' && order_charge.Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.Fulfilment_Start_Date__c!=null && order_charge.RecordType.DeveloperName!= 'M_N_Order_Rate_Plan_Charge'){
                    MDL_RecursionHandler.mapOrderRPCIdNBooleanForManuallyFFDXML.put(order_charge.Id,true);
                }
                else if(order_charge.Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.Product_Provisioning__c=='Manual Fulfillment' && order_charge.Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.Fulfilment_Start_Date__c==null && order_charge.RecordType.DeveloperName!= 'M_N_Order_Rate_Plan_Charge'){
                    MDL_RecursionHandler.mapOrderRPCIdNBooleanForManuallyFFDXML.put(order_charge.Id,false);
                }
                if (order_charge.Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.Chat_ID__c!= null ){
                    //System.debug('Chat ID  will be carried forward @@@' +order_charge);
                    order_charge.Chat_ID__c = order_charge.Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.Chat_ID__c;
                }
                
                if(order_charge.Opportunity_Rate_Plan_Charge__r.Live_Date__C != Null){
                    order_charge.Live_Date__c = order_charge.Opportunity_Rate_Plan_Charge__r.Live_Date__C;
                }
                if(order_charge.Opportunity_Rate_Plan_Charge__r.IsAddOnFeature__c!=Null){
                        order_charge.IsAddOnFeature__c = order_charge.Opportunity_Rate_Plan_Charge__r.IsAddOnFeature__c;
                }
                
                //Added By Sai C
               /* if(order_charge.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c!=Null){
                        order_charge.Chat_Parent_Order_Rate_Plan_Charge__c = order_charge.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c;
                }*/
                
                if(order_charge.Opportunity_Rate_Plan_Charge__r.SIN__c != null && order_charge.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Product_SIN__c != null){
                        //System.debug('SIN NUmber will be carried forward**'+order_charge);
                        order_charge.SIN__c = order_charge.Opportunity_Rate_Plan_Charge__r.SIN__c ;
                        
                        Map_OrderProductId_SIN.put(order_charge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id ,
                            order_charge.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Product_SIN__c);
                        
                        order_charge.Type__c = 'Existing';
                        //if(order_charge.Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.Terms_Months__c != null)
                            //order_charge.Terms_Months__c = order_charge.Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.Terms_Months__c;
                        if(order_charge.Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.invoiceit_s__Service_End_Date__c != null)
                            order_charge.Billing_Start_Date1__c = order_charge.Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.invoiceit_s__Service_End_Date__c;
                }
                else{
                        //System.debug('New SIN Number will be generated**'+order_charge);
                        order_charge.SIN__c =                       
                                    order_charge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.invoiceit_s__Account__r.MH_Cust_Number__c
                                    +'.'
                                    +order_charge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c
                                    +'.'
                                    +order_charge.Id;
                        
                        Map_OrderProductId_SIN.put(order_charge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id ,  
                                order_charge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.invoiceit_s__Account__r.MH_Cust_Number__c
                                    +'.'
                                    +order_charge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c
                                    +'.'
                                    +order_charge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id);
                        
                        if(order_charge.Opportunity_Rate_Plan_Charge__r.Created_From_Charge__r.Terms_Months__c != null)
                            order_charge.Terms_Months__c = order_charge.Opportunity_Rate_Plan_Charge__r.Terms_Months__c; 
                        
                }
                
                Map_OrderId_InventoryId.put(order_charge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id , 
                                        order_charge.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.InventoryId__c);
                                        
                Map_OrderProductId_IsAddOnFeature.put(order_charge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id , order_charge.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.IsAddOnFeature__c);
                
                
                Map_OrderId_OppProdId.put(order_charge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id, order_charge.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c);   
                    
                if(order_charge.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_Opportunity_Product__c!=NULL){
                    Map_OrderProductId_createdFromOppProdID.put(order_charge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id, order_charge.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_Opportunity_Product__c); 
                }
                
                Map_OppProdID_OrdProdID.put(order_charge.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id,order_charge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id);
                 
                if(order_charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c != null){
                    if(order_charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__r.Name.startswith('Auto evergreen') && order_charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__r.Quote_Type__c == 'Renew' && order_charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__r.Reason_Won_Lost__c == 'Auto Evergreen'){
                        OrderAutoEvergreenChargesId.add(order_charge.Id);                   
                    }
                    else{
                        setOrderChargeIds.add(order_charge.Id);
                        for(Order_Charge_Attribute__c attribute : order_charge.Order_Charge_Attributes__r){
                            ListOfOrderChargeAttribute.add(attribute.Id);
                        }
                    }
                }
                else{
                    setOrderChargeIds.add(order_charge.Id);
                    for(Order_Charge_Attribute__c attribute : order_charge.Order_Charge_Attributes__r){
                        ListOfOrderChargeAttribute.add(attribute.Id);
                    }
                }                                             
        }
        /*System.debug('@@1sttt@@@@@@@@@@@@@@Order Prod Id vs OppProdId'+Map_OrderId_OppProdId);
        System.debug('@@2nddd@@@@@@@@@Map_OrderProductId_createdFromOppProdID'+Map_OrderProductId_createdFromOppProdID);
        System.debug('=======3rd======Map_OppProdID_OrdProdID============'+Map_OppProdID_OrdProdID);*/
        if(!list_orderCharges.isempty()){
        List_chat_Prod_Ord_Charge = [Select id, name,Chat_Usage_Order_Rate_Plan_Charge__c,Chat_Product_Order_Rate_Plan_Charge__c,
                                    Chat_Product_Order_Rate_Plan_Charge__r.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id,
                                    Chat_Product_Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id
                                    From Chat_Product_Order_Charge__c Where Chat_Usage_Order_Rate_Plan_Charge__c in: list_orderCharges];
        
            for(Chat_Product_Order_Charge__c cp: List_chat_Prod_Ord_Charge ){
                if(cp.Chat_Product_Order_Rate_Plan_Charge__c != Null){
                    Map_OppProdID_OrdProdID.put(cp.Chat_Product_Order_Rate_Plan_Charge__r.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id, cp.Chat_Product_Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id);
                }
                
            }
        }
        
        list_orderProducts = [Select Id, Sin_Number__c , Inventory_Id__c, IsAddOnFeature__c
                                from invoiceit_s__Job_Product__c where 
                                Id in : Map_OrderProductId_SIN.keySet()
                                and (RecordType.DeveloperName = 'MDL_Order_Product' or RecordType.DeveloperName = 'Nolo_Order_Product' or RecordType.DeveloperName = 'M_N_Order_Product' or RecordType.DeveloperName = 'M_NG_Order_Product')];

        for(invoiceit_s__Job_Product__c order_product : list_orderProducts){
                    //System.debug('@@@@@list_orderProducts'+list_orderProducts);                    
                    order_product.Sin_Number__c = Map_OrderProductId_SIN.get(order_product.Id);
                    order_product.Inventory_Id__c = Map_OrderId_InventoryId.get(order_product.Id);
                    if(Map_OrderId_OppProdId.containskey(order_product.id)){
                        order_product.Opportunity_Product__c = Map_OrderId_OppProdId.get(order_product.Id);

                    }
                    order_product.IsAddOnFeature__c = Map_OrderProductId_IsAddOnFeature.get(order_product.Id);
                    //System.debug('=========Map_OrderProductId_createdFromOppProdID========='+Map_OrderProductId_createdFromOppProdID);
                    //System.debug('======Map_OppProdID_OrdProdID=========='+Map_OppProdID_OrdProdID);
                    
                    //System.debug('@@@@@@@@@@@@@@@ check if true'+Map_OrderProductId_createdFromOppProdID.containskey(order_product.id));
                    if(Map_OrderProductId_createdFromOppProdID.containskey(order_product.id)){
                        string createdFromOpptyProdId = Map_OrderProductId_createdFromOppProdID.get(order_product.id);
                        //System.debug('=====createdFromOpptyProdId ===='+createdFromOpptyProdId );
                        //System.debug('===========Map_OppProdID_OrdProdID.containskey(createdFromOpptyProdId )========='+Map_OppProdID_OrdProdID.containskey(createdFromOpptyProdId ));
                        if(Map_OppProdID_OrdProdID.containskey(createdFromOpptyProdId )){
                           // System.debug('====isnide the if condition====');
                            order_product.Created_From_Order_Product__c = Map_OppProdID_OrdProdID.get(createdFromOpptyProdId);
                            //System.debug('====isnide the if condition end===='+order_product.Created_From_Order_Product__c);
                        }   
                    }
        }
        
      if( list_orderCharges.size() > 0 ){
          //system.debug('@@@@list_orderCharges'+list_orderCharges);
          update list_orderCharges;
      }
            
        
        if( list_orderProducts.size() > 0 ) 
           // system.debug('@@@@list_orderProducts'+list_orderProducts);
            update list_orderProducts;
            
        if(!test.isRunningTest()){
            //System.debug('%%%'+OrderChargesId);  
            if(setOrderChargeIds.size() > 0)  
                //New method added by Sai C for Order Cancellation Request ----- 06-12-2017
                MDL_Integration_Vim_Efs.orderReqInCaseOfAttributesChange(setOrderChargeIds, ListOfOrderChargeAttribute,userName);
               //MDL_Integration_Vim_Efs.orderReqInCaseOfOrdercancel(setOrderChargeIds, ListOfOrderChargeAttribute,userName);
        }
    }

  //commenting this method since ecf is handled in another way - MHBS-26
 /* public static void rollupECF(List<invoiceit_s__Job_Rate_Plan_Charge__c> triggerList) {
    
    List<invoiceit_s__Job_Product__c> listOfOrderProductToUpdate = new List<invoiceit_s__Job_Product__c>();
    List<Id> orderIds = new List<id>();        
    Map<Id, Decimal> mapOfOrderProductId_ECF = new Map<Id, Decimal>();
    system.debug('>>>>>>>>triggerList  '+triggerList);    
    for(invoiceit_s__Job_Rate_Plan_Charge__c oRPC : triggerList){
        if(oRPC.invoiceit_s__Status__c == 'Cancelled')
            
            orderIds.add(oRPC.invoiceit_s__Order__c);
    }
    system.debug('>>>>>>>>orderIds '+orderIds); 
    List<invoiceit_s__Job_Rate_Plan_Charge__c> listOfOrderRPC = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
    
    listOfOrderRPC = [Select Id, of_days__c ,   invoiceit_s__Order__c  ,invoiceit_s__Price__c , Cancellation_Date__c ,
                             invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c, invoiceit_s__Service_End_Date__c ,
                             invoiceit_s__Service_Activation_Date__c , Early_Cancellation_Fee__c
                        from invoiceit_s__Job_Rate_Plan_Charge__c 
                        where invoiceit_s__Order__c in  :orderIds
                        And invoiceit_s__Status__c = 'Cancelled'
                        and RecordType.DeveloperName = 'MDL_Order_Rate_Plan_Charge']    ;
     
     system.debug('@2 ' + listOfOrderRPC );
     for(invoiceit_s__Job_Rate_Plan_Charge__c iter : listOfOrderRPC){
        
        //List<invoiceit_s__Job_Rate_Plan_Charge__c> templistOfOrderRPC ;
        Decimal tempECFAmt = 0;
        Decimal ECF = 0;
        system.debug('--- 0 '+ iter.Id);
        system.debug('--- 1 '+ iter.invoiceit_s__Price__c);
        system.debug('--- 3 '+ iter.invoiceit_s__Service_Activation_Date__c);
        system.debug('--- 4 '+ iter.Cancellation_Date__c);
        system.debug('--- 5' + system.today());
        if(iter.invoiceit_s__Price__c != null &&  iter.invoiceit_s__Service_Activation_Date__c != null &&
            System.today() > iter.invoiceit_s__Service_Activation_Date__c && iter.invoiceit_s__Service_End_Date__c!=null){
            Decimal a = ((iter.invoiceit_s__Service_Activation_Date__c.daysBetween(System.today())));
            system.debug(' @daysBetween ' + iter.invoiceit_s__Service_Activation_Date__c.daysBetween(System.today()));
            a = a.divide(30,0, System.RoundingMode.UP);
            Decimal b1 = ((iter.invoiceit_s__Service_Activation_Date__c.daysBetween(iter.invoiceit_s__Service_End_Date__c)));
            system.debug(' @month ' + b1);
            b1 = b1.divide(30,0, System.RoundingMode.UP);
            ECF = iter.invoiceit_s__Price__c +(iter.invoiceit_s__Price__c * (b1 - a))*0.6 ;
            ECF  = ECF.round();                                
            system.debug('--- ? '+ ECF);    
        }                   
        iter.Early_Cancellation_Fee__c = ECF;                
        //if(iter.of_days__c != null){
            
            if(mapOfOrderProductId_ECF.containsKey(iter.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c)){
                tempECFAmt = mapOfOrderProductId_ECF.get(iter.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c);
                tempECFAmt += ECF;
                mapOfOrderProductId_ECF.put(iter.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c , tempECFAmt);
            }
            else{               
                mapOfOrderProductId_ECF.put(iter.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c , ECF);
            }
        //}   
         
     }          
     system.debug('**** --->>> ' + mapOfOrderProductId_ECF);
     listOfOrderProductToUpdate = [Select Id , ECF__c
                                    from invoiceit_s__Job_Product__c
                                    where id in : mapOfOrderProductId_ECF.keyset()];
     
     for(invoiceit_s__Job_Product__c orderProdIter : listOfOrderProductToUpdate)    {
        orderProdIter.ECF__c = mapOfOrderProductId_ECF.get(orderProdIter.Id);
     }      
     system.debug('**** --->>> ' + listOfOrderProductToUpdate);         
     if(listOfOrderProductToUpdate.size() > 0 )
        update listOfOrderProductToUpdate;
     
     if(listOfOrderRPC.size() >0 )
        update listOfOrderRPC;   
      listOfOrderProductToUpdate = new List<invoiceit_s__Job_Product__c>();
      /*listOfOrderProductToUpdate = [Select Id , ECF__c
                                    from invoiceit_s__Job_Product__c
                                    where id in : mapOfOrderProductId_ECF.keyset()];
     
      system.debug('**** --->>> ' + listOfOrderProductToUpdate);                        
  }*/
  
  
  
  
/*
  // Start of changes for MHBS-956 -- Jehan 

  public static void createCaseForManuallyFulfilledProducts(List<invoiceit_s__Job_Rate_Plan_Charge__c> cancelledRPCList) {
    List<Case> casesToInsert = new List<Case>();
    
    List<invoiceit_s__Job_Rate_Plan_Charge__c> cancelledManuallyfulfilledRPCs = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
    
    cancelledManuallyfulfilledRPCs = [Select Id , invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name , 
                                            invoiceit_s__Order__r.invoiceit_s__Account__r.Name , Product_Provisioning__c ,
                                            invoiceit_s__Order__r.invoiceit_s__Account__r.Id
                                            from invoiceit_s__Job_Rate_Plan_Charge__c
                                            where id in : cancelledRPCList
                                            And Product_Provisioning__c =: 'Manual Fulfillment'
                                            and RecordType.DeveloperName = 'MDL_Order_Rate_Plan_Charge'] ;
                                           
    for(invoiceit_s__Job_Rate_Plan_Charge__c jrpc : cancelledRPCList){
            system.debug(' product provisioning ' + jrpc.Product_Provisioning__c); 
            if(jrpc.Product_Provisioning__c == 'Manual Fulfillment'){                
                cancelledManuallyfulfilledRPCs.add(jrpc);
            }
    }   
                                          
    for(invoiceit_s__Job_Rate_Plan_Charge__c iterRPC : cancelledManuallyfulfilledRPCs ){
            Case tempCase = new Case();
            tempCase.Subject = 'Product - ' + iterRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name  
                                +' cancelled for Customer - ' + iterRPC.invoiceit_s__Order__r.invoiceit_s__Account__r.Name;
            tempCase.AccountId = iterRPC.invoiceit_s__Order__r.invoiceit_s__Account__r.Id;
            tempCase.Type = 'Manually Fulfilled product cancelled';         
            casesToInsert.add(tempCase);
    }
    
    if(casesToInsert.size() > 0)
        insert casesToInsert;
        
    system.debug(' ---- > '  + casesToInsert);
  }
// End of changes for MHBS-956 -- Jehan  
  */


  public void handleBeforeOnOrderRatePlanChargeforRenew(list<invoiceit_s__Job_Rate_Plan_Charge__c> newCharges, map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> newMap, map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> oldMap) {
        List<id> orderids=new List<id>();
        List<id> chargeids=new List<id>();
        
        
        List<invoiceit_s__Job_Rate_Plan_Charge__c> toupdate=new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        Map<id,invoiceit_s__Job__c> orders=new Map<id,invoiceit_s__Job__c>();
        Map<id,invoiceit_s__Job__c> orderenddates=new Map<id,invoiceit_s__Job__c>();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> renewedcharges=new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        Map<id,invoiceit_s__Job_Rate_Plan_Charge__c> oldnewedcharges=new Map<id,invoiceit_s__Job_Rate_Plan_Charge__c>();
        //invoiceit_s__Order__c
        for(invoiceit_s__Job_Rate_Plan_Charge__c iter: newCharges){
            orderids.add(iter.invoiceit_s__Order__c);
            chargeids.add(iter.id);
        }
        orders=new Map<id,invoiceit_s__Job__c >([select id,Renew_Rebase__c,invoiceit_s__Service_End_Date__c from invoiceit_s__Job__c where id in :orderids]);
        //orderenddates=new Map<id,invoiceit_s__Job__c >([select id,invoiceit_s__Service_End_Date__c from invoiceit_s__Job__c where id in :orderids]);
        renewedcharges=[select id,invoiceit_s__Status__c,Product_Provisioning__c,
                                Fulfilment_Start_Date__c,invoiceit_s__Order__c,
                                Created_From_Charge__c,Created_From_Charge__r.invoiceit_s__Service_End_Date__c,
                                 invoiceit_s__Price_Type__c,Shippable__c,Created_From_Charge__r.Chat_ID__c
                                 from invoiceit_s__Job_Rate_Plan_Charge__c  where Created_From_Charge__c in : chargeids];

        for(invoiceit_s__Job_Rate_Plan_Charge__c iter : renewedcharges){
            if(newMap.containsKey(iter.Created_From_Charge__c)){
                invoiceit_s__Job_Rate_Plan_Charge__c temp=newMap.get(iter.Created_From_Charge__c);
                oldnewedcharges.put(temp.id,iter);
            }
        }
        for(invoiceit_s__Job_Rate_Plan_Charge__c iter : newCharges){
            boolean toadd=false;
                invoiceit_s__Job__c temporder=orders.get(iter.invoiceit_s__Order__c);
                if(temporder!=null && temporder.Renew_Rebase__c!=null && orders.get(iter.invoiceit_s__Order__c).invoiceit_s__Service_End_Date__c!=null && (temporder.Renew_Rebase__c=='Renew' || temporder.Renew_Rebase__c=='Rebase') && oldMap.get(iter.id)!=null && oldMap.get(iter.id).Fulfilment_Start_Date__c ==null && newMap.get(iter.id).Fulfilment_Start_Date__c !=null){
                    //system.debug('>>>>>>>>>>>>>>>inside update fullfillment loop1');
                    invoiceit_s__Job_Rate_Plan_Charge__c tempcharge=oldnewedcharges.get(iter.id);
                    if(tempcharge!=null && tempcharge.invoiceit_s__Price_Type__c!='One Time' && tempcharge.invoiceit_s__Status__c!='Cancelled' && tempcharge.invoiceit_s__Status__c!='Expired' && !(tempcharge.invoiceit_s__Price_Type__c=='Monthly' && tempcharge.Shippable__c=='Yes')){                   
                        if(tempcharge.Created_From_Charge__r.invoiceit_s__Service_End_Date__c!=null){
                            tempcharge.Fulfilment_Start_Date__c= tempcharge.Created_From_Charge__r.invoiceit_s__Service_End_Date__c.addDays(1);
                            tempcharge.Chat_ID__c              = tempcharge.Created_From_Charge__r.Chat_ID__c;
                            oldnewedcharges.put(iter.id,tempcharge);
                            toadd=true;
                            //system.debug('>>>>>>>>>>>>>>>inside update fullfillment');
                        }
                    }
                }
            //Commented by Ronak - 02/06/2020
                //System.debug(' before the funcition ' + iter.id + ' ' + oldnewedcharges.containskey(iter.id) + ' iter.invoiceit_s__Status__c ' + iter.invoiceit_s__Status__c + ' temporder.Renew_Rebase__c ' + temporder.Renew_Rebase__c);
                if(oldnewedcharges.containskey(iter.id) && iter.invoiceit_s__Status__c=='Cancelled' && temporder!=null && temporder.Renew_Rebase__c!=null && (temporder.Renew_Rebase__c=='Renew' || temporder.Renew_Rebase__c=='Rebase')){
                    invoiceit_s__Job_Rate_Plan_Charge__c tempcharge=oldnewedcharges.get(iter.id);
                    //Changes made by Sai C for not updating Renew and rebased charge status 
                    if(tempcharge.invoiceit_s__Status__c!='Cancelled' && tempcharge.invoiceit_s__Status__c!='Truncated'&& tempcharge.invoiceit_s__Status__c!='Renewed'&& tempcharge.invoiceit_s__Status__c!='Rebased'&& tempcharge.invoiceit_s__Status__c!='Expired'){
                        tempcharge.invoiceit_s__Status__c='Cancelled';
                        tempcharge.Loss_Reasons__c=iter.Loss_Reasons__c;
                        oldnewedcharges.put(iter.id,tempcharge);
                        //Commented by Ronak - 02/06/2020
                        //system.debug('>>>>>>>>>>>>>>>inside update status old charge ' + tempcharge.Id + ' new charge ' + iter.Id);
//                        if(newMap.get(iter.id) == null && newMap.get(iter.id).invoiceit_s__Order__r.invoiceit_s__Status__c != 'Cancelled')
                        toadd=true;


                    }
                }
                if(toadd==true){
                    toupdate.add(oldnewedcharges.get(iter.id));
                }
           
        }
       // system.debug('>>>>>>>>>>>>>>>'+toupdate.size()+'>>>>>>>>>'+toupdate);
//        if(toupdate!=null && MDL_CancelOrderController.cancelrecursionflag == false){
        if(toupdate!=null )

            update toupdate;
//            MDL_CancelOrderController.cancelrecursionflag = true;

     
        //Clear Fulfillment end date for charges (created from charge's status = renewed and fulfillment start date is null)
        Set<id> setChargeIds_ClearFulfillment = new Set<Id>();
        
        //System.debug('Charge Ids'+chargeids);
        for(invoiceit_s__Job_Rate_Plan_Charge__c orderCharge : [select id,invoiceit_s__Status__c,Fulfilment_Start_Date__c,Fulfilment_End_Date__c ,
                                                                invoiceit_s__Order__c,Created_From_Charge__c , Created_From_Charge__r.invoiceit_s__Status__c
                                                                from invoiceit_s__Job_Rate_Plan_Charge__c  
                                                                where Id in : chargeids]){
                if(orderCharge.Created_From_Charge__r.invoiceit_s__Status__c == 'Renewed'){
                    if(newMap.containsKey(orderCharge.Id)){
                        if(newMap.get(orderCharge.Id).Fulfilment_Start_Date__c == null){
                            setChargeIds_ClearFulfillment.add(orderCharge.Id);
                        }   
                    }                       
                }                                                                   
        }
        
        for(invoiceit_s__Job_Rate_Plan_Charge__c orderCharge : newCharges){
            if(setChargeIds_ClearFulfillment.contains(orderCharge.Id)){
                orderCharge.Fulfilment_End_Date__c = null;
            }
        }
    }
    public static void changeRenewedOrRebasedOrTruncatedStatus(List<invoiceit_s__Job_Rate_Plan_Charge__c> triggerList) {
        Set<Id> setOrderIds = new Set<Id>();
        Set<Id> setCreatedFromOrderIds = new Set<Id>();
        Set<Id> setAutoEvergreenOppIds = new Set<Id>();
        Set<Id> setAutoEvergreenCreatedFromOrderIds = new Set<Id>();
        Set<Id> setOppIds = new Set<Id>();
        Set<String> setTruncatedOrderCharges = new Set<String>();
        List<String> lstOrderCharges = new List<String>();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> lstOldChargesToUpdate = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();        
        for(invoiceit_s__Job_Rate_Plan_Charge__c iter : triggerList){           
            setOrderIds.add(iter.invoiceit_s__Order__c);            
        }
        //system.debug('@@Rama Debug: ' + triggerList);
        for(invoiceit_s__Job__c order : [Select Id,Created_From_Order__c,invoiceit_crmx__Opportunity__c,invoiceit_crmx__Opportunity__r.Name, invoiceit_crmx__Opportunity__r.Quote_Type__c, invoiceit_crmx__Opportunity__r.Reason_Won_Lost__c                                  
                                                            from invoiceit_s__Job__c
                                                            where Id in : setOrderIds]){
            if(order.Created_From_Order__c!=null){
                if(order.invoiceit_crmx__Opportunity__r.Name.startswith('Auto evergreen') && order.invoiceit_crmx__Opportunity__r.Quote_Type__c == 'Renew' && order.invoiceit_crmx__Opportunity__r.Reason_Won_Lost__c == 'Auto Evergreen'){
                    setAutoEvergreenCreatedFromOrderIds.add(order.Created_From_Order__c);
                    setAutoEvergreenOppIds.add(order.invoiceit_crmx__Opportunity__c);
                }
                else{
                    setCreatedFromOrderIds.add(order.Created_From_Order__c);
                    setOppIds.add(order.invoiceit_crmx__Opportunity__c);
                }                
            }           
        } 
        if(setAutoEvergreenOppIds.size() > 0){
            for(invoiceit_s__Job_Rate_Plan_Charge__c orderRPC : [Select Name,i.invoiceit_s__Status__c, i.invoiceit_s__Order__r.Renew_Rebase__c,Renewable__c, i.invoiceit_s__Order__c, i.Id,isTruncated__c,invoiceit_s__Price_Type__c, Shippable__c
                                                                 From invoiceit_s__Job_Rate_Plan_Charge__c i 
                                                                 Where i.invoiceit_s__Order__c in : setAutoEvergreenCreatedFromOrderIds and invoiceit_s__Status__c!='Cancelled' and invoiceit_s__Status__c!='Expired' and (RecordType.DeveloperName = 'MDL_Order_Rate_Plan_Charge' 
                                                                 OR RecordType.DeveloperName = 'Nolo_Order_Rate_Plan_Charge'
                                                                 OR RecordType.DeveloperName = 'M_NG_Order_Rate_Plan_Charge')]) {
               if(orderRPC.invoiceit_s__Order__r.Renew_Rebase__c == 'Renew' && orderRPC.Renewable__c==true && (orderRPC.invoiceit_s__Price_Type__c == 'Monthly'|| orderRPC.invoiceit_s__Price_Type__c == 'Usage' ) && orderRPC.invoiceit_s__Status__c == 'Active'){
                    orderRPC.invoiceit_s__Status__c = 'Renewed';
                    lstOldChargesToUpdate.add(orderRPC);
               }
            }
        } 
        else{
            if(setOppIds.size() > 0){
                for(Opportunity opp : [Select Id,Truncated_Order_Charges__c  from Opportunity where Id in :setOppIds]){
                    if(opp.Truncated_Order_Charges__c!=null && opp.Truncated_Order_Charges__c!=''){
                        if(opp.Truncated_Order_Charges__c.contains(',')){
                            lstOrderCharges = new List<String>();
                            lstOrderCharges = opp.Truncated_Order_Charges__c.split(',');                        
                        }
                        else{
                            lstOrderCharges = new List<String>();
                            lstOrderCharges.add(opp.Truncated_Order_Charges__c);
                        }
                    }
                    for(String s : lstOrderCharges){
                        if(s!=null && s!='')
                            setTruncatedOrderCharges.add(s);
                    }
                }
            }    
            for(invoiceit_s__Job_Rate_Plan_Charge__c orderRPC : [Select Name,i.invoiceit_s__Status__c, invoiceit_s__Price_Type__c, Fulfilment_Start_Date__c, Opportunity_Rate_Plan_Charge__r.quote_type__c, i.invoiceit_s__Order__r.Renew_Rebase__c,Renewable__c, i.invoiceit_s__Order__c, i.Id,isTruncated__c, Shippable__c
                                                                 From invoiceit_s__Job_Rate_Plan_Charge__c i 
                                                                 Where i.invoiceit_s__Order__c in : setCreatedFromOrderIds and invoiceit_s__Status__c!='Cancelled' and invoiceit_s__Status__c!='Expired' and (RecordType.DeveloperName = 'MDL_Order_Rate_Plan_Charge' or RecordType.DeveloperName = 'Nolo_Order_Rate_Plan_Charge' or RecordType.DeveloperName = 'M_NG_Order_Rate_Plan_Charge' or RecordType.DeveloperName = 'M_N_Order_Rate_Plan_Charge')]) {
             //   System.debug('----------'+orderRPC.name);
             //   System.debug('----------'+orderRPC.invoiceit_s__Status__c);
             //   System.debug('<><><>'+setTruncatedOrderCharges);            
                if(setTruncatedOrderCharges.contains(orderRPC.Id)){
                    if(orderRPC.invoiceit_s__Status__c!='Truncated'){

                        orderRPC.invoiceit_s__Status__c = 'Truncated';
                        lstOldChargesToUpdate.add(orderRPC);
                    }
                }            
                else if(orderRPC.invoiceit_s__Order__r.Renew_Rebase__c == 'Renew') {
                    if(orderRPC.invoiceit_s__Status__c!='Truncated' && orderRPC.Renewable__c==true){
                        orderRPC.invoiceit_s__Status__c = 'Renewed';
                        lstOldChargesToUpdate.add(orderRPC);
                    }
                }
                else if(orderRPC.invoiceit_s__Order__r.Renew_Rebase__c == 'Rebase') {
                 // System.debug('Rama Trigger Rebase: ' + orderRpc + ' Quote: ' + orderRPC.Opportunity_Rate_Plan_Charge__r.quote_type__c + '  ful: ' + orderRPC.Fulfilment_Start_Date__c);                                                     
                   if(orderRPC.invoiceit_s__Status__c!='Truncated' && orderRPC.Renewable__c==true){
//                        if (orderRPC.Opportunity_Rate_Plan_Charge__r.quote_type__c == 'New' && orderRPC.Shippable__c == 'Yes' && orderRPC.Fulfilment_Start_Date__c == null && (orderRPC.invoiceit_s__Price_Type__c == 'One Time' || orderRPC.invoiceit_s__Price_Type__c == 'Monthly'))
//                            orderRPC.invoiceit_s__Status__c = 'Truncated';
//                        else 
                          orderRPC.invoiceit_s__Status__c = 'Rebased';
                        
                        lstOldChargesToUpdate.add(orderRPC);
                     // System.debug('Rama Trigger Rebase: After Update: ' + orderRpc);                                                     
                    }
                }                                                                
            }
        }
        if(lstOldChargesToUpdate.size() > 0 ) {
            Database.update(lstOldChargesToUpdate);
        }
    }
    
    /*public static void ValidateFutureFullfillmentforManuallyFulfilledProducts(List<invoiceit_s__Job_Rate_Plan_Charge__c> triggerList,Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> oldmap,Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> newmap) 
    {
        Set<Id> setOrderRPCIds = new Set<Id>();
        Map<Id,String> mapOrderRPCIdNoldOrderStatus = new Map<Id,String>();
        for(invoiceit_s__Job_Rate_Plan_Charge__c iter : triggerList){
            if(iter.Fulfilment_Start_Date__c != null && oldmap.get(iter.Id).Fulfilment_Start_Date__c!=newmap.get(iter.Id).Fulfilment_Start_Date__c){
                setOrderRPCIds.add(iter.Id);
            }
        }
        for(invoiceit_s__Job_Rate_Plan_Charge__c orderRPC : [Select invoiceit_s__Order__r.Created_From_Order__r.Renew_Rebase__c, Id
                                                             From invoiceit_s__Job_Rate_Plan_Charge__c 
                                                             Where Id in : setOrderRPCIds and Product_Provisioning__c='Manual Fulfillment' and Fulfilment_Start_Date__c >Today]) {
             if(orderRPC.invoiceit_s__Order__r.Created_From_Order__r.Renew_Rebase__c==null){
                mapOrderRPCIdNoldOrderStatus.put(orderRPC.Id,orderRPC.invoiceit_s__Order__r.Created_From_Order__r.Renew_Rebase__c);
             }
        }
          
        for(invoiceit_s__Job_Rate_Plan_Charge__c iter : triggerList){
            if(mapOrderRPCIdNoldOrderStatus.containskey(iter.id)){
                iter.adderror('Please provide valid fulfillment start date as future fulfillment date not permitted on manual fulfilled product');
            }
        }                                          
           
    }*/
    public static void createCaseDuringMidTermAdjustment(List<invoiceit_s__Job_Rate_Plan_Charge__c> triggerList) {
        Set<Id> setOrderIds = new Set<Id>();
        List<Case> lstCases = new List<Case>();
        RecordType r;
        AssignmentRule AR;
        Database.DMLOptions dmlOpts;
        //Group queue = [select Id from Group where Type='Queue' and DeveloperName='Fulfillment_Operations' LIMIT 1];
        for(invoiceit_s__Job_Rate_Plan_Charge__c ch : triggerList) {
            if(ch.invoiceit_s__Mid_Term_Status__c == 'New') {
                setOrderIds.add(ch.invoiceit_s__Order__c);
            }
        }
        if(setOrderIds.size()>0){
            r = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType = 'Case' and r.Name = 'Standard Case Record' LIMIT 1];            
            //Fetching the assignment rules on case
            for(AssignmentRule assignRule : [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1]){
                AR = assignRule;
            }
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            dmlOpts = new Database.DMLOptions();
            if(AR!=null)
                dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        
            for(invoiceit_s__Job__c ord : [Select Id,Name,invoiceit_s__Account__c from invoiceit_s__Job__c where Id in : setOrderIds]) {
                Case c = new Case();
                if(r.Id != null) {
                    c.RecordTypeId = r.Id;
                }
                c.Area__c = 'Subscription Changes';
                c.Sub_Area__c = 'Order Repush';
                c.Origin = 'Automation';
                c.Reason = 'Midterm Adjustment';
                c.Priority = 'High';
                /*if(queue.Id!= null) {
                    c.OwnerId = queue.Id;
                }*/
                c.Subject = 'Repush order number '+ ord.Name +' to downstream systems';
                c.AccountId = ord.invoiceit_s__Account__c;
                c.Parent_Order__c = ord.Id;
                c.setOptions(dmlOpts);
                lstCases.add(c);
            }
        }
        if(lstCases.size() > 0) {
            Database.insert(lstCases);
        }
    }

   
     public static void  deletefromchat(map<id, invoiceit_s__Job_Rate_Plan_Charge__c> prodmap)
    {
         list<id> oprpc = new list<id>();
         for ( invoiceit_s__Job_Rate_Plan_Charge__c o:[select id from invoiceit_s__Job_Rate_Plan_Charge__c where invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c in :prodmap.keySet() ])
             oprpc.add(o.id);
        list<Chat_Product_Order_Charge__c> cp = new list<Chat_Product_Order_Charge__c>();
        cp = [select id from Chat_Product_Order_Charge__c where Chat_Usage_Order_Rate_Plan_Charge__c in :oprpc or Chat_Product_Order_Rate_Plan_Charge__c in :oprpc];
        //system.debug('Chat Trigger: ' + cp + ' oprpc: ' + oprpc);
        delete cp;
    }

    
    
    /************************************************************************************************************
     * Author          : Akash
     * Description     : To send XML whenver Live date inserted or updated
     * Created Date    : 22/06/2017
     * *********************************************************************************************************/
    public static void liveDateCallout(List<invoiceit_s__Job_Rate_Plan_Charge__c> orpcList , map<id, invoiceit_s__Job_Rate_Plan_Charge__c> oldMap){
        
        //system.debug('@@@@@ in liveDateCallout');
         string username = UserInfo.getUsername();
        Set<Id> liveDateorders = new Set<Id>();
        for(invoiceit_s__Job_Rate_Plan_Charge__c orpc : orpcList){
           // if(trigger.isInsert || (trigger.isUpdate && ((orpc.Live_Date__c != oldMap.get(orpc.id).Live_Date__c) ||(orpc.Chat_ID__c !=NULL && orpc.Fulfilment_Start_Date__c != oldMap.get(orpc.id).Fulfilment_Start_Date__c)))){
            //Commented by Ronak on 02/06/2020 as part of CPU time limit issue
            //system.debug('@@@@@orpc.Fulfilment_Start_Date__c'+orpc.Fulfilment_Start_Date__c);
            /*system.debug('@@@@@oldMap.get(orpc.id).Fulfilment_Start_Date__c'+oldMap.get(orpc.id).Fulfilment_Start_Date__c);
            system.debug('@@@@@orpc.Live_Date__c'+orpc.Live_Date__c);
            system.debug('@@@@@orpc.Live_Date__c'+orpc.Live_Date__c);
            system.debug('@@@@@orpc.Opportunity_Name__c'+orpc.Opportunity_Name__c);
            */
            if(trigger.isInsert || (trigger.isUpdate && ((orpc.Live_Date__c != oldMap.get(orpc.id).Live_Date__c) ||(orpc.Chat_ID__c !=NULL && orpc.Fulfilment_Start_Date__c != NULL)))){
                  
                //system.debug('@@@@@orpc.Live_Date__c'+orpc.Live_Date__c);
                if((orpc.Live_Date__c != NULL && orpc.Opportunity_Name__c != Null &&  !orpc.Opportunity_Name__c.contains('Auto evergreen') )|| (orpc.Opportunity_Name__c != Null &&  !orpc.Opportunity_Name__c.contains('Auto evergreen') && orpc.Chat_ID__c != NULL && orpc.Fulfilment_Start_Date__c != NULL)){
                    liveDateorders.add(orpc.invoiceit_s__Order__c);
                }
            }
        }
        
        if(!liveDateorders.isEmpty()){
            MDL_Integration_Vim_Efs.livedateXMLCallout(liveDateorders, username);
        }
        
        
    }
    
    
    public static void addonFeatureRelationship(List<invoiceit_s__Job_Rate_Plan_Charge__c> orpcList){
        
        List<invoiceit_s__Job_Rate_Plan_Charge__c>orpctoUpdate  = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
         Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>> addonchatParentVsaddonchats = new Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>>();
         Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> idVsOrdercharge = new Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c>();
       for(invoiceit_s__Job_Rate_Plan_Charge__c orpcchat : [Select id,Name,invoiceit_s__Status__c, 
                               invoiceit_s__Accounting_Code__c,invoiceit_s__Service_End_Date__c, 
                             invoiceit_s__Service_Activation_Date__c, invoiceit_s__Row_Total__c,  
                                invoiceit_s__Job_Rate_Plan__c,invoiceit_s__Price_Type__c, 
                                  Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c,
                                   invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.Parent_Order__c, 
                                   invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__C, 
                                    invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name , 
                                        Cancel_Date__c , invoiceit_s__Charge_Date__c ,Fulfilment_Start_Date__c , 
                                        Fulfilment_End_Date__c ,Loss_Reasons__c,of_days__c,Renewable__c, 
                                        Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Product_Bundle_Line__r.invoiceit_s__Is_Quantity_Editable__c, 
                                        Opportunity_Rate_Plan_Charge__r.Optional_Product__c 
                             From invoiceit_s__Job_Rate_Plan_Charge__c where
                                                               Id IN:orpcList ]){
                         idVsOrdercharge.put(orpcchat.id,orpcchat);                                          
                        If(orpcchat.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c != NULL){
                                 IF(addonchatParentVsaddonchats.containsKey(orpcchat.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c)){
                                        addonchatParentVsaddonchats.get(orpcchat.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c).add(orpcchat);                                 
                                   }
                                   else{
                                       addonchatParentVsaddonchats.put(orpcchat.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c, new List<invoiceit_s__Job_Rate_Plan_Charge__c>{orpcchat});                                  
                                  }                                   

                         }
                                                                                                     
                   }
        
        List<invoiceit_s__Job_Product__c> orderproductstoUpdate = new List<invoiceit_s__Job_Product__c>();
        for(invoiceit_s__Job_Rate_Plan_Charge__c singleorpc : orpcList){
            If(!addonchatParentVsaddonchats.isEmpty() &&  addonchatParentVsaddonchats.containsKey(singleorpc.Opportunity_Rate_Plan_Charge__c)){
                for(invoiceit_s__Job_Rate_Plan_Charge__c childorpc : addonchatParentVsaddonchats.get(singleorpc.Opportunity_Rate_Plan_Charge__c)){
                    childorpc.Chat_Parent_Order_Rate_Plan_Charge__c = singleorpc.id;
                    orpctoUpdate.add(childorpc);
                    
                    invoiceit_s__Job_Product__c orpd = new invoiceit_s__Job_Product__c();
                    orpd.id = childorpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c;
                    orpd.Created_From_Order_Product__c = idVsOrdercharge.get(singleorpc.id).invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c;
                    orderproductstoUpdate.add(orpd);
                }
            }
            
            
        }
        
        
        If(!orpctoUpdate.isEmpty()){
            update orpctoUpdate;
        }
        If(!orderproductstoUpdate.isEmpty()){
            update orderproductstoUpdate;
        } 
        
    }
    
    
    public static void pupulateCPRPC(List<invoiceit_s__Job_Rate_Plan_Charge__c> orderRPCList){
         //System.debug('orderRPCList=====>'+orderRPCList);
         
        Set<Id> orderRPCIdSet = new Set<Id>();
        for(invoiceit_s__Job_Rate_Plan_Charge__c oRPC:orderRPCList){
            orderRPCIdSet.add(oRPC.id);
        }
        
        List<invoiceit_s__Job_Rate_Plan_Charge__c> childOrderRPCList= [Select Id,Created_From_Charge__c,
        Created_From_Charge__r.invoiceit_s__Order__c,
        RecordType.DeveloperName,SIN__c,Chat_Parent_Order_Rate_Plan_Charge__c,
        invoiceit_s__Order__r.invoiceit_crmx__Opportunity__r.Name
        From invoiceit_s__Job_Rate_Plan_Charge__c 
        Where Created_From_Charge__c!=null 
        //AND RecordType.DeveloperName = :'M_NG_Order_Rate_Plan_Charge'
        AND Id IN:orderRPCIdSet];
        
        //System.debug('childOrderRPCList=====>'+childOrderRPCList);
        Set<Id> parentOrderId = new Set<Id>();
        Map<String,invoiceit_s__Job_Rate_Plan_Charge__c> mapSINToChildOrder = new Map<String,invoiceit_s__Job_Rate_Plan_Charge__c>();
        
        for(invoiceit_s__Job_Rate_Plan_Charge__c cOrder:childOrderRPCList){
            parentOrderId.add(cOrder.Created_From_Charge__r.invoiceit_s__Order__c);
            mapSINToChildOrder.put(cOrder.Created_From_Charge__r.invoiceit_s__Order__c+'-'+cOrder.SIN__c,cOrder);
        }
        
        //System.debug('mapSINToChildOrder=====>'+mapSINToChildOrder);
        
        //System.debug('parentOrderId=====>'+parentOrderId);
        List<invoiceit_s__Job_Rate_Plan_Charge__c> parentOrderRPCList= [Select Id,invoiceit_s__Order__c,
        RecordType.DeveloperName,SIN__c,Chat_Parent_Order_Rate_Plan_Charge__c,Chat_Parent_Order_Rate_Plan_Charge__r.SIN__c
        From invoiceit_s__Job_Rate_Plan_Charge__c 
        Where Chat_Parent_Order_Rate_Plan_Charge__c!=null 
        AND RecordType.DeveloperName = :'M_NG_Order_Rate_Plan_Charge'
        AND invoiceit_s__Order__c IN:parentOrderId];
        
        //System.debug('parentOrderRPCList=====>'+parentOrderRPCList);

        
        for(invoiceit_s__Job_Rate_Plan_Charge__c pOrder: parentOrderRPCList){
            if(mapSINToChildOrder.containsKey(pOrder.invoiceit_s__Order__c+'-'+pOrder.SIN__c) && 
             mapSINToChildOrder.containsKey(pOrder.invoiceit_s__Order__c+'-'+pOrder.Chat_Parent_Order_Rate_Plan_Charge__r.SIN__c)){
                 //System.debug('In if =====>');
                mapSINToChildOrder.get(pOrder.invoiceit_s__Order__c+'-'+pOrder.SIN__c).Chat_Parent_Order_Rate_Plan_Charge__c = 
                mapSINToChildOrder.get(pOrder.invoiceit_s__Order__c+'-'+pOrder.Chat_Parent_Order_Rate_Plan_Charge__r.SIN__c).Id;
            }
        }
        update mapSINToChildOrder.values();
        
    }   
    
    
        
}
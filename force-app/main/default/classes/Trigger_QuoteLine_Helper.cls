/*
Apex Class   : Trigger_QuoteLine_Helper
Created By   : Serge Kandukuri 
Description  : This is Helper class for QuoteLineTrigger

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6018    SS            31/03/2022   John Mattheson  T01     Move process builders to apex
MHBS-8923    Chetna        09/03/23                     T02     Fix for value ID's being null due to DML inside for loop
MHMAC-374    RR            09/25/2023                   T03     PSD Development Work
MHMAC-570    RR            12/08/2023                   T04     Update Sales Rep
************************************************************************************************************************/
public class Trigger_QuoteLine_Helper{
    public static List<String> prodName = new List<String>{'Avvo Attorney Base Profile','Avvo.com Banner Ads','M-A Attorney Complete Profile Plus','Avvo.com Sponsored Listings'};
   
    public static void updateParentQuote(List<SBQQ__QuoteLine__c> newList){
        set<Id> sQuoteId = new set<Id>();
        for(SBQQ__QuoteLine__c qli: newList){
            if((qli.SBQQ__SubscriptionType__c == 'Renewable' || qli.SBQQ__SubscriptionType__c == 'Renewable/Evergreen')){
                sQuoteId.add(qli.SBQQ__Quote__c);
            }
            
        }
        
        if(!sQuoteId.isEmpty()){
            calculateBillingUnitPrice(sQuoteId);
        }
    }
    //T03 Start
    public static void updateParentQuo(List<SBQQ__QuoteLine__c> newList){
        system.debug('rrr in new calc');
        set<Id> sQuoteId = new set<Id>();
        Id RecordTypeId_MAquoteLine = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Quote Line').getRecordTypeId(); 
        for(SBQQ__QuoteLine__c qli: newList){
            if(qli.RecordTypeId == RecordTypeId_MAquoteLine){
                sQuoteId.add(qli.SBQQ__Quote__c);
            }     
        }
    
        if(!sQuoteId.isEmpty()){
            system.debug('rrr111 in new calc');
            calculateProductType(sQuoteId);
            updateSalesRep(sQuoteId); //MHMAC-570 T04
        }

    }

    /******************************************************************************************************************
    Method      : updateSalesRep
    Parameters  : Id
    Return Type : 
    Description : Method to update sales rep in Quote MHMAC-570 T04
    *******************************************************************************************************************/  
    public static void updateSalesRep(set<Id> sQuoteId){
        List<SBQQ__Quote__c> lstQuote = [SELECT Id,SBQQ__Type__c,Calculate_Billing_Unit_Price__c,SBQQ__SalesRep__c FROM SBQQ__Quote__c WHERE Id IN: sQuoteId];
        List<SBQQ__Quote__c> quoteToUpdate = new List<SBQQ__Quote__c>();

        for(SBQQ__Quote__c quo : lstQuote){
            if(quo.SBQQ__Type__c == 'Amendment' && quo.SBQQ__SalesRep__c != UserInfo.getUserId()){
                quo.SBQQ__SalesRep__c = UserInfo.getUserId();
                quoteToUpdate.add(quo);
            }
        }

        database.update(quoteToUpdate);
    }

    public static void calculateProductType(set<Id> sQuoteId){
    
      
      List<SBQQ__Quote__c> lstQuote = [SELECT Id,Calculate_Billing_Unit_Price__c,(Select id ,SBQQ__Product__c,isAnimated__c, SBQQ__Product__r.Name from SBQQ__LineItems__r where (SIN__c ='' or SIN__c = null) and SBQQ__Product__r.Name =: prodName ) FROM SBQQ__Quote__c WHERE Id IN: sQuoteId];
      List<String> productName = new List<String>();
      List<SBQQ__Quote__c> quoteToUpdate = new List<SBQQ__Quote__c>();
      List<Double> disNumber = new List<Double>();
      Map<String, Double> productValueMap = new Map<String, Double>();
      Map<String, String> productValueMap1 = new Map<String, String>();
   
      for(PSD_Mapping__mdt metaDataRec : [select id,MasterLabel,Display_Number__c,Product_Name__c 
      From  PSD_Mapping__mdt]){
          system.debug('rrr33 in new calc');
          productValueMap.put(metaDataRec.Product_Name__c, metaDataRec.Display_Number__c);
          productValueMap1.put(metaDataRec.Product_Name__c, metaDataRec.MasterLabel);
          system.debug('rrr44 in new calc :::' + productValueMap);
      } 

    for(SBQQ__Quote__c qo : lstQuote){
        system.debug('rrr22 in new calc');
        if(qo.SBQQ__LineItems__r.size() > 0){
            for(SBQQ__QuoteLine__c ql : qo.SBQQ__LineItems__r){
                system.debug('rrr33 in new calc');
                if(ql.isAnimated__c == true){
                    //productName.add('Animated Display Ad');
                    productName.add('Avvo.com Animated Banner Ads');      
                }
                else{
                    productName.add(ql.SBQQ__Product__r.Name);
                }
                system.debug('rrr in new calc :::' + productName);
            }
        
            for(string s : productName){
                system.debug('rrr55 string s :::' + s);
                if(productValueMap.containsKey(s)){
                    disNumber.add(productValueMap.get(s));
                }
            
                system.debug('rrr55 in new calc :::' + disNumber);
            }

            disNumber.sort();
            String type;
            String type1;
            for(String key : productValueMap.keySet()){
                if(productValueMap.get(key) == disNumber[0]){
                    type = key;
                }
                if(productValueMap1.containsKey(type)){
                    type1 = productValueMap1.get(type);
                }
                else{
                    type1 = '';
                }
                
            }
            qo.Product_Field_Requirements__c = type1;
            quoteToUpdate.add(qo);
            //update qo;
            system.debug('rrr66 in new calc :::' + type);
    }
    else {
        qo.Product_Field_Requirements__c = '';
        quoteToUpdate.add(qo);
    }
}
    if(quoteToUpdate.size() > 0){
        database.update(quoteToUpdate);
    }
}
 //T03 End
    
    
    
    @Future
    public static void calculateBillingUnitPrice(set<Id> sQuoteId){
        Map<String,String> productCode = new Map<String,String>();
       
        List<SBQQ__Quote__c> lstQuote = [SELECT Id,Calculate_Billing_Unit_Price__c FROM SBQQ__Quote__c WHERE Id IN: sQuoteId];
        for(SBQQ__Quote__c q: lstQuote){
            q.Calculate_Billing_Unit_Price__c = TRUE;
            
        }
        update lstQuote;
        
    }
    
   //added by IJ on Dec 28,2020 for upsell
    public static void updateOrderItemandSubs(List<SBQQ__QuoteLine__c> newList, Map<Id, SBQQ__QuoteLine__c> oldMap){
     list<Id> SubscriptionIds = new list<Id>();
     List<OrderItem> OrderItemsToUpdate = new list<OrderItem>();
     List<SBQQ__Subscription__c> SubsToUpdate = new list<SBQQ__Subscription__c>();
      for(SBQQ__QuoteLine__c qli: newList){
         if(qli.Part_of_Upsell__c == true && (qli.Part_of_Upsell__c!= oldMap.get(qli.id).Part_of_Upsell__c)){
            if(qli.SBQQ__RenewedSubscription__c!=null)
            SubscriptionIds.add(qli.SBQQ__RenewedSubscription__c); 
            else if(qli.SBQQ__UpgradedSubscription__c!=null)
            SubscriptionIds.add(qli.SBQQ__UpgradedSubscription__c);            
            }
      } system.debug('SubscriptionIds'+SubscriptionIds);
     
     if(SubscriptionIds.size()>0){ 
      for(OrderItem ObjOrderItem:[select Id,Part_of_Upsell__c,SBQQ__Subscription__c,OrderId from OrderItem where SBQQ__Subscription__c in: SubscriptionIds]){
         ObjOrderItem.Part_of_Upsell__c=true;         
         OrderItemsToUpdate.add(ObjOrderItem);
      }
      system.debug('OrderItemsToUpdate'+OrderItemsToUpdate);
      if(OrderItemsToUpdate.size()>0)
          update OrderItemsToUpdate;
      
      for(SBQQ__Subscription__c ObjSub: [select Id,Part_of_Upsell__c,SBQQ__OrderProduct__c from SBQQ__Subscription__c where Id in: SubscriptionIds ]){
         ObjSub.Part_of_Upsell__c=true;
         SubsToUpdate.add(ObjSub);
      }
      if(SubsToUpdate.size()>0)
          update SubsToUpdate;
          }
    }
    
    public static void updatePriceOnQLConsumptionSchedule(List<SBQQ__QuoteLine__c> newList, Map<Id, SBQQ__QuoteLine__c> oldMap){
        Map<Id, decimal> mapQLIWithUsagePrice = new Map<Id, decimal>();
        for(SBQQ__QuoteLine__c qli: newList){
            if(qli.SBQQ__SubscriptionType__c == 'Evergreen' && qli.Usage_List_Price__c != null
             && (trigger.isInsert || (trigger.isUpdate && qli.Usage_List_Price__c != oldMap.get(qli.id).Usage_List_Price__c))){
                mapQLIWithUsagePrice.put(qli.Id, qli.Usage_List_Price__c);
            }
        }
        
        if(!mapQLIWithUsagePrice.isEmpty()){
            List<SBQQ__QuoteLineConsumptionRate__c> lstQLCSRateUpdate = new List<SBQQ__QuoteLineConsumptionRate__c>();
            SBQQ__QuoteLineConsumptionRate__c objCSRateUpdate;
            List<SBQQ__QuoteLineConsumptionRate__c> lstQLCSRate = [SELECT Id, SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__c FROM SBQQ__QuoteLineConsumptionRate__c WHERE SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__c IN: mapQLIWithUsagePrice.keyset()];
            for(SBQQ__QuoteLineConsumptionRate__c csRate: lstQLCSRate){
                if(mapQLIWithUsagePrice != null && mapQLIWithUsagePrice.containsKey(csRate.SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__c)){
                    objCSRateUpdate = new SBQQ__QuoteLineConsumptionRate__c(id=csRate.id);
                    objCSRateUpdate.SBQQ__Price__c = mapQLIWithUsagePrice.get(csRate.SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__c);
                    lstQLCSRateUpdate.add(objCSRateUpdate);
                }
            }
            if(!lstQLCSRateUpdate.isEmpty()){
                update lstQLCSRateUpdate;
            }
        }
    }
    
    /*
    public static void splitQLI(List<SBQQ__QuoteLine__c> newList){
        List<SBQQ__QuoteLine__c> lstQLICreate = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c objQLI;
        
        List<SBQQ__QuoteLine__c> lstQLIDel = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c objQLIDel;
        
        for(SBQQ__QuoteLine__c qli: newList){
            if(qli.SBQQ__Quantity__c > 1){
                for(integer i=1; i<qli.SBQQ__Quantity__c; i++){
                    objQLI =qli.clone();
                    objQLI.SBQQ__Quantity__c = 1;
                    //objQLI.SBQQ__BundledQuantity__c = 1;
                    lstQLICreate.add(objQLI);
                }
                objQLIDel = new SBQQ__QuoteLine__c(id=qli.id);
                objQLIDel.SBQQ__Quantity__c = 1;
                //objQLIDel.SBQQ__BundledQuantity__c = 1;
                lstQLIDel.add(objQLIDel);
            }
        }
        
        if(!lstQLICreate.isEmpty()){
            insert lstQLICreate;
        }
        
        if(!lstQLIDel.isEmpty()){
            system.debug('############');
            system.debug('############'+lstQLIDel);
            update lstQLIDel;
        }
    }*/
    /*
    
    public static void setQuantityto1(List<SBQQ__QuoteLine__c> newList){
        List<SBQQ__QuoteLine__c> lstQLIUpdate = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c objQLI;
        
        for(SBQQ__QuoteLine__c qli: newList){
            if(qli.SBQQ__Quantity__c > 1){
                objQLI = new SBQQ__QuoteLine__c(id=qli.id);
                objQLI.SBQQ__Quantity__c = 1;
                //objQLI.SBQQ__BundledQuantity__c = 1;
                lstQLIUpdate.add(objQLI);
            }
        }
        if(!lstQLIUpdate.isEmpty()){
            update lstQLIUpdate;
        }
    }
    
    public static void recalculationNeeded(List<SBQQ__QuoteLine__c> newList, Map<Id, SBQQ__QuoteLine__c> oldMap){
        set<Id> sQLIId = new set<Id>();
        for(SBQQ__QuoteLine__c qli: newList){
            if(qli.Recalculation_Needed__c && qli.Recalculation_Needed__c != oldMap.get(qli.id).Recalculation_Needed__c){
                sQLIId.add(qli.id);
            }
        }
        if(!sQLIId.isEmpty()){
            recalculationNeeded(sQLIId);
        }
    }
    
    @future
    public static void recalculationNeeded(set<Id> sQLIId){
        List<SBQQ__QuoteLine__c> lstQLI = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Id IN: sQLIId AND Recalculation_Needed__c = TRUE];
        List<SBQQ__QuoteLine__c> lstQLIUpdate = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c objQLI;
        
        for(SBQQ__QuoteLine__c qli: lstQLI){
            objQLI = new SBQQ__QuoteLine__c(id=qli.id);
            objQLI.Recalculation_Needed__c = false;
            lstQLIUpdate.add(objQLI);
        }
        if(!lstQLIUpdate.isEmpty()){
           update lstQLIUpdate;
        }
    }
    */
    //added by saiv
    public static void sendReleaseInventory(List<SBQQ__QuoteLine__c> lstOppProdsToDelete) {
        Set<Id> setOppProdsToDelete = new Set<Id>();
        Set<Id> setOppProdIds = new Set<Id>();
        System.debug('inside Delete Opp prod trigger handler');
        User u = [select Id, username from User where Id = :UserInfo.getUserId()];
        for(SBQQ__QuoteLine__c oppProd : lstOppProdsToDelete) {
            setOppProdsToDelete.add(oppProd.Id);
        }
        for(SBQQ__QuoteLine__c oppProd : [Select Id,Inventory_Id__c, SIN__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Type__c
                                                              from SBQQ__QuoteLine__c
                                                              Where Id in : setOppProdsToDelete]) {
            if(oppProd.SBQQ__Quote__r.SBQQ__Type__c == 'Renew') {
                if(!Test.isRunningTest()) { 
                    lstOppProdsToDelete[0].addError('Products cannot be deleted since this is a renewal opportunity');
                }
            }
            if(oppProd.SIN__c==null || oppProd.SIN__c==''){
                if(oppProd.Inventory_Id__c != null && oppProd.Inventory_Id__c != '') {
                    setOppProdIds.add(oppProd.Id);                                  
                }
            }                   
        }
        System.debug('list to delete :'+setOppProdIds);
        if(setOppProdIds.size() > 0) {
            if(!test.isRunningTest()) {
                CPQ_MDL_Integration_Vim_Efs.releaseInventoryRequest(setOppProdIds,u.Username);
            }
        }
     }
     
    //<T01> - MHBS-6018 
    public static void populateBillingSchedule(List<SBQQ__QuoteLine__c> newQLIs,Map<Id, SBQQ__QuoteLine__c> oldQLIs) {
    
        List<SBQQ__QuoteLine__c> qlToUpdate = new List<SBQQ__QuoteLine__c>();

        for(SBQQ__QuoteLine__c QLI: [Select id, SBQQ__ChargeType__c,SBQQ__Quote__r.SBQQ__Account__c,SBQQ__Quote__r.SBQQ__Account__r.Billing_Schedule__c from SBQQ__QuoteLine__c where id in :newQLIs]){
           
           if(QLI.SBQQ__Quote__r.SBQQ__Account__c != null 
              && QLI.SBQQ__Quote__r.SBQQ__Account__r.Billing_Schedule__c != null 
              && QLI.SBQQ__Quote__r.SBQQ__Account__r.Billing_Schedule__c == 'Advanced'    && QLI.SBQQ__ChargeType__c != 'One-Time'   && QLI.SBQQ__ChargeType__c != 'Usage'){
                 QLI.SBQQ__BillingType__c = 'Advance'; 
                  qlToUpdate.add(QLI);
              }
            
            if(QLI.SBQQ__Quote__r.SBQQ__Account__c != null 
              && QLI.SBQQ__Quote__r.SBQQ__Account__r.Billing_Schedule__c != null 
              && QLI.SBQQ__Quote__r.SBQQ__Account__r.Billing_Schedule__c == 'Arrears' 
              && QLI.SBQQ__ChargeType__c != 'One-Time' 
              && QLI.SBQQ__ChargeType__c != 'Usage'){
                 QLI.SBQQ__BillingType__c = 'Arrears';                  
                  qlToUpdate.add(QLI);
              }
        }       
        System.debug(qlToUpdate);
        if(qlToUpdate.size()>0){//<T02>
            update qlToUpdate;
        }
    }

//MHMAC-407 MHMAC-480
    /*public static void UpdateProductCheckOnContact(List<SBQQ__QuoteLine__c> newQLIs,Map<Id, SBQQ__QuoteLine__c> oldQLIs) {
        //Check The Checkbox on Contact
        Set<Id> ConId = new Set<Id>();
        List<Contact> ConToUpdate = new List<Contact>();
        System.debug('testAAAAAAAA---> ' + newQLIs);
        for(SBQQ__QuoteLine__c QLI :  newQLIs){
        System.debug('testBBBBBBBB---> ' +QLI.SBQQ__Quantity__c+ ' --- ' + QLI.Contact__c + ' --- ' + QLI.Contact__r.CPP_Base_Product_Added__c);
            if(QLI.SBQQ__Quantity__c != 0 && QLI.Contact__c != Null && QLI.Contact__r.CPP_Base_Product_Added__c == false){
              System.debug('testCCCCCCC---> ' + newQLIs);  
              ConId.add(QLI.Contact__c);  
            }
        }
        System.debug('testDDDDDDDD---> ' + ConId);
        for(Contact Con: [Select Id,CPP_Base_Product_Added__c FROM Contact WHERE Id IN: ConId]){
            System.debug('testEEEEEEEEE---> ' + Con.CPP_Base_Product_Added__c);
            if(Con.CPP_Base_Product_Added__c == False){
                System.debug('testFFFFFFFFF---> ' + Con.CPP_Base_Product_Added__c);
                Con.CPP_Base_Product_Added__c = True;
                ConToUpdate.add(Con);  
            }
        }
        System.debug('testGGGGGGGGG---> ' + ConToUpdate);
        if(ConToUpdate.Size() > 0 ){
            Update ConToUpdate;
        }
        //-------------------------------------------------------------
        
        //UnCheck The Checkbox on Contact
        Set<Id> ConIdAA = new Set<Id>();
        List<Contact> ConToUpdateAA = new List<Contact>();
        List<SBQQ__QuoteLine__c> QuoLUpdateAA = new List<SBQQ__QuoteLine__c>();
        System.debug('BoxAAAAAAAAAAAAAA---> ' + newQLIs + '--- ' + oldQLIs);
        for(SBQQ__QuoteLine__c QuoL : [SELECT ID,SBQQ__Quantity__c,Contact__c,Contact__r.CPP_Base_Product_Added__c FROM SBQQ__QuoteLine__c WHERE ID IN: newQLIs]){

  /*          System.debug('BoxBBBBBBBBBB---> ' + QuoL.SBQQ__Quantity__c);
            if(QuoL.SBQQ__Quantity__c == 0){
                System.debug('BoxCCCCCCCCCCC---> ' + QuoL.Contact__c);
                if(QuoL.Contact__c != Null){
                    
                    System.debug('BoxDDDDDDDDDDDDDD---> ' + QuoL.Contact__r.CPP_Base_Product_Added__c);
                    if(QuoL.Contact__r.CPP_Base_Product_Added__c == True){
                        System.debug('BoxEEEEEEEEEEEEE---> ' + oldQLIs.get(QuoL.Id).SBQQ__Quantity__c); 
                        if(QuoL.SBQQ__Quantity__c != oldQLIs.get(QuoL.Id).SBQQ__Quantity__c){
*/
                            /*   if(QuoL.SBQQ__Quantity__c != oldQLIs.get(QuoL.Id).SBQQ__Quantity__c && QuoL.SBQQ__Quantity__c == 0 && QuoL.Contact__c != Null && QuoL.Contact__r.CPP_Base_Product_Added__c == True) {
                            System.debug('testBSSB123334---> ' + QuoL);
                            ConIdAA.add(QuoL.Contact__c);
                            //QuoL.Contact__c = Null;
                            QuoLUpdateAA.add(QuoL); 
                        
                               }
                
                               
        }
        System.debug('BoxFFFFFFFFFFFFF---> ' + QuoLUpdateAA);
        if(QuoLUpdateAA.Size() > 0 ){
           System.debug('BoxGGGGGGGGGGGGG---> ' + QuoLUpdateAA);
            Update QuoLUpdateAA;
        }
        System.debug('BoxHHHHHHHHHHH--> ' + ConIdAA);
        for(Contact Cont: [Select Id,CPP_Base_Product_Added__c FROM Contact WHERE Id IN: ConIdAA]){
            System.debug('BoxIIIIIIIIIIIIII---> ' + Cont.CPP_Base_Product_Added__c);
            if(Cont.CPP_Base_Product_Added__c == True){
               System.debug('BoxJJJJJJJJJJJJJJJ---> ' + Cont.CPP_Base_Product_Added__c); 
                Cont.CPP_Base_Product_Added__c = False;
                ConToUpdateAA.add(Cont);  
            }
        }
        System.debug('BoxKKKKKKKKKKKK--> ' + ConToUpdateAA);
        if(ConToUpdateAA.Size() > 0 ){
            System.debug('BoxLLLLLLLLLLL--> ' + ConToUpdateAA);
            Update ConToUpdateAA;
        }
        

        
    }  */// MHMAC-480 End     
      
      // Quote line group changes Started
      
        public static void UpdateQuoteLineGrp(List<SBQQ__QuoteLine__c> quoteLines,Map<Id, SBQQ__QuoteLine__c> oldQLIs) {
        System.debug('111111111111111111 ' + quoteLines);
        Set<Id> QuoteIdSet = new Set<Id>();
        List<SBQQ__QuoteLine__c> filterquoteLine = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c quoLine : [SELECT Id,SBQQ__Quote__r.SBQQ__LineItemsGrouped__c,SBQQ__Product__r.Family,SBQQ__Group__c FROM SBQQ__QuoteLine__c WHERE Id IN: quoteLines]){
            System.debug('222222222222222222222 ' + quoLine.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c + '   ' + quoLine.SBQQ__Group__c);
            if(quoLine.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c == True && quoLine.SBQQ__Group__c == Null){
                System.debug('3333333333333333333333333333 ' + quoteLines);
                QuoteIdSet.add(quoLine.SBQQ__Quote__c);
                filterquoteLine.add(quoLine);
            }
        }
        
        Map<Id, Map<String, Id>> quoteIdToProductFamilyToGroupId = new Map<Id, Map<String, Id>>();
        
        List<SBQQ__QuoteLineGroup__c> quoteLineGroups = [SELECT Id, Name, SBQQ__Quote__c FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c IN: QuoteIdSet];
        System.debug('444444444444444444444 ' + quoteLineGroups);

        for (SBQQ__QuoteLineGroup__c groupQl : quoteLineGroups) {
            System.debug('5555555555555555555555 ' + quoteIdToProductFamilyToGroupId + '   ' + groupQl.SBQQ__Quote__c);
            if (!quoteIdToProductFamilyToGroupId.containsKey(groupQl.SBQQ__Quote__c)) {
                System.debug('666666666666666666666666 ');
                quoteIdToProductFamilyToGroupId.put(groupQl.SBQQ__Quote__c, new Map<String, Id>());
            }
            System.debug('77777777777777777777 ');
            quoteIdToProductFamilyToGroupId.get(groupQl.SBQQ__Quote__c).put(groupQl.Name, groupQl.Id);
        }
        
        List<SBQQ__QuoteLine__c> updatedQuoteLines = new List<SBQQ__QuoteLine__c>();
        System.debug('888888888888888888888888 ' + filterquoteLine);
        for (SBQQ__QuoteLine__c quoteLine : filterquoteLine) {
            System.debug('888888888888888888888888 ' + quoteIdToProductFamilyToGroupId);
            Map<String, Id> productFamilyToGroupId = quoteIdToProductFamilyToGroupId.get(quoteLine.SBQQ__Quote__c);
            String QLGroup = quoteLine.SBQQ__Product__r.Family;
            if(QLGroup == 'Advertising'){
                System.debug('kkasssssskakakka ' + QLGroup);
                QLGroup = 'Advertisements';
            }
            System.debug('999999999999999 ' + productFamilyToGroupId + '  ' + quoteLine.SBQQ__Product__r.Family );
            if (productFamilyToGroupId != null && productFamilyToGroupId.containsKey(QLGroup)) {
                System.debug('10101010101010101010101 ' + productFamilyToGroupId.containsKey(QLGroup) );
                System.debug('7788788788788 ' + productFamilyToGroupId.get(QLGroup));
                quoteLine.SBQQ__Group__c = productFamilyToGroupId.get(QLGroup);
                System.debug('10101010101010101010101 ' + quoteLine.SBQQ__Group__c);
                updatedQuoteLines.add(quoteLine);
            }
        }
        
        System.debug('2121212132122 '  + updatedQuoteLines);
        if (!updatedQuoteLines.isEmpty()) {
            System.debug('2121212132122 '  + updatedQuoteLines);
            update updatedQuoteLines; 
            System.debug('2121212132122 '  + updatedQuoteLines);
        }
        
    }
    
     // Quote line group changes Ended


@InvocableMethod(label = 'calculateQuote')
      public static void calculateQuote(List<ID> quoteIDs){
        //recalculateQuoteForPromo(quoteIDs);
          if(quoteIDs.size()>0){
              Sbqq__quote__c quoteRec = [Select Id,recalculatequote__c from Sbqq__quote__c where id = :quoteIDs[0]];
              if(quoteRec.recalculatequote__c == true){
                  quoteRec.recalculatequote__c = false;
              }else if(quoteRec.recalculatequote__c == false){
                  quoteRec.recalculatequote__c = true;
              }
             update quoteRec;
          }          
          
        System.debug('TTTTTTTTTTTTTS' + quoteIDs);
    }
    
    @future(callout=true)
    public static void recalculateQuoteForPromo(List<Id> quoteIDs) {
        System.debug(quoteIDs);
          if(quoteIDs.size()>0){
              Id qId= quoteIDs[0];
              QuoteReader qreader = new QuoteReader();
              System.debug(qId);
              QuoteModel quoteModel = qreader.read(qId);
              
              QuoteCalculator calculator = new QuoteCalculator();
              System.debug(quoteModel);
              calculator.calculate(quoteModel, 'QuoteCalculatorCallbackClass');
    }
    }    
        public static void UpdateCancelNowDate(List<SBQQ__QuoteLine__c> quoteLines,Map<Id, SBQQ__QuoteLine__c> oldQLIs) {
        Set<Id> OrderProId = new Set<Id>();
        Set<Id> SubId = new Set<Id>();
        Date CancelNow;
        List<OrderItem> UpdateOrderPro = new List<OrderItem>();
        List<SBQQ__Subscription__c> UpdateSub = new List<SBQQ__Subscription__c>();
        for(SBQQ__QuoteLine__c Quo : [SELECT ID,Cancel_Now_Date__c,SBQQ__UpgradedSubscription__c,SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c FROM SBQQ__QuoteLine__c WHERE Id IN: quoteLines AND Cancel_Now_Date__c != Null AND SBQQ__Quantity__c = 0]){
            System.debug('ALALALALALALAALA ' + Quo.Cancel_Now_Date__c + ' ' + oldQLIs.get(Quo.Id).Cancel_Now_Date__c);
            if(Quo.Cancel_Now_Date__c != oldQLIs.get(Quo.Id).Cancel_Now_Date__c && oldQLIs.get(Quo.Id).Cancel_Now_Date__c == Null ){
                CancelNow = Quo.Cancel_Now_Date__c;
                SubId.add(Quo.SBQQ__UpgradedSubscription__c);
                OrderProId.add(Quo.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c);
            }
        }
        if(OrderProId.Size() > 0) {
            for(OrderItem OrdItem : [SELECT ID,Cancel_Now_Date__c FROM OrderItem WHERE ID IN: OrderProId AND Cancel_Now_Date__c = Null]){
                OrdItem.Cancel_Now_Date__c = CancelNow;
                UpdateOrderPro.add(OrdItem);
            }
        }
        if(SubId.Size() > 0) {
            for(SBQQ__Subscription__c OrdItem : [SELECT ID FROM SBQQ__Subscription__c WHERE ID IN: SubId AND Cancel_Now_Date__c = Null]){
                OrdItem.Cancel_Now_Date__c = CancelNow;
                UpdateSub.add(OrdItem); 
            }
        }
        System.debug('uyioojojojjojjijooi ' + CancelNow + ' ' + UpdateOrderPro + ' ' + UpdateSub);
        if(UpdateOrderPro.size() > 0 ){
            Update UpdateOrderPro;
        }
        if(UpdateSub.size() > 0 ){
            Update UpdateSub;
        }
        System.debug('rarararararraat ' + OrderProId + '  ' + SubId);
    }
}
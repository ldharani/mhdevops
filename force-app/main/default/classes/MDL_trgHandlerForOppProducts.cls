/*
 * Modified By      : Lister Technologies
 * Modified Date    : 13th May,2015 
 * Modified Purpose : MHBS-48
 *
 * Modified By      : Lister Technologies
 * Modified Date    : 07th September,2015 
 * Modified Purpose : MHBS-386
 */
public with sharing class MDL_trgHandlerForOppProducts {
    /*public void restrictProductAddition(List<invoiceit_crmx__Opportunity_Product__c> lstOppProds) {
        Set<id> setOppIds = new Set<id>();
        for(invoiceit_crmx__Opportunity_Product__c oppProd : lstOppProds) {
            System.debug('OPPORTUNITY is'+oppProd.invoiceit_crmx__Opportunity__c+'&&&&Quote Type&&&&'+oppProd.invoiceit_crmx__Opportunity__r.Quote_Type__c);
            setOppIds.add(oppProd.invoiceit_crmx__Opportunity__c);
            System.debug('$$$$'+setOppIds);
        }
        for(invoiceit_crmx__Opportunity_Product__c oppProd : [Select Id,invoiceit_crmx__Opportunity__c,invoiceit_crmx__Opportunity__r.Quote_Type__c,invoiceit_crmx__Opportunity__r.invoiceit_crmx__Recalculate__c 
                                                              from invoiceit_crmx__Opportunity_Product__c
                                                              Where invoiceit_crmx__Opportunity__c in : setOppIds]) {
            System.debug('Opp is:::'+oppProd.invoiceit_crmx__Opportunity__c+'^^^Quote Type of Opp'+oppProd.invoiceit_crmx__Opportunity__r.Quote_Type__c);
            if(oppProd.invoiceit_crmx__Opportunity__r.Quote_Type__c == 'Renew') {
                if(!Test.isRunningTest()) {     
                    lstOppProds[0].addError('New Products cannot be added since this is a renewal opportunity');
                }
            }   
        }
    }*/
    public void upsellPackagesValidation(List<invoiceit_crmx__Opportunity_Product__c> lstOppProds){
        
        System.debug('===============Inside Sai Method====================');
        Set<id> OppId = new Set<id>();
        Set<Id> productBundleIdSet = new Set<ID>();
        String webProds = Web_Products__c.getValues('Web Products List').Value__c; //custom setting        
        List<String> webprodsList = new List<String>();
        webprodsList = webProds.split(',');
        system.debug('webprodsList here:::'+webprodsList);
        
        Set<String> webProdsSet = new Set<String>();
        webProdsSet.addAll(webprodsList);
        
        
        for(invoiceit_crmx__Opportunity_Product__c oppProd :lstOppProds){
            OppId.add(oppProd.invoiceit_crmx__Opportunity__c);// add opportunity Ids to set
            productBundleIdSet.add(oppProd.invoiceit_crmx__Product_Bundle__c); //add product bundel ids
      
        }
        Map<id,invoiceit_s__Product_Bundle__c> productBundleMap = new Map<Id,invoiceit_s__Product_Bundle__c>([select id,Name from invoiceit_s__Product_Bundle__c where id IN: productBundleIdSet]);
        
        Boolean ProfessionalProfileFlag = false;
        Boolean webProdFlag = false;
        Boolean isOldOpp= false;
        Boolean webProdPkgFlag = false;
        
        // query the opportunityProducs records which carryforwarded from previous order.
        for(invoiceit_crmx__Opportunity_Product__c alloppProd :[Select id, Name, Product_SIN__c, invoiceit_crmx__Product_Code__c, invoiceit_crmx__Product_Bundle__c, invoiceit_crmx__Opportunity__r.Created_From_Order__c
                                                                from invoiceit_crmx__Opportunity_Product__c where invoiceit_crmx__Opportunity__c IN:OppId]){
             isOldOpp = true;
             // check the condition which of previous opportunity products
             if(alloppProd.name =='Professional Profile'){
                 ProfessionalProfileFlag = true;
             }
             if(alloppProd.name =='Web Bronze' || alloppProd.name =='Web Gold' ||alloppProd.name =='Web Silver' || alloppProd.name =='Web Platinum'){
                 webProdFlag = true;
             }  
             if(webProdsSet.contains(alloppProd.invoiceit_crmx__Product_Code__c)){
                 webProdPkgFlag = true;
             }                                                
             
        }
        
        for(invoiceit_crmx__Opportunity_Product__c alloppProd :lstOppProds){
        
            if(!(ProfessionalProfileFlag && webProdFlag)  &&  isOldOpp ){
                
                if(alloppProd.invoiceit_crmx__Product_Bundle__c != null && productBundleMap.containsKey(alloppProd.invoiceit_crmx__Product_Bundle__c) && (productBundleMap.get(alloppProd.invoiceit_crmx__Product_Bundle__c).Name =='Gold Upsell - SEO' || productBundleMap.get(alloppProd.invoiceit_crmx__Product_Bundle__c).Name =='Platinum Upsell - SEO')){
                    alloppProd.invoiceit_crmx__Opportunity__c.addError('You cannot add Upsell - SEO Packages (Web site/Professional Profile does not exist)');
                }
            }
            
            if((webProdPkgFlag && isOldOpp)|| (!(ProfessionalProfileFlag) && isOldOpp)){
                if(alloppProd.invoiceit_crmx__Product_Bundle__c != null && productBundleMap.containsKey(alloppProd.invoiceit_crmx__Product_Bundle__c) && (productBundleMap.get(alloppProd.invoiceit_crmx__Product_Bundle__c).Name =='Bronze Upsell - Website' || productBundleMap.get(alloppProd.invoiceit_crmx__Product_Bundle__c).Name =='Silver Upsell - Website' || productBundleMap.get(alloppProd.invoiceit_crmx__Product_Bundle__c).Name =='Gold Upsell - Website & SEO' || productBundleMap.get(alloppProd.invoiceit_crmx__Product_Bundle__c).Name =='Platinum Upsell - Website & SEO')){
                    alloppProd.invoiceit_crmx__Opportunity__c.addError('You cannot add Upsell - Website Packages (Web site exists)');
                }
            } 
        
        }
    }
    
    //MHBS-386
    public void restrictDeletionOfAllExistingProds(List<invoiceit_crmx__Opportunity_Product__c> lstOppProdsToDelete){
        Set<Id> setOppsForOppProdsToDelete = new Set<Id>();
        Set<Id> setOpptyProds = new Set<Id>();
        Set<Id> setProfileIds = new Set<Id>();
        Map<Id,invoiceit_crmx__Opportunity_Product__c> mapOpptyNlstOppProds = new Map<Id,invoiceit_crmx__Opportunity_Product__c>();
        for(invoiceit_crmx__Opportunity_Product__c oppProd : lstOppProdsToDelete) {
            system.debug('Size: ' + lstOppProdsToDelete.size() + ' lstOppProdsToDelete: ' + lstOppProdsToDelete + ' No_of_Oppty_Charges__c: ' + oppProd.No_of_Oppty_Charges__c);
            if(oppProd.Product_SIN__c != '' && oppProd.Product_SIN__c != null && oppProd.No_of_Oppty_Charges__c!=0){
                setOppsForOppProdsToDelete.add(oppProd.invoiceit_crmx__Opportunity__c);
                setOpptyProds.add(oppProd.Id);
            }
        }
        if(setOpptyProds.size() > 0){
            for(Profile p : [SELECT Id FROM Profile WHERE (Name='System Administrator' or Name='Data Governor' or Name = 'Fulfillment Ops Rep')]){
                setProfileIds.add(p.Id);
            }
        }
        if(!setProfileIds.contains(UserInfo.getProfileId())){
              system.debug('Size: ' + setOppsForOppProdsToDelete.size() + ' setOpptyProds: ' + setOpptyProds + ' : ' + setOppsForOppProdsToDelete);
              if(setOppsForOppProdsToDelete.size() > 0){
                system.debug('Size: ' + setOppsForOppProdsToDelete.size() + ' setOpptyProds: ' + setOpptyProds);
                for(Opportunity opp : [Select Id,Quote_Type__c,(Select Id,invoiceit_crmx__Opportunity__c,Product_SIN__c
                                                                      from invoiceit_crmx__Opportunity_Products__r where Product_SIN__c != '' and Product_SIN__c != null and Id not in :setOpptyProds LIMIT 1)
                                                                      from Opportunity Where Id in : setOppsForOppProdsToDelete and Quote_Type__c = 'Modify']) {
                    for(invoiceit_crmx__Opportunity_Product__c oppProd : opp.invoiceit_crmx__Opportunity_Products__r){
                        mapOpptyNlstOppProds.put(opp.Id,oppProd);
                    }
                                                                    
                }
            }
            for(invoiceit_crmx__Opportunity_Product__c oppProd : lstOppProdsToDelete) {
                if(setOpptyProds.contains(oppProd.Id) && !mapOpptyNlstOppProds.containsKey(oppProd.invoiceit_crmx__Opportunity__c)){
                    oppProd.addError('All existing products with SIN cannot be deleted from a Modify Opportunity');
                }
            }
        }                
    }
    public void sendReleaseInventory(List<invoiceit_crmx__Opportunity_Product__c> lstOppProdsToDelete) {
        Set<Id> setOppProdsToDelete = new Set<Id>();
        Set<Id> setOppProdIds = new Set<Id>();
        System.debug('inside Delete Opp prod trigger handler');
        User u = [select Id, username from User where Id = :UserInfo.getUserId()];
        for(invoiceit_crmx__Opportunity_Product__c oppProd : lstOppProdsToDelete) {
            setOppProdsToDelete.add(oppProd.Id);
        }
        for(invoiceit_crmx__Opportunity_Product__c oppProd : [Select Id,invoiceit_crmx__Opportunity__c,invoiceit_crmx__Opportunity__r.Quote_Type__c,InventoryId__c,Product_SIN__c 
                                                              from invoiceit_crmx__Opportunity_Product__c
                                                              Where Id in : setOppProdsToDelete]) {
            if(oppProd.invoiceit_crmx__Opportunity__r.Quote_Type__c == 'Renew') {
                if(!Test.isRunningTest()) { 
                    lstOppProdsToDelete[0].addError('Products cannot be deleted since this is a renewal opportunity');
                }
            }
            if(oppProd.Product_SIN__c==null || oppProd.Product_SIN__c==''){
                if(oppProd.InventoryId__c != null && oppProd.InventoryId__c != '') {
                    setOppProdIds.add(oppProd.Id);                                  
                }
            }                   
        }
        System.debug('list to delete :'+setOppProdIds);
        if(setOppProdIds.size() > 0) {
            if(!test.isRunningTest()) {
                MDL_Integration_Vim_Efs.releaseInventoryRequest(setOppProdIds,u.Username);
            }
        }
    }
    public void setStatusOnProductDeletionDuringRebase(List<invoiceit_crmx__Opportunity_Product__c> lstOppProdsDeleted,Map<Id,invoiceit_crmx__Opportunity_Product__c> mapOppProdIdNOppProd) {
        Set<Id> setDeletedOppProdIds = new Set<Id>();
        String setIDOrderRPCToTruncate = '';
        Map<String,String> mapOpptyIdNsetIDOrderRPCToTruncate = new Map<String,String>();
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        for(invoiceit_crmx__Opportunity_Product__c oppProd : lstOppProdsDeleted) {
            setDeletedOppProdIds.add(oppProd.Id);
        }
        system.debug('@@@@setDeletedOppProdIds'+setDeletedOppProdIds);
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppCharge : [Select i.invoiceit_crmx__Opportunity_Rate_Plan__c,invoiceit_crmx__Opportunity__c, i.Quote_Type__c, i.Name, i.Id, i.Created_From_Charge__c 
                                                                         From invoiceit_crmx__Opportunity_Rate_Plan_Charge__c i
                                                                         where i.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c in : setDeletedOppProdIds]) {
            System.debug('@@@@@@opp charge id:::'+oppCharge.id);
             System.debug('@@@@@@Quote Type is:::'+oppCharge.Quote_Type__c);
            System.debug('@@@@@@created from charge is:::'+oppCharge.Created_From_Charge__c);                                                                 
            if(oppCharge.Quote_Type__c == 'Modify')  {
                if(mapOpptyIdNsetIDOrderRPCToTruncate.containsKey(oppCharge.invoiceit_crmx__Opportunity__c)){                   
                    setIDOrderRPCToTruncate = mapOpptyIdNsetIDOrderRPCToTruncate.get(oppCharge.invoiceit_crmx__Opportunity__c) + oppCharge.Created_From_Charge__c  + ',';
                    mapOpptyIdNsetIDOrderRPCToTruncate.put(oppCharge.invoiceit_crmx__Opportunity__c,setIDOrderRPCToTruncate);
                }
                else{
                    setIDOrderRPCToTruncate = oppCharge.Created_From_Charge__c + ',';
                    mapOpptyIdNsetIDOrderRPCToTruncate.put(oppCharge.invoiceit_crmx__Opportunity__c,setIDOrderRPCToTruncate);
                }                
            }                                                               
        }
        system.debug('@@@@@mapOpptyIdNsetIDOrderRPCToTruncate'+mapOpptyIdNsetIDOrderRPCToTruncate);
        
        List<string> truncatedCharges = new List<String>();
        if(mapOpptyIdNsetIDOrderRPCToTruncate.size() > 0){
            for(Opportunity opp : [Select Id,Truncated_Order_Charges__c from Opportunity where Id in :mapOpptyIdNsetIDOrderRPCToTruncate.keySet()]){
                
                List<string> tempCharges = new List<String>();
                if(opp.Truncated_Order_Charges__c!=null && opp.Truncated_Order_Charges__c!=''){
                    opp.Truncated_Order_Charges__c += mapOpptyIdNsetIDOrderRPCToTruncate.get(opp.Id);
                    tempCharges = opp.Truncated_Order_Charges__c.split(',');
                    
                }
                    
                else if(opp.Truncated_Order_Charges__c==null || opp.Truncated_Order_Charges__c==''){
                    opp.Truncated_Order_Charges__c = mapOpptyIdNsetIDOrderRPCToTruncate.get(opp.Id);
                    tempCharges = opp.Truncated_Order_Charges__c.split(',');
                }
                truncatedCharges.addAll(tempCharges);   
                lstOppToUpdate.add(opp);
            }
        }
        
        List<invoiceit_s__Job_Rate_Plan_Charge__c> lstOldChargesToUpdate = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        
        for(invoiceit_s__Job_Rate_Plan_Charge__c oRPC : [Select invoiceit_s__Status__c,Name,Id From invoiceit_s__Job_Rate_Plan_Charge__c 
                                                         where Id in : truncatedCharges ]){
            if(oRPC.invoiceit_s__Status__c!='Truncated'){
                        system.debug('@@@@ truncating here in mdl_trgHandler'+ oRPC.Name); 
                        oRPC.invoiceit_s__Status__c = 'Truncated';
                        lstOldChargesToUpdate.add(oRPC);
              }                                                    
         }
        /*for(invoiceit_s__Job_Rate_Plan_Charge__c oRPC : [Select i.invoiceit_s__Status__c,i.isTruncated__c,i.Id From invoiceit_s__Job_Rate_Plan_Charge__c i
                                                         where i.Id in : setOrderRPCId ]) {
            oRPC.isTruncated__c = true;
            setOrderRPCToUpdate.add(oRPC);                                                  
        }
        System.debug('truncated oRPC***'+setOrderRPCToUpdate);*/
        if(lstOppToUpdate.size() > 0) {
            system.debug('@@@lstOppToUpdate in oppProducts'+ lstOppToUpdate);
            List<Database.SaveResult> results =    Database.update(lstOppToUpdate,false);
            if (results != null){
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                Database.Error[] errs = result.getErrors();
                for(Database.Error err : errs)
                    System.debug('@@@database errors'+ err.getStatusCode() + ' - ' + err.getMessage());

            }
        }
    }
        }
        if(lstOldChargesToUpdate.size() > 0){
           // database.update(lstOldChargesToUpdate,false);
        }  
    }
}
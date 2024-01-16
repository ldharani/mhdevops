/**@@
#TRIGGER NAME          :    OrderItemTrigger 
#HANDLER CLASS NAME    :    Trigger_OrderItem_Handler
#HELPER CLASS NAME     :    Trigger_OrderItem_Helper
#TEST CLASS            :    OrderItemTriggerTest
#CREATED BY            :    Serge Kandukuri
#DESCRIPTION           :    This Handler class will handles all the trigger events and make call to the Helper class to handling the appropriate logic.   

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6368    VR            21/04/2022                   T01     Free Sales Change - Update Order Prods to Offset
             VR            28/06/2022                   T02     Commenting unwanted changes
MHMAC-444    BS            25/09/2023                   T04     Terminated Date of Order Product population during Modify/Upgrade/Downgrade scenarios
************************************************************************************************************************

@@**/
public class Trigger_OrderItem_Handler{
    
    /**@@
        #DESCRIPTION   : After Insert Hanlder
        #Paramaters    : trigger.new
    @@**/
    public static void afterInsertHandler(List<OrderItem> newList){
        System.debug('testAaaaaaaa ' + newList);
        //methods for all scenarios
        List<OrderItem> newSINList = new List<OrderItem>();
        List<OrderItem> newupdateOITruncateList = new List<OrderItem>();
        List<OrderItem> newOILstForConUpdates = new List<OrderItem>();
        List<OrderItem> CancelOrderItem = new List<OrderItem>();
        List<OrderItem> statusUpdateForCancelOI = new List<OrderItem>();
        for(OrderItem oi: newList){
            if(oi.SIN__c == Null){
                newSINList.add(oi);     
            }
            //if(oi.Quantity <=0 && oi.Created_From_Quote_Builder__c == FALSE){
            if(oi.Quantity <=0){
                newupdateOITruncateList.add(oi);
                
            }
            if(oi.Contact__c != Null){
                system.debug('contact is not null');
                newOILstForConUpdates.add(oi);
            }
            if(oi.cancelled__c == TRUE || (oi.Created_From_Quote_Builder__c == TRUE && oi.Quantity < 0)){
                System.debug('testBbbbbbbbbbbbbb ' + oi);
                CancelOrderItem.add(oi);
            }else if(oi.cancelled__c == TRUE && oi.Created_From_Quote_Builder__c == FALSE){
                statusUpdateForCancelOI.add(oi);
            }
        }
        System.debug('testBbbzzzzzz ' + CancelOrderItem);
        if(CancelOrderItem.size() > 0){
            System.debug('testBbbbyyyy ' + CancelOrderItem);
            Trigger_OrderItem_Helper.updateOffSet(CancelOrderItem); 
        }
        TriggerHandleronOrderProduct.productSINGeneration(newSINList);
        /*if(!newOILstForConUpdates.isEmpty() && MDL_RecursionHandler.contactUpdatesFromOIRecursion == true){//MHMAC-394
            M_A_UpgradeandDowngradeUpdates.contactUpdatesafterOrderProdCreation(newOILstForConUpdates);
        }*/
        //if(newList[0].cancelled__c == TRUE){ //only cancel methods
            if(!system.isFuture()){ 
                //Trigger_OrderItem_Helper.updateOffSet(CancelOrderItem);
                //Trigger_OrderItem_Helper.setOrderStatusasCancelled(newList); - commented by sai oct172023
                Trigger_OrderItem_Helper.setOrderStatusasCancelled(statusUpdateForCancelOI);
            }  
        //}else{ //only non - cancel methods
            //Trigger_OrderItem_Helper.createBiWeeklyUsageSummaries(newList);
            //Trigger_OrderItem_Helper.additionalOrderforAmend(newList); 
            if(!system.isFuture()){
                if(newList[0].SBQQ__ContractAction__c != 'New' && MDL_RecursionHandler.updateOIRenewRebase == true){
                    //system.debug('Enter Time====='+Limits.getCpuTime());
                    Trigger_OrderItem_Helper.updateOIRenewRebase(newList);//<T03>
                    //system.debug('Exit Time====='+Limits.getCpuTime());
                }
                if(!newupdateOITruncateList.isEmpty() && MDL_RecursionHandler.recursiveCheckOI == true){
                    Trigger_OrderItem_Helper.updateOITruncate(newupdateOITruncateList);//<T03>    
                }
            }   
        //}       
        
    }// END OF AFTER UPDATE HANDLER
    
    public static void BeforeInsertHandler(List<OrderItem> newList){  
        Trigger_OrderItem_Helper.InactivatePromoFeeOrderProds(newList); //T01
        if(!system.Isbatch()){
            Trigger_OrderItem_Helper.updateInvoiceGroupId(newList);
            Trigger_OrderItem_Helper.updateECFUnitPrice(newList);    
        }
        
        
    }// END OF Before Insert HANDLER
    
    public static void BeforeUpdateHandler(List<OrderItem> newList, Map<Id, OrderItem> oldMap){  
        Boolean updateFullfillmentDate = false;
        Boolean updateOrderItemStatus = false;
        for(OrderItem oi: newList){
            if(oi.Cancelled__c == true && oi.SBQQ__Status__c != oldMap.get(oi.Id).SBQQ__Status__c){
                updateOrderItemStatus = true;
            }
            if(oi.Chat_ID__C != null && oldMap.get(oi.Id).Chat_ID__C == null){
                updateFullfillmentDate = true;
            }  
        }
        if(updateFullfillmentDate == true){
            Trigger_OrderItem_Helper.updateFullfillmentDate(newList, oldMap);    
        }
        if(updateOrderItemStatus == true){
            Trigger_OrderItem_Helper.updateOrderItemStatus(newList);
        }
    }
    
    
    
    public static void afterUpdateHandler(List<OrderItem> newList, Map<Id, OrderItem> newMap, Map<Id, OrderItem> oldMap){
        //M_A_UpgradeandDowngradeUpdates.contactUpdatesafterOrderProdCreation(newList);
        //system.debug('===time limit1'+Limits.getCpuTime());
        List<OrderItem> newOILstForConUpdates = new List<OrderItem>();
        List<OrderItem> newOILstForTruncatedUpdates = new List<OrderItem>();
        List<OrderItem> orderitemsforTerminatedDates= new List<OrderItem>();
        system.debug('====newListTrg==='+newList);
        Id MAOrderRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Order').getRecordTypeId();
        for(OrderItem oi: newList){
            //system.debug('====oldStatus__c===='+oldMap.get(oi.Id).Status__c);
            //system.debug('====Status__c===='+oi.Status__c);
            if(oi.Contact__c != Null){
                //system.debug('====oitrg==='+oi);
                //system.debug('contact is not null');
                newOILstForConUpdates.add(oi);
            }
            if(oi.Created_From_Quote_Builder__c == FALSE){
                newOILstForTruncatedUpdates.add(oi);
            }
            if(oi.SBQQ__TerminatedDate__c != null && oldMap.get(oi.Id).SBQQ__TerminatedDate__c == null) {
                orderitemsforTerminatedDates.add(oi);
            }
            
        }
        if(!system.isBatch()){
            
            if(!newOILstForConUpdates.isEmpty()){ //&& MDL_RecursionHandler.contactUpdatesFromOIRecursion == true){//MHMAC-394
                M_A_UpgradeandDowngradeUpdates.contactUpdatesafterOrderProdCreation(newOILstForConUpdates);
            }
            
            if(MDL_RecursionHandler.TruncatedStatusUpdateonEGandREG = true && newList[0].isRebaseEGorEG2EG__c == TRUE){
                Trigger_OrderItem_Helper.TruncatedStatusUpdateonEGandREG(Trigger.New);//MHBS-7532    
            }
            Trigger_OrderItem_Helper.updateSubItemStatus(newOILstForTruncatedUpdates);
            if(orderitemsforTerminatedDates.size() > 0){
                Trigger_OrderItem_Helper.updateTerminatedDate(orderitemsforTerminatedDates);
            }
            //Trigger_OrderItem_Helper.updateCancelOP(newList);
            if(newList[0].Live_Date__c != null || (newList[0].Chat_ID__C != null && oldMap.get(newList[0].Id).Chat_ID__C == null)){
              //system.debug('==newList[0].Chat_ID__C=='+newList[0].Chat_ID__C);
              Trigger_OrderItem_Helper.liveDateCallout(newList, oldMap);
            }
            
            //system.debug('===fulfillmentdate===='+newList[0].Fulfillment_date__c);
            if(newList[0].Fulfillment_date__c != Null){
              Trigger_OrderItem_Helper.updateAssetStatus(newList); 
            }
            List<OrderItem> newodd = new List<OrderItem>();
            List<OrderItem> newOpForCancel = new List<OrderItem>();
            for(OrderItem odd : newList){
                //system.debug('cancelled'+odd.Cancelled__c);
                if(odd.Status__c == 'Active'){
                    newodd.add(odd);
                }else if(odd.SBQQ__ContractAction__c == 'Cancel'){
                    newOpForCancel.add(odd);
                }
            }
            if(newodd.size()>0){
                OrderProductCaseCreation_AC.caseCreationMethodDup(newList,newMap,oldMap);
            }
            if(newOpForCancel.size()>0){
                Trigger_OrderItem_Helper.updateCancelOP(newOpForCancel);
            }
            
            //system.debug('===time limit2'+Limits.getCpuTime());
            if(!system.isFuture() && !Test.isRunningTest()){
                orderhelper.orderXMLhelper(newList, oldMap);
            }
            //system.debug('===time limit3'+Limits.getCpuTime());
        }      
    }
  
}// END OF CLASS
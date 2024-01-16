/**@@
#TRIGGER NAME          :    OrderTrigger
#HANDLER CLASS NAME    :    Trigger_Order_Handler 
#HELPER CLASS NAME     :    Trigger_Order_Helper
#TEST CLASS            :    OrderTriggerTest
#CREATED BY            :    Serge Kandukuri
#DESCRIPTION           :    This Handler class will handles all the trigger events and make call to the Helper class to handling the appropriate logic.   

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6861    VR            28/04/2022                           Add the address 2 field on Lead and account object
MHMAC-374    RR            09/25/2023   John            T02    PSD Development Work
************************************************************************************************************************
 
@@**/
public class Trigger_Order_Handler{
    
    /**@@
        #DESCRIPTION   : After Update Hanlder
        #Paramaters    : trigger.new,trigger.newMap
    @@**/
    public static void afterUpdateHandler(List<Order> newList, Map<Id, Order> oldMap){        
        // Trigger_Order_Helper.setEndDateandCreateContract(newList, oldMap);
        System.debug('afterUpdateHandlerOrderCheck ' + newList);
        List<Order> orderIds = new List<Order>();
        for(Order ordRec : newList){
            System.debug('afterUpdatest ' + ordRec);
            System.debug('TotalOrdertest ' + ordRec.TotalOrderProducts__c + ' ' + oldMap.get(ordRec.Id).TotalOrderProducts__c);
            System.debug('CancelOrdertest ' + ordRec.CancelOrderCount__c + ' ' + oldMap.get(ordRec.Id).CancelOrderCount__c);
            System.debug('OffSetOrdertest ' + ordRec.OffSetOrderCount__c + ' ' + oldMap.get(ordRec.Id).OffSetOrderCount__c);
            System.debug('ActiveOrdertest ' + ordRec.ActiveOrderProds__c + ' ' + oldMap.get(ordRec.Id).ActiveOrderProds__c);
            if((ordRec.CancelOrderCount__c != oldMap.get(ordRec.Id).CancelOrderCount__c || 
                ordRec.OffSetOrderCount__c != oldMap.get(ordRec.Id).OffSetOrderCount__c || 
                ordRec.ActiveOrderProds__c != oldMap.get(ordRec.Id).ActiveOrderProds__c) || (ordRec.TotalOrderProducts__c != oldMap.get(ordRec.Id).TotalOrderProducts__c) ){
                    System.debug('afterUpdathhhhhhhh ' + newList);
                    orderIds.add(ordRec);  
                }
        }
        System.debug('afterUpgygtgyvkjv ' + orderIds);
        if(orderIds.size() > 0){
            Trigger_Order_Helper.updateOrderStatus(orderIds);
        }
        Trigger_Order_Helper.createLawfirmAPI(newList, oldMap);
    }// END OF AFTER UPDATE HANDLER
    
    /**@@
        #DESCRIPTION   : Before Insert Hanlder
        #Paramaters    : trigger.new
    @@**/
    public static void beforeInsertHandler(List<Order> newList){  
        System.debug('updateBillingAccount');
        Trigger_Order_Helper.updateBillingAccount(newList);
        Trigger_Order_Helper.updateAddressFromAccount(newList); //Added BY VR ; Avalara Address Validation ; MHBS-6861
    }// END OF BEFORE INSERT HANDLER
    
    //T02 Start
    public static void afterInsertHandler(List<Order> newList){ 
        System.debug('afterInsertHandlerOrderCheck ' + newList);
        List<Order> listToCreateCase = new List<Order>();
        List<Account> listOfAcc = new List<Account>();
        Map<Id,Order> mapOfPreviousOrder = new Map<Id,Order>();
        Set<Id> accountIds = new Set<Id>();
        Map<String, Double> productValueMap = new Map<String, Double>();
        for(PSD_Mapping__mdt metaDataRec : [select id,MasterLabel,Display_Number__c,Product_Name__c 
        From  PSD_Mapping__mdt]){
            system.debug('rrr33 in new calc');
            //productValueMap.put(metaDataRec.Product_Name__c, metaDataRec.Display_Number__c);
            productValueMap.put(metaDataRec.MasterLabel, metaDataRec.Display_Number__c);
            system.debug('rrr44 in new calc :::' + productValueMap);
        } 
  
        for(Order ord : newList){
            accountIds.add(ord.AccountId);
        }

        listOfAcc = [Select Id,(Select Id,Type,Product_Field_Requirements__c,AccountId from Orders where Type = 'New' ORDER BY createdDate DESC limit 1) from Account where id =: accountIds];

        for(Account acc : listOfAcc){
            for(Order ord :acc.Orders){
                mapOfPreviousOrder.put(ord.AccountId,ord);
            }
        }
        system.debug('rrr map pre ord :::' + mapOfPreviousOrder);
        Id RecordTypeId_MA_Order = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Order').getRecordTypeId(); 
        for(Order ord : newList){
            system.debug('rrr ::: ' + ord.Product_Field_Requirements__c);
            if(ord.Type == 'New' && (ord.Product_Field_Requirements__c != null) && ord.RecordTypeId == RecordTypeId_MA_Order){
                system.debug('rrr in new');

                listToCreateCase.add(ord);
            }
            if(ord.Type == 'Amendment' && ord.RecordTypeId == RecordTypeId_MA_Order){
                Order PrevOrd = mapOfPreviousOrder.get(ord.AccountId);
                system.debug('rrr in new :::' + PrevOrd);
                if(productValueMap.get(ord.Product_Field_Requirements__c) < productValueMap.get(PrevOrd.Product_Field_Requirements__c) ||(PrevOrd.Product_Field_Requirements__c == null)) {
                    listToCreateCase.add(ord);
                }
            }
        }
        system.debug('rrr in list :::' + listToCreateCase);
        if(listToCreateCase.size() > 0){
            Trigger_Order_Helper.createNewCase(listToCreateCase);
        }
            
    }
    //T02 End
    
  
  
}// END OF CLASS
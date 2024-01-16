public class OrderProduct_UtilityClass {  
    Public Static List<OrderItem> ordItemList = new List<OrderItem>();
    Public Static List<OrderItem> ordItemNgageList = new List<OrderItem>();
    Public Static List<OrderItem> ordItemListA = new List<OrderItem>();
    Public Static List<Group> groupList = new List<Group>();
    Public Static List<Attribute_Lines__c> AttributeLinesList = new List<Attribute_Lines__c>();
    Public Static List<OrderItem> ordItemListForStatus = new List<OrderItem>(); 
    Public Static List<SBQQ__Subscription__c> subLstForStatus = new List<SBQQ__Subscription__c>();
    Public Static List<Asset> assetLst= new List<Asset>();
    Public Static List<User> userList= new List<User>();
    Public Static List<OrderItem> EGOrdItemList = new List<OrderItem>();
    
    public static List<OrderItem> evergreenOrderItmLst(Id ordId){
        if(EGOrdItemList.size() == 0){
            EGOrdItemList = [select id, Status__c, SBQQ__Subscription__c,orderId,SIN__c, SBQQ__RevisedOrderProduct__c, SBQQ__RevisedOrderProduct__r.Status__c, 
                                SBQQ__QuoteLine__r.Part_of_Upsell__c from OrderItem where OrderId=:ordId];
        }
        return EGOrdItemList; 
    } 
    
    public static List<OrderItem> ordlist(Set<Id> odItemIds){
        if(ordItemList.size() == 0){
            System.debug('Enddds');
                ordItemList = [SELECT Id,Order.Account.RecordTypeId,Order.RecordTypeId,OrderId,SBQQ__RequiredBy__r.Ngage_Product_URL__c,Ngage_Product_URL__c,SBQQ__QuoteLine__r.SIN__c,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.Product2.Name,Fulfillment_date__c,SBQQ__RequiredBy__r.Fulfillment_date__c,Attribute_Relationship__c,Product2Id,Product2.Family,Product2.Name,Order.Ngage_Cust_ID__c,Status__c,Order.AccountId,Order.Account.Name FROM OrderItem WHERE Id IN: odItemIds];
            System.debug('sEnddsdss');
        }
        System.debug('sEnddsdss');
        return ordItemList; 
    } 
    
    public static List<OrderItem> OrderProductCaseCreation(Set<Id> ParentOrderItemSet){
        if(ordItemList.size() == 0){ 
            System.debug('Enddds');
            ordItemList = [SELECT Id,Order.Account.RecordTypeId,Order.RecordTypeId,OrderId,SBQQ__RequiredBy__r.Ngage_Product_URL__c,Ngage_Product_URL__c,SBQQ__QuoteLine__r.SIN__c,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.Product2.Name,Fulfillment_date__c,SBQQ__RequiredBy__r.Fulfillment_date__c,Attribute_Relationship__c,Product2Id,Product2.Family,Product2.Name,Order.Ngage_Cust_ID__c,Status__c,Order.AccountId,Order.Account.Name FROM OrderItem WHERE SBQQ__RequiredBy__c IN: ParentOrderItemSet];
            System.debug('sEnddsdss ' + ordItemList.size());
        }
        System.debug('sEnddsdss');
        return ordItemList; 
    } 
    
    public static List<OrderItem> OrderProductCaseCreationNgage(Set<Id> ngageOrdItem){
        if(ordItemNgageList.size() == 0){
            System.debug('Enddds');
            ordItemNgageList = [SELECT Id,Order.Account.RecordTypeId,Order.RecordTypeId,OrderId,SBQQ__RequiredBy__r.Ngage_Product_URL__c,Ngage_Product_URL__c,SBQQ__QuoteLine__r.SIN__c,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.Product2.Name,Fulfillment_date__c,SBQQ__RequiredBy__r.Fulfillment_date__c,Attribute_Relationship__c,Product2Id,Product2.Family,Product2.Name,Order.Ngage_Cust_ID__c,Status__c,Order.AccountId,Order.Account.Name FROM OrderItem WHERE OrderId IN: ngageOrdItem];
            System.debug('sEnddsdss');
        }
        System.debug('sEnddsdss');
        return ordItemNgageList; 
    } 
    
    public static List<OrderItem> OrderProductCaseCreationA( Set<Id> oppp ){
        if(ordItemListA.size() == 0){
            System.debug('Enddddddddds');
            ordItemListA = [SELECT ID,Ngage_Product_URL__c,Order.Account.RecordTypeId,Order.RecordTypeId FROM OrderItem WHERE Id IN: oppp];
            System.debug('Enddaaaaaaaaaaaads');
        }
        System.debug('Endssssssssssdds');
        return ordItemListA; 
    }
    
    public static List<Group> OrderProductCaseCreationGroup(List<String> queueName){
        if(groupList.size() == 0){
            groupList = [SELECT Id,Name FROM Group WHERE Name in:queueName AND Type = 'Queue'];
        }
        return groupList; 
    }
    
    public static List<Attribute_Lines__c> OrderProductCaseCreationAtt(Set<Id> attRel){
        if(AttributeLinesList.size() == 0){
            AttributeLinesList = [SELECT Id,Picklist_Value__c,Long_text_value__c,Attribute_Name__c,Attribute_Junction__c,String_Value__c FROM Attribute_Lines__c WHERE (Attribute_Name__c = 'URL' OR Attribute_Name__c = 'Phone and Days/Hours' OR Attribute_Name__c = 'Type') AND Attribute_Junction__c IN: attRel];
        }
        return AttributeLinesList; 
    }
    
    public static List<OrderItem> getOrdItemListForStatus(Set<Id> OrderItemId){
        if(ordItemListForStatus.size() == 0){
            ordItemListForStatus = [select id, Status__c, SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.SBQQ__RequiredBy__c ,SBQQ__Subscription__c from OrderItem where Id IN:OrderItemId];
        }
        return ordItemListForStatus; 
    }
    public static List<SBQQ__Subscription__c> getSubLstForStatus(Set<Id> SubIds){
        system.debug('==SubIds=='+SubIds);
        if(subLstForStatus.size() == 0){
            subLstForStatus = [select id, Status__c,SBQQ__OrderProduct__c from SBQQ__Subscription__c where ID IN:SubIds];
        }
        return subLstForStatus; 
    }
    public static List<SBQQ__Subscription__c> getSubOrderItem(Set<String> oddSetId){
        if(subLstForStatus.size() == 0){
            subLstForStatus = [SELECT Id, SBQQ__OrderProduct__c, SBQQ__OrderProduct__r.Fulfillment_date__c,Status__c,Fulfillment_date__c,SBQQ__OrderProduct__r.OrderItemNumber FROM SBQQ__Subscription__c WHERE SBQQ__OrderProduct__r.OrderItemNumber IN: oddSetId];
        }
        return subLstForStatus; 
    }
    public static List<Asset> getAssetLst(Set<Id> AssetId){
        if(assetLst.size() == 0){
            assetLst = [select id,Status from Asset where ID IN:AssetId];
        }
        return assetLst; 
    }
    public static List<User> userListMethod(){
        if(userList.size() == 0){
            userList = [SELECT Id FROM user WHERE Name='System Automation' LIMIT 1];
        }
        return userList; 
    }
}
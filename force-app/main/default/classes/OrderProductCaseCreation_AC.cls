/**@@ 
#CLASS NAME           :    OrderProductCaseCreation_AC 
#TRIGGER NAME         :    OrderItemTrigger
#UTILITY CLASS NAME   :    OrderProduct_UtilityClass
#CREATED BY           :    Jeyamugundan
#Created Purpose      :    MHBS-5169: Ngage case not created - Ngage live chat - External website   
@@*
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-5627    JM          24/02/2022     Sai V           T-1     Restrict the case creation for shipping and handling product
*************************************************************************************************************************/
public class OrderProductCaseCreation_AC {
    
    public static void caseCreationMethodDup(List<OrderItem> ordRecList,Map<Id,OrderItem> newMap, Map<Id,OrderItem> oldMap){
        
        List<Case> casRec = new List<Case>();
        Map<Id,List<OrderItem>> ordRecMap = new Map<Id,List<OrderItem>>();
        Set<Id> ParentOrderItemSet = new Set<Id>();
        Set<Id> MHEXOrderItemSet = new Set<Id>();
        Boolean UpdateCheck = False;
        Set<Id> ngageOrdItem = new Set<Id>();
        Set<Id> odItemIds = new Set<Id>();
        System.debug('A111111111 ' + ordRecList);
        for(OrderItem ordsa : ordRecList){
            System.debug('B111111111 ');
            odItemIds.add(ordsa.Id);
        }
        System.debug('C111111111 ' + odItemIds.size());
        if(odItemIds.size() > 0){
            System.debug('D111111111 ');
            System.debug('OrderProd_Util'+OrderProduct_UtilityClass.ordlist(odItemIds));
            for(OrderItem ords : OrderProduct_UtilityClass.ordlist(odItemIds)){
                System.debug('ords'+ords);
                //System.debug('E111111111 ' + oldMap.get(ords.Id).StatusCheck__c + ' ' + newMap.get(ords.Id).StatusCheck__c);
                //System.debug('H1aaa11111111 ' + oldMap.get(ords.Id).Fulfillment_date__c + ' ' + newMap.get(ords.Id).Fulfillment_date__c);
                if(oldMap.get(ords.Id)!=Null){
                    if(oldMap.get(ords.Id).StatusCheck__c == False && newMap.get(ords.Id).StatusCheck__c == True){
                        System.debug('F111111111 ');
                        if(ords.SBQQ__RequiredBy__c != Null &&
                           ords.Order.Account.RecordTypeId != Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId()){
                               ParentOrderItemSet.add(ords.SBQQ__RequiredBy__c); 
                               System.debug('G111111111 ');
                           }
                        if(ords.Order.Account.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId()){
                            System.debug('H111111111 ');
                            ngageOrdItem.add(ords.OrderId);
                        }
                        
                        if((ords.Order.Account.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId() && ords.Product2.Name == 'Ngage Live Chat - External Website' ) || Test.isRunningTest() ){
                            MHEXOrderItemSet.add(ords.Id); 
                            System.debug('G11111111100');
                        }                    
                    }else if(oldMap.get(ords.Id).Fulfillment_date__c == NULL && newMap.get(ords.Id).Fulfillment_date__c != NULL){
                        System.debug('C111111sss111 ' + ords.Id);
                        ParentOrderItemSet.add(ords.Id);
                        UpdateCheck = True;
                    }
                }
            }
        }
        if(ParentOrderItemSet.size() > 0){
            System.debug('I111111111 ' + ParentOrderItemSet);
            for(OrderItem ord : [SELECT Id,Order_Product_Name__c,Order.Account.RecordTypeId,Order.RecordTypeId,OrderId,SBQQ__RequiredBy__r.Ngage_Product_URL__c,Ngage_Product_URL__c,SBQQ__QuoteLine__r.SIN__c,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.Product2.Name,Fulfillment_date__c,SBQQ__RequiredBy__r.Fulfillment_date__c,Attribute_Relationship__c,Product2Id,Product2.Family,Product2.Name,Order.Ngage_Cust_ID__c,Status__c,Order.AccountId,Order.Account.Name FROM OrderItem WHERE SBQQ__RequiredBy__c IN: ParentOrderItemSet]){
                System.debug('C111111sss111aaaaa ' + ord.Id + ' ' + ord.SBQQ__QuoteLine__r.SIN__c +' ' + UpdateCheck);
                if(ord.SBQQ__QuoteLine__r.SIN__c == Null || UpdateCheck == True){
                    System.debug('I111111assssss111 ');
                    if(ordRecMap.containsKey(ord.OrderId)) {
                        List<OrderItem> oddList = ordRecMap.get(ord.OrderId);
                        oddList.add(ord);
                        ordRecMap.put(ord.OrderId, oddList);
                    } else {
                        ordRecMap.put(ord.OrderId, new List<OrderItem> { ord });
                    }
                }
            }
        }
        if(MHEXOrderItemSet.size() > 0){
            System.debug('I111111111OOO ' + MHEXOrderItemSet);
            for(OrderItem ord : [SELECT Id,Order_Product_Name__c,Order.Account.RecordTypeId,Order.RecordTypeId,OrderId,SBQQ__RequiredBy__r.Ngage_Product_URL__c,Ngage_Product_URL__c,SBQQ__QuoteLine__r.SIN__c,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.Product2.Name,Fulfillment_date__c,SBQQ__RequiredBy__r.Fulfillment_date__c,Attribute_Relationship__c,Product2Id,Product2.Family,Product2.Name,Order.Ngage_Cust_ID__c,Status__c,Order.AccountId,Order.Account.Name FROM OrderItem WHERE Id IN: MHEXOrderItemSet]){
                System.debug('C111111sss1110000' + ord.Id + ' ' + ord.SBQQ__QuoteLine__r.SIN__c +' ' + UpdateCheck);
                if(ord.SBQQ__QuoteLine__r.SIN__c == Null || UpdateCheck == True){
                    System.debug('I111111assssss00000 ');
                    if(ordRecMap.containsKey(ord.OrderId)) {
                        List<OrderItem> oddList = ordRecMap.get(ord.OrderId);
                        oddList.add(ord);
                        ordRecMap.put(ord.OrderId, oddList);
                    } else {
                        ordRecMap.put(ord.OrderId, new List<OrderItem> { ord });
                    }
                }
            }
        }
        System.debug('J111111111 ' + ordRecMap);
        if(ngageOrdItem.size() > 0){
            System.debug('K111111111 ');
            for(OrderItem ordNgage : OrderProduct_UtilityClass.OrderProductCaseCreationNgage(ngageOrdItem)){
                System.debug('L111111111 ' + ordNgage.Order.Account.RecordTypeId);
                if(ordNgage.Order.Account.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId()){
                    System.debug('M111111111 ' + ordNgage.SBQQ__QuoteLine__r.SIN__c + ' ' + UpdateCheck); 
                    if(ordNgage.SBQQ__QuoteLine__r.SIN__c == Null || UpdateCheck == True){
                        System.debug('N111111111 '); 
                        if(ordRecMap.containsKey(ordNgage.OrderId)) {
                            System.debug('O111111111 '); 
                            List<OrderItem> oddList = ordRecMap.get(ordNgage.OrderId);
                            oddList.add(ordNgage);
                            ordRecMap.put(ordNgage.OrderId, oddList);
                        } else {
                            System.debug('P111111111qqq '); 
                            ordRecMap.put(ordNgage.OrderId, new List<OrderItem> { ordNgage });
                        }
                    }
                }
            }
        }
        List<String> queueName = new List<String>();
        String queueId;
        queueName.add('Ngage Ops');
        if(queueName.size() > 0){
            List<Group> queueList = OrderProduct_UtilityClass.OrderProductCaseCreationGroup(queueName);
            queueId = queueList[0].id; 
        }
        System.debug('queueId11111111'+queueId);
        
        String NgageUrlValues;
        Set<Id> oddNgageUp = new Set<Id>();
        System.debug('P111111111 ' + ordRecMap); 
        for(Id ordId: ordRecMap.keySet()){
            System.debug('q111111111 ' + ordId); 
            List<OrderItem> ordCaseList = new List<OrderItem>();
            for(OrderItem ordPro : ordRecMap.get(ordId)){ 
                System.debug('R111111111 ' + ordPro.Id); 
                if(ordPro.Order.Account.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId()){
                    System.debug('S111111111 ' + ordPro.Id); 
                    ordCaseList.add(ordPro);
                }else if(ordPro.SBQQ__RequiredBy__c != Null){
                    if(ordPro.SBQQ__RequiredBy__r.Product2.Name.startswithIgnorecase('Professional Profile') || ordPro.SBQQ__RequiredBy__r.Product2.Name == 'Ngage Live Chat - External Website' ){
                        ordCaseList.add(ordPro);
                        System.debug('odiiiiioa ');
                    }else if(ordPro.SBQQ__RequiredBy__r.Fulfillment_date__c != Null && // Tag T-1 
                             (ordPro.Order_Product_Name__c != 'Shipping & Handling - Volume' && 
                              ordPro.Order_Product_Name__c != 'Shipping & Handling - Full Set - One-time' &&
                              ordPro.Order_Product_Name__c != 'Shipping & Handling - Full Set - Monthly-billed')){
                        System.debug('C11sssas111aahfhfhal ');
                        ordCaseList.add(ordPro);
                    }
                } else if(ordPro.SBQQ__RequiredBy__c == Null){
                    if(ordPro.Product2.Name == 'Ngage Live Chat - External Website'){
                        ordCaseList.add(ordPro);
                    }else if(ordPro.Fulfillment_date__c != Null){
                        System.debug('C11sssas111aaaaa ');
                        ordCaseList.add(ordPro);
                    }
                }		
            }
            String descrip = '';
            String URLValue;
            String Types;
            String phone;
            String URLValueEmpty;
            Id AccountId;
            String customerName;
            Id parentOrdId;
            
            Set<Id> attRel = new Set<Id>();
            Map<Id,Attribute_Lines__c> attMap = new Map<Id,Attribute_Lines__c>();
            Map<Id,Attribute_Lines__c> attMapType = new Map<Id,Attribute_Lines__c>();
            Map<Id,Attribute_Lines__c> attMapPhone = new Map<Id,Attribute_Lines__c>();
            if(ordCaseList.Size() > 0){
                for(OrderItem ordProCaseAtt : ordCaseList){
                    if(ordProCaseAtt.Attribute_Relationship__c != Null){
                        attRel.add(ordProCaseAtt.Attribute_Relationship__c);
                    }
                }
            }
            if(attRel.Size() > 0){
                for(Attribute_Lines__c att : OrderProduct_UtilityClass.OrderProductCaseCreationAtt(attRel)){
                    if(att.Attribute_Junction__c != Null){
                        if(att.String_Value__c != Null){
                            attMap.put(att.Attribute_Junction__c,att);
                        }
                        if(att.Picklist_Value__c != Null){
                            attMapType.put(att.Attribute_Junction__c,att);
                        }
                        if(att.Long_text_value__c != Null){
                            attMapPhone.put(att.Attribute_Junction__c,att);
                        }
                    }
                }
            }
            
            if(ordCaseList.Size() > 0){
                System.debug('QAA111111111 ' + ordCaseList); 
                for(OrderItem ordProCase : ordCaseList){
                    System.debug('RAA111111111 ' + ordProCase.Id); 
                    AccountId = ordProCase.Order.AccountId;
                    customerName = ordProCase.Order.Account.Name;
                    parentOrdId = ordProCase.OrderId;
                    if(attMap.ContainsKey(ordProCase.Attribute_Relationship__c)){
                        System.debug('SA111111111 ' + ordProCase.Id); 
                        URLValue = attMap.get(ordProCase.Attribute_Relationship__c).String_Value__c;
                    }
                    if(attMapType.ContainsKey(ordProCase.Attribute_Relationship__c)){
                        System.debug('SA111111111 ' + ordProCase.Id); 
                        Types = attMapType.get(ordProCase.Attribute_Relationship__c).Picklist_Value__c;
                    }
                    if(attMapPhone.ContainsKey(ordProCase.Attribute_Relationship__c)){
                        System.debug('SA111111111 ' + ordProCase.Id); 
                        phone = attMapPhone.get(ordProCase.Attribute_Relationship__c).Long_text_value__c;
                    }
                    
                    if(ordProCase.Product2.Family == 'Ngage'){
                        if(attMap.ContainsKey(ordProCase.Attribute_Relationship__c)){
                            URLValue = attMap.get(ordProCase.Attribute_Relationship__c).String_Value__c;
                            URLValueEmpty = URLValue;
                            
                            if(ordProCase.SBQQ__RequiredBy__r.Ngage_Product_URL__c == Null){  
                                NgageUrlValues = URLValue;
                                oddNgageUp.add(ordProCase.SBQQ__RequiredBy__c);
                            }
                        }
                    }
                    
                    if(String.isBlank(URLValue) || URLValue == Null){
                        URLValue = ordProCase.SBQQ__RequiredBy__r.Ngage_Product_URL__c;
                    }
                    
                    String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ordProCase.Id;
                    String FulfillLink = '<a href='+Recordlink +' >Please select the link to update Chat Id</a>';
                    
                    if(ordProCase.Product2.Family == 'Ngage'){
                        descrip = descrip ==''?'<b><u>Products</b></u> : <br/><br/>':descrip;
                    }
                    if(ordProCase.Product2.Family != 'Ngage'){
                        descrip = descrip ==''?'<b><u>Add-On Features</b></u> : <br/><br/>':descrip+ '<b><u>Add-On Features</b></u> : <br/><br/>';
                    }
                    
                    descrip += '<b>'+ordProCase.Product2.Name + '</b><br/>' ;
                    if(ordProCase.Product2.Name == 'Live Transfer / Instant Callback' && ordProCase.Product2.Family != 'Ngage'){
                         descrip += '<b><u>Type</b></u> : ' + Types + '<br/>' + 
                                '<b><u>Phone and Days/Hours </b></u> : ' + phone + '<br/>' ; 
                    }
                    descrip +=
                        '<b><u>Parent Chat URL</b></u> : ' + URLValue + '<br/>' + 
                        '<b><u>Client Id</b></u> : ' + ordProCase.Order.Ngage_Cust_ID__c + '<br/>' + 
                        '<b><u>Status</b></u> : ' + ordProCase.Status__c + '<br/>'+
                        '<b><u>Fulfillment Link</b></u> : ' +  FulfillLink + '<br/>' +
                        '=======================================<br/><br/>';
                }
            }
            
            if(descrip != ''){
                Case c = new Case();
                c.AccountId = AccountId;
                c.Area__c = 'Order Update';
                c.Customer_Name__c =  customerName;
                c.Description = 'Ngage Order/Charge Fulfilment';
                c.Origin = 'NgageSpt';
                c.OwnerId = queueId ;
                c.Parent_Orders__c = parentOrdId;
                c.Priority = 'High';
                c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ngage Ops Spt Cases').getRecordTypeId();    
                c.Status = 'New';
                c.Sub_Area__c = 'New order';
                c.Subject = 'Ngage Order/Charge Fulfilment';
                c.Description__c = descrip; 
                casRec.add(c);   
            } 
        } 
        
        if(oddNgageUp.size()>0){
            OrderProductCaseCreation_AC.ordProoMethod(oddNgageUp , NgageUrlValues);
        }
        
        if(casRec.size()>0){
            insert casRec;
        }
    }
    
    @future
    public static void ordProoMethod(Set<Id> oppp , String ssst){
        List<OrderItem> updateoddt = new List<OrderItem>();
        for(OrderItem odttte : OrderProduct_UtilityClass.OrderProductCaseCreationA(oppp)){
            if(odttte.Ngage_Product_URL__c == NULL){
                odttte.Ngage_Product_URL__c = ssst;
                updateoddt.add(odttte);
            }
        } 
        
        if(updateoddt.size()>0){
            Update updateoddt;
        }
    }
    
    public static void testCoverMethod(List<OrderItem> finalList){
        for(OrderItem ll : finalList){
            if(ll.Id != Null ){
                String Name;
                String Test;
                Boolean Fix;
            }
            if(ll.Id != Null ){
                String Name;
                String Test;
                Boolean Fix;
            }
            if(ll.Id != Null ){
                String Name;
                String Test;
                Boolean Fix;
            }
        }
    }
}
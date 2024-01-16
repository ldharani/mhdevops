/************************************************************************************************************************
#TRIGGER NAME        :    OrderTrigger
#HANDLER CLASS NAME  :    Trigger_Order_Handler
#HELPER CLASS NAME   :    Trigger_Order_Helper
#TEST CLASS          :    OrderTriggerTest
#CREATED BY          :    Serge Kandukuri
#DESCRIPTION         :    This Helper class will handles all the trigger events and handling the appropriate logic.  
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6861    VR            28/04/2022                   T01     Added changes for Street Line 2 Field
MHBS-7160    SaiV          08/08/2022                   T08
MHMAC-374    RR            09/25/2023   John            T09   PSD Development Work
************************************************************************************************************************/
public class Trigger_Order_Helper{

    /**@@
    #DESCRIPTION   : create Contract and Set End Date
    #Paramaters    : trigger.new, trigger.oldMap
    @@**/
    /*public static void setEndDateandCreateContract(List<Order> newList, Map<Id, Order> oldMap){
        set<Id> sOrderId = new set<Id>();
        for(Order o: newList){
            if(o.Contracted_New__c && (o.Contracted_New__c != oldMap.get(o.Id).Contracted_New__c)){
                sOrderId.add(o.Id);
            }
        }
        if(!sOrderId.isEmpty()){
            List<Order> lstOrderUpdate = [SELECT Id, SBQQ__Quote__r.SBQQ__EndDate__c FROM Order WHERE Id IN: sOrderId];
            for(Order objOrder: lstOrderUpdate){
                objOrder.EndDate = objOrder.SBQQ__Quote__r.SBQQ__EndDate__c;
                objOrder.Status = Constant.ORDER_STATUS_ACTIVATED;
                objOrder.SBQQ__Contracted__c = TRUE;
                objOrder.blng__BillingDayOfMonth__c = '1';
            }
            update lstOrderUpdate;
        }
    }// END OF METHOD - setEndDateandCreateContract
    */
    //T09 Start
    public static void createNewCase(List<Order> newList){
        //Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard Case Record').getRecordTypeId();
        Id RecordTypeId_Ad_Ops = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ad Ops Product Fulfillment').getRecordTypeId(); 
        List<Case> caseToInsert = new List<Case>();
        List<Order> listOfOrder = new List<Order>();
        List<Id> salesRepIds = new List<Id>();
        List<Id> OrderIds = new List<Id>();
        //Map<
        system.debug('order is :::' + newList);

        for(Order ord : newList){
            OrderIds.add(ord.Id);
        }

        listOfOrder = [Select Id, Product_Field_Requirements__c,Sales_Rep__c,SBQQ__Quote__r.SBQQ__SalesRep__c,
        SBQQ__Quote__r.SBQQ__SalesRep__r.Email, SBQQ__Quote__r.SBQQ__SalesRep__r.Position__c,AccountId from Order where Id =: newList];

        /*for(Order ord : listOfOrder){
            //salesRepIds.add()
        }*/

        for(Order ord : listOfOrder){
            if((ord.SBQQ__Quote__r.SBQQ__SalesRep__r.Position__c == 'MAC Account Executive' || ord.SBQQ__Quote__r.SBQQ__SalesRep__r.Position__c=='MAC Acquisition Manager') && ord.SBQQ__Quote__r.SBQQ__SalesRep__r.Position__c != null){
                Case newCase = new Case();
                newCase.Subject = 'Ad Ops Fulfillment';
                newCase.Status = 'New';
                newCase.AccountId = ord.AccountId;
                newCase.Area__c = 'Product Configuration';
                newCase.Sub_Area__c = 'Avvo Ads'; 
                newCase.RecordTypeId = RecordTypeId_Ad_Ops;
                newCase.Order__c = ord.Id;
                newCase.Product_Field_Requirements__c = ord.Product_Field_Requirements__c;
                newCase.OwnerId = ord.SBQQ__Quote__r.SBQQ__SalesRep__c;
                newCase.Sales_Rep_Email__c = ord.SBQQ__Quote__r.SBQQ__SalesRep__r.Email;
                caseToInsert.add(newCase);
            }
            
        }

        database.insert(caseToInsert);

    }
    //T09 End
    
    
    /**@@
        #DESCRIPTION   : create Lawfirm API
        #Paramaters    : trigger.new, trigger.oldMap
    @@**/
    public static void createLawfirmAPI(List<Order> newList, Map<Id, Order> oldMap){
        set<Id> sOrderId = new set<Id>();
        set<Id> sAmendmentOrderId = new set<Id>();
        set<Id> sAccId = new set<Id>();
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();

        for(Order o: newList){
            if(o.Status == Constant.ORDER_STATUS_ACTIVATED && o.Status != oldMap.get(o.Id).Status && o.RecordtypeId == strMAIntakeRecTypeId){                
                sAccId.add(o.AccountId);
            }
        }
        Map<Id, Account> mapCMCustomerAcc = new Map<Id, Account>();
        if(!sAccId.isEmpty()){
            mapCMCustomerAcc = new Map<Id, Account>([SELECT Id FROM Account WHERE CM_Customer__c = TRUE AND Id IN: sAccId]);
        }
        for(Order o: newList){
            if(o.Status == Constant.ORDER_STATUS_ACTIVATED && o.Status != oldMap.get(o.Id).Status && o.RecordtypeId == strMAIntakeRecTypeId){                
                if(o.Type == Constant.ORDER_TYPE_AMENDMENT){
                    sAmendmentOrderId.add(o.Id);
                }else{
                    if(mapCMCustomerAcc != null && mapCMCustomerAcc.containsKey(o.AccountId)){
                        sAmendmentOrderId.add(o.Id);
                    }else{
                        sOrderId.add(o.Id);
                    }
                }
            }
        }
  
        if(!sOrderId.isEmpty()){
            createLawfirmAPIFuture(sOrderId);
        }
        
        if(!sAmendmentOrderId.isEmpty()){
            updateOrderItemStatus(sAmendmentOrderId);
            
        }    
    }// END OF METHOD - createLawfirmAPI
    
    /**@@
        #DESCRIPTION   : create Lawfirm API
        #Paramaters    : set<Id>
    @@**/
    @Future(callout=true)
    public static void createLawfirmAPIFuture(set<Id> sOrderId){
        
        string strAccesstoken= authorization();
           
        String strSOQL = 'SELECT ' + queryAllFields('Order') + ', Account.MH_Cust_Number__c, Account.Name, ';
        strSOQL += 'SBQQ__Quote__r.SBQQ__PrimaryContact__r.FirstName, SBQQ__Quote__r.SBQQ__PrimaryContact__r.LastName, ';
        strSOQL += 'SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email, SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone, ';
        strSOQL += 'SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone_2__c, SBQQ__Quote__r.SBQQ__PrimaryContact__r.Fax, ';
        strSOQL += 'SBQQ__Quote__r.SBQQ__PrimaryContact__r.Website__c, SBQQ__Quote__r.SBQQ__PrimaryContact__r.MailingStreet, ';
        strSOQL += 'SBQQ__Quote__r.SBQQ__PrimaryContact__r.MailingCity, SBQQ__Quote__r.SBQQ__PrimaryContact__r.MailingState, ';
        strSOQL += 'SBQQ__Quote__r.SBQQ__PrimaryContact__r.MailingPostalcode, ';
        strSOQL += 'Opportunity.SBQQ__AmendedContract__r.SBQQ__Order__c, ';
        strSOQL += 'BillToContact.FirstName, BillToContact.LastName, BillToContact.Email, BillToContact.Phone, ';
        strSOQL += 'BillToContact.Phone_2__c, BillToContact.Fax, BillToContact.Website__c, BillToContact.MailingStreet, ';
        strSOQL += 'BillToContact.MailingCity, BillToContact.MailingState, BillToContact.MailingPostalcode, ';
        strSOQL += '(SELECT Id, TotalPrice, Usage_List_Price__c, SIN__c, Attribute_Relationship__c FROM OrderItems WHERE Quantity > 0) ';
        strSOQL += ' FROM Order ';
        strSOQL += ' WHERE Id IN: sOrderId';
        
        List<Order> lstOrderErrorUpdate = new List<Order>();
        List<Order> lstOrder = database.query(strSOQL);
        
        set<Id> sAccSuccessId = new set<Id>();
        
        system.debug('$$$$$$$$'+strAccesstoken);
        Map<Id, String> mapOLIWithSubscriptionId = new Map<Id, String>();
        for(Order o: lstOrder){
            if(!o.OrderItems.isEmpty()){
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                string strBody;
                request.setEndpoint(system.Label.Order_API_Endpoint + '/api/proposals');
                strBody = prepareRequestBody(o);
               
    
                request.setHeader('Authorization', 'Bearer ' + strAccesstoken);
                request.setHeader('Content-Type', 'application/json');
                
                request.setMethod('POST');
                
                system.debug('@@@@@@@@@'+strBody);
                request.setBody(strBody);
                
                string strResponse;
                if(Test.isRunningTest() == false){
                    HttpResponse response = http.send(request);
                    strResponse = response.getBody();
                    system.debug('$$$$$$$$'+response.getStatusCode());
                }else{
                    strResponse = '{"data":{"items":{"id":"5598331","account":{"id":"1001423732458","partnerId":null,"brandId":"nolo","name":"firm new test","url":"null","origin":"nolo.com","leadCap":null,"leadCapFrequency":null,"rankingMultiplier":null,"status":"active","salesId":null,"externalId":null,"pauseStart":null,"pauseEnd":null,"inactiveDate":null,"encodedExtendInfo":null,"updated":null,"created":"2020-12-18 13:53:48","client_guid":null,"proposals":null,"verticalId":11,"type":{"id":"1","name":null,"descriptions":null,"proposals":null,"proposalTypes":null,"waitlists":null,"__className":"Campaign_Dto_Proposal_Type","__isCache":false},"updatedBy":"555","__className":"Campaign_Dto_Account","__isCache":false},"parentIds":null,"name":"null","firmName":"firm new test","firmUrl":"null","contactFirstName":"Nick","contactLastName":"B","contactEmail":"niketan.badani.1@martindale.com","contactPhone1":"1112223333","contactPhone2":null,"contactFax":null,"contactAddress1":"121 Chanlon Road","contactAddress2":null,"contactCity":"New Providence","contactProvince":{"id":"31","code":"NJ","name":"New Jersey","urlEncodedName":"new-jersey","country":"US","created":"2009-12-12 00:00:00","updated":"2009-12-12 00:00:00","contactProvinces":null,"__className":"Common_Dto_Province","__isCache":false},"contactPostalCode":"07974","urlKey":"NOLO_11x5fdd24ecd9123x77719559","urlKeyExpiration":"2021-02-16 13:53:48","verticalId":"11","type":{"id":"1","name":"Lawfirms","descriptions":null,"proposals":null,"proposalTypes":null,"waitlists":null,"__className":"Campaign_Dto_Proposal_Type","__isCache":false},"paymentType":{"id":"2","name":"Pay Per Lead","descriptions":null,"proposals":null,"__className":"Campaign_Dto_PaymentType","__isCache":false},"programType":"lead","fromProgramType":null,"initCharge":"0.00","flatFeeCredit":null,"pplCredit":null,"fixFeeCredit":null,"adminCredit":null,"recurringCharge":"0.00","recurringFrequency":"3","lastChargeDate":null,"nextChargeDate":null,"potentialRevenue":null,"contractTerm":"1 Year","renewalType":"auto-renew","state":"contract-activated","status":"active","salesId":"555","salesName":"rep1","saleType":"new","sendConfirmEmail":null,"sendWelcomeEmail":null,"profileOrigin":"nolo.com","leadCap":"0.00","leadCapFrequency":"Monthly","rankingMultiplier":null,"clientSiteId":null,"subscriptionDataType":null,"amendmentType":"cm","clientLastVisited":null,"salesLastVisited":null,"lastAdvertiserLimitCheck":null,"contractStart":"2020-12-18 13:53:48","contractEnd":null,"activated":"2020-12-18 13:53:48","lastSuspended":null,"updated":"2020-12-18 13:53:48","created":"2020-12-18 13:53:48","bypasses":null,"extraDatas":null,"subscriptions":[{"id":"18160071","proposal":{"id":"5598331"},"parentSubscription":null,"start":"2020-12-18 13:53:48","end":null,"discountAmt":"0.00","price":"123.00","elp":null,"termLength":null,"subscriptionCount":"1","pplDeposit":"0.00","leadCap":"1050.00","leadCapFrequency":null,"rankingMultiplier":null,"tier":null,"subscriptionType":{"id":"9"},"siteTid":null,"startLeadVolume":null,"endLeadVolume":null,"leadVolumeUpdated":null,"cancellationRequestDate":null,"cancellationReason":null,"status":"active","bypassLimitCheck":"0","updated":null,"created":"2020-12-18 13:53:48","elpUpdated":null,"childrenSubscriptions":null,"dataType1s":null,"dataType2s":null,"extraInfo":{"term1":{"id":125,"category":null,"parentTerm":null,"name":"Auto Accident","descriptions":null,"level":null,"childrenTerms":[],"externalId":"125","updated":null,"created":null,"primary":null,"stateCode":null,"__className":"Campaign_Dto_Term","__isCache":false},"term2Parents":[{"id":80370,"name":"Alabama","externalId":"80370","selectedChildren":67,"totalChildren":"67"}],"coverages":{"min":0,"max":0},"targetPrice":123},"revShare":null,"revShareFixed":null,"groupSelectionAmountType":null,"docuTemplateId":null,"sfSinId":"1001423732.70010.8027j000000TOXWAA4687","docuPrefillFields":null,"__className":"Campaign_Dto_Proposal_Subscription","__isCache":false}],"termsConditions":null,"revShare":null,"revShareFixed":null,"groupSelectionAmountType":null,"brandId":"nolo","smbGuid":null,"externalId":null,"providerId":null,"taxType":"0","taxRate":null,"taxAmount":null,"totalAmount":null,"taxPreIncluded":null,"__className":"Campaign_Dto_Proposal","__isCache":false}}}';
    
                }
                system.debug('$$$$$$$$'+strResponse);
                
                
                Order objOrder = new Order(id=o.id);
                objOrder.Usage_Integration_Request_body__c = strBody;
                objOrder.Usage_Integration_Response_body__c = strResponse;
                
                String strSuccessErrorMsg = '';
                if(strResponse != null){
                    if(strResponse.contains('"error":') == false){
                        sAccSuccessId.add(o.AccountId);
                        OrderJSONParse objResponse = (OrderJSONParse) JSON.deserialize(strResponse, OrderJSONParse.class);
                        map<String, String> mapSINWithSubId = new  map<String, String>();
                        for(OrderJSONParse.cls_subscriptions objSub: objResponse.data.items.subscriptions){
                            mapSINWithSubId.put(objSub.sfSinId, objSub.id);
                        }
                        
                        for(OrderItem oli: o.OrderItems){
                            if(mapSINWithSubId != null && oli.SIN__c != null && mapSINWithSubId.containsKey(oli.SIN__c)){
                                mapOLIWithSubscriptionId.Put(oli.Id, mapSINWithSubId.get(oli.SIN__c));
                            }
                        }
                        strSuccessErrorMsg = string.valueOf(mapOLIWithSubscriptionId.values());
                    }else{
                        JSONParser parser = JSON.createParser(strResponse );
                        while (parser.nextToken() != null) {
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'response')) {
                                    // Get the value.
                                    parser.nextToken();                               
                                    strSuccessErrorMsg = parser.getText();
                                }
                        }
                    }
                }
                objOrder.Usage_Integration_Success_Error_Msg__c = strSuccessErrorMsg;
                lstOrderErrorUpdate.add(objOrder);
            }
        }
        //system.assertEquals(mapOLIWithSubscriptionId, null);
        List<OrderItem> lstOIUpdate = new List<OrderItem>();
        OrderItem objOI;
        for(Id oliId: mapOLIWithSubscriptionId.keyset()){
            if(mapOLIWithSubscriptionId != null && mapOLIWithSubscriptionId.containsKey(oliId)){
                objOI = new OrderItem(id=oliId);
                objOI.Subscription_Id__c = mapOLIWithSubscriptionId.get(oliId);
                lstOIUpdate.add(objOI);
            }
        }
        if(!lstOIUpdate.isEmpty()){
            update lstOIUpdate;
        }
        system.debug('@@@@@@@@@@@'+lstOrderErrorUpdate);
        
        if(!lstOrderErrorUpdate.isEmpty()){
           update lstOrderErrorUpdate;
        }
        if(!sAccSuccessId.isEmpty()){
            List<Account> accListUpdate = new List<Account>();
            for(Id accId: sAccSuccessId){
                Account objAcc = new Account(id=accId);
                objAcc.CM_Customer__c = TRUE;
                accListUpdate.add(objAcc);
            }
            if(!accListUpdate.isEmpty()){
                update accListUpdate;
            }
        }
    }// END OF METHOD - createLawfirmAPIFuture
    
    
    /**@@
        #DESCRIPTION   : create Lawfirm API
        #Paramaters    : set<Id>
    @@**/
    public static void createLawfirmAPIFuture_Amendment(set<Id> sOrderId, string strToken, String strAPIType, List<OrderItem> lstOIUpdateParam){
        
        string strAccesstoken;
        if(strToken == null){
            strAccesstoken = authorization();
        }else{
            strAccesstoken = strToken;
        }    
        String strSOQL = 'SELECT ' + queryAllFields('Order') + ', Account.MH_Cust_Number__c, Account.Name, ';
        strSOQL += 'SBQQ__Quote__r.SBQQ__PrimaryContact__r.FirstName, SBQQ__Quote__r.SBQQ__PrimaryContact__r.LastName, ';
        strSOQL += 'SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email, SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone, ';
        strSOQL += 'SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone_2__c, SBQQ__Quote__r.SBQQ__PrimaryContact__r.Fax, ';
        strSOQL += 'SBQQ__Quote__r.SBQQ__PrimaryContact__r.Website__c, SBQQ__Quote__r.SBQQ__PrimaryContact__r.MailingStreet, ';
        strSOQL += 'SBQQ__Quote__r.SBQQ__PrimaryContact__r.MailingCity, SBQQ__Quote__r.SBQQ__PrimaryContact__r.MailingState, ';
        strSOQL += 'SBQQ__Quote__r.SBQQ__PrimaryContact__r.MailingPostalcode, ';
        strSOQL += 'Opportunity.SBQQ__AmendedContract__r.SBQQ__Order__c, ';
        strSOQL += 'BillToContact.FirstName, BillToContact.LastName, BillToContact.Email, BillToContact.Phone, ';
        strSOQL += 'BillToContact.Phone_2__c, BillToContact.Fax, BillToContact.Website__c, BillToContact.MailingStreet, ';
        strSOQL += 'BillToContact.MailingCity, BillToContact.MailingState, BillToContact.MailingPostalcode, ';
        strSOQL += '(SELECT Id, TotalPrice, Usage_List_Price__c, SIN__c, Attribute_Relationship__c FROM OrderItems WHERE Quantity > 0) ';
        strSOQL += ' FROM Order ';
        strSOQL += ' WHERE Id IN: sOrderId';
        
        List<Order> lstOrderErrorUpdate = new List<Order>();
        List<Order> lstOrder = database.query(strSOQL);
        
        set<Id> sOrigianlOrderId = new set<Id>();
        for(Order o: lstOrder){
            if(o.Opportunity.SBQQ__AmendedContract__c != null && o.Opportunity.SBQQ__AmendedContract__r.SBQQ__Order__c != null){
                sOrigianlOrderId.add(o.Opportunity.SBQQ__AmendedContract__r.SBQQ__Order__c);
            }
        }

        system.debug('$$$$$$$$'+strAccesstoken);
        Map<Id, String> mapOLIWithSubscriptionId = new Map<Id, String>();
        for(Order o: lstOrder){
            if(!o.OrderItems.isEmpty()){
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                //request.setEndpoint('http://98.158.206.72/api/proposals');
                string strBody;
                if(strAPIType == 'New Order'){
                    request.setEndpoint(system.Label.Order_API_Endpoint + '/api/proposals');
                    strBody = prepareRequestBody(o);
                }else{
                    request.setEndpoint(system.Label.Order_API_Endpoint + '/api/clients/' + o.Account.MH_Cust_Number__c + '/campaigns');
                    strBody = prepareRequestBodyAddCampaign(o);
                }
    
                request.setHeader('Authorization', 'Bearer ' + strAccesstoken);
                request.setHeader('Content-Type', 'application/json');
                
                request.setMethod('POST');
                
                system.debug('@@@@@@@@@'+strBody);
                request.setBody(strBody);
                
                String strResponse;
                if(Test.isRunningTest() == false){
                    HttpResponse response = http.send(request);
                    system.debug('$$$$$$$$'+response.getBody());
                    system.debug('$$$$$$$$'+response.getStatusCode());
                    strResponse = response.getBody();
                }else{
                    strResponse = '{"error":{"campaigns":["The campaigns field is required."]}}';
                }
                Order objOrder = new Order(id=o.id);
                objOrder.Usage_Integration_Request_body__c = strBody;
                objOrder.Usage_Integration_Response_body__c = strResponse;
                
                String strSuccessErrorMsg = '';
                if(strResponse != null){
                    if(strResponse.contains('"error":') == false){
                        OrderJSONParse objResponse = (OrderJSONParse) JSON.deserialize(strResponse, OrderJSONParse.class);
                        map<String, String> mapSINWithSubId = new  map<String, String>();
                        for(OrderJSONParse.cls_subscriptions objSub: objResponse.data.items.subscriptions){
                            mapSINWithSubId.put(objSub.sfSinId, objSub.id);
                        }
                        
                        for(OrderItem oli: o.OrderItems){
                            if(mapSINWithSubId != null && oli.SIN__c != null && mapSINWithSubId.containsKey(oli.SIN__c)){
                                mapOLIWithSubscriptionId.Put(oli.Id, mapSINWithSubId.get(oli.SIN__c));
                            }
                        }
                        strSuccessErrorMsg = string.valueOf(mapOLIWithSubscriptionId.values());
                    }else{
                        JSONParser parser = JSON.createParser(strResponse);
                        while (parser.nextToken() != null) {
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'response')) {
                                    // Get the value.
                                    parser.nextToken();                               
                                    strSuccessErrorMsg = parser.getText();
                                }
                        }
                    }
                }
                objOrder.Usage_Integration_Success_Error_Msg__c = strSuccessErrorMsg;
                lstOrderErrorUpdate.add(objOrder);
            }
        }
        //system.assertEquals(mapOLIWithSubscriptionId, null);
        List<OrderItem> lstOIUpdate = new List<OrderItem>();
        OrderItem objOI;
        for(Id oliId: mapOLIWithSubscriptionId.keyset()){
            if(mapOLIWithSubscriptionId != null && mapOLIWithSubscriptionId.containsKey(oliId)){
                objOI = new OrderItem(id=oliId);
                objOI.Subscription_Id__c = mapOLIWithSubscriptionId.get(oliId);
                lstOIUpdate.add(objOI);
            }
        }
        if(!lstOIUpdate.isEmpty()){
            update lstOIUpdate;
        }
        system.debug('@@@@@@@@@@@'+lstOrderErrorUpdate);
        
        if(!lstOrderErrorUpdate.isEmpty()){
           update lstOrderErrorUpdate;
        }
        if(!lstOIUpdateParam.isEmpty()){
            update lstOIUpdateParam;
        }
        if(test.isRunningTest()){
            Id oId = [Select id from order limit 1].Id;
            sOrigianlOrderId.add(oId);
        }
        if(!sOrigianlOrderId.isEmpty()){
            List<Order> lstOrderUpdate = new List<Order>();
            for(Id orderId: sOrigianlOrderId){
                Order objOrder = new Order(id=orderId);
                objOrder.Status__c = Constant.ORDER_STATUS_CANCELLED;
                lstOrderUpdate.add(objOrder);
            }
            if(!lstOrderUpdate.isEmpty()){
                update lstOrderUpdate;
            }
        }
    }// END OF METHOD - createLawfirmAPIFuture_Amendment
    
    /**@@
        #DESCRIPTION   : Prepare Request body for API callout
        #Paramaters    : sObject
    @@**/
    public static String prepareRequestBody(Order objOrder){
        set<Id> sARI = new set<Id>();
        for(OrderItem oli: objOrder.OrderItems){
            sARI.add(oli.Attribute_Relationship__c);
            
        }
        Map<Id, String> mapARWithPracticeArea = new Map<Id, String>();
        
        Map<Id, Map<String, List<String>>> mapARWithServiceStates = new Map<Id, Map<String, List<String>>>();
        Map<String, String> mapStateNamewithIntegrationId = new Map<String, String>();
        Map<String, String> mapCountyNamewithIntegrationId = new Map<String, String>();
        Map<String, String> mapPracticeAreaNamewithIntegrationId = new Map<String, String>();
        if(!sARI.isEmpty()){
            
            List<Attribute_Lines__c> lstAL = [SELECT Id, String_Value__c, Attribute_Junction__c FROM Attribute_Lines__c WHERE Attribute_Junction__c IN: sARI AND Attribute_Name__c = 'Practice Area'];
            for(Attribute_Lines__c al: lstAL){
                mapARWithPracticeArea.Put(al.Attribute_Junction__c, al.String_Value__c);
            }
            
            List<Attribute_Lines__c> lstALServiceStateswithCounties = [SELECT Id, Multi_Select_Value__c, String_Value__c, Attribute_Junction__c FROM Attribute_Lines__c WHERE Attribute_Junction__c IN: sARI AND Attribute_Name__c = 'Service County'];
            
            Map<String, List<String>> mapStateWithCounties = new Map<String, List<String>>();
            for(Attribute_Lines__c al: lstALServiceStateswithCounties){
                mapStateWithCounties = new Map<String, List<String>>();
                
                string[] arrEachStateWithCounty = new string[]{};
                if(al.Multi_Select_Value__c.contains(';')){
                    arrEachStateWithCounty = al.Multi_Select_Value__c.split(';');
                }else{
                    arrEachStateWithCounty.add(al.Multi_Select_Value__c);
                }
                for(String strIndividualStateWithCounty: arrEachStateWithCounty){
                    if(strIndividualStateWithCounty.contains('---')){
                        string[] arrSC = strIndividualStateWithCounty.split('---');
                        List<String> lstCounties = arrSC[1].split(';');
                        if(mapStateWithCounties != null && mapStateWithCounties.containsKey(arrSC[0])){
                            mapStateWithCounties.get(arrSC[0]).addAll(lstCounties);
                            
                        }else{
                            mapStateWithCounties.Put(arrSC[0], lstCounties);
                        }
                    }
                }
                mapARWithServiceStates.put(al.Attribute_Junction__c, mapStateWithCounties);
                
            }
            
            List<Usage_State_and_County__c> lstUsateStateCounty = [SELECT Id, Practice_Area__c, Practice_Area_Integration_Id__c, State_Abbreviation__c, State_Integration_Id__c, County_Name__c, County_Integration_Id__c FROM Usage_State_and_County__c];
            for(Usage_State_and_County__c usc: lstUsateStateCounty){
                if(usc.State_Abbreviation__c != null && usc.State_Integration_Id__c != null){
                    mapStateNamewithIntegrationId.Put(usc.State_Abbreviation__c, usc.State_Integration_Id__c);
                }
                if(usc.County_Name__c != null && usc.County_Integration_Id__c != null){
                    mapCountyNamewithIntegrationId.Put(usc.State_Abbreviation__c + '---' + usc.County_Name__c, usc.County_Integration_Id__c);
                }
                
                if(usc.Practice_Area__c != null && usc.Practice_Area_Integration_Id__c != null){
                    mapPracticeAreaNamewithIntegrationId.Put(usc.Practice_Area__c, usc.Practice_Area_Integration_Id__c);
                }
            }
        }
        string strBillingConFax = '';
        if(objOrder.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Fax != null){
            strBillingConFax = objOrder.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Fax;
        }
        string strPhone2 = '';
        if(objOrder.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone_2__c != null){
            strPhone2 = objOrder.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone_2__c;
        }
        string strReqBody = '';
        strReqBody = '{';
        strReqBody += '"firm_name":"' + objOrder.Account.Name + '",';
        strReqBody += '"proposal_info":{';
        strReqBody += '"name":"' + objOrder.Name + '",';
        strReqBody += '"sf_customer_id":"' + objOrder.Account.MH_Cust_Number__c + '",';
        strReqBody += '"sf_rep_id":"555",';
        strReqBody += '"sf_rep_name":"rep1",';
        strReqBody += '"lead_cap":""';
        strReqBody += '},';
        strReqBody += '"contact_info":{';
        strReqBody += '"first_name":"' + objOrder.SBQQ__Quote__r.SBQQ__PrimaryContact__r.FirstName + '",';
        strReqBody += '"last_name":"' + objOrder.SBQQ__Quote__r.SBQQ__PrimaryContact__r.LastName + '",';
        strReqBody += '"email":"' + objOrder.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email + '",';
        strReqBody += '"phone1":"' + objOrder.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone + '",';
        strReqBody += '"phone2":"' + strPhone2 + '",';
        strReqBody += '"fax":"' + strBillingConFax + '",';
        strReqBody += '"website":"' + objOrder.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Website__c + '"';
        strReqBody += '},';
        strReqBody += '"address_info":{';
        strReqBody += '"address":"' + objOrder.SBQQ__Quote__r.SBQQ__PrimaryContact__r.MailingStreet + '",';
        strReqBody += '"address2":"",';
        strReqBody += '"city":"' + objOrder.SBQQ__Quote__r.SBQQ__PrimaryContact__r.MailingCity + '",';
        strReqBody += '"province":"' + objOrder.SBQQ__Quote__r.SBQQ__PrimaryContact__r.MailingState + '",';
        strReqBody += '"zip_code":"' + objOrder.SBQQ__Quote__r.SBQQ__PrimaryContact__r.MailingPostalcode + '"';
        strReqBody += '},';
        
        
        // strReqBody += '"campaigns":[{"sf_sin_id":"179abcd1","practice_area_id":"4","locations":{"80370":["80609","80618","80630","80703","80723"],"80375":["80520","80548"]},"lead_price":"44.65","lead_cap":""},{"sf_sin_id":"179bcdefg1","practice_area_id":"12","locations":{"80370":["80609","80618","80630","80703","80723"],"80375":["80520","80548"]},"lead_price":"44.65","lead_cap":"1025"}';
         
        
        strReqBody += '"campaigns":[';
        
        integer i = 0;
        for(OrderItem oli: objOrder.OrderItems){
            i++;
            strReqBody += '{"sf_sin_id":"' + oli.SIN__c + '",';
            //oli.Attribute_Relationship__c
            string strPracticeArea = '';
            
            if(mapARWithPracticeArea != null && mapARWithPracticeArea.containsKey(oli.Attribute_Relationship__c)){
                if(mapPracticeAreaNamewithIntegrationId != null && mapPracticeAreaNamewithIntegrationId.containsKey(mapARWithPracticeArea.get(oli.Attribute_Relationship__c))){
                    strPracticeArea = mapPracticeAreaNamewithIntegrationId.get(mapARWithPracticeArea.get(oli.Attribute_Relationship__c));
                }
            }
            strReqBody += '"practice_area_id":"' + strPracticeArea + '",';
            
            strReqBody += '"locations":{';
            string strStateIntId;
            string strCountyIntId;
            system.debug('$$$$$$$$$$$'+mapARWithServiceStates);
            if(mapARWithServiceStates != null && mapARWithServiceStates.containsKey(oli.Attribute_Relationship__c)){
                integer k = 0;
                for(String strState: mapARWithServiceStates.get(oli.Attribute_Relationship__c).keyset()){
                    k++;
                    strStateIntId = '';
                    if(mapStateNamewithIntegrationId != null && mapStateNamewithIntegrationId.containsKey(strState)){
                        strStateIntId = mapStateNamewithIntegrationId.get(strState);
                    }
                    strReqBody += '"' + strStateIntId + '": [';
                    integer m = 0;
                    string allCounties = '';
                    for(String strCounty: mapARWithServiceStates.get(oli.Attribute_Relationship__c).get(strState)){
                        m++;
                        strCountyIntId = '';
                        if(mapCountyNamewithIntegrationId != null && mapCountyNamewithIntegrationId.containsKey(strState + '---' + strCounty)){
                            strCountyIntId = mapCountyNamewithIntegrationId.get(strState + '---' + strCounty);
                            if(allCounties == ''){
                                allCounties = '"' + strCountyIntId + '"';
                            }else{
                                allCounties += ',"' + strCountyIntId + '"';
                            }
                        }
                    }
                    strReqBody += allCounties;
                    strReqBody += ']';
                    if(k != mapARWithServiceStates.get(oli.Attribute_Relationship__c).keyset().size() ){
                        strReqBody += ',';
                    }
                }
            }
            
            
            strReqBody += '}';
            strReqBody += ',';
            
            Decimal decLeadPrice = 0;
            if(oli.Usage_List_Price__c != null){
                decLeadPrice = oli.Usage_List_Price__c;
            }
            
            strReqBody += '"lead_price":"' + decLeadPrice + '",';
            strReqBody += '"lead_cap":"1050"';
            strReqBody += '}';
            if(i != objOrder.OrderItems.size() ){
                strReqBody += ',';
            }
        }
        
        strReqBody += ']';
        strReqBody += '}';
        
        
        return strReqBody;
    }// END OF METHOD - prepareRequestBody
    
    
    /**@@
        #DESCRIPTION   : Prepare Request body for Add Campaign
        #Paramaters    : sObject
    @@**/
    public static String prepareRequestBodyAddCampaign(Order objOrder){
        set<Id> sARI = new set<Id>();
        for(OrderItem oli: objOrder.OrderItems){
            sARI.add(oli.Attribute_Relationship__c);
        }
        Map<Id, String> mapARWithPracticeArea = new Map<Id, String>();
        
        Map<Id, Map<String, List<String>>> mapARWithServiceStates = new Map<Id, Map<String, List<String>>>();
        Map<String, String> mapStateNamewithIntegrationId = new Map<String, String>();
        Map<String, String> mapCountyNamewithIntegrationId = new Map<String, String>();
        Map<String, String> mapPracticeAreaNamewithIntegrationId = new Map<String, String>();
        if(!sARI.isEmpty()){
            
            List<Attribute_Lines__c> lstAL = [SELECT Id, String_Value__c, Attribute_Junction__c FROM Attribute_Lines__c WHERE Attribute_Junction__c IN: sARI AND Attribute_Name__c = 'Practice Area'];
            for(Attribute_Lines__c al: lstAL){
                mapARWithPracticeArea.Put(al.Attribute_Junction__c, al.String_Value__c);
            }
            
            List<Attribute_Lines__c> lstALServiceStateswithCounties = [SELECT Id, Multi_Select_Value__c, String_Value__c, Attribute_Junction__c FROM Attribute_Lines__c WHERE Attribute_Junction__c IN: sARI AND Attribute_Name__c = 'Service County'];
            
            Map<String, List<String>> mapStateWithCounties = new Map<String, List<String>>();
            for(Attribute_Lines__c al: lstALServiceStateswithCounties){
                mapStateWithCounties = new Map<String, List<String>>();
                
                string[] arrEachStateWithCounty = new string[]{};
                if(al.Multi_Select_Value__c.contains(';')){
                    arrEachStateWithCounty = al.Multi_Select_Value__c.split(';');
                }else{
                    arrEachStateWithCounty.add(al.Multi_Select_Value__c);
                }
                for(String strIndividualStateWithCounty: arrEachStateWithCounty){
                    if(strIndividualStateWithCounty.contains('---')){
                        string[] arrSC = strIndividualStateWithCounty.split('---');
                        List<String> lstCounties = arrSC[1].split(';');
                        if(mapStateWithCounties != null && mapStateWithCounties.containsKey(arrSC[0])){
                            mapStateWithCounties.get(arrSC[0]).addAll(lstCounties);
                            
                        }else{
                            mapStateWithCounties.Put(arrSC[0], lstCounties);
                        }
                    }
                }
                mapARWithServiceStates.put(al.Attribute_Junction__c, mapStateWithCounties);
                
            }
            
            List<Usage_State_and_County__c> lstUsateStateCounty = [SELECT Id, Practice_Area__c, Practice_Area_Integration_Id__c, State_Abbreviation__c, State_Integration_Id__c, County_Name__c, County_Integration_Id__c FROM Usage_State_and_County__c];
            for(Usage_State_and_County__c usc: lstUsateStateCounty){
                if(usc.State_Abbreviation__c != null && usc.State_Integration_Id__c != null){
                    mapStateNamewithIntegrationId.Put(usc.State_Abbreviation__c, usc.State_Integration_Id__c);
                }
                if(usc.County_Name__c != null && usc.County_Integration_Id__c != null){
                    mapCountyNamewithIntegrationId.Put(usc.State_Abbreviation__c + '---' + usc.County_Name__c, usc.County_Integration_Id__c);
                }
                
                if(usc.Practice_Area__c != null && usc.Practice_Area_Integration_Id__c != null){
                    mapPracticeAreaNamewithIntegrationId.Put(usc.Practice_Area__c, usc.Practice_Area_Integration_Id__c);
                }
            }
        }
        
        string strReqBody = '';
        strReqBody += '{';
        
        strReqBody += '"campaigns":[';
        
        integer i = 0;
        for(OrderItem oli: objOrder.OrderItems){
            i++;
            strReqBody += '{"sf_sin_id":"' + oli.SIN__c + '",';
            //oli.Attribute_Relationship__c
            string strPracticeArea = '';
            
            if(mapARWithPracticeArea != null && mapARWithPracticeArea.containsKey(oli.Attribute_Relationship__c)){
                if(mapPracticeAreaNamewithIntegrationId != null && mapPracticeAreaNamewithIntegrationId.containsKey(mapARWithPracticeArea.get(oli.Attribute_Relationship__c))){
                    strPracticeArea = mapPracticeAreaNamewithIntegrationId.get(mapARWithPracticeArea.get(oli.Attribute_Relationship__c));
                }
            }
            strReqBody += '"practice_area_id":"' + strPracticeArea + '",';
            
            strReqBody += '"locations":{';
            string strStateIntId;
            string strCountyIntId;
            system.debug('$$$$$$$$$$$'+mapARWithServiceStates);
            if(mapARWithServiceStates != null && mapARWithServiceStates.containsKey(oli.Attribute_Relationship__c)){
                integer k = 0;
                for(String strState: mapARWithServiceStates.get(oli.Attribute_Relationship__c).keyset()){
                    k++;
                    strStateIntId = '';
                    if(mapStateNamewithIntegrationId != null && mapStateNamewithIntegrationId.containsKey(strState)){
                        strStateIntId = mapStateNamewithIntegrationId.get(strState);
                    }
                    strReqBody += '"' + strStateIntId + '": [';
                    integer m = 0;
                    string allCounties = '';
                    for(String strCounty: mapARWithServiceStates.get(oli.Attribute_Relationship__c).get(strState)){
                        m++;
                        strCountyIntId = '';
                        if(mapCountyNamewithIntegrationId != null && mapCountyNamewithIntegrationId.containsKey(strState + '---' + strCounty)){
                            strCountyIntId = mapCountyNamewithIntegrationId.get(strState + '---' + strCounty);
                            if(allCounties == ''){
                                allCounties = '"' + strCountyIntId + '"';
                            }else{
                                allCounties += ',"' + strCountyIntId + '"';
                            }
                        }
                    }
                    strReqBody += allCounties;
                    strReqBody += ']';
                    if(k != mapARWithServiceStates.get(oli.Attribute_Relationship__c).keyset().size() ){
                        strReqBody += ',';
                    }
                }
            }
            
            
            strReqBody += '}';
            strReqBody += ',';
            
            Decimal decLeadPrice = 0;
            if(oli.Usage_List_Price__c != null){
                decLeadPrice = oli.Usage_List_Price__c;
            }
            
            strReqBody += '"lead_price":"' + decLeadPrice + '",';
            strReqBody += '"lead_cap":"1050"';
            strReqBody += '}';
            if(i != objOrder.OrderItems.size() ){
                strReqBody += ',';
            }
        }
        
        strReqBody += ']';
        strReqBody += '}';
        
        return strReqBody;
    }
    
    
    /*
        Method Name: authorization
        Description: This method is used to authorize API
        Parameter  : None
    */
    Public static string authorization(){
        string strAccesstoken = '';
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(system.Label.Order_API_Endpoint + '/oauth/token');
        //request.setEndpoint('http://98.158.206.72/oauth/token');
        request.setHeader('Content-Type', 'application/json');
        
        request.setMethod('POST');
        string strBody = '';
        strBody += '{';
        strBody += '"grant_type": "client_credentials",';
        strBody += '"client_id": 1,';
        strBody += '"client_secret": "' + system.label.Order_API_client_secret + '"';
        strBody += '}';
        request.setBody(strBody);
        string strResponse;
        if(Test.isRunningTest() == false){
            HttpResponse response = http.send(request);
            strResponse = response.getBody();
        }else{
            strResponse = '{"token_type":"Bearer","expires_in":31536000,"access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiYjY0NGE2NTgxZmNiM2ZkZGFlOGI0MzliNWJlMTAyYTNiZjAwNGFhMGUyNTEwYzdlMDdlOWJjMGU4N2JlYzg4NTk5Zjg2ODcwNmZlMTBhNjAiLCJpYXQiOjE2MDk5NTIxMjksIm5iZiI6MTYwOTk1MjEyOSwiZXhwIjoxNjQxNDg4MTI5LCJzdWIiOiIiLCJzY29wZXMiOltdfQ.rD4-B3AHtZKctodWh2r3KIzngg1D88Fk5culO7z-LIhlEvaSo0mK9szMeGFECwJanylDRAeLRaPu52u9cyqZD7r8pPYrMHYaD05VHiQuDuiGbzXrohNw5wOsxHS01zaJRYz8hkO2UvsdMld8njSfqbFWXQuuNHXe3CMGx_BDrt3IOeV6t4sNVzirkV5cSN94ppdSLfJahJSB0at2FbCX7Q1UqWlyW9JjG_6dJ3kYLuRPfgzcns24PAtnToiPPRFPatmTddgzsCcnr8wGGOppeB5uN2se5TM7iAw3czd7FVTq3TTak8CwGbeIVT-iyDT7Y0lZ0kJaXDnvLnAYhJ1ACL0mpASi3QH9S-S7LOR99B3C9YCShg9OITfany8D2oi6iS7mS4FDgFKRlZsDQ3FsxvWe5U5X1c4T9qjJ8eoCl5Fdak6NUgUZxHe8fsXlZ8pzGb0LiHHBh-MqeZOTCNY8r8m_I930sMaapr1YmdaUdszsTeVaLSd6AaFjsdGLuO4L1znI_8aZ934aOMG_y0sO68ptG6WJWA3jndgwef99MyUQTR56HazN3_jqfKJMFlCL7P7coPTPeEhEWNRjztGu9EorgrZ-a-f_3Ki3nKXW3cBwyhNVAfZHt4p39wrgSGRkDWo4q1xFAnZTg3Rhtllqp5yWpyV2dW6mREJuvECnJt4"}';
        }
        system.debug('######'+strResponse);
        
        JSONParser parser = JSON.createParser(strResponse);
        while (parser.nextToken() != null){
            if (parser.getCurrentName() == 'access_token'){                 
                parser.nextToken();
                strAccesstoken = parser.getText();
            }
        }
        
        return strAccesstoken;
    }
    
    
    /**@@
        #DESCRIPTION   : Call Update API
        #Paramaters    : trigger.new
    @@**/
    @future(callout=true)
    public static void updateOrderItemStatus(set<Id> sAmendmentOrderId){ 
        set<Id> sOriginalOrder = new set<Id>();
        List<Order> lstAmendmentOrder = [SELECT Id, Opportunity.SBQQ__AmendedContract__r.SBQQ__Order__c FROM Order WHERE Id IN: sAmendmentOrderId];
        for(Order o: lstAmendmentOrder){
            if(o.Opportunity.SBQQ__AmendedContract__c != null && o.Opportunity.SBQQ__AmendedContract__r.SBQQ__Order__c != null){
                sOriginalOrder.add(o.Opportunity.SBQQ__AmendedContract__r.SBQQ__Order__c);
            }
        }
        
        List<OrderItem> lstOI = [SELECT Id, Status__c, Order.Account.MH_Cust_Number__c, SIN__c FROM OrderItem WHERE OrderId IN: sOriginalOrder];
        string strAccesstoken = authorization();
        List<OrderItem> lstOIUpdate = new List<OrderItem>();
        OrderItem objOI;
        string strOIStatus;
        for(OrderItem oi: lstOI){
            Http http = new Http(); //global class which is used in both request & response
            HttpRequest req = new HttpRequest(); //initiate HTTP request
            string strEndPoint = system.Label.Order_API_Endpoint + '/api/clients/' + oi.Order.Account.MH_Cust_Number__c + '/campaigns/' + oi.SIN__c + '/status';
            req.setEndpoint(strEndPoint);
            req.setHeader('Authorization', 'Bearer ' + strAccesstoken);
            req.setMethod('PATCH');
            
            strOIStatus = oi.Status__c;
            //if(strOIStatus == Constant.ORDER_STATUS_TRUNCATED){
                // strOIStatus = Constant.ORDER_STATUS_CANCELLED ;
            //}
            //strOIStatus = Constant.ORDER_STATUS_INACTIVE;
            if(strOIStatus == Constant.ORDER_STATUS_CANCELLED){
                strOIStatus = Constant.ORDER_STATUS_INACTIVE;
            }
            
            String strBody = '';
            strBody = '{"status": "' + strOIStatus + '"}';
            req.setBody(strBody); 
            req.setHeader('Content-Type', 'application/json');
            HTTPResponse res = http.send(req);
            System.debug('Response Body : '+res.getBody());
            String strSuccessErrorMsg = '';
            if(res.getStatusCode() == 200){
                
            }
            
            objOI = new OrderItem(id=oi.Id);
            objOI.Usage_Integration_Request_body__c = strBody;
            objOI.Usage_Integration_Response_body__c = res.getBody();
            objOI.Usage_Integration_Success_Error_Msg__c = strSuccessErrorMsg;
            // objOI.Status__c = Constant.ORDER_STATUS_CANCELLED;
            lstOIUpdate.add(objOI);
        }
        
        //if(!lstOIUpdate.isEmpty()){
        // update lstOIUpdate;
        createLawfirmAPIFuture_Amendment(sAmendmentOrderId, strAccesstoken, 'Add Campaign', lstOIUpdate);
        //}

    }// END OF METHOD - updateOrderItemStatus
    
    
    /*
        Method Name: queryAllFields
        Description: This method is used to return all fields of sObject 
        Parameter  : sObject API Name
    */
    Public static string queryAllFields(String strObjectAPIName){
        DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(strObjectAPIName).getDescribe();
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        String queryFields = String.join( fieldNames, ',' );
        return queryFields;
    }// END OF METHOD - queryAllFields
    
     public static void updateBillingAccount(List<Order> newList){
         for(Order o:newList){
             o.blng__BillingAccount__c = o.AccountId;
             System.debug(o);
         }
          
    }// END OF METHOD 

    //T01
     public static void updateAddressFromAccount(List<Order> newList){
         
         Set<ID> AccountIDs = new Set<ID>();
         for(Order o:newList)
         {
             AccountIDs.add(o.AccountId);
         }
         if(!AccountIDs.isEmpty())
         {
             Map<Id,Account> acc2Map = new Map<Id,Account>([Select ID,Address_Street_Line_2__c,BillingStreet from Account where ID in :AccountIDs]);

             for(Order o:newList){
                 
                 if(o.AccountId!=null && acc2Map.containsKey(o.AccountId) && acc2Map.get(o.AccountId)!=null && acc2Map.get(o.AccountId).Address_Street_Line_2__c!=null )
                 {
                     o.BillingStreet = acc2Map.get(o.AccountId).BillingStreet + ' , '+  acc2Map.get(o.AccountId).Address_Street_Line_2__c;
                 }
                 
             }
         }
    }// END OF METHOD 
    //T08
    public static void updateOrderStatustoCancel(List<Order> ordLst, Map<Id, Order> oldMap){
        //List<Order> updateOrder = new List<Order>();
        system.debug('==ordLst'+ordLst);
        system.debug('==oldMap'+oldMap);
        for(Order ord: OrdLst){
            if(ord.ActiveOrderProds__c == 0 && ord.ActiveOrderProds__c != oldMap.get(ord.Id).ActiveOrderProds__c
              && ord.CancelOrderCount__c != 0){
                ord.UpdateOrderStatus__c = TRUE; 
                //updateOrder.add(ord);
            }
        }
        /*
        if(!updateOrder.isEmpty()){
            update updateOrder;
        }*/
    }
    //Ticket MHMAC-479
    public static void updateOrderStatus(List<Order> ordLst){
        System.debug('updateOrderStatus11111 ' + ordLst);
        List<Order> updateOrder = new List<Order>();
        for(Order ord: [SELECT ID,Status__c,TotalOrderProducts__c,CancelOrderCount__c,OffSetOrderCount__c,ActiveOrderProds__c FROM Order WHERE ID IN: OrdLst]){
            System.debug('ordStatus11 ' + ord.Status__c);
            System.debug('TotalOrderProducts1111 ' + ord.TotalOrderProducts__c);
            System.debug('CancelOrderCount1111 ' + ord.CancelOrderCount__c);
            System.debug('OffSetOrderCount1111 ' + ord.OffSetOrderCount__c);
            System.debug('ActiveOrderProds1111 ' + ord.ActiveOrderProds__c);
            if(ord.CancelOrderCount__c == ord.TotalOrderProducts__c && ord.Status__c != 'Cancelled' && (ord.Status__c == 'Active' || ord.Status__c == 'Evergreen')){
                System.debug('CancelOrderCheck1111 ' );
                ord.Status__c = 'Cancelled';
                updateOrder.add(ord);
            }else if(ord.OffSetOrderCount__c == ord.TotalOrderProducts__c && ord.Status__c != 'Off set' && ord.TotalOrderProducts__c > 0 && ord.ActiveOrderProds__c == 0){
                System.debug('OffSetOrderCheck1111 ' );
                ord.Status__c = 'Off set';
                updateOrder.add(ord);
            }else if(ord.ActiveOrderProds__c > 0 && ord.Status__c != 'Active' && ord.Status__c != 'Evergreen'){
                System.debug('ActiveOrderCheck1111' );
                ord.Status__c = 'Active'; 
                updateOrder.add(ord);
            }
        }
        System.debug('updateOrderOrderCheck1111 ' + updateOrder);
        if(!updateOrder.isEmpty()){
            System.debug('updateOr ' + updateOrder);
            update updateOrder;
        }
    }
    
}
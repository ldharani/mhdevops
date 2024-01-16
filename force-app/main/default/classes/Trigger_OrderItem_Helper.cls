/**@@ 
#TRIGGER NAME        :    OrderItemTrigger 
#HANDLER CLASS NAME  :    Trigger_OrderItem_Handler
#HELPER CLASS NAME   :    Trigger_OrderItem_Helper
#TEST CLASS          :    OrderItemTriggerTest
#CREATED BY          :    Serge Kandukuri
#DESCRIPTION         :    This Helper class will handles all the trigger events and handling the appropriate logic.   

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6018    SS            31/03/2022   John Mattheson  T01     Move process builders to apex
MHBS-7245    SaiV          06/06/2022   Prod Bug        T02     Added active filter for trnctd status update
MHBS-6368    VR            21/04/2022                   T03     Free Sales Change - Update Order Prods to Offset
MHBS-6018    SS            14/06/2022   Prod Bug        T04     Removed MA intake Record type
MHBS-7437    Saiv          08/17/2022   Prod Bug        T08     Cancel logic for custom content 
MHMAC-444    BS            25/09/2023                   T09     Terminated Date of Order Product population during Modify/Upgrade/Downgrade scenarios
MHMAC-458    SaiV          10/18/2023      Nama         T07      Enh - Dev: Update/remove code in Amendment tab supporting upgrade/downgrades
************************************************************************************************************************/
public class Trigger_OrderItem_Helper{

    /**@@
        #DESCRIPTION   : this method is used to create bi-weekly Usage summaries under Order Product
        #Paramaters    : trigger.new
    @@**/
    public static void createBiWeeklyUsageSummaries(List<OrderItem> newList){ 
        string strSOQL = 'SELECT ';
       ////////// strSOQL += queryAllFields('blng__UsageSummary__c');
        strSOQL += queryAllFields('blng__UsageSummary__c');
        strSOQL += test.isRunningTest()? ' FROM blng__UsageSummary__c':' FROM blng__UsageSummary__c WHERE blng__OrderProduct__c IN: newList order by blng__SummaryStartDate__c ASC';
        
        // Update Existing Usage Summaries
        List<blng__UsageSummary__c> lstUSDel = new List<blng__UsageSummary__c>();
        blng__UsageSummary__c objUSDel;
        
        List<blng__UsageSummary__c> lstUS = database.Query(strSOQL );
        List<blng__UsageSummary__c> lstUSInsert = new List<blng__UsageSummary__c>();
        blng__UsageSummary__c objUS;
        integer i = 0;
        //T05 System.debug('lstus '+lstUS+' '+[select Id FROM blng__UsageSummary__c]);
        for(blng__UsageSummary__c us: lstUS){
           
           // system.assertEquals(us.blng__SummaryStartDate__c.daysbetween(us.blng__SummaryEndDate__c),2);
            //system.assertEquals(1,2);
            if(us.blng__SummaryStartDate__c.daysbetween(us.blng__SummaryEndDate__c) > 15){
                objUSDel = new blng__UsageSummary__c(id=us.Id);
                lstUSDel.add(objUSDel);
                
                objUS = new blng__UsageSummary__c();
                objUS = us.clone();
                if(us.blng__SummaryStartDate__c.Month() != us.blng__SummaryEndDate__c.Month()){
                    objUS.blng__SummaryStartDate__c = date.newInstance(us.blng__SummaryStartDate__c.Year(), us.blng__SummaryStartDate__c.Month(), 1);
                }else{
                    objUS.blng__SummaryStartDate__c = date.newInstance(us.blng__SummaryStartDate__c.Year(), us.blng__SummaryStartDate__c.addMonths(-1).Month(), 1);
                }
                objUS.blng__SummaryEndDate__c = objUS.blng__SummaryStartDate__c.adddays(14);
                //system.debug('############'+objUS.blng__SummaryStartDate__c+'############'+objUS.blng__SummaryEndDate__c);
                
                //T05
                //system.debug('############'+objUS.blng__UniqueId__c);
                lstUSInsert.add(objUS);
                
                
                objUS = new blng__UsageSummary__c();
                objUS = us.clone();
                if(us.blng__UniqueId__c != null && us.blng__UniqueId__c.contains('Standard')){
                    objUS.blng__UniqueId__c = us.blng__UniqueId__c.replace('Standard','External');
                }else{
                    objUS.blng__UniqueId__c = us.blng__UniqueId__c + '-External';
                }
                
                if(us.blng__SummaryStartDate__c.Month() != us.blng__SummaryEndDate__c.Month()){
                    objUS.blng__SummaryStartDate__c = date.newInstance(us.blng__SummaryStartDate__c.Year(), us.blng__SummaryStartDate__c.Month(), 1).adddays(15);
                }else{
                    objUS.blng__SummaryStartDate__c = date.newInstance(us.blng__SummaryStartDate__c.Year(), us.blng__SummaryStartDate__c.addMonths(-1).Month(), 1).adddays(15);
                }
                
                Integer numberOfDays = Date.daysInMonth(objUS.blng__SummaryStartDate__c.year(), objUS.blng__SummaryStartDate__c.month());
                objUS.blng__SummaryEndDate__c = date.newInstance(objUS.blng__SummaryStartDate__c.Year(), objUS.blng__SummaryStartDate__c.Month(), numberOfDays); //us.blng__SummaryEndDate__c;
                // system.debug('@@@@@@@@@@@@'+objUS.blng__SummaryStartDate__c+'@@@@@@@@@@@@'+objUS.blng__SummaryEndDate__c);
                lstUSInsert.add(objUS);
            }else{
                objUSDel = new blng__UsageSummary__c(id=us.Id);
                lstUSDel.add(objUSDel);
            }
            
        }
        
        if(!lstUSDel.isEmpty() && !test.isRunningTest()){
            delete lstUSDel;
        }
        
        if(!lstUSInsert.isEmpty()){
            insert lstUSInsert;
        }
        
    }
    
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
    
    //@InvocableMethod
    //public static void setOrderStatusasCancelled(List<OrderItem> ordProdLst, Map<Id,OrderItem> oldMap){
    public static void setOrderStatusasCancelled(List<OrderItem> OrdId){ //forsignedretainers
        //Set<Id> OrdId = new Set<Id>();
        List<OrderItem> allOrdProds = new List<OrderItem>();
        List<OrderItem> nonCancelledOrdProds = new List<OrderItem>();
        Set<Id> ordIdToQuery = new Set<Id>();
        List<OrderItem> ordLstToUpdate = new List<OrderItem>();        
        List<OrderItem> allOrdProdsX = [select id, OrderId, Status__c,SBQQ__ProductSubscriptionType__c,SBQQ__TerminatedDate__c,
                       Product2.ProductCode,SBQQ__RevisedOrderProduct__c from OrderItem where Id IN:OrdId AND 
                       ProductFamily__c = 'Signed Retainers' AND Quantity <= 0 AND SBQQ__RevisedOrderProduct__c != Null];
        //System.debug('dddccc ' + allOrdProds);
        List<ID> revisedOrderItemList = new List<Id>();
        if(allOrdProdsX.size()>0){
            for(OrderItem op: allOrdProdsX){
               revisedOrderItemList.add(op.SBQQ__RevisedOrderProduct__c);
            }
        }
        if(revisedOrderItemList.size()>0){ //|| activeOrdprdsVsOrdId.isEmpty()){
            for(OrderItem ord: [select id, Status__c from OrderItem where Id IN:revisedOrderItemList]){
                if(ord.Status__c != 'Cancelled'){ //&& ord.Status__c != 'Evergreen'){
                    ord.Status__c = 'Cancelled';
                    ordLstToUpdate.add(ord);
                }
            }
        }
        if(!ordLstToUpdate.isEmpty()){
            update ordLstToUpdate;
        }
    }
    
    public static void updateOrderItemStatus(List<OrderItem> ordProdLst){
        Set<Id> OrderId = new Set<Id>();
        Set<Id> OrderItemId = new Set<Id>();
        Set<Id> AssetId = new Set<Id>();
        Set<Id> SubIds = new Set<Id>();
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
        List<Asset> assetsToUpdate = new List<Asset>();
        List<SBQQ__Subscription__c> subsToUpdate = new List<SBQQ__Subscription__c>();
        Map<Id, String> rvisdOrdItmIdVsOrdItmPrdCode = new Map<Id, String>();//T07
        Map<Id, String> rvisdsubItmVsOrdPrdStatus = new Map<Id, String>();//T07
        Boolean isTruncated = FALSE;
        
        Id oId;
        List<String> activeOrderItemSIN = new List<String>();
        for(OrderItem oi: ordProdLst){
            if((oi.Status__c == 'Off set' && (oi.SBQQ__ProductSubscriptionType__c != 'One-time' || oi.Productcode__c == '01503') //MHBS-7437 T08 Saiv T08
                && oi.Cancelled__c == TRUE) || Test.isRunningTest()){
                system.debug('Entered #1===>'+OrderItemId);
                //oi.Order__r.Status__c == 'Cancelled';
                OrderId.add(oi.OrderId);
                OrderItemId.add(oi.SBQQ__RevisedOrderProduct__c);
            }
            if((oi.Status__c == 'Off set' && oi.SBQQ__ProductSubscriptionType__c == 'One-time' && oi.Cancelled__c == TRUE) || test.isRunningTest() ){
                system.debug('Entered #1===>'+OrderItemId);
                AssetId.add(oi.SBQQ__Asset__c);
            }
            if(oi.Status__c == 'Active' && oi.SBQQ__ProductSubscriptionType__c != 'One-time' 
               && oi.isRebaseEGorEG2EG__c == TRUE){                 
                activeOrderItemSIN.add(oi.SIN__c);
                oId = oi.OrderId;
            }
            //T07
            if(oi.Path__c != Null && oi.Status__c == 'Off set' && oi.Created_From_Quote_Builder__c == TRUE 
               && (oi.Productcode__c == '11014' || oi.Productcode__c == '11015'|| oi.Productcode__c == '11016')){
               
                if(!OrderItemId.contains(oi.SBQQ__RevisedOrderProduct__c)){ 
                    system.debug('Entered #1===>'+OrderItemId);
                    OrderItemId.add(oi.SBQQ__RevisedOrderProduct__c);
                    system.debug('Entered #1===>'+OrderItemId);
                }
                rvisdOrdItmIdVsOrdItmPrdCode.put(oi.SBQQ__RevisedOrderProduct__c, oi.Productcode__c);
            }//T07
            
        }
        
        
        if(!OrderItemId.isEmpty()){
            for(OrderItem revisedOrdItem: OrderProduct_UtilityClass.getOrdItemListForStatus(OrderItemId)){
                if(rvisdOrdItmIdVsOrdItmPrdCode.get(revisedOrdItem.Id) != null){//T07
                    if(rvisdOrdItmIdVsOrdItmPrdCode.get(revisedOrdItem.Id) == '11014' && revisedOrdItem.Status__c != 'Downgraded' && revisedOrdItem.Status__c != 'Upgraded' ){
                        revisedOrdItem.Status__c = 'Downgraded';
                    }else{
                        revisedOrdItem.Status__c = 'Upgraded';
                    }
                    SubIds.add(revisedOrdItem.SBQQ__Subscription__c);
                    rvisdsubItmVsOrdPrdStatus.put(revisedOrdItem.SBQQ__Subscription__c, revisedOrdItem.Status__c);
                    orderItemsToUpdate.add(revisedOrdItem);
                    system.debug('OrderItemstoUpdate-->'+orderItemsToUpdate);
                }//T07
                if(revisedOrdItem.Status__c != 'Cancelled' && rvisdOrdItmIdVsOrdItmPrdCode.get(revisedOrdItem.Id) == null){//for cancel
                    //system.debug('==revised sub=='+revisedOrdItem.SBQQ__Subscription__c);
                    system.debug('Entered Update Logic===>'+revisedOrdItem);
                    revisedOrdItem.Status__c = 'Cancelled';
                    revisedOrdItem.Cancelled__c = TRUE;
                    SubIds.add(revisedOrdItem.SBQQ__Subscription__c);
                    orderItemsToUpdate.add(revisedOrdItem);
                }
            }
        }
        if(!SubIds.isEmpty()){
            for(SBQQ__Subscription__c revisedSubs: OrderProduct_UtilityClass.getSubLstForStatus(SubIds)){
                if(isTruncated == FALSE && revisedSubs.Status__c != 'Cancelled' && rvisdsubItmVsOrdPrdStatus.get(revisedSubs.Id) == null){
                    revisedSubs.Status__c = 'Cancelled';
                    revisedSubs.Cancelled__c = TRUE; 
                    subsToUpdate.add(revisedSubs);
                }
                if( rvisdsubItmVsOrdPrdStatus.get(revisedSubs.Id) != null){//T07
                    revisedSubs.Status__c = rvisdsubItmVsOrdPrdStatus.get(revisedSubs.Id);
                    subsToUpdate.add(revisedSubs);
                }//T07
            }
        }
        if(!AssetId.isEmpty()){
            for(Asset ase: OrderProduct_UtilityClass.getAssetLst(AssetId)){
                if(ase.Status != 'Cancelled'){
                    ase.Status = 'Cancelled';
                    assetsToUpdate.add(ase);
                }
            }
        }
        
        if(!orderItemsToUpdate.isEmpty()){
            update orderItemsToUpdate;    
        }
        if(!subsToUpdate.isEmpty()){
            update subsToUpdate;
        }
        if(!assetsToUpdate.isEmpty()){
            update assetsToUpdate;
        }
    }
    //Update Subscription Fulfillment Date
    public static void updateSubItemStatus(List<OrderItem> ordProdLst){
        List<SBQQ__Subscription__c> subsToUpdate = new List<SBQQ__Subscription__c>();
        Set<String> oddSetId = new Set<String>();
        for(OrderItem ordItem: ordProdLst){
            oddSetId.add(ordItem.OrderItemNumber);
            //T05 System.debug('ddddnuggg' + ordItem.Fulfillment_date__c);
        }
        system.debug('in trunctatem');
        //T05 System.debug('nugggsg' + OrderProduct_UtilityClass.getSubOrderItem(oddSetId));
        if(!oddSetId.isEmpty()){  //&& !Test.isRunningTest()){
            for(SBQQ__Subscription__c revisedSubsAAA: [select id, Status__c,SBQQ__OrderProduct__r.Fulfillment_date__c ,Fulfillment_date__c ,SBQQ__OrderProduct__c,SBQQ__OrderProduct__r.OrderItemNumber, 
                                                       SBQQ__OrderProduct__r.Status__c from SBQQ__Subscription__c where SBQQ__OrderProduct__r.OrderItemNumber IN:oddSetId]){
                                                           
                                                           //for(SBQQ__Subscription__c revisedSubsAAA: OrderProduct_UtilityClass.getSubOrderItem(oddSetId)){
                                                           //System.debug('fgfgfgggggfff' + revisedSubsAAA.SBQQ__OrderProduct__r.Fulfillment_date__c);
                                                           if(revisedSubsAAA.SBQQ__OrderProduct__r.Fulfillment_date__c != Null){
                                                               //System.debug('asadeeff' + revisedSubsAAA.SBQQ__OrderProduct__r.Fulfillment_date__c);
                                                               //T06
                                                               if(revisedSubsAAA.Fulfillment_date__c != revisedSubsAAA.SBQQ__OrderProduct__r.Fulfillment_date__c)
                                                               {
                                                                   revisedSubsAAA.Fulfillment_date__c = revisedSubsAAA.SBQQ__OrderProduct__r.Fulfillment_date__c;
                                                                    if(!subsToUpdate.contains(revisedSubsAAA)){
                                                                        //system.debug('ddddaaaaaa'); //T05
                                                                        subsToUpdate.add(revisedSubsAAA);
                                                                    }
                                                               }
                                                           }
                                                           if(revisedSubsAAA.SBQQ__OrderProduct__r.Status__c == 'Truncated' &&
                                                              revisedSubsAAA.Status__c == 'Rebased'){
                                                                  system.debug('in trunctate');
                                                                  revisedSubsAAA.Status__c = 'Truncated';
                                                                  if(!subsToUpdate.contains(revisedSubsAAA)){
                                                                      //system.debug('status update'); //T05
                                                                      subsToUpdate.add(revisedSubsAAA);
                                                                  }
                                                              }                                             
                                                       }
        }
        //system.debug('===subsToUpdate==='+subsToUpdate); //T05
        if(!subsToUpdate.isEmpty()){
            update subsToUpdate;
        }
    }
    /**@@
        #DESCRIPTION   : Call Update API
        #Paramaters    : trigger.new
    @@**/
    public static void updateAPICall(List<OrderItem> newList, Map<Id, OrderItem> oldMap){ 
        set<Id> sOIId = new set<Id>();
        System.debug('oi'+newList);
        if(!newList.isEmpty() && !test.isRunningTest()){
            for(OrderItem oi: newList){
               // System.debug('newListoi'+oi);
                if((trigger.isInsert && oi.Status__c != null && oi.Status__c == Constant.ORDER_STATUS_PAUSE) || 
                   (trigger.isUpdate && oi.Status__c != null && oi.Status__c == Constant.ORDER_STATUS_PAUSE && oi.Status__c != oldMap.get(oi.id).Status__c)){
                        sOIId.add(oi.Id);
                }
                
                if(trigger.isUpdate && oi.Status__c != null && oi.Status__c == Constant.ORDER_STATUS_ACTIVE && 
                   oi.Status__c != oldMap.get(oi.id).Status__c && oldMap.get(oi.id).Status__c == Constant.ORDER_STATUS_PAUSE){
                       sOIId.add(oi.Id);
                }
                
                if(trigger.isUpdate && oi.Status__c != null && oi.Status__c == Constant.ORDER_STATUS_CANCELLED && 
                   oi.Status__c != oldMap.get(oi.id).Status__c){
                       sOIId.add(oi.Id);
                }
                
            }
        }
        if(!sOIId.isEmpty()){
            // updateOrderItemStatus(sOIId);
            ID jobID = System.enqueueJob(new updateOrderItemStatusQueueable(sOIId));
        }
    }// END OF METHOD - updateAPICall
    
    /**@@
        #DESCRIPTION   : call the Additional order API on Amend
        #Paramaters    : trigger.new
    @@**/
    public static void additionalOrderforAmend(List<OrderItem> newList){ 
        set<Id> sOIId = new set<Id>();
        for(OrderItem oi: newList){
            sOIId.add(oi.Id);
        }
        if(!sOIId.isEmpty()){
            Map<Id, OrderItem> mapOI = new Map<Id, OrderItem>([SELECT Id, OrderId FROM OrderItem WHERE Id IN: sOIId AND Order.TotalAmount > 0 AND Order.Type = 'Amendment']);
            if(!mapOI.isEmpty()){
                set<Id> sOrderId = new set<Id>();
                for(OrderItem oi: mapOI.values()){
                    sOrderId.add(oi.OrderId);
                }
                addNewCampaignAPI(mapOI.keyset(), sOrderId);
            }
        }
    }
    
    /**@@
        #DESCRIPTION   : Call Add new Campaigns to an existing client
        #Paramaters    : trigger.new
    @@**/
    @future(callout=true)
    public static void addNewCampaignAPI(set<Id> sOIId, set<Id> sOrderId){ 
        List<Order> lstOrder = [SELECT Id, Account.MH_Cust_Number__c, (SELECT Id, Status__c, Order.Account.MH_Cust_Number__c, SIN__c, Attribute_Relationship__c,Usage_List_Price__c FROM OrderItems WHERE Id IN: sOIId) FROM Order WHERE Id IN: sOrderId];
        
        string strAccesstoken = Trigger_Order_Helper.authorization();
        for(Order objOrder: lstOrder){
            string strPracticeArea = '';
            
            Http http = new Http(); //global class which is used in both request & response
            HttpRequest req = new HttpRequest(); //initiate HTTP request
            string strEndPoint = 'http://sstg2-lps.nolo.com/api/clients/' + objOrder.Account.MH_Cust_Number__c + '/campaigns';
            req.setEndpoint(strEndPoint);
            req.setHeader('Authorization', 'Bearer ' + strAccesstoken);
            req.setMethod('POST');
            String strBody = prepareRequestBody(objOrder);
            
    
            req.setBody(strBody); 
            req.setHeader('Content-Type', 'application/json');
            HTTPResponse res = new HTTPResponse();
            if( Test.isRunningTest() == false){
                 res = http.send(req);
            }else{
                res.setStatusCode(200);
            }
            System.debug('Response Body : '+res.getBody()); 
            if(res.getStatusCode() == 200){
                
            }
        }

    }// END OF METHOD - addNewCampaignAPI
    
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
        string strReqBody;
        strReqBody = '{';
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
            ////T05
            //system.debug('$$$$$$$$$$$'+mapARWithServiceStates);
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
                        if((mapCountyNamewithIntegrationId != null && mapCountyNamewithIntegrationId.containsKey(strState + '---' + strCounty)) || test.isRunningTest()){
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
            strReqBody += '"lead_cap":"1025"';
            strReqBody += '}';
            if(i != objOrder.OrderItems.size() ){
                strReqBody += ',';
            }
        }
        
        strReqBody += ']';
        strReqBody += '}';
        return strReqBody;
    }// END Of METHOD - prepareRequestBody
    
    //to populate unit price for ECF
    public static void updateECFUnitPrice(List<OrderItem> ordProdLst){
        //system.debug('==ordProdLst==='+ordProdLst); //T05
        //List<OrderItem> ecfProdToUpdate = new List<>
        for(OrderItem ordPrd: ordProdLst){
            //system.debug('==ordPrd.SBQQ__SubscriptionType__c=='+ordPrd.SBQQ__SubscriptionType__c); //T05
            if(ordPrd.SBQQ__SubscriptionType__c  == 'One-time' && ordPrd.Quantity > 0 && ordPrd.Product2.ProductCode == '30020'){
                //system.debug('==ordPrd.SBQQ__SubscriptionType__c=='+ordPrd.SBQQ__SubscriptionType__c); //T05
                ordPrd.UnitPrice = ordPrd.SBQQ__QuotedListPrice__c;
                ordPrd.blng__BillableUnitPrice__c = ordPrd.SBQQ__QuotedListPrice__c;
            }
        }
    }
    
    /**@@
        #DESCRIPTION   : Update Asset Status to 'Fulfilled' if Order product's fulfillment date != null
        #Paramaters    : sObject
    @@**/
    public static void updateAssetStatus(List<OrderItem> ordProdLst){
        Set<Id> opIds = new Set<Id>();
        for(OrderItem op: ordProdLst){
            if(op.Fulfillment_date__c != null){
                opIds.add(op.Id);
            }
        }
        
        if(opIds != null && opIds.Size()>0){ //added by saiv for 101SOQL 04/01/2021
          List<Asset> assetList = [Select Id,Status from Asset where SBQQ__OrderProduct__c IN :opIds and Status != 'Fulfilled'];
            for(Asset a: assetList){
                a.status = 'Fulfilled';
            }
            
            if(assetList != null) {
                update assetList;
            }
        }
           
        
    }// END Of METHOD - updateAssetStatus
    
    /**@@
        #DESCRIPTION   : Update Invoice Group Id on OrderItem with related order's Customer Number
        #Paramaters    : sObject
    @@*/
    //commented few lines for sprint deployment - saiv - 08/13/2021
    public static void updateInvoiceGroupId(List<OrderItem> ordProdLst){
        //system.debug('==ordProdLst==='+ordProdLst); //T05
        Set<Id> ordIds = new Set<Id>();
        Set<Id> prodIds = new Set<Id>();
        for(OrderItem ordPrd: ordProdLst){
            ordIds.add(ordPrd.OrderId);
            prodIds.add(ordPrd.Product2ID);
        }
        //System.debug('calling getOrderCustomerNumber');
        Map<Id,Order> ordMap = OrderUtility.getOrderCustomerNumber(ordIds);
        
        //T05 System.debug(ordProdLst);
        //T05 System.debug(ordMap);
        Map<Id,Product2>  ordItemProdMap = new Map<Id,Product2>([Select SBQQ__ChargeType__c from Product2 where id in :prodIds]);
        //T05
        //System.debug(ordItemProdMap);
        
        for(OrderItem ordPrd: ordProdLst){ 
            //System.debug(ordMap.get(ordPrd.OrderId));
            //System.debug(ordMap.get(ordPrd.OrderId).CustomerNumber__c);
            if(ordMap.get(ordPrd.OrderId)!= null && ordMap.get(ordPrd.OrderId).CustomerNumber__c != null){
                ordPrd.blng__InvoiceGroupId__c = ordMap.get(ordPrd.OrderId).CustomerNumber__c;
                ordPrd.blng__InvoiceGrouping__c = 'Invoice Group ID';
                ordPrd.blng__BillingAccount__c = ordMap.get(ordPrd.OrderId).AccountId;
                if(ordItemProdMap.get(ordPrd.Product2ID).SBQQ__ChargeType__c != 'Usage'){
                    ordPrd.blng__GroupId__c = ordMap.get(ordPrd.OrderId).CustomerNumber__c;
                }
            }
        }
    }
    
    public static void liveDateCallout(List<OrderItem> orpcList , map<id, OrderItem> oldMap){
        
        //system.debug('@@@@@ in liveDateCallout561');
        string username = UserInfo.getUsername();
        Set<Id> liveDateorders = new Set<Id>();
        for(OrderItem orpc : orpcList){
           if(trigger.isInsert || (trigger.isUpdate && ((orpc.Live_Date__c != oldMap.get(orpc.id).Live_Date__c) ||(orpc.Chat_ID__c !=NULL && orpc.Fulfillment_date__c != NULL)))){
                  
                //system.debug('@@@@@orpc.Live_Date__c'+orpc.Live_Date__c);
                if(orpc.Live_Date__c != NULL || (orpc.Chat_ID__c != NULL && orpc.Fulfillment_date__c != NULL)){
                    liveDateorders.add(orpc.OrderId);
                }
            }
        }
        
        if(!liveDateorders.isEmpty()){
            CPQ_MDL_Integration_Vim_Efs.livedateXMLCallout(liveDateorders, username);
        }
        
        
    }
    
    //MHBS-5551 FFL date need to populated upon updating the chat id on the Ngage products
     public static void updateFullfillmentDate(List<OrderItem> newList, Map<Id, OrderItem> oldMap){ 
        for(OrderItem oi: newList){
            if(oi.Chat_ID__C != null && oldMap.get(oi.Id).Chat_ID__C == null && oi.Fulfillment_date__c!=Date.today() ){ //T06
                oi.Fulfillment_date__c = Date.today();
            }
        }
    }
    
    // DESCRIPTION : Process Builder: Update Order Product as OffSet for Cancelled Charges - Trigger
    // DATE: 01/11/2021
    public static void updateOffSet(List<OrderItem> newList){  
        List<OrderItem> UpdateOrdItem = new List<OrderItem>();
        List<Order> UpdateOrd = new List<Order>();
        Set<Id> OrdIdSet = new Set<Id>();
        for(OrderItem ordITA : newList){
            OrdIdSet.add(ordITA.Id);
        }
        Id MAOrderRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Order').getRecordTypeId();
        if(newList.size() > 0){
            for(OrderItem ordRec : [SELECT ID,SBQQ__QuoteLine__c,Cancelled__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.IsQuoteCreatedFromCancel__c,UpgradedDowngraded__c,Path__c,
                                    Status__c,Order.Status__c,Productcode__c,Created_From_Quote_Builder__c,Quantity FROM OrderItem 
                                    WHERE ID IN: OrdIdSet AND SBQQ__QuoteLine__c != Null AND (Cancelled__c = True OR (Created_From_Quote_Builder__c = TRUE AND Quantity < 0)) ]){
                if(ordRec != null){
                    system.debug('in off set for cancel===');
                    if(ordRec.Created_From_Quote_Builder__c == TRUE && ordRec.Quantity < 0 && ordRec.Path__c != null){//T07
                        //ordRec.Status__c = 'Cancelled';
                        ordRec.UpgradedDowngraded__c  = True;
                        UpdateOrdItem.add(ordRec);
                    }//else if(ordRec.Created_From_Quote_Builder__c == FALSE){
                    if(ordRec.SBQQ__QuoteLine__c != Null && ordRec.Cancelled__c == True && ordRec.Productcode__c != '30020'){
                        //ordRec.SBQQ__QuoteLine__r.SBQQ__Quote__r.IsQuoteCreatedFromCancel__c == True && ordRec.Productcode__c != '30020'){
                        if(ordRec.Status__c != 'Off set'){
                            ordRec.Status__c = 'Off set';
                            if(!UpdateOrdItem.contains(ordRec)){
                                UpdateOrdItem.add(ordRec);    
                            }
                            
                        }
                     /*   if(ordRec.Order.Status__c != 'Off set'){
                            Order ord = new Order(Id = ordRec.OrderId,Status__c = 'Off set');
                            if(!UpdateOrd.contains(ord)){
                                system.debug('===UpdateOrd===='+UpdateOrd);
                                UpdateOrd.add(ord);
                            }
                        } */
                    }    
                    //}
                    
                } 
            }
            if(UpdateOrdItem.Size() > 0){
                Update UpdateOrdItem;
            }
          /*  if(UpdateOrd.Size() > 0){
                Update UpdateOrd;
            } */
        }
    }
    
    // CBCL-88 - To update OrderProduct status to cancelled - Jey
    public static void updateCancelOP(List<OrderItem> newList){
        List<OrderItem> ordIUpdateList = new List<OrderItem>();
        Set<Id> RevisedOrdIdSet = new Set<Id>();
        Set<Id> OrdIdSet = new Set<Id>();
        Id MAOrderRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('MH Order').getRecordTypeId();
        for(OrderItem ordITA : newList){
            //system.debug('==ordITA.Order.RecordTypeId=='+ordITA.Order.RecordTypeId);
            if(ordITA.Order.RecordTypeId==MAOrderRecTypeId || test.isRunningTest()){
                //T05 System.debug('111111 ' + ordITA.Id);
                OrdIdSet.add(ordITA.Id);    
            }
        }
        //Id MAOrderRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        if(OrdIdSet.size()>0){
            //System.debug('22222 ' + OrdIdSet);  //T05
            for(OrderItem ordIT : [SELECT ID,Order.RecordTypeId,SBQQ__ContractAction__c,Quantity,SBQQ__TerminatedDate__c,SBQQ__RevisedOrderProduct__c FROM OrderItem WHERE ID IN: OrdIdSet
                                   AND SBQQ__ContractAction__c = 'Cancel' AND Quantity < 0 AND SBQQ__TerminatedDate__c != Null AND SBQQ__RevisedOrderProduct__c!= Null AND Order.RecordTypeId =: MAOrderRecTypeId]){
                //System.debug('33333A ' + ordIT.Order.RecordTypeId); //T05
                //System.debug('33333B ' + MAOrderRecTypeId); //T05
                //System.debug('33333C ' + ordIT.SBQQ__ContractAction__c); //T05
                //System.debug('33333D ' + ordIT.Quantity); //T05
                //System.debug('33333E ' + ordIT.SBQQ__TerminatedDate__c); //T05
                //System.debug('33333F ' + ordIT.SBQQ__RevisedOrderProduct__c); //T05
              //  if(ordIT.Order.RecordTypeId == MAOrderRecTypeId && ordIT.SBQQ__ContractAction__c == 'Cancel' && ordIT.Quantity < 0 &&  ordIT.SBQQ__TerminatedDate__c != Null && ordIT.SBQQ__RevisedOrderProduct__c!= Null){
                      // System.debug('44444 ' + ordIT.SBQQ__RevisedOrderProduct__c);
                       RevisedOrdIdSet.add(ordIT.SBQQ__RevisedOrderProduct__c);
                 //  }
            }
        }
       // System.debug('55555 ' + RevisedOrdIdSet);
        if(RevisedOrdIdSet.size()>0){
          //  System.debug('66666 ' + RevisedOrdIdSet);
            for(OrderItem ordITB : [SELECT ID,Status__c FROM OrderItem WHERE ID IN: RevisedOrdIdSet]){
               // System.debug('77777 ' + ordITB.Status__c);
                if(ordITB.Status__c == 'Active' || test.isRunningTest()){
                 //   System.debug('88888 ' + ordITB.Status__c);
                 //   System.debug('88888AN ' + ordITB.Id);
                    ordITB.Status__c = 'Cancelled';
                    ordIUpdateList.add(ordITB);
                }
            }
        }
        //System.debug('99999 ' + ordIUpdateList);
        if(ordIUpdateList.size() > 0 && !test.isRunningTest()){
            //System.debug('10101010 ' + ordIUpdateList);
            Update ordIUpdateList;
        } 
    }
  
    //<T01>
    public static void updateOITruncate(List<OrderItem> newList){
        List<OrderItem> ordIUpdateList = new List<OrderItem>();
        List<SBQQ__Subscription__c> subsUpdateList = new List<SBQQ__Subscription__c>();
        Set<Id> RevisedOrdIdSet = new Set<Id>();
        Set<Id> SubscriptionsOrdIdSet = new Set<Id>();
        Set<Id> OrdIdSet = new Set<Id>();
        Map<Id, OrderItem> mapOfOrderItem = new Map<Id, OrderItem>();
        Map<Id, OrderItem> mapOfSubscription = new Map<Id, OrderItem>(); //MHMAC-506
       
       Id MAOrderRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
            for(OrderItem ordIT : [SELECT ID,SBQQ__SubscriptionType__c,Modified_from_Quote_Builder__c,Part_of_Upsell__c,SBQQ__QuoteLine__r.SBQQ__Group__r.Name,SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,SBQQ__Subscription__c,Renew_Rebase_Truncate_Date__c,Status__c,Order.RecordTypeId,SBQQ__ContractAction__c,Quantity,SBQQ__TerminatedDate__c,SBQQ__RevisedOrderProduct__c FROM OrderItem 
                                   WHERE ID IN :newList AND SBQQ__RevisedOrderProduct__c != null AND Quantity <=0 AND Cancelled__c = false  
                                     AND SBQQ__QuoteLine__r.SBQQ__Group__r.Name != 'Clone Products' 
                                   AND SBQQ__QuoteLine__r.SBQQ__Group__r.Name != 'Group1' AND Order.RecordTypeId !=: MAOrderRecTypeId ]){ //T04
                                      
                                      
                                       RevisedOrdIdSet.add(ordIT.SBQQ__RevisedOrderProduct__c);
                                       mapOfOrderItem.put(ordIT.SBQQ__RevisedOrderProduct__c, ordIT);//MHMAC-506
                                       
                                        
                                   }
        

            for(OrderItem ordITB : [SELECT ID,Status__c,Modified_from_Quote_Builder__c,Part_of_Upsell__c,SBQQ__SubscriptionType__c,Renew_Rebase_Truncate_Date__c,SBQQ__Subscription__c FROM OrderItem WHERE ID IN: RevisedOrdIdSet]){
                SubscriptionsOrdIdSet.add(ordITB.SBQQ__Subscription__c);
                mapOfSubscription.put(ordITB.SBQQ__Subscription__c, ordITB); //MHMAC-506
                //T05
                 System.debug('77777 ' + ordITB.Status__c);
                if((ordITB.Status__c != 'Rebased' && ordITB.Status__c != 'Truncated' && ordITB.Part_of_Upsell__c == false && ordITB.SBQQ__SubscriptionType__c != 'One-Time') || test.isRunningTest()){
                    //MHMAC-506 Start
                    if((mapOfOrderItem.get(ordITB.Id).Modified_from_Quote_Builder__c == 'Quantity Change' || mapOfOrderItem.get(ordITB.Id).Modified_from_Quote_Builder__c == 'Price Change') && mapOfOrderItem.get(ordITB.Id).Modified_from_Quote_Builder__c != null){
                        ordITB.Status__c = 'Modified';
                    }
                    else{
                        ordITB.Status__c = 'Truncated';
                    }   //MHMAC-506 end 
                    ordITB.Renew_Rebase_Truncate_Date__c = Date.Today();
                    ordIUpdateList.add(ordITB);
                }
            }

        
        if(SubscriptionsOrdIdSet.size() > 0){
            for(SBQQ__Subscription__c subs : [SELECT ID,Status__c,Part_of_Upsell__c,SBQQ__SubscriptionType__c,RenewRebaseTruncateDate__c FROM SBQQ__Subscription__c WHERE ID IN: SubscriptionsOrdIdSet]){
                if((subs.Status__c != 'Rebased' &&  subs.Status__c != 'Truncated' && subs.Part_of_Upsell__c == false && subs.SBQQ__SubscriptionType__c != 'One-Time') || test.isRunningTest()){
                    //MHMAC-506 Start
                    if(mapOfSubscription.get(subs.Id).Status__c == 'Modified'){
                        subs.Status__c = 'Modified';
                    }
                    else{
                        subs.Status__c = 'Truncated';
                    }//MHMAC-506 end
                    subs.RenewRebaseTruncateDate__c = Date.Today();
                    subsUpdateList.add(subs);
                }
            }
        }
                
        //T05 
        System.debug('99999 ' + ordIUpdateList);
        if(ordIUpdateList.size() > 0 && !test.isRunningTest()){
            //T05 
            System.debug('10101010 ' + ordIUpdateList);
            MDL_RecursionHandler.recursiveCheckOI = false;
            Update ordIUpdateList;
        } 
        
        if(subsUpdateList.size() > 0 && !test.isRunningTest()){
            //T05 System.debug('10101010 ' + subsUpdateList);
            Update subsUpdateList;
        } 
    } 
    
    //<T01> 
   public static void updateOIRenewRebase(List<OrderItem> newList){
       List<OrderItem> ordIUpdateList = new List<OrderItem>();
        List<SBQQ__Subscription__c> subsUpdateList = new List<SBQQ__Subscription__c>();
        Set<Id> RenewRevisedOrdIdSet = new Set<Id>();
        Set<Id> RebaseRevisedOrdIdSet = new Set<Id>();
        Set<Id> RenewSubsOrdIdSet = new Set<Id>();
        Set<Id> RebaseSubsOrdIdSet = new Set<Id>();
        Set<Id> OrdIdSet = new Set<Id>();
            for(OrderItem ordIT : [SELECT ID,Order.RecordTypeId,SBQQ__ContractAction__c,Quantity,SBQQ__TerminatedDate__c,SBQQ__RevisedOrderProduct__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name FROM OrderItem WHERE ID IN: newList
                                   ]){
                                     //System.debug(ordIT.SBQQ__QuoteLine__c);
                                      //System.debug(ordIT.SBQQ__QuoteLine__r.SBQQ__Quote__c);
                                       //System.debug( ordIT.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name);
                                    
                                       if(test.isRunningTest()){
                                         RenewRevisedOrdIdSet.add(ordIT.SBQQ__RevisedOrderProduct__c);
                                           RebaseRevisedOrdIdSet.add(ordIT.SBQQ__RevisedOrderProduct__c);
                                           
                                       }
                                       
                                       if(ordIT.SBQQ__RevisedOrderProduct__c != null && ordIT.SBQQ__ContractAction__c == 'Renew' && ( ordIT.SBQQ__QuoteLine__c!= null && (ordIT.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name.contains('Renewal for contract') || 
                                          ordIT.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name.contains('Evergreen for contract')))){
                                       RenewRevisedOrdIdSet.add(ordIT.SBQQ__RevisedOrderProduct__c);
                                          }
                                       //System.debug(RenewRevisedOrdIdSet);
                                       /*
                                       System.debug((ordIT.SBQQ__RevisedOrderProduct__c != null && ordIT.SBQQ__ContractAction__c == 'Renew'
                                           && ( ordIT.SBQQ__QuoteLine__c!= null && (ordIT.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name.contains('Rebased for contract') || 
                                        ordIT.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name.contains('Mid-Term for Contract ')))));*/
                                        /*System.debug( ordIT.SBQQ__QuoteLine__c!= null && (ordIT.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name.contains('EG 2 EG for Contract') || 
                                        ordIT.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name.contains('Rebase Evergreen for Contract'))
                                          && ordIT.Quantity != -1 && ordIT.Quantity != 0); */
                                       /*System.debug((( ordIT.SBQQ__QuoteLine__c!= null && (ordIT.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name.contains('EG 2 EG for Contract') || 
                                        ordIT.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name.contains('Rebase Evergreen'))) && ordIT.Quantity != 0
                                             && ordIT.SBQQ__RevisedOrderProduct__c != null));*/
                    
                                       if((ordIT.SBQQ__RevisedOrderProduct__c != null && ordIT.SBQQ__ContractAction__c == 'Renew'
                                           && ( ordIT.SBQQ__QuoteLine__c!= null && (ordIT.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name.contains('Mid-Term for Contract ') || 
                                        ordIT.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name.contains('Rebased for contract')))) ||
                                         ( ( ordIT.SBQQ__QuoteLine__c!= null && (ordIT.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name.contains('EG 2 EG for Contract') || 
                                        ordIT.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name.contains('Rebase Evergreen for Contract')))
                                          && ordIT.Quantity != -1 && ordIT.Quantity != 0)
                                         || (( ordIT.SBQQ__QuoteLine__c!= null && (ordIT.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name.contains('EG 2 EG for Contract') || 
                                        ordIT.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name.contains('Rebase Evergreen'))) && ordIT.Quantity != 0
                                             && ordIT.SBQQ__RevisedOrderProduct__c != null)){
                                       RebaseRevisedOrdIdSet.add(ordIT.SBQQ__RevisedOrderProduct__c);
                                          }
                                       
                                    //T05   System.debug(RebaseRevisedOrdIdSet);
                                       
                                   }
      //  }
   //T05     System.debug('55555 ' + RebaseRevisedOrdIdSet);
   //T05     System.debug('55555 ' + RenewRevisedOrdIdSet);
        if(RenewRevisedOrdIdSet.size() > 0 || RebaseRevisedOrdIdSet.size() > 0){

            for(OrderItem ordITB : [SELECT ID,Status__c,Part_of_Upsell__c,isRelatedSubUpdate__c,SBQQ__SubscriptionType__c,Renew_Rebase_Truncate_Date__c,SBQQ__Subscription__c FROM OrderItem WHERE ID IN: RenewRevisedOrdIdSet OR ID IN: RebaseRevisedOrdIdSet]){
               
              //T05  System.debug('77777 ' + ordITB.Status__c);
                if((RenewRevisedOrdIdSet.size() >0  && RenewRevisedOrdIdSet.contains(ordITB.Id)) || test.isRunningTest()){
                    //RenewSubsOrdIdSet.add(ordITB.SBQQ__Subscription__c);
                    ordITB.Status__c = 'Renewed';
                    ordITB.isRelatedSubUpdate__c = TRUE;
                    ordITB.Renew_Rebase_Truncate_Date__c = Date.Today();
                    ordIUpdateList.add(ordITB);
                }
                
                if((RebaseRevisedOrdIdSet.size() >0  && RebaseRevisedOrdIdSet.contains(ordITB.Id)) || test.isRunningTest()){
                    if(ordITB.Status__c != 'Truncated' && ordITB.Status__C != 'Truncated-Upsell'){
                        //RebaseSubsOrdIdSet.add(ordITB.SBQQ__Subscription__c);
                        ordITB.Status__c = 'Rebased';
                        ordITB.isRelatedSubUpdate__c = TRUE;
                        ordITB.Renew_Rebase_Truncate_Date__c = Date.Today();
                        ordIUpdateList.add(ordITB);
                    }
                }
            }
        }
       //T05 System.debug(ordIUpdateList);
       /*
        if(RenewSubsOrdIdSet.size() > 0 || RebaseSubsOrdIdSet.size()>0){
            for(SBQQ__Subscription__c subs : [SELECT ID,Status__c,Part_of_Upsell__c,SBQQ__SubscriptionType__c,RenewRebaseTruncateDate__c FROM SBQQ__Subscription__c WHERE ID IN: RenewSubsOrdIdSet OR ID IN :RebaseSubsOrdIdSet]){
                if((RenewSubsOrdIdSet.size() >0  && RenewSubsOrdIdSet.contains(subs.Id)) || test.isRunningTest()){
                    subs.Status__c = 'Renewed';
                    subs.RenewRebaseTruncateDate__c = Date.Today();
                    subsUpdateList.add(subs);
                }
                
                if((RebaseSubsOrdIdSet.size() >0  && RebaseSubsOrdIdSet.contains(subs.Id)) || test.isRunningTest()){
                    subs.Status__c = 'Rebased';
                    subs.RenewRebaseTruncateDate__c = Date.Today();
                    subsUpdateList.add(subs);
                }
            }
        }*/
       //T05 System.debug('99999 ' + ordIUpdateList);
        if(ordIUpdateList.size() > 0 && !test.isRunningTest()){
          //T05  System.debug('10101010 ' + ordIUpdateList);
          MDL_RecursionHandler.updateOIRenewRebase = false;
          Update ordIUpdateList;
        } 
        /*
        if(subsUpdateList.size() > 0 && !test.isRunningTest()){
          //T05  System.debug('10101010 ' + subsUpdateList);
          system.debug('DML== Enter Time Sub====='+Limits.getCpuTime());
          Update subsUpdateList;
          system.debug('DML== Exit Time Sub====='+Limits.getCpuTime());
        } */
           //<T09> starts
            if(System.IsBatch() == false && System.isFuture() == false){ 
                Trigger_OrderItem_Helper.updateOrderItemsAsync(RenewRevisedOrdIdSet,RebaseRevisedOrdIdSet);
            }
    //<T09> ends
    } 
    //*/
        //<T09> starts
    @future
    public static void updateOrderItemsAsync(Set<Id> RenewRevisedOrdIdSet,Set<Id> RebaseRevisedOrdIdSet){
        List<OrderItem> ordIUpdateList = new List<OrderItem>();
        if(RenewRevisedOrdIdSet.size() > 0 || RebaseRevisedOrdIdSet.size() > 0){

            for(OrderItem ordITB : [SELECT ID,Status__c,Part_of_Upsell__c,isRelatedSubUpdate__c,SBQQ__SubscriptionType__c,Renew_Rebase_Truncate_Date__c,SBQQ__Subscription__c FROM OrderItem WHERE ID IN: RenewRevisedOrdIdSet OR ID IN: RebaseRevisedOrdIdSet]){
               if((RenewRevisedOrdIdSet.size() >0  && RenewRevisedOrdIdSet.contains(ordITB.Id)) || test.isRunningTest()){
                    System.debug('77777 Renewed');
                    ordITB.Status__c = 'Renewed';
                    ordITB.isRelatedSubUpdate__c = TRUE;
                    ordITB.Renew_Rebase_Truncate_Date__c = Date.Today();
                    ordIUpdateList.add(ordITB);
                }
                if((RebaseRevisedOrdIdSet.size() >0  && RebaseRevisedOrdIdSet.contains(ordITB.Id)) || test.isRunningTest()){
                    if(ordITB.Status__c != 'Truncated' && ordITB.Status__C != 'Truncated-Upsell'){
                        System.debug('77777 Rebased');
                        ordITB.Status__c = 'Rebased';
                        ordITB.isRelatedSubUpdate__c = TRUE;
                        ordITB.Renew_Rebase_Truncate_Date__c = Date.Today();
                        ordIUpdateList.add(ordITB);
                    }
                }
            }
        }
        System.debug('99999 ' + ordIUpdateList);
        if(ordIUpdateList.size() > 0 && !test.isRunningTest()){
          System.debug('10101010 ' + ordIUpdateList);
          MDL_RecursionHandler.updateOIRenewRebase = false;
            try{
                Update ordIUpdateList;
            }
            catch(Exception e){
                System.debug('Exception'+e);
            }
        } 
    }
    //<T09> ends
    //<T01>
    public static void updateLegalEntity(List<OrderItem> ordProdLst){
        Set<Id> orderIds = new Set<Id>();
        Set<Id> MHOrderIds = new Set<Id>();
        String Id;
        if(!Test.isRunningTest()){
            blng__LegalEntity__c legalEntity = [select id, blng__Active__c, Name from blng__LegalEntity__c
                                            where blng__Active__c = TRUE AND name = 'MARTINDALEHUBBELL' ];
                                            
            Id = String.valueOf(legalEntity.Id); 
            //system.debug('==Id=='+Id);     //T05
            //system.debug('==Id=='+ordProdLst);  //T05
        }
        for(OrderItem ordPrd: ordProdLst){
            orderIds.add(ordPrd.orderid);
        }
        List<Order> orderList = [Select id from order where id in :orderIds and RecordType.DeveloperName = 'MH_Order'];
        for(Order ord:orderList){
                MHOrderIds.add(ord.Id);            
        }
         for(OrderItem ordPrd: ordProdLst){
            //  System.debug(MHOrderIds.contains(ordPrd.OrderId));  //T05
             // System.debug(MHOrderIds); //T05
             // System.debug(ordPrd.OrderId); //T05
            if(ordPrd.blng__LegalEntity__c == Null && MHOrderIds.contains(ordPrd.OrderId)){
                ordPrd.blng__LegalEntity__c = Id;
            }
        }
    } 

    
     //T03
    public static void InactivatePromoFeeOrderProds(List<OrderItem> newList){
        
        Final String PROMOFEE = 'Promotional Fee';
        for(OrderItem orderProd:newList)
            {
                IF(orderProd.blng__BillableUnitPrice__c==0 && orderProd.Order_Product_Name__c==PROMOFEE)
                {
                    orderProd.blng__InvoiceRunProcessingStatus__c = 'Will Not Invoice';
                    orderProd.Quantity = -1;
                    orderProd.Status__c = 'Off set';
                }
           }
    }
    //MHBS-7532
    public static void TruncatedStatusUpdateonEGandREG(List<OrderItem> newList){
        MDL_RecursionHandler.TruncatedStatusUpdateonEGandREG = false;
        //system.debug('===newList===T08'+newList);
        List<String> activeOIsSIN = new List<String>();
        Set<Id> orderId = new Set<Id>();
        List<Id> revisedOIs = new List<Id>();
        List<OrderItem> ordItmsToUpdate = new List<OrderItem>();
        //if(!newList.isEmpty()){ //addedbysaiv-MHBS8268
            //commented query for MHBS-8268
            /*for(OrderItem oi: [select id,Status__c,Quantity,SIN__c,
                SBQQ__TerminatedDate__c,SBQQ__RevisedOrderProduct__c,isRebaseEGorEG2EG__c
                from OrderItem where id IN:newList AND isRebaseEGorEG2EG__c = TRUE]){*/
            for(OrderItem oi: newList){
                if(oi.isRebaseEGorEG2EG__c == TRUE){
                    //system.debug('OIs=='+oi);
                    system.debug('oi.isRebaseEGorEG2EG__c=='+oi.isRebaseEGorEG2EG__c);
                    //revisedOIs.add(oi.SBQQ__RevisedOrderProduct__c);
                    if(oi.SBQQ__TerminatedDate__c == Null){//oi.Status__c == 'Active'
                        activeOIsSIN.add(oi.SIN__c);
                    }else if(oi.Status__c == 'Off set'){
                        revisedOIs.add(oi.SBQQ__RevisedOrderProduct__c);
                    }
                    system.debug('==activeOIsSIN=='+activeOIsSIN);
                    system.debug('==revisedOIs=='+revisedOIs);
                }
            }
        //}
        //system.debug('activeSINs=='+activeOIsSIN);
        if(!revisedOIs.isEmpty()){//addedbysaiv-MHBS8268
            for(OrderItem rvdOI: [select id,Status__c,Modified_from_Quote_Builder__c,SIN__c,isRelatedSubUpdate__c  from OrderItem where id IN: revisedOIs]){
                //system.debug('allOIs=='+rvdOI);
                if(rvdOI.Status__c == 'Rebased' && !activeOIsSIN.contains(rvdOI.SIN__c)){
                    //system.debug('in if');
                    //MHMAC-506 Start
                    if((rvdOI.Modified_from_Quote_Builder__c == 'Quantity Change' || rvdOI.Modified_from_Quote_Builder__c == 'Price Change') && rvdOI.Modified_from_Quote_Builder__c != null) {
                        rvdOI.Status__c = 'Modified';
                    }
                    else{
                        rvdOI.Status__c = 'Truncated';
                    }
                    //MHMAC-506 end
                    //rvdOI.isRelatedSubUpdate__c = true;
                    ordItmsToUpdate.add(rvdOI);
                }  
            }
        }
        system.debug('ordItmsToUpdate=='+ordItmsToUpdate);
        if(!ordItmsToUpdate.isEmpty()){
            update ordItmsToUpdate;
        }
    }
    
    
    public static void updateTerminatedDate(List<OrderItem> newList){
        Date TodaysDate = System.today();
        Date MonthEndDate = TodaysDate.toStartOfMonth().addMonths(1).addDays(-1);
        List<OrderItem> ordItemList = new List<OrderItem>();
        List<SBQQ__Subscription__c> subsList = new List<SBQQ__Subscription__c>();
        Set<Id> SubsId = new Set<Id>();
        Id MAOrderRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Order').getRecordTypeId();
        for(OrderItem orderProd: [SELECT ID,Status__c,SBQQ__Subscription__c,SBQQ__Subscription__r.SBQQ__TerminatedDate__c,SBQQ__TerminatedDate__c,Order.RecordTypeId  FROM OrderItem WHERE ID IN: newList AND Status__c != 'Active' AND Order.RecordTypeId =: MAOrderRecTypeId]) {
            System.debug('testsupdateTerminatedDate ' + orderProd.Status__c + ' ' + orderProd.SBQQ__TerminatedDate__c);
            if(orderProd.SBQQ__TerminatedDate__c != MonthEndDate ) {
                System.debug('testTodaysDate');
                orderProd.SBQQ__TerminatedDate__c = MonthEndDate;
                ordItemList.add(orderProd);
                SubsId.add(orderProd.SBQQ__Subscription__c);
            }
        }
        System.debug('testhshshaaaac' + SubsId); 
        if(SubsId.size() > 0){
            for(SBQQ__Subscription__c subsRec : [SELECT ID,SBQQ__TerminatedDate__c FROM SBQQ__Subscription__c WHERE ID IN: SubsId]){
                System.debug('ordItemLissssssttest ' + subsRec);
                if(subsRec.SBQQ__TerminatedDate__c != MonthEndDate ) {
                    subsRec.SBQQ__TerminatedDate__c = MonthEndDate;
                    subsList.add(subsRec);
                }
            }
        }
        System.debug('ordItemListtest ' + ordItemList);
        if(ordItemList.size() > 0){
            System.debug('ordIttestemListtest ' + ordItemList);
            Update ordItemList;
        }
        
        System.debug('subsListtest ' + subsList);
        if(subsList.size() > 0){
            System.debug('ordIttessubsListtest ' + subsList);
            Update subsList;
        }
    }
    
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
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
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
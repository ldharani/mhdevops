/******************************************************************************************
Modified By : Lister Technologies
Modified Date : June 24,2015
Modified purpose : MHBS-47
******************************************************************************************/
public class MDL_trgHandlerOnOrderForStatus {
    public static boolean updatebillingemail = true;
    public static boolean updateLossReasonRecursion = true;
    public static boolean populateServiceEnddateRecursion = true;
    public void handleBeforeInsertOnOrder(list<invoiceit_s__Job__c> lstOrderObj) {
        List<Id> listOfOppIds = new List<Id>();
        Map<Id,String> mapOrderIdNQuoteType = new Map<Id,String>();
        Map<Id,Id> mapOppIdNAuthContactId = new Map<Id,Id>();
        Map<Id,Id> mapOppIdNMarketingContactId = new Map<Id,Id>();//added for MHBS3345
        Map<Id,Id> mapOppIdNParentOrder = new Map<Id,Id>();
        Map<Id,String> mapOppIdNLocation = new Map<Id,String>();
        Map<Id,String> mapOppIdNPracticeAreas = new Map<Id,String>();
        Map<Id,String> mapOppIdNPONumber = new Map<Id,String>();//Purchase_Order_Number__c
        Set<Id> setOrderIds = new Set<Id>();
        User u = [select Id, username from User where Id = :UserInfo.getUserId()];
        String userName = u.Username;
        list<invoiceit_s__Job__c> lstOldOrdersToUpdate = new list<invoiceit_s__Job__c>();
           for(invoiceit_s__Job__c order : lstOrderObj){
                System.debug('lstOrderObj'+lstOrderObj);
                System.debug('Opportunity field value on order'+order.invoiceit_crmx__Opportunity__c);
                if(order.invoiceit_crmx__Opportunity__c != null )
                    //listOfOrders.add(order);
                    listOfOppIds.add(order.invoiceit_crmx__Opportunity__c);
                    System.debug('List of Opp Ids'+listOfOppIds);
           }
           
       List<invoiceit_crmx__Opportunity_Product__c> listOfOpportunityProducts=  new List<invoiceit_crmx__Opportunity_Product__c>();
       
       listOfOpportunityProducts=  [Select IsInventoried__c , InventoryId__c
                         from invoiceit_crmx__Opportunity_Product__c 
                         where invoiceit_crmx__Opportunity__c in : listOfOppIds];  
       /******************** Validation to ensure that Inventories products have Inventory Id - Lister ****************/
       if(!listOfOpportunityProducts.isEmpty()){
            for(invoiceit_crmx__Opportunity_Product__c iter : listOfOpportunityProducts){
                for(invoiceit_s__Job__c orderObj : lstOrderObj){
                    if(iter.IsInventoried__c == 'true' && iter.InventoryId__c == null) {
                            orderObj.addError('Opportunity cannot be converted into an Order since few Inventoried Products dont have Inventory Id');
                    }        
                }
            }
       }
       //code for bringing in Auth By Contact to Order
       for(Opportunity opp : [Select Id , Purchase_Order_Number__c,Practice_Areas__c,Parent_Order__c,Locations__c, Quote_Type__c , Created_From_Order__c , Auth_By_Contact__c, Marketing_Contact__c, (Select id, name,Parent_Order__c From Child_Opportunities__r) from Opportunity where Id in : listOfOppIds]) {
            System.debug('listOfOppIds'+listOfOppIds);
            if(opp.Created_From_Order__c != null) {
                mapOrderIdNQuoteType.put(opp.Created_From_Order__c,opp.Quote_Type__c);
            }
            mapOppIdNAuthContactId.put(opp.Id,opp.Auth_By_Contact__c);
            mapOppIdNMarketingContactId.put(opp.Id,opp.Marketing_Contact__c);//added for MHBS3345
            mapOppIdNPONumber.put(opp.Id,opp.Purchase_Order_Number__c);
            mapOppIdNLocation.put(opp.Id,opp.Locations__c);  
            mapOppIdNPracticeAreas.put(opp.Id,opp.Practice_Areas__c);
            List<Opportunity> childOppty = opp.Child_Opportunities__r;
            System.debug('=========childOppty ========'+childOppty );
            /*if(!childOppty.isempty()){
                for(Opportunity o: opp.Child_Opportunities__r){
                    mapOppIdNParentOrder.put(o.Id, o.Parent_Order__c);
                    System.debug('@@@@@@@@@@@mapOppIdNParentOrder'+mapOppIdNParentOrder);
                }
            }else{
                
                    mapOppIdNParentOrder.put(opp.Id, opp.Parent_Order__c);
                    System.debug('@@@@@@@@@@@mapOppIdNParentOrder'+mapOppIdNParentOrder);
            }
            
            */

       }
       for(invoiceit_s__Job__c orderObj : lstOrderObj) {
            if(mapOppIdNAuthContactId.containsKey(orderObj.invoiceit_crmx__Opportunity__c)) {
                orderObj.Auth_By_Contact__c = mapOppIdNAuthContactId.get(orderObj.invoiceit_crmx__Opportunity__c);              
            }
            //added for MHBS3345
            if(mapOppIdNMarketingContactId.containsKey(orderObj.invoiceit_crmx__Opportunity__c)) {
                orderObj.Marketing_Contact__c = mapOppIdNMarketingContactId.get(orderObj.invoiceit_crmx__Opportunity__c);              
            }
            /*System.debug('=======mapOppIdNParentOrder=========='+mapOppIdNParentOrder.containsKey(orderObj.invoiceit_crmx__Opportunity__c));
            if(mapOppIdNParentOrder.containsKey(orderObj.invoiceit_crmx__Opportunity__c)) {
                orderObj.Parent_Order__c= mapOppIdNParentOrder.get(orderObj.invoiceit_crmx__Opportunity__c);              
            }*/
            if(mapOppIdNPONumber.containsKey(orderObj.invoiceit_crmx__Opportunity__c)){
                orderObj.Purchase_Order_Number__c =  mapOppIdNPONumber.get(orderObj.invoiceit_crmx__Opportunity__c);                
            }
            if(mapOppIdNLocation.containsKey(orderObj.invoiceit_crmx__Opportunity__c)){
                orderObj.Locations__c = mapOppIdNLocation.get(orderObj.invoiceit_crmx__Opportunity__c);   
            }
            if(mapOppIdNPracticeAreas.containsKey(orderObj.invoiceit_crmx__Opportunity__c)){
                orderObj.Practice_Areas__c = mapOppIdNPracticeAreas.get(orderObj.invoiceit_crmx__Opportunity__c);   
            }   
       }
       
        Integer numberOfDays = Date.daysInMonth(date.today().year(), date.today().month());
        Date lastDayOfMonth = Date.newInstance(date.today().year(), date.today().month(), date.today().day());
        
       for(invoiceit_s__Job__c orderObj : [Select Renew_Rebase__c ,invoiceit_s__Service_Activation_Date__c,invoiceit_s__Service_End_Date__c,invoiceit_s__Number_Of_Terms__c, Id , Auth_By_Contact__c, Marketing_Contact__c from invoiceit_s__Job__c where Id in : mapOrderIdNQuoteType.keySet()]) {
            System.debug('Orders within the loop'+orderObj);
            if(mapOrderIdNQuoteType.get(orderObj.Id) == 'Renew') {
                System.debug('Getting the value'+mapOrderIdNQuoteType.get(orderObj.Id));
                orderObj.Renew_Rebase__c = 'Renew'; 
                lstOldOrdersToUpdate.add(orderObj);
            }
            else if(mapOrderIdNQuoteType.get(orderObj.Id) == 'Modify') {
                orderObj.Renew_Rebase__c = 'Rebase';
                
                if(orderObj.invoiceit_s__Service_Activation_Date__c > lastDayOfMonth){
                    orderObj.invoiceit_s__Number_Of_Terms__c = 0;
                }
                else if(orderObj.invoiceit_s__Service_Activation_Date__c.year() == lastDayOfMonth.year() ){
                    orderObj.invoiceit_s__Number_Of_Terms__c = lastDayOfMonth.month() - orderObj.invoiceit_s__Service_Activation_Date__c.month() + 1;
                }
                else{
                    orderObj.invoiceit_s__Number_Of_Terms__c = (12 * (lastDayOfMonth.year() - orderObj.invoiceit_s__Service_Activation_Date__c.year() ) - orderObj.invoiceit_s__Service_Activation_Date__c.month())
                                                                    + lastDayOfMonth.month() + 1;
                }
                
                
                lstOldOrdersToUpdate.add(orderObj);
                setOrderIds.add(orderObj.Id);
            }
       }
       system.debug('lstOldOrdersToUpdate::'+lstOldOrdersToUpdate);
       if(lstOldOrdersToUpdate.size() > 0) {
            Database.update(lstOldOrdersToUpdate);
       }
       if(setOrderIds.size() > 0) {
            //MDL_trgHandlerOnOrderForStatus.sendOrderRequestForCurrentOrderInRebase(setOrderIds, userName);  
       }
    }
    /*public static void sendOrderRequestForCurrentOrderInRebase(Set<Id>setOrderIds,String userName) {
        List<Id> lstAttIds= new List<Id>();//empty map just to pass in as a parameter to the generic function calling Order XML
        Set<id> setOrderChargeIds = new Set<id>();
        System.debug('^^^^Calling Order XML for current rebased order');
        //MDL_Integration_Vim_Efs.orderRequestFromBatch(setOrderIds,userName,mapOrderIdNOpp);
        for(invoiceit_s__Job_Rate_Plan_Charge__c orderCharges : [Select Id from invoiceit_s__Job_Rate_Plan_Charge__c where invoiceit_s__Order__c in : setOrderIds]) {
            setOrderChargeIds.add(orderCharges.Id);
        }
        if(setOrderChargeIds.size() > 0) {
            MDL_Integration_Vim_Efs.orderReqInCaseOfAttributesChange(setOrderChargeIds,lstAttIds,userName);
        }   
    }*/
    //added by saiv for SOQL 101 Error - start
    /*private static boolean run = true;
    public static boolean runOnce(){
        if(run){
         run=false;
         return true;
        }else{
            return run;
        }
    }*/
    
    public static void updateAccountNgageCustId(List<invoiceit_s__Job__c > orderList){
        
        //updatedorderList -> order1,order3,order2   databaseOrder -> order1,order2,order3,order4,order5
        
            
        //accToOrderMap -> {Acc1.Id -> cust1Id,cust2Id,cust4Id
        //          Acc2.Id -> cust3Id,cust5Id}   
        Map<String,List<invoiceit_s__Job__c>> accToOrderMap = new Map<String,List<invoiceit_s__Job__c>>();  
        for(invoiceit_s__Job__c  obj : orderList){
            //obj -> order2
            //accToOrderList -> [order1,order2]
            List<invoiceit_s__Job__c> accToOrderList = new List<invoiceit_s__Job__c>();
            if(accToOrderMap.containsKey(obj.invoiceit_s__Account__c)){
                accToOrderList = accToOrderMap.get(obj.invoiceit_s__Account__c);
                accToOrderList.add(obj);
                accToOrderMap.put(obj.invoiceit_s__Account__c,accToOrderList);
            }else{
                accToOrderList.add(obj);
                accToOrderMap.put(obj.invoiceit_s__Account__c,accToOrderList);
            }
        }
        //Acc1.Id,Acc2.ID
        Map<String,Set<String>> accMap = new Map<String,Set<String>>();
        if(!accToOrderMap.keySet().Isempty() && accToOrderMap.keySet() != null){
        List<invoiceit_s__Job__c> orderFromDatabase = [Select id,invoiceit_s__Account__c,Ngage_Cust_ID__c from invoiceit_s__Job__c where invoiceit_s__Account__c In: accToOrderMap.keySet()];
        //orderFromDatabase -> order1,order2,order3,order4,order5
        
        for(invoiceit_s__Job__c obj : orderFromDatabase){
          //obj-> order1
            String custId = obj.Ngage_Cust_ID__c;
            Set<String> custIdSet = new Set<String>();
            if(accMap.containsKey(obj.invoiceit_s__Account__c)){
                custIdSet = accMap.get(obj.invoiceit_s__Account__c);
            }
            custIdSet.add(custId);
            accMap.put(obj.invoiceit_s__Account__c,custIdSet);
        }
        
        List<Account> accListToBeUpdated = new List<Account>();
        //Acc1.Id -> cust1Id,cust2Id,cust4Id
        for(String AccId : accMap.keySet()){
            //AccId -> Acc1.Id
            //Set<String> temp = accMap.get(AccId);
            String result = '';
            for(String custId : accMap.get(AccId)){
                if(custId != null){
                    if(result != ''){
                        result += ',';
                    }
                    result += custId;
                }
            }
            Account acc = new Account();
            acc.Id = AccId;
            acc.Customer_ID__c = result;
          accListToBeUpdated.add(acc);
        }
        upsert accListToBeUpdated;
        }
    }
    
    //added by saiv for SOQL 101 Error - end
    public static void populateLossReason(List<invoiceit_s__Job__c> lstOrders,Map<Id,invoiceit_s__Job__c> mapOldOrders) {
        system.Debug('@@@@@ in populateLossReason');
            
        Set<Id> setCancelledOrderIds = new Set<Id>();
        List<invoiceit_s__Job__c> setOrdersToUpdate = new List<invoiceit_s__Job__c>();
        System.debug('@@@@lstOrders::::::'+lstOrders);
        System.debug('@@@@trigger.newMap'+mapOldOrders);
        for(invoiceit_s__Job__c ord : lstOrders) {
            System.debug('@@@@@ord.invoiceit_s__Status__c:::'+ord.invoiceit_s__Status__c);
            System.debug('@@@@@ord.Loss_Reasons__c:::'+ord.Loss_Reasons__c);
            System.debug('@@@@ord.Created_from_Order__c :::'+ord.Created_from_Order__c );
            System.debug('@@@@mapOldOrders.get(ord.id).invoiceit_s__Status__c :::'+mapOldOrders.get(ord.id).invoiceit_s__Status__c );
            if(ord.invoiceit_s__Status__c == 'Cancelled' && ord.Loss_Reasons__c != null ) {
                setCancelledOrderIds.add(ord.Id);
                System.debug('@@@@@order modified is:::'+ord.Name);
            }
        }
        Map<id,invoiceit_s__Job__c> futureOrderIdsMap = new Map<id,invoiceit_s__Job__c>();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> JRPCList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
         String lossReason = '';
        
        if(!setCancelledOrderIds.isempty() && setCancelledOrderIds!=NULL){
            for(invoiceit_s__Job__c ord : [Select Name,invoiceit_s__Status__c, Cancellation_Date__c , Loss_Reasons__c , Id , 
                                                 Created_From_Order__r.Loss_Reasons__c,Created_From_Order__r.invoiceit_s__Status__c,Created_From_Order__r.Created_From_Order__c,
                                                 Created_From_Order__r.Created_From_Order__r.invoiceit_s__Status__c, Created_From_Order__r.Created_From_Order__r.Loss_Reasons__c ,
                                                 Created_From_Order__r.Created_From_Order__r.Cancellation_Date__c,
                                                 Created_From_Order__r.Cancellation_Date__c,Created_From_Order__r.Name  
                                           from invoiceit_s__Job__c where (Created_From_Order__c in : setCancelledOrderIds
                                                                            OR Created_From_Order__r.Created_From_Order__c in : setCancelledOrderIds
                                                                            OR Created_From_Order__r.Created_From_Order__r.Created_From_Order__c in :setCancelledOrderIds)]) {
                System.debug('@@@@@@@Status of old order is :::'+ord);
               
                 System.debug('@@@@@@@ord.Created_From_Order__r.Loss_Reasons__c :::'+ord.Created_From_Order__r.Loss_Reasons__c);                                                               
                if(ord.Created_From_Order__r.Loss_Reasons__c != NULL  && ord.Created_From_Order__r.Loss_Reasons__c!= ''){
                          lossReason = ord.Created_From_Order__r.Loss_Reasons__c;                                                              
                }   
                system.debug('@@@@@ lossReason'+lossReason);                                                                
                System.debug('@@@Cancel Date of old order is :::'+ord.Created_From_Order__r.Cancellation_Date__c);
                System.debug('@@@@Loss reason of old order is :::'+ord.Created_From_Order__r.Loss_Reasons__c);
                if((ord.Created_From_Order__c != NULL && ord.Created_From_Order__r.invoiceit_s__Status__c == 'Cancelled' && ord.Created_From_Order__r.Loss_Reasons__c != null && ord.Cancellation_Date__c == null) || (ord.Created_From_Order__r.Created_From_Order__c != NULL && ord.Created_From_Order__r.Created_From_Order__r.invoiceit_s__Status__c == 'Cancelled' && ord.Created_From_Order__r.Created_From_Order__r.Loss_Reasons__c != null && ord.Cancellation_Date__c == null)) {
                    //ord.invoiceit_s__Service_End_Date__c = ord.Created_From_Order__r.invoiceit_s__Service_End_Date__c;
                    ord.invoiceit_s__Status__c = 'Cancelled';
                    ord.Loss_Reasons__c = lossReason;
                    ord.Cancellation_Date__c = Date.today();
                    //ord.invoiceit_s__Status__c = ord.Created_From_Order__r.invoiceit_s__Status__c;
                    ord.invoiceit_s__Service_End_Date__c = Date.today().addMonths(1).toStartofMonth().addDays(-1);
                    system.debug('=========order SED:'+ord.invoiceit_s__Service_End_Date__c);
                    setOrdersToUpdate.add(ord);
                    System.debug('Order to be updated is:::'+ord.Id);
                    futureOrderIdsMap.put(ord.Id,ord);
                }
            }
        }
        //system.debug('setOrdersToUpdate::'+setOrdersToUpdate);
        system.debug('@@@@@@futureOrderIdsMap'+futureOrderIdsMap.keySet());
        // To cancel extra charges in future order
       
        if(!futureOrderIdsMap.keyset().isempty() && futureOrderIdsMap.keyset()!=NULL){
            for(invoiceit_s__Job_Rate_Plan_Charge__c charg : [select id,invoiceit_s__Order__c ,invoiceit_s__Status__c, Previous_order_cancel__c from invoiceit_s__Job_Rate_Plan_Charge__c where invoiceit_s__Order__c in :futureOrderIdsMap.keyset()]){
               if(charg.invoiceit_s__Status__c !='Cancelled' &&  charg.invoiceit_s__Status__c !='Renewed' && charg.invoiceit_s__Status__c !='Rebased'){
                   charg.invoiceit_s__Status__c = 'Cancelled';
                   charg.Loss_Reasons__c = futureOrderIdsMap.get(charg.invoiceit_s__Order__c).Loss_Reasons__c;
                   charg.Previous_order_cancel__c = TRUE;
                   JRPCList.add(charg);
               }               
            }
        }        
        
        system.debug('@@@@@JRPCList'+JRPCList);
        //
        
        if(JRPCList.size() > 0) {
            Database.update(JRPCList);
        }
        
        
        if(setOrdersToUpdate.size() > 0) {
            Database.update(setOrdersToUpdate);
        }
        
        
       //charg.Previous_order_cancel__c = FALSE; 
       
    }
     
    // Added by Ronak Jain MHBS-932
   public static void populateServiceEndDate(List<invoiceit_s__Job__c> lstOrders,Map<Id,invoiceit_s__Job__c> mapOldOrders) {
        Set<Id> setCancelledOrderIds = new Set<Id>();
        List<invoiceit_s__Job__c> setOrdersToUpdate = new List<invoiceit_s__Job__c>();
        
        
        //added by saiv - 2/6/17 - start
        //map<string, boolean> chargersNclosedFlagmap = new map<string, boolean>();
        Set<String> notCancelledOrderIdSet = new Set<String>();
        Set<String> ordersWithCharges = new Set<String>();
        for(invoiceit_s__Job_Rate_Plan_Charge__c charg : [select id,invoiceit_s__Order__c , invoiceit_s__Status__c from invoiceit_s__Job_Rate_Plan_Charge__c where invoiceit_s__Order__c in :trigger.new ]){
               if(charg.invoiceit_s__Status__c !='Cancelled'){
                   notCancelledOrderIdSet.add(charg.invoiceit_s__Order__c);
                   ordersWithCharges.add(charg.invoiceit_s__Order__c);
               }
               
        }
        
        for(invoiceit_s__Job__c ord : lstOrders) {
            System.debug('list of order========================'+lstOrders);
            if(ordersWithCharges.contains(ord.id) && !notCancelledOrderIdSet.contains(ord.id)){
                System.debug('======================================'+notCancelledOrderIdSet);
                ord.invoiceit_s__Status__c = 'Cancelled' ;
            }
        //added by saiv - 2/6/17 - end
            
            System.debug('invoiceit_s__Service_Activation_Date__c::'+ord.invoiceit_s__Service_Activation_Date__c);
            System.debug('ord.Cancellation_Date__c'+ord.Cancellation_Date__c);          
            System.debug('ord.invoiceit_s__Status__c::'+ord.invoiceit_s__Status__c);
            System.debug('3rd condition::'+(ord.invoiceit_s__Service_Activation_Date__c > ord.Cancellation_Date__c));
            System.debug('4th condition::'+(ord.Created_From_Order__c));
            System.debug('5th condition::'+(ord.invoiceit_s__Number_Of_Terms__c));
            
            if((ord.invoiceit_s__Status__c != mapOldOrders.get(ord.Id).invoiceit_s__Status__c) && (ord.invoiceit_s__Status__c == 'Cancelled' ) && (ord.invoiceit_s__Service_Activation_Date__c > ord.Cancellation_Date__c)  && (ord.Created_From_Order__c != NULL || ord.Created_From_Order__c !='') && (ord.invoiceit_s__Number_Of_Terms__c == null || ord.invoiceit_s__Number_Of_Terms__c == 0) ) {
                
                Integer numberOfDays = Date.daysInMonth(system.today().year(), system.today().month());
                Date serviceEndDate = Date.newInstance(system.today().year(), system.today().month(), numberOfDays);
                ord.invoiceit_s__Service_End_Date__c = serviceEndDate;
                system.debug('=======serviceEndDate:'+serviceEndDate);
            }
        }
    }
    
    
    public static void populateLeastSEDonAcct(List<invoiceit_s__Job__c> orderList, Map<Id,invoiceit_s__Job__c> mapOldOrders){
        System.debug('@@@@@@@Inside my method--------->>>>'+orderList);
        
        List<invoiceit_s__Job__c> activeOrders = new List<invoiceit_s__Job__c>();
        List<invoiceit_s__Job__c> allOrdersOnAccount = new List<invoiceit_s__Job__c>(); 
        List<invoiceit_s__Job__c> allActiveOrders = new List<invoiceit_s__Job__c>(); 
        Map<Id, List<invoiceit_s__Job__c>> accountIdNorderMap = new Map<Id, List<invoiceit_s__Job__c>>();
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Date> accIdvsSEDMap = new Map<Id, Date>();
        List<Account> updateAccounts = new List<Account>();
        
        Map<Id, List<invoiceit_s__Job__c>> accountIdNInactiveorderMap = new Map<Id, List<invoiceit_s__Job__c>>();
        
        List<Account> cancelledExpiredNEvergreenOrd = new List<Account>();
        
        String mhOrderRecTypeId= Schema.SObjectType.invoiceit_s__Job__c .getRecordTypeInfosByName().get('M-H Order').getRecordTypeId();

        //checking if order is active or not
        for(invoiceit_s__Job__c order : orderList){
            //System.debug('@@@@@@@Order Status----------->'+order.invoiceit_s__Status__c);
            //System.debug('@@@@@@@Order SED----------->'+order.invoiceit_s__Service_End_Date__c);
            //System.debug('@@@@@@@Order Renew Rebase----------->'+order.Renew_Rebase__c);
            //System.debug('@@@@@@@@@@@Old Order SED------------>'+mapOldOrders.get(order.Id).invoiceit_s__Service_End_Date__c);
            
            if(order.invoiceit_s__Status__c == 'Active' && mapOldOrders.get(order.Id).invoiceit_s__Service_End_Date__c == NULL && order.invoiceit_s__Service_End_Date__c!= NULL && order.Renew_Rebase__c == NULL && order.RecordTypeId == mhOrderRecTypeId){
                System.debug('@@@@@@@@@@@Active Orders -------------->'+order.invoiceit_s__Status__c);
                activeOrders.add(order);
                accountIds.add(order.invoiceit_s__Account__c);
            }
            else if(order.invoiceit_s__Status__c == 'Cancelled' && mapOldOrders.get(order.Id).invoiceit_s__Status__c == 'Active' && order.RecordTypeId == mhOrderRecTypeId){
                System.debug('@@@@@@@@@@@Cancelled Orders -------------->'+order.invoiceit_s__Status__c);
                accountIds.add(order.invoiceit_s__Account__c);
            }
            else if(order.invoiceit_s__Status__c == 'Expired' && mapOldOrders.get(order.Id).invoiceit_s__Status__c == 'Active' && order.RecordTypeId == mhOrderRecTypeId){
                System.debug('@@@@@@@@@@@Expired Orders -------------->'+order.invoiceit_s__Status__c);
                accountIds.add(order.invoiceit_s__Account__c);
            }
            else if(order.invoiceit_s__Status__c == 'Evergreen' &&  order.invoiceit_s__Service_End_Date__c == NULL && order.RecordTypeId == mhOrderRecTypeId){
                System.debug('@@@@@@@@@@@Evergreen Orders -------------->'+order.invoiceit_s__Status__c);
                accountIds.add(order.invoiceit_s__Account__c);
            }
        }
        System.debug('@@@@@@Account Ids-------->'+accountIds);
        if(!accountIds.isEmpty()){
            allOrdersOnAccount = [Select Id, name,invoiceit_s__Account__c,Renew_Rebase__c,invoiceit_s__Status__c ,invoiceit_s__Service_End_Date__c  From invoiceit_s__Job__c Where invoiceit_s__Account__c in: accountIds];
            
            System.debug('@@@@@@@All orders-------------------------->'+allOrdersOnAccount);
            
            for(invoiceit_s__Job__c ord: allOrdersOnAccount ){
                if(ord.invoiceit_s__Status__c == 'Active' && ord.Renew_Rebase__c == NULL){
                    allActiveOrders.add(ord);
                }
            }
            
            if(!allActiveOrders.isempty()){
                for(invoiceit_s__Job__c ord: allActiveOrders){
                    if(!accountIdNorderMap.containskey(ord.invoiceit_s__Account__c)){
                        accountIdNorderMap.put(ord.invoiceit_s__Account__c, new List<invoiceit_s__Job__c> {ord});     
                    }else{
                        accountIdNorderMap.get(ord.invoiceit_s__Account__c).add(ord);
                    } 
                }
            }else{
                for(invoiceit_s__Job__c ord: allOrdersOnAccount ){
                    if(!accountIdNInactiveorderMap.containskey(ord.invoiceit_s__Account__c)){
                        accountIdNInactiveorderMap.put(ord.invoiceit_s__Account__c, new List<invoiceit_s__Job__c> {ord});                    
                    }else{
                        accountIdNInactiveorderMap.get(ord.invoiceit_s__Account__c).add(ord);
                    }
                }
            
            }
            
            System.debug('---------------accountIdNInactiveorderMap----------------->'+accountIdNInactiveorderMap);
            
            if(!accountIdNorderMap.values().isempty()){
                for(Id accId: accountIdNorderMap.keyset()){
                    Date ordServiceEndDate;
                    for(invoiceit_s__Job__c ordr: accountIdNorderMap.get(accId)){
                        //System.debug('@@@@@@@Ordr service end date----->'+ordServiceEndDate);
                        if(ordServiceEndDate!=NULL && ordr.invoiceit_s__Service_End_Date__c < ordServiceEndDate ){
                            ordServiceEndDate = ordr.invoiceit_s__Service_End_Date__c ;
                        }else if(ordServiceEndDate == NULL){
                            ordServiceEndDate = ordr.invoiceit_s__Service_End_Date__c ;
                        }
                    }
                    
                    accIdvsSEDMap.put(accId, ordServiceEndDate); 
                    
                }
                
                System.debug('@@@@@@@@@accIdvsSEDMap--------------->'+accIdvsSEDMap);
            }
            
            if(!accountIdNInactiveorderMap.values().isempty()){
                for(Id accId: accountIdNInactiveorderMap.keyset()){
                    Date ordServiceEndDate = NULL ;
                    
                    accIdvsSEDMap.put(accId, ordServiceEndDate); 
                    
                }
                
                System.debug('@@@@@@@@@accountIdNInactiveorderMap--------------->'+accountIdNInactiveorderMap);
            }
            
        }
        
        if(!accIdvsSEDMap.keyset().isempty()){
            List<Account> accListToUpate = [Select id, name,Least_Service_End_Date__c  From Account where id in: accIdvsSEDMap.keyset()];
            
            if(!accListToUpate.isempty()){
                for(Account acc: accListToUpate){
                    if(accIdvsSEDMap.containskey(acc.Id)){
                        acc.Least_Service_End_Date__c = accIdvsSEDMap.get(acc.Id);
                        updateAccounts.add(acc);
                    }
                    
                }
            }
        }
        if(!updateAccounts.isempty()){
            update updateAccounts;
        }
        
    }
        
    public void makeOtherOppsClosedLostWhenOppIsClosedWon(List<invoiceit_s__Job__c> lstOrders) {
        Set<Id> setRelatedOrderIds = new Set<Id>();
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        Set<Id> oppIds        = new Set<Id>();
        for(invoiceit_s__Job__c order : lstOrders){
            if(order.Created_From_Order__c != null){
                setRelatedOrderIds.add(order.Created_From_Order__c);
            }
        }
        for(Opportunity opp : [Select Id, StageName, Reason_Won_Lost__c,CloseDate,IsVoidable__c, Ngage_Upsell_Order__c
                               from Opportunity 
                               where Created_From_Order__c in : setRelatedOrderIds 
                                and StageName!='Closed Lost' and StageName!='Declined']) {
            if(opp.StageName!='Closed Won'){
                opp.StageName = 'Closed Lost';
                opp.Reason_Won_Lost__c = 'Duplicate';              
                opp.CloseDate = system.Today();
                opp.IsVoidable__c = True;
                opp.Parent_Stage_Change__c = system.now(); // akash:26/03
                oppIds.add(opp.id);
                lstOppToUpdate.add(opp);
            }               
        }
        
        for(Opportunity ngageopp : [Select Id, StageName, Reason_Won_Lost__c,CloseDate ,Ngage_Upsell_Order__c,Closed_lost_from_code__c,
                                            Parent_Opportunity__r.Created_From_Order__c,Parent_Opportunity__r.StageName,
                                            Parent_Opportunity__c
                                    from Opportunity 
                                    where (Ngage_Upsell_Order__c in : setRelatedOrderIds 
                                           OR Parent_Opportunity__r.Created_From_Order__c in : setRelatedOrderIds)
                                    //and Parent_Opportunity__c = NULL
                                    and StageName!='Closed Lost' and StageName!='Declined']) {
            if ( ( ngageopp.Parent_Opportunity__c ==NULL && ngageopp.Ngage_Upsell_Order__c != NULL && setRelatedOrderIds.contains(ngageopp.Ngage_Upsell_Order__c))
                   || (ngageopp.Parent_Opportunity__c != NULL && ngageopp.Parent_Opportunity__r.StageName != 'Closed won' && ngageopp.Parent_Opportunity__r.Created_From_Order__c != NULL 
                          && setRelatedOrderIds.contains(ngageopp.Parent_Opportunity__r.Created_From_Order__c)) ){
                     if(ngageopp.StageName!='Closed Won' ){
                        ngageopp.StageName = 'Closed Lost';
                        ngageopp.Closed_lost_from_code__c = True;                        
                        ngageopp.Reason_Won_Lost__c = 'Duplicate';                        
                        ngageopp.CloseDate = system.Today();
                        
                        //  opp.Parent_Stage_Change__c = system.now(); // akash:26/03
                        oppIds.add(ngageopp.id);
                        lstOppToUpdate.add(ngageopp);
                    }                       
              }                         
                       
        }
        
      /*  for(Opportunity ngagechildopp : [Select Id, StageName, Reason_Won_Lost__c,CloseDate 
                               from Opportunity 
                               where Parent_Opportunity__r.Created_From_Order__c in : setRelatedOrderIds 
                                and Parent_Opportunity__c != NULL
                                and StageName!='Closed Lost' and StageName!='Declined']) {
            if(ngagechildopp.StageName!='Closed Won'){
                ngagechildopp.StageName = 'Closed Lost';
                ngagechildopp.Reason_Won_Lost__c = 'Duplicate';
                ngagechildopp.CloseDate = system.Today();
              //  opp.Parent_Stage_Change__c = system.now(); // akash:26/03
                oppIds.add(ngagechildopp.id);
                lstOppToUpdate.add(ngagechildopp);
            }               
        }*/
        
        //if(oppIds.size()>0){
            
            // added to handle void docusign on opty closed lost while cancel
          //voidenvelope(oppIds);
       //}
       
        System.debug('lstOppToUpdate::'+lstOppToUpdate);
        if(lstOppToUpdate.size()>0){
            Database.update(lstOppToUpdate);
            
            MDL_trgHandlerforOppRenew_Rebase.releaseOrderProductInventories(oppIds);
           // MDL_trgHandlerforOppRenew_Rebase.voidingenvelopefrombatch(oppIds);
            
            // added to handle void docusign on opty closed lost while cancel
            MDL_trgHandlerforOppRenew_Rebase.voidingenvelope(oppIds);
           
               // ID jobID = System.enqueueJob(new MDL_docusignvoidingenvelop(oppIds));
            
             
        }
    }
    
    public static void voidenvelope(Set<Id> OppIds){
        System.debug('===========Inside voidenvelopeforevergreenbatch Method==============');
        for(dsfs__DocuSign_Status__c docustat : [Select id, name,dsfs__DocuSign_Envelope_ID__c,dsfs__Envelope_Status__c From dsfs__DocuSign_Status__c where dsfs__Envelope_Status__c!= 'Completed' AND dsfs__Envelope_Status__c!= 'Voided' AND dsfs__Opportunity__c in :OppIds]){
                DocusignVoidApi voi = new DocusignVoidApi();
                voi.voidEnvelope(docustat.dsfs__DocuSign_Envelope_ID__c,'Void APIs');
            }
    }
    
    
     //MHBS-47
   /* public static void makeOpptysClosedLostWhenOrderIsExpired(List<invoiceit_s__Job__c> lstOrders,Map<Id,invoiceit_s__Job__c> mapOldOrders,Map<Id,invoiceit_s__Job__c> mapNewOrders){
        Set<Id> setOrderIds = new Set<Id>();
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        for(invoiceit_s__Job__c order : lstOrders){
            if((order.invoiceit_s__Status__c == 'Expired' || order.invoiceit_s__Status__c == 'Cancelled') && (mapOldOrders.get(order.Id).invoiceit_s__Status__c != mapNewOrders.get(order.Id).invoiceit_s__Status__c) && order.Renew_Rebase__c == null){
                setOrderIds.add(order.Id);
            }
        }
        for(Opportunity opp : [Select Id,StageName, Reason_Won_Lost__c,CloseDate,Created_From_Order__r.invoiceit_s__Status__c from Opportunity where Created_From_Order__c in :setOrderIds and StageName!='Closed Won' and StageName!='Closed Lost' and StageName!='Declined' and (RecordType.DeveloperName='MH_Opportunity' or RecordType.DeveloperName='Nolo_Opportunity')]){
            System.debug('<><>'+opp.Created_From_Order__r.invoiceit_s__Status__c);
            opp.StageName = 'Closed Lost';
             if(opp.Created_From_Order__r.invoiceit_s__Status__c == 'Expired')
              opp.Reason_Won_Lost__c = 'Order Expired';
            else if(opp.Created_From_Order__r.invoiceit_s__Status__c == 'Cancelled')
              opp.Reason_Won_Lost__c = 'Order Cancelled';
            opp.CloseDate = system.Today();
            lstOppToUpdate.add(opp);
        }system.debug('lstOppToUpdate::'+lstOppToUpdate);
        if(lstOppToUpdate.size()>0){
            Database.update(lstOppToUpdate);
        }
    }*/

//Below method added by Rama 3/4/16   

//Edited by saiv - ncons-45 2/6/17
     public static void updatePaymentMethodsBillingEmail(map<id, invoiceit_s__Job__c> newMapOrderObj, map<id, invoiceit_s__Job__c> oldMapOrderObj) {
        map<id, invoiceit_s__Job__c> acctids = new map<id, invoiceit_s__Job__c>();
        
        system.debug('---newMapOrderObj---'+newMapOrderObj);
        String mnOrderRecTypeId= Schema.SObjectType.invoiceit_s__Job__c .getRecordTypeInfosByName().get('M-N Order').getRecordTypeId();
        list<invoiceit_s__Job__c> orders = new list<invoiceit_s__Job__c>();
        map<string,string> recidmap = new map<string,string>();
        for(RecordType  jobRecType : [SELECT Id,Name,developerNAme FROM RecordType WHERE SobjectType='invoiceit_s__Job__c']){
            if(jobRecType.developerName !='M_N_Order'){
                recidmap.put(jobRecType.id, jobRecType.id);
            }
        }
        
        for(invoiceit_s__Job__c job : newMapOrderObj.values()){
            if(recidmap.containsKey(job.RecordTypeId)){
                orders.add(job);
            }
        }
         system.debug('-----orders: ----'+orders);  
         system.debug('-----recidmap: ----'+recidmap);      
        try {
         for(invoiceit_s__Job__c j : [select id, invoiceit_s__Account__c,RecordTypeId  from invoiceit_s__Job__c where RecordTypeId in: recidmap.keySet() and id in :orders]) {
            if (j.invoiceit_s__Account__c != null && recidmap.containsKey(j.RecordTypeId ) )
                acctids.put(j.invoiceit_s__Account__c, j);
         }
         
         system.debug('Accounts: ' + acctids);
         list<aggregateresult> ar = [select max(OrderNumber__c) MaxName, invoiceit_s__Account__c from invoiceit_s__Job__c where invoiceit_s__Account__c in :acctids.keyset()  and recordTypeid in:recidmap.keySet() and invoiceit_s__Billing_Contact__r.email != null  group by invoiceit_s__Account__c];
         
       
         updPayMethodEmail(ar);

        }
        catch(exception e) {
           system.debug(e.getMessage());
        }
    }
    
//Added by Rana 3/9/16    edited by saiv - ncons-45 2/6/17
    public static void updPayMethodEmail(List<AggregateResult> ar)
    {
         list<string> orders = new list<String>();
         map<id, invoiceit_s__Job__c> acctids2 = new map<id, invoiceit_s__Job__c>();
         String mnOrderRecTypeId= Schema.SObjectType.invoiceit_s__Job__c .getRecordTypeInfosByName().get('M-N Order').getRecordTypeId();
        
        
        
         for (AggregateResult a : ar) {
             
            orders.add((String) a.get('MaxName'));
         }  
         
                  
         for (invoiceit_s__Job__c j : [select  id, name,invoiceit_s__Account__c, recordType.id, invoiceit_s__Billing_Contact__r.email from invoiceit_s__Job__c where OrderNumber__c in :orders and invoiceit_s__Billing_Contact__r.email != null ORDER BY CreatedDate])
         {
         
           if ( j.invoiceit_s__Account__c != null  && !acctids2.containsKey(j.invoiceit_s__Account__c) && j.recordType.id != mnOrderRecTypeId )
                acctids2.put(j.invoiceit_s__Account__c, j);             
         }//edited by saiv for ncons-46
         list<invoiceit_s__Payment_Method__c> lstPaymethod = new list<invoiceit_s__Payment_Method__c>();
         system.debug('---acctids2----'+acctids2);
         for(invoiceit_s__Payment_Method__c p : [select id, invoiceit_s__Account__c, invoiceit_s__Billing_Email__c,invoiceit_s__Account__r.recordType.developerName from invoiceit_s__Payment_Method__c where invoiceit_s__Account__c in :acctids2.keySet() and invoiceit_s__Payment_Method__c = 'Credit Card']) {
             
             system.debug('---ppppppp----'+p);
             if(acctids2.containsKey(p.invoiceit_s__Account__c) && (p.invoiceit_s__Billing_Email__c == null || (p.invoiceit_s__Billing_Email__c != acctids2.get(p.invoiceit_s__Account__c).invoiceit_s__Billing_Contact__r.email)))
             {  
                
                p.invoiceit_s__Billing_Email__c = acctids2.get(p.invoiceit_s__Account__c).invoiceit_s__Billing_Contact__r.email;           
                lstPaymethod.add(p);
             }
         }
         system.debug('lstPaymethod::'+lstPaymethod);
         if (!lstPaymethod.isEmpty()) 
             update lstPaymethod; 
    }
    //added 02/24/2020 - saiv MHBS-3924
    public static void populateEvergreenOrderStatusonAccount(List<invoiceit_s__Job__c> ordList, Map<Id,invoiceit_s__Job__c> oldMap){
        Set<Id> accId = new Set<Id>();
        List<Account> accToUpdate = new List<Account>();
        //Deactivate_Trigger_for_data_load__c debug = Deactivate_Trigger_for_data_load__c.getValues('Debug Status');
        for(invoiceit_s__Job__c ord: ordList){
            if(ord.invoiceit_s__Status__c == 'Evergreen' && ord.invoiceit_s__Status__c != oldMap.get(ord.Id).invoiceit_s__Status__c){
                accId.add(ord.invoiceit_s__Account__c);
            }
        }
        if(!accId.isEmpty()){
            List<Account> accList = [select Id, Order_Status__c from Account where Id IN:accId];
            for(Account acc:accList){
                if(acc.Order_Status__c == Null || acc.Order_Status__c != 'Evergreen'){
                    acc.Order_Status__c = 'Evergreen';
                    accToUpdate.add(acc);
                }
            }
        }
        system.debug('==accToUpdate=='+accToUpdate);
        if(!accToUpdate.isEmpty()){
            update accToUpdate;
        }
    }
    //moved from process builder for MHBS-3924
    public static void populateLatestChildOrderNumber(List<invoiceit_s__Job__c>ordList){
        Set<Id> parentMHOrderId = new Set<Id>();
        Map<Id, invoiceit_s__Job__c> parentMHOrderMap = new Map<Id, invoiceit_s__Job__c>();
        List<invoiceit_s__Job__c> updateMHOrder = new List<invoiceit_s__Job__c>();
        //Deactivate_Trigger_for_data_load__c debug = Deactivate_Trigger_for_data_load__c.getValues('Debug Status');
        for(invoiceit_s__Job__c ord: ordList){
            if(ord.Parent_Order__c!=Null){ //&& ord.Record_Type_Name__c == mngOrderRecTypeId){
                parentMHOrderId.add(ord.Parent_Order__c);
            }
        }
        if(!parentMHOrderId.isEmpty()){
            parentMHOrderMap = new Map<Id,invoiceit_s__Job__c>([select id, name, LatestRelatedOrder__c FROM invoiceit_s__Job__c WHERE Id IN:parentMHOrderId]);
        }
        for(invoiceit_s__Job__c ord: ordList){
            if(parentMHOrderMap.containsKey(ord.Parent_Order__c)){
                invoiceit_s__Job__c parentOrd = parentMHOrderMap.get(ord.Parent_Order__c);
                if(parentOrd != Null){
                    parentOrd.LatestRelatedOrder__c = ord.OrderNumber__c;
                    updateMHOrder.add(parentOrd);
                }
            }
        }
        if(!updateMHOrder.isEmpty()){
            update updateMHOrder;
        }
    }

}
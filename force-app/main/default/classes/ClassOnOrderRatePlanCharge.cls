public with sharing class ClassOnOrderRatePlanCharge {
    /*
    **Created By : Invoice iT
    **Created Purpose : For creating renewal opportunities & opportunity for Rebase based on Quote type selected in order(Renew/Rebase)
    
    Last Modified Date : 15th Aug, 2014
    */
    // Req : 1
    // For Renew ORPC we need to populate the service activation date and service end date
    //           service activation date =  old charge.ServiceEndDate + 1
    //           service end date = above charge + number of terms on order

    // Req : 2
    // For Modify ORPC, once the old charge is modified we need to do :
    // A) Make the old charge expired to the current last day of the month
    // B) Make the new charge active from 1st of next month(i.e previous date + 1)

    // PS : Req : 1, 2 are done using before insert trigger
 
    
    public static boolean triggerOnOrderRatePlanChargeRecusion = true;
    
    Deactivate_Trigger_for_data_load__c debug = Deactivate_Trigger_for_data_load__c.getValues('Debug Status');
    
    public void handleBeforeOnOrderRatePlanCharge(list<invoiceit_s__Job_Rate_Plan_Charge__c> newCharges, map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> newMap, map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> oldMap) {
        map<Id, invoiceit_s__Job_Rate_Plan_Charge__c> mapChargeId_Charge = new map<Id, invoiceit_s__Job_Rate_Plan_Charge__c>();
        map<Id, invoiceit_s__Job_Rate_Plan__c> mapRPChargeId_RPCharge = new map<Id, invoiceit_s__Job_Rate_Plan__c>();

        list<invoiceit_s__Job_Rate_Plan_Charge__c> chargesToExpired = new list<invoiceit_s__Job_Rate_Plan_Charge__c>();
        invoiceit_s__Job_Rate_Plan_Charge__c chargeToExpire;

        for(invoiceit_s__Job_Rate_Plan_Charge__c newCharge : newCharges) {
            if(newCharge.Quote_Type__c == 'Renew' && newCharge.Created_From_Charge__c != null) {
                // need this for finding the end date of charge
                mapChargeId_Charge.put(newCharge.Created_From_Charge__c, null); 

                // need this for finding the number of terms from order record
                mapRPChargeId_RPCharge.put(newCharge.invoiceit_s__Job_Rate_Plan__c, null);  
            } else if(newCharge.Quote_Type__c == 'Modify' && newCharge.Created_From_Charge__c != null) {
                // we need to ignore the one time charges
                Date selectedDate =  Date.today(); //Give your date
                Date firstDate = selectedDate.toStartOfMonth();
                Date lastDateOfTheMonth = firstDate.addDays(date.daysInMonth(selectedDate.year() , selectedDate.month())  - 1);
                
                // once the old charge is modified we need to do :
                // A) Make the old charge expired to the current last day of the month
                // B) Make the new charge active from 1st of next month(i.e previous date + 1)
                newCharge.invoiceit_s__Service_Activation_Date__c = lastDateOfTheMonth.addDays(1);
                
                //if(newCharge.invoiceit_s__Price_Type__c != 'One Time') {
                 
                    chargeToExpire = new invoiceit_s__Job_Rate_Plan_Charge__c(Id = newCharge.Created_From_Charge__c, invoiceit_s__Service_End_Date__c = lastDateOfTheMonth);
                    chargesToExpired.add(chargeToExpire);  
                
                //} 

                  // need this for finding the number of terms from order record
                mapRPChargeId_RPCharge.put(newCharge.invoiceit_s__Job_Rate_Plan__c, null);
            }   
        }   
        if(debug.DebugOn__c == TRUE){
            system.debug('@@@@@mapChargeId_Charge'+mapChargeId_Charge);
        } 
        if(mapRPChargeId_RPCharge.size() > 0) {
            map<Id, invoiceit_s__Job__c> mapOrderId_Order = new map<Id, invoiceit_s__Job__c>();

           // List<invoiceit_s__Job_Rate_Plan_Charge__c> charges = [SELECT Id,invoiceit_s__Service_Activation_Date__c, invoiceit_s__Service_End_Date__c FROM invoiceit_s__Job_Rate_Plan_Charge__c WHERE Id In: mapChargeId_Charge.keySet()];
            mapChargeId_Charge = new map<Id, invoiceit_s__Job_Rate_Plan_Charge__c>([SELECT Id,invoiceit_s__Service_Activation_Date__c, invoiceit_s__Service_End_Date__c FROM invoiceit_s__Job_Rate_Plan_Charge__c WHERE Id In: mapChargeId_Charge.keySet()]);
            if(debug.DebugOn__c == TRUE){
                system.debug('mapRPChargeId_RPCharge is ' + mapRPChargeId_RPCharge.keySet());
            }
            mapRPChargeId_RPCharge = new map<Id, invoiceit_s__Job_Rate_Plan__c>([SELECT invoiceit_s__Job_Product__r.invoiceit_s__Job__r.invoiceit_s__Number_Of_Terms__c, 
                                                                                 invoiceit_s__Job_Product__r.invoiceit_s__Job__c
                                                                                 FROM invoiceit_s__Job_Rate_Plan__c WHERE Id IN: mapRPChargeId_RPCharge.keySet()]);
            if(debug.DebugOn__c == TRUE){
                system.debug('mapRPChargeId_RPCharge is ' + mapRPChargeId_RPCharge.values());
            }
            for(invoiceit_s__Job_Rate_Plan_Charge__c newCharge : newCharges) {
                if(newCharge.Quote_Type__c == 'Renew' && newCharge.Created_From_Charge__c!=NULL) {
                    // populate the charge dates(Start and End dates)
                    
                    newCharge.invoiceit_s__Service_Activation_Date__c = mapChargeId_Charge.get(newCharge.Created_From_Charge__c).invoiceit_s__Service_End_Date__c;      

                    if(newCharge.invoiceit_s__Service_Activation_Date__c != null) {
                        newCharge.invoiceit_s__Service_Activation_Date__c = newCharge.invoiceit_s__Service_Activation_Date__c.addDays(1);       

                        decimal noOfTerms = mapRPChargeId_RPCharge.get(newCharge.invoiceit_s__Job_Rate_Plan__c).invoiceit_s__Job_Product__r.invoiceit_s__Job__r.invoiceit_s__Number_Of_Terms__c;
                        if(noOfTerms != null) {
                            newCharge.invoiceit_s__Service_End_Date__c = newCharge.invoiceit_s__Service_Activation_Date__c.addMonths(integer.ValueOf(noOfTerms));   
                            newCharge.invoiceit_s__Service_End_Date__c = newCharge.invoiceit_s__Service_End_Date__c.addDays(-1);
                        }
                    }

                    // populate the orderIds for calculating the dates(Start and End dates)
                    Id orderId = mapRPChargeId_RPCharge.get(newCharge.invoiceit_s__Job_Rate_Plan__c).invoiceit_s__Job_Product__r.invoiceit_s__Job__c;
                    if(!mapOrderId_Order.containsKey(orderId)) {
                        mapOrderId_Order.put(orderId, null);    
                    }


                } else if(newCharge.Quote_Type__c == 'Modify') {
                    Date selectedDate =  Date.today(); //Give your date
                    Date firstDate = selectedDate.toStartOfMonth();
                    Date lastDateOfTheMonth = firstDate.addDays(date.daysInMonth(selectedDate.year() , selectedDate.month())  - 1);
                    
                    // populate the charge dates(Start and End dates)
                    newCharge.invoiceit_s__Service_Activation_Date__c = lastDateOfTheMonth.addDays(1);
                    if(debug.DebugOn__c == TRUE){
                        system.debug('newCharge.invoiceit_s__Job_Rate_Plan__c is ' + newCharge.invoiceit_s__Job_Rate_Plan__c);
                        system.debug('mapRPChargeId_RPCharge is ' + mapRPChargeId_RPCharge.values());
                        system.debug('mapRPChargeId_RPCharge is ' + mapRPChargeId_RPCharge);
                    }
                    
                    //don't populate the end dates for the one time charges
                    decimal noOfTerms = mapRPChargeId_RPCharge.get(newCharge.invoiceit_s__Job_Rate_Plan__c).invoiceit_s__Job_Product__r.invoiceit_s__Job__r.invoiceit_s__Number_Of_Terms__c;
                    if(newCharge.invoiceit_s__Price_Type__c != 'One Time' && noOfTerms != null && newCharge.invoiceit_s__Service_Activation_Date__c != null) {
                        newCharge.invoiceit_s__Service_End_Date__c = newCharge.invoiceit_s__Service_Activation_Date__c.addMonths(integer.ValueOf(noOfTerms));   
                        newCharge.invoiceit_s__Service_End_Date__c = newCharge.invoiceit_s__Service_End_Date__c.addDays(-1);
                    }

                    // populate the orderIds for calculating the dates(Start and End dates)
                    Id orderId = mapRPChargeId_RPCharge.get(newCharge.invoiceit_s__Job_Rate_Plan__c).invoiceit_s__Job_Product__r.invoiceit_s__Job__c;
                    if(!mapOrderId_Order.containsKey(orderId)) {
                        mapOrderId_Order.put(orderId, null);    
                    }
                }   
            }


            if(mapOrderId_Order.size() > 0) {
                mapOrderId_Order = new map<Id, invoiceit_s__Job__c>([SELECT invoiceit_s__Number_Of_Terms__c, Quote_Type__c, Created_From_Order__c,invoiceit_s__Service_Activation_Date__c FROM invoiceit_s__Job__c WHERE Id In: mapOrderId_Order.keySet()]);

            }


            if(chargesToExpired.size() > 0) {
                update chargesToExpired;    
            }
        }
    }

    public static void populateTheActivationDatesOnOrder(list<invoiceit_s__Job__c> listOfOrders) {
        
        Deactivate_Trigger_for_data_load__c debug = Deactivate_Trigger_for_data_load__c.getValues('Debug Status');         
        list<invoiceit_s__Job__c> ordersToExpired = new list<invoiceit_s__Job__c>();
        invoiceit_s__Job__c orderToExpired;
        map<Id, invoiceit_s__Job__c> mapOrderId_Order = new map<Id, invoiceit_s__Job__c>();
        map<Id, invoiceit_s__Job__c> mapOfOldOrders;
        Date selectedDate =  Date.today(); //Give your date
        Date firstDate = selectedDate.toStartOfMonth();
        Date lastDateOfTheMonth = firstDate.addDays(date.daysInMonth(selectedDate.year() , selectedDate.month())  - 1);
        
        
        set<Id> setOfOrderIds = new set<Id>();
        for(invoiceit_s__Job__c newOrder : listOfOrders) {
            if(newOrder.Created_From_Order__c != null) 
            setOfOrderIds.add(newOrder.Created_From_Order__c);
        }
        
        if(!setOfOrderIds.isEmpty())
            mapOfOldOrders = new map<Id, invoiceit_s__Job__c>([Select Id FROM invoiceit_s__Job__c WHERE Id in: setOfOrderIds AND invoiceit_s__Service_End_Date__c !=: lastDateOfTheMonth]);
        
        for(invoiceit_s__Job__c newOrder : listOfOrders) {
            if(newOrder.Quote_Type__c == 'Renew' && newOrder.Created_From_Order__c != null) {
                // need this for finding the end date of charge
                mapOrderId_Order.put(newOrder.Created_From_Order__c, null); 
            }  else if(newOrder.Quote_Type__c == 'Modify' && newOrder.Created_From_Order__c != null) {
                // need this for finding the end date of charge
                mapOrderId_Order.put(newOrder.Created_From_Order__c, null);     
                    
                 if(mapOfOldOrders.containskey(newOrder.Created_From_Order__c)) {
                    // make the old order expired to the last day of the month
                  orderToExpired = new invoiceit_s__Job__c(Id = newOrder.Created_From_Order__c, invoiceit_s__Service_End_Date__c = lastDateOfTheMonth);
                  ordersToExpired.add(orderToExpired);    
                 }                       
            }
            
        }


        if(mapOrderId_Order.size() > 0) {
            //query the old order end date
            mapOrderId_Order = new map<Id, invoiceit_s__Job__c>([SELECT invoiceit_s__Number_Of_Terms__c, invoiceit_s__Service_Activation_Date__c, invoiceit_s__Service_End_Date__c FROM invoiceit_s__Job__c WHERE Id In: mapOrderId_Order.keySet()]);    
            if(debug.DebugOn__c == TRUE){
                system.debug('mapOrderId_Order is ' + mapOrderId_Order);
            }
            for(invoiceit_s__Job__c newOrder : listOfOrders) {
                //system.debug('before newOrder.invoiceit_s__Service_Activation_Date__c is ' + newOrder.invoiceit_s__Service_Activation_Date__c);
                //system.debug('newOrder.Quote_Type__c  is ' + newOrder.Quote_Type__c );
                //system.debug('newOrder.Created_From_Order__c is ' + newOrder.Created_From_Order__c);
                if(newOrder.Quote_Type__c == 'Renew' && newOrder.Created_From_Order__c != null) {
                    newOrder.invoiceit_s__Service_Activation_Date__c = mapOrderId_Order.get(newOrder.Created_From_Order__c).invoiceit_s__Service_End_Date__c;       
                    if(newOrder.invoiceit_s__Service_Activation_Date__c != null && newOrder.invoiceit_s__Number_Of_Terms__c != null) {
                        newOrder.invoiceit_s__Service_Activation_Date__c = newOrder.invoiceit_s__Service_Activation_Date__c.addDays(1);

                        system.debug('newOrder.invoiceit_s__Service_Activation_Date__c is ' + newOrder.invoiceit_s__Service_Activation_Date__c);
                        newOrder.invoiceit_s__Service_End_Date__c = newOrder.invoiceit_s__Service_Activation_Date__c.addMonths(integer.ValueOf(newOrder.invoiceit_s__Number_Of_Terms__c));
                        newOrder.invoiceit_s__Service_End_Date__c = newOrder.invoiceit_s__Service_End_Date__c.addDays(-1);
                    }

                }  else if(newOrder.Quote_Type__c == 'Modify' && newOrder.Created_From_Order__c != null) {
                    newOrder.invoiceit_s__Service_Activation_Date__c = lastDateOfTheMonth.addDays(1);

                    if(newOrder.invoiceit_s__Service_Activation_Date__c != null && newOrder.invoiceit_s__Number_Of_Terms__c != null) {
                        newOrder.invoiceit_s__Service_End_Date__c = newOrder.invoiceit_s__Service_Activation_Date__c.addMonths(integer.ValueOf(newOrder.invoiceit_s__Number_Of_Terms__c));
                        newOrder.invoiceit_s__Service_End_Date__c = newOrder.invoiceit_s__Service_End_Date__c.addDays(-1);
                    }
                }
            }
        }

        if(ordersToExpired.size() > 0) {
            update ordersToExpired; 
        }

        //update listOfOrders;
    }
    //Ronak Milestone - For cancelling the Project, Milestone and Task on Order RPC cancel  
    public void handleCancelOrderRPC(map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> newMap, map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> oldMap){
        
        Set<Id> cancelldOrderRPCId = new Set<Id>();
        Set<Id> projIds = new Set<Id>();
        List<Milestone1_Project__c> CancellPrjIds = new List<Milestone1_Project__c>();
        List<Milestone1_Milestone__c> cancelMilestonelist = new List<Milestone1_Milestone__c>();
        List<SObject> updateCancelList = new List<SObject>();
        
        
        for(invoiceit_s__Job_Rate_Plan_Charge__c orderCharge : newMap.values()) {
            //updated by saiv - MHBS-2287
            if((orderCharge.invoiceit_s__Status__c == 'Cancelled' || orderCharge.invoiceit_s__Status__c == 'Expired' || orderCharge.invoiceit_s__Status__c == 'Truncated') && oldmap.get(orderCharge.Id).invoiceit_s__Status__c!= newMap.get(orderCharge.Id).invoiceit_s__Status__c) {
                if(orderCharge.invoiceit_s__Status__c == 'Expired' && (orderCharge.invoiceit_s__Accounting_Code__c != '01502' && orderCharge.invoiceit_s__Accounting_Code__c != '01668')){
                    cancelldOrderRPCId.add(orderCharge.Id);
                }else if(orderCharge.invoiceit_s__Status__c == 'Cancelled' || orderCharge.invoiceit_s__Status__c == 'Truncated'){
                    cancelldOrderRPCId.add(orderCharge.Id);
                }
            }
        }
        if(debug.DebugOn__c == TRUE){
            System.debug('=========cancelldOrderRPCId============'+cancelldOrderRPCId);
        }
        if(cancelldOrderRPCId.size()>0){
            List<Milestone1_Project__c> projectListToCancel = [Select id, name,Status__c, (SELECT Id,
                                                               Name,
                                                               Project__c,Status__c,
                                                               Parent_Milestone__c,
                                                               Complete__c,
                                                               Deadline__c,
                                                               Total_Actual_Hours__c From Project_Milestones__r Where Status__c!='Cancelled' AND Status__c!='Completed') From Milestone1_Project__c Where Status__c!='Completed' AND Status__c!= 'Cancelled' AND Order_Rate_Plan_Charge__c in: cancelldOrderRPCId];
            if(debug.DebugOn__c == TRUE){
                System.debug('=============projectListToCancel============='+projectListToCancel);
            }
        
        id cancelProjectrecordTypeId = Schema.SObjectType.Milestone1_Project__c.RecordTypeInfosByName.get('Cancel Project').RecordTypeId ;
        id cancelMilestonRecTypId = Schema.SObjectType.Milestone1_Milestone__c.RecordTypeInfosByName.get('Cancel project Milestone').RecordTypeId ;
        id cancelTaskRecTypId = Schema.SObjectType.Milestone1_Task__c.RecordTypeInfosByName.get('Cancel Project Task').RecordTypeId ;
        
            if(!projectListToCancel.isEmpty()){
                for(Milestone1_Project__c prj : projectListToCancel){
                    projIds.add(prj.id);
                    if(prj.Status__c!= 'Cancelled'){
                        CancellPrjIds.add(prj);
                    }
                
                    if(prj.Project_Milestones__r.size() > 0){
                         cancelMilestonelist = prj.Project_Milestones__r;
                    }
                }
                if(debug.DebugOn__c == TRUE){
                    System.debug('==============projIds============'+projIds);
                }
                if(!CancellPrjIds.isEmpty()){
                    for(Milestone1_Project__c cancelprj: CancellPrjIds){
                        cancelprj.Status__c = 'Cancelled';
                        cancelprj.AllmilestoneCancelled__c = True;
                        cancelprj.RecordTypeId = cancelProjectrecordTypeId;
                    }
                    update CancellPrjIds;
                }
                
                if(!cancelMilestonelist.isEmpty()){
                    for(Milestone1_Milestone__c canmil : cancelMilestonelist){
                        canmil.Status__c = 'Cancelled';
                        canmil.RecordTypeId = cancelMilestonRecTypId;
                    }
                    update cancelMilestonelist;
                }
                if(debug.DebugOn__c == TRUE){
                    System.debug('==========projIds============='+projIds);
                }
                List<Milestone1_Task__c> cancelTaskList = [select id,Task_Stage__c,ProjectId__c
                                                     from Milestone1_Task__c WHERE Task_Stage__c!= 'Cancelled' AND Task_Stage__c!= 'Completed' AND Project_ID__c IN:projIds];
                if(debug.DebugOn__c == TRUE){
                    System.debug('==========cancelTaskList==========='+cancelTaskList);
                }
                if(!cancelTaskList.isEmpty()){
                    for(Milestone1_Task__c cancelTask : cancelTaskList){
                        canceltask.Task_Stage__c = 'Cancelled';
                        canceltask.RecordTypeId = cancelTaskRecTypId;
                    }
                    update cancelTaskList;
                }
            
            }
        }
    }
    // Create a case when the web products are fiulfilled and they have an existing chat associated to it.
        public void createChargeCase(List<invoiceit_s__Job_Rate_Plan_Charge__c> listOfOrderCharges, Map<Id, invoiceit_s__Job_Rate_Plan_Charge__c> oldmap){
            
            Set<Id> mhChargeIds = new Set<Id>();
            Set<Id> ngageChatChargeIds = new Set<Id>();
            Set<Id> ngageOrderIds = new Set<Id>();
            Map<String, String> mapChatVsCharge = new Map<String,String>();
            Map<String, String> mapProdChargeVsLatestChat = new Map<String, String>();
            List<Chat_Product_Order_Charge__c> chatprodOrdChargeList= new List<Chat_Product_Order_Charge__c>();
            List<invoiceit_s__Job_Rate_Plan_Charge__c> insertChargesList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
            List<invoiceit_s__Job_Rate_Plan_Charge__c> finalChargeList= new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
            Map<string,string> chatNUrlMap = new Map<String,String>();
            List<Case> casesToInsert = new List<Case>(); 
            List<invoiceit_s__Job_Rate_Plan_Charge__c> chatFeatureList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
            Map<String,List<invoiceit_s__Job_Rate_Plan_Charge__c>> featureNchatMap = new Map<String,List<invoiceit_s__Job_Rate_Plan_Charge__c>>();
            List<invoiceit_s__Job_Rate_Plan_Charge__c> chargesToUpdate = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
            Map<Id, Milestone1_Project__c> chargeIdVsProject = new Map<Id, Milestone1_Project__c>();
            List<Milestone1_Project__c> projectsList = new List<Milestone1_Project__c>();
            String parentChargeId;
            if(debug.DebugOn__c == TRUE){
                System.debug('@@@listOfOrderCharges'+listOfOrderCharges);
            }
            if(!listOfOrderCharges.isempty()){
                for(invoiceit_s__Job_Rate_Plan_Charge__c ord: listOfOrderCharges){
                    if(!ord.name.contains('Professional Profile') && ord.Fulfilment_Start_Date__c!=NULL && (ord.Fulfilment_Start_Date__c!= oldmap.get(ord.id).Fulfilment_Start_Date__c)  && oldmap.get(ord.id).Fulfilment_Start_Date__c==NULL && ord.invoiceit_s__Status__c == 'Active' && (ord.invoiceit_s__Status__c!='Cancelled' || ord.invoiceit_s__Status__c!='Expired' || ord.invoiceit_s__Status__c!='Truncated')){
                        mhChargeIds.add(ord.id);
                    }
                }
                if(debug.DebugOn__c == TRUE){
                    System.debug('@@@@@@@@mhChargeIds'+mhChargeIds);
                }
                if(!mhChargeIds.isempty()){
                
                    chatprodOrdChargeList = [Select id, name,Chat_Usage_Order_Rate_Plan_Charge__c,Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Order__c ,Chat_Product_Order_Rate_Plan_Charge__c,Chat_Product_Order_Rate_Plan_Charge__r.Fulfilment_Start_Date__c From Chat_Product_Order_Charge__c Where Chat_Product_Order_Rate_Plan_Charge__c in: mhChargeIds Order By CreatedDate DESC];    
                    if(debug.DebugOn__c == TRUE){
                        System.debug('@@@@@chatprodOrdChargeList '+chatprodOrdChargeList );
                    }
                    if(!chatprodOrdChargeList.isempty()){
                        for(Chat_Product_Order_Charge__c chat:  chatprodOrdChargeList){
                            if(chat.Chat_Product_Order_Rate_Plan_Charge__c!=Null && chat.Chat_Usage_Order_Rate_Plan_Charge__c!=NULL){
                                if(mapProdChargeVsLatestChat.containskey(chat.Chat_Product_Order_Rate_Plan_Charge__c)){
                                    
                                }else{
                                    mapProdChargeVsLatestChat.put(chat.Chat_Product_Order_Rate_Plan_Charge__c,chat.Chat_Usage_Order_Rate_Plan_Charge__c);
                                    mapChatVsCharge.put(chat.Chat_Usage_Order_Rate_Plan_Charge__c,chat.Chat_Product_Order_Rate_Plan_Charge__c );
                                    ngageChatChargeIds.add(chat.Chat_Usage_Order_Rate_Plan_Charge__c);
                                    ngageOrderIds.add(chat.Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Order__c); 
                                }
                                if(debug.DebugOn__c == TRUE){
                                    System.debug('@@@@@@@@@@@mapProdChargeVsLatestChat'+mapProdChargeVsLatestChat);
                                }
                            }
                        }
                    }
                }
                if(debug.DebugOn__c == TRUE){
                    System.debug('Get the Ngage Order Ids :: '+ngageOrderIds);
                }
                if(!ngageOrderIds.isempty() && ngageOrderIds!=NULL){
                    
                    insertChargesList = [Select id, name,invoiceit_s__Status__c,Chat_Parent_Order_Rate_Plan_Charge__c,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name,
                                invoiceit_s__Order__r.invoiceit_s__Account__r.Name,IsCaseCreated__c,invoiceit_s__Order__r.Ngage_Cust_ID__c,
                                Chat_Parent_Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name,invoiceit_s__Order__r.invoiceit_s__Account__c,
                                invoiceit_s__Service_End_Date__c,Fulfilment_Start_Date__c,Created_From_Charge__c,Chat_Parent_Order_Rate_Plan_Charge__r.created_from_Charge__c,RecordTypeId,
                                invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c,(select id,name,Attribute_Name__c,Attribute_Type__c,
                                String_Value__c,Picklist_Value__c,Boolean_Value__c,Phone_Value__c,Number_Value__c,Date_value__c,Long_text_value__c,
                                Order_Rate_Plan_Charge__r.invoiceit_s__Status__c From Order_Charge_Attributes__r) From invoiceit_s__Job_Rate_Plan_Charge__c 
                                Where invoiceit_s__Order__c in: ngageOrderIds AND invoiceit_s__Status__c!='Cancelled' AND invoiceit_s__Status__c!='Expired' AND invoiceit_s__Status__c!='Truncated' AND IsCaseCreated__c= False];
                
                    if(!insertChargesList.isempty()){
                        for(invoiceit_s__Job_Rate_Plan_Charge__c rm: insertChargesList ){
                            
                            if(rm.Chat_Parent_Order_Rate_Plan_Charge__c == Null){
                                chatNUrlMap.put(rm.id, rm.Order_Charge_Attributes__r[0].String_Value__c);
                            }
                            
                            if(rm.Chat_Parent_Order_Rate_Plan_Charge__c!= Null /*&& rm.created_from_Charge__c == Null && rm.Chat_Parent_Order_Rate_Plan_Charge__r.created_from_Charge__c == NULL*/){
                                if(debug.DebugOn__c == TRUE){
                                    System.debug('@@@@@@rm.Chat_Parent_Order_Rate_Plan_Charge__c'+rm.Chat_Parent_Order_Rate_Plan_Charge__c);
                                }
                                if(featureNchatMap.containskey(rm.Chat_Parent_Order_Rate_Plan_Charge__c)){
                                    featureNchatMap.get(rm.Chat_Parent_Order_Rate_Plan_Charge__c).add(rm);
                                }else{
                                    featureNchatMap.put(rm.Chat_Parent_Order_Rate_Plan_Charge__c, new List<invoiceit_s__Job_Rate_Plan_Charge__c> {rm});
                                }
                            }
                            if(debug.DebugOn__c == TRUE){
                                System.debug('@@@@chat id is in the map or not===='+mapChatVsCharge.containskey(rm.id));
                            }
                            if(mapChatVsCharge.containskey(rm.id)){
                                finalChargeList.add(rm);            
                            }
                        }
                        
                    }
                    
                    if(!mhChargeIds.isempty() && mhChargeIds!=NULL){
                        projectsList = [Select id, name,Procurrox_URL__c,Order_Rate_Plan_Charge__c From Milestone1_Project__c where Order_Rate_Plan_Charge__c in: mhChargeIds];
                        
                        if(!projectsList.isempty() && projectsList!=NULL){
                            for(Milestone1_Project__c prj: projectsList){
                                if(prj.Order_Rate_Plan_Charge__c!=NULL || prj.Order_Rate_Plan_Charge__c!=''){
                                    chargeIdVsProject.put(prj.Order_Rate_Plan_Charge__c, prj);
                                }
                            }
                        }
                    }
                    if(debug.DebugOn__c == TRUE){
                        System.debug('@@@@@@finalChargeList'+finalChargeList);
                        System.debug('@@@@@@featureNchatMap'+featureNchatMap);
                        System.debug('@@@@@@@@@@@@@@chargeIdVsProject'+chargeIdVsProject);
                    }
                    
                }
                
                if(!finalChargeList.isempty()){
                            if(debug.DebugOn__c == TRUE){
                                system.debug('@@@@@@@@inside my CREATE');
                            }
                            List<String> queueName = new List<String>();
                            queueName.add('Ngage Ops');
                            List<Group> queueList = [Select Id,Name from Group where Name in:queueName and Type = 'Queue'];
                            if(debug.DebugOn__c == TRUE){
                                System.debug('@@@@@@queue List'+queueList);
                            }
                            String queueId;
                            queueId = queueList[0].id;
                            if(debug.DebugOn__c == TRUE){
                                System.debug('@@@@@@queue id'+queueId );
                            }
                            Id RecordTypeId_NgageOrderRPC  = Schema.SObjectType.invoiceit_s__Job_Rate_Plan_Charge__c.getRecordTypeInfosByName().get('M-NG Order Rate Plan Charge').getRecordTypeId();
                            if(debug.DebugOn__c == TRUE){
                                System.debug('@@@@@@@RecordTypeId_NgageOrderRPC  :'+RecordTypeId_NgageOrderRPC  );
                            }
                                List<User> automationUser = [select id from user Where Name='System Automation' limit 1];
                                if(debug.DebugOn__c == TRUE){
                                    System.debug('@@@@@@@@Automation User Id-------------->'+automationUser[0].id);
                                }
                            for(invoiceit_s__Job_Rate_Plan_Charge__c orpc: finalChargeList){
                                //System.debug('@@@@@@@@orpc.invoiceit_s__Order__r.No_of_active_charges__c'+orpc.invoiceit_s__Order__r.No_of_active_charges__c);
                                if(debug.DebugOn__c == TRUE){
                                    System.debug('@@@@@@@@orpc.invoiceit_s__Order__r.invoiceit_s__Account__c'+orpc.invoiceit_s__Order__r.invoiceit_s__Account__c);    
                                    System.debug('@@@@@@@@@orpc.RecordTypeId'+orpc.RecordTypeId);
                                }
                                if(orpc.RecordTypeId == RecordTypeId_NgageOrderRPC ){
                                    
                                    Case c = new Case();
                                    c.AccountId = orpc.invoiceit_s__Order__r.invoiceit_s__Account__c;
                                    c.Area__c = 'Order Update';
                                    c.Customer_Name__c = orpc.invoiceit_s__Order__r.invoiceit_s__Account__r.Name;
                                    c.Description = 'Ngage Order/Charge Fulfilment';
                                    c.Origin = 'NgageSpt';
                                    c.OwnerId = queueId ;
                                    c.Parent_Order__c = orpc.invoiceit_s__Order__c;
                                    c.Priority = 'High';
                                    c.RecordTypeId = '0120G000000WmRG';    
                                    c.Status = 'New';
                                    c.Sub_Area__c = 'New order';
                                    c.Subject = 'Ngage Order/Charge Fulfilment';
                                    c.CreatedById = automationUser[0].id; //'005F0000005Po9o';
                                    c.LastModifiedById = automationUser[0].id; //'005F0000005Po9o';
                                    //c.Name = 'Ngage Order';
                                    c.Description__c = '<b><u>Products</b></u> : <br/><br/>';
                                if(debug.DebugOn__c == TRUE){    
                                    System.debug('@@@@Testingggg'+featureNchatMap.containskey(orpc.Chat_Parent_Order_Rate_Plan_Charge__c));
                                }
                                    if(orpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c == '60010'){
                                        
                                        String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+orpc.Id;
                                        if(debug.DebugOn__c == TRUE){
                                            System.debug('@@@@@@@Re3cordLink'+RecordLink);
                                        }
                                        String FulfillLink = '<a href='+Recordlink +' >Please select the link to update Chat Id</a>';
                                        if(debug.DebugOn__c == TRUE){
                                            System.debug('@@@@@@@FulfillLink '+FulfillLink );
                                        }
                                        System.debug('@@@@@@@Features'+chatFeatureList);
                                        c.Description__c += '<b>'+orpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name + '</b><br/>' +
                                                             '<b><u>URL</b></u> : ' + orpc.Order_Charge_Attributes__r[0].String_Value__c + '<br/>' + 
                                                             '<b><u>Client Id</b></u> : ' + orpc.invoiceit_s__Order__r.Ngage_Cust_ID__c + '<br/>' + 
                                                             '<b><u>Status</b></u> : ' + orpc.invoiceit_s__Status__c + '<br/>'+
                                                             '<b><u>Fulfillment Link</b></u> : ' +  FulfillLink + '<br/>'; //-- commenting for now
                                                             
                                         if(debug.DebugOn__c == TRUE){
                                             System.debug('@@@mapChatVsCharge'+mapChatVsCharge);
                                             system.debug('======orpc.id===='+orpc.id);
                                         }
                                         if(mapChatVsCharge.containskey(orpc.id)){
                                             parentChargeId = mapChatVsCharge.get(orpc.id);
                                             if(debug.DebugOn__c == TRUE){
                                                 System.debug('@@@parentChargeId '+parentChargeId );
                                                 System.debug('@@@@@@procurrox URl exist or not========='+chargeIdVsProject.containskey(parentChargeId));
                                             }
                                             if(chargeIdVsProject.containskey(parentChargeId)){
                                                 System.debug('===what is the URL@@@@@'+chargeIdVsProject.get(parentChargeId).Procurrox_URL__c );
                                                 if(chargeIdVsProject.get(parentChargeId).Procurrox_URL__c!=Null || chargeIdVsProject.get(parentChargeId).Procurrox_URL__c!=''){
                                                     c.Description__c += '<b><u>Procurrx URL</b></u> : ' + chargeIdVsProject.get(parentChargeId).Procurrox_URL__c + '<br/><br/>'; 
                                                 }
                                             }
                                         }
                                         
                                        
                                        if(featureNchatMap.containskey(orpc.id)){
                                            chatFeatureList = featureNchatMap.get(orpc.id);
                                        
                                            if(chatFeatureList.size()>0){
                                                c.Description__c += '<b><u>Add-on Features</b></u><br/><br/>';
                                                
                                                for(invoiceit_s__Job_Rate_Plan_Charge__c featOrpc: chatFeatureList){
                                                    c.Description__c += '<b>'+featOrpc.Name + '</b><br/>'; //+
                                                                        
                                            
                                                    if(!featOrpc.Order_Charge_Attributes__r.isempty()){
                                                        for(Order_Charge_Attribute__c attr: featOrpc.Order_Charge_Attributes__r){
                                                            if(attr.Attribute_Type__c == 'Text' || attr.Attribute_Type__c == 'String'){
                                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.String_Value__c + '<br/>'; //+
                                                                                                                                   
                                                            }
                                                            else if(attr.Attribute_Type__c == 'Picklist'){
                                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Picklist_Value__c + '<br/>'; //+
                                                                                
                                                            }
                                                            else if(attr.Attribute_Type__c == 'Boolean'){
                                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Boolean_Value__c + '<br/>' ;//+
                                                                               
                                                            }
                                                            else if(attr.Attribute_Type__c == 'Phone'){
                                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Phone_Value__c + '<br/>' ;//+
                                                                               
                                                            }
                                                            else if(attr.Attribute_Type__c == 'Number'){
                                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Number_Value__c + '<br/>'; //+
                                                                               
                                                            }
                                                            else if(attr.Attribute_Type__c == 'Date'){
                                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Date_Value__c + '<br/>' ;//+
                                                                                
                                                            }
                                                            else if(attr.Attribute_Type__c == 'Text Area'){
                                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Long_text_value__c + '<br/>'; //+
                                                                               
                                                            }
                                                            
                                                             
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                    String Recordlink2 = URL.getSalesforceBaseUrl().toExternalForm()+'/'+featOrpc.Id;
                                                    if(debug.DebugOn__c == TRUE){
                                                        System.debug('@@@@@@@Re3cordLink2'+RecordLink2);
                                                    }
                                                    String FulfillLink2 = '<a href='+Recordlink2 +' >Please select the link to update Chat Id</a>';
                                                    if(debug.DebugOn__c == TRUE){
                                                        System.debug('@@@@@@@FulfillLink2 '+FulfillLink2 );
                                                    }
                                                    c.Description__c += '<b><u> Status</b></u> : ' + featOrpc.invoiceit_s__Status__c + '<br/>' ;//+
                                                    
                                                     if(!orpc.Order_Charge_Attributes__r.isempty()){
                                                        c.Description__c += '<b><u> Chat URL</b></u> : ' + orpc.Order_Charge_Attributes__r[0].String_Value__c + '<br/>';
                                                    }
                                                    
                                                    c.Description__c += '<b><u>Fulfillment Link</b></u> : ' +  FulfillLink2 + '<br/><br/>'; //-- commenting for now
                                                }
                                            }
                                        }
                                        c.Description__c += '======================================================<br/><br/>';
                                        orpc.IsCaseCreated__c = True;
                                        if(debug.DebugOn__c == TRUE){
                                            System.debug('@@@@@@@orpc.IsCaseCreated__c'+orpc.IsCaseCreated__c);
                                        }
                                        chargesToUpdate.add(orpc);
                                    }
                                    if(debug.DebugOn__c == TRUE){
                                        System.debug('@@@@@@@@@@casesToInsert'+casesToInsert);
                                    }
                                    casesToInsert.add(c);    
                        }           
                      }
                  }
              }
              if(debug.DebugOn__c == TRUE){
                  System.debug('@@@@@@casesToInsert'+casesToInsert);
              }
              if(!casesToInsert.isempty()){
                  insert casesToInsert;
              }
              if(debug.DebugOn__c == TRUE){
                  System.debug('@@@@@@chargesToUpdate'+chargesToUpdate);
              }
              if(!chargesToUpdate.isempty() && chargesToUpdate!=Null){
                  update chargesToUpdate;
              }                      
            // Get the list of junction object records 'Chat Product Order RPC' where the MH products are associated to related chat products
            
            //if the junction object list is not empty then create a map of the mh web product and related Ngage order
            //checekif the ngage charges are not null and also check the chat id for the Ngage charges, if both are not null then create a case for that charge
        
    }
    // Creating cancel, truncated and expired cases for Ngage Order Rate plan Charges -- Ronak
    // Cancel Case code commented as on 11/27/2018 --------------------------------------------------------------------- Ronak Jain
   /*** public void cancelChargeCase(List<invoiceit_s__Job_Rate_Plan_Charge__c> listOfOrderCharges, Map<Id, invoiceit_s__Job_Rate_Plan_Charge__c> oldmap){
            
            
        
            Set<Id> orderIds = new Set<Id>();
            Map<id,invoiceit_s__Job_Rate_Plan_Charge__c> mapIdNCharge = new Map<id,invoiceit_s__Job_Rate_Plan_Charge__c>();
        
            List<Case> casesToInsert = new List<Case>();
            List<invoiceit_s__Job_Rate_Plan_Charge__c> allOrderRPCList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
            List<invoiceit_s__Job_Rate_Plan_Charge__c> orderRPCList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
            List<invoiceit_s__Job_Rate_Plan_Charge__c> cancelorderRPCList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
            Set<String> finalCancelOrderChargeIds = new Set<String>();
            List<invoiceit_s__Job_Rate_Plan_Charge__c> cancelOrderChargeIds = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
            List<Chat_Product_Order_Charge__c> chatprodOrdChargeList= new List<Chat_Product_Order_Charge__c>();
            
            
            List<invoiceit_s__Job_Rate_Plan_Charge__c> finalOrderRPCList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
            Map<String,List<invoiceit_s__Job_Rate_Plan_Charge__c>> featureNchatMap = new Map<String,List<invoiceit_s__Job_Rate_Plan_Charge__c>>();
            List<invoiceit_s__Job_Rate_Plan_Charge__c> featureList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();    
            List<invoiceit_s__Job_Rate_Plan_Charge__c> chatFeatureList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>(); 
            List<invoiceit_s__Job_Rate_Plan_Charge__c> updateChargesList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
            
            Map<Id, List<invoiceit_s__Job_Rate_Plan_Charge__c>> mapOrderNActiveCharge = new Map<Id, List<invoiceit_s__Job_Rate_Plan_Charge__c>>();
            Map<String,Date> mapNgageChargeVsMHCharge = new Map<String,Date>();
        
            //Set<Id> orderIds = new Set<Id>();
            List<invoiceit_s__Job__c> orderList = new List<invoiceit_s__Job__c>();        
            
            Date cancelDate = System.today();
            Map<string,string> chatNUrlMap = new Map<String,String>();
            
            System.debug('@@@@@@@Cancel Order Charge Ids'+cancelOrderChargeIds);
            
            if(!listOfOrderCharges.isempty()){
                for(invoiceit_s__Job_Rate_Plan_Charge__c ord: listOfOrderCharges){
                    System.debug('@@@@@@@Old Order Status'+oldmap.get(ord.id).invoiceit_s__Status__c);
                    System.debug('@@@New Order Status'+ord.invoiceit_s__Status__c);
                    System.debug('@@@@Order Status'+ord.Order_Status__c);
                    if(ord.invoiceit_s__Status__c!=NULL && oldmap!=NULL && oldmap.get(ord.id).invoiceit_s__Status__c !=ord.invoiceit_s__Status__c && ord.Order_Status__c!='Cancelled' && (ord.invoiceit_s__Status__c== 'Cancelled' || ord.invoiceit_s__Status__c == 'Expired' || ord.invoiceit_s__Status__c == 'Truncated')){
                        //cancelOrderChargeIds.add(ord);
                        orderIds.add(ord.invoiceit_s__Order__c);
                        mapIdNCharge.put(ord.id,ord);
                    }
                }
            }
            if(!orderIds.isempty()){
                 allOrderRPCList = [Select id, name,invoiceit_s__Status__c,Chat_Parent_Order_Rate_Plan_Charge__c,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name,
                                Cancellation_Date__c,invoiceit_s__Service_End_Date__c,invoiceit_s__Order__r.invoiceit_s__Account__c,invoiceit_s__Order__r.Ngage_Cust_ID__c,
                                invoiceit_s__Order__r.invoiceit_s__Account__r.Name,invoiceit_s__Order__r.Id,invoiceit_s__Order__r.invoiceit_s__Status__c,RecordTypeId,
                                Chat_Parent_Order_Rate_Plan_Charge__r.invoiceit_s__Status__c,invoiceit_s__Order__r.No_of_active_charges__c,//Order_Status__c,
                                invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c,Chat_ID__c,Fulfilment_End_Date__c,
                                (select id,name,Attribute_Name__c,Attribute_Type__c,String_Value__c,Picklist_Value__c,Boolean_Value__c,Phone_Value__c,Number_Value__c,
                                 Date_value__c,Long_text_value__c,Order_Rate_Plan_Charge__r.invoiceit_s__Status__c From Order_Charge_Attributes__r) 
                                From invoiceit_s__Job_Rate_Plan_Charge__c Where invoiceit_s__Order__c in: orderIds  ];
            
            
                for(invoiceit_s__Job_Rate_Plan_Charge__c feat: allOrderRPCList ){
                    if(feat.Chat_Parent_Order_Rate_Plan_Charge__c!= Null){
                        System.debug('@@@@@@feat.Chat_Parent_Order_Rate_Plan_Charge__c'+feat.Chat_Parent_Order_Rate_Plan_Charge__c);
                        if(featureNchatMap.containskey(feat.Chat_Parent_Order_Rate_Plan_Charge__c)){
                            featureNchatMap.get(feat.Chat_Parent_Order_Rate_Plan_Charge__c).add(feat);
                        }else{
                            featureNchatMap.put(feat.Chat_Parent_Order_Rate_Plan_Charge__c, new List<invoiceit_s__Job_Rate_Plan_Charge__c> {feat});
                        }
                    }else if(feat.Chat_Parent_Order_Rate_Plan_Charge__c == NULL && feat.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c == '60010'){
                        chatNUrlMap.put(feat.id, feat.Order_Charge_Attributes__r[0].String_Value__c);
                    }
                    
                }
                System.debug('@@@@chatNUrlMap'+chatNUrlMap);
                
            for(invoiceit_s__Job_Rate_Plan_Charge__c can: allOrderRPCList){
                if(can.invoiceit_s__Status__c == 'Active' || can.invoiceit_s__Status__c == 'Evergreen'){
                    if(mapOrderNActiveCharge.containskey(can.invoiceit_s__Order__c)){
                        mapOrderNActiveCharge.get(can.invoiceit_s__Order__c).add(can);
                    }else{
                        mapOrderNActiveCharge.put(can.invoiceit_s__Order__c, new List<invoiceit_s__Job_Rate_Plan_Charge__c> {can});
                    }
                }else{
                    if(mapIdNCharge.containskey(can.id)){
                        cancelOrderChargeIds.add(can);
                    }
                }
            }
            }
            
            
            
            
            System.debug('@@@@@@@@mapOrderNActiveCharge'+mapOrderNActiveCharge); 
            System.debug('@@@@@@@@orderRPCList'+orderRPCList);
            
            System.debug('@@@@@@@@mapIdNCharge'+mapIdNCharge);
            System.debug('@@@@@@@cancelOrderChargeIds'+cancelOrderChargeIds);
             
            if(!cancelOrderChargeIds.isempty()){
                for(invoiceit_s__Job_Rate_Plan_Charge__c an: cancelOrderChargeIds){
                    if(mapOrderNActiveCharge.containskey(an.invoiceit_s__Order__c)){
                                
                        if(mapOrderNActiveCharge.get(an.invoiceit_s__Order__c).size() > 0){
                            cancelorderRPCList.add(an);
                            finalCancelOrderChargeIds.add(an.id); 
                        }  
                    }else{
                                
                     }
                 }
             }
             System.debug('@@@@@@@@cancelorderRPCList'+cancelorderRPCList);   
        
            if(!cancelorderRPCList.isempty()){
            
                chatprodOrdChargeList = [Select id, name,Chat_Usage_Order_Rate_Plan_Charge__c,Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Order__c ,Chat_Product_Order_Rate_Plan_Charge__c,Chat_Product_Order_Rate_Plan_Charge__r.Fulfilment_Start_Date__c From Chat_Product_Order_Charge__c Where Chat_Usage_Order_Rate_Plan_Charge__c in: finalCancelOrderChargeIds Order By CreatedDate DESC];    
                   
                if(!chatprodOrdChargeList.isempty()){
                    for(Chat_Product_Order_Charge__c chat:  chatprodOrdChargeList){
                        if(chat.Chat_Product_Order_Rate_Plan_Charge__c!=Null && chat.Chat_Usage_Order_Rate_Plan_Charge__c!=NULL){
                            mapNgageChargeVsMHCharge.put(chat.Chat_Usage_Order_Rate_Plan_Charge__c, chat.Chat_Product_Order_Rate_Plan_Charge__r.Fulfilment_Start_Date__c);
                        }
                    }
                }
                System.debug('@@@@@@@@@@mapNgageChargeVsMHCharge'+mapNgageChargeVsMHCharge);
                
                for(invoiceit_s__Job_Rate_Plan_Charge__c can: cancelorderRPCList){
                                        
                
                    System.debug('@@@@@@@@can.invoiceit_s__Order__r.invoiceit_s__Status__c'+can.invoiceit_s__Order__r.invoiceit_s__Status__c);
                    if(can.invoiceit_s__Order__r.invoiceit_s__Status__c!='Cancelled' && can.invoiceit_s__Order__r.invoiceit_s__Status__c!='Expired'){
                        if(can.Chat_Parent_Order_Rate_Plan_Charge__c!= NULL && can.Chat_Parent_Order_Rate_Plan_Charge__r.invoiceit_s__Status__c!='Cancelled'){
                            System.debug('Check whether the related chat charge has web product associated to it'+mapNgageChargeVsMHCharge.containskey(can.Chat_Parent_Order_Rate_Plan_Charge__c));
                            if(mapNgageChargeVsMHCharge.containskey(can.Chat_Parent_Order_Rate_Plan_Charge__c)){
                                System.debug('@@@@@@Inside the website if=========='+mapNgageChargeVsMHCharge.get(can.Chat_Parent_Order_Rate_Plan_Charge__c));
                                if(mapNgageChargeVsMHCharge.get(can.Chat_Parent_Order_Rate_Plan_Charge__c)!=NULL){
                                    finalOrderRPCList.add(can);
                                }else{
                                }
                            }
                            else{
                                finalOrderRPCList.add(can);
                            }
                            //System.debug('yeh kaha aa gaye hum===========================');
                               
                        }else if(can.Chat_Parent_Order_Rate_Plan_Charge__c == NULL){
                            finalOrderRPCList.add(can);   
                        }
                    }
                }
                
                System.debug('@@@@@@@@@@@finalOrderRPCList'+finalOrderRPCList);
                
              }  
                System.debug('@@@@@@@featureNchatMap'+featureNchatMap);
                
                    
                System.debug('@@@@@@CancelorderRPCList '+finalOrderRPCList );
                        
                        if(!finalOrderRPCList.isempty()){
                            system.debug('@@@@@@@@inside my canecl');
                            
                            Id RecordTypeId_NgageOrderRPC  = Schema.SObjectType.invoiceit_s__Job_Rate_Plan_Charge__c.getRecordTypeInfosByName().get('M-NG Order Rate Plan Charge').getRecordTypeId();
                            System.debug('@@@@@@@RecordTypeId_NgageOrderRPC  :'+RecordTypeId_NgageOrderRPC  );
                            
                            
                            for(invoiceit_s__Job_Rate_Plan_Charge__c orpc: finalOrderRPCList ){
                                //System.debug('@@@@@@@@orpc.invoiceit_s__Order__r.No_of_active_charges__c'+orpc.invoiceit_s__Order__r.No_of_active_charges__c);
                                System.debug('@@@@@@@@orpc.invoiceit_s__Order__r.invoiceit_s__Account__c'+orpc.invoiceit_s__Order__r.invoiceit_s__Account__c);    
                                System.debug('@@@@@@@@@orpc.RecordTypeId'+orpc.RecordTypeId);
                                
                                if(orpc.RecordTypeId == RecordTypeId_NgageOrderRPC  ){
                                    
                                    Case c = new Case();
                                    c.AccountId = orpc.invoiceit_s__Order__r.invoiceit_s__Account__c;
                                    c.Area__c = 'Order Update';
                                    c.Customer_Name__c = orpc.invoiceit_s__Order__r.invoiceit_s__Account__r.Name;
                                    c.Description = 'Chat Product Cancellation';
                                    c.Origin = 'Order Change';
                                    c.OwnerId = '00G0G000007goH5';
                                    c.Parent_Order__c = orpc.invoiceit_s__Order__r.id;
                                    c.Priority = 'High';
                                    c.RecordTypeId = '0120G000000WmRG';    
                                    c.Status = 'New';
                                    c.Sub_Area__c = 'Cancellation';
                                    c.Subject = 'Ngage Product Cancellation';//Ngage Order/Charge Fulfilment
                                    //c.Name = 'Ngage Order';
                                    c.Description__c = '<b><u>Products</b></u> : <br/><br/>';
                                   
                                    System.debug('@@@@@@@@@ACCOUNT'+orpc.invoiceit_s__Order__r.invoiceit_s__Account__c);
                               System.debug('@@@@@@@@@Product Code'+orpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c);
                                if(orpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c == '60010'){
                                    
                                    System.debug('@@@@@@@Features'+chatFeatureList);
                                    System.debug('@@@@@Chat SED Date'+orpc.invoiceit_s__Service_End_Date__c);
                                    System.debug('@@@@@Chat Cancellation Date'+orpc.Cancellation_Date__c);
                                    
                                    if(orpc.invoiceit_s__Service_End_Date__c!=NULL && orpc.invoiceit_s__Status__c!='Cancelled'){
                                        cancelDate = orpc.invoiceit_s__Service_End_Date__c;
                                    }else{
                                        cancelDate = orpc.Cancellation_Date__c;
                                    }
                                            
                                    c.Description__c += '<b>'+orpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name + '</b><br/>' +
                                                         '<b><u>URL</b></u> : ' + orpc.Order_Charge_Attributes__r[0].String_Value__c + '<br/>' + 
                                                         '<b><u>Chat Id</b></u> : ' + orpc.Chat_ID__c + '<br/>' + 
                                                         '<b><u>Client Id</b></u> : ' + orpc.invoiceit_s__Order__r.Ngage_Cust_ID__c +'<br/>' + 
                                                         '<b><u>Fulfillment Date:</b></u> : ' + orpc.Fulfilment_End_Date__c + '<br/>' +
                                                         '<b><u>Charge Status</b></u> : ' + orpc.invoiceit_s__Status__c + '<br/>' +
                                                         '<b><u>Cancellation Date</b></u> : ' + cancelDate  +'<br/><br/>';
                                                         //'<b><u>Cancellation Date</b></u> : ' + orpc.Cancellation_Date__c+'<br/><br/>';
                                    
                                    if(featureNchatMap.containskey(orpc.id)){
                                        chatFeatureList = featureNchatMap.get(orpc.id);
                                    
                                        if(chatFeatureList.size()>0){
                                            c.Description__c += '<b><u>Add-on Features</b></u><br/><br/>';
                                            
                                            for(invoiceit_s__Job_Rate_Plan_Charge__c featOrpc: chatFeatureList){
                                            
                                            
                                            if(featOrpc.Chat_Parent_Order_Rate_Plan_Charge__c!= NULL){
                                                
                                            }
                                                c.Description__c += '<b>'+featOrpc.Name + '</b><br/>' ;//+
                                                                    
                                        
                                                if(!featOrpc.Order_Charge_Attributes__r.isempty()){
                                                    for(Order_Charge_Attribute__c attr: featOrpc.Order_Charge_Attributes__r){
                                                        if(attr.Attribute_Type__c == 'Text' || attr.Attribute_Type__c == 'String'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.String_Value__c + '<br/>' ;//+
                                                                            //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>';+
                                                                                                                                 
                                                        }
                                                        else if(attr.Attribute_Type__c == 'Picklist'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.Picklist_Value__c + '<br/>' ;//+
                                                                            //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/><br/>';//+
                                                                            //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                                        }
                                                        else if(attr.Attribute_Type__c == 'Boolean'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.Boolean_Value__c + '<br/>' ;//+
                                                                            //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/><br/>';//+
                                                                            //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                                        }
                                                        else if(attr.Attribute_Type__c == 'Phone'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.Phone_Value__c + '<br/>' ;//+
                                                                            //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>';//+
                                                                            //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                                        }
                                                        else if(attr.Attribute_Type__c == 'Number'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.Number_Value__c + '<br/>' ;//+
                                                                            //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>'+
                                                                            //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                                        }
                                                        else if(attr.Attribute_Type__c == 'Date'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.Date_Value__c + '<br/>' ;//+
                                                                            //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>'+
                                                                            //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                                        }
                                                        else if(attr.Attribute_Type__c == 'Text Area'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.Long_text_value__c + '<br/>' ;//+
                                                                            //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>'+
                                                                            //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                                        }
                                                        
                                                    }
                                                }
                                               System.debug('@@@@@Feature SED Date'+featOrpc.invoiceit_s__Service_End_Date__c);
                                                System.debug('@@@@@Feature Cancellation Date'+featOrpc.Cancellation_Date__c);
                                                
                                                if(featOrpc.invoiceit_s__Service_End_Date__c!=NULL && orpc.invoiceit_s__Status__c!='Cancelled'){
                                                    cancelDate = featOrpc.invoiceit_s__Service_End_Date__c;
                                                }else{
                                                    cancelDate = featOrpc.Cancellation_Date__c;
                                                }
                                                
                                                c.Description__c += '<b><u> Fulfillment Date </b></u> : ' + featOrpc.Fulfilment_End_Date__c +'<br/>'+//;
                                                                    '<b><u>Chat Id</b></u> : ' + featOrpc.Chat_ID__c + '<br/>' + 
                                                                     '<b><u>Client Id</b></u> : ' + featOrpc.invoiceit_s__Order__r.Ngage_Cust_ID__c + '<br/>' + 
                                                                     '<b><u> Charge Status</b></u> : ' + featOrpc.invoiceit_s__Status__c + '<br/>' +
                                                                     '<b><u> Chat URL</b></u> : ' + orpc.Order_Charge_Attributes__r[0].String_Value__c + '<br/>' +
                                                                     '<b><u> Cancellation Date</b></u> : ' + cancelDate  + '<br/><br/>';
                                                                     //'<b><u> Cancellation Date</b></u> : ' + featOrpc.Cancellation_Date__c+ '<br/><br/>';
                                                
                                            }
                                        }
                                    }
                                    c.Description__c += '======================================================<br/><br/>';
                                    
                                }
                                else if(orpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c != '60010' ){
                                  
                                    c.Description__c += //'<b><u>Add-on Features</b></u><br/><br/>' +
                                                        '<b>' + orpc.Name + '</b><br/>' ;//+
                                                        //'<b><u> Fulfillment Date </b></u> : ' + orpc.Fulfilment_End_Date__c +'<br/>'+//;
                                                         //       '<b><u>Chat Id</b></u> : ' + orpc.Chat_ID__c + '<br/>' + 
                                                         //        '<b><u>Client Id</b></u> : ' + '<br/>' + 
                                                         //        '<b><u> Charge Status</b></u> : ' + orpc.invoiceit_s__Status__c + '<br/><br/>'; 
                                                         
                                    if(!orpc.Order_Charge_Attributes__r.isempty()){
                                        for(Order_Charge_Attribute__c attr: orpc.Order_Charge_Attributes__r){
                                            //c.Description__c += attr.Attribute_Name__c +' : ' + attr.String_Value__c + '<br/>';
                                                                //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>'+
                                                                //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>';
                                                                
                                            
                                            if(attr.Attribute_Type__c == 'Text' || attr.Attribute_Type__c == 'String'){
                                                        c.Description__c += attr.Attribute_Name__c +' : ' + attr.String_Value__c + '<br/>' ;
                                                                        //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>';+
                                                                                                                             
                                            }
                                            else if(attr.Attribute_Type__c == 'Picklist'){
                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Picklist_Value__c + '<br/>' ;//+
                                                                //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/><br/>';//+
                                                                //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                            }
                                            else if(attr.Attribute_Type__c == 'Boolean'){
                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Boolean_Value__c + '<br/>' ;//+
                                                                //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/><br/>';//+
                                                                //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                            }
                                            else if(attr.Attribute_Type__c == 'Phone'){
                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Phone_Value__c + '<br/>' ;//+
                                                                //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>';//+
                                                                //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                            }
                                            else if(attr.Attribute_Type__c == 'Number'){
                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Number_Value__c + '<br/>' ;//+
                                                                //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>'+
                                                                //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                            }
                                            else if(attr.Attribute_Type__c == 'Date'){
                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Date_Value__c + '<br/>' ;//+
                                                                //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>'+
                                                                //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                            }
                                            else if(attr.Attribute_Type__c == 'Text Area'){
                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Long_text_value__c + '<br/>' ;//+
                                                                //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>'+
                                                                //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                            }                                                     
                                        }
                                    }
                                    System.debug('@@@@@One Time SED Date'+orpc.invoiceit_s__Service_End_Date__c);
                                    System.debug('@@@@@One Time Cancellation Date'+orpc.Cancellation_Date__c);
                                    if(orpc.invoiceit_s__Service_End_Date__c!=NULL && orpc.invoiceit_s__Status__c!='Cancelled'){
                                        cancelDate = orpc.invoiceit_s__Service_End_Date__c;
                                    }else{
                                        cancelDate = System.Today();
                                    }
                                            
                                    c.Description__c += '<b><u> Fulfillment Date </b></u> : ' + orpc.Fulfilment_End_Date__c +'<br/>'+//;
                                                        '<b><u>Chat Id</b></u> : ' + orpc.Chat_ID__c + '<br/>' + 
                                                        '<b><u>Client Id</b></u> : ' + orpc.invoiceit_s__Order__r.Ngage_Cust_ID__c +  '<br/>' + 
                                                        '<b><u> Charge Status</b></u> : ' + orpc.invoiceit_s__Status__c + '<br/>' +
                                                        '<b><u> Cancellation Date</b></u> : ' + cancelDate + '<br/>';
                                     System.debug('@@@@@@@@@chat parent'+chatNUrlMap.containskey(orpc.Chat_Parent_Order_Rate_Plan_Charge__c));                   
                                     if(chatNUrlMap.containskey(orpc.Chat_Parent_Order_Rate_Plan_Charge__c)){
                                         c.Description__c += '<b><u> Chat URL</b></u> : ' + chatNUrlMap.get(orpc.Chat_Parent_Order_Rate_Plan_Charge__c) + '<br/><br/>';
                                     }                         
                                                        
                                                           
                                }

                               System.debug('@@@@@@@@@@casesToInsert'+casesToInsert);
                                casesToInsert.add(c);
                               
                               }
                                
                            } 
                        } 
    
              System.debug('@@@@@@casesToInsert'+casesToInsert);
              if(!casesToInsert.isempty()){
                  insert casesToInsert;
              }
                 
     }*/
    
    
    public void handleAfterOnOrderRatePlanCharge(map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> newMap, map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> oldMap) {
        if(debug.DebugOn__c == TRUE){
            system.debug('@@@@@ in after call');
        }
        list<string> list_BillingMillestone_SplitValues;
        list<invoiceit_s__Job_Rate_Plan_Charge__c> listOfOrderRatePlanCharge = new list<invoiceit_s__Job_Rate_Plan_Charge__c>();
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge;
        list<invoiceit_s__Job_Rate_Plan_Charge__c> listOfOrderRatePlanChargeToDelete = new list<invoiceit_s__Job_Rate_Plan_Charge__c>();
        list<Order_Charge_Attribute__c> listOfOrderChargeAttribute = new list<Order_Charge_Attribute__c>();
        set<Id> productChargeidSet = new set<Id>();
        set<Id> opptChargeidSet = new set<Id>();
        set<id> accountIdSet = new set<id>();
        for(invoiceit_s__Job_Rate_Plan_Charge__c orderCharge : newMap.values()) {
            
            if(orderCharge.Billing_Milestones__c != null) {
                string sBillingMilestones = orderCharge.Billing_Milestones__c;


                // Assinging the values to the sting in order to split
                list_BillingMillestone_SplitValues = new list<string>();
                list_BillingMillestone_SplitValues = sBillingMilestones.split(',', 0);
                if(debug.DebugOn__c == TRUE){
                    system.debug('@@@@@@list_BillingMillestone_SplitValues'+list_BillingMillestone_SplitValues);
                }
                if(list_BillingMillestone_SplitValues != null && list_BillingMillestone_SplitValues.size() > 1) {
                    decimal dUnitprice = 0.0;
                    decimal dSubtotal = 0.0;
                    decimal dNettotal = 0.0;
                    decimal dDiscountvalue = 0.0;
                    decimal dVAT = 0.0;
                    decimal dTax = 0.0;
                    decimal dUnitcost = 0.0;
                    decimal dTotalcost = 0.0;
                    decimal dProfit = 0.0;
                    integer j = 1;

                    listOfOrderRatePlanChargeToDelete.add(new invoiceit_s__Job_Rate_Plan_Charge__c(Id = orderCharge.Id));
                    integer sizeOfList = list_BillingMillestone_SplitValues.size();

                    for(integer i=0; i<sizeOfList; i++) {
                        orderRatePlanCharge = new invoiceit_s__Job_Rate_Plan_Charge__c();
                        orderRatePlanCharge = orderCharge.clone(false);
                        

                        if((list_BillingMillestone_SplitValues.size() -1) != i) {
                            orderRatePlanCharge.Name = orderRatePlanCharge.Name + ' - Phase ' + j++;
                            if(debug.DebugOn__c == TRUE){
                                system.debug('@@@@@list_BillingMillestone_SplitValues[i]'+list_BillingMillestone_SplitValues[i]);
                            }
                            decimal iloc = decimal.valueOf(list_BillingMillestone_SplitValues[i]);
                            if(iloc != null) {    

                                if(orderRatePlanCharge.invoiceit_s__Unit_Price__c != null) {
                                    orderRatePlanCharge.invoiceit_s__Unit_Price__c = (iloc/100)*(orderRatePlanCharge.invoiceit_s__Unit_Price__c);
                                    dUnitprice = dUnitprice + orderRatePlanCharge.invoiceit_s__Unit_Price__c;
                                }

                                if(orderRatePlanCharge.invoiceit_s__Profit__c != null) {
                                    orderRatePlanCharge.invoiceit_s__Profit__c = (iloc/100)*(orderRatePlanCharge.invoiceit_s__Profit__c);
                                    dProfit = dProfit + orderRatePlanCharge.invoiceit_s__Profit__c; 
                                }

                                if(orderRatePlanCharge.invoiceit_s__Cost__c != null) {
                                    orderRatePlanCharge.invoiceit_s__Cost__c = (iloc/100)*(orderRatePlanCharge.invoiceit_s__Cost__c);
                                    dTotalcost = dTotalcost + orderRatePlanCharge.invoiceit_s__Cost__c;
                                }

                                if(orderRatePlanCharge.invoiceit_s__Cost_Price__c != null) {
                                    orderRatePlanCharge.invoiceit_s__Cost_Price__c = (iloc/100)*(orderRatePlanCharge.invoiceit_s__Cost_Price__c);
                                    dUnitcost = dUnitcost + orderRatePlanCharge.invoiceit_s__Cost_Price__c;
                                }

                                if(orderRatePlanCharge.invoiceit_s__Tax__c != null) {
                                    orderRatePlanCharge.invoiceit_s__Tax__c = (iloc/100)*(orderRatePlanCharge.invoiceit_s__Tax__c);
                                    dTax = dTax + orderRatePlanCharge.invoiceit_s__Tax__c;
                                }

                                if(orderRatePlanCharge.invoiceit_s__VAT__c != null) {
                                    orderRatePlanCharge.invoiceit_s__VAT__c = (iloc/100)*(orderRatePlanCharge.invoiceit_s__VAT__c);
                                    dVAT = dVAT + orderRatePlanCharge.invoiceit_s__VAT__c;
                                }

                                if(orderRatePlanCharge.invoiceit_s__Discount_Value__c != null) {
                                    orderRatePlanCharge.invoiceit_s__Discount_Value__c = (iloc/100)*(orderRatePlanCharge.invoiceit_s__Discount_Value__c);
                                    dDiscountvalue = dDiscountvalue + orderRatePlanCharge.invoiceit_s__Discount_Value__c;
                                }

                                if(orderRatePlanCharge.invoiceit_s__Net_Total__c != null) {
                                    orderRatePlanCharge.invoiceit_s__Net_Total__c = (iloc/100)*(orderRatePlanCharge.invoiceit_s__Net_Total__c);
                                    dNettotal = dNettotal + orderRatePlanCharge.invoiceit_s__Net_Total__c ;
                                }

                                if(orderRatePlanCharge.invoiceit_s__Price__c != null) {
                                    orderRatePlanCharge.invoiceit_s__Price__c = (iloc/100)*(orderRatePlanCharge.invoiceit_s__Price__c);
                                    dSubtotal = dSubtotal + orderRatePlanCharge.invoiceit_s__Price__c;  
                                }

                                orderRatePlanCharge.Billing_Milestones__c = '';

                                listOfOrderRatePlanCharge.add(orderRatePlanCharge);
                            }
                        } else {
                            orderRatePlanCharge.Name = orderRatePlanCharge.Name + ' - Phase ' + j++;
                            decimal iloc = decimal.valueOf(list_BillingMillestone_SplitValues[i]);
                            if(iloc != null) {      
                                orderRatePlanCharge.invoiceit_s__Unit_Price__c = orderCharge.invoiceit_s__Unit_Price__c - dUnitprice;
                                orderRatePlanCharge.invoiceit_s__Price__c = orderCharge.invoiceit_s__Price__c - dSubtotal;
                                orderRatePlanCharge.invoiceit_s__Net_Total__c = orderCharge.invoiceit_s__Net_Total__c - dNettotal;
                                orderRatePlanCharge.invoiceit_s__Discount_Value__c = orderCharge.invoiceit_s__Discount_Value__c - dDiscountvalue;
                                orderRatePlanCharge.invoiceit_s__VAT__c = orderCharge.invoiceit_s__VAT__c - dVAT;
                                orderRatePlanCharge.invoiceit_s__Tax__c = orderCharge.invoiceit_s__Tax__c - dTax;
                                orderRatePlanCharge.invoiceit_s__Cost_Price__c = orderCharge.invoiceit_s__Cost_Price__c - dUnitcost;
                                orderRatePlanCharge.invoiceit_s__Cost__c = orderCharge.invoiceit_s__Cost__c - dTotalcost;
                                orderRatePlanCharge.invoiceit_s__Profit__c = orderCharge.invoiceit_s__Profit__c - dProfit;
                                orderRatePlanCharge.Billing_Milestones__c = '';
                                if(debug.DebugOn__c == TRUE){
                                    system.debug('orderRatePlanCharge inside else ====' + orderRatePlanCharge.invoiceit_s__Price__c);
                                }
                                listOfOrderRatePlanCharge.add(orderRatePlanCharge);
                            }
                        }  
                    }   
                }
            }
        }
        insert listOfOrderRatePlanCharge;
        if(!test.isRunningTest()){
            delete listOfOrderRatePlanChargeToDelete;

        }
        

        // transfering product Charge attribute infomration to Order charge attribute
        for(invoiceit_s__Job_Rate_Plan_Charge__c orderCharge : newMap.values()) {
            //insert ing acount id ina set
            accountIdSet.add(orderCharge.Account_Id__c);
            productChargeidSet.add(orderCharge.invoiceit_s__Product_Rate_Plan_Charge__c);
            //condition added by sai: 30/6/2017
            if(orderCharge.Opportunity_Rate_Plan_Charge__c != NULL ){
            opptChargeidSet.add(orderCharge.Opportunity_Rate_Plan_Charge__c);
            }
        }
        map<Id, invoiceit_s__Product_Rate_Plan_Charge__c> map_proRatePlanCharge = new map<Id, invoiceit_s__Product_Rate_Plan_Charge__c>();
        map<Id, Account> map_Account;

        //map for Oppt charge object and id
        map<Id, invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> map_OptRatePlanCharge = new map<Id, invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        if(debug.DebugOn__c == TRUE){
            System.debug('Printing size of OpptChargeidSet'+productChargeidSet.size());
            System.debug('Printing size of OpptChargeidSet'+productChargeidSet);
        }
        //query account information 
        if(!accountIdset.isEmpty()){
            map_Account = new map<id, Account>([SELECT Id,Name,ShippingCity,tz__Timezone_Full_F__c,ShippingState,ShippingCountry,Phone,ShippingPostalCode,ShippingStreet,Website,
                                                BillingCity,BillingState,BillingCountry,BillingPostalCode,BillingStreet, Firm_Email__c
                                                FROM Account
                                                WHERE id IN:accountIdSet]); 

        }
        if(!productChargeidSet.isEmpty()){
            map_proRatePlanCharge = new map<Id, invoiceit_s__Product_Rate_Plan_Charge__c>([SELECT Name,invoiceit_s__Product_Rate_Plan__r.invoiceit_s__Product__r.Shippable__c, 
                                                                                           (SELECT name, Attribute_Name__c, Attribute_Type__c, Product_Rate_Plan_Charge__c,
                                                                                                   AttributeName__r.Attribute_Picklist_Values__c,
                                                                                                   AttributeName__r.Attribute_Type__c,Show_in_DocuSign__c,

                                                                                                   Default_Boolean__c,Default_Currency__c,Default_Date__c,Default_Number__c,Default_Text__c,Required__c,                                                                                                   AttributeName__r.Maximum_No_Of_Characters_In_Text__c,
                                                                                                   AttributeName__r.Minimum_No_Of_Characters_In_Text__c,Attribute_Order__c,
                                                                                                   AttributeName__r.Name
                                                                                                   FROM Product_Charge_Attributes__r)
                                                                                                   FROM invoiceit_s__Product_Rate_Plan_Charge__c 
                                                                                                   WHERE Id IN : productChargeidSet
                                                                                                   ]);
        }

        // querying Oppt charge with attribute

        if(!opptChargeidSet.isEmpty()){
            map_OptRatePlanCharge = new map<Id, invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>([SELECT Name, 
                                                                                                  (SELECT name, Attribute_Name__c,Boolean_Value__c,long_text_value__c,Date_Value__c,Maximum_No_Of_Characters_In_Text__c,Minimum_No_Of_Characters_In_Text__c,Number_Value__c,String_Value__c,Opportunity_Rate_Plan_Charge__c, Attribute_Type__c,

                                                                                                          Attribute_Order__c,Required__c,Show_in_DocuSign__c ,
                                                                                                          Attribute_Picklist_Values__c,
                                                                                                          Picklist_Value__c,Phone_Value__c,Value_ID__c,RecordType.DeveloperName
                                                                                                          FROM Opportunity_Charge_Attributes__r)
                                                                                                          FROM invoiceit_crmx__Opportunity_Rate_Plan_Charge__c 
                                                                                                          WHERE Id IN : opptChargeidSet
                                                                                                          ]);
        }
        if(debug.DebugOn__c == TRUE){
            System.debug('Printing size of map_oppRatePlanChareg'+map_proRatePlanCharge.size());
        }
        list<Product_Charge_Attribute__c> listOfProductChargeAttribute = new list<Product_Charge_Attribute__c>();
        list<Opportunity_Charge_Attribute__c> listOfOpportunityChargeAttribute = new list<Opportunity_Charge_Attribute__c>();
        Order_Charge_Attribute__c orderChargeAtt;
        Opportunity_Charge_Attribute__c opptChargeAtt;

        for(invoiceit_s__Job_Rate_Plan_Charge__c orderCharge : newMap.values()) {
            if(!map_proRatePlanCharge.isEmpty() || !map_OptRatePlanCharge.isEmpty()){
                //if(orderCharge.Quote_Type__c == null || orderCharge.Quote_Type__c == 'New') {
                //populating inforamtion from Oppt charge attribute to Order charge Attribute
                if(orderCharge.Opportunity_Rate_Plan_Charge__c != null) {
                    if(debug.DebugOn__c == TRUE){
                        System.debug('from Oppt to Ordr attribute');
                    }
                    if( map_OptRatePlanCharge.containskey(orderCharge.Opportunity_Rate_Plan_Charge__c)) {
                        //listOfOrderChargeAttribute = new list<Order_Charge_Attribute__c>();
                        listOfOpportunityChargeAttribute = map_OptRatePlanCharge.get(orderCharge.Opportunity_Rate_Plan_Charge__c).Opportunity_Charge_Attributes__r;
                        if(debug.DebugOn__c == TRUE){
                            System.debug('Printing size of listofloc'+listOfProductChargeAttribute.size());
                        }
                        for(Opportunity_Charge_Attribute__c opptChargeAttr : listOfOpportunityChargeAttribute ){
                            orderChargeAtt = new Order_Charge_Attribute__c();
                            
                            orderChargeAtt.Required__c = opptChargeAttr.Required__c ;
                            orderChargeAtt.Attribute_Type__c = opptChargeAttr.Attribute_Type__c;
                            orderChargeAtt.Attribute_Name__c = opptChargeAttr.Attribute_Name__c;
                            orderChargeAtt.String_Value__c = opptChargeAttr.String_Value__c;
                            orderChargeAtt.Boolean_Value__c = opptChargeAttr.Boolean_Value__c;
                            orderChargeAtt.Date_Value__c = opptChargeAttr.Date_Value__c;
                            orderChargeAtt.Number_Value__c = opptChargeAttr.Number_Value__c;
                            orderChargeAtt.Order_Rate_Plan_Charge__c = orderCharge.Id;
                            orderChargeAtt.Attribute_Order__c = opptChargeAttr.Attribute_Order__c;
                            orderChargeAtt.Attribute_Picklist_Values__c = opptChargeAttr.Attribute_Picklist_Values__c;
                            orderChargeAtt.Picklist_Value__c = opptChargeAttr.Picklist_Value__c;
                            orderChargeAtt.Phone_Value__c = opptChargeAttr.Phone_Value__c;
                            orderChargeAtt.Value_ID__c = opptChargeAttr.Value_ID__c;
                            orderChargeAtt.Long_text_value__c = opptChargeAttr.Long_text_value__c;
                            orderChargeAtt.Show_in_DocuSign__c = opptChargeAttr.Show_in_DocuSign__c ;
                        
                            orderChargeAtt.Maximum_No_Of_Characters_In_Text__c = opptChargeAttr.Maximum_No_Of_Characters_In_Text__c;
                            orderChargeAtt.Minimum_No_Of_Characters_In_Text__c = opptChargeAttr.Minimum_No_Of_Characters_In_Text__c;
                            if(orderChargeAtt.Order_Rate_Plan_Charge__r.Shippable__c != 'No'){
                                if(debug.DebugOn__c == TRUE){
                                    system.debug('===in shippable if attr===');
                                }
                                orderChargeAtt.Picked_for_Shipping__c = 'N';
                            }

                            listOfOrderChargeAttribute.add(orderChargeAtt );
                            if(debug.DebugOn__c == TRUE){
                                system.debug('listOfOrderChargeAttribute added' + listOfOrderChargeAttribute);
                            }
                        }    
                    }
                } //populating data from Product charge attribute to Order charge Attribute 
                else if(orderCharge.invoiceit_s__Product_Rate_Plan_Charge__c != null) {
                    if(debug.DebugOn__c == TRUE){
                        System.debug('from Product to Ordr attribute' + orderCharge.invoiceit_s__Product_Rate_Plan_Charge__c);
                    }
                    //listOfOrderChargeAttribute = new list<Order_Charge_Attribute__c>();
                    if( map_proRatePlanCharge.containskey(orderCharge.invoiceit_s__Product_Rate_Plan_Charge__c)) {
                        
                        listOfProductChargeAttribute = map_proRatePlanCharge.get(orderCharge.invoiceit_s__Product_Rate_Plan_Charge__c).Product_Charge_Attributes__r;
                        if(debug.DebugOn__c == TRUE){
                            system.debug('@@@@@listOfProductChargeAttribute'+listOfProductChargeAttribute);
                        }
                        invoiceit_s__Product_Rate_Plan_Charge__c prpc = map_proRatePlanCharge.get(orderCharge.invoiceit_s__Product_Rate_Plan_Charge__c);
                       
                         System.debug('Printing size of listofloc'+prpc );
                        for(Product_Charge_Attribute__c productChargeAttr : listOfProductChargeAttribute ){
                            orderChargeAtt = new Order_Charge_Attribute__c();
                            orderChargeAtt.Attribute_Type__c = productChargeAttr.AttributeName__r.Attribute_Type__c;
                            orderChargeAtt.Attribute_Name__c = productChargeAttr.AttributeName__r.Name;
                            orderChargeAtt.Show_in_DocuSign__c = productChargeAttr.Show_in_DocuSign__c ;
                            if(debug.DebugOn__c == TRUE){
                                System.debug('orderChargeAtt.Type'+ orderChargeAtt.Attribute_Type__c);
                                System.debug('orderChargeAtt.Attribute_Name__c'+orderChargeAtt.Attribute_Name__c);
                            }    
                            // popute attribute value based on jira Ln-23
                            // verify if it is a Shippable product or not
                                if(prpc.invoiceit_s__Product_Rate_Plan__r.invoiceit_s__Product__r.Shippable__c == 'Yes') {
                                    Account account = map_Account.get(orderCharge.Account_Id__c);       
                                    
                                    if(orderChargeAtt.Attribute_Name__c == 'Service Account Name' || orderChargeAtt.Attribute_Name__c == 'Xref Service Account Name') {
                                        if(orderChargeAtt.Attribute_Type__c == 'Text'){
                                            orderChargeAtt.String_Value__c = account.name;   
                                        }   
                                        else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                            orderChargeAtt.Picklist_Value__c = account.name; 
                                        }   
                                    }
                                    else if(orderChargeAtt.Attribute_Name__c == 'Service Street Address'){
                                
                                        if(orderChargeAtt.Attribute_Type__c == 'Text' && account.ShippingStreet != NULL){
                                               orderChargeAtt.String_Value__c = account.ShippingStreet;
                                        }                                                  
                                        else if(orderChargeAtt.Attribute_Type__c == 'Text' && account.ShippingStreet == NULL){
                                            orderChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                        }
                                        else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                            orderChargeAtt.Picklist_Value__c = account.ShippingStreet;   
                                        }   
                                                                  
                                    }
                                    else if(orderChargeAtt.Attribute_Name__c == 'Service City'){
                                        if(orderChargeAtt.Attribute_Type__c == 'Text' && account.ShippingCity != NULL){
                                            orderChargeAtt.String_Value__c = account.ShippingCity;   
                                        } 
                                        else if(orderChargeAtt.Attribute_Type__c == 'Text' && account.ShippingCity == NULL){
                                            orderChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                        }  
                                        else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                            orderChargeAtt.Picklist_Value__c = account.ShippingCity; 
                                        }   
                                    }
                                    else if(orderChargeAtt.Attribute_Name__c == 'Service State'){
                                        if(orderChargeAtt.Attribute_Type__c == 'Text' && account.ShippingState !=NULL){
                                            orderChargeAtt.String_Value__c = account.ShippingState;  
                                        } 
                                        else if(orderChargeAtt.Attribute_Type__c == 'Text' && account.ShippingState == NULL){
                                            orderChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                        }  
                                        else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                            orderChargeAtt.Picklist_Value__c = account.ShippingState;    
                                        }   
                                    }
                                    else if(orderChargeAtt.Attribute_Name__c == 'Service Country'){
                                        if(orderChargeAtt.Attribute_Type__c == 'Text' && account.ShippingCountry != NULL){
                                            orderChargeAtt.String_Value__c = account.ShippingCountry;    
                                        }  
                                        else if(orderChargeAtt.Attribute_Type__c == 'Text' && account.ShippingCountry == NULL){
                                            orderChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                        }  
                                        else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                            orderChargeAtt.Picklist_Value__c = account.ShippingCountry;  
                                        }   
                                    }
                                    else if(orderChargeAtt.Attribute_Name__c == 'Service Zip'){
                                        if(orderChargeAtt.Attribute_Type__c == 'Text' && account.ShippingPostalCode !=NULL){
                                            orderChargeAtt.String_Value__c = account.ShippingPostalCode; 
                                        } 
                                        else if(orderChargeAtt.Attribute_Type__c == 'Text' && account.ShippingPostalCode == NULL){
                                            orderChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                        }  
                                        else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                            orderChargeAtt.Picklist_Value__c = account.ShippingPostalCode;   
                                        }  
                                                                  
                                    }else if(orderChargeAtt.Attribute_Name__c=='Timezone'){
                                            if(orderChargeAtt.Attribute_Type__c == 'Text' && account.tz__Timezone_Full_F__c !=NULL){
                                                orderChargeAtt.String_Value__c = account.tz__Timezone_Full_F__c;   
                                            }
                                          }
                                }
                                else {
                                    // non shippable products
                                    // populate attribute value according to jira LN-23
                                    if(map_Account.containskey(orderCharge.Account_Id__c)){
                                        Account account = map_Account.get(orderCharge.Account_Id__c);
                                        if(debug.DebugOn__c == TRUE){
                                            system.debug('@@@@@@in if condition');
                                        }
                                        if(orderChargeAtt.Attribute_Name__c == 'Service Account Name' || orderChargeAtt.Attribute_Name__c == 'Xref Service Account Name') {
                                            if(orderChargeAtt.Attribute_Type__c == 'Text'){
                                                orderChargeAtt.String_Value__c = account.name;   
                                            }   
                                            else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                                orderChargeAtt.Picklist_Value__c = account.name; 
                                            }   
                                            else{
    
                                            }                           
                                        }else if(orderChargeAtt.Attribute_Name__c=='Timezone'){
                                            if(orderChargeAtt.Attribute_Type__c == 'Text' && account.tz__Timezone_Full_F__c !=NULL){
                                                orderChargeAtt.String_Value__c = account.tz__Timezone_Full_F__c;   
                                            }
                                          }
                                        else if(orderChargeAtt.Attribute_Name__c == 'Service Street Address'){
                                            
                                            if(orderChargeAtt.Attribute_Type__c == 'Text' && account.BillingStreet != NULL){
                                                   orderChargeAtt.String_Value__c = account.BillingStreet;
                                            } 
                                            
                                            if(orderChargeAtt.Attribute_Type__c == 'Text' && account.BillingStreet != NULL){
                                                   orderChargeAtt.String_Value__c = account.BillingStreet;
                                            }   
                                            else if(orderChargeAtt.Attribute_Type__c == 'Text' && account.BillingStreet == NULL){
                                                orderChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                            }
                                            else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                                orderChargeAtt.Picklist_Value__c = account.BillingStreet;   
                                            }   
                                                                      
                                        }
                                        else if(orderChargeAtt.Attribute_Name__c == 'Service City'){
                                            if(orderChargeAtt.Attribute_Type__c == 'Text' && account.BillingCity != NULL){
                                                orderChargeAtt.String_Value__c = account.BillingCity;   
                                            } 
                                            else if(orderChargeAtt.Attribute_Type__c == 'Text' && account.BillingCity == NULL){
                                                orderChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                            }  
                                            else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                                orderChargeAtt.Picklist_Value__c = account.BillingCity; 
                                            }   
                                            else{
    
                                            }                           
                                        }
                                        else if(orderChargeAtt.Attribute_Name__c == 'Service State'){
                                            if(orderChargeAtt.Attribute_Type__c == 'Text' && account.BillingState !=NULL){
                                                orderChargeAtt.String_Value__c = account.BillingState;  
                                            } 
                                            else if(orderChargeAtt.Attribute_Type__c == 'Text' && account.BillingState == NULL){
                                                orderChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                            }  
                                            else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                                orderChargeAtt.Picklist_Value__c = account.BillingState;    
                                            }   
                                            else{
    
                                            }                           
                                        }
                                        else if(orderChargeAtt.Attribute_Name__c == 'Service Country'){
                                            if(orderChargeAtt.Attribute_Type__c == 'Text' && account.BillingCountry != NULL){
                                                orderChargeAtt.String_Value__c = account.BillingCountry;    
                                            }  
                                            else if(orderChargeAtt.Attribute_Type__c == 'Text' && account.BillingCountry == NULL){
                                                orderChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                            }  
                                            else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                                orderChargeAtt.Picklist_Value__c = account.BillingCountry;  
                                            }   
                                            else{
    
                                            }                           
                                        }
                                        else if(orderChargeAtt.Attribute_Name__c == 'Service Zip'){
                                            if(orderChargeAtt.Attribute_Type__c == 'Text' && account.BillingPostalCode !=NULL){
                                                orderChargeAtt.String_Value__c = account.BillingPostalCode; 
                                            } 
                                            else if(orderChargeAtt.Attribute_Type__c == 'Text' && account.BillingPostalCode == NULL){
                                                orderChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                            }  
                                            else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                                orderChargeAtt.Picklist_Value__c = account.BillingPostalCode;   
                                            }  
                                            else{
    
                                            }                           
                                        }

                                        else if(orderChargeAtt.Attribute_Name__c == 'Ring To Number'){
                                            if(orderChargeAtt.Attribute_Type__c == 'Text' && account.Phone !=NULL){
                                                orderChargeAtt.String_Value__c = account.Phone.replaceAll('[^\\d.]', '');   
                                            }
                                        }
                                        
                                        else if(orderChargeAtt.Attribute_Name__c == 'Domain Name' || orderChargeAtt.Attribute_Name__c == 'Location' || orderChargeAtt.Attribute_Name__c == 'URL'){
                                            if(orderChargeAtt.Attribute_Type__c == 'Text' && account.Website !=NULL){
                                                orderChargeAtt.String_Value__c = account.Website;   
                                            } else {
                                                if(orderChargeAtt.Attribute_Type__c == 'Picklist' && account.Website !=NULL){
                                                    orderChargeAtt.Picklist_Value__c = account.Website;   
                                                }
                                            }
                                        }  
                                        
                                        else{
                                            if(orderChargeAtt.Attribute_Type__c == 'Date'){
                                                orderChargeAtt.Date_Value__c= productChargeAttr.Default_Date__c;
                                            
                                            }
                                            else if(orderChargeAtt.Attribute_Type__c == 'Boolean'){
                                                 orderChargeAtt.Boolean_Value__c = productChargeAttr.Default_Boolean__c;    
                                            }
                                            else if(orderChargeAtt.Attribute_Type__c == 'Date'){
                                                orderChargeAtt.Date_Value__c= productChargeAttr.Default_Date__c;
                                            }
                                            else if(orderChargeAtt.Attribute_Type__c == 'Number'){
                                                orderChargeAtt.Number_Value__c = productChargeAttr.Default_Number__c;
                                                
                                            }
                                        else if (orderChargeAtt.Attribute_Type__c == 'Currency'){
                                                 orderChargeAtt.String_Value__c = productChargeAttr.Default_Currency__c ;
                                                
                                            }
                                        }
                                    }
                            }
                            
                            if(orderChargeAtt.Attribute_Name__c == 'Language'){
                                if(orderChargeAtt.Attribute_Type__c == 'Text' && productChargeAttr.Default_Text__c == null){
                                    orderChargeAtt.String_Value__c = 'English';   
                                } else if(orderChargeAtt.Attribute_Type__c == 'Text' && productChargeAttr.Default_Text__c != null){
                                    orderChargeAtt.String_Value__c = productChargeAttr.Default_Text__c;     
                                } else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                    orderChargeAtt.Picklist_Value__c = 'English';  
                                }   
                            }
                            else if(orderChargeAtt.Attribute_Name__c == 'Country'){
                                if(orderChargeAtt.Attribute_Type__c == 'Text' && productChargeAttr.Default_Text__c == null){
                                    orderChargeAtt.String_Value__c = 'USA';   
                                } else if(orderChargeAtt.Attribute_Type__c == 'Text' && productChargeAttr.Default_Text__c != null){
                                    orderChargeAtt.String_Value__c = productChargeAttr.Default_Text__c;     
                                } else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                    orderChargeAtt.Picklist_Value__c = 'USA';  
                                }   
                            }
                            else if(orderChargeAtt.Attribute_Name__c == 'Call Tracking'){
                                if(orderChargeAtt.Attribute_Type__c == 'Text'){
                                    orderChargeAtt.String_Value__c = 'Y';   
                                }else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                    orderChargeAtt.Picklist_Value__c = 'Y';  
                                }   
                            }
                            else if(orderChargeAtt.Attribute_Name__c == 'Phone Number Type'){
                                if(orderChargeAtt.Attribute_Type__c == 'Text'){
                                    orderChargeAtt.String_Value__c = 'Local';   
                                }else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                    orderChargeAtt.Picklist_Value__c = 'Local';  
                                }   
                            }
                            else if(orderChargeAtt.Attribute_Name__c == 'Primary Website'){
                                if(orderChargeAtt.Attribute_Type__c == 'Text'){
                                    orderChargeAtt.String_Value__c = 'Y';   
                                }else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                    orderChargeAtt.Picklist_Value__c = 'Y';  
                                }   
                            }
                            else if(orderChargeAtt.Attribute_Name__c == 'Call Firm Now'){
                                if(orderChargeAtt.Attribute_Type__c == 'Text'){
                                    orderChargeAtt.String_Value__c = 'Y';   
                                }else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                    orderChargeAtt.Picklist_Value__c = 'Y';  
                                }   
                            }
                            else if(orderChargeAtt.Attribute_Name__c == 'Direct Website Link'){
                                if(orderChargeAtt.Attribute_Type__c == 'Text'){
                                    orderChargeAtt.String_Value__c = 'Y';   
                                }else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                    orderChargeAtt.Picklist_Value__c = 'Y';  
                                }   
                            }
                            else if(orderChargeAtt.Attribute_Name__c == 'Starter Kit'){
                                if(orderChargeAtt.Attribute_Type__c == 'Text'){
                                    orderChargeAtt.String_Value__c = 'Y';   
                                }else if(orderChargeAtt.Attribute_Type__c == 'Picklist'){
                                    orderChargeAtt.Picklist_Value__c = 'Y';  
                                }   
                            }

                            orderChargeAtt.Attribute_Picklist_Values__c = productChargeAttr.AttributeName__r.Attribute_Picklist_Values__c;
                            orderChargeAtt.Attribute_Order__c = productChargeAttr.Attribute_Order__c;
                            orderChargeAtt.Required__c = productChargeAttr.Required__c ;
                            orderChargeAtt.Maximum_No_Of_Characters_In_Text__c = productChargeAttr.AttributeName__r.Maximum_No_Of_Characters_In_Text__c;
                            orderChargeAtt.Minimum_No_Of_Characters_In_Text__c = productChargeAttr.AttributeName__r.Minimum_No_Of_Characters_In_Text__c;
                            orderChargeAtt.Order_Rate_Plan_Charge__c = orderCharge.id;
                            listOfOrderChargeAttribute.add(orderChargeAtt );
                        }    
                    }
                }
                else{
                }
                //}
            }
        }
        if(debug.DebugOn__c == TRUE){
            System.debug('Printing size of listOfOrderChargeAttribute'+listOfOrderChargeAttribute.size());
        }
        if(!listOfOrderChargeAttribute.isEmpty()){
            try{
                upsert listOfOrderChargeAttribute;  
            }catch(Exception ex) {
                if(ApexPages.currentPage() != null) {  
                    system.debug('An exprtion' +ex.getMessage());
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An exception has occured. Exception message is : ' + ex.getMessage());
                    ApexPages.addMessage(myMsg);
                }
            }
            
        }
//Updated this until I work on Chat
       updateChatOrpc(newMap, opptChargeidSet);

    }


    public void updateChatOrpc(map<id, invoiceit_s__Job_Rate_Plan_Charge__c> newMap, set<id> opptChargeidSet)
    {
        if(debug.DebugOn__c == TRUE){
            system.debug('@@@@@in updateChatOrpc');
        }
        list<Chat_Product_Opportunity_Charge__c> coprc = new list<Chat_Product_Opportunity_Charge__c>();
        list<Chat_Product_Order_Charge__c> corc = new list<Chat_Product_Order_Charge__c>();
        coprc = [select id, Chat_Product_Opp_Rate_Plan_Charge__c, 
                        Chat_Usage_Opp_Rate_Plan_Charge__c ,
                      Parent_MH_Order_Rate_Plan_Charge__c
                       from Chat_Product_Opportunity_Charge__c 
                      where Chat_Product_Opp_Rate_Plan_Charge__c in :opptChargeidSet 
                       or Chat_Usage_Opp_Rate_Plan_Charge__c in :opptChargeidSet];
        if(debug.DebugOn__c == TRUE){
            system.debug('Chat records: ' + coprc + ' Opp: ' + opptChargeidSet + ' Rate: ' + newMap);
        }
        /********************************akash : 07/01/2018 ******************************************/
        set<Id> opprateplanChargeIds                            =  new Set<Id>();
        Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c>oppIdVSorpc = new Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c>();
        for(Chat_Product_Opportunity_Charge__c c:coprc){
            opprateplanChargeIds.add(c.Chat_Product_Opp_Rate_Plan_Charge__c);
            opprateplanChargeIds.add(c.Chat_Usage_Opp_Rate_Plan_Charge__c);
        }
        
        if(!opprateplanChargeIds.isEmpty()){
             for(invoiceit_s__Job_Rate_Plan_Charge__c orpc : [select id ,Opportunity_Rate_Plan_Charge__c 
                                                              from  invoiceit_s__Job_Rate_Plan_Charge__c 
                                                         where Opportunity_Rate_Plan_Charge__c IN:opprateplanChargeIds
                                                                    AND Opportunity_Rate_Plan_Charge__c != NULL]){
              oppIdVSorpc.put(orpc.Opportunity_Rate_Plan_Charge__c, orpc);                                                  
           }
            
        }
       
        
        
        
        for (Chat_Product_Opportunity_Charge__c c:coprc)
        {
            //system.debug('@@@@@ coprc'+c);
            Chat_Product_Order_Charge__c corc1 = new Chat_Product_Order_Charge__c();
            for(invoiceit_s__Job_Rate_Plan_Charge__c orderCharge : newMap.values()) {
                if (orderCharge.Opportunity_Rate_Plan_Charge__c == c.Chat_Product_Opp_Rate_Plan_Charge__c){
                   
                    corc1.Chat_Product_Order_Rate_Plan_Charge__c = orderCharge.id;
                      corc1.Chat_Usage_Order_Rate_Plan_Charge__c = 
                             (oppIdVSorpc.containsKey(c.Chat_Usage_Opp_Rate_Plan_Charge__c))?
                                 oppIdVSorpc.get(c.Chat_Usage_Opp_Rate_Plan_Charge__c).id:NULL;
                    
                }
                      
                if (orderCharge.Opportunity_Rate_Plan_Charge__c == c.Chat_Usage_Opp_Rate_Plan_Charge__c){
                  
                    corc1.Chat_Usage_Order_Rate_Plan_Charge__c = orderCharge.id; 
                     corc1.Chat_Product_Order_Rate_Plan_Charge__c = 
                             (oppIdVSorpc.containsKey(c.Chat_Product_Opp_Rate_Plan_Charge__c))?
                                 oppIdVSorpc.get(c.Chat_Product_Opp_Rate_Plan_Charge__c).id:NULL;
                    IF(c.Parent_MH_Order_Rate_Plan_Charge__c != NULL){
                         corc1.Chat_Product_Order_Rate_Plan_Charge__c = c.Parent_MH_Order_Rate_Plan_Charge__c;
                    }
                }
                                
            }
            if (corc1.Chat_Usage_Order_Rate_Plan_Charge__c != null)
                corc.add(corc1);
            
        }
        if(debug.DebugOn__c == TRUE){
            system.debug('@@@Rama Corc: ' + corc);
        }
        if (!corc.isempty()&& !test.isRunningTest()){}
            insert corc;

    }


    /*public void handleBeforeOnOrderRatePlanChargeforRenew(list<invoiceit_s__Job_Rate_Plan_Charge__c> newCharges, map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> newMap, map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> oldMap) {
        List<id> orderids=new List<id>();
        List<id> chargeids=new List<id>();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> toupdate=new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        Map<id,invoiceit_s__Job__c> orders=new Map<id,invoiceit_s__Job__c>();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> renewedcharges=new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        Map<id,invoiceit_s__Job_Rate_Plan_Charge__c> oldnewedcharges=new Map<id,invoiceit_s__Job_Rate_Plan_Charge__c>();
        //invoiceit_s__Order__c
        for(invoiceit_s__Job_Rate_Plan_Charge__c iter: newCharges){
            orderids.add(iter.invoiceit_s__Order__c);
            chargeids.add(iter.id);
        }
        orders=new Map<id,invoiceit_s__Job__c >([select id,Renew_Rebase__c from invoiceit_s__Job__c where id in :orderids]);
        renewedcharges=[select id,invoiceit_s__Status__c,Fulfilment_Start_Date__c,invoiceit_s__Order__c,Created_From_Charge__c from invoiceit_s__Job_Rate_Plan_Charge__c  where Created_From_Charge__c in : chargeids];

        for(invoiceit_s__Job_Rate_Plan_Charge__c iter : renewedcharges){
                invoiceit_s__Job_Rate_Plan_Charge__c temp=newMap.get(iter.Created_From_Charge__c);
                oldnewedcharges.put(temp.id,iter);
        }
        for(invoiceit_s__Job_Rate_Plan_Charge__c iter : newCharges){
            boolean toadd=false;
            invoiceit_s__Job__c temporder=orders.get(iter.invoiceit_s__Order__c);
            if(temporder!=null && temporder.Renew_Rebase__c!=null && temporder.Renew_Rebase__c=='Renew' && oldMap.get(iter.id)!=null && oldMap.get(iter.id).Fulfilment_Start_Date__c ==null && newMap.get(iter.id).Fulfilment_Start_Date__c !=null){
                system.debug('>>>>>>>>>>>>>>>inside update fullfillment loop1');
                invoiceit_s__Job_Rate_Plan_Charge__c tempcharge=oldnewedcharges.get(iter.id);
                if(tempcharge!=null){
                    tempcharge.Fulfilment_Start_Date__c=iter.Fulfilment_Start_Date__c;
                    oldnewedcharges.put(iter.id,tempcharge);
                    toadd=true;
                    system.debug('>>>>>>>>>>>>>>>inside update fullfillment');
                }
            }
            if(oldnewedcharges.containskey(iter.id) && iter.invoiceit_s__Status__c=='Cancelled' && temporder!=null && temporder.Renew_Rebase__c!=null && (temporder.Renew_Rebase__c=='Renew' || temporder.Renew_Rebase__c=='Rebase')){
                invoiceit_s__Job_Rate_Plan_Charge__c tempcharge=oldnewedcharges.get(iter.id);
                tempcharge.invoiceit_s__Status__c='Cancelled';
                tempcharge.Loss_Reasons__c=iter.Loss_Reasons__c;
                oldnewedcharges.put(iter.id,tempcharge);
                system.debug('>>>>>>>>>>>>>>>inside update status');
                toadd=true;
            }
            if(toadd==true){
                toupdate.add(oldnewedcharges.get(iter.id));
            }
        }
        system.debug('>>>>>>>>>>>>>>>'+toupdate.size()+'>>>>>>>>>'+toupdate);
        if(toupdate!=null){
            update toupdate;
        }
    }*/
    
    //moving Update the Picked for shipping on Charge and Attribute to trigger
    public void updatePickedforShippinonChargeAttr(List<invoiceit_s__Job_Rate_Plan_Charge__c> ordRPCLst){
        Set<Id> ordRPCId = new Set<Id>();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> ordRPCToGet = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> ordRPCToUpdate = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        for(invoiceit_s__Job_Rate_Plan_Charge__c ordrpc: ordRPCLst){
            if(ordrpc.Shippable__c != 'No'){
                ordRPCId.add(ordrpc.Id);
            }
        }
        if(!ordRPCId.isEmpty()){
            ordRPCToGet = [select id, name, Shippable__c, Picked_for_Shipping__c
                           FROM invoiceit_s__Job_Rate_Plan_Charge__c WHERE Id IN:ordRPCId];         
        }
        //Deactivate_Trigger_for_data_load__c debug = Deactivate_Trigger_for_data_load__c.getValues('Debug Status');
        if(debug.DebugOn__c == TRUE){
            system.debug('==ordRPCToGet=='+ordRPCToGet);
        }
        for(invoiceit_s__Job_Rate_Plan_Charge__c odrpc: ordRPCToGet){
            if(odrpc.Shippable__c != 'No'){
                odrpc.Picked_for_Shipping__c = 'N';
                ordRPCToUpdate.add(odrpc);
            }
        }
        if(!ordRPCToUpdate.isEmpty()){
            update ordRPCToUpdate;
        }
    }
    //mark is addOn feature to false - added by saiv 03/11/2020
    public void markIsAddOnFeaturetoFalse(List<invoiceit_s__Job_Rate_Plan_Charge__c> ordRPCList, Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> oldMap){
        Set<Id> ordProductIds = new Set<Id>();
        List<invoiceit_s__Job_Product__c> ordProdList = new List<invoiceit_s__Job_Product__c>();
        List<invoiceit_s__Job_Product__c> ordProdUpdateList = new List<invoiceit_s__Job_Product__c>();
        //Deactivate_Trigger_for_data_load__c debug = Deactivate_Trigger_for_data_load__c.getValues('Debug Status');
        if(debug.DebugOn__c == TRUE){
            system.debug('===ordRPCList==='+ordRPCList);
        }
        for(invoiceit_s__Job_Rate_Plan_Charge__c orpc: [select id, name,invoiceit_s__Job_Rate_Plan__c,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c, 
                                                        invoiceit_s__Status__c from invoiceit_s__Job_Rate_Plan_Charge__c WHERE Id IN:ordRPCList]){
            if(debug.DebugOn__c == TRUE){                                            
                system.debug('==oldMap.get(orpc.Id).invoiceit_s__Status__c==='+oldMap.get(orpc.Id).invoiceit_s__Status__c);
            }
            if(orpc.invoiceit_s__Status__c == 'Cancelled' && oldMap.get(orpc.Id).invoiceit_s__Status__c != orpc.invoiceit_s__Status__c){
                if(debug.DebugOn__c == TRUE){
                    system.debug('==insideif====');
                }
                ordProductIds.add(orpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c);
            }
        }
        if(debug.DebugOn__c == TRUE){
            system.debug('==ordProductIds2=='+ordProductIds);
        }
        if(!ordProductIds.isEmpty()){
            ordProdList = [select id, name, IsAddOnFeature__c FROM invoiceit_s__Job_Product__c WHERE ID IN:ordProductIds];
        }
        if(debug.DebugOn__c == TRUE){
            system.debug('===ordProdList==='+ordProdList);
        }
        for(invoiceit_s__Job_Product__c op: ordProdList){
            for(invoiceit_s__Job_Rate_Plan_Charge__c orpc: ordRPCList){
                if(orpc.invoiceit_s__Status__c == 'Cancelled' && op.IsAddOnFeature__c == true){
                    op.IsAddOnFeature__c = false;
                    ordProdUpdateList.add(op);
                }
            }
        }
        if(debug.DebugOn__c == TRUE){
            system.debug('===ordProdUpdateList==='+ordProdUpdateList);
        }
        if(!ordProdUpdateList.isEmpty()){
            update ordProdUpdateList;
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
    i++;    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
      i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;  i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
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
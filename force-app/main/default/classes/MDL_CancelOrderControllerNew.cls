/***
Modified on: Sep 9,2020
By: Ieswarya J
Ticket : MHBS-4006
*/
public class MDL_CancelOrderControllerNew {
     public class InnerClassORPC{
                     
        public boolean isChecked {get;set;}
        public invoiceit_s__Job_Rate_Plan_Charge__c orderRPC{get;set;}          
        public List<invoiceit_s__Job_Rate_Plan_Charge__c> childorderRPC{get;set;} 
         public boolean ischildChecked{get;set;} 
        // public List<Chat_Product_Order_Charge__c> childOrderchatProduct{get;set;}
         public string childorderchatStatus{get;set;} //this is to check status on chat order charge status
         public string childorderchatlossReason{get;set;}
         
         public List<addonchatwrapper> addoncharges{get;set;}
        
        public InnerClassORPC(invoiceit_s__Job_Rate_Plan_Charge__c oRPC, List<invoiceit_s__Job_Rate_Plan_Charge__c> cORPC) {
            this.isChecked = false;
            this.orderRPC = oRPC;
            this.childorderRPC = cORPC;
            this.ischildChecked = false;
        }    
    }
    
    public class addonchatwrapper{
        public boolean isChecked {get;set;}
        public invoiceit_s__Job_Rate_Plan_Charge__c orderRPC{get;set;} 
        
        public addonchatwrapper(invoiceit_s__Job_Rate_Plan_Charge__c oRPC, boolean chck){
            this.orderRPC = oRPC;
            this.isChecked = chck;
        }
    }
    
    
    public InnerClassORPC packageWrap{get;set;}
    public List<InnerClassORPC> componentWrap{get;set;}
    public list<InnerClassORPC> independentWrap{get;set;}
     private ApexPages.StandardController standardController;
    public invoiceit_s__Job__c orderObj{get;set;}
    public boolean showLossReason{get;set;}
    public boolean cancelcharge{get;set;}
    public boolean cancelorder{get;set;}
    public Id orderId{get;set;}
    public boolean isError{get;set;}
    public integer counter;    
    public List<invoiceit_s__Job_Rate_Plan_Charge__c> orderRPCList{get;set;}
    public List<invoiceit_s__Job_Rate_Plan_Charge__c> lstOrderRPCToUpdate;
    public List<InnerClassORPC> lstInnerClassORPC{get;set;}
    public List<List<InnerClassORPC>> lstOfLstInnerClassORPC{get;set;}
    public transient Integer Items_Per_Page {get;set;}
    public transient List<Integer> Pagination {get;set;}
    public transient Integer PageNumber {get;set;}
    public list<selectoption> lstLossReasons{get;set;}
    public list<selectoption> secLossReasons{get;set;} //added by saiv
    public String selVal{get;set;}
    public String selVal2{get;set;}
    public Decimal TotalValue {get;set;}
    Public String radiobuttonstatus{set;get;}
    public Id OrderRatePlanid;
    private set<string> chatprodset = new set<string>();
    private list<Chat_Product_Order_Charge__c> chatlist = new list<Chat_Product_Order_Charge__c>();
    public map<id, Set<id>> chatusagelist = new map<id, Set<id>>();
    public boolean compPanelFlag {get;set;}
    public Id childorderId;
    public boolean isChildOrder {get;set;}
    public invoiceit_s__Job__c orderrecord;
    public Map<Id,Chat_Product_Order_Charge__c>chatProductChargeVSchatProduct = new Map<Id,Chat_Product_Order_Charge__c>();
    public set<Id>childchargestotUpdateIds = new Set<Id>();
    
    public MDL_CancelOrderControllerNew(ApexPages.StandardController standardController) {
        orderRPCList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
         componentWrap = new List<InnerClassORPC>();
        independentWrap = new list<InnerClassORPC>();
        Items_Per_Page = 100;
        TotalValue = 0.0;        
        Pagination = new List<Integer>();
        lstOfLstInnerClassORPC = new List<List<InnerClassORPC>>();
        this.standardController = standardController;
        orderId=standardController.getId();
        showLossReason = false;
        counter = 0;
        isError = false;
        compPanelFlag = false;
        map<id, invoiceit_s__Job_Rate_Plan_Charge__c> parentChargeIdVschildCharge = new  map<id, invoiceit_s__Job_Rate_Plan_Charge__c>();
        lstLossReasons = new list<selectoption>();
        secLossReasons = new list<selectoption>();//added by saiv
        orderObj = new invoiceit_s__Job__c();
        orderrecord = new invoiceit_s__Job__c();
        orderrecord = [Select o.id,o.name,o.RecordType.DeveloperName From invoiceit_s__Job__c o Where o.id =:orderId  ];
        //getting order details
        orderObj = [SELECT Id, name, RecordType.DeveloperName, invoiceit_s__Status__c,invoiceit_s__Sub_Total__c,
                            invoiceit_s__Net_Total__c, Parent_Order__c,Parent_Order__r.Name,invoiceit_s__Total__c,Total_ECF__c,invoiceit_s__Recalculate__c,
                            invoiceit_s__Total_Contract_Value__c ,invoiceit_s__Service_Activation_Date__c, Loss_Reasons__c,
                            invoiceit_s__Service_End_Date__c, Reason_for_Waiver__c, Secondary_Loss_Reason__c, Other_Cancel_Reason__c,
                               (Select Id, Name ,invoiceit_s__Status__c, Loss_Reasons__c,Cancellation_Date__c,
                                         invoiceit_s__Service_Activation_Date__c,Created_From_Order__c,RecordType.DeveloperName,
                                         invoiceit_s__Number_Of_Terms__c,invoiceit_s__Service_End_Date__c  
                                         from Orders__r )
                            FROM invoiceit_s__Job__c 
                            WHERE id =: orderId];
        
         // Forming chat usage list which will hold junction chat records
         // Froming addon Prents also here to form inner addon relationship
          set<Id> addonchateParentIds   = new set<Id>();
          system.debug('@@@@@orderObj '+orderObj );
        //getting Recent Child order here
        system.debug('@@@@@orderObj.Orders__r'+orderObj.Orders__r);
        //if(!orderObj.Orders__r.isempty()){
         isChildOrder = true;
         system.debug('@@@@@orderrecord.RecordType.DeveloperName'+ orderrecord.RecordType.DeveloperName); 
        if(orderrecord.RecordType.DeveloperName!='M_NG_Order'){
            List<invoiceit_s__Job__c> childorders = new List<invoiceit_s__Job__c>();
            childorders = [SELECT Id, name, RecordType.DeveloperName, invoiceit_s__Status__c,invoiceit_s__Sub_Total__c,
                            invoiceit_s__Net_Total__c, Parent_Order__c, Parent_Order__r.Name, invoiceit_s__Total__c,Total_ECF__c,invoiceit_s__Recalculate__c,
                            invoiceit_s__Total_Contract_Value__c ,invoiceit_s__Service_Activation_Date__c, Loss_Reasons__c, Secondary_Loss_Reason__c, Other_Cancel_Reason__c,
                            invoiceit_s__Service_End_Date__c, Reason_for_Waiver__c
                                            from invoiceit_s__Job__c where Parent_Order__c=:orderId order by CreatedDate DESC LIMIT 1];
        invoiceit_s__Job__c childOrderobj = new invoiceit_s__Job__c();
            
        
        
      
        if(childorders  != NULL && !childorders.isEmpty()){
            isChildOrder = false;
               childOrderobj = childorders[0];
             for ( Chat_Product_Order_Charge__c chatcharge: [select Chat_Product_Order_Rate_Plan_Charge__c, Status__c,
                                                  Chat_Product_Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c, 
                                                   Chat_Product_Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name, 
                                                     Chat_Usage_Order_Rate_Plan_Charge__c, Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Status__c, 
                                                     Chat_Usage_Order_Rate_Plan_Charge__r.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c,    
                                                     Chat_Product_Order_Rate_Plan_Charge__r.invoiceit_s__Status__c,
                                                             Chat_Product_Order_Rate_Plan_Charge__r.Name,
                                                         Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__C,
                                                         Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.Name
                                              from Chat_Product_Order_Charge__c 
                                                where Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Order__c = :childOrderobj.id ]){
                 chatlist.add(chatcharge);
              //if(chatcharge.Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Status__c != 'Cancelled'
              //      && chatcharge.Chat_Product_Order_Rate_Plan_Charge__r.invoiceit_s__Status__c != 'Cancelled'){
              //                                  /************Akash : 02/05 chatusagelist converted to map bcoz child chat can be linked to many parent charges***/
                                                    if(chatusagelist.containsKey(chatcharge.Chat_Usage_Order_Rate_Plan_Charge__c)){
                                                        chatusagelist.get(chatcharge.Chat_Usage_Order_Rate_Plan_Charge__c).add(chatcharge.Chat_Product_Order_Rate_Plan_Charge__c);
                                                    }
                                                    else{
                                                        chatusagelist.put(chatcharge.Chat_Usage_Order_Rate_Plan_Charge__c, new Set<Id>{chatcharge.Chat_Product_Order_Rate_Plan_Charge__c});
                                                    }
                                                    
                                                    
                                                    If(chatcharge.Chat_Product_Order_Rate_Plan_Charge__r.Name.contains('Professional Profile')){
                                                        chatProductChargeVSchatProduct.put(chatcharge.Chat_Product_Order_Rate_Plan_Charge__c,chatcharge);
                                                        childchargestotUpdateIds.add(chatcharge.Chat_Usage_Order_Rate_Plan_Charge__c);
                                                    }
                                                    
                  // chatusagelist.put(chatcharge.Chat_Usage_Order_Rate_Plan_Charge__c, chatcharge.Chat_Product_Order_Rate_Plan_Charge__c);
              // }  
                                                   // if(chatcharge.Chat_Usage_Order_Rate_Plan_Charge__r.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c != NULL){
                                                      //  addonchateParentIds.add(chatcharge.Chat_Usage_Order_Rate_Plan_Charge__r.Opportunity_Rate_Plan_Charge__c);
                                                    childorderId = chatcharge.Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__C;
                                                    //}                                                  
            }
        }
        
        
       }
           
       //}
            string query = 'Select i.id, i.Package_Wrapper__c, i.Package_Component__c, i.Name,i.invoiceit_s__Status__c, ' 
                                + ' i.invoiceit_s__Accounting_Code__c,i.invoiceit_s__Service_End_Date__c, '
                                +  ' i.invoiceit_s__Service_Activation_Date__c, i.invoiceit_s__Row_Total__c,i.Chat_Parent_Order_Rate_Plan_Charge__c, ' 
                                +  ' i.invoiceit_s__Job_Rate_Plan__c, i.invoiceit_s__Price_Type__c, '
                                +  ' i.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c, '
                                +  ' i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.Parent_Order__c, i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.Name, '
                                +  ' i.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__C,i.Chat_Parent_Order_Rate_Plan_Charge__r.SIN__c, i.Chat_Parent_Order_Rate_Plan_Charge__r.name,'
                                +   ' i.invoiceit_s__Order__c, i.invoiceit_s__Order__r.OrderNumber__c,i.invoiceit_s__Order__r.Name,i.invoiceit_s__Order__r.id,'
                                    + '(Select Id, OwnerId,  Name, RecordTypeId, Attribute_Name__c, Attribute_Order__c, ' 
                                      + ' Attribute_Picklist_Values__c, Attribute_Type__c, Boolean_Value__c,  '
                                      +  ' Date_Value__c, Maximum_No_Of_Characters_In_Text__c,Minimum_No_Of_Characters_In_Text__c,'
                                      + ' Number_Value__c , Order_Rate_Plan_Charge__c, Phone_Value__c,Long_text_value__c, Picklist_Value__c, String_Value__c'
                                      + ' From Order_Charge_Attributes__r),invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name ,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c, '
                                      + ' Cancel_Date__c , invoiceit_s__Charge_Date__c ,Fulfilment_Start_Date__c , '
                                      + ' Fulfilment_End_Date__c ,Loss_Reasons__c,of_days__c,Renewable__c, '
                                      + ' Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Product_Bundle_Line__r.invoiceit_s__Is_Quantity_Editable__c, '
                                      + ' Opportunity_Rate_Plan_Charge__r.Optional_Product__c '
                            + ' From invoiceit_s__Job_Rate_Plan_Charge__c i '
                            + ' Where (i.invoiceit_s__Order__c =: orderid ';
        if(!chatusagelist.isEmpty()){
            set<Id> tempset = chatusagelist.keyset();
           // query += ' OR ID IN:tempset ';
            query += ' OR i.invoiceit_s__Order__c =:childorderId ';
        }
        query += ' ) Order BY invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__SequenceNumber__c,invoiceit_s__Sequence_No__c ';
          
        system.debug('@@@@@query'+ query); 
        List<invoiceit_s__Job_Rate_Plan_Charge__c> orpclistTemp = database.query(query);
         system.debug('@@@@@orpclistTemp'+ orpclistTemp);
        Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> orpcMap = new Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c>(orpclistTemp);
        system.debug('@@@@@orpcMap'+ orpcMap);
        
        for(invoiceit_s__Job_Rate_Plan_Charge__c orp: orpclistTemp ){
            If (orp.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name.Contains('External Website')){
            ApexPages.Message errMsg1 = new ApexPages.Message(ApexPages.Severity.WARNING,'This Order Contain Ngage live chat on External Website'); 
            ApexPages.addMessage(errMsg1); 
            }
        }
       
        
        for (ID orpcId: orpcMap.keySet())
            {
                if(chatusagelist.containsKey(orpcId)){
                    for(Id parentId : chatusagelist.get(orpcId)){
                         parentChargeIdVschildCharge.put(parentId,orpcMap.get(orpcId));
                    }
                    //parentChargeIdVschildCharge.put(chatusagelist.get(orpcId),orpcMap.get(orpcId));
                   // childorderId = orpcMap.get(orpcId).invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__C;
                }
                //checking this orpc belongs to child order 
                /*else if((childorderId != NULL && orpcMap.get(orpcId).invoiceit_s__Order__c == childorderId)
                        || orpcMap.get(orpcId).invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.Parent_Order__c != NULL){*/
                
                else{   
                   invoiceit_s__Job_Rate_Plan_Charge__c orpct = orpcMap.get(orpcId);
                    //getting chat parent ids to form relationship between add on charges
                   system.debug('@@@@@orpct parent id'+ orpct.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c);
                   system.debug('@@@@@orpct parent id'+ orpct.Chat_Parent_Order_Rate_Plan_Charge__c);
                    If(orpct.Chat_Parent_Order_Rate_Plan_Charge__c != NULL){
                        addonchateParentIds.add(orpct.Chat_Parent_Order_Rate_Plan_Charge__c);
                    }
                    //adding only parent stand alone chats here
                    else{
                        orderRPCList.add(orpcMap.get(orpcId));
                    }
                }   
                //}
               // else{
                 //   orderRPCList.add(orpcMap.get(orpcId));
               // }
             }
        
         system.debug('@@@@@orderRPCList'+orderRPCList);
         system.debug('@@@@@addonchateParentIds'+addonchateParentIds);
         system.debug('@@@@@parentChargeIdVschildCharge'+parentChargeIdVschildCharge);
        Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>> addonchatParentVsaddonchats = new Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>>();
        if(!addonchateParentIds.isEmpty()){
            for(invoiceit_s__Job_Rate_Plan_Charge__c orpcchat : [Select id,Name,invoiceit_s__Status__c, 
                               invoiceit_s__Accounting_Code__c,invoiceit_s__Service_End_Date__c,invoiceit_s__Order__r.Name, 
                             invoiceit_s__Service_Activation_Date__c, invoiceit_s__Row_Total__c,  
                                invoiceit_s__Job_Rate_Plan__c,invoiceit_s__Price_Type__c, Chat_Parent_Order_Rate_Plan_Charge__c,
                                  Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c,
                                   invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.Parent_Order__c, 
                                   invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__C, invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.Name,
                                                                 invoiceit_s__Order__r.OrderNumber__c,
                                     (Select Id, OwnerId,  Name, RecordTypeId, Attribute_Name__c, Attribute_Order__c,  
                                        Attribute_Picklist_Values__c, Attribute_Type__c, Boolean_Value__c, Long_Text_value__c,
                                         Date_Value__c, Maximum_No_Of_Characters_In_Text__c,Minimum_No_Of_Characters_In_Text__c,
                                        Number_Value__c , Order_Rate_Plan_Charge__c, Phone_Value__c, Picklist_Value__c, String_Value__c
                                        From Order_Charge_Attributes__r),invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name ,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c, 
                                        Cancel_Date__c , invoiceit_s__Charge_Date__c ,Fulfilment_Start_Date__c , 
                                        Fulfilment_End_Date__c ,Loss_Reasons__c,of_days__c,Renewable__c, 
                                        Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Product_Bundle_Line__r.invoiceit_s__Is_Quantity_Editable__c, 
                                        Opportunity_Rate_Plan_Charge__r.Optional_Product__c 
                             From invoiceit_s__Job_Rate_Plan_Charge__c where
                                                                 Chat_Parent_Order_Rate_Plan_Charge__c IN:addonchateParentIds  ]){
                           
                                  IF(addonchatParentVsaddonchats.containsKey(orpcchat.Chat_Parent_Order_Rate_Plan_Charge__c)){
                                        addonchatParentVsaddonchats.get(orpcchat.Chat_Parent_Order_Rate_Plan_Charge__c).add(orpcchat);                                 
                                   }
                                   else{
                                       addonchatParentVsaddonchats.put(orpcchat.Chat_Parent_Order_Rate_Plan_Charge__c, new List<invoiceit_s__Job_Rate_Plan_Charge__c>{orpcchat});                                  
                                  }                                   
                                                                     
                   }
        }
        
        
        system.debug('@@@@addonchatParentVsaddonchats'+addonchatParentVsaddonchats); 
        
        
        
        cancelcharge=true;
        cancelorder=true; 
        if(orderObj.invoiceit_s__Status__c == 'Cancelled' && orderObj.Loss_Reasons__c!=null) {
            String reasonLoss = orderObj.Loss_Reasons__c;
            lstLossReasons.add(new SelectOption(reasonLoss,reasonLoss)); // added by saiv - start NCONS -72
            //String secreasonLoss = orderObj.Secondary_Loss_Reason__c;
            //secLossReasons.add(new SelectOption(secreasonLoss,secreasonLoss));
        }else if(orderObj.RecordType.DeveloperName == 'M_N_Order') {
            lstLossReasons.add(new SelectOption('--None--','--None--'));
            //lstLossReasons.add(new SelectOption('Cancelled - Credit Card Decline','Cancelled - Credit Card Decline'));
            //lstLossReasons.add(new SelectOption('Cancelled - Lead','Cancelled - Lead'));
            //lstLossReasons.add(new SelectOption('Cancelled - Listings','Cancelled - Listings'));
            //added by saiv
            lstLossReasons.add(new SelectOption('Closed Practice','Closed Practice'));
            lstLossReasons.add(new SelectOption('Customer Experience','Customer Experience'));
            lstLossReasons.add(new SelectOption('Financial','Financial'));
            lstLossReasons.add(new SelectOption('Leads','Leads'));
            lstLossReasons.add(new SelectOption('New Marketing Strategy','New Marketing Strategy'));
            lstLossReasons.add(new SelectOption('Public Health Issue','Public Health Issue'));
            lstLossReasons.add(new SelectOption('Customer Unresponsive','Customer Unresponsive'));
            lstLossReasons.add(new SelectOption('Other','Other'));
        
        }  else if(orderObj.RecordType.DeveloperName == 'MH_Orders' || orderObj.RecordType.DeveloperName == 'Nolo_Order' 
                    || orderObj.RecordType.DeveloperName == 'M_NG_Order'){
            lstLossReasons.add(new SelectOption('--None--','--None--'));
            /*lstLossReasons.add(new SelectOption('Duplicate','Duplicate'));
            lstLossReasons.add(new SelectOption('Firm Dissolved/Merged','Firm Dissolved/Merged'));
            lstLossReasons.add(new SelectOption('Fulfillment issues','Fulfillment issues'));
            lstLossReasons.add(new SelectOption('Lost to Competitor','Lost to Competitor'));
            lstLossReasons.add(new SelectOption('No reason given','No reason given'));
            lstLossReasons.add(new SelectOption('No Referrals/Little Value','No Referrals/Little Value'));
            lstLossReasons.add(new SelectOption('Past due/unable to pay','Past due/unable to pay'));
            lstLossReasons.add(new SelectOption('Unhappy with rating','Unhappy with rating'));
            lstLossReasons.add(new SelectOption('Price too High','Price too High'));
            lstLossReasons.add(new SelectOption('Wants free listing','Wants free listing'));*/
            //added by saiv
            lstLossReasons.add(new SelectOption('Closed Practice','Closed Practice'));
            lstLossReasons.add(new SelectOption('Customer Experience','Customer Experience'));
            lstLossReasons.add(new SelectOption('Financial','Financial'));
            lstLossReasons.add(new SelectOption('Leads','Leads'));
            lstLossReasons.add(new SelectOption('New Marketing Strategy','New Marketing Strategy'));
            lstLossReasons.add(new SelectOption('Public Health Issue','Public Health Issue'));
            lstLossReasons.add(new SelectOption('Customer Unresponsive','Customer Unresponsive'));
            lstLossReasons.add(new SelectOption('Silent Cancel','Silent Cancel'));
            lstLossReasons.add(new SelectOption('Other','Other'));
            
        } // added by saiv - end NCONS -72
        else {
            lstLossReasons = getPicklistValues(new invoiceit_s__Job__c(),'Loss_Reasons__c');
        }
        
        
        
          lstInnerClassORPC = new List<InnerClassORPC>();
        lstOrderRPCToUpdate = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        
        /***not adding pagination logic as of now *********************/
        for(invoiceit_s__Job_Rate_Plan_Charge__c oRPC : orderRPCList) {
            if(parentChargeIdVschildCharge.containsKey(oRPC.id)){
                InnerClassORPC wrapcharge = new InnerClassORPC(oRPC,new List<invoiceit_s__Job_Rate_Plan_Charge__c>{parentChargeIdVschildCharge.get(oRPC.id)});
                invoiceit_s__Job_Rate_Plan_Charge__c addonchatParent = parentChargeIdVschildCharge.get(oRPC.id);
                
                //to check professional profile and get the status from junction chat object
                if(oRPC.Name.contains('Professional Profile')){
                    wrapcharge.childorderchatStatus = chatProductChargeVSchatProduct.get(oRPC.id).status__c;
                }
                
                
                List<addonchatwrapper> addonlist = new List<addonchatwrapper>();
                system.debug('@@@@@@@addonchatParent.id'+addonchatParent.id);
                If(addonchatParentVsaddonchats.containsKey(addonchatParent.id)){
                    for(invoiceit_s__Job_Rate_Plan_Charge__c orpcChat : addonchatParentVsaddonchats.get(addonchatParent.id)){
                        addonchatwrapper addon = new addonchatwrapper(orpcChat,false);
                        addonlist.add(addon);
                    }
                    wrapcharge.addoncharges = addonlist;
                }
                
                
                 lstInnerClassORPC.add(wrapcharge);
            }
            else{
                 lstInnerClassORPC.add(new InnerClassORPC(oRPC,null));
            }
            
            if(oRPC.Package_Wrapper__c){
                if(parentChargeIdVschildCharge.containsKey(oRPC.id)){
                     InnerClassORPC wrapcharge = new InnerClassORPC(oRPC,new List<invoiceit_s__Job_Rate_Plan_Charge__c>{parentChargeIdVschildCharge.get(oRPC.id)});
                invoiceit_s__Job_Rate_Plan_Charge__c addonchatParent = parentChargeIdVschildCharge.get(oRPC.id);
                    
                     //to check professional profile and get the status from junction chat object
                if(oRPC.Name.contains('Professional Profile')){
                    wrapcharge.childorderchatStatus = chatProductChargeVSchatProduct.get(oRPC.id).status__c;
                }
                List<addonchatwrapper> addonlist = new List<addonchatwrapper>();
                     system.debug('@@@@@@@addonchatParent.id2'+addonchatParent.id);
                If(addonchatParentVsaddonchats.containsKey(addonchatParent.id)){
                    for(invoiceit_s__Job_Rate_Plan_Charge__c orpcChat : addonchatParentVsaddonchats.get(addonchatParent.id)){
                        addonchatwrapper addon = new addonchatwrapper(orpcChat,false);
                        addonlist.add(addon);
                    }
                    wrapcharge.addoncharges = addonlist;
                }
                    packageWrap = wrapcharge;
                }
                else{
                    packageWrap = new InnerClassORPC(oRPC, null);
                }
                
            }else if(ORPC.Package_Component__c){
                if(parentChargeIdVschildCharge.containsKey(oRPC.id)){
                    
                     InnerClassORPC wrapcharge = new InnerClassORPC(oRPC,new List<invoiceit_s__Job_Rate_Plan_Charge__c>{parentChargeIdVschildCharge.get(oRPC.id)});
                invoiceit_s__Job_Rate_Plan_Charge__c addonchatParent = parentChargeIdVschildCharge.get(oRPC.id);
                     //to check professional profile and get the status from junction chat object
                if(oRPC.Name.contains('Professional Profile')){
                    wrapcharge.childorderchatStatus = chatProductChargeVSchatProduct.get(oRPC.id).status__c;
                }
                List<addonchatwrapper> addonlist = new List<addonchatwrapper>();
                     system.debug('@@@@@@@addonchatParent.Opportunity_Rate_Plan_Charge__c3'+addonchatParent.id);
                If(addonchatParentVsaddonchats.containsKey(addonchatParent.id)){
                    for(invoiceit_s__Job_Rate_Plan_Charge__c orpcChat : addonchatParentVsaddonchats.get(addonchatParent.id)){
                        addonchatwrapper addon = new addonchatwrapper(orpcChat,false);
                        addonlist.add(addon);
                    }
                    wrapcharge.addoncharges = addonlist;
                }
                    
                    
                    componentWrap.add(wrapcharge);
                }
                else{
                     componentWrap.add(new InnerClassORPC(oRPC,null));
                }
                
            }else{
                if(parentChargeIdVschildCharge.containsKey(oRPC.id)){
                    
                       InnerClassORPC wrapcharge = new InnerClassORPC(oRPC,new List<invoiceit_s__Job_Rate_Plan_Charge__c>{parentChargeIdVschildCharge.get(oRPC.id)});
                invoiceit_s__Job_Rate_Plan_Charge__c addonchatParent = parentChargeIdVschildCharge.get(oRPC.id);
                     //to check professional profile and get the status from junction chat object
                if(oRPC.Name.contains('Professional Profile')){
                    wrapcharge.childorderchatStatus = chatProductChargeVSchatProduct.get(oRPC.id).status__c;
                }
                List<addonchatwrapper> addonlist = new List<addonchatwrapper>();
                     system.debug('wrapcharge'+wrapcharge);
                     system.debug('@@@@@@@addonchatParent.id4'+addonchatParent.id);
                If(addonchatParentVsaddonchats.containsKey(addonchatParent.id)){
                    for(invoiceit_s__Job_Rate_Plan_Charge__c orpcChat : addonchatParentVsaddonchats.get(addonchatParent.id)){
                        addonchatwrapper addon = new addonchatwrapper(orpcChat,false);
                        addonlist.add(addon);
                    }
                    wrapcharge.addoncharges = addonlist;
                }
                    independentWrap.add(wrapcharge);
                }
                else{
                    InnerClassORPC ind = new InnerClassORPC(oRPC,null);
                     List<addonchatwrapper> addonlist = new List<addonchatwrapper>();
                       
                     // check for child order in both parent and child scenarios
                    //if(((childorderId != NULL && oRPC.invoiceit_s__Order__c == childorderId)
                      //    || oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.Parent_Order__c != NULL)
                       //  && 
                      If(oRPC.Chat_Parent_Order_Rate_Plan_Charge__c == NULL
                        && !addonchatParentVsaddonchats.isEmpty()
                        && addonchatParentVsaddonchats.containsKey(oRPC.id)){
                             for(invoiceit_s__Job_Rate_Plan_Charge__c orpcChat : addonchatParentVsaddonchats.get(oRPC.id)){
                                addonchatwrapper addon = new addonchatwrapper(orpcChat,false);
                                addonlist.add(addon);
                        }
                          ind.addoncharges = addonlist;
                            system.debug('@@@in adoncharget'+ ind.addoncharges);
                    }
                    independentWrap.add(ind);
                }
                
            }
        }
        
        
        
         if(orderObj.invoiceit_s__Status__c == 'Cancelled') {
                cancelcharge=false;
                cancelorder=false; 
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'This order cannot be cancelled since it is already Cancelled'); 
                ApexPages.addMessage(errMsg);   
                return;
        }
        if(orderObj.invoiceit_s__Status__c == 'Expired') {
                cancelcharge=false;
                cancelorder=false; 
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'This order cannot be cancelled since it is already Expired'); 
                ApexPages.addMessage(errMsg);   
                return;
        }  
  
        
        
    }
    
    
      public Pagereference cancel() {
        return new PageReference('/'+orderId);
    }
    
 
    public List<SelectOption> getItems() {
       List<SelectOption> options = new List<SelectOption>(); 
       options.add(new SelectOption('Yes','Yes')); 
       options.add(new SelectOption('No','No')); 
       return options; 
   }
   
    Public void initialize(){
        invoiceit_s__Job_Rate_Plan_Charge__c orderRPC = new invoiceit_s__Job_Rate_Plan_Charge__c();
         for(invoiceit_s__Job_Rate_Plan_Charge__c orderRPCtemp : orderRPCList) {
             //excluding ngage charges here
             if(orderRPCtemp.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.Parent_Order__c == NULL){
                 TotalValue += orderRPCtemp.of_days__c;
             }
                
         }
         invoiceit_s__Job__c jobtoupdate = new invoiceit_s__Job__c(Id=orderObj.id);
         jobtoupdate.Total_ECF__c = TotalValue;
         update jobtoupdate;
    }
    
    
     public Pagereference cancelCharges() {
        System.debug('Counter value is ***'+counter);
        Savepoint sp1 = Database.setSavepoint();
            Integer totalCharges = 0;
            Integer cancelledCharges = 0;
            Integer totalchildCharges = 0;
            Integer cancelledchildCharges = 0;
        List<InnerClassORPC> allChargesList = new List<InnerClassORPC>();
         Map<id,Chat_Product_Order_Charge__c> chatchargestoUpdateMap = new Map<id,Chat_Product_Order_Charge__c>();
         system.debug('@@@packagewrap'+packageWrap);
        if(packageWrap != null && packageWrap.isChecked == true){
            allChargesList.add(packageWrap);
            if(componentWrap != null){
                for(InnerClassORPC inn : componentWrap) {                    
                    inn.isChecked = true;
                    inn.orderRPC.Loss_Reasons__c = packageWrap.orderRPC.Loss_Reasons__c;
                }
            }            
        }
        if(componentWrap != null){
           allChargesList.addAll(componentWrap);
            for(InnerClassORPC inn : componentWrap){
            if(inn.isChecked == true){
                compPanelFlag = true;
                break;
                }
            }
        }
        if(independentWrap != null)
        allChargesList.addAll(independentWrap);
        try {
                    
            for(InnerClassORPC inn : allChargesList) {
                if(inn.isChecked == true && inn.orderRPC.invoiceit_s__Status__c != 'Cancelled') {
                    counter = counter + 1;
                }
            }
            invoiceit_s__Job_Rate_Plan_Charge__c orderRPC = new invoiceit_s__Job_Rate_Plan_Charge__c();
            invoiceit_s__Job_Rate_Plan_Charge__c childorderRPC = new invoiceit_s__Job_Rate_Plan_Charge__c();
           //MHBS-4006 starts  
             map<Id,string> mapofproducttoURL = new map<Id,string>();  
                map<string,list<string>> mapofURLtoProductName = new map<string,list<string>>();
            list<Order_Charge_Attribute__c> listofatt = [select Id, Name,Order_Rate_Plan_Charge__c,Order_Rate_Plan_Charge__r.Name,Attribute_Name__c,String_Value__c,  
                                           Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name ,Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c  
                                           from Order_Charge_Attribute__c where Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c =: orderid and Attribute_Name__c = 'URL'];  
                                            
            for(Order_Charge_Attribute__c att: listofatt){  
             String OrderRPCId= att.Order_Rate_Plan_Charge__c;  
             mapofproducttoURL.put(OrderRPCId,att.String_Value__c);
             
              string productname = att.Order_Rate_Plan_Charge__r.Name;
                         if(mapofURLtoProductName.containskey(att.String_Value__c)){  
                          list<string> templist = mapofURLtoProductName.get(att.String_Value__c);  
                            templist.add(productname);  
                            mapofURLtoProductName.put(att.String_Value__c,templist);    
                         }else{ 
                            mapofURLtoProductName.put(att.String_Value__c,new list<string>{productname});    
                         }                             
                        }   
            
            list<Id> updateMilestoneRPC = new list<Id>(); 
            
            for(InnerClassORPC inn : allChargesList) {              
                
                if(inn.isChecked == true && inn.orderRPC.invoiceit_s__Status__c != 'Cancelled') {
                    counter = counter + 1;
                    System.debug('Counter value is %%%'+counter);
                    if(inn.orderRPC.Loss_Reasons__c != null) {
                        orderRPC = inn.orderRPC;
                        orderRPC.invoiceit_s__Status__c = 'Cancelled';
                        lstOrderRPCToUpdate.add(orderRPC);
                        //cancelledCharges++;
                        if(inn.orderRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name == 'Ngage Live Chat - External Website'){
                            //cancelledchildCharges++;
                        }
                         /*******child order rpc cancelling**********************/
                        if(inn.childorderRPC !=NULL){
                           /* inn.childorderRPC[0].invoiceit_s__Status__c = 'Cancelled';
                            inn.childorderRPC[0].Loss_Reasons__c = inn.orderRPC.Loss_Reasons__c;
                            lstOrderRPCToUpdate.add(inn.childorderRPC[0]);*/
                              system.debug('Selected Loss Reason Value'+selVal);
                              //lstOrderRPCToUpdate.add(cancelChildCharge(inn.childorderRPC[0],inn.orderRPC.Loss_Reasons__c, NULL));
                            string selctdValue;
                            if(inn.childorderRPC[0].Loss_Reasons__c != NULL){
                                selctdValue = inn.childorderRPC[0].Loss_Reasons__c;
                            }
                            else{
                                selctdValue = inn.orderRPC.Loss_Reasons__c;
                            }
                            /*System.debug('@Ra : inn.childorderRPC[0].Loss_Reasons__c--> ' + inn.childorderRPC[0].Loss_Reasons__c);
                            System.debug('@Ra : inn.orderRPC.Loss_Reasons__c--> ' + inn.orderRPC.Loss_Reasons__c);
                            System.debug('@Ra : selctdValue--> ' + selctdValue);
                            System.debug('@Ra : childorderchatlossReason--> ' + inn.childorderchatlossReason);
                                if(inn.orderRPC.name.contains('Professional Profile')){
                                    selctdValue = inn.childorderchatlossReason;
                                 }
                                System.debug('@RA: chatProductChargeVSchatProduct -- > ' + JSON.serialize(chatProductChargeVSchatProduct));
                                */
                                if(!inn.orderRPC.name.contains('Professional Profile') || (chatProductChargeVSchatProduct.keySet() != null && chatProductChargeVSchatProduct.keySet().size() == 1 )){
                                    System.debug('@RA:selctdValue--> '+ selctdValue); 
                                    lstOrderRPCToUpdate.add(cancelChildCharge(inn.childorderRPC[0],selctdValue, NULL));
                                }
                                else{
                                    
                                    if(!chatProductChargeVSchatProduct.isEmpty() && chatProductChargeVSchatProduct.containsKey(inn.orderRPC.id)){
                                        Chat_Product_Order_Charge__c chattemp = chatProductChargeVSchatProduct.get(inn.orderRPC.id);
                                        if(chattemp.Status__c != 'Cancelled'){
                                            system.debug('@@@@@in junction object cancelling');
                                            chattemp.Status__c = 'Cancelled';
                                            chattemp.LossReasons__c  = selctdValue;
                                             chatchargestoUpdateMap.put(chattemp.id,chattemp);
                                        }
                                    }
                                    
                                    System.debug('chatProductChargeVSchatProduct-->'+ JSON.serialize(chatProductChargeVSchatProduct));
                                    
                                    Boolean isAllCancelled = true;
                                    for(String tempJunction : chatProductChargeVSchatProduct.keySet()){
                                        Chat_Product_Order_Charge__c chattemp = chatProductChargeVSchatProduct.get(tempJunction);
                                        if(chattemp.Status__c != 'Cancelled'){
                                            isAllCancelled = false;
                                            break;
                                        }
                                    }
                                    if(isAllCancelled){
                                        lstOrderRPCToUpdate.add(cancelChildCharge(inn.childorderRPC[0],selctdValue, NULL));
                                    }
                                    
                                }
                            
                            //cancelledchildCharges++;
                            //cancelledCharges++;
                        }
                        
                        /***************add on chats cancelling here***********************/
                            if(inn.addoncharges != NULL){
                                System.debug('@AB :inn.childorderRPC--> ' + JSON.serialize(inn.childorderRPC));
                                for(addonchatwrapper addonchat : inn.addoncharges){
                                    /*addonchat.orderRPC.invoiceit_s__Status__c = 'Cancelled';
                                    addonchat.orderRPC.Loss_Reasons__c = inn.orderRPC.Loss_Reasons__c;
                                    lstOrderRPCToUpdate.add(addonchat.orderRPC);*/
                                      system.debug('Selected Loss Reason Value'+selVal);
                                      system.debug('@AB : child order '+JSON.serialize(addonchat.orderRPC));
                                      system.debug('@AB : inn--> ' + JSON.serialize(inn));
                                        if(inn.childorderRPC != null && inn.childorderRPC[0].invoiceit_s__Status__c == 'Cancelled'){
                                            lstOrderRPCToUpdate.add(cancelChildCharge(addonchat.orderRPC,inn.orderRPC.Loss_Reasons__c, NULL));
                                        }
                                    if(inn.childorderRPC == null && inn.orderRPC != null){
                                        lstOrderRPCToUpdate.add(cancelChildCharge(addonchat.orderRPC,inn.orderRPC.Loss_Reasons__c, NULL));
                                    }
                                    
                                            System.debug('@AB :lstOrderRPCToUpdate--> ' + JSON.serialize(lstOrderRPCToUpdate));
                                    //cancelledchildCharges++;
                                    //cancelledCharges++;
                                }
                                System.debug('@AB :inn.addoncharges--> ' + JSON.serialize(inn.addoncharges));
                                
                            }
                       
                    }
                    else {
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Loss Reasons before cancelling the charges'); 
                        ApexPages.addMessage(errMsg);   
                        return null;
                    }
                }
                
     if(inn.isChecked == false && inn.orderRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c == '01980' && inn.orderRPC.invoiceit_s__Status__c!='Cancelled'){  
           system.debug('check1');  
            string ROFURL = mapofproducttoURL.get(inn.orderRPC.Id);  
            List<string> prodlist = mapofURLtoProductName.get(ROFURL);
      for(InnerClassORPC objinn : allChargesList){  
        if(objinn.isChecked == true && (objinn.orderRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name == 'Web Bronze' ||     
            objinn.orderRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name == 'Web Silver')){  
            system.debug('check2'); 
            string ParentURL= mapofproducttoURL.get(objinn.orderRPC.Id);   
            if(ROFURL==ParentURL){  
               ApexPages.Message errMsg1 = new ApexPages.Message(ApexPages.Severity.WARNING,'Please cancel "Review Page Plus" product if its related "Web Bronze" or "Web Silver" product is cancelled');    
                ApexPages.addMessage(errMsg1);  
                system.debug('check3'); 
                return null;    
            }  else{              
                if(prodlist.size() == 1){
                    if(!isError){
                        isError = true;
                        system.debug('check4'); 
                        return null;
                    }else{
                      system.debug('check5');
                    }
                }
               // return null;
            } 
        
           }    
        }   
      }     
       if(inn.isChecked == true && inn.orderRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c == '01980' && inn.orderRPC.invoiceit_s__Status__c!='Cancelled'){ 
          string ROFURL = mapofproducttoURL.get(inn.orderRPC.Id);    
          for(InnerClassORPC objinn : allChargesList){ 
            if(objinn.isChecked == false && (objinn.orderRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name == 'Web Bronze' ||    
                objinn.orderRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name == 'Web Silver')){  
                system.debug('check2'); 
                string ParentURL= mapofproducttoURL.get(objinn.orderRPC.Id);   
                if(ROFURL==ParentURL){  
                   updateMilestoneRPC.add(inn.orderRPC.Id);                     
                }   
        
           }    
        }   
      } 
                
                //Id individual add on chats selected then cancelling add on chats here
                If((inn.childorderRPC !=NULL && !inn.ischildChecked) || (!inn.isChecked && inn.childorderRPC == NULL)){
                    If(inn.addoncharges != NULL){
                        for(addonchatwrapper addonchat : inn.addoncharges){
                            if(addonchat.isChecked) {
                                counter = counter + 1;
                               IF(addonchat.orderRPC.Loss_Reasons__c != NULL){
                                   /* addonchat.orderRPC.invoiceit_s__Status__c = 'Cancelled';
                                    addonchat.orderRPC.Loss_Reasons__c = addonchat.orderRPC.Loss_Reasons__c;
                                    lstOrderRPCToUpdate.add(addonchat.orderRPC);*/
                                     system.debug('Selected Loss Reason Value'+selVal);
                                     system.debug('@RA : child order '+JSON.serialize(addonchat.orderRPC));
                                     system.debug('@@@@ inn.childorderRPC[0]'+inn.childorderRPC);
                                     if(inn.childorderRPC != null && inn.childorderRPC[0].invoiceit_s__Status__c == 'Cancelled'){
                                         
                                     
                                        lstOrderRPCToUpdate.add(cancelChildCharge(addonchat.orderRPC,addonchat.orderRPC.Loss_Reasons__c, NULL));
                                    }
                                    
                                    //Added by Sai C 07/25/2018
                                    if(inn.childorderRPC == null && inn.orderRPC != null){
                                        lstOrderRPCToUpdate.add(cancelChildCharge(addonchat.orderRPC,addonchat.orderRPC.Loss_Reasons__c, NULL));
                                    }
                                    
                                   //cancelledchildCharges++; 
                                   //cancelledCharges++;
                                   //lstOrderRPCToUpdate.add(cancelChildCharge(addonchat.orderRPC, addonchat.orderRPC.Loss_Reasons__c, NULL));
                                 }
                                 else{
                                     ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Loss Reasons before cancelling the add on charges'); 
                                 ApexPages.addMessage(errMsg);   
                                 return null;
                                  }
                              }
                           
                        }
                    }
                }
               
            }
             
             //T1 - MHBS-4006 starts  
      
                                                
    if(updateMilestoneRPC.size()>0){  
        set<Id> projectIds = new set<Id>(); 
            for(Milestone1_Project__c proj: [select Id,Order_Rate_Plan_Charge__c from Milestone1_Project__c where Order_Rate_Plan_Charge__c in: updateMilestoneRPC]){   
              projectIds.add(proj.Id);  
            }   
                
            list<Milestone1_Milestone__c> UpdateROFMil = new list<Milestone1_Milestone__c>();   
            for(Milestone1_Milestone__c mil: [select Id,project__c,status__c from Milestone1_Milestone__c where project__c in:projectIds and Name = 'K - Review Page Plus']){    
              mil.status__c = 'Not Needed'; 
              system.debug('***milestonereview');
              UpdateROFMil.add(mil);    
            }   
             update UpdateROFMil;   
                
             list<Milestone1_Task__c> UpdateROFMilesTasks = new list<Milestone1_Task__c>(); 
                
             for(Milestone1_Task__c tasks: [select Id,Task_Stage__c,Project_Milestone__c from Milestone1_Task__c where Project_Milestone__c in: UpdateROFMil]){ 
             tasks.Task_Stage__c = 'Not Required'; 
             system.debug('&&taskreview');               
             UpdateROFMilesTasks.add(tasks);    
             }  
             update UpdateROFMilesTasks;    
        
    }   
        
    //MHBS-4006 ends
            
             if(counter == 0) {
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select some charges before cancelling them'); 
                    ApexPages.addMessage(errMsg);   
                    return null;
              }
            
           
            
            /***********child junction chat order rate plan charge LOGic*******************************************************/
              if(chatchargestoUpdateMap.size()>0){
                update chatchargestoUpdateMap.values();
                  
                  
                  //if all junction child chat order rate plan charges are cancelled then we need to cancel the 
                  //child order charge as well
                  Map<string,Integer>ProfessionalChildVscancelledchats = new Map<string,Integer>();
                  if(!childchargestotUpdateIds.isEmpty()){
                      for(aggregateResult ag: [select count(id) cnt,Chat_Usage_Order_Rate_Plan_Charge__c chatusage
                                                       From Chat_Product_Order_Charge__c
                                                       where Chat_Usage_Order_Rate_Plan_Charge__c IN:childchargestotUpdateIds
                                                          AND Status__c = 'Cancelled'
                                                          AND Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Status__c != 'Cancelled'
                                               Group by Chat_Usage_Order_Rate_Plan_Charge__c]){
                              ProfessionalChildVscancelledchats.put(string.valueOf(ag.get('chatusage')), Integer.valueOf(ag.get('cnt')));                     
                        }
                      
                      if(!ProfessionalChildVscancelledchats.isEmpty()){
                          
                          for(String childchargeid : ProfessionalChildVscancelledchats.keyset()){
                              if(chatusagelist.containsKey(childchargeid)){
                                  if(chatusagelist.get(childchargeid).size() == ProfessionalChildVscancelledchats.get(childchargeid)){
                                      Map<id,invoiceit_s__Job_Rate_Plan_Charge__c> tempMap = new Map<id,invoiceit_s__Job_Rate_Plan_Charge__c>(lstOrderRPCToUpdate);
                                      if(!tempMap.containsKey(childchargeid)){
                                            lstOrderRPCToUpdate.add(new invoiceit_s__Job_Rate_Plan_Charge__c(id=childchargeid , invoiceit_s__Status__c='Cancelled',Loss_Reasons__c='From Parent'));
                                      }
                                    
                                  }
                              }
                              
                              
                          }
                          
                      }
                      
                      
                  }
                  
            }
           /***********child junction chat order rate plan charge LOGic END*******************************************************/
          
              if(lstOrderRPCToUpdate.size() > 0){
                system.debug('@@@@lstOrderRPCToUpdate'+lstOrderRPCToUpdate);
             
                     update lstOrderRPCToUpdate;
               }
          
            
            
            
            
            Set<Id> ordertoCancel = new Set<Id>();
            ordertoCancel.add(orderId);
            if(childorderId != NULL){
                ordertoCancel.add(childorderId);
            }
            
            Map<Id,Integer>orderVsTotalCharges = new Map<Id,Integer>();
            Map<Id,Integer>orderVsTotalCancelledCharges = new Map<Id,Integer>();
           for(invoiceit_s__Job_Rate_Plan_Charge__c ordcharge : [select id,invoiceit_s__Status__c,
                                                                      invoiceit_s__Order__c
                                                                      From invoiceit_s__Job_Rate_Plan_Charge__c
                                                                 where invoiceit_s__Order__c IN:ordertoCancel]){
              
              /****************Order Total count logic start********************************/                                                       
             if(orderVsTotalCharges.containsKey(ordcharge.invoiceit_s__Order__c)){
                Integer countemp=   orderVsTotalCharges.get(ordcharge.invoiceit_s__Order__c);
                 countemp++;
                 orderVsTotalCharges.put(ordcharge.invoiceit_s__Order__c,countemp);
             }
              else{
                     orderVsTotalCharges.put(ordcharge.invoiceit_s__Order__c,1);                                                    
               }                                                        
                /****************Order Total count logic END********************************/  
                                                                     
                
             /****************Order Cancelled count logic start********************************/   
             if(ordcharge.invoiceit_s__Status__c == 'Cancelled'){
                      if(orderVsTotalCancelledCharges.containsKey(ordcharge.invoiceit_s__Order__c)){
                        Integer countemp=   orderVsTotalCancelledCharges.get(ordcharge.invoiceit_s__Order__c);
                         countemp++;
                         orderVsTotalCancelledCharges.put(ordcharge.invoiceit_s__Order__c,countemp);
                        }
                    else{
                        orderVsTotalCancelledCharges.put(ordcharge.invoiceit_s__Order__c,1);                                                    
                    }                                                              
            }                                                        
                                                          
                /****************Order Cancelled count logic END********************************/  
                                                                     
                                                                          
           }
            
             List<invoiceit_s__Job__c> orders_toUpdate = new List<invoiceit_s__Job__c>(); 
            
            If(!orderVsTotalCharges.isEmpty()){
                
                for(Id ordId :orderVsTotalCharges.keyset()){
                    if(orderVsTotalCancelledCharges.containsKey(ordId)){
                        If(orderVsTotalCharges.get(ordId) == orderVsTotalCancelledCharges.get(ordId)){
                             Integer numberOfDays = Date.daysInMonth(system.today().year(), system.today().month());
                              Date serviceEndDate = Date.newInstance(system.today().year(), system.today().month(), numberOfDays);
                
                            invoiceit_s__Job__c singleOrder = new invoiceit_s__Job__c();
                            singleOrder.id = ordId;
                            singleOrder.invoiceit_s__Status__c = 'Cancelled';
                           singleOrder.Loss_Reasons__c = 'No reason given';
                            singleOrder.invoiceit_s__Service_End_Date__c = serviceEndDate;
                            singleOrder.Cancellation_Date__c = system.today();
                            //update orderObj;
                            orders_toUpdate.add(singleOrder);
                        }
                    }
                }
                
            }
            
            
            
            
            
            
          
             
            system.debug('@@@ after child update');
            
            
            //setting orders to cancel status new logic here
            /***********************************************************************************************************/
            
            
            
            
            
            
            
            
            
           
            
            //counting charges here : total charges, total child charges, cancelled charges
         /*   for(InnerClassORPC inn : allChargesList) {
                //totalCharges ++;
                system.debug('@@@@cancelledchildCharges 1'+cancelledchildCharges);
                //this is to consider ngage external chat products as child charges
                if(inn.orderRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name == 'Ngage Live Chat - External Website'){
                     totalchildCharges ++;
                    if(inn.orderRPC.invoiceit_s__Status__c == 'Cancelled'){
                       cancelledchildCharges++;
                        
                    }
                }
                else{
                    totalCharges ++;
                    if(inn.orderRPC.invoiceit_s__Status__c == 'Cancelled'){
                        cancelledCharges ++;
                    }
                }
                 system.debug('@@@@cancelledchildCharges 2'+cancelledchildCharges);
                
                 if(inn.childorderRPC != NULL && inn.childorderRPC[0].invoiceit_s__Status__c == 'Cancelled'){
                          //cancelledCharges ++; 
                          cancelledchildCharges++;
                     }
                 system.debug('@@@@cancelledchildCharges 3'+cancelledchildCharges);
                if(inn.addoncharges != NULL){
                          for(addonchatwrapper addonchat : inn.addoncharges){
                                 If(addonchat.orderRPC.invoiceit_s__Status__c == 'Cancelled')
                                     // cancelledCharges ++; 
                                     cancelledchildCharges++;
                                    
                                }
                           
                      }
                 system.debug('@@@@cancelledchildCharges 4'+cancelledchildCharges);
                 if(inn.childorderRPC != NULL){
                         // totalCharges ++; 
                     totalchildCharges ++;
                  }
                if(inn.addoncharges != NULL){
                    //totalCharges = totalCharges + inn.addoncharges.size();
                    totalchildCharges = totalchildCharges+ inn.addoncharges.size();
                }
                
                system.debug('@@@@cancelledchildCharges 5'+cancelledchildCharges);
              /*  if(inn.isChecked || inn.orderRPC.invoiceit_s__Status__c == 'Cancelled'){
                    cancelledCharges ++;
                     if(inn.childorderRPC != NULL && inn.childorderRPC[0].invoiceit_s__Status__c == 'Cancelled'){
                          cancelledCharges ++; 
                          cancelledchildCharges++;
                     }
                     if(inn.addoncharges != NULL){
                          for(addonchatwrapper addonchat : inn.addoncharges){
                                 If(addonchat.orderRPC.invoiceit_s__Status__c == 'Cancelled')
                                      cancelledCharges ++; 
                                     cancelledchildCharges++;
                                    
                                }
                           
                      }
                }
            } */  
            
       
            
            
            //cancelling order status here as all charges cancelled under this order
           /* if(totalCharges == cancelledCharges){
                              
                Integer numberOfDays = Date.daysInMonth(system.today().year(), system.today().month());
                Date serviceEndDate = Date.newInstance(system.today().year(), system.today().month(), numberOfDays);
                
                System.debug('CHarge List to be updated is :'+lstOrderRPCToUpdate);
                orderObj.invoiceit_s__Status__c = 'Cancelled';
                orderObj.Loss_Reasons__c = 'No reason given';
                orderObj.invoiceit_s__Service_End_Date__c = serviceEndDate;
                orderObj.Cancellation_Date__c = system.today();
                //update orderObj;
                orders_toUpdate.add(orderObj);
                
                //cancelling child order also here
                for(invoiceit_s__Job__c order_renewed : orderObj.Orders__r){
                    //newOrder = order_renewed;
                    order_renewed.invoiceit_s__Status__c = 'Cancelled';
                    order_renewed.Loss_Reasons__c = 'No reason given';
                    order_renewed.Cancellation_Date__c = system.today();
                    orders_toUpdate.add(order_renewed);
                }
                system.debug('cancel charges::'+orders_toUpdate);
                               
            } 
            
            //IF all child order charges cancelled then cancelling child order here
            system.debug('@@@@@totalchildCharges'+totalchildCharges);
            system.debug('@@@@@cancelledchildCharges'+cancelledchildCharges);
            IF(childorderId != NULL && totalchildCharges >0 && totalchildCharges == cancelledchildCharges ){
               Integer numberOfDays = Date.daysInMonth(system.today().year(), system.today().month());
                Date serviceEndDate = Date.newInstance(system.today().year(), system.today().month(), numberOfDays);
                
            
                invoiceit_s__Job__c childorder = new invoiceit_s__Job__c();
                childorder.id               = childorderId;
                childorder.invoiceit_s__Status__c = 'Cancelled';
                childorder.Loss_Reasons__c = 'No reason given';
                childorder.invoiceit_s__Service_End_Date__c = serviceEndDate;
                childorder.Cancellation_Date__c = system.today();
                //update orderObj;
                orders_toUpdate.add(childorder); 
            }*/
            
            if(orders_toUpdate.size() > 0){
                 update orders_toUpdate;
            }
                   

                
            //return new PageReference('/'+orderId);
             return new PageReference('/apex/MDL_ForceWindowClose?id='+orderId);  
        }
        catch(System.Exception e) {
            cancelcharge=false;
            cancelorder=false;
            Integer startOfError;
            Integer endOfError;
            String error;
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                startOfError = e.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')+35;
                endOfError = e.getMessage().indexOf(':',startOfError);
                error = e.getMessage().substring(startOfError,endOfError);
            }
            Database.rollback(sp1);
            //ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,error); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,error));   
            return null;            
        }
    }
    
      public void changeList(){
        system.debug('pagenumber -----> ' + PageNumber);
        lstInnerClassORPC = new List<InnerClassORPC>(); 
        if(lstOfLstInnerClassORPC[PageNumber-1] != null)            
        lstInnerClassORPC = lstOfLstInnerClassORPC[PageNumber-1];   
    }
    
     public Pagereference updateIndependentCharges(){
        showLossReason = true;
        Savepoint sp = Database.setSavepoint();
        try{            
            if(radiobuttonstatus == null && TotalValue!= 0.0){
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select Yes or No for Waive ECF charges'); 
                ApexPages.addMessage(errMsg);   
                return null;
            }
            if(orderObj.Reason_for_Waiver__c == null && TotalValue != 0.0 && radiobuttonstatus == 'Yes'){             
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Reason for Waiver before cancelling the order'); 
                ApexPages.addMessage(errMsg);   
                return null;                
            }
            System.debug('selVal here'+selVal );
            if(selVal == '--None--' || selVal == 'None') {
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Loss Reasons before cancelling the order'); 
                ApexPages.addMessage(errMsg);   
                return null;
            //added by saiv---start
            }else if(selVal == 'Other' && orderObj.Other_Cancel_Reason__c == null){
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Other Cancel Reason before cancelling the order'); 
                ApexPages.addMessage(errMsg);   
                return null;
            }else if((selVal == 'Closed Practice' || selVal == 'Customer Experience' || selVal == 'Financial'
                        ||selVal == 'Leads' || selVal == 'New Marketing Strategy' || selVal == 'Public Health Issue' || selVal == '')
                       && selVal2 =='--None--'){
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Secondary Loss Reasons before cancelling the order'); 
                ApexPages.addMessage(errMsg);   
                return null;
            //added by saiv---end
            }else if(selVal != '--None--'){
                invoiceit_s__Job_Rate_Plan_Charge__c orderRPC = new invoiceit_s__Job_Rate_Plan_Charge__c();
                lstOrderRPCToUpdate = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
                
                Integer numberOfDays = Date.daysInMonth(system.today().year(), system.today().month());
                Date serviceEndDate = Date.newInstance(system.today().year(), system.today().month(), numberOfDays);
                Date firstDayOfMonth = System.today().toStartOfMonth();
                invoiceit_s__Job_Rate_Plan_Charge__c ecfrateplancharge = new  invoiceit_s__Job_Rate_Plan_Charge__c();
                invoiceit_s__Job_Product__c ecfproduct = new invoiceit_s__Job_Product__c();
                invoiceit_s__Job_Rate_Plan__c ecfrateplan = new invoiceit_s__Job_Rate_Plan__c();
                
                List<invoiceit_s__Product__c> earlycancellationproduct = [select Name,Id,invoiceit_s__Product_Code__c,invoiceit_s__Product_Family__c,invoiceit_s__Description__c,(select id ,invoiceit_s__Description__c,Name ,Product_Code__c from invoiceit_s__ProductRatePlan__r) from invoiceit_s__Product__c where Name ='Early Cancellation Fee' LIMIT 1];
                
                String rateplanid;
                String productrateplanid;
                String productrateplanname;
                String productrateplandescription;
                String productrateplanproductcode;
                for (invoiceit_s__Product__c prod : earlycancellationproduct) {
                    list<invoiceit_s__Product_Rate_Plan__c> prodrateplan = prod.invoiceit_s__ProductRatePlan__r;
                     rateplanid = prodrateplan[0].id;
                     productrateplanid = prodrateplan[0].Id;
                     productrateplandescription = prodrateplan[0].invoiceit_s__Description__c;
                     productrateplanname= prodrateplan[0].Name ;
                     productrateplanproductcode = prodrateplan[0].Product_Code__c ;                   
                }
                
                List<invoiceit_s__Product_Rate_Plan_Charge__c> prodrateplancharge = [select Id,Name,invoiceit_s__Product_Rate_Plan__c,invoiceit_s__Charge_Sequence_Number__c,
                    invoiceit_s__Accounting_Code__c,invoiceit_s__Unit_Price__c,invoiceit_s__CurrencyL__c,invoiceit_s__Price_Format__c,invoiceit_s__Price_Type__c,invoiceit_s__Product_Charge_Category__c from invoiceit_s__Product_Rate_Plan_Charge__c where invoiceit_s__Product_Rate_Plan__c =: productrateplanid];
                
                
                System.debug('============================'+radiobuttonstatus);

                System.debug('============================'+orderObj.invoiceit_s__Status__c);

                System.debug('============================'+radiobuttonstatus);

                System.debug('============================'+radiobuttonstatus);

               
                for(InnerClassORPC inn : independentWrap) {
                    System.debug('before');
                    System.debug('+++++'+inn.orderRPC.invoiceit_s__Status__c);                  
                    System.debug('after');
                    if(inn.orderRPC.invoiceit_s__Status__c != 'Cancelled' && inn.orderRPC.invoiceit_s__Status__c != 'Expired' && inn.orderRPC.invoiceit_s__Status__c != 'Truncated'){
                        If((!isChildOrder && !inn.orderRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name.contains('External')) || isChildOrder){
                        if(inn.orderRPC.invoiceit_s__Price_Type__c!='One Time') {
                            orderRPC = inn.orderRPC;
                            orderRPC.invoiceit_s__Status__c = 'Cancelled';
                            orderRPC.Loss_Reasons__c = selVal;
                            orderRPC.invoiceit_s__Service_End_Date__c = serviceEndDate;
                            lstOrderRPCToUpdate.add(orderRPC);
                            system.debug('@@@Before if cancelled');
                             if(inn.childorderRPC!= NULL &&  !inn.childorderRPC.isEmpty()){
                                /*inn.childorderRPC[0].invoiceit_s__Status__c = 'Cancelled';
                                inn.childorderRPC[0].Loss_Reasons__c = selVal;
                                 inn.childorderRPC[0].invoiceit_s__Service_End_Date__c = serviceEndDate;
                                lstOrderRPCToUpdate.add(inn.childorderRPC[0]);*/
                                  system.debug('Selected Loss Reason Value'+selVal);
                                  lstOrderRPCToUpdate.add(cancelChildCharge(inn.childorderRPC[0],selVal, serviceEndDate));
                                
                          }
                            system.debug('@@@inn.addoncharges'+inn.addoncharges);
                             If(inn.addoncharges != NULL &&  !inn.addoncharges.isEmpty()){
                                     for(addonchatwrapper addonchat : inn.addoncharges){
                                              /*  addonchat.orderRPC.invoiceit_s__Status__c = 'Cancelled';
                                                addonchat.orderRPC.Loss_Reasons__c = selVal;
                                               addonchat.orderRPC.invoiceit_s__Service_End_Date__c = serviceEndDate;
                                               lstOrderRPCToUpdate.add(addonchat.orderRPC);*/
                                          system.debug('Selected Loss Reason Value'+selVal);
                                          lstOrderRPCToUpdate.add(cancelChildCharge(addonchat.orderRPC,selVal, serviceEndDate));
                                            
                                         }
                                 }
                        }
                        else{
                            if(inn.orderRPC.Fulfilment_Start_Date__c==null){
                                orderRPC = inn.orderRPC;
                                orderRPC.invoiceit_s__Status__c = 'Cancelled';
                                orderRPC.Loss_Reasons__c = selVal;
                                orderRPC.invoiceit_s__Service_End_Date__c = serviceEndDate;
                                lstOrderRPCToUpdate.add(orderRPC);
                                if(inn.childorderRPC!= NULL && !inn.childorderRPC.isEmpty()){
                                   /* inn.childorderRPC[0].invoiceit_s__Status__c = 'Cancelled';
                                    inn.childorderRPC[0].Loss_Reasons__c = selVal;
                                     inn.childorderRPC[0].invoiceit_s__Service_End_Date__c = serviceEndDate;
                                    
                                    lstOrderRPCToUpdate.add(inn.childorderRPC[0]);*/
                                    system.debug('Selected Loss Reason Value'+selVal);
                                    lstOrderRPCToUpdate.add(cancelChildCharge(inn.childorderRPC[0],selVal, serviceEndDate));
                                    
                             }
                                 If(inn.addoncharges != NULL){
                                          for(addonchatwrapper addonchat : inn.addoncharges){
                                               /* addonchat.orderRPC.invoiceit_s__Status__c = 'Cancelled';
                                                addonchat.orderRPC.Loss_Reasons__c = selVal;
                                               addonchat.orderRPC.invoiceit_s__Service_End_Date__c = serviceEndDate;
                                               lstOrderRPCToUpdate.add(addonchat.orderRPC);*/
                                               system.debug('Selected Loss Reason Value'+selVal);
                                               lstOrderRPCToUpdate.add(cancelChildCharge(addonchat.orderRPC,selVal, serviceEndDate));
                                            
                                         }
                                       
                                     }
                            }
                        }
                       }     
                    }
                }
                
                System.debug('%%%%'+ecfrateplancharge);
                System.debug('&&&Order updated&&&');
                
                 if(lstOrderRPCToUpdate.size() > 0){
                    
                    RecursionHandlerOrderRPC.beforeupdate = True; //as first ECF creation stopping trigger execution
                                                                  // making this flag true to run the trigger once again
                    MDL_RecursionHandler.firstRun = True;
                    system.debug('@@@@updating cancel here');
                    
                    Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> tempMap = new Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c>();
                    for(invoiceit_s__Job_Rate_Plan_Charge__c orpct :lstOrderRPCToUpdate){
                        tempMap.put(orpct.id,orpct);
                    }
                    update tempMap.Values();
                }
                
                List<invoiceit_s__Job__c> orders_toUpdate = new List<invoiceit_s__Job__c>();
                invoiceit_s__Job__c newOrder;
                //if(orderObj.invoiceit_s__Status__c == 'Evergreen'){
                //    orderObj.Reason_for_Waiver__c = 'Evergreen Order';
                //}
                
                System.debug('CHarge List to be updated is :'+lstOrderRPCToUpdate);
                orderObj.invoiceit_s__Status__c = 'Cancelled';
                orderObj.Loss_Reasons__c = selVal;
                orderObj.Secondary_Loss_Reason__c = selVal2; //addedbysaiv
                orderObj.invoiceit_s__Service_End_Date__c = serviceEndDate;
                System.debug('Active Order Service End date is :'+orderObj.invoiceit_s__Service_End_Date__c);
                orderObj.Cancellation_Date__c = system.today();
                system.debug('===orderObj.Other_Cancel_Reason__c==='+orderObj.Other_Cancel_Reason__c);
                
                if(childorderId != NULL){
                    system.debug('@@@@childorderId'+childorderId);
                    List<invoiceit_s__Job_Rate_Plan_Charge__c> childordercancelledcharges= new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
                        childordercancelledcharges =  [select id, Name,invoiceit_s__Status__c,
                                                                      invoiceit_s__Order__c
                                                                      From invoiceit_s__Job_Rate_Plan_Charge__c
                                                                 where invoiceit_s__Order__c =:childorderId
                                                                and invoiceit_s__Status__c != 'Cancelled'];
                    system.debug('@@@@childordercancelledcharges'+childordercancelledcharges);
                    if(childordercancelledcharges.isEmpty()){
                        invoiceit_s__Job__c childOrder = new invoiceit_s__Job__c(
                                                     id=childorderId,
                                                      invoiceit_s__Status__c = 'Cancelled',
                                                     Loss_Reasons__c = selVal, Secondary_Loss_Reason__c = selVal2, //added by saiv
                                                Cancellation_Date__c = system.today(),
                                                Other_Cancel_Reason__c = orderObj.Other_Cancel_Reason__c,
                                                invoiceit_s__Service_End_Date__c = serviceEndDate);
                        orders_toUpdate.add(childOrder);
                    }
                    
                }
                
                system.debug('@@@@orders_toUpdate'+orders_toUpdate);
                 //cancelling child order also here
                for(invoiceit_s__Job__c order_renewed : orderObj.Orders__r){
                    system.debug('===orderObj.Other_Cancel_Reason__c==='+orderObj.Other_Cancel_Reason__c);
                    //newOrder = order_renewed;
                    order_renewed.invoiceit_s__Status__c = 'Cancelled';
                    order_renewed.Loss_Reasons__c = selVal;
                    order_renewed.Secondary_Loss_Reason__c = selVal2;
                    order_renewed.Other_Cancel_Reason__c = orderObj.Other_Cancel_Reason__c; //addedbysaiv
                    //order_renewed.Cancellation_Date__c = system.today();
                    order_renewed.invoiceit_s__Service_End_Date__c = serviceEndDate;
                   // orders_toUpdate.add(order_renewed); 
                }
                //update orderObj;
                //Recursion avoided here by adding boolean
                MDL_trgHandlerOnOrderForStatus.updateLossReasonRecursion = true;
                
                system.debug('@@@@@@updating cancel here');
                orders_toUpdate.add(orderObj);
                
                 system.debug('cancel order:::'+orders_toUpdate);
                if(orders_toUpdate.size() > 0)
                    update orders_toUpdate;
                
                
                //moving this code here : sai : 22/06
                 if(radiobuttonstatus == 'No' && orderObj.invoiceit_s__Status__c != 'Evergreen'){
                    ecfproduct = new invoiceit_s__Job_Product__c(Name = earlycancellationproduct[0].Name,invoiceit_s__Product_Family__c = earlycancellationproduct[0].invoiceit_s__Product_Family__c,invoiceit_s__Description__c=earlycancellationproduct[0].invoiceit_s__Description__c ,invoiceit_s__SequenceNumber__c=1,invoiceit_s__Product__c= earlycancellationproduct[0].Id,invoiceit_s__Job__c=orderObj.id,invoiceit_s__Product_Code__c = earlycancellationproduct[0].invoiceit_s__Product_Code__c);
                    insert ecfproduct;
                    
                    ecfrateplan = new invoiceit_s__Job_Rate_Plan__c(Name = productrateplanname,invoiceit_s__Description__c=productrateplandescription,invoiceit_s__Job_Product__c = ecfproduct.id,invoiceit_s__Product_Rate_Plan__c=productrateplanid);
                    insert ecfrateplan;
                    
                    ecfrateplancharge = new invoiceit_s__Job_Rate_Plan_Charge__c(Name= prodrateplancharge[0].Name,invoiceit_s__Job_Rate_Plan__c=ecfrateplan.id,invoiceit_s__Order__c=orderId,invoiceit_s__Unit_Price__c=TotalValue,invoiceit_s__Status__c='Active',invoiceit_s__Price_Type__c=prodrateplancharge[0].invoiceit_s__Price_Type__c,invoiceit_s__Quantity__c=1.00,invoiceit_s__Price__c=TotalValue,invoiceit_s__Net_Total__c=TotalValue,invoiceit_s__Discount_Type__c='By Percentage',invoiceit_s__Tax__c=0.00,invoiceit_s__Tax_Percentage__c=0.00,invoiceit_s__Discount_Value__c=0.00,invoiceit_s__Sequence_No__c=prodrateplancharge[0].invoiceit_s__Charge_Sequence_Number__c,invoiceit_s__Accounting_Code__c=prodrateplancharge[0].invoiceit_s__Accounting_Code__c,invoiceit_s__Price_Format__c=prodrateplancharge[0].invoiceit_s__Price_Format__c,invoiceit_s__Product_Charge_Category__c=prodrateplancharge[0].invoiceit_s__Product_Charge_Category__c,invoiceit_s__Product_Rate_Plan_Charge__c=prodrateplancharge[0].id,invoiceit_s__CurrencyL__c = prodrateplancharge[0].invoiceit_s__CurrencyL__c,Terms_Months__c = 1);
                    insert ecfrateplancharge;                    
                    
                // Un-Commented by Sai C    
                }
               
               
                    
               
                    
                
                //orderObj.invoiceit_s__Recalculate__c = true;
                //List<invoiceit_s__Job__c> ordlistToRecal = new List<invoiceit_s__Job__c>();
                //ordlistToRecal.add(orderObj);
                
                //if(ordlistToRecal.size() > 0)
                //    update ordlistToRecal;
                 
                return new PageReference('/'+orderId);
            }
            return null;
         }
         catch(System.Exception e) {
            cancelcharge=false;
            cancelorder=false;
            Integer startOfError;
            Integer endOfError;
            String error;
             system.debug('@@@@@exception'+e);
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                startOfError = e.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')+35;
                endOfError = e.getMessage().indexOf(':',startOfError);
                error = e.getMessage().substring(startOfError,endOfError);
            }
            Database.rollback(sp);
            //ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,error); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,error));   
            return null;
        }  
        
        
    }
    
    
     public PageReference updateAllCharges(){
        showLossReason = true;
        Savepoint sp = Database.setSavepoint();
        System.debug('=================='+radiobuttonstatus);
        try {
            if(radiobuttonstatus == null && TotalValue!= 0.0){
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select Yes or No for Waive ECF charges'); 
                ApexPages.addMessage(errMsg);   
                return null;
            }
            if(orderObj.Reason_for_Waiver__c == null && TotalValue != 0.0 && radiobuttonstatus == 'Yes'){                  
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Reason for Waiver before cancelling the order'); 
                ApexPages.addMessage(errMsg);   
                return null;                
            }
            System.debug('selVal here'+selVal );
            if(selVal == '--None--') {
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Loss Reasons before cancelling the order'); 
                ApexPages.addMessage(errMsg);   
                return null;
            //added by saiv---start
            }else if(selVal == 'Other' && orderObj.Other_Cancel_Reason__c == null){
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Other Cancel Reason before cancelling the order'); 
                ApexPages.addMessage(errMsg);   
                return null;
            }else if((selVal == 'Closed Practice' || selVal == 'Customer Experience' || selVal == 'Financial'
                        ||selVal == 'Leads' || selVal == 'New Marketing Strategy' || selVal == 'Public Health Issue' || selVal == '')
                       && selVal2 =='--None--'){
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Secondary Loss Reasons before cancelling the order'); 
                ApexPages.addMessage(errMsg);   
                return null;
            //added by saiv---end
            }else if(selVal != '--None--'){
                invoiceit_s__Job_Rate_Plan_Charge__c orderRPC = new invoiceit_s__Job_Rate_Plan_Charge__c();
                lstOrderRPCToUpdate = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
                //if(radiobuttonstatus == 'Yes' || TotalValue == 0.0){
                    if(packageWrap != null && packageWrap.orderRPC.invoiceit_s__Status__c != 'Cancelled' && packageWrap.orderRPC.invoiceit_s__Status__c != 'Expired' && packageWrap.orderRPC.invoiceit_s__Status__c != 'Truncated'){
                        if(packageWrap.orderRPC.invoiceit_s__Price_Type__c!='One Time'){
                            orderRPC = packageWrap.orderRPC;
                            orderRPC.invoiceit_s__Status__c = 'Cancelled';
                            orderRPC.Loss_Reasons__c = selVal;
                            lstOrderRPCToUpdate.add(orderRPC);
                        }else{
                            if(packageWrap.orderRPC.Fulfilment_Start_Date__c==null){
                                orderRPC = packageWrap.orderRPC;
                                orderRPC.invoiceit_s__Status__c = 'Cancelled';
                                orderRPC.Loss_Reasons__c = selVal;
                                lstOrderRPCToUpdate.add(orderRPC);
                             }
                        }
                    }
                //}
                Integer numberOfDays = Date.daysInMonth(system.today().year(), system.today().month());
                Date serviceEndDate = Date.newInstance(system.today().year(), system.today().month(), numberOfDays);
                Date firstDayOfMonth = System.today().toStartOfMonth();
                invoiceit_s__Job_Rate_Plan_Charge__c ecfrateplancharge = new  invoiceit_s__Job_Rate_Plan_Charge__c();
                invoiceit_s__Job_Product__c ecfproduct = new invoiceit_s__Job_Product__c();
                invoiceit_s__Job_Rate_Plan__c ecfrateplan = new invoiceit_s__Job_Rate_Plan__c();
                
                List<invoiceit_s__Product__c> earlycancellationproduct = [select Name,Id,invoiceit_s__Product_Code__c,invoiceit_s__Product_Family__c,invoiceit_s__Description__c,(select id ,invoiceit_s__Description__c,Name ,Product_Code__c from invoiceit_s__ProductRatePlan__r) from invoiceit_s__Product__c where Name ='Early Cancellation Fee' LIMIT 1];
                
                String rateplanid;
                String productrateplanid;
                String productrateplanname;
                String productrateplandescription;
                String productrateplanproductcode;
                for (invoiceit_s__Product__c prod : earlycancellationproduct) {
                    list<invoiceit_s__Product_Rate_Plan__c> prodrateplan = prod.invoiceit_s__ProductRatePlan__r;
                     rateplanid = prodrateplan[0].id;
                     productrateplanid = prodrateplan[0].Id;
                     productrateplandescription = prodrateplan[0].invoiceit_s__Description__c;
                     productrateplanname= prodrateplan[0].Name ;
                     productrateplanproductcode = prodrateplan[0].Product_Code__c ;                   
                }
                
                List<invoiceit_s__Product_Rate_Plan_Charge__c> prodrateplancharge = [select Id,Name,invoiceit_s__Product_Rate_Plan__c,invoiceit_s__Charge_Sequence_Number__c,
                    invoiceit_s__Accounting_Code__c,invoiceit_s__Unit_Price__c,invoiceit_s__CurrencyL__c,invoiceit_s__Price_Format__c,invoiceit_s__Price_Type__c,invoiceit_s__Product_Charge_Category__c from invoiceit_s__Product_Rate_Plan_Charge__c where invoiceit_s__Product_Rate_Plan__c =: productrateplanid];
                
                
                System.debug('============================'+radiobuttonstatus);

                System.debug('============================'+orderObj.invoiceit_s__Status__c);

                System.debug('============================'+radiobuttonstatus);

                System.debug('============================'+radiobuttonstatus);

                if(radiobuttonstatus == 'No' && orderObj.invoiceit_s__Status__c != 'Evergreen'){
                    System.debug('=========Inside if condition===========');
                    ecfproduct = new invoiceit_s__Job_Product__c(Name = earlycancellationproduct[0].Name,invoiceit_s__Product_Family__c = earlycancellationproduct[0].invoiceit_s__Product_Family__c,invoiceit_s__Description__c=earlycancellationproduct[0].invoiceit_s__Description__c ,invoiceit_s__SequenceNumber__c=1,invoiceit_s__Product__c= earlycancellationproduct[0].Id,invoiceit_s__Job__c=orderObj.id,invoiceit_s__Product_Code__c = earlycancellationproduct[0].invoiceit_s__Product_Code__c);
                    insert ecfproduct;
                    
                    System.debug('======================='+ecfproduct);
                    
                    ecfrateplan = new invoiceit_s__Job_Rate_Plan__c(Name = productrateplanname,invoiceit_s__Description__c=productrateplandescription,invoiceit_s__Job_Product__c = ecfproduct.id,invoiceit_s__Product_Rate_Plan__c=productrateplanid);
                    insert ecfrateplan;
                    
                    ecfrateplancharge = new invoiceit_s__Job_Rate_Plan_Charge__c(Name= prodrateplancharge[0].Name,invoiceit_s__Job_Rate_Plan__c=ecfrateplan.id,invoiceit_s__Order__c=orderId,invoiceit_s__Unit_Price__c=TotalValue,invoiceit_s__Status__c='Active',invoiceit_s__Price_Type__c=prodrateplancharge[0].invoiceit_s__Price_Type__c,invoiceit_s__Quantity__c=1.00,invoiceit_s__Price__c=TotalValue,invoiceit_s__Net_Total__c=TotalValue,invoiceit_s__Discount_Type__c='By Percentage',invoiceit_s__Tax__c=0.00,invoiceit_s__Tax_Percentage__c=0.00,invoiceit_s__Discount_Value__c=0.00,invoiceit_s__Sequence_No__c=prodrateplancharge[0].invoiceit_s__Charge_Sequence_Number__c,invoiceit_s__Accounting_Code__c=prodrateplancharge[0].invoiceit_s__Accounting_Code__c,invoiceit_s__Price_Format__c=prodrateplancharge[0].invoiceit_s__Price_Format__c,invoiceit_s__Product_Charge_Category__c=prodrateplancharge[0].invoiceit_s__Product_Charge_Category__c,invoiceit_s__Product_Rate_Plan_Charge__c=prodrateplancharge[0].id,invoiceit_s__CurrencyL__c = prodrateplancharge[0].invoiceit_s__CurrencyL__c,Terms_Months__c = 1);
                    insert ecfrateplancharge;                    
                    
                //uncommented by Sai C    
                }
                for(InnerClassORPC inn : componentWrap) {
                    System.debug('before');
                    System.debug('+++++'+inn.orderRPC.invoiceit_s__Status__c);                  
                    System.debug('after');
                    if(inn.orderRPC.invoiceit_s__Status__c != 'Cancelled' && inn.orderRPC.invoiceit_s__Status__c != 'Expired' && inn.orderRPC.invoiceit_s__Status__c != 'Truncated'){
                        if(inn.orderRPC.invoiceit_s__Price_Type__c!='One Time') {
                            orderRPC = inn.orderRPC;
                            orderRPC.invoiceit_s__Status__c = 'Cancelled';
                            orderRPC.Loss_Reasons__c = selVal;
                            orderRPC.invoiceit_s__Service_End_Date__c = serviceEndDate;
                            lstOrderRPCToUpdate.add(orderRPC);
                             if(inn.childorderRPC != NULL){
                                 
                               /* inn.childorderRPC[0].invoiceit_s__Status__c = 'Cancelled';
                                inn.childorderRPC[0].Loss_Reasons__c = selVal;
                                 inn.childorderRPC[0].invoiceit_s__Service_End_Date__c = serviceEndDate;*/
                                system.debug('Selected Loss Reason Value'+selVal);
                                lstOrderRPCToUpdate.add(cancelChildCharge(inn.childorderRPC[0],selVal, serviceEndDate));
                          }
                        }
                        else{
                            //if(packageWrap.orderRPC.invoiceit_s__Status__c == 'Cancelled'){
                                orderRPC = inn.orderRPC;
                               /* orderRPC.invoiceit_s__Status__c = 'Cancelled';
                                orderRPC.Loss_Reasons__c = selVal;
                                orderRPC.invoiceit_s__Service_End_Date__c = serviceEndDate;*/
                              lstOrderRPCToUpdate.add(cancelChildCharge(orderRPC,selVal, serviceEndDate));
                                //lstOrderRPCToUpdate.add(orderRPC);
                                 if(inn.childorderRPC != NULL){
                                   /* inn.childorderRPC[0].invoiceit_s__Status__c = 'Cancelled';
                                    inn.childorderRPC[0].Loss_Reasons__c = selVal;
                                     inn.childorderRPC[0].invoiceit_s__Service_End_Date__c = serviceEndDate;
                                    lstOrderRPCToUpdate.add(inn.childorderRPC[0]);*/
                                      system.debug('Selected Loss Reason Value'+selVal);
                                      lstOrderRPCToUpdate.add(cancelChildCharge(inn.childorderRPC[0],selVal, serviceEndDate));
                              }
                            //}
                        }
                    }
                    
                    If(inn.addoncharges != NULL){
                        for(addonchatwrapper addonchat : inn.addoncharges){
                           
                            lstOrderRPCToUpdate.add(cancelChildCharge(addonchat.orderRPC,selVal, serviceEndDate));
                            
                        }
                                       
                    }
                }
                for(InnerClassORPC inn : independentWrap) {                        
                    System.debug('+++++inn'+inn.orderRPC.invoiceit_s__Status__c);
                    if(inn.orderRPC.invoiceit_s__Status__c != 'Cancelled' && inn.orderRPC.invoiceit_s__Status__c != 'Expired' && inn.orderRPC.invoiceit_s__Status__c != 'Truncated'){
                         If((!isChildOrder && !inn.orderRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name.contains('External')) || isChildOrder){
                                          if(inn.orderRPC.invoiceit_s__Price_Type__c!='One Time') {
                                  
                                    orderRPC = inn.orderRPC;
                                    orderRPC.invoiceit_s__Status__c = 'Cancelled';
                                    orderRPC.Loss_Reasons__c = selVal;
                                    orderRPC.invoiceit_s__Service_End_Date__c = serviceEndDate;
                                     if(inn.childorderRPC != NULL){
                                       /* inn.childorderRPC[0].invoiceit_s__Status__c = 'Cancelled';
                                        inn.childorderRPC[0].Loss_Reasons__c = selVal;
                                         inn.childorderRPC[0].invoiceit_s__Service_End_Date__c = serviceEndDate;
                                        lstOrderRPCToUpdate.add(inn.childorderRPC[0]);*/
                                          lstOrderRPCToUpdate.add(cancelChildCharge(inn.childorderRPC[0],selVal, serviceEndDate));
                                  }
                                    lstOrderRPCToUpdate.add(orderRPC);
                                }
                                else{
                                    if(inn.orderRPC.Fulfilment_Start_Date__c==null){
                                        orderRPC = inn.orderRPC;
                                        /*orderRPC.invoiceit_s__Status__c = 'Cancelled';
                                        orderRPC.Loss_Reasons__c = selVal;
                                        orderRPC.invoiceit_s__Service_End_Date__c = serviceEndDate;*/
                                        lstOrderRPCToUpdate.add(cancelChildCharge(orderRPC,selVal, serviceEndDate));
                                        if(inn.childorderRPC != NULL){
                                            /*inn.childorderRPC[0].invoiceit_s__Status__c = 'Cancelled';
                                            inn.childorderRPC[0].Loss_Reasons__c = selVal;
                                             inn.childorderRPC[0].invoiceit_s__Service_End_Date__c = serviceEndDate;
                                            lstOrderRPCToUpdate.add(inn.childorderRPC[0]);*/
                                             lstOrderRPCToUpdate.add(cancelChildCharge(inn.childorderRPC[0],selVal, serviceEndDate));
                                      }
                                        lstOrderRPCToUpdate.add(orderRPC);
                                    }
                                }
                            }
                       
                    }
                    
                    If(inn.addoncharges != NULL){
                        for(addonchatwrapper addonchat : inn.addoncharges){
                            system.debug('Selected Loss Reason Value'+selVal);
                            lstOrderRPCToUpdate.add(cancelChildCharge(addonchat.orderRPC,selVal, serviceEndDate));
                            
                        }
                                       
                    }
                }
                
                System.debug('%%%%'+ecfrateplancharge);
                System.debug('&&&Order updated&&&');
                
                List<invoiceit_s__Job__c> orders_toUpdate = new List<invoiceit_s__Job__c>();
                invoiceit_s__Job__c newOrder;
                //if(orderObj.invoiceit_s__Status__c == 'Evergreen'){
                //    orderObj.Reason_for_Waiver__c = 'Evergreen Order';
                //}
                
                System.debug('CHarge List to be updated is :'+lstOrderRPCToUpdate);
                orderObj.invoiceit_s__Status__c = 'Cancelled';
                orderObj.Loss_Reasons__c = selVal;
                orderObj.Secondary_Loss_Reason__c = selVal2; //addedbysaiv
                orderObj.invoiceit_s__Service_End_Date__c = serviceEndDate;
                System.debug('Active Order Service End date is :'+orderObj.invoiceit_s__Service_End_Date__c);
                orderObj.Cancellation_Date__c = system.today();
                //update orderObj;
                //added By Sai C for handling recursion 07/24/2017
                 MDL_trgHandlerOnOrderForStatus.updateLossReasonRecursion = true;
                
                system.debug('@@@@@@ updating cancel here for package');
                //END
                orders_toUpdate.add(orderObj);
                
                IF(childorderId != NULL  ){
                 List<invoiceit_s__Job_Rate_Plan_Charge__c> childordercancelledcharges= new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
                        childordercancelledcharges =  [select id,invoiceit_s__Status__c,
                                                                      invoiceit_s__Order__c
                                                                      From invoiceit_s__Job_Rate_Plan_Charge__c
                                                                 where invoiceit_s__Order__c =:childorderId
                                                                and invoiceit_s__Status__c = 'Cancelled'];
                    system.debug('==orderObj.Other_Cancel_Reason__c=='+orderObj.Other_Cancel_Reason__c);                                            
                    if(childordercancelledcharges.isEmpty()){
                        invoiceit_s__Job__c childorder = new invoiceit_s__Job__c();
                        childorder.id               = childorderId;
                        childorder.invoiceit_s__Status__c = 'Cancelled';
                        childorder.Loss_Reasons__c = selVal;
                        childorder.Secondary_Loss_Reason__c = selVal2; //addedbysaiv
                        childorder.Other_Cancel_Reason__c = orderObj.Other_Cancel_Reason__c; //addedbysaiv
                        childorder.invoiceit_s__Service_End_Date__c = serviceEndDate;
                        childorder.Cancellation_Date__c = system.today();
                        //update orderObj;
                        orders_toUpdate.add(childorder); 
                        
                    }
                    
                
                    
              }
                
               
                system.debug('cancel order:::'+orders_toUpdate);
                if(orders_toUpdate.size() > 0)
                    update orders_toUpdate;
                    
                if(lstOrderRPCToUpdate.size() > 0){
                //Added By Sai C for handling recursion 07/24/2017
                RecursionHandlerOrderRPC.beforeupdate = True; //as first ECF creation stopping trigger execution
                                                                  // making this flag true to run the trigger once again
                    MDL_RecursionHandler.firstRun = True;
                    system.debug('@@@@updating cancel here');   
                    update lstOrderRPCToUpdate;
                }   
                //END
                
                //orderObj.invoiceit_s__Recalculate__c = true;
                //List<invoiceit_s__Job__c> ordlistToRecal = new List<invoiceit_s__Job__c>();
                //ordlistToRecal.add(orderObj);
                
                //if(ordlistToRecal.size() > 0)
                //    update ordlistToRecal;
                 
                return new PageReference('/'+orderId);
            }
            return null;
         }
         catch(System.Exception e) {
            cancelcharge=false;
            cancelorder=false;
            Integer startOfError;
            Integer endOfError;
            String error;
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                startOfError = e.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')+35;
                endOfError = e.getMessage().indexOf(':',startOfError);
                error = e.getMessage().substring(startOfError,endOfError);
            }
            Database.rollback(sp);
            //ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,error); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,error));   
            return null;
        }            
    }
    
     
    public static invoiceit_s__Job_Rate_Plan_Charge__c cancelChildCharge(invoiceit_s__Job_Rate_Plan_Charge__c ch,String selvaluet, Date serviceEndDatet){
        system.debug('@@@@selvaluet'+selvaluet);
        ch.invoiceit_s__Status__c = 'Cancelled';
        ch.Loss_Reasons__c = selvaluet;
        ch.invoiceit_s__Service_End_Date__c = serviceEndDatet;
        return ch;
    }
    
    
     @TestVisible static list<SelectOption> getPicklistValues(SObject obj, String fld)
   {
      list<SelectOption> options = new list<SelectOption>();
      options.add(new SelectOption('None','None'));
      // Get the object type of the SObject.
      Schema.sObjectType objType = obj.getSObjectType(); 
      // Describe the SObject using its object type.
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
      // Get a map of fields for the SObject
      map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
      // Get the list of picklist values for this field.
      list<Schema.PicklistEntry> values =
         fieldMap.get(fld).getDescribe().getPickListValues();
      // Add these values to the selectoption list.
      for (Schema.PicklistEntry a : values)
      { 
         options.add(new SelectOption(a.getLabel(), a.getValue())); 
      }
      return options;
      //
   } 
   //method added by saiv
   public void displaySecondaryLossReason(){
       secLossReasons.clear();
       system.debug('===calling sec loss===');
       system.debug('===in if===');
       system.debug('==selval=='+selVal);
       system.debug('==orderObj.Secondary_Loss_Reason__c=='+orderObj.Secondary_Loss_Reason__c);
            //String secreasonLoss = orderObj.Secondary_Loss_Reason__c;
            //secLossReasons.add(new SelectOption('--None--','--None--'));
       if(orderObj.Secondary_Loss_Reason__c!=null){
            String secreasonLoss = orderObj.Secondary_Loss_Reason__c;
            secLossReasons.add(new SelectOption(secreasonLoss,secreasonLoss));
       }
       else if(selVal=='Closed Practice'){
            secLossReasons.add(new SelectOption('--None--','--None--'));
            secLossReasons.add(new SelectOption('Attorney Disbarred','Attorney Disbarred'));
            secLossReasons.add(new SelectOption('Deceased','Deceased'));
            secLossReasons.add(new SelectOption('Firm Dissolved','Firm Dissolved'));
            secLossReasons.add(new SelectOption('Retired','Retired'));
       }
       else if(selVal=='Customer Experience'){
            secLossReasons.add(new SelectOption('--None--','--None--'));
            secLossReasons.add(new SelectOption('Fulfillment Issues','Fulfillment Issues'));
            secLossReasons.add(new SelectOption('Poor Customer Service Experience','Poor Customer Service Experience'));
            secLossReasons.add(new SelectOption('Service Features Did Not Meet Expectations','Service Features Did Not Meet Expectations'));
            secLossReasons.add(new SelectOption('Unhappy with rating','Unhappy with rating'));
       }
       else if(selVal=='Financial'){
            secLossReasons.add(new SelectOption('--None--','--None--'));
            secLossReasons.add(new SelectOption('Financial Hardship','Financial Hardship'));
            secLossReasons.add(new SelectOption('Past Due/ Unable To Pay','Past Due/ Unable To Pay'));
            secLossReasons.add(new SelectOption('Price too High','Price too High'));
       }
       else if(selVal=='Leads'){
            secLossReasons.add(new SelectOption('--None--','--None--'));
            secLossReasons.add(new SelectOption('Low Number of Leads','Low Number of Leads'));
            secLossReasons.add(new SelectOption('Poor Lead Management','Poor Lead Management'));
            secLossReasons.add(new SelectOption('Too many leads for wrong AOP','Too many leads for wrong AOP'));
       }
       else if(selVal=='New Marketing Strategy'){
            secLossReasons.add(new SelectOption('--None--','--None--'));
            secLossReasons.add(new SelectOption('Firm Switching to In House Marketing','Firm Switching to In House Marketing'));
            secLossReasons.add(new SelectOption('Lost to Competitor','Lost to Competitor'));
       }
       else if(selVal=='Public Health Issue'){
            secLossReasons.add(new SelectOption('--None--','--None--'));
            secLossReasons.add(new SelectOption('COVID-19 (Coronavirus)','COVID-19 (Coronavirus)'));
       }
   
   } 
    

}
/*
** Created By : Lister Technologies
** Created Date : 5/8/2014
** Purpose : To Cancel Individual charges in an order or cancel the order as a whole
** Test Class : 
*/
public with sharing class MDL_CancelOrderController {
    
    public InnerClassORPC packageWrap{get;set;}
    public List<InnerClassORPC> componentWrap{get;set;}
    public list<InnerClassORPC> independentWrap{get;set;}
        

    private ApexPages.StandardController standardController;
    public invoiceit_s__Job__c orderObj{get;set;}
    public boolean showLossReason{get;set;}
    public boolean cancelcharge{get;set;}
    public boolean cancelorder{get;set;}
    public Id orderId{get;set;}
    public integer counter;    
    public List<invoiceit_s__Job_Rate_Plan_Charge__c> orderRPCList{get;set;}
    public List<invoiceit_s__Job_Rate_Plan_Charge__c> lstOrderRPCToUpdate;
    public List<InnerClassORPC> lstInnerClassORPC{get;set;}
    public List<List<InnerClassORPC>> lstOfLstInnerClassORPC{get;set;}
    public Integer Items_Per_Page {get;set;}
    public List<Integer> Pagination {get;set;}
    public Integer PageNumber {get;set;}
    public list<selectoption> lstLossReasons{get;set;}
    public String selVal{get;set;}
    public Decimal TotalValue {get;set;}
    Public String radiobuttonstatus{set;get;}
    public Id OrderRatePlanid;
    private set<string> chatprodset = new set<string>();
    private list<Chat_Product_Order_Charge__c> chatlist = new list<Chat_Product_Order_Charge__c>();
    private map<id, list<id>> chatusagelist = new map<id, list<id>>();
    public boolean compPanelFlag {get;set;}   

    public MDL_CancelOrderController(ApexPages.StandardController standardController) {
    
        
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
        compPanelFlag = false;
        map<id, invoiceit_s__Job_Rate_Plan_Charge__c> orderRPCList1 = new  map<id, invoiceit_s__Job_Rate_Plan_Charge__c>();
        lstLossReasons = new list<selectoption>();
        orderObj = new invoiceit_s__Job__c();
        orderObj = [SELECT name, RecordType.DeveloperName, invoiceit_s__Status__c,invoiceit_s__Sub_Total__c,invoiceit_s__Net_Total__c,invoiceit_s__Total__c,Total_ECF__c,invoiceit_s__Recalculate__c,invoiceit_s__Total_Contract_Value__c ,invoiceit_s__Service_Activation_Date__c, Loss_Reasons__c,
                 invoiceit_s__Service_End_Date__c, Reason_for_Waiver__c,
                 (Select Id, invoiceit_s__Status__c, Loss_Reasons__c,Cancellation_Date__c,invoiceit_s__Service_Activation_Date__c,Created_From_Order__c,invoiceit_s__Number_Of_Terms__c,invoiceit_s__Service_End_Date__c  from Orders__r)
                 FROM invoiceit_s__Job__c 
                 WHERE id =: orderId];
       id oldid = null;
       list<id> cpid = new list<id>();
        
        
        //modified by Sai: 24/10/2016
       for ( Chat_Product_Order_Charge__c o: [select Chat_Product_Order_Rate_Plan_Charge__c, Chat_Product_Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c, Chat_Product_Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name, Chat_Usage_Order_Rate_Plan_Charge__c, Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Status__c, Chat_Product_Order_Rate_Plan_Charge__r.invoiceit_s__Status__c  from Chat_Product_Order_Charge__c where Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Order__c = :orderid ])
        {
           chatlist.add(o);
           if(o.Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Status__c != 'Cancelled'
              && o.Chat_Product_Order_Rate_Plan_Charge__r.invoiceit_s__Status__c != 'Cancelled'){
                  if(chatusagelist.containsKey(o.Chat_Usage_Order_Rate_Plan_Charge__c)){
                      chatusagelist.get(o.Chat_Usage_Order_Rate_Plan_Charge__c).add(o.Chat_Product_Order_Rate_Plan_Charge__c);
                  }
                  else{
                      chatusagelist.put(o.Chat_Usage_Order_Rate_Plan_Charge__c, new list<Id>{o.Chat_Product_Order_Rate_Plan_Charge__c});
                  }
              } 
        }    
            
        
        system.debug('@@@chatlist'+chatlist);
        system.debug('@@@chatusagelist'+chatusagelist);
        
//        orderRPCList1 = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        
        for (invoiceit_s__Job_Rate_Plan_Charge__c j:[Select i.Package_Wrapper__c, i.Package_Component__c, i.Name,i.invoiceit_s__Status__c, i.invoiceit_s__Accounting_Code__c,i.invoiceit_s__Service_End_Date__c, i.invoiceit_s__Service_Activation_Date__c, i.invoiceit_s__Row_Total__c, 
                                i.invoiceit_s__Job_Rate_Plan__c, i.invoiceit_s__Price_Type__c,(Select Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, 
                                LastModifiedById, SystemModstamp, LastActivityDate, Attribute_Name__c,Attr_Name__c, Attribute_Order__c, 
                                Attribute_Picklist_Values__c, Attribute_Type__c, Boolean_Value__c, Date_Value__c, Maximum_No_Of_Characters_In_Text__c, 
                                Minimum_No_Of_Characters_In_Text__c, Number_Value__c , Order_Rate_Plan_Charge__c, Phone_Value__c, Picklist_Value__c, String_Value__c
                                From Order_Charge_Attributes__r ORDER By Address_Order__c ASC,Attribute_Order__c DESC NULLS LAST),invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name , Cancel_Date__c , invoiceit_s__Charge_Date__c ,
                                Fulfilment_Start_Date__c , Fulfilment_End_Date__c ,Loss_Reasons__c,of_days__c,Renewable__c,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Product_Bundle_Line__r.invoiceit_s__Is_Quantity_Editable__c,Opportunity_Rate_Plan_Charge__r.Optional_Product__c
                        From invoiceit_s__Job_Rate_Plan_Charge__c i
                        Where i.invoiceit_s__Order__c =: orderid 
                        Order BY invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__SequenceNumber__c,invoiceit_s__Sequence_No__c])
        {
            orderRPCList1.put(j.id, j);
        }
        orderRPCList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        for (id i:orderRPCList1.keyset())
        {
            boolean matchfound = false;
            for (Chat_Product_Order_Charge__c c:chatlist) {
                if (i == c.Chat_Product_Order_Rate_Plan_Charge__c && ! c.Chat_Product_Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name.contains('Professional Profile'))
                {
                    matchfound = true;
                    orderRPCList.add(orderRPCList1.get(i));
                    invoiceit_s__Job_Rate_Plan_Charge__c o1 = new invoiceit_s__Job_Rate_Plan_Charge__c();
                    o1 = orderRPCList1.get(c.Chat_Usage_Order_Rate_Plan_Charge__c);
                    o1.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name = '--> ' + o1.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name;
                    orderRPCList.add(o1);
                }
                if(i == c.Chat_Usage_Order_Rate_Plan_Charge__c && !c.Chat_Product_Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name.contains('Professional Profile') )
                    matchfound = true;
            }
            if (matchfound == false )
            {
                orderRPCList.add(orderRPCList1.get(i));
            }
        }
        if(orderRPCList.size() > 0){
        OrderRatePlanid =  orderRPCList[0].invoiceit_s__Job_Rate_Plan__c;
        
         System.debug('TO BE CANCELELELE:::'+orderRPCList);
        cancelcharge=true;
        cancelorder=true; 
        if(orderObj.invoiceit_s__Status__c == 'Cancelled' && orderObj.Loss_Reasons__c!=null) {
            String reasonLoss = orderObj.Loss_Reasons__c;
            lstLossReasons.add(new SelectOption(reasonLoss,reasonLoss)); // added by saiv - start NCONS -72
        }else if(orderObj.RecordType.DeveloperName == 'M_N_Order') {
            lstLossReasons.add(new SelectOption('--None--','--None--'));
            lstLossReasons.add(new SelectOption('Cancelled - Credit Card Decline','Cancelled - Credit Card Decline'));
            lstLossReasons.add(new SelectOption('Cancelled - Lead','Cancelled - Lead'));
            lstLossReasons.add(new SelectOption('Cancelled - Listings','Cancelled - Listings'));
        
        }  else if(orderObj.RecordType.DeveloperName == 'MH_Orders' || orderObj.RecordType.DeveloperName == 'Nolo_Order' ){
            lstLossReasons.add(new SelectOption('--None--','--None--'));
            lstLossReasons.add(new SelectOption('Duplicate','Duplicate'));
            lstLossReasons.add(new SelectOption('Firm Dissolved/Merged','Firm Dissolved/Merged'));
            lstLossReasons.add(new SelectOption('Fulfillment issues','Fulfillment issues'));
            lstLossReasons.add(new SelectOption('Lost to Competitor','Lost to Competitor'));
            lstLossReasons.add(new SelectOption('No reason given','No reason given'));
            lstLossReasons.add(new SelectOption('No Referrals/Little Value','No Referrals/Little Value'));
            lstLossReasons.add(new SelectOption('Past due/unable to pay','Past due/unable to pay'));
            lstLossReasons.add(new SelectOption('Unhappy with rating','Unhappy with rating'));
            lstLossReasons.add(new SelectOption('Price too High','Price too High'));
            lstLossReasons.add(new SelectOption('Wants free listing','Wants free listing'));
        } // added by saiv - end NCONS -72
        else {
            lstLossReasons = getPicklistValues(new invoiceit_s__Job__c(),'Loss_Reasons__c');
        }           
        System.debug('Loss Reasons Values are:::'+lstLossReasons);              
        lstInnerClassORPC = new List<InnerClassORPC>();
        lstOrderRPCToUpdate = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        
        for(invoiceit_s__Job_Rate_Plan_Charge__c oRPC : orderRPCList) {
            lstInnerClassORPC.add(new InnerClassORPC(oRPC));
            if(lstInnerClassORPC.size() == Items_Per_Page){
                        lstOfLstInnerClassORPC.add(lstInnerClassORPC);
                        lstInnerClassORPC = new List<InnerClassORPC>();
            }
            if(oRPC.Package_Wrapper__c){
                packageWrap = new InnerClassORPC(oRPC);
            }else if(ORPC.Package_Component__c){
                componentWrap.add(new InnerClassORPC(oRPC));
            }else{
                independentWrap.add(new InnerClassORPC(oRPC));
            }
        }
       
        if(lstInnerClassORPC.size() > 0) {
            lstOfLstInnerClassORPC.add(lstInnerClassORPC);
        }
        system.debug('@@@@lstOfLstInnerClassORPC'+lstOfLstInnerClassORPC);    
        //sizeOfPagination =    List_wrapperList.size();
        for(Integer i = 1; i <= lstOfLstInnerClassORPC.size(); i ++){
            Pagination.add(i);
        }
        lstInnerClassORPC = new List<InnerClassORPC>();
        if(lstOfLstInnerClassORPC.size()>0)             
        lstInnerClassORPC = lstOfLstInnerClassORPC[0];   
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
    }// constructer end
    
    
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
            TotalValue += orderRPCtemp.of_days__c;
     }
     invoiceit_s__Job__c jobtoupdate = new invoiceit_s__Job__c(Id=orderObj.id);
     jobtoupdate.Total_ECF__c = TotalValue;
     update jobtoupdate;
    }
    
    public Pagereference cancelCharges() {
        System.debug('Counter value is ***'+counter);
        Savepoint sp1 = Database.setSavepoint();
        List<InnerClassORPC> allChargesList = new List<InnerClassORPC>();
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
            for(InnerClassORPC inn : allChargesList) {
                System.debug('$$isChecked'+inn.isChecked+'Status:::'+inn.orderRPC.invoiceit_s__Status__c);
                if(inn.isChecked == true && inn.orderRPC.invoiceit_s__Status__c != 'Cancelled') {
                    //counter = counter + 1;
                    System.debug('Counter value is %%%'+counter);
                    if(inn.orderRPC.Loss_Reasons__c != null) {
                        orderRPC = inn.orderRPC;
                        orderRPC.invoiceit_s__Status__c = 'Cancelled';
                        for (Chat_Product_Order_Charge__c c:chatlist) {
                            system.debug('@@@@ before final if'+ chatusagelist.get(c.Chat_Usage_Order_Rate_Plan_Charge__c));
                            system.debug('orderRPC: ' + orderRPC.id + ' c: ' + c.Chat_Product_Order_Rate_Plan_Charge__c + ' chat get: ' + chatusagelist.get(c.Chat_Usage_Order_Rate_Plan_Charge__c) + ' chatusagelist: ' + chatusagelist);
                            if (orderRPC.id == c.Chat_Product_Order_Rate_Plan_Charge__c && (chatusagelist.containsKey(c.Chat_Usage_Order_Rate_Plan_Charge__c) && chatusagelist.get(c.Chat_Usage_Order_Rate_Plan_Charge__c).size() == 1) )
                            {
                                system.debug('@@@@ in final if'+ chatusagelist.get(c.Chat_Usage_Order_Rate_Plan_Charge__c));
                                invoiceit_s__Job_Rate_Plan_Charge__c orderRPC1 = new invoiceit_s__Job_Rate_Plan_Charge__c();
                                orderRPC1.id = c.Chat_Usage_Order_Rate_Plan_Charge__c;
                                orderRPC1.invoiceit_s__Status__c = 'Cancelled';
                                orderRPC1.Loss_Reasons__c = orderRPC.Loss_Reasons__c;
                                boolean matchfound = false;
                                for (invoiceit_s__Job_Rate_Plan_Charge__c i:lstOrderRPCToUpdate)
                                {
                                    if (i.id == orderRPC1.id)  matchfound = true;
                                }  
                                if (matchfound == false) lstOrderRPCToUpdate.add(orderRPC1);
                               }                                
                        }
                        boolean matchfound = false;
                        for (invoiceit_s__Job_Rate_Plan_Charge__c i:lstOrderRPCToUpdate)
                        {
                             if (i.id == orderRPC.id)  matchfound = true;
                        }  
                        if (matchfound == false) lstOrderRPCToUpdate.add(orderRPC);
                    }
                    else {
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Loss Reasons before cancelling the charges'); 
                        ApexPages.addMessage(errMsg);   
                        return null;
                    }
                }
                if(counter == 0) {
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select some charges before cancelling them'); 
                    ApexPages.addMessage(errMsg);   
                    return null;
                }
            }
            if(lstOrderRPCToUpdate.size() > 0){
                
                    update lstOrderRPCToUpdate;
            }
                
            
            Integer totalCharges = 0;
            Integer cancelledCharges = 0;
             
            for(InnerClassORPC inn : lstInnerClassORPC) {
                totalCharges ++;
                if(inn.isChecked || inn.orderRPC.invoiceit_s__Status__c == 'Cancelled'){
                    cancelledCharges ++;
                }
            }   
            
            if(totalCharges == cancelledCharges){
                List<invoiceit_s__Job__c> orders_toUpdate = new List<invoiceit_s__Job__c>();                
                Integer numberOfDays = Date.daysInMonth(system.today().year(), system.today().month());
                Date serviceEndDate = Date.newInstance(system.today().year(), system.today().month(), numberOfDays);
                
                System.debug('CHarge List to be updated is :'+lstOrderRPCToUpdate);
                orderObj.invoiceit_s__Status__c = 'Cancelled';
                orderObj.Loss_Reasons__c = 'No reason given';
                orderObj.invoiceit_s__Service_End_Date__c = serviceEndDate;
                orderObj.Cancellation_Date__c = system.today();
                //update orderObj;
                orders_toUpdate.add(orderObj);
                
                
                for(invoiceit_s__Job__c order_renewed : orderObj.Orders__r){
                    //newOrder = order_renewed;
                    order_renewed.invoiceit_s__Status__c = 'Cancelled';
                    order_renewed.Loss_Reasons__c = 'No reason given';
                    order_renewed.Cancellation_Date__c = system.today();
                    orders_toUpdate.add(order_renewed);
                }
                system.debug('cancel charges::'+orders_toUpdate);
                if(orders_toUpdate.size() > 0)
                    update orders_toUpdate;
               
            } 
                
            return new PageReference('/'+orderId);
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
            if(selVal == '--None--') {
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Loss Reasons before cancelling the order'); 
                ApexPages.addMessage(errMsg);   
                return null;
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
                        if(inn.orderRPC.invoiceit_s__Price_Type__c!='One Time') {
                            orderRPC = inn.orderRPC;
                            orderRPC.invoiceit_s__Status__c = 'Cancelled';
                            orderRPC.Loss_Reasons__c = selVal;
                            orderRPC.invoiceit_s__Service_End_Date__c = serviceEndDate;
                            lstOrderRPCToUpdate.add(orderRPC);
                        }
                        else{
                            if(inn.orderRPC.Fulfilment_Start_Date__c==null){
                                orderRPC = inn.orderRPC;
                                orderRPC.invoiceit_s__Status__c = 'Cancelled';
                                orderRPC.Loss_Reasons__c = selVal;
                                orderRPC.invoiceit_s__Service_End_Date__c = serviceEndDate;
                                lstOrderRPCToUpdate.add(orderRPC);
                            }
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
                orderObj.invoiceit_s__Service_End_Date__c = serviceEndDate;
                System.debug('Active Order Service End date is :'+orderObj.invoiceit_s__Service_End_Date__c);
                orderObj.Cancellation_Date__c = system.today();
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
               
               
                    
                if(lstOrderRPCToUpdate.size() > 0){
                    
                    RecursionHandlerOrderRPC.beforeupdate = True; //as first ECF creation stopping trigger execution
                                                                  // making this flag true to run the trigger once again
                    MDL_RecursionHandler.firstRun = True;
                    system.debug('@@@@updating cancel here');
                    update lstOrderRPCToUpdate;
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
                        }
                        else{
                            //if(packageWrap.orderRPC.invoiceit_s__Status__c == 'Cancelled'){
                                orderRPC = inn.orderRPC;
                                orderRPC.invoiceit_s__Status__c = 'Cancelled';
                                orderRPC.Loss_Reasons__c = selVal;
                                orderRPC.invoiceit_s__Service_End_Date__c = serviceEndDate;
                                lstOrderRPCToUpdate.add(orderRPC);
                            //}
                        }
                    }
                }
                for(InnerClassORPC inn : independentWrap) {                        
                    System.debug('+++++inn'+inn.orderRPC.invoiceit_s__Status__c);
                    if(inn.orderRPC.invoiceit_s__Status__c != 'Cancelled' && inn.orderRPC.invoiceit_s__Status__c != 'Expired' && inn.orderRPC.invoiceit_s__Status__c != 'Truncated'){
                        if(inn.orderRPC.invoiceit_s__Price_Type__c!='One Time') {
                            orderRPC = inn.orderRPC;
                            orderRPC.invoiceit_s__Status__c = 'Cancelled';
                            orderRPC.Loss_Reasons__c = selVal;
                            orderRPC.invoiceit_s__Service_End_Date__c = serviceEndDate;
                            lstOrderRPCToUpdate.add(orderRPC);
                        }
                        else{
                            if(inn.orderRPC.Fulfilment_Start_Date__c==null){
                                orderRPC = inn.orderRPC;
                                orderRPC.invoiceit_s__Status__c = 'Cancelled';
                                orderRPC.Loss_Reasons__c = selVal;
                                orderRPC.invoiceit_s__Service_End_Date__c = serviceEndDate;
                                lstOrderRPCToUpdate.add(orderRPC);
                            }
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
                orderObj.invoiceit_s__Service_End_Date__c = serviceEndDate;
                System.debug('Active Order Service End date is :'+orderObj.invoiceit_s__Service_End_Date__c);
                orderObj.Cancellation_Date__c = system.today();
                //update orderObj;
                //added By Sai C for handling recursion 07/24/2017
                 MDL_trgHandlerOnOrderForStatus.updateLossReasonRecursion = true;
                
                system.debug('@@@@@@ updating cancel here for package');
                //END
                orders_toUpdate.add(orderObj);
                
               
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
   }
    public class InnerClassORPC{
                     
        public boolean isChecked {get;set;}
        public invoiceit_s__Job_Rate_Plan_Charge__c orderRPC{get;set;}          
        
        public InnerClassORPC(invoiceit_s__Job_Rate_Plan_Charge__c oRPC) {
            isChecked = false;
            orderRPC = oRPC;
        }    
    }
    
}
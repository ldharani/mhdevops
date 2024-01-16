/*****************************************************************************************
Created By : Lister Technologies
Created Date : June 5,2015
Created Purpose : MHBS-80 Automate Evergreen process
*****************************************************************************************/
global class MDL_BatchAutomateEvergreenProcess implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    global String query;
    public Date endDate;
    public Set<Id> setOrderIds;
    public Set<Id> setErrorOrderIds;
    public Set<Id> setExcludeOrderIds;
    public Set<Id> setCorrectOrderIds;
    public integer noOfTerms;
    public Integer noOfDays;
    public List<Case> lstCasesToUpdate;
    public List<invoiceit_s__Job__c> lstOrdersToUpdate;
    public Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>> mapOrderIdNLstOrderRPC;
    public Map<Id,Opportunity> mapOrderIdToOpp;
    global Set<Id> orderIdstoBatch;
    global MDL_BatchAutomateEvergreenProcess(){
        
        endDate = Date.Today().addmonths(1).toStartOfMonth().addDays(-1);
        System.debug('===========End Date============='+endDate);
        //endDate = Date.newInstance(2018,11,30);
        if(Test.isRunningTest()){
            endDate = Date.Today().addMonths(2).toStartOfMonth().addDays(-1);
        }
        noOfTerms = null;       
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
       //List<Id> lstIds = new List<Id>{'a0H0U000001kdhW'};
        //List<Id> lstIds = new List<Id>();
        mapOrderIdToOpp = new Map<Id,Opportunity>();
        orderIdstoBatch = new Set<Id>();
       // query = 'Select '+getObjectFields('invoiceit_s__Job__c')+' from invoiceit_s__Job__c where id IN:lstIds AND invoiceit_s__Service_End_Date__c = :endDate and invoiceit_s__Status__c = \'Active\' and Renew_Rebase__c = null and invoiceit_s__Account__r.Credit_Status__c!=\'Bad Debt\' and invoiceit_s__Account__r.Credit_Status__c!=\'Past Due\' and invoiceit_s__Account__r.BillingCountry!=\'Canada\' and Do_Not_Renew__c!=true and invoiceit_s__Account__r.Sub_Type__c = \'Small Law\' and (RecordType.DeveloperName = \'MH_Orders\' OR RecordType.DeveloperName = \'Nolo_Order\' OR RecordType.DeveloperName = \'M_NG_Order\')';
        query = 'Select '+getObjectFields('invoiceit_s__Job__c')+' from invoiceit_s__Job__c where invoiceit_s__Service_End_Date__c = :endDate and invoiceit_s__Status__c = \'Active\' and Renew_Rebase__c = null and invoiceit_s__Account__r.Credit_Status__c!=\'Bad Debt\' and invoiceit_s__Account__r.Credit_Status__c!=\'Past Due\' and invoiceit_s__Account__r.BillingCountry!=\'Canada\' and Do_Not_Renew__c!=true and invoiceit_s__Account__r.Sub_Type__c = \'Small Law\' and (RecordType.DeveloperName = \'MH_Orders\' OR RecordType.DeveloperName = \'Nolo_Order\' OR RecordType.DeveloperName = \'M_NG_Order\')';
        System.debug('Checking the Record Type'+query);
        if(Test.isRunningTest()){
            query += ' and invoiceit_s__Account__r.Name like \'%testAcc%\' LIMIT 5';
        }
        system.debug('@@@@query'+ query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<invoiceit_s__Job__c> scope) {
        System.debug('@@@@@List of orders in execute'+scope);
        //Commented for evergreen test        
        MDL_BatchAutoEvergreenHandler.OppsClosedLostWhenOppIsClosedWon(scope);
        //System.enqueueJob(new MDL_BatchAutoEvergreenQueueable(scope));
        setOrderIds = new Set<Id>();
        setErrorOrderIds = new Set<Id>();
        setCorrectOrderIds = new Set<Id>();
        setExcludeOrderIds = new Set<Id>();
        lstCasesToUpdate = new List<Case>();
        lstOrdersToUpdate = new List<invoiceit_s__Job__c>();
        mapOrderIdNLstOrderRPC = new Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>>();
        for(invoiceit_s__Job__c order : scope){
            setOrderIds.add(order.Id);
            orderIdstoBatch.add(order.Id);
        }
        //consider only Active and 'Monthly' charges
        for(invoiceit_s__Job_Rate_Plan_Charge__c orderRPC : [Select Id,invoiceit_s__Service_End_Date__c,invoiceit_s__Order__c,invoiceit_s__Price_Type__c from invoiceit_s__Job_Rate_Plan_Charge__c where invoiceit_s__Order__c in :setOrderIds and invoiceit_s__Status__c = 'Active' and (invoiceit_s__Price_Type__c='Monthly' or invoiceit_s__Price_Type__c = 'Usage') and Renewable__c = true]){
            system.debug('orderRPC:::'+orderrpc);
            if(mapOrderIdNLstOrderRPC.containsKey(orderRPC.invoiceit_s__Order__c)){
                mapOrderIdNLstOrderRPC.get(orderRPC.invoiceit_s__Order__c).add(orderRPC);
            }
            else{
                mapOrderIdNLstOrderRPC.put(orderRPC.invoiceit_s__Order__c,new List<invoiceit_s__Job_Rate_Plan_Charge__c>{orderRPC});
            }
        }
        system.debug('mapOrderIdNLstOrderRPC Map::::'+mapOrderIdNLstOrderRPC);
        // check if the service end dates of the order and the charges are same
        for(Id orderId : mapOrderIdNLstOrderRPC.keyset()){
            for(invoiceit_s__Job_Rate_Plan_Charge__c jobRPC : mapOrderIdNLstOrderRPC.get(orderId)){
                if(jobRPC.invoiceit_s__Service_End_Date__c!=endDate){
                    setErrorOrderIds.add(jobRPC.invoiceit_s__Order__c);
                }
            }
        }
        system.debug('setErrorOrderIds::::'+setErrorOrderIds);
        //to exclude orders which have opportunities in 'QA Review' or 'Closed Won' or 'QA Rejected' Stage
        for(Opportunity opp : [Select Id,Created_From_Order__c from Opportunity where Created_From_Order__c in :mapOrderIdNLstOrderRPC.keyset() and (StageName = 'QA Review' or StageName = 'Closed Won' or StageName = 'QA Rejected')]){
            setExcludeOrderIds.add(opp.Created_From_Order__c);
        }
        system.debug('setExcludeOrderIds::::'+setExcludeOrderIds);
        for(Id orderId : mapOrderIdNLstOrderRPC.keyset()){
            if(!setErrorOrderIds.contains(orderId) && !setExcludeOrderIds.contains(orderId)){
                setCorrectOrderIds.add(orderId);
            }
        }
        system.debug('setCorrectOrderIds::::'+setCorrectOrderIds);
        Savepoint sp =  Database.setSavepoint();
        try{
            for(invoiceit_s__Job__c order : scope){
                if(setCorrectOrderIds.contains(order.Id)){
                    Opportunity opportunity;                
                    if(noOfTerms != null) {
                        noOfTerms = null;
                    }
                    JobClass jobClass = ControllerSelectQuoteType.populateJobClass(order);
                    opportunity = createEvergreenOrder(jobClass, 'Renew',order.Id);                 
                }
            }
            for(Case c : [Select Id,Status,Resolution__c from Case where Parent_Order__c in :setCorrectOrderIds and Area__c = 'Opportunity' and Sub_Area__c = 'Renewal' and Subject like 'Subscription Renewal for%' and RecordType.DeveloperName= 'MDL_Oppty_Renew' and Status != 'Closed']){
                c.Status = 'Closed';
                c.Resolution__c = 'Auto Evergreen';
                lstCasesToUpdate.add(c);
            }
            system.debug('lstCasesToUpdate::'+lstCasesToUpdate);
            if(lstCasesToUpdate.size() > 0){
                Database.update(lstCasesToUpdate);
            }
        }catch(Exception e){
            system.debug('Exception occurred::::'+e);
            Database.rollback(sp);
            List<invoiceit_s__Job__c> lstOrdersToUpdate = new List<invoiceit_s__Job__c>();
            for(invoiceit_s__Job__c job : [Select Id,Automate_Evergreen_Failure_Reason__c from invoiceit_s__Job__c where Id in :setCorrectOrderIds]){
                job.Automate_Evergreen_Failure_Reason__c = e.getMessage();
                lstOrdersToUpdate.add(job);
            }
            if(lstOrdersToUpdate.size() > 0){
                Database.update(lstOrdersToUpdate);
            }
        }
        
        //MDL_BatchAutoEvergreenHandler.OppsClosedLostWhenOppIsClosedWon(scope);
        
    }
    
    
    public Opportunity createEvergreenOrder(JobClass jobClass, String quoteType,Id orderId) {
        Opportunity opportunity;
        OpportunityClass opportunityClass;
        OpportunityProductClass opportunityProductClass;
        OpportunityRatePlanClass opportunityRatePlanClass;
        OpportunityRatePlanChargeClass opportunityPlanChargeClass;
        Integer opportunityProductCounter = 0;
        Integer opportunityRatePlanCounter = 0;
        Integer opportunityRateplanChargeCounter = 0;
        String casedescription;
        
        set<id> setOppProdId = new set<id>();
        Set<Id> setOrderProducts = new Set<Id>();        
        Map<String,String> Map_SINName = new Map<String,String>();   
        Map<Integer, invoiceit_crmx__Opportunity_Product__c> mapOpportunityProducts = new Map<Integer, invoiceit_crmx__Opportunity_Product__c>();        
        Map<Id,invoiceit_crmx__Opportunity_Product__c> map_orderproductId_oppProd = new Map<Id,invoiceit_crmx__Opportunity_Product__c>(); 
        map<Integer,invoiceit_crmx__Opportunity_Rate_Plan__c> mapOppRatePlans = new map<Integer,invoiceit_crmx__Opportunity_Rate_Plan__c>();
        Map<Id,invoiceit_crmx__Opportunity_Rate_Plan__c> map_orderRP_oppRP = new Map<Id,invoiceit_crmx__Opportunity_Rate_Plan__c>(); 
        
        for(JobProductClass jp : jobClass.JobProducts) {
            for(JobRatePlanClass jrp : jp.jobRatePlans) {
                for(JobRatePlanChargeClass jrpc : jrp.JobRatePlanCharges) {
                    if(jrpc.jobrateplancharge.invoiceit_s__Status__c == 'Active' && (jrpc.jobrateplancharge.invoiceit_s__Price_Type__c=='Monthly'|| jrpc.jobrateplancharge.invoiceit_s__Price_Type__c=='Usage') && jrpc.jobrateplancharge.Renewable__c == true){
                        setOrderProducts.add(jp.jobProduct.Id);
                    }          
                }
            }
         }         
         system.debug('setOrderProducts::'+setOrderProducts);
         for(JobProductClass jp1 : jobClass.JobProducts){
            for(JobRatePlanClass jrp1 : jp1.jobRatePlans) {
                for(JobRatePlanChargeClass jrpc1 : jrp1.JobRatePlanCharges) {
                    if((jrpc1.jobrateplancharge.invoiceit_s__Price_Type__c == 'Monthly'|| jrpc1.jobrateplancharge.invoiceit_s__Price_Type__c == 'Usage') && jrpc1.jobrateplancharge.Renewable__c==true){
                        if(jrpc1.jobrateplancharge.Fulfilment_Start_Date__c==null){
                            Map_SINName.put(jrpc1.jobrateplancharge.SIN__c,jrpc1.jobrateplancharge.Name);                       
                        }
                    }
                }
            }           
         } 
         system.debug('Map_SINName:::'+Map_SINName);
         if(Map_SINName!=null && Map_SINName.size()>0){
            AssignmentRule AR;
            Database.DMLOptions dmlOpts;
            //Fetching the assignment rules on case
            for(AssignmentRule assignRule : [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1]){
                AR = assignRule;
            }
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            dmlOpts = new Database.DMLOptions();
            if(AR!=null)
                dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            Case unfulfilledcase = new Case();
            unfulfilledcase.AccountId = jobClass.job.invoiceit_s__Account__c;
            unfulfilledcase.Priority = 'High';
            unfulfilledcase.Subject = 'Unfulfilled Order Rate Plan Charge';
            unfulfilledcase.Description = 'SIN Numbers and Names of Order Rate Plan Charges are as follows : ';
            //if(queue!=null)
            //unfulfilledcase.OwnerId = queue.Id;
            casedescription='';
            for(String sin : Map_SINName.keyset()){
                casedescription += sin+'-'+Map_SINName.get(sin)+';';
            }
            unfulfilledcase.Description += casedescription;
            unfulfilledcase.setOptions(dmlOpts);
            insert unfulfilledcase;
         } 
          
        opportunity = new Opportunity();
        opportunityClass = new OpportunityClass();
        opportunityClass.opportunity = opportunity;
        opportunity.StageName = 'Value Proposition';
        opportunity.CloseDate = system.today();        
        opportunity.Name = 'Auto evergreen '+jobClass.job.Name;
        opportunity.AccountId = jobClass.job.invoiceit_s__Account__c;
        opportunity.invoiceit_crmx__CurrencyL__c = jobClass.job.invoiceit_s__CurrencyL__c;
        opportunity.invoiceit_crmx__Billing_Contact__c = jobClass.job.invoiceit_s__Billing_Contact__c;
        opportunity.invoiceit_crmx__Shipping_Contact__c = jobClass.job.invoiceit_s__Shipping_Contact__c;
        opportunity.invoiceit_crmx__Discount_Value__c = jobClass.job.invoiceit_s__Discount_Value__c;
        opportunity.invoiceit_crmx__Discount_Percent__c = jobClass.job.invoiceit_s__Discount_Percent__c;        
        opportunity.invoiceit_crmx__Sub_Total__c = jobClass.job.invoiceit_s__Sub_Total__c;
        opportunity.invoiceit_crmx__Total__c = jobClass.job.invoiceit_s__Total__c;
        opportunity.invoiceit_crmx__Number_Of_Terms__c = noOfTerms;             
        opportunity.Created_From_Order__c = jobClass.job.Id; 
        opportunity.Do_Not_Auto_Close_Won__c = true;
        opportunity.Auth_By_Contact__c = jobClass.job.Auth_By_Contact__c;
        opportunity.Marketing_Contact__c = jobClass.job.Marketing_Contact__c;
        opportunity.Purchase_Order_Number__c = jobClass.job.Purchase_Order_Number__c;
        //opportunity.ReferralAccount__c = jobClass.job.PartnerAccount__c; //for MHBS-3445
        opportunity.ReferralAccount__c = jobClass.job.PartnerAccountOrder__c;     
        insert opportunity; 
        system.debug('**** New Opportunity Created ******'+opportunity );    
        
        for(JobProductClass jobProductClass : jobClass.JobProducts) {
            if(setOrderProducts.contains(jobProductClass.jobproduct.Id)){
                invoiceit_crmx__Opportunity_Product__c opportunityProduct = new invoiceit_crmx__Opportunity_Product__c();
                opportunityProduct.invoiceit_crmx__Opportunity__c = opportunity.Id;
                opportunityProduct.Name = jobProductClass.jobproduct.Name;
                opportunityProduct.invoiceit_crmx__Product__c = jobProductClass.jobproduct.invoiceit_s__Product__c;
                opportunityProduct.invoiceit_crmx__SequenceNumber__c = jobProductClass.jobproduct.invoiceit_s__SequenceNumber__c;                
                opportunityProduct.invoiceit_crmx__Product_Code__c = jobProductClass.jobproduct.invoiceit_s__Product_Code__c; 
                opportunityProduct.invoiceit_crmx__Description__c = jobProductClass.jobproduct.invoiceit_s__Description__c; 
                opportunityProduct.invoiceit_crmx__Product_Family__c = jobProductClass.jobproduct.invoiceit_s__Product_Family__c; 
                opportunityProduct.Product_SIN__c = jobProductClass.jobproduct.Sin_Number__c ;
                opportunityProduct.invoiceit_crmx__Bundle_SequenceNumber__c = jobProductClass.jobproduct.invoiceit_s__Bundle_SequenceNumber__c;
                opportunityProduct.invoiceit_crmx__Product_Bundle__c =   jobProductClass.jobproduct.invoiceit_s__Product_Bundle__c;
                //code added by Lister to facilitate carrrying Inventory numbers from Order products to Oppty Products(though SIN number is pending)
                if(JobProductClass.jobproduct.Inventory_Id__c!=null) {
                    opportunityProduct.InventoryId__c = JobProductClass.jobproduct.Inventory_Id__c;
                }      
                opportunityProductClass = new OpportunityProductClass();
                opportunityProductClass.opportunityProductCounter = ++opportunityProductCounter;
                opportunityProductClass.opportunityProduct = opportunityProduct;
                opportunityClass.opportunityProducts.add(opportunityProductClass);
                mapOpportunityProducts.put(opportunityProductClass.opportunityProductCounter, opportunityProduct);
                map_orderproductId_oppProd.put(jobProductClass.jobproduct.Id,opportunityProduct);
                System.debug('check 4 '  +  map_orderproductId_oppProd);
            }
        }
                
        if(map_orderproductId_oppProd.size() > 0)
            upsert map_orderproductId_oppProd.values();
        
        System.debug('check 5 ' + map_orderproductId_oppProd );
        
        for(invoiceit_crmx__Opportunity_Product__c op : map_orderproductId_oppProd.values()) {
            setOppProdId.add(op.Id);
        } 
        List<invoiceit_crmx__Opportunity_Product__c>  listopProd = [select Id,invoiceit_crmx__Product_Code__c from invoiceit_crmx__Opportunity_Product__c where Id in :setOppProdId];
        for(invoiceit_crmx__Opportunity_Product__c c : listopProd){
            System.debug(c.invoiceit_crmx__Product_Code__c);
        }
        
        for(JobProductClass jp : jobClass.JobProducts) {
            if(setOrderProducts.contains(jp.jobproduct.Id)){
                 for(JobRatePlanClass jrp : jp.jobRatePlans) {
                        invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c();
                        if(map_orderproductId_oppProd.containsKey(jp.JobProduct.Id))
                            oppRatePlan.invoiceit_crmx__Opportunity_Product__c = map_orderproductId_oppProd.get(jp.JobProduct.Id).Id;
                        oppRatePlan.Name = jrp.jobRatePlan.Name;
                        oppRatePlan.invoiceit_crmx__Description__c = jrp.jobRatePlan.invoiceit_s__Description__c;
                        oppRatePlan.invoiceit_crmx__Product_Rate_Plan__c = jrp.jobRatePlan.invoiceit_s__Product_Rate_Plan__c;
                        oppRatePlan.invoiceit_crmx__SequenceNumber__c = jrp.jobRatePlan.invoiceit_s__SequenceNumber__c;
                        
                        //dynamic field mapping ends here
                        opportunityRatePlanClass = new OpportunityRatePlanClass();
                        opportunityRatePlanClass.opportunityRatePlanCounter = ++OpportunityRatePlanCounter;
                        opportunityRatePlanClass.opportunityrateplan = oppRatePlan;
                        opportunityProductClass.opportunityRatePlans.add(opportunityRatePlanClass);
                        mapOppRatePlans.put(opportunityRatePlanClass.opportunityRatePlanCounter, oppRatePlan);
                        map_orderRP_oppRP.put(jrp.jobRatePlan.Id , oppRatePlan);
                }       
            }
        }
        if(map_orderRP_oppRP.size()>0)
            upsert map_orderRP_oppRP.values();
            
        map<Integer,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> mapOppRatePlanCharges = new map<Integer,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> map_orderRPCId_OppRPC = new map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        Set<invoiceit_crmx__Opportunity_Product__c> setOppProductsToBeUpdates = new Set<invoiceit_crmx__Opportunity_Product__c>();
        List<invoiceit_crmx__Opportunity_Product__c> lstOppProductsToBeUpdates = new List<invoiceit_crmx__Opportunity_Product__c>();
        
        for(JobProductClass jp : jobClass.JobProducts) {
            if(setOrderProducts.contains(jp.jobproduct.Id)){
                for(JobRatePlanClass jrp : jp.jobRatePlans) {        
                    Id oppRatePlanId = map_orderRP_oppRP.get(jrp.jobRatePlan.Id).Id;
                    for(JobRatePlanChargeClass jrpc : jrp.JobRatePlanCharges) {
                        if(jrpc.jobrateplancharge.Renewable__c){
                            //adding one condition to check service end date of charge is null or not.
                            invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c();
                            oppRatePlanCharge.invoiceit_crmx__Opportunity_Rate_Plan__c = oppRatePlanId;
                            oppRatePlanCharge.Name = jrpc.jobrateplancharge.Name;
                            oppRatePlanCharge.invoiceit_crmx__Discount_Value__c = jrpc.jobrateplancharge.invoiceit_s__Discount_Value__c;
                            System.debug('Charge Disc Value &&&'+jrpc.jobrateplancharge.invoiceit_s__Discount_Value__c);
                            oppRatePlanCharge.invoiceit_crmx__Price_Format__c = jrpc.jobrateplancharge.invoiceit_s__Price_Format__c;
                            oppRatePlanCharge.invoiceit_crmx__Profit__c = jrpc.jobrateplancharge.invoiceit_s__Profit__c;
                            oppRatePlanCharge.invoiceit_crmx__Sequence_No__c = jrpc.jobrateplancharge.invoiceit_s__Sequence_No__c;
                            oppRatePlanCharge.invoiceit_crmx__Unit_Of_Measurement__c = jrpc.jobrateplancharge.invoiceit_s__Unit_Of_Measurement__c;
                            oppRatePlanCharge.invoiceit_crmx__Price__c = jrpc.jobrateplancharge.invoiceit_s__Price__c;
                            oppRatePlanCharge.invoiceit_crmx__Unit_Price__c = jrpc.jobrateplancharge.invoiceit_s__Unit_Price__c;
                            oppRatePlanCharge.invoiceit_crmx__Price_Type__c = jrpc.jobrateplancharge.invoiceit_s__Price_Type__c;
                            oppRatePlanCharge.invoiceit_crmx__CurrencyL__c = jrpc.jobrateplancharge.invoiceit_s__CurrencyL__c;
                            oppRatePlanCharge.invoiceit_crmx__Quantity__c = jrpc.jobrateplancharge.invoiceit_s__Quantity__c;
                            oppRatePlanCharge.invoiceit_crmx__Sequence_No__c = jrpc.jobrateplancharge.invoiceit_s__Sequence_No__c;                                   
                            oppRatePlanCharge.invoiceit_crmx__Tax__c = jrpc.jobrateplancharge.invoiceit_s__Tax__c;
                            oppRatePlanCharge.invoiceit_crmx__Vat__c = jrpc.jobrateplancharge.invoiceit_s__Vat__c;                                  
                            oppRatePlanCharge.invoiceit_crmx__Cost__c = jrpc.jobrateplancharge.invoiceit_s__Cost__c;
                            oppRatePlanCharge.invoiceit_crmx__Cost_Price__c = jrpc.jobrateplancharge.invoiceit_s__Cost_Price__c;
                            oppRatePlanCharge.invoiceit_crmx__Is_Product_Editable__c = jrpc.jobrateplancharge.invoiceit_s__Is_Product_Editable__c;
                            oppRatePlanCharge.invoiceit_crmx__Product_Rate_Plan_Charge__c = jrpc.jobrateplancharge.invoiceit_s__Product_Rate_Plan_Charge__c;
                            oppRatePlanCharge.invoiceit_crmx__Product_Charge_Category__c = jrpc.jobrateplancharge.invoiceit_s__Product_Charge_Category__c;
                            oppRatePlanCharge.invoiceit_crmx__VAT_Percentage__c = jrpc.jobrateplancharge.invoiceit_s__VAT_Percentage__c;
                            oppRatePlanCharge.invoiceit_crmx__Tax_Percentage__c = jrpc.jobrateplancharge.invoiceit_s__Tax_Percentage__c;
                            oppRatePlanCharge.invoiceit_crmx__Net_Total__c =  jrpc.jobrateplancharge.invoiceit_s__Net_Total__c;
                            oppRatePlanCharge.invoiceit_crmx__Discount_percent__c = jrpc.jobrateplancharge.invoiceit_s__Discount_percent__c;
                            System.debug('Charge Disc Percent ****'+jrpc.jobrateplancharge.invoiceit_s__Discount_percent__c);
                            oppRatePlanCharge.invoiceit_crmx__VAT_Percentage__c =  jrpc.jobrateplancharge.invoiceit_s__VAT_Percentage__c;
                            oppRatePlanCharge.invoiceit_crmx__Tax_Percentage__c =  jrpc.jobrateplancharge.invoiceit_s__Tax_Percentage__c;
                            oppRatePlanCharge.invoiceit_crmx__Accounting_Code__c = jrpc.jobrateplancharge.invoiceit_s__Accounting_Code__c;
                            oppRatePlanCharge.invoiceit_crmx__Percentage_of_other_Charges__c = jrpc.jobrateplancharge.invoiceit_s__Percentage_of_other_Charges__c;
                            oppRatePlanCharge.Live_Date__c=  jrpc.jobrateplancharge.Live_Date__c;
                            oppRatePlanCharge.invoiceit_crmx__Product_Bundle_Line__c = jrpc.jobrateplancharge.invoiceit_s__Product_Bundle_Line__c;
                            //code added by Lister to facilitate carrrying SIN numbers from Order products to Oppty Products
                            if((jrpc.jobrateplancharge.invoiceit_s__Price_Type__c != 'One Time') && 
                                !(jrpc.jobrateplancharge.invoiceit_s__Price_Type__c == 'Monthly' && jrpc.jobrateplancharge.Shippable__c == 'Yes')) {
                                oppRatePlanCharge.SIN__c = jrpc.jobrateplancharge.SIN__c;
                                
                            }   
                            if(jrpc.jobrateplancharge.invoiceit_s__Price_Type__c == 'One Time' || (jrpc.jobrateplancharge.invoiceit_s__Price_Type__c == 'Monthly' && jrpc.jobrateplancharge.Shippable__c == 'Yes')) {
                                if(map_orderproductId_oppProd.containsKey(jp.jobproduct.Id)) {
                                    map_orderproductId_oppProd.get(jp.jobproduct.Id).Product_SIN__c = null;
                                    setOppProductsToBeUpdates.add(map_orderproductId_oppProd.get(jp.jobproduct.Id));
                                }
                            }
                            oppRatePlanCharge.Created_From_Charge__c = jrpc.jobrateplancharge.Id;
                            oppRatePlanCharge.Quote_Type__c = quoteType;
                            
                            OpportunityRatePlanChargeClass oppRatePlanChargeClass = new OpportunityRatePlanChargeClass();
                            oppRatePlanChargeClass.opportunityRatePlanChargeCounter = ++opportunityRateplanChargeCounter;
                            oppRatePlanChargeClass.opportunityRatePlanCharge = oppRatePlanCharge;
                            opportunityRatePlanClass.opportunityRatePlanCharges.add(oppRatePlanChargeClass);
                            mapOppRatePlanCharges.put(jrpc.JobRatePlanChargeCounter, oppRatePlanCharge);
                            map_orderRPCId_OppRPC.put(jrpc.jobrateplancharge.Id, oppRatePlanCharge);    
                        }
                    }    
                }
            }
        }
        if(map_orderRPCId_OppRPC.size() > 0)
            upsert map_orderRPCId_OppRPC.values();
            
        if(setOppProductsToBeUpdates.size() > 0) { 
            lstOppProductsToBeUpdates.addAll(setOppProductsToBeUpdates);
            System.debug('lst of Product SIN to be removed::'+lstOppProductsToBeUpdates);
            update lstOppProductsToBeUpdates;    
        }
         System.debug('####map Oppty Charges###'+map_orderRPCId_OppRPC.values());
        
        // we need to populate the opportunity charge attributes
        map<Id, list<Order_Charge_Attribute__c>> map_JobChargeId_OrderAttributes = new map<Id, list<Order_Charge_Attribute__c>>();
        list<Order_Charge_Attribute__c> jobAttributes = new list<Order_Charge_Attribute__c>();
        jobAttributes = [SELECT Name, Attribute_Name__c, Boolean_Value__c,Maximum_No_Of_Characters_In_Text__c,Minimum_No_Of_Characters_In_Text__c, Date_Value__c, Number_Value__c, String_Value__c, Attribute_Type__c,
                                                         Attribute_Order__c,Order_Rate_Plan_Charge__r.Shippable__c,
                                                         Attribute_Picklist_Values__c,
                                                         Picklist_Value__c,
                                                         Phone_Value__c,
                                                         Order_Rate_Plan_Charge__c, Show_in_Docusign__c,
                                                         Value_ID__c
                                                         FROM Order_Charge_Attribute__c
                                                         WHERE Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c =: orderId
                                                         AND Order_Rate_Plan_Charge__c in: map_orderRPCId_OppRPC.keyset()
                                                         ORDER BY Attribute_Order__c];
        
        list<Order_Charge_Attribute__c> jobAttributesLocalVar;
        for(Order_Charge_Attribute__c jobAttribute : jobAttributes) {
            if(map_JobChargeId_OrderAttributes.containsKey(jobAttribute.Order_Rate_Plan_Charge__c)) {
                jobAttributesLocalVar = map_JobChargeId_OrderAttributes.get(jobAttribute.Order_Rate_Plan_Charge__c);
            } else {
                jobAttributesLocalVar = new list<Order_Charge_Attribute__c>();
            }

            jobAttributesLocalVar.add(jobAttribute);
            map_JobChargeId_OrderAttributes.put(jobAttribute.Order_Rate_Plan_Charge__c, jobAttributesLocalVar);
        }   
        system.debug('map_JobChargeId_OrderAttributes::'+map_JobChargeId_OrderAttributes);
        // we need to insert the tiers and atrributes here
        //list<invoiceit_crmx__Opportunity_Rate_Plan_Charge_Tier__c> opportunityTiers = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge_Tier__c>();
        list<Opportunity_Charge_Attribute__c> opportunityAttributes = new list<Opportunity_Charge_Attribute__c>();
        //invoiceit_crmx__Opportunity_Rate_Plan_Charge_Tier__c opportunityTier;
        Opportunity_Charge_Attribute__c opportunityAttribute;

        for(JobProductClass jp : jobClass.JobProducts) {
            if(setOrderProducts.contains(jp.jobproduct.Id)){
                for(JobRatePlanClass jrp : jp.jobRatePlans) {
                    for(JobRatePlanChargeClass jrpc : jrp.JobRatePlanCharges) {
                        //invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppCharge = mapOppRatePlanCharges.get(jrpc.JobRatePlanChargeCounter);
                        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppCharge = map_orderRPCId_OppRPC.get(jrpc.JobRatePlanCharge.Id);
                        // pull the tiers and create the opportunity tiers
                        // pull the attributes and create the opportunity attributes
                        if(map_JobChargeId_OrderAttributes.containsKey(jrpc.jobrateplancharge.Id)) {
                            for(Order_Charge_Attribute__c orderAttribute : map_JobChargeId_OrderAttributes.get(jrpc.jobrateplancharge.Id)) {                                
                                        opportunityAttribute = new Opportunity_Charge_Attribute__c();
                                        opportunityAttribute.Attribute_Type__c = orderAttribute.Attribute_Type__c;
                                        opportunityAttribute.Attribute_Name__c = orderAttribute.Attribute_Name__c;
                                        if(!(orderAttribute.Attribute_Name__c == 'Edition' && orderAttribute.Order_Rate_Plan_Charge__r.Shippable__c == 'Yes')){
                                            opportunityAttribute.Picklist_Value__c = orderAttribute.Picklist_Value__c;
                                            opportunityAttribute.String_Value__c = orderAttribute.String_Value__c;
                                            opportunityAttribute.Boolean_Value__c = orderAttribute.Boolean_Value__c;
                                            opportunityAttribute.Number_Value__c = orderAttribute.Number_Value__c;
                                            opportunityAttribute.Date_Value__c = orderAttribute.Date_Value__c;
                                            opportunityAttribute.Phone_Value__c= orderAttribute.Phone_Value__c;
                                            opportunityAttribute.Show_in_Docusign__c = orderAttribute.Show_in_Docusign__c;
                                        } 
                                        else if(orderAttribute.Attribute_Name__c == 'Edition' && orderAttribute.Order_Rate_Plan_Charge__r.Shippable__c == 'Yes'){
                                            if(orderAttribute.Picklist_Value__c!=null && orderAttribute.Picklist_Value__c!=''){
                                                opportunityAttribute.Picklist_Value__c = String.valueOf(Integer.valueOf(orderAttribute.Picklist_Value__c)+1);
                                            }
                                            if(orderAttribute.String_Value__c!=null && orderAttribute.String_Value__c!=''){
                                                opportunityAttribute.String_Value__c = String.valueOf(Integer.valueOf(orderAttribute.String_Value__c)+1);
                                            }
                                            if(orderAttribute.Number_Value__c!=null){
                                                opportunityAttribute.Number_Value__c = orderAttribute.Number_Value__c+1.0;
                                            }
                                        }         
                                        opportunityAttribute.Attribute_Order__c = orderAttribute.Attribute_Order__c;
                                        opportunityAttribute.Attribute_Picklist_Values__c = orderAttribute.Attribute_Picklist_Values__c;
                                        opportunityAttribute.Opportunity_Rate_Plan_Charge__c = oppCharge.Id;
                                        opportunityAttribute.Maximum_No_Of_Characters_In_Text__c = orderAttribute.Maximum_No_Of_Characters_In_Text__c;
                                        opportunityAttribute.Minimum_No_Of_Characters_In_Text__c = orderAttribute.Minimum_No_Of_Characters_In_Text__c;
                                        if(orderAttribute.Value_ID__c != null){
                                            opportunityAttribute.Value_ID__c = orderAttribute.Value_ID__c;
                                        }
                                        opportunityAttributes.add(opportunityAttribute);
                                }
                            
                        }
                    }
                }
            }
        }      

        if(opportunityAttributes.size() > 0) {
            insert opportunityAttributes;   
        }
        system.debug('opportunityAttributes::'+opportunityAttributes);
        
        //calling chat opty charge creation method : added by sai: 11/13/2016
         genericUtilityClass.insertIntoOppChat(opportunity, orderid);
        
        
        if(opportunity.invoiceit_crmx__Discount_Percent__c >= 0.20){
            opportunity.Discoint_Approved__c = 'Discount Approved';
        }
        opportunity.Quote_Type__c = 'Renew';
        opportunity.StageName = 'Closed Won';
        opportunity.Reason_Won_Lost__c = 'Auto Evergreen';  
        opportunity.invoiceit_crmx__Recalculate__c = true;
        opportunity.invoiceit_crmx__Create_Order__c = true;
        opportunity.Do_Not_Auto_Close_Won__c = true;
        update opportunity;
        mapOrderIdToOpp.put(jobClass.job.Id,opportunity);
        //System.debug('mapOrderIdToOpp===>'+mapOrderIdToOpp);
        system.debug('final opp:'+opportunity);
        
        //Added for populating Chat Parent Order Rate Plan Charge for Opp Product
        List<invoiceit_s__Job_Rate_Plan_Charge__c> rpcOrderList = [Select Id,invoiceit_s__Order__c,RecordType.DeveloperName,
        SIN__c,Chat_Parent_Order_Rate_Plan_Charge__c,Chat_Parent_Order_Rate_Plan_Charge__r.SIN__c 
        From invoiceit_s__Job_Rate_Plan_Charge__c 
        Where invoiceit_s__Order__c=:jobClass.job.Id
        AND RecordType.DeveloperName =: 'M_NG_Order_Rate_Plan_Charge'
        AND Chat_Parent_Order_Rate_Plan_Charge__c!=null];
        
        System.debug('rpcOrderList ===>' +rpcOrderList);
        
        if(rpcOrderList!=null && !rpcOrderList.isEmpty()){
            System.debug('In first If===>');
            Map<String,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> mapSinTOoppRPCID = new Map<String,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
            List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> rpcOppList = [Select Id,invoiceit_crmx__Opportunity__c,RecordType.DeveloperName,
            SIN__c,Chat_Parent_Opportunity_Rate_Plan_Charge__c 
            From invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
            Where invoiceit_crmx__Opportunity__c=:opportunity.id];
            if(rpcOppList!=null && !rpcOppList.isEmpty()){
                for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRPC:rpcOppList){
                    mapSinTOoppRPCID.put(oppRPC.SIN__c,oppRPC);
                }
                
                for(invoiceit_s__Job_Rate_Plan_Charge__c orderRPC:rpcOrderList){
                    if(mapSinTOoppRPCID.containsKey(orderRPC.SIN__c) && 
                    mapSinTOoppRPCID.get(orderRPC.Chat_Parent_Order_Rate_Plan_Charge__r.SIN__c)!=null){
                        mapSinTOoppRPCID.get(orderRPC.SIN__c).Chat_Parent_Opportunity_Rate_Plan_Charge__c = mapSinTOoppRPCID.get(orderRPC.Chat_Parent_Order_Rate_Plan_Charge__r.SIN__c).id;
                    }
                }
                update mapSinTOoppRPCID.values();
            }
        }
        
        return opportunity;
    }
    public static String getObjectFields(String objectName) {
        String sQuery = '';
        Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for(Schema.SObjectField column: objectFieldMap.values()) {
            //system.debug('column Name is ' + column + 'column permission' + column.getDescribe().isUpdateable());
            sQuery += column+', ';
        }
        sQuery = sQuery.substring(0, sQuery.length()-2);
        sQuery += ' ';
        return sQuery;
    }
    global void finish(Database.BatchableContext BC) {
        
        Boolean dontExecute = false;
        for(AsyncApexJob batch :[Select ExtendedStatus,NumberOfErrors,Status,JobItemsProcessed,TotalJobItems from AsyncApexJob where Id = :BC.getJobId()]){         
            if(batch.TotalJobItems==batch.NumberOfErrors){
                dontExecute = true;
            }
        }
        if(dontExecute==false){
            //System.debug('mapOrderIdToOpp===>'+mapOrderIdToOpp);
            List<invoiceit_s__Job__c> orderList = [Select Id,RecordType.DeveloperName,Created_From_Order__c,Parent_Order__c
                                      From invoiceit_s__Job__c Where Id IN:mapOrderIdToOpp.keySet()];
           
            List<Opportunity> oppListToUpdate = new List<Opportunity>();
            //System.debug('=orderList==>'+orderList );
            for(invoiceit_s__Job__c order:orderList){
                if(order.RecordType.DeveloperName == 'M_NG_Order'
                 && mapOrderIdToOpp.containsKey(order.id) 
                 && (mapOrderIdToOpp.containsKey(order.Created_From_Order__c)||mapOrderIdToOpp.containsKey(order.Parent_Order__c))){
                    System.debug('Inside If===>');
                    if(mapOrderIdToOpp.containsKey(order.Created_From_Order__c)){
                        mapOrderIdToOpp.get(order.id).Parent_Opportunity__c = mapOrderIdToOpp.get(order.Created_From_Order__c).id;
                    }
                    else{
                        mapOrderIdToOpp.get(order.id).Parent_Opportunity__c = mapOrderIdToOpp.get(order.Parent_Order__c).id;
                    }
                    oppListToUpdate.add(mapOrderIdToOpp.get(order.id));
                }
            }
            //System.debug('oppListToUpdate===>'+oppListToUpdate);
            if(!oppListToUpdate.isEmpty()){
                update oppListToUpdate;
            }
            Map<Id,Id> mapOppToOrderId = new Map<Id,Id>();
            List<invoiceit_s__Job__c> orderFrmParentOppList = [Select Id,invoiceit_crmx__Opportunity__c,Parent_Order__c,RecordType.DeveloperName,
                                      invoiceit_crmx__Opportunity__r.Name,invoiceit_crmx__Opportunity__r.Parent_Opportunity__c
                                      From invoiceit_s__Job__c Where invoiceit_crmx__Opportunity__c IN: mapOrderIdToOpp.values() 
                                      ];
            //System.debug('orderFrmParentOppList--->'+orderFrmParentOppList);                          
            if(orderFrmParentOppList!=null && !orderFrmParentOppList.isEmpty()){
                for(invoiceit_s__Job__c order:orderFrmParentOppList){
                    if(order.RecordType.DeveloperName =='Nolo_Order')
                        mapOppToOrderId.put(order.invoiceit_crmx__Opportunity__c,order.id);
                }
                //System.debug('mapOppToOrderId--->'+mapOppToOrderId);   
                for(invoiceit_s__Job__c order:orderFrmParentOppList){
                    if(order.RecordType.DeveloperName =='M_NG_Order'){
                        order.Parent_Order__c = mapOppToOrderId.get(order.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c);
                    }
                    //System.debug('order.Parent_Order__c--->'+order.Parent_Order__c); 
                }
                update orderFrmParentOppList;
            }
            MDL_BatchAutomateEvergreenoppClosedLost b  = new MDL_BatchAutomateEvergreenoppClosedLost(orderIdstoBatch);
            //MDL_BatchSendXMLAutomateEvergreenProcess b = new MDL_BatchSendXMLAutomateEvergreenProcess(Date.Today());
            Database.executeBatch(b,1);
            
            
        }
    }
}
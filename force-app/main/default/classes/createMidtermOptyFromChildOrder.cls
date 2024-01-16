public class createMidtermOptyFromChildOrder {

    public static opportunity opportunity;
    public static List<invoiceit_crmx__Opportunity_Product__c> OppProductsFromOrder;
    public static List<invoiceit_crmx__Opportunity_Rate_Plan__c> oppProdRatePlansFromOrder;
    public static List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> oppProdRatePlanChargeFromOrder;
    public static list<Opportunity_Charge_Attribute__c> opportunityAttributesFromOrder;
    public static set<id> set_RenewableJobProductId = new set<id>();
     //set of one time & monthly shippable products for rebase to not carry them over
    public static set<id> setRebasedOneTimeAndShippableProductIds = new Set<Id>();
     public static Map<Id,invoiceit_crmx__Opportunity_Product__c> map_orderproductId_oppProd = new Map<Id,invoiceit_crmx__Opportunity_Product__c>(); 
    public static JobClass jobClass;
    public static  Map<Id,invoiceit_crmx__Opportunity_Rate_Plan__c> map_orderRP_oppRP = new Map<Id,invoiceit_crmx__Opportunity_Rate_Plan__c>();
    public static  map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> map_orderRPCId_OrderRPC = new map<Id,invoiceit_s__Job_Rate_Plan_Charge__c>();
     public static  map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> map_orderRPCId_oppRPCharge = new map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
    public static string optyId;
    
    public static void createchildoptyfromorder(string quoteType, string ordId){
        
       opportunityAttributesFromOrder = new list<Opportunity_Charge_Attribute__c>();
        OpportunityClass opportunityClass;
        OpportunityProductClass opportunityProductClass;
        OpportunityRatePlanClass opportunityRatePlanClass;
        OpportunityRatePlanChargeClass opportunityPlanChargeClass;
        Integer opportunityProductCounter = 0;
        Integer opportunityRatePlanCounter = 0;
        Integer opportunityRateplanChargeCounter = 0;
        String casedescription;
        
        
        set<id> set_RenewableJobRatePlanId = new set<id>();
        set<id> set_RenewableJobRatePlanChargeId = new set<id>();
        set<id> setCancelledOrderProductsId = new Set<id>();
        set<id> setOppProdId = new set<id>();
        
        Map<String,String> Map_SINName = new Map<String,String>();
        
       
        
        Map<Id,String> map_ChargeId_Pricetype = new Map<Id,String>();
        Map<Id,String> map_ChargeId_Shippable = new Map<Id,String>();
        
    
        for(JobProductClass jp : jobClass.JobProducts) {
            for(JobRatePlanClass jrp : jp.jobRatePlans) {
                for(JobRatePlanChargeClass jrpc : jrp.JobRatePlanCharges) {
                    //map_JobProductId_RenewableCharges.add(jp.Id , jrpc)   ;
                    if((quoteType == 'Modify' || quoteType == 'Mid-Term') && (jrpc.jobrateplancharge.invoiceit_s__Price_Type__c == 'One Time' && (jrpc.jobrateplancharge.invoiceit_s__Status__c != 'Active' && jrpc.jobrateplancharge.invoiceit_s__Service_End_Date__c != null))) {
                        setRebasedOneTimeAndShippableProductIds.add(jp.jobProduct.Id);
                    }
/*                    if(quoteType == 'Mid-Term' && (jrpc.jobrateplancharge.invoiceit_s__Price_Type__c == 'One Time' ) && jrpc.jobrateplancharge.Fulfilment_End_Date__c != null && jrpc.jobrateplancharge.Shippable__c=='Yes') {
                         setRebasedOneTimeAndShippableProductIds.add(jp.jobProduct.Id);                       
                    }
*/
                   if(quoteType == 'Mid-Term' && (jrpc.jobrateplancharge.invoiceit_s__Price_Type__c == 'One Time' && jrpc.jobrateplancharge.Shippable__c!='Yes')) {
                         setRebasedOneTimeAndShippableProductIds.add(jp.jobProduct.Id);                       
                    }

                    if(jrpc.JobRatePlanCharge.Renewable__c || quoteType == 'Modify' || quoteType == 'Mid-Term') {

                        System.debug(jp.jobProduct.Id);
                        set_RenewableJobProductId.add(jp.jobProduct.Id);                    
                        map_ChargeId_Shippable.put(jrpc.JobRatePlanCharge.Id,jrpc.JobRatePlanCharge.Shippable__c);  
                        map_ChargeId_Pricetype.put(jrpc.JobRatePlanCharge.Id,jrpc.JobRatePlanCharge.invoiceit_s__Price_Type__c);
                    }
                    if((jrpc.JobRatePlanCharge.invoiceit_s__Status__c == 'Cancelled')||(jrpc.JobRatePlanCharge.invoiceit_s__Status__c == 'Expired')) {
                        //RBW-980 - Fulfilled & Expired One time shippable product need to carry forward to Renewal scenario's 
                        if(!((quoteType == 'Renew') && (jrpc.JobRatePlanCharge.invoiceit_s__Status__c == 'Expired') && (jrpc.jobrateplancharge.invoiceit_s__Price_Type__c == 'One Time' && jrpc.jobrateplancharge.Shippable__c=='Yes') &&(jrpc.jobrateplancharge.Fulfilment_Start_Date__c!=null))){
                            setCancelledOrderProductsId.add(jp.jobProduct.Id);
                        }
                    }           
                }
            }
         } 
         
         System.debug(' check1 ' + setRebasedOneTimeAndShippableProductIds);
         System.debug(' check2 ' + set_RenewableJobProductId);
         System.debug(' check3 ' + setCancelledOrderProductsId);
        
        
         
        opportunity = new Opportunity();
        opportunityClass = new OpportunityClass();
        opportunityClass.opportunity = opportunity;
        opportunity.StageName = 'Value Proposition';
        opportunity.CloseDate = system.today().addDays(30); 
        opportunity.Renew_Check_Flag__c = True;      
        opportunity.Name = 'Ngage Upsell';
        opportunity.AccountId = jobClass.job.invoiceit_s__Account__c;
        opportunity.invoiceit_crmx__CurrencyL__c = jobClass.job.invoiceit_s__CurrencyL__c;
        //opportunity.invoiceit_crmx__Billing_Contact__c = jobClass.job.invoiceit_s__Billing_Contact__c;Commented for MHBS3345
        //opportunity.invoiceit_crmx__Shipping_Contact__c = jobClass.job.invoiceit_s__Shipping_Contact__c;Commented for MHBS3345
        //opportunity.invoiceit_crmx__Discount_Value__c = jobClass.job.invoiceit_s__Discount_Value__c;
        //opportunity.invoiceit_crmx__Discount_Percent__c = jobClass.job.invoiceit_s__Discount_Percent__c;
        System.debug('Discount Percent%%'+jobClass.job.invoiceit_s__Discount_Percent__c);
        System.debug('Discount Value^^'+jobClass.job.invoiceit_s__Discount_Value__c);
        opportunity.invoiceit_crmx__Sub_Total__c = jobClass.job.invoiceit_s__Sub_Total__c;
        opportunity.invoiceit_crmx__Total__c = jobClass.job.invoiceit_s__Total__c;
      
        opportunity.invoiceit_crmx__Number_Of_Terms__c = 12;             
        opportunity.Created_From_Order__c = jobClass.job.Id;
        opportunity.Locations__c = jobClass.job.Locations__c;
        opportunity.Practice_Areas__c = jobClass.job.Practice_Areas__c;
        //opportunity.ReferralAccount__c = jobClass.job.PartnerAccount__c;
        opportunity.ReferralAccount__c = jobClass.job.PartnerAccountOrder__c;
        // Added by Ronak
        //opportunity.Parent_Order__c = jobClass.job.Parent_Order__c;
        
        //added by saiv MHBS-3345
        if(opportunity.Name.contains('Auto Evergreen')){
            opportunity.invoiceit_crmx__Billing_Contact__c = jobClass.job.invoiceit_s__Billing_Contact__c;
            opportunity.invoiceit_crmx__Shipping_Contact__c = jobClass.job.invoiceit_s__Shipping_Contact__c;
            opportunity.Auth_By_Contact__c = jobClass.job.Auth_By_Contact__c;
            opportunity.Marketing_Contact__c = jobClass.job.Marketing_Contact__c;
        }

        System.debug('Previous Order Status===='+jobClass.job.invoiceit_s__Status__c);
        System.debug('Order Record Type====='+jobClass.job.RecordType.DeveloperName);
        if(jobClass.job.RecordType.DeveloperName == 'M_N_Order' || ( jobClass.job.invoiceit_s__Status__c == 'Evergreen' && (jobClass.job.RecordType.DeveloperName == 'MH_Orders' || jobClass.job.RecordType.DeveloperName == 'Nolo_Order'))){
            opportunity.Quote_Type__c = 'Modify';
        }
        else{
        opportunity.Quote_Type__c = quoteType;
        }
        if ( quoteType == 'Mid-Term')
            opportunity.Quote_Type__c = 'Modify';

        //opportunity.Auth_By_Contact__c = jobClass.job.Auth_By_Contact__c;Commented for MHBS3345
        opportunity.Purchase_Order_Number__c = jobClass.job.Purchase_Order_Number__c;
         opportunity.Ngage_Upsell_Order__c =ordId;
        
        
          System.debug('Oppty discount values are ####'+opportunity.invoiceit_crmx__Discount_Percent__c+'discount value$$$'+opportunity.invoiceit_crmx__Discount_Value__c);
        
        Map<Integer, invoiceit_crmx__Opportunity_Product__c> mapOpportunityProducts = new Map<Integer, invoiceit_crmx__Opportunity_Product__c>();
        
       
        
        //Added for rebasing Ngage only order for adding additional chats and feature products --- Ronak
        
        Map<Id,String> map_orderproductId_oppProdId = new Map<Id,String>(); 

        Map<Id, String> map_opptyProdId_CreatedFromOrdProd = new Map<Id, String>();
        
        for(JobProductClass jobProductClass : jobClass.JobProducts) {
            if(set_RenewableJobProductId.contains(jobProductClass.jobproduct.Id) && (!setRebasedOneTimeAndShippableProductIds.contains(jobProductClass.jobproduct.Id)) && (!setCancelledOrderProductsId.contains(jobProductClass.jobproduct.Id))){
                invoiceit_crmx__Opportunity_Product__c opportunityProduct = new invoiceit_crmx__Opportunity_Product__c();
                opportunityProduct.invoiceit_crmx__Opportunity__c = optyId;
                opportunityProduct.Name = jobProductClass.jobproduct.Name;
                opportunityProduct.Is_Chat_Option_Shown__c = null;
                opportunityProduct.invoiceit_crmx__Product__c = jobProductClass.jobproduct.invoiceit_s__Product__c;
                opportunityProduct.invoiceit_crmx__SequenceNumber__c = jobProductClass.jobproduct.invoiceit_s__SequenceNumber__c;                
                System.debug(jobProductClass.jobproduct.invoiceit_s__Product_Code__c);
                opportunityProduct.invoiceit_crmx__Product_Code__c = jobProductClass.jobproduct.invoiceit_s__Product_Code__c; 
                //Ronak added
                opportunityProduct.Created_From_Order_Product__c     = jobProductClass.jobproduct.id;
                opportunityProduct.IsAddOnFeature__c = jobProductClass.jobproduct.IsAddOnFeature__c;
                opportunityProduct.MidTerm__c = True;
               // opportunityProduct.Created_From_Opportunity_Product__c = map_orderproductId_oppProd.get(map_opptyProdId_CreatedFromOrdProd.get(OpportunityProduct.Id));
                
                //opportunityProduct.Created_From_Opportunity_Product__c = jobProductClass.jobproduct.id; 
                
                
                boolean bundlsequenceflag = false;
                for(JobRatePlanClass jrp : jobProductClass.getJobRatePlans()){
                    //if(jrp.jobrateplan.name.contains('package') ){
                        for(JobRatePlanChargeClass jrpc: jrp.getJobRatePlanCharges()){
                            if(jrpc.jobrateplancharge.Package_Wrapper__c ==true || jrpc.jobrateplancharge.Package_Component__c ==true){
                                opportunityProduct.invoiceit_crmx__Bundle_SequenceNumber__c = 1;
                                opportunityProduct.invoiceit_crmx__Product_Bundle__c = jobProductClass.jobProduct.invoiceit_s__Product_Bundle__c;
                               bundlsequenceflag =true;
                               break;
                            }    
                        }
                    
                    //}
                    if(bundlsequenceflag){
                        break;
                    }
                }
                
                
                
                System.debug(opportunityProduct.invoiceit_crmx__Product_Code__c);

                opportunityProduct.invoiceit_crmx__Description__c = jobProductClass.jobproduct.invoiceit_s__Description__c; 
                opportunityProduct.invoiceit_crmx__Product_Family__c = jobProductClass.jobproduct.invoiceit_s__Product_Family__c; 
                opportunityProduct.Product_SIN__c = jobProductClass.jobproduct.Sin_Number__c ;
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
        //upsert mapOpportunityProducts.values();
       
          if(map_orderproductId_oppProd.size() > 0){
              //upsert map_orderproductId_oppProd.values();
              OppProductsFromOrder = new  List<invoiceit_crmx__Opportunity_Product__c>();
              OppProductsFromOrder = map_orderproductId_oppProd.values();
              
            
              
          }
        
        
        
        /*****************Opportunity Rate Plans Logic ********************************/
         set<Id> setOpportunityProductIds = new set<Id>();
        map<Integer,invoiceit_crmx__Opportunity_Rate_Plan__c> mapOppRatePlans = new map<Integer,invoiceit_crmx__Opportunity_Rate_Plan__c>();
        Map<Id,invoiceit_crmx__Opportunity_Rate_Plan__c> map_orderRP_oppRP = new Map<Id,invoiceit_crmx__Opportunity_Rate_Plan__c>();
        
        for(JobProductClass jp : jobClass.JobProducts) {
            if(set_RenewableJobProductId.contains(jp.jobproduct.Id) && (!setRebasedOneTimeAndShippableProductIds.contains(jp.jobproduct.Id)) && (!setCancelledOrderProductsId.contains(jp.jobproduct.Id))){
           
                    for(JobRatePlanClass jrp : jp.jobRatePlans) {
                        invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c();
                        if(map_orderproductId_oppProd.containsKey(jp.JobProduct.Id))
                            oppRatePlan.invoiceit_crmx__Opportunity_Product__c = map_orderproductId_oppProd.get(jp.JobProduct.Id).Id;
                        oppRatePlan.Name = jrp.jobRatePlan.Name;
                        oppRatePlan.invoiceit_crmx__Description__c = jrp.jobRatePlan.invoiceit_s__Description__c;
                        system.debug('before ::::'+oppRatePlan.invoiceit_crmx__Product_Rate_Plan__c);
                        system.debug('before plan::::'+jrp.jobRatePlan.invoiceit_s__Product_Rate_Plan__c);
                        oppRatePlan.invoiceit_crmx__Product_Rate_Plan__c = jrp.jobRatePlan.invoiceit_s__Product_Rate_Plan__c;
                        system.debug('after ::::'+oppRatePlan.invoiceit_crmx__Product_Rate_Plan__c);
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
            oppProdRatePlansFromOrder = new List<invoiceit_crmx__Opportunity_Rate_Plan__c>();
             oppProdRatePlansFromOrder = map_orderRP_oppRP.values();
        /*******************************Opportunity Rate Plans Logic END************************************/
        
        
        /*******************Opportunity Rate Plan charge Logic START****************************************************/
         map<Integer,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> mapOppRatePlanCharges = new map<Integer,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> map_orderRPCId_OppRPC = new map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> map_orderRPCId_OrderRPC = new map<Id,invoiceit_s__Job_Rate_Plan_Charge__c>();
        Set<invoiceit_crmx__Opportunity_Product__c> setOppProductsToBeUpdates = new Set<invoiceit_crmx__Opportunity_Product__c>();
        List<invoiceit_crmx__Opportunity_Product__c> lstOppProductsToBeUpdates = new List<invoiceit_crmx__Opportunity_Product__c>();
        for(JobProductClass jp : jobClass.JobProducts) {
            system.debug('checkpoint 1');
            if(set_RenewableJobProductId.contains(jp.jobproduct.Id) && (!setRebasedOneTimeAndShippableProductIds.contains(jp.jobproduct.Id)) && (!setCancelledOrderProductsId.contains(jp.jobproduct.Id))){
                system.debug('checkpoint 2');
                for(JobRatePlanClass jrp : jp.jobRatePlans) {        
                    system.debug('checkpoint 3');           
                    Id oppRatePlanId = map_orderRP_oppRP.get(jrp.jobRatePlan.Id).Id;
                    for(JobRatePlanChargeClass jrpc : jrp.JobRatePlanCharges) {
                       if(jrpc.jobrateplancharge.Renewable__c){
                            system.debug('checkpoint 4');
                            //adding one condition to check service end date of charge is null or not.
                            /*if(jrpc.jobrateplancharge.invoiceit_s__Service_End_Date__c == null && jrpc.jobrateplancharge.invoiceit_s__Price_Type__c != 'One Time'){
        
                                chargeNames.add(jrpc.jobrateplancharge.name);
                                //mapProductNameNPriceType.put(jrpc.jobrateplancharge.name,jrpc.jobrateplancharge.invoiceit_s__Price_Type__c);
                                opportunity = new Opportunity();
                                return opportunity; 
                            }*/
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
                            oppRatePlanCharge.Chat_ID__c             = jrpc.jobrateplancharge.Chat_ID__c; 
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
                            oppRatePlanCharge.Created_From_Charge__c      = jrpc.jobrateplancharge.id; 
                           
                           //Addded by saiv - prodpack
                            system.debug('test here before line:::'+oppRatePlanCharge.invoiceit_crmx__Product_Bundle_Line__c);
                            system.debug('test here:::'+jrpc.jobrateplancharge.invoiceit_s__Product_Bundle_Line__c);
                            oppRatePlanCharge.invoiceit_crmx__Product_Bundle_Line__c = jrpc.jobrateplancharge.invoiceit_s__Product_Bundle_Line__c;
                            system.debug('test here after line:::'+oppRatePlanCharge.invoiceit_crmx__Product_Bundle_Line__c);
                            oppRatePlanCharge.Live_Date__c=  jrpc.jobrateplancharge.Live_Date__c;
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
                            System.debug('Job rate plan charge'+jrpc.jobrateplancharge.RecordType.DeveloperName);
                            System.debug('Quote Type'+quoteType);
                            if(jrpc.jobrateplancharge.RecordType.DeveloperName == 'M_N_Order_Rate_Plan_Charge' || (jrpc.jobrateplancharge.invoiceit_s__Order__r.invoiceit_s__Status__c == 'Evergreen' && (jrpc.jobrateplancharge.RecordType.DeveloperName == 'MDL_Order_Rate_Plan_Charge' || jrpc.jobrateplancharge.RecordType.DeveloperName == 'Nolo_Order_Rate_Plan_Charge'))){
                                System.debug('Inside the if condition');
                                oppRatePlanCharge.Quote_Type__c = 'Modify';
                            } else{
                            oppRatePlanCharge.Quote_Type__c = quoteType;
                            }
                            if (quoteType == 'Mid-Term')


                              oppRatePlanCharge.Quote_Type__c = 'Modify';
                            
                            OpportunityRatePlanChargeClass oppRatePlanChargeClass = new OpportunityRatePlanChargeClass();
                            oppRatePlanChargeClass.opportunityRatePlanChargeCounter = ++opportunityRateplanChargeCounter;
                            oppRatePlanChargeClass.opportunityRatePlanCharge = oppRatePlanCharge;
                            opportunityRatePlanClass.opportunityRatePlanCharges.add(oppRatePlanChargeClass);
                            mapOppRatePlanCharges.put(jrpc.JobRatePlanChargeCounter, oppRatePlanCharge);
                            map_orderRPCId_OppRPC.put(jrpc.jobrateplancharge.Id, oppRatePlanCharge);  
                           map_orderRPCId_OrderRPC.put(jrpc.jobrateplancharge.Id,jrpc.jobrateplancharge);
                        }
                    }    
                }
            }
        }
       oppProdRatePlanChargeFromOrder = new  List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> ();
        oppProdRatePlanChargeFromOrder = map_orderRPCId_OppRPC.values();
        /*************************************Opportunity Rate Plan Charge Logic END***************************/
        
        /***********************Opportunity Attribute LOGIC START*****************************************/
         // we need to populate the tiers
        map<Id, list<invoiceit_s__Job_Rate_Plan_Charge_Tier__c>> map_JobChargeId_JobTiers = new map<Id, list<invoiceit_s__Job_Rate_Plan_Charge_Tier__c>>();
        list<invoiceit_s__Job_Rate_Plan_Charge_Tier__c> jobTiers = new list<invoiceit_s__Job_Rate_Plan_Charge_Tier__c>();
         

        list<invoiceit_s__Job_Rate_Plan_Charge_Tier__c> jobTiersLocalVar;
      
        
        system.debug('@@@@@@map_orderRPCId_OppRPC keyset'+map_orderRPCId_OppRPC.keyset());

        // we need to populate the opportunity charge attributes
        map<Id, list<Order_Charge_Attribute__c>> map_JobChargeId_OrderAttributes = new map<Id, list<Order_Charge_Attribute__c>>();
        list<Order_Charge_Attribute__c> jobAttributes = [SELECT Name, Attribute_Name__c, Boolean_Value__c,Maximum_No_Of_Characters_In_Text__c,Minimum_No_Of_Characters_In_Text__c, Date_Value__c, Number_Value__c, String_Value__c, Attribute_Type__c,
                                                         Attribute_Order__c,Order_Rate_Plan_Charge__r.Shippable__c,Long_text_value__c,
                                                         Attribute_Picklist_Values__c,
                                                         Picklist_Value__c,
                                                         Phone_Value__c,Value_ID__c,
                                                         Order_Rate_Plan_Charge__c
                                                         FROM Order_Charge_Attribute__c
                                                         WHERE Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c =: jobClass.job.id
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
        system.debug('@@@@map_JobChargeId_OrderAttributes'+map_JobChargeId_OrderAttributes);
        // we need to insert the tiers and atrributes here
        //list<invoiceit_crmx__Opportunity_Rate_Plan_Charge_Tier__c> opportunityTiers = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge_Tier__c>();
        list<Opportunity_Charge_Attribute__c> opportunityAttributes = new list<Opportunity_Charge_Attribute__c>();
        //invoiceit_crmx__Opportunity_Rate_Plan_Charge_Tier__c opportunityTier;
        Opportunity_Charge_Attribute__c opportunityAttribute;
        String OppName;
        for(JobProductClass jp : jobClass.JobProducts) {
            if(set_RenewableJobProductId.contains(jp.jobproduct.Id)){
                for(JobRatePlanClass jrp : jp.jobRatePlans) {
                    for(JobRatePlanChargeClass jrpc : jrp.JobRatePlanCharges) {
                        //invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppCharge = mapOppRatePlanCharges.get(jrpc.JobRatePlanChargeCounter);
                        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppCharge = map_orderRPCId_OppRPC.get(jrpc.JobRatePlanCharge.Id);
                        // pull the tiers and create the opportunity tiers
                        /*if(map_JobChargeId_JobTiers.containsKey(jrpc.jobrateplancharge.Id)) {
                            for(invoiceit_s__Job_Rate_Plan_Charge_Tier__c orderTier : map_JobChargeId_JobTiers.get(jrpc.jobrateplancharge.Id)) {
                                opportunityTier = new invoiceit_crmx__Opportunity_Rate_Plan_Charge_Tier__c();
                                opportunityTier.invoiceit_crmx__Start_Unit__c = orderTier.invoiceit_s__Start_Unit__c;
                                opportunityTier.invoiceit_crmx__End_Unit__c = orderTier.invoiceit_s__End_Unit__c;
                                opportunityTier.invoiceit_crmx__Unit_Cost_Price__c = orderTier.invoiceit_s__Unit_Cost_Price__c;
                                opportunityTier.invoiceit_crmx__Unit_Price__c = orderTier.invoiceit_s__Unit_Price__c;
                                opportunityTier.invoiceit_crmx__Opportunity_Rate_Plan_Charge__c = oppCharge.Id;
    
                                opportunityTiers.add(opportunityTier);
                            }
                        }   
                        */
                        // pull the attributes and create the opportunity attributes
                        // change for MHBS-160
                       system.debug('@@@@@jrpc.jobrateplancharge.name'+jrpc.jobrateplancharge.Name);
                        if(map_JobChargeId_OrderAttributes.containsKey(jrpc.jobrateplancharge.Id)) {
                            for(Order_Charge_Attribute__c orderAttribute : map_JobChargeId_OrderAttributes.get(jrpc.jobrateplancharge.Id)) {                                
                                       system.debug('@@@@orderAttribute name'+ orderAttribute.Attribute_Name__c);
                                        opportunityAttribute = new Opportunity_Charge_Attribute__c();
                                        opportunityAttribute.Attribute_Type__c = orderAttribute.Attribute_Type__c;
                                        opportunityAttribute.Attribute_Name__c = orderAttribute.Attribute_Name__c;
                    opportunityAttribute.Value_ID__c= orderAttribute.Value_ID__c;
                                        if(!(orderAttribute.Attribute_Name__c == 'Edition' && orderAttribute.Order_Rate_Plan_Charge__r.Shippable__c == 'Yes')){
                                            opportunityAttribute.Picklist_Value__c = orderAttribute.Picklist_Value__c;
                                            opportunityAttribute.String_Value__c = orderAttribute.String_Value__c;
                                            opportunityAttribute.Boolean_Value__c = orderAttribute.Boolean_Value__c;
                                            opportunityAttribute.Number_Value__c = orderAttribute.Number_Value__c;
                                            opportunityAttribute.Date_Value__c = orderAttribute.Date_Value__c;
                                            opportunityAttribute.Phone_Value__c= orderAttribute.Phone_Value__c;
                                            opportunityAttribute.Long_text_value__c= orderAttribute.Long_text_value__c;
                                            
                                        }    
                                        opportunityAttribute.Attribute_Order__c = orderAttribute.Attribute_Order__c;
                                        opportunityAttribute.Attribute_Picklist_Values__c = orderAttribute.Attribute_Picklist_Values__c;
                                        opportunityAttribute.Opportunity_Rate_Plan_Charge__c = oppCharge.Id;
                                        opportunityAttribute.Maximum_No_Of_Characters_In_Text__c = orderAttribute.Maximum_No_Of_Characters_In_Text__c;
                                        opportunityAttribute.Minimum_No_Of_Characters_In_Text__c = orderAttribute.Minimum_No_Of_Characters_In_Text__c;
                                        opportunityAttributesFromOrder.add(opportunityAttribute);
                                }
                            
                        }
                    }
                }
            }
        }
        
        /***************************Opportunity Attribute LOGIC END*********************************************/
        
        
        
      
    }
    
    
    public static List<invoiceit_crmx__Opportunity_Product__c> oppProductsRelationship(List<invoiceit_crmx__Opportunity_Product__c> OppProductsFromOrdert ){
          Map<Id,invoiceit_crmx__Opportunity_Product__c> OrderprodVsOppprod = new Map<Id,invoiceit_crmx__Opportunity_Product__c>();
          /********To Establish relationship between feature products and parent products *******************************/
              List<invoiceit_crmx__Opportunity_Product__c> oppPRodtoUpdate = new List<invoiceit_crmx__Opportunity_Product__c>();
              List<invoiceit_crmx__Opportunity_Product__c> oppPRod = [select id,Name, AddNgageChatFeature__c,Created_From_Order_Product__c,
                                                                          Created_From_Order_Product__r.Created_From_Order_Product__c
                                                                        From invoiceit_crmx__Opportunity_Product__c
                                                                        where id IN:OppProductsFromOrdert];
              
              system.debug('@@@@oppPRod'+oppPRod);
              for(invoiceit_crmx__Opportunity_Product__c soppProd : oppPRod){
                  if(soppProd.AddNgageChatFeature__c == false){
                      OrderprodVsOppprod.put(soppProd.Created_From_Order_Product__c,soppProd);
                  }
                  
              }
              
              for(invoiceit_crmx__Opportunity_Product__c soppProd : oppPRod){
                   if(soppProd.Created_From_Order_Product__r.Created_From_Order_Product__c!=Null ){
                       
                        if(soppProd.AddNgageChatFeature__c == false && OrderprodVsOppprod.containskey(soppProd.Created_From_Order_Product__r.Created_From_Order_Product__c)){
                             soppProd.Chat_Parent_Opportunity_Product__c  = OrderprodVsOppprod.get(soppProd.Created_From_Order_Product__r.Created_From_Order_Product__c).id;
                           oppPRodtoUpdate.add(soppProd);
                            //system.debug('@@@@@@ childvhat midterm '+childchat.Chat_Parent_Opportunity_Product__c);
                        }
                      
                          
                       
                    }
                   else if(soppProd.AddNgageChatFeature__c && OrderprodVsOppprod.containskey(soppProd.Created_From_Order_Product__c)){
                           soppProd.Chat_Parent_Opportunity_Product__c  = OrderprodVsOppprod.get(soppProd.Created_From_Order_Product__c).id;
                        oppPRodtoUpdate.add(soppProd);
                     }
                  
              } 
              
              //if(!oppPRodtoUpdate.isEmpty()){
                 // update oppPRodtoUpdate;
              //}
              //
              system.debug('@@@@@@oppPRodtoUpdate'+oppPRodtoUpdate);
              return oppPRodtoUpdate;
        
     }
    
    /*
    public static void oppRatePlanChargeRelationship(List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> oppCharges,
                                                     map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> map_orderRPCId_OrderRPC){
         List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>childcharges = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>childchargestoUpdate = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>chatIdVScharge = new Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opcharge: oppCharges){
                if(opcharge.Created_From_Charge__c != NULL){
                    invoiceit_s__Job_Rate_Plan_Charge__c ordc = map_orderRPCId_OrderRPC.get(opcharge.Created_From_Charge__c);
                    if(ordc.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c != NULL){
                        childcharges.add(opcharge);
                    }
                    else{
                        chatIdVScharge.put(ordc.Opportunity_Rate_Plan_Charge__c,opcharge);
                    }
                    
                }
            }
            
            if(!childcharges.isEmpty()){
                 for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c ccharget: childcharges){
                    invoiceit_s__Job_Rate_Plan_Charge__c ordc = map_orderRPCId_OrderRPC.get(ccharget.Created_From_Charge__c);
                    if(ordc.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c != NULL){
                        ccharget.Chat_Parent_Opportunity_Rate_Plan_Charge__c = chatIdVScharge.get(ordc.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c).id;
                        childchargestoUpdate.add(ccharget);
                    }
                }
                if(!childchargestoUpdate.isEmpty()){
                    update childchargestoUpdate;
                }
                
            }
        
        
    }
    
   */
    public static List<invoiceit_crmx__Opportunity_Rate_Plan__c> createoppPoductRateplans(List<invoiceit_crmx__Opportunity_Product__c>oppProductst){
        List<invoiceit_crmx__Opportunity_Rate_Plan__c> oppratePlans = new List<invoiceit_crmx__Opportunity_Rate_Plan__c>();
        Map<Id,invoiceit_crmx__Opportunity_Product__c> orderIdtoOppProduct = new Map<Id,invoiceit_crmx__Opportunity_Product__c>();
        for(invoiceit_crmx__Opportunity_Product__c oppProd : oppProductst){
            If(map_orderproductId_oppProd.containsKey(oppProd.Created_From_Order_Product__c) && oppProd.MidTerm__c == True){
                orderIdtoOppProduct.put(oppProd.Created_From_Order_Product__c,oppProd);
            }
        }
        
        
        if(jobClass!= NULL && jobClass.JobProducts != NULL){
             for(JobProductClass jp : jobClass.JobProducts) {
                if(set_RenewableJobProductId.contains(jp.jobproduct.Id) && (!setRebasedOneTimeAndShippableProductIds.contains(jp.jobproduct.Id)) ){
                //for(OpportunityProductClass op : opportunityClass.opportunityProducts) {
                        for(JobRatePlanClass jrp : jp.jobRatePlans) {
                            invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c();
                            if(orderIdtoOppProduct.containsKey(jp.JobProduct.Id))
                                oppRatePlan.invoiceit_crmx__Opportunity_Product__c = orderIdtoOppProduct.get(jp.JobProduct.Id).Id;
                            oppRatePlan.Name = jrp.jobRatePlan.Name;
                            oppRatePlan.invoiceit_crmx__Description__c = jrp.jobRatePlan.invoiceit_s__Description__c;
                            system.debug('before ::::'+oppRatePlan.invoiceit_crmx__Product_Rate_Plan__c);
                            system.debug('before plan::::'+jrp.jobRatePlan.invoiceit_s__Product_Rate_Plan__c);
                            oppRatePlan.invoiceit_crmx__Product_Rate_Plan__c = jrp.jobRatePlan.invoiceit_s__Product_Rate_Plan__c;
                            system.debug('after ::::'+oppRatePlan.invoiceit_crmx__Product_Rate_Plan__c);
                            oppRatePlan.invoiceit_crmx__SequenceNumber__c = jrp.jobRatePlan.invoiceit_s__SequenceNumber__c;
                            oppRatePlan.MidTerm__c = true;
                            oppRatePlan.Created_From_Order_Rate_Plan__c = jrp.jobRatePlan.Id;
                            //dynamic field mapping ends here
                            /*opportunityRatePlanClass = new OpportunityRatePlanClass();
                            opportunityRatePlanClass.opportunityRatePlanCounter = ++OpportunityRatePlanCounter;
                            opportunityRatePlanClass.opportunityrateplan = oppRatePlan;
                            opportunityProductClass.opportunityRatePlans.add(opportunityRatePlanClass);
                            mapOppRatePlans.put(opportunityRatePlanClass.opportunityRatePlanCounter, oppRatePlan);*/
                            map_orderRP_oppRP.put(jrp.jobRatePlan.Id , oppRatePlan);
                            oppratePlans.add(oppRatePlan);
                        }         
                //}
                }
            }
            
        }
       
        
       return oppratePlans;
        
    }
    
    
    public static List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> createOpprateplancharges(List<invoiceit_crmx__Opportunity_Rate_Plan__c> opprateplanst){
         List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> oppratePlancharges = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        Map<Id,invoiceit_crmx__Opportunity_Rate_Plan__c> orderrateplanIdtoOpprateplan= new Map<Id,invoiceit_crmx__Opportunity_Rate_Plan__c>();
        for(invoiceit_crmx__Opportunity_Rate_Plan__c opprp : opprateplanst){
            If(map_orderRP_oppRP.containsKey(opprp.Created_From_Order_Rate_Plan__c) && opprp.MidTerm__c == True){
                orderrateplanIdtoOpprateplan.put(opprp.Created_From_Order_Rate_Plan__c,opprp);
            }
        }
        system.debug('@@@@orderrateplanIdtoOpprateplan'+orderrateplanIdtoOpprateplan);
        
        for(JobProductClass jp : jobClass.JobProducts) {
            system.debug('checkpoint 1');
            if(set_RenewableJobProductId.contains(jp.jobproduct.Id) && (!setRebasedOneTimeAndShippableProductIds.contains(jp.jobproduct.Id))){
                system.debug('checkpoint 2');
                for(JobRatePlanClass jrp : jp.jobRatePlans) {        
                    system.debug('checkpoint 3');           
                    Id oppRatePlanId = orderrateplanIdtoOpprateplan.get(jrp.jobRatePlan.Id).Id;
                    system.debug('@@@@oppRatePlanId'+oppRatePlanId);
                    for(JobRatePlanChargeClass jrpc : jrp.JobRatePlanCharges) {
                      // if(jrpc.jobrateplancharge.Renewable__c){
                            system.debug('checkpoint 4');
                            //adding one condition to check service end date of charge is null or not.
                            /*if(jrpc.jobrateplancharge.invoiceit_s__Service_End_Date__c == null && jrpc.jobrateplancharge.invoiceit_s__Price_Type__c != 'One Time'){
        
                                chargeNames.add(jrpc.jobrateplancharge.name);
                                //mapProductNameNPriceType.put(jrpc.jobrateplancharge.name,jrpc.jobrateplancharge.invoiceit_s__Price_Type__c);
                                opportunity = new Opportunity();
                                return opportunity; 
                            }*/
                            invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c();
                             oppRatePlanCharge.invoiceit_crmx__Opportunity__c = optyId;
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
                            oppRatePlanCharge.Chat_ID__c             = jrpc.jobrateplancharge.Chat_ID__c; 
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
                            oppRatePlanCharge.Created_From_Charge__c      = jrpc.jobrateplancharge.id; 
                           
                           //Addded by saiv - prodpack
                            system.debug('test here before line:::'+oppRatePlanCharge.invoiceit_crmx__Product_Bundle_Line__c);
                            system.debug('test here:::'+jrpc.jobrateplancharge.invoiceit_s__Product_Bundle_Line__c);
                            oppRatePlanCharge.invoiceit_crmx__Product_Bundle_Line__c = jrpc.jobrateplancharge.invoiceit_s__Product_Bundle_Line__c;
                            system.debug('test here after line:::'+oppRatePlanCharge.invoiceit_crmx__Product_Bundle_Line__c);
                            oppRatePlanCharge.Live_Date__c=  jrpc.jobrateplancharge.Live_Date__c;
                            //code added by Lister to facilitate carrrying SIN numbers from Order products to Oppty Products
                            if((jrpc.jobrateplancharge.invoiceit_s__Price_Type__c != 'One Time') && 
                                !(jrpc.jobrateplancharge.invoiceit_s__Price_Type__c == 'Monthly' && jrpc.jobrateplancharge.Shippable__c == 'Yes')) {
                                oppRatePlanCharge.SIN__c = jrpc.jobrateplancharge.SIN__c;
                                
                            }   
                           /* if(jrpc.jobrateplancharge.invoiceit_s__Price_Type__c == 'One Time' || (jrpc.jobrateplancharge.invoiceit_s__Price_Type__c == 'Monthly' && jrpc.jobrateplancharge.Shippable__c == 'Yes')) {
                                if(map_orderproductId_oppProd.containsKey(jp.jobproduct.Id)) {
                                    map_orderproductId_oppProd.get(jp.jobproduct.Id).Product_SIN__c = null;
                                    setOppProductsToBeUpdates.add(map_orderproductId_oppProd.get(jp.jobproduct.Id));
                                }
                            }*/
                            //oppRatePlanCharge.Created_From_Charge__c = jrpc.jobrateplancharge.Id;
                            System.debug('Job rate plan charge'+jrpc.jobrateplancharge.RecordType.DeveloperName);
                           // System.debug('Quote Type'+quoteType);
                            if(jrpc.jobrateplancharge.RecordType.DeveloperName == 'M_N_Order_Rate_Plan_Charge' || (jrpc.jobrateplancharge.invoiceit_s__Order__r.invoiceit_s__Status__c == 'Evergreen' && (jrpc.jobrateplancharge.RecordType.DeveloperName == 'MDL_Order_Rate_Plan_Charge' || jrpc.jobrateplancharge.RecordType.DeveloperName == 'Nolo_Order_Rate_Plan_Charge'))){
                                System.debug('Inside the if condition');
                                //oppRatePlanCharge.Quote_Type__c = 'Modify';
                            } else{
                            //oppRatePlanCharge.Quote_Type__c = quoteType;
                            }
                           // if (quoteType == 'Mid-Term')


                              oppRatePlanCharge.Quote_Type__c = 'Modify';
                        oppRatePlanCharge.MidTerm__c = true;
                            
                           /* OpportunityRatePlanChargeClass oppRatePlanChargeClass = new OpportunityRatePlanChargeClass();
                            oppRatePlanChargeClass.opportunityRatePlanChargeCounter = ++opportunityRateplanChargeCounter;
                            oppRatePlanChargeClass.opportunityRatePlanCharge = oppRatePlanCharge;
                            opportunityRatePlanClass.opportunityRatePlanCharges.add(oppRatePlanChargeClass);
                            mapOppRatePlanCharges.put(jrpc.JobRatePlanChargeCounter, oppRatePlanCharge);
                            map_orderRPCId_OppRPC.put(jrpc.jobrateplancharge.Id, oppRatePlanCharge);  */
                           map_orderRPCId_oppRPCharge.put(jrpc.jobrateplancharge.Id,oppRatePlanCharge);
                           oppratePlancharges.add(oppRatePlanCharge);
                       // }
                    }    
                }
            }
        }
        //insert oppratePlancharges;
        return oppratePlancharges;
    }
    
    
    public static void insertoptychargeattributes(List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> chrgestList){
         Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> orderrateplanchargeIdtoOpprateplancharge= new Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc : chrgestList){
            If(map_orderRPCId_oppRPCharge.containsKey(opprpc.Created_From_Charge__c) && opprpc.MidTerm__c == True){
                orderrateplanchargeIdtoOpprateplancharge.put(opprpc.Created_From_Charge__c,opprpc);
            }
        }
        
        
        
        
         // we need to populate the opportunity charge attributes
        map<Id, list<Order_Charge_Attribute__c>> map_JobChargeId_OrderAttributes = new map<Id, list<Order_Charge_Attribute__c>>();
        list<Order_Charge_Attribute__c> jobAttributes = [SELECT Name, Attribute_Name__c, Boolean_Value__c,Maximum_No_Of_Characters_In_Text__c,Minimum_No_Of_Characters_In_Text__c, Date_Value__c, Number_Value__c, String_Value__c, Attribute_Type__c,
                                                         Attribute_Order__c,Order_Rate_Plan_Charge__r.Shippable__c,Long_text_value__c,
                                                         Attribute_Picklist_Values__c,
                                                         Picklist_Value__c,
                                                         Phone_Value__c,Value_ID__c,
                                                         Order_Rate_Plan_Charge__c
                                                         FROM Order_Charge_Attribute__c
                                                         WHERE Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c =: jobClass.job.id
                                                         AND Order_Rate_Plan_Charge__c in: map_orderRPCId_oppRPCharge.keyset()
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
        
         Opportunity_Charge_Attribute__c opportunityAttribute;
        String OppName;
        for(JobProductClass jp : jobClass.JobProducts) {
            if(set_RenewableJobProductId.contains(jp.jobproduct.Id)){
                for(JobRatePlanClass jrp : jp.jobRatePlans) {
                    for(JobRatePlanChargeClass jrpc : jrp.JobRatePlanCharges) {
                        //invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppCharge = mapOppRatePlanCharges.get(jrpc.JobRatePlanChargeCounter);
                        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppCharge = orderrateplanchargeIdtoOpprateplancharge    .get(jrpc.JobRatePlanCharge.Id);
                        // pull the tiers and create the opportunity tiers
                        /*if(map_JobChargeId_JobTiers.containsKey(jrpc.jobrateplancharge.Id)) {
                            for(invoiceit_s__Job_Rate_Plan_Charge_Tier__c orderTier : map_JobChargeId_JobTiers.get(jrpc.jobrateplancharge.Id)) {
                                opportunityTier = new invoiceit_crmx__Opportunity_Rate_Plan_Charge_Tier__c();
                                opportunityTier.invoiceit_crmx__Start_Unit__c = orderTier.invoiceit_s__Start_Unit__c;
                                opportunityTier.invoiceit_crmx__End_Unit__c = orderTier.invoiceit_s__End_Unit__c;
                                opportunityTier.invoiceit_crmx__Unit_Cost_Price__c = orderTier.invoiceit_s__Unit_Cost_Price__c;
                                opportunityTier.invoiceit_crmx__Unit_Price__c = orderTier.invoiceit_s__Unit_Price__c;
                                opportunityTier.invoiceit_crmx__Opportunity_Rate_Plan_Charge__c = oppCharge.Id;
    
                                opportunityTiers.add(opportunityTier);
                            }
                        }   
                        */
                        // pull the attributes and create the opportunity attributes
                        // change for MHBS-160
                       system.debug('@@@@@jrpc.jobrateplancharge.name'+jrpc.jobrateplancharge.Name);
                        if(map_JobChargeId_OrderAttributes.containsKey(jrpc.jobrateplancharge.Id)) {
                            for(Order_Charge_Attribute__c orderAttribute : map_JobChargeId_OrderAttributes.get(jrpc.jobrateplancharge.Id)) {                                
                                       system.debug('@@@@orderAttribute name'+ orderAttribute.Attribute_Name__c);
                                        opportunityAttribute = new Opportunity_Charge_Attribute__c();
                                        opportunityAttribute.Attribute_Type__c = orderAttribute.Attribute_Type__c;
                                        opportunityAttribute.Attribute_Name__c = orderAttribute.Attribute_Name__c;
                    opportunityAttribute.Value_ID__c= orderAttribute.Value_ID__c;
                                        if(!(orderAttribute.Attribute_Name__c == 'Edition' && orderAttribute.Order_Rate_Plan_Charge__r.Shippable__c == 'Yes')){
                                            opportunityAttribute.Picklist_Value__c = orderAttribute.Picklist_Value__c;
                                            opportunityAttribute.String_Value__c = orderAttribute.String_Value__c;
                                            opportunityAttribute.Boolean_Value__c = orderAttribute.Boolean_Value__c;
                                            opportunityAttribute.Number_Value__c = orderAttribute.Number_Value__c;
                                            opportunityAttribute.Date_Value__c = orderAttribute.Date_Value__c;
                                            opportunityAttribute.Phone_Value__c= orderAttribute.Phone_Value__c;
                                            opportunityAttribute.Long_text_value__c= orderAttribute.Long_text_value__c;
                                        }    
                                        opportunityAttribute.Attribute_Order__c = orderAttribute.Attribute_Order__c;
                                        opportunityAttribute.Attribute_Picklist_Values__c = orderAttribute.Attribute_Picklist_Values__c;
                                        opportunityAttribute.Opportunity_Rate_Plan_Charge__c = oppCharge.Id;
                                        opportunityAttribute.Maximum_No_Of_Characters_In_Text__c = orderAttribute.Maximum_No_Of_Characters_In_Text__c;
                                        opportunityAttribute.Minimum_No_Of_Characters_In_Text__c = orderAttribute.Minimum_No_Of_Characters_In_Text__c;
                                        opportunityAttributesFromOrder.add(opportunityAttribute);
                                }
                            
                        }
                    }
                }
            }
        }
        
        
        if(!opportunityAttributesFromOrder.isEmpty()){
            insert opportunityAttributesFromOrder;
        }
        
        
        
    }
    
    
    
    
    
}
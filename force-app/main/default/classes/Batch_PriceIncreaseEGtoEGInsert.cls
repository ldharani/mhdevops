/***********************************************************************************************************************
 * @author - SS
 * @date - 11 Mar 2022
 * @description - To create EG to EG opportunity and quote for price increased evergreen contracts
 * @testclass - Test_Batch_EvgPriceIncrease

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-5998    SS            11/03/2022   John Mattheson          Update EG to EG quote for price increased evergreen contracts
MHBS-6636    SS            31/03/2022   John Mattheson   <T1>   Package relationship cascading on EG price increase batch job
MHBS-8916    CK			   30/03/2023   Kavitha VS		 <T02>  Replacing AttributeValues__c with newly created field Attribute_Values__c due to Formula field limitation of pointing to a long text area
************************************************************************************************************************/
global class Batch_PriceIncreaseEGtoEGInsert implements Database.Batchable <SObject>,Database.AllowsCallouts,Database.Stateful{
    String exId;
   // List<SBQQ__QuoteLine__c> insertqlineList = new List<SBQQ__QuoteLine__c>();
   List<Set<Id>> qIdVSqlIds = new List<Set<Id>>();
    
    global Batch_PriceIncreaseEGtoEGInsert(){
        init('');
    }
    
     global Batch_PriceIncreaseEGtoEGInsert(String exId){
       init(exId);
    }
    
    global void init(String exId){
        if(!String.isEmpty(exId)){
            this.exId = exId;
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strQuery;
        
        strQuery= 'Select Id,Amend_Quote__c,Status__c,SBQQ__Quote__c,AutoEvergreen_Failure_Reason__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Status__c ,SBQQ__Order__c from contract where Status__c = \'Evergreen\' and Price_Increased__c = true'; 
        if(!String.isEmpty(this.exId))  {
           strQuery += ' and  id = ' + '\''+ this.exId+'\'';        
        } 
        if(test.isRunningTest()) {
            strQuery= 'Select Id,Amend_Quote__c,Status__c,SBQQ__RenewalOpportunity__c,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c,AutoEvergreen_Failure_Reason__c from contract';           
        }
        
        return Database.getQueryLocator(strQuery);
        
    }
    
    global void execute(Database.BatchableContext BC, List <Contract> ContractsList) {
        MDL_RecursionHandler.batchAutoEvgPriceincreaseCheck = false; 
        Set<Id> quoteIds = new Set<Id>();
        Set<id> quoteLineIds = new Set<Id>();
        Set<Id> setOfPackageQuoteLine = new Set<Id>();
        //List<Opportunity> updateOpplist= new List<Opportunity>();
         List<SBQQ__QuoteLine__c> insertqlineList = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> updateQuoteline = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> qlineList = new List<SBQQ__QuoteLine__c>();
        
        Map<Id,Id> quoteLineVsContractIds = new Map<Id,Id>();
        
        for(Contract obj: ContractsList){
            quoteIds.add(obj.Amend_Quote__c);
        }
        
        if(quoteIds.size() > 0){
            List<SBQQ__Quote__c> qList = [Select Id from SBQQ__Quote__c where id in:quoteIds];
            List<SBQQ__QuoteLineGroup__c> insertQLG = new  List<SBQQ__QuoteLineGroup__c>();
            for(SBQQ__Quote__c q: qList){
                SBQQ__QuoteLineGroup__c group1 = new SBQQ__QuoteLineGroup__c();
                group1.name = 'Cloned Products';
                group1.SBQQ__Quote__c = q.Id ;
                group1.SBQQ__CustomerTotal__c =0;
                group1.SBQQ__ListTotal__c = 0;
                group1.SBQQ__NetTotal__c = 0;
                group1.SBQQ__Number__c = 2;
                insertQLG.add(group1);
            }
            //Create Quote Line Group for Cloned Quote Lines
            try{
            insert insertQLG;
            }
            catch(Exception ex){
                Util.processException(ex,true,'Error during insert of Quote Line Group'+insertQLG);
            }
            
            //Create Map for Quote and Quote Line Group
            List<SBQQ__QuoteLineGroup__c> qlgList = [Select Id,SBQQ__Quote__c from SBQQ__QuoteLineGroup__c where SBQQ__Quote__c in:quoteIds];
            Map<id,id> quoteVsqlgId = new Map<Id,Id>();
            for(SBQQ__QuoteLineGroup__c qlg :qlgList){
                quoteVsqlgId.put(qlg.SBQQ__Quote__c,qlg.Id);
                
            }
            
            
            if(!test.isRunningTest()){
            qlineList= [ SELECT Id, Name, RecordTypeId, SBQQ__Quote__r.SBQQ__MasterEvergreenContract__c,CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, SBQQ__Quote__c, SBQQ__AdditionalDiscountAmount__c, SBQQ__AdditionalDiscount__c, SBQQ__AdditionalQuantity__c, SBQQ__AllowAssetRefund__c, SBQQ__BatchQuantity__c, SBQQ__BillingFrequency__c, SBQQ__BillingType__c, SBQQ__BlockPrice__c, SBQQ__Bundle__c, SBQQ__BundledQuantity__c, SBQQ__Bundled__c, SBQQ__CarryoverLine__c, SBQQ__ChargeType__c, SBQQ__ComponentCost__c, SBQQ__ComponentDiscountedByPackage__c, SBQQ__ComponentListTotal__c, SBQQ__ComponentSubscriptionScope__c, SBQQ__ComponentTotal__c, SBQQ__ComponentUpliftedByPackage__c, SBQQ__ComponentVisibility__c, SBQQ__CompoundDiscountRate__c, SBQQ__ConfigurationRequired__c, SBQQ__ContractedPrice__c, SBQQ__CostEditable__c, SBQQ__Cost__c, SBQQ__CustomerPrice__c, SBQQ__CustomerTotal__c, SBQQ__DefaultSubscriptionTerm__c, SBQQ__Description__c, SBQQ__Dimension__c, SBQQ__DiscountScheduleType__c, SBQQ__DiscountSchedule__c, SBQQ__DiscountTier__c, SBQQ__Discount__c, SBQQ__DistributorDiscount__c, SBQQ__DynamicOptionId__c, SBQQ__EarliestValidAmendmentStartDate__c, SBQQ__EffectiveEndDate__c, SBQQ__EffectiveQuantity__c, SBQQ__EffectiveStartDate__c, SBQQ__EffectiveSubscriptionTerm__c, SBQQ__EndDate__c, SBQQ__Existing__c, SBQQ__Favorite__c, SBQQ__GenerateContractedPrice__c, SBQQ__GrossProfit__c, SBQQ__Group__c, SBQQ__Guidance__c, SBQQ__HasConsumptionSchedule__c, SBQQ__Hidden__c, SBQQ__Incomplete__c, SBQQ__ListPrice__c, SBQQ__ListTotal__c, SBQQ__MarkupAmount__c, SBQQ__MarkupRate__c, SBQQ__Markup__c, SBQQ__MaximumPrice__c, SBQQ__MinimumPrice__c, SBQQ__NetPrice__c, SBQQ__NetTotal__c, SBQQ__NonDiscountable__c, SBQQ__NonPartnerDiscountable__c, SBQQ__Number__c, SBQQ__OptionDiscountAmount__c, SBQQ__OptionDiscount__c, SBQQ__OptionLevel__c, SBQQ__OptionType__c, SBQQ__Optional__c, SBQQ__OriginalPrice__c, SBQQ__OriginalQuoteLineId__c, SBQQ__OriginalUnitCost__c, SBQQ__PackageCost__c, SBQQ__PackageListTotal__c, SBQQ__PackageProductCode__c, SBQQ__PackageProductDescription__c, SBQQ__PackageTotal__c, SBQQ__PartnerDiscount__c, SBQQ__PartnerPrice__c, SBQQ__PartnerTotal__c, SBQQ__PreviousSegmentPrice__c, SBQQ__PreviousSegmentUplift__c, SBQQ__PriceEditable__c, SBQQ__PricebookEntryId__c, SBQQ__PricingMethodEditable__c, SBQQ__PricingMethod__c, SBQQ__PriorQuantity__c, SBQQ__ProductCode__c, SBQQ__ProductFamily__c, SBQQ__ProductName__c, SBQQ__ProductOption__c, SBQQ__ProductSubscriptionType__c, SBQQ__Product__c, SBQQ__ProrateMultiplier__c, SBQQ__ProratedListPrice__c, SBQQ__ProratedPrice__c, SBQQ__Quantity__c, SBQQ__RegularPrice__c, SBQQ__RegularTotal__c, SBQQ__Renewal__c, SBQQ__RenewedAsset__c, SBQQ__RenewedSubscription__c, SBQQ__RequiredBy__c, SBQQ__SegmentIndex__c, SBQQ__SegmentKey__c, SBQQ__SegmentLabel__c, SBQQ__Source__c, SBQQ__SpecialPriceDescription__c, SBQQ__SpecialPriceType__c, SBQQ__SpecialPrice__c, SBQQ__StartDate__c, SBQQ__SubscribedAssetIds__c, SBQQ__SubscriptionBase__c, SBQQ__SubscriptionCategory__c, SBQQ__SubscriptionPercent__c, SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionScope__c, SBQQ__SubscriptionTargetPrice__c, SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionType__c, SBQQ__TaxCode__c, SBQQ__Taxable__c, SBQQ__TermDiscountSchedule__c, SBQQ__TermDiscountTier__c, SBQQ__TermDiscount__c, SBQQ__TotalDiscountAmount__c, SBQQ__TotalDiscountRate__c, SBQQ__UnitCost__c, SBQQ__UnproratedNetPrice__c, SBQQ__UpgradedAsset__c, SBQQ__UpgradedQuantity__c, SBQQ__UpgradedSubscription__c, SBQQ__UpliftAmount__c, SBQQ__Uplift__c, SBQQ__VolumeDiscount__c, blng__BillableUnitPrice__c, AVA_SFCPQ__Location_Code__c, AVA_SFCPQ__SalesTaxDetails__c, AVA_SFCPQ__Sales_Tax_Details__c, AVA_SFCPQ__TaxAmount__c, Attribute_Values__c, Attribute_Relationship__c, Cancelled__c, ECF1__c, ECF__c, Early_Cancellation_Fee__c, Error_Text__c, Historical_SFDC_ID__c, IconImg__c, Inventory_Id__c, Isdataloaded__c, Legacy_Current_Charge_Date__c, Legacy_Next_Charge_Date__c, Legacy_Order_Number_Sequence__c, Legacy_Order_Number__c, Live_Date__c, Loss_Reasons__c, Part_of_Upsell__c, Pend_Date__c, Product_Business_Unit__c, Profit__c, Recalculation_Needed__c, SIN__c, Shipper_Name__c, Shipping_Tracking_Number__c, Usage_List_Price__c, Amend_Bundle__c, Discount_Percent__c, Fulfillment_date__c, Legacy_Cancellation_date__c, Legacy_Fulfillment_End_Date__c, Legacy_Fulfillment_Start_Date__c, Legacy_Live_Date__c, Legacy_Renew_Rebase_Truncate_Date__c, MonthlyDiscountValue__c, ParentProduct__c, Product_Bundle_Type__c, Product_Upsell_Package__c, customerNumber__c, Chat_ID__c, Attribute_Relationship_18_digit_Id__c, Quote_Subscription_type__c, Last_day_of_month__c,   Group_Number__c FROM SBQQ__QuoteLine__c  where sbqq__quote__c in :quoteids];//<T02>
            }
            else{
                qlineList = [ select id,SBQQ__Group__c,SBQQ__Quote__r.SBQQ__MasterEvergreenContract__c,SBQQ__Quote__c,SBQQ__SubscriptionType__c,SBQQ__ProductSubscriptionType__c,SBQQ__SubscriptionTerm__c,SBQQ__EndDate__c,SBQQ__Quantity__c,SBQQ__Product__c, SBQQ__ProductOption__c from SBQQ__QuoteLine__c limit 1];
            }
            
            if(insertqlineList.size()>0){
                insertqlineList.clear();
            }
            System.debug('insertqlineList :'+insertqlineList);
            //Update Quantity as 1 for Cloned Quote Lines
            //Update Prior Quantity as 0 as this is considered a new product
            //Update upgraded subscription to null as this is considered a new product
            for(SBQQ__QuoteLine__c quoteline: qlineList){
                quoteLineVsContractIds.put(quoteline.Id,quoteline.SBQQ__Quote__r.SBQQ__MasterEvergreenContract__c);
                SBQQ__QuoteLine__c ql =new SBQQ__QuoteLine__c(); 
                System.debug(quoteline);
                System.debug(ql);
                ql = quoteline.clone(false,true,false,true);
                if(quoteVsqlgId.containskey(ql.SBQQ__Quote__c)){
                    ql.SBQQ__Group__c = quoteVsqlgId.get(ql.SBQQ__Quote__c);
                 }
                ql.Id = null;
                ql.SBQQ__Quantity__c = 1;
                ql.SBQQ__PriorQuantity__c = 0;
                ql.SBQQ__UpgradedSubscription__c = null;
                ql.SBQQ__RequiredBy__c = null;
                insertqlineList.add(ql);
                
            }
            for(SBQQ__QuoteLine__c ql:insertqlineList){
            System.debug(ql);
            }
            try{ 
                insert insertqlineList;
            }
            catch(Exception ex){
                Util.processException(ex,true,'Error during insert of Cloned Quote Lines'+insertqlineList,quoteLineVsContractIds);
            }
            
            
        }
        System.debug(insertqlineList);
        
       Set<Id> qLIds = new Set<Id>();
        List<SBQQ__QuoteLine__c> qList = [Select Id, Name, SBQQ__Product__r.Name  from SBQQ__QuoteLine__c where id in :insertqlineList];
        Boolean hasBundle = false;
        for(SBQQ__QuoteLine__c ql:qList){
            //<T1> 
            if( ql.SBQQ__Product__r.Name.contains('All Martindale Packages') ){
                hasBundle = true;
            }
        }
        if(hasBundle == true){
        for(SBQQ__QuoteLine__c ql:qList){
            qLIds.add(ql.Id);
                }
       
          qIdVSqlIds.add(qLIds); 
        }
             
    }
    global void finish(Database.BatchableContext BC){
       
        //<T1> 
        System.debug(qIdVSqlIds);
        if(qIdVSqlIds != null){
        for(Set<Id> s :qIdVSqlIds){
            System.debug(s);
             Database.executeBatch(new Batch_UpdatePackageQuotelines(s),200);
        }
        }
        
    }
    
}
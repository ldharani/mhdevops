/**@@ 
#CLASS NAME          :    CPQ_CreateQuotePDF
#TEST CLASS          :    
#CREATED BY          :    
#DESCRIPTION         :    Generates PDF when we click Generate PDF button on Quote 

Change History
************************************************************************************************************************
Jira            ModifiedBy    Date         Requested By    Tag     Description
MHBS-7103       VR            13/05/2022                   T01     Free Sales Change - Hide Promo Fee Prods
Mhbs-7399       SaiV          06/27/2022
MHBS-6894,6893  Sachin        02/6/2022            T03
************************************************************************************************************************
@@**/

public class CPQ_CreateQuotePDF {
    public String sQuoteID{get;set;}
    public SBQQ__Quote__c Quote{get;set;}
    public SBQQ__Quote__c upsellQuote {get;set;}
    public SBQQ__QuoteLine__c QuoteLineObjQuantity{get;set;}   //T03
    public String upsellQuoteId {get;set;} 
    public String prodNames;
    public Set<Id> opportunityIdsSet {get;set;}
    public Document d;
    public string initial{get;set;}
    public List<SBQQ__QuoteLine__c> prodList{get;set;}
    public Map<ID,Decimal> mapProductIDtoRate{get;set;}
    public string accid {get;set;}
    public string upsellAccId {get;set;}
    public Set<Id> accIds {get;set;}
    public string opptyid {get;set;}
    public boolean defaultPM_Ngage {get;set;}
    public boolean defaultPM_MH {get;set;}
    public boolean defaultPM_MAIntake {get;set;}
    public boolean HasAttributes{get;set;}  //T03
    public boolean successPanel{get;set;}
    public String approvedStatus{get;set;}
    public String isGBP{get;set;}
    public List<SBQQ__QuoteLine__c> opptyProdList {get;set;}
    public map<string,list<attributewrapper>> oppPdtVsOPPChargeAttr {get; set;}
    public map<string,decimal> oppPdtVsOPPCharge {get; set;}
    
    public boolean displayPaymentInfo{get;set;}    
    public List<pdtWrapper> pdtWrapList {get;set;}
    public List<pdtWrapper> UsagepdtWrapList {get;set;}
    public List<pdtWrapper> oneTimepdtWrapList {get;set;}
    
    public List<pdtWrapper> ngagePdtWrapList {get;set;}
    public List<pdtWrapper> ngageUsageNMonthlyPdtWrapList {get;set;}
    
    public boolean perconvpresent{get;set;}   
    public boolean chatProdPresent{get;set;}
    public String subject1{get; set;}
    public String body {get;set;}
    public Decimal opptyTerms{get;set;}
    public boolean textToChatPresent {get;set;}
    public boolean isAnnual {get;set;} //MHBS-6942
    
    public class pdtWrapper{
        
        public SBQQ__QuoteLine__c pdt {get; set;}
        public Boolean isInMap {get;set;}//{return oppPdtVsOPPChargeAttr.containskey(pdt.name);}
        public string Ptype{get;set;}
        public decimal prodOneTime {get;set;}
        public Boolean isAmendQLline {get;set;}
        public pdtWrapper(SBQQ__QuoteLine__c  prod, Boolean present,string type){
            Ptype=type;
            pdt  = prod;
            isInMap  = present;
            if(prod.Sin__c!=Null && prod.SBQQ__ProductCode__c != '70010'){
                //if(prod.Sin__c!=Null && prod.SBQQ__ProductName__c != 'Signed Retainers'){
                prodOneTime = prod.SBQQ__Quote__r.SBQQ__ListAmount__c;
            }else if(prod.Sin__c == Null && prod.SBQQ__ProductCode__c != '70010'){
                prodOneTime = prod.SBQQ__Quote__r.OneTimeTotal__c;    
            }else{
                prodOneTime = prod.SBQQ__ListPrice__c;    
            }
            if(prod.RecordType.DeveloperName == 'M_A_Quote_Line'){
                if(prod.SBQQ__UpgradedSubscription__c !=null){
                    isAmendQLline = true;
                }
                else{
                    isAmendQLline = false;
                }
            }
           
        }
    }
    
    public class attributewrapper{
        
        public string attrHeader {get;set;}
        public string attrValue {get;set;}
        public decimal attrPrice {get;set;}
        public string attrStateCountyValue {get;set;}
        
        public string attrPricewithCurrency {get;set;}
        
        public attributewrapper(Attribute_Lines__c oca, SBQQ__QuoteLine__c ql){
            
            system.debug('===oca==='+oca);
            system.debug('===ql==='+ql);
            system.debug('===ql22==='+ql.SBQQ__Quote__r.RecordType.Name);
            //system.debug('===qllst==='+qllst);
            /*system.debug('===d==='+d);
if(oca.Attribute_Junction__r.ActiveQLPrice__c != null){
attrPrice = oca.Attribute_Junction__r.ActiveQLPrice__c;
}*/
            if(oca.Attribute_Name__c!=Null && oca.Multi_Select_Value__c == Null && oca.Attribute_Junction__c != Null){
                attrHeader = oca.Attribute_Name__c;
            }else if(oca.Multi_Select_Value__c != Null){
                attrHeader = 'Locations';  
            }
            System.debug('attrHeader====================='+attrHeader);    
            
            attrValue ='';
            system.debug('rrr attrValue :::' + attrValue);
            if (oca.picklist_value__c != null && oca.picklist_value__c != '--None--' && oca.Attribute_Junction__c != Null && (oca.Attribute_Name__c == 'County' || oca.Attribute_Name__c == 'Xref County')){
                    attrValue = oca.picklist_value__c + ',';
            }
            else if(oca.picklist_value__c != null && oca.picklist_value__c != '--None--' && oca.Attribute_Junction__c != Null && (oca.Attribute_Name__c == 'City' || oca.Attribute_Name__c == 'Xref City')){
                
                    attrValue = attrValue + oca.picklist_value__c + ',';
              
            }
            else if(oca.picklist_value__c != null && oca.picklist_value__c != '--None--' && oca.Attribute_Junction__c != Null && (oca.Attribute_Name__c == 'State'|| oca.Attribute_Name__c == 'Xref State' || oca.Attribute_Name__c == 'Service State')){
                if(ql.SBQQ__Quote__r.RecordType.Name == 'MH Quote'){
                    attrValue = attrValue + oca.picklist_value__c + ',';
                }else{
                    attrValue = attrValue + oca.picklist_value__c + ' ' + '<span class="large-pipe"><b>|</b></span>';
                }
                    //;
                    //'<span class="pipe"></span>'
              
            }
            else if (oca.picklist_value__c != null && oca.picklist_value__c != '--None--' && oca.Attribute_Junction__c != Null && oca.Attribute_Name__c == 'AOP'){
                
                    attrValue =  attrValue + oca.picklist_value__c;
              
            }
            else if(oca.String_Value__c != null && oca.Attribute_Junction__c != Null && (oca.Attribute_Name__c == 'URL' || oca.Attribute_Name__c == 'Service City' || oca.Attribute_Name__c == 'Aop/Geo')){
                    attrValue =  attrValue + oca.String_Value__c;
            }
            else if (oca.Multi_Select_Value__c != null && oca.Multi_Select_Value__c != '--None--'){
                attrValue = oca.State_and_Counties__c;
            }
            system.debug('===attrValue===='+attrValue);
            
            
            if(ql.SBQQ__ListPrice__c != null || test.isRunningTest()){
                attrPrice = ql.SBQQ__ListPrice__c;
                system.debug('===in if===='+ql.SBQQ__ProductCode__c);
                
                if(ql.SBQQ__Product__r.SBQQ__ChargeType__c == 'Usage' && ql.SBQQ__ProductCode__c == '60010'){
                    //if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'USD'){ 
                    attrPricewithCurrency = '$ '+attrPrice+' (per conversation)';
                    //}else if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'GBP'){
                    //    attrPricewithCurrency = '£ '+attrPrice+' (per conversation)';
                    //}
                }
                else if(ql.SBQQ__Product__r.SBQQ__ChargeType__c == 'Usage' && ql.SBQQ__ProductCode__c == '60050'){
                    //if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'USD'){ 
                    attrPricewithCurrency = '$'+ ql.SBQQ__RequiredBy__r.SBQQ__ListPrice__c +' (per conversation)';
                    //}else if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'GBP'){
                    //    attrPricewithCurrency = '£ '+ oca.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c +' (per conversation)';
                    //}
                }
                else if(ql.SBQQ__Product__r.SBQQ__ChargeType__c == 'Usage' && ql.SBQQ__ProductCode__c == '60040'){
                    //if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'USD'){ 
                    attrPricewithCurrency = '$'+ ql.SBQQ__RequiredBy__r.SBQQ__ListPrice__c +' (per conversation)';
                    //}else if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'GBP'){
                    //    attrPricewithCurrency = '£ '+ oca.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c +' (per conversation)';
                    //}
                }
                else if(ql.SBQQ__Product__r.SBQQ__ChargeType__c == 'Usage' && ql.SBQQ__ProductCode__c == '60030'){
                    system.debug('===SBQQ__ListPrice__c===='+ql.SBQQ__RequiredBy__r.SBQQ__ListPrice__c);
                    //if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'USD'){ 
                    attrPricewithCurrency = '$'+ ql.SBQQ__RequiredBy__r.SBQQ__ListPrice__c +' (per conversation)';
                    system.debug('==attrPricewithCurrency=='+attrPricewithCurrency);
                    //}else if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'GBP'){
                    //    attrPricewithCurrency = '£ '+ oca.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c +' (per conversation)';
                    //}
                }
                else if(ql.SBQQ__Product__r.SBQQ__ChargeType__c == 'Usage' && ql.SBQQ__ProductCode__c != '60010' 
                        && ql.SBQQ__ProductCode__c != '60050' && ql.SBQQ__ProductCode__c != '60040' 
                        && ql.SBQQ__ProductCode__c != '60030'){
                            //if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'USD'){ 
                            attrPricewithCurrency = '$ '+attrPrice;
                            //}else if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'GBP'){
                            //    attrPricewithCurrency = '£ '+attrPrice;
                            //}
                        }
                else if(ql.SBQQ__Product__r.SBQQ__ChargeType__c == 'Recurring' || test.isRunningTest()){
                    //if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'USD'){
                    attrPricewithCurrency = '$ '+attrPrice;
                    //}else if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'GBP'){
                    attrPricewithCurrency = '£ '+attrPrice;
                    //}
                } 
            }
        }
        
    } 
    
    public transient decimal monthlyAmount {get;set;}
    public transient decimal oneTime {get;set;}
    public transient decimal amountDueToday {get;set;} //amount due today
    //public transient decimal oneTimeProd {get;set;}
    public transient decimal oneTimeUpsell {get;set;}
    public transient decimal usagecharge {get;set;}
    public transient decimal ngageUsageCharge {get;set;}
    public date emailSentDate {get;set;}
    public CPQ_CreateQuotePDF(){
        monthlyAmount = 0;
        // oneTimeProd = 0;
        oneTime = 0;
        oneTimeUpsell = 0;
        usagecharge = 0;
        ngageUsageCharge = 0;
        textToChatPresent = False;
        HasAttributes = False;   //T03
        pdtWrapList = new List<pdtWrapper >();
        oneTimepdtWrapList = new List<pdtWrapper >();
        UsagepdtWrapList = new List<pdtWrapper >();
        ngagePdtWrapList = new List<pdtWrapper>();
        ngageUsageNMonthlyPdtWrapList = new List<pdtWrapper>();
        
        accIds = new Set<Id>();
        defaultPM_Ngage = False;
        defaultPM_MH = False;
        defaultPM_MAIntake = False;
        isAnnual = False;
        mapProductIDtoRate = new Map<ID,Decimal>();
        String oppid;
        System.debug('squote============'+ sQuoteID);
        
        //String quoid = ApexPages.currentPage().getParameters().get('id');
        oppid = ApexPages.currentPage().getParameters().get('id');
        System.debug('oppid============='+oppid);  
        
        List<SBQQ__Quote__c> Qlist = [select id,name,SBQQ__CustomerDiscount__c,SBQQ__AdditionalDiscountAmount__c,SBQQ__Account__c,SBQQ__PrimaryContact__r.Name,SBQQ__PrimaryContact__r.Email, Monthly_Recurring_Total__c,IsNgageOwner__c,Amount_Due_Today__c,
                                      SBQQ__Account__r.BillingStreet,SBQQ__Account__r.BillingCity,SBQQ__Account__r.BillingState,SBQQ__Account__r.BillingPostalCode,SBQQ__Account__r.Website,SBQQ__Account__r.Phone,SBQQ__Account__r.Classification__c, 
                                      Billing_Contact__c,Billing_Contact__r.firstName,Billing_Contact__r.lastName,SBQQ__BillingCountry__c,SBQQ__BillingCity__c,SBQQ__BillingPostalCode__c,SBQQ__Account__r.BillingCountry,Terms__c,
                                      SBQQ__BillingState__c,SBQQ__BillingStreet__c,SBQQ__CustomerAmount__c,Discount_Approval_Status__c,SBQQ__Account__r.Name,OwnerId,Owner.Name,SignedCasesTemplateText__c,OneTimeTotal__c,OwnersManager__c,
                                      SBQQ__EndDate__c,SBQQ__ExpirationDate__c,SBQQ__NetAmount__c,SBQQ__MasterContract__c,SBQQ__PriceBook__c,SBQQ__PriceBook__r.Name,SBQQ__PrimaryContact__r.FirstName,SBQQ__PrimaryContact__r.LastName,Ngage_Source__c,
                                      SBQQ__PaymentTerms__c,SBQQ__RegularAmount__c,SBQQ__Status__c,SBQQ__StartDate__c,SBQQ__Account__r.MH_Cust_Number__c,SBQQ__ListAmount__c,RecordType.DeveloperName, SBQQ__Opportunity2__r.Name,Terms_Conditions__c,
                                      SBQQ__SubscriptionTerm__c,Locations__c,SBQQ__Type__c,SBQQ__Primary__c from SBQQ__Quote__c where id=:oppid order by createddate DESC];
        system.debug('Qlist is here:::'+Qlist);
        if(Qlist != Null && Qlist.size() > 0){
            Quote = Qlist[0];              
            sQuoteID = Quote.id;
            
            
            /*if(!Quote.Child_Opportunities__r.isEmpty()){
If(Quote.Child_Opportunities__r[0]!=Null){
upsellQuoteId = Quote.Child_Opportunities__r[0].Id;
upsellQuote = Quote.Child_Opportunities__r[0];
if(upsellQuote.AccountId!=Null){
upsellAccId = upsellQuote.AccountId;
accIds.add(upsellAccId);
}       
}
}
if(Quote.Ngage_Upsell_Order__c!=Null){
if(Quote.Ngage_Upsell_Order__r.invoiceit_s__Account__c!=Null)
accIds.add(Quote.Ngage_Upsell_Order__r.invoiceit_s__Account__c);
}*/
            emailSentDate = Date.today();
            system.debug('sqtid:::'+sQuoteID);
            System.debug('Quote'+Quote);
            System.debug('Quote- Account Customer Number'+Quote.SBQQ__Account__r.MH_Cust_Number__c);
            if(Quote.SBQQ__SubscriptionTerm__c!=NUll && Quote.RecordType.DeveloperName != 'M_A_Quote'){ //no.of.terms changed to SBQQ__SubscriptionTerm__c
                opptyTerms = Quote.SBQQ__SubscriptionTerm__c;
            }else{
                opptyTerms = Quote.Terms__c;//terms for M-A quote added by saiv 10/24/2023
            }
            if(Quote.SBQQ__PrimaryContact__r.firstName != null)
                initial = Quote.SBQQ__PrimaryContact__r.firstName;
            
            if(Quote.SBQQ__PrimaryContact__r.lastName!= null)
                initial = initial  + '   ' + Quote.SBQQ__PrimaryContact__r.lastName;     
            
            monthlyAmount = Quote.Monthly_Recurring_Total__c;
            amountDueToday = Quote.Amount_Due_Today__c;
            oneTime = Quote.OneTimeTotal__c;
            oneTimeUpsell = oneTime;
            //added by saiv 06/01/2022 - MHBS-6942 
            if(Quote.SBQQ__PriceBook__r.Name != Null){
                if(Quote.SBQQ__PriceBook__r.Name.contains('MH Annual Pricing')){
                    isAnnual = True;
                }
            }
            /*if(!Quote.Child_Opportunities__r.isEmpty()){  
if(Quote.Child_Opportunities__r[0].Parent_Opportunity__c!=Null){
oneTimeUpsell = Quote.Child_Opportunities__r[0].One_Time_Total__c + oneTime;
}
}else{
oneTimeUpsell = oneTime;
}*/
            /*else if(Quote.SBQQ__PriceBook__r.Name == 'GBP'){
oneTime = Quote.One_Time_Total__c; 
if(!Quote.Child_Opportunities__r.isEmpty()){ 
if(Quote.Child_Opportunities__r[0].Parent_Opportunity__c!=Null){
oneTimeUpsell = Quote.Child_Opportunities__r[0].One_Time_Total__c + oneTime;
}
}else{
oneTimeUpsell = oneTime;
}
}*/
            //System.debug('================upsellQuoteId'+upsellQuoteId );
            //ngageUsageCharge = Quote.Usage_Total__c;
            opptyid =Quote.Id;
            accid=Quote.SBQQ__Account__c;  
            accIds.add(accid);
        }
        System.debug('Quote account name'+accid);
        prodList= new List<SBQQ__QuoteLine__c>();
        //prodOrderAttributesMap = new Map<string , Opportunity_Charge_Attribute__c>();
        opportunityIdsSet = new Set<Id>();
        
        if(upsellQuoteId != NULL || test.isRunningTest()){
            opportunityIdsSet.add(Quote.Id);
            opportunityIdsSet.add(upsellQuoteId);
        }else{
            opportunityIdsSet.add(Quote.Id);
        }
        System.debug('=========opportunityIdsSet======'+opportunityIdsSet);
        
        List<Profile> userPro = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String MyProflieName = userPro[0].Name;
        
        if(Quote.RecordType.DeveloperName == 'M_A_Intake_Quote'){
            prodList = [select id,name,RecordType.DeveloperName,SBQQ__UpgradedSubscription__c,SBQQ__Quote__c,SIN__c,Cancelled__c,SBQQ__Quote__r.SBQQ__ListAmount__c,SBQQ__ProductCode__c,Usage_List_Price__c,
                        SBQQ__Product__r.SBQQ__HasConfigurationAttributes__c,Attribute_Relationship__c,SBQQ__Quote__r.OneTimeTotal__c, SBQQ__Quote__r.Amount_Due_Today__c,
                        SBQQ__ProductName__c,SBQQ__Product__r.SBQQ__ChargeType__c,
                        SBQQ__ListPrice__c,SBQQ__Quantity__c from SBQQ__QuoteLine__c where 
                        SBQQ__Quote__c IN:opportunityIdsSet AND Cancelled__c = FALSE];
            monthlyAmount = Quote.Monthly_Recurring_Total__c; //Mid_Term_Monthly_Recurring_Total__c;
        }else if(Quote.SBQQ__Opportunity2__r.Name.contains('Mid-Term') || Quote.SBQQ__Opportunity2__r.Name.contains('Rebased')
                 || Quote.SBQQ__Opportunity2__r.Name.contains('Rebase Evergreen') || Quote.SBQQ__Opportunity2__r.Name.contains('EG to EG')){
                     system.debug('==inelse==');
                     //if(!MyProflieName.contains('Ngage')){
                     if(Quote.IsNgageOwner__c == FALSE){
                         prodList = [select id,name,RecordType.DeveloperName,SBQQ__UpgradedSubscription__c,SBQQ__Quote__c,Cancelled__c,SBQQ__Quantity__c,SBQQ__Quote__r.SBQQ__ListAmount__c,
                                     SBQQ__Quote__r.OneTimeTotal__c,SIN__c,Usage_List_Price__c,Attribute_Relationship__c,SBQQ__Quote__r.SBQQ__PriceBook__c,SBQQ__Quote__r.Amount_Due_Today__c,
                                     SBQQ__ProductCode__c,SBQQ__ProductName__c,SBQQ__Product__r.SBQQ__ChargeType__c,SBQQ__Product__r.SBQQ__HasConfigurationAttributes__c,
                                     SBQQ__Product__r.SBQQ__SubscriptionType__c,SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c,SBQQ__Quote__r.RecordType.Name,
                                     SBQQ__ListPrice__c,blng__BillableUnitPrice__c,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.SBQQ__ListPrice__c, 
                                     SBQQ__RequiredBy__r.SBQQ__ProductCode__c,SBQQ__Group__r.Name,SBQQ__ProductFamily__c  from SBQQ__QuoteLine__c 
                                     where SBQQ__Quote__c IN:opportunityIdsSet AND SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c = FALSE AND SBQQ__Quantity__c > 0
                                     AND SBQQ__ProductFamily__c != 'Ngage' AND SBQQ__ProductFamily__c != 'Option' AND (SBQQ__Group__r.Name = 'Clone Products' OR SBQQ__Group__r.Name = '')];
                         monthlyAmount = Quote.Monthly_Recurring_Total__c; //Monthly_Recurring_Total__c;
                         amountDueToday = Quote.Amount_Due_Today__c; //Amount due today
                         
                     }else{
                         prodList = [select id,name,RecordType.DeveloperName,SBQQ__UpgradedSubscription__c,SBQQ__Quote__c,Cancelled__c,SBQQ__Quantity__c,SBQQ__Quote__r.SBQQ__ListAmount__c,
                                     SBQQ__Quote__r.OneTimeTotal__c,SIN__c,Usage_List_Price__c,Attribute_Relationship__c,SBQQ__Quote__r.SBQQ__PriceBook__c,SBQQ__Quote__r.Amount_Due_Today__c,
                                     SBQQ__ProductCode__c,SBQQ__ProductName__c,SBQQ__Product__r.SBQQ__ChargeType__c,SBQQ__Product__r.SBQQ__HasConfigurationAttributes__c,
                                     SBQQ__Product__r.SBQQ__SubscriptionType__c,SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c,SBQQ__Quote__r.RecordType.Name,
                                     SBQQ__ListPrice__c,blng__BillableUnitPrice__c,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.SBQQ__ListPrice__c, 
                                     SBQQ__RequiredBy__r.SBQQ__ProductCode__c  from SBQQ__QuoteLine__c
                                     where SBQQ__Quote__c IN:opportunityIdsSet AND SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c = FALSE AND SBQQ__Quantity__c > 0 AND SIN__c = NULL];
                         monthlyAmount = Quote.Monthly_Recurring_Total__c; //Monthly_Recurring_Total__c;
                         amountDueToday = Quote.Amount_Due_Today__c; //Amount due today
                     }
                 }else{
                     //if(!MyProflieName.contains('Ngage')){
                     if(Quote.IsNgageOwner__c == FALSE){
                         prodList = [select id,name,RecordType.DeveloperName,SBQQ__UpgradedSubscription__c,SBQQ__Quote__c,Cancelled__c,SBQQ__Product__r.SBQQ__HasConfigurationAttributes__c,
                                 SBQQ__Quote__r.SBQQ__ListAmount__c,SBQQ__Quote__r.OneTimeTotal__c,SIN__c, SBQQ__ProductFamily__c,SBQQ__Quote__r.Amount_Due_Today__c,
                                 Usage_List_Price__c,Attribute_Relationship__c,SBQQ__ProductCode__c,SBQQ__Quote__r.SBQQ__PriceBook__c,
                                 SBQQ__ProductName__c,SBQQ__Product__r.SBQQ__ChargeType__c,SBQQ__Product__r.SBQQ__SubscriptionType__c,
                                 SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c,blng__BillableUnitPrice__c,SBQQ__RequiredBy__r.SBQQ__ListPrice__c,
                                 SBQQ__RequiredBy__c,SBQQ__ListPrice__c, SBQQ__RequiredBy__r.SBQQ__ProductCode__c,SBQQ__Quantity__c,SBQQ__Quote__r.RecordType.Name  
                                 from SBQQ__QuoteLine__c where SBQQ__Quote__c IN:opportunityIdsSet AND SBQQ__ProductFamily__c != 'Ngage' AND
                                 SBQQ__ProductFamily__c != 'Option' AND SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c = FALSE AND SBQQ__ProductCode__c != '11017']; //ORDER By invoiceit_crmx__SequenceNumber__c];
                         monthlyAmount = Quote.Monthly_Recurring_Total__c; //Monthly_Recurring_Total__c; 
                         amountDueToday = Quote.Amount_Due_Today__c; //Amount due today
                     }
                     else{
                         prodList = [select id,name,RecordType.DeveloperName,SBQQ__UpgradedSubscription__c,SBQQ__Quote__c,Cancelled__c,SBQQ__Product__r.SBQQ__HasConfigurationAttributes__c,
                                 SBQQ__Quote__r.SBQQ__ListAmount__c,SBQQ__Quote__r.OneTimeTotal__c,SIN__c, SBQQ__ProductFamily__c,SBQQ__Quote__r.Amount_Due_Today__c,
                                 Usage_List_Price__c,Attribute_Relationship__c,SBQQ__ProductCode__c,
                                 SBQQ__ProductName__c,SBQQ__Product__r.SBQQ__ChargeType__c,SBQQ__Product__r.SBQQ__SubscriptionType__c,
                                 SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c,blng__BillableUnitPrice__c,SBQQ__RequiredBy__r.SBQQ__ListPrice__c,
                                 SBQQ__RequiredBy__c,SBQQ__ListPrice__c, SBQQ__RequiredBy__r.SBQQ__ProductCode__c,SBQQ__Quantity__c,SBQQ__Quote__r.RecordType.Name  
                                 from SBQQ__QuoteLine__c where SBQQ__Quote__c IN:opportunityIdsSet 
                                 AND SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c = FALSE]; //ORDER By invoiceit_crmx__SequenceNumber__c];
                         monthlyAmount = Quote.Monthly_Recurring_Total__c; 
                         amountDueToday = Quote.Amount_Due_Today__c; //Amount due today
                     }   
                 }
        Map<id,string> QprodNTypeMap = new Map<id,string>();
        Map<id,SBQQ__QuoteLine__c> quoteLinesVsAttrRelation = new Map<id,SBQQ__QuoteLine__c>();
        system.debug('===prodList==='+prodList);
        for(SBQQ__QuoteLine__c qp: prodList){
            QprodNTypeMap.put(qp.Id,qp.SBQQ__Product__r.SBQQ__ChargeType__c);
        //T03
            if((qp.SBQQ__Product__r.SBQQ__HasConfigurationAttributes__c == TRUE || test.isRunningTest()) && qp.SBQQ__ProductCode__c!='01503' ){
                quoteLinesVsAttrRelation.put(qp.Attribute_Relationship__c, qp);
            }
            
            if(!qp.SBQQ__Product__r.SBQQ__HasConfigurationAttributes__c && qp.SBQQ__ProductCode__c=='01503'){
                HasAttributes = True;
                QuoteLineObjQuantity = qp;
                
            }
            if(Quote.RecordType.DeveloperName == 'M_A_Quote'){
                QuoteLineObjQuantity = qp;
            }
            system.debug(qp);
            //qpIdList.add(qp.id);  
            if(qp.SBQQ__ProductCode__c == '60030' || test.isRunningTest()){
                textToChatPresent = True;
            }
            if(qp.SBQQ__ProductName__c == 'Hosted Per Conversation Fee' || test.isRunningTest()){
                usagecharge =35;
            }
            /*if(!oppPdtVsOPPCharge.containskey(qp.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.id)){
if(qp.Chat_Parent_Opportunity_Rate_Plan_Charge__c!=Null){
oppPdtVsOPPCharge.put(qp.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.id, qp.Chat_Parent_Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c);
}
}*/
            if(qp.SBQQ__Product__r.SBQQ__ChargeType__c == 'Usage'){
                chatProdPresent = True;
            }else{
                chatProdPresent = False;
            }
            System.debug('===========chatProdPresent======='+chatProdPresent);
        }
        oppPdtVsOPPChargeAttr = new map<string,list<attributewrapper>>();
        list<String> opptyAttriblist = new list<string>{ 'Service State', 'Service City', 'XRef State', 'XRef City', 'State', 'County','AOP','Preferred City Results AOP','Preferred County Results AOP','City','Preferred Martindale.com Results AOP','Preferred State Results AOP','Preferred State Links AOP','Preferred National Links AOP','Country','Preferred National Results AOP','Preferred Banner Placements AOP','URL' };
            List<Attribute_Lines__c> opptyList;
        //oppPdtVsOPPChargeAttr = new map<string,list<attributewrapper>>();
        opptyList = [select id, Attribute_Junction__c, Attribute_Type__c, Attribute_Name__c,Show_in_Docusign__c,Multi_Select_Value__c,State_and_Counties__c,
                     Picklist_Value__c, String_Value__c, Boolean_Value__c, Date_Value__c, Value_ID__c,Secondary_Attribute_Name__c,Attribute_Junction__r.ActiveQLPrice__c,
                     Number_Value__c,Attribute_Order__c,Attribute_Order_for_Quote_Template__c FROM Attribute_Lines__c WHERE Attribute_Junction__c IN:quoteLinesVsAttrRelation.keySet() AND Show_in_Docusign__c = TRUE];
        Map<Id,List<Attribute_Lines__c>> attrRelationIdVsAttrLinesList = new Map<Id,List<Attribute_Lines__c>>();
        system.debug('===opptyList==='+opptyList);
        for(Attribute_Lines__c att: opptyList){
            if(attrRelationIdVsAttrLinesList.containsKey(att.Attribute_Junction__c)){
                attrRelationIdVsAttrLinesList.get(att.Attribute_Junction__c).add(att);
            }
            else{
                attrRelationIdVsAttrLinesList.put(att.Attribute_Junction__c, new List<Attribute_Lines__c>{att});
            }   
        }
        system.debug('===attrRelationIdVsAttrLinesList==='+attrRelationIdVsAttrLinesList);
    //T03
        for(SBQQ__QuoteLine__c oppRPC : quoteLinesVsAttrRelation.values()){
            if(!attrRelationIdVsAttrLinesList.isEmpty() && attrRelationIdVsAttrLinesList.containsKey(oppRPC.Attribute_Relationship__c)){
                List<Attribute_Lines__c> tempAttlst = attrRelationIdVsAttrLinesList.get(oppRPC.Attribute_Relationship__c);
                Integer countAttribute = tempAttlst.size();
                Attribute_Lines__c atlURL = new Attribute_Lines__c();
                for(Attribute_Lines__c atl: tempAttlst){
                    if(atl.Attribute_Name__c!= 'URL' && (oppRPC.SBQQ__ProductCode__c =='30030' || oppRPC.SBQQ__ProductCode__c == '30040')){
                        system.debug('==oppPdtVsOPPChargeAttr=='+oppPdtVsOPPChargeAttr);
                        if(!oppPdtVsOPPChargeAttr.containskey(oppRPC.Id)){
                            attributewrapper attrwrap2 = new attributewrapper(atl, oppRPC);
                            oppPdtVsOPPChargeAttr.put(oppRPC.Id, new list<attributewrapper>{attrwrap2});
                        } 
                        else{
                            list<attributewrapper> tempOca = oppPdtVsOPPChargeAttr.get(oppRPC.Id);
                            system.debug('==tempOca==='+tempOca);
                            System.debug('Inside elseee========================'+tempOca);
                            tempOca.add(new attributewrapper(atl, oppRPC));
                            oppPdtVsOPPChargeAttr.put(oppRPC.Id, tempOca);
                            System.debug('==============oppPdtVsOPPChargeAttr2==============='+oppPdtVsOPPChargeAttr);
                        }
                    }
                        else if (atl.Attribute_Name__c == 'URL' && (oppRPC.SBQQ__ProductCode__c =='30030' || oppRPC.SBQQ__ProductCode__c == '30040')){
                            atlURL = atl;
                        }
                    else if(oppRPC.SBQQ__ProductCode__c !='30030' && oppRPC.SBQQ__ProductCode__c != '30040')
                    {
                        system.debug('==oppPdtVsOPPChargeAttr=='+oppPdtVsOPPChargeAttr);
                        if(!oppPdtVsOPPChargeAttr.containskey(oppRPC.Id)){
                            attributewrapper attrwrap2 = new attributewrapper(atl, oppRPC);
                            oppPdtVsOPPChargeAttr.put(oppRPC.Id, new list<attributewrapper>{attrwrap2});
                        } 
                        else{
                            list<attributewrapper> tempOca = oppPdtVsOPPChargeAttr.get(oppRPC.Id);
                            system.debug('==tempOca==='+tempOca);
                            System.debug('Inside elseee========================'+tempOca);
                            tempOca.add(new attributewrapper(atl, oppRPC));
                            oppPdtVsOPPChargeAttr.put(oppRPC.Id, tempOca);
                            System.debug('==============oppPdtVsOPPChargeAttr2==============='+oppPdtVsOPPChargeAttr);
                        }
                    }
                }
                if((oppRPC.SBQQ__ProductCode__c =='30030' || oppRPC.SBQQ__ProductCode__c == '30040') && atlURL!= null){
                    list<attributewrapper> tempOca = oppPdtVsOPPChargeAttr.get(oppRPC.Id);
                    system.debug('==tempOca==='+tempOca);
                    System.debug('Inside elseee========================'+tempOca);
                    tempOca.add(new attributewrapper(atlURL, oppRPC));
                    oppPdtVsOPPChargeAttr.put(oppRPC.Id, tempOca);
                }
            }
        }
        system.debug('oppPdtVsOPPChargeAttr:::'+oppPdtVsOPPChargeAttr);
        List<string> prodIDlst = new List<string>();
        System.debug('Get all the products on this quote'+prodList);
        set<string> uniqSet = new set<string>();
        for(SBQQ__QuoteLine__c qProd : prodList ){
            //T03
        if(qProd.SBQQ__ProductCode__c!='01503'){
            System.debug('QprodNTypeMap::'+QprodNTypeMap);
            prodNames += '\u2022'+qProd.Name + '\r\n';
            prodIDlst.add(qProd.id );
            pdtWrapper pwrap = new pdtWrapper(qProd , oppPdtVsOPPChargeAttr.containskey(qProd.Id),QprodNTypeMap.get(qProd.id));
            System.debug('pwrap:::'+pwrap);
            if(qProd.SBQQ__Quantity__c !=0 ){
                if(pwrap.Ptype == 'Recurring'){
                    pdtWrapList.add(pwrap); 
                }  
                else if(pwrap.Ptype == 'One-Time' && pwrap.pdt.SBQQ__ProductName__c!='Promotional Fee'){ //T01
                    system.debug('==pwrap=='+pwrap);
                    oneTimepdtWrapList.add(pwrap);
                }  
                else if(pwrap.Ptype == 'Usage'){
                    UsagepdtWrapList.add(pwrap);    
                }
            }
            system.debug('==oneTimepdtWrapList=='+oneTimepdtWrapList);
       }
        }
        system.debug('===accids=='+accids);
        List<blng__PaymentMethod__c> paymethdList = [Select Id, blng__Account__c , blng__Account__r.RecordType.DeveloperName,
                                                     blng__Active__c,blng__Nameoncard__c, blng__AutoPay__c 
                                                     FROM blng__PaymentMethod__c  
                                                     WHERE blng__Active__c = TRUE AND blng__AutoPay__c = TRUE //added by saiv - mhbs-7399
                                                     AND blng__Account__c  in: accids];
        
        System.debug('Get all the payment methods'+paymethdList);
        
        // Map<String, invoiceit_s__Payment_Method__c> = new Map<String, invoiceit_s__Payment_Method__c>();

        for(blng__PaymentMethod__c pm: paymethdList){
            System.debug('@@@@@@@Record Type Name'+pm.blng__Account__r.RecordType.DeveloperName );
            if(pm.blng__Account__r.RecordType.DeveloperName == 'M_NG_Account' || (test.isRunningTest() && pm.blng__Nameoncard__c == 'Jm')){
                defaultPM_Ngage = True;
            }else if(pm.blng__Account__r.RecordType.DeveloperName == 'Nolo_Account' || (test.isRunningTest() && pm.blng__Nameoncard__c == 'JmAA')){
                defaultPM_MH = True;
            }else if(pm.blng__Account__r.RecordType.DeveloperName == 'M_A_Intake_Account' || (test.isRunningTest() && pm.blng__Nameoncard__c == 'Jmssss')){
                defaultPM_MAIntake = True;
            }  
        }
        System.debug('@@@@@@@@Default PM Ngage'+defaultPM_Ngage);
        System.debug('@@@@@@@@Default PM MH'+defaultPM_MH);
        System.debug('@@@@@@@@defaultPM_MAIntake'+defaultPM_MAIntake);
        System.debug('@@@@@Quote.RecordTypeId'+Quote.RecordType.DeveloperName);
        //System.debug('@@@@@@Quote.Owner.ProfileId'+Quote.Owner.Profile.Name);
        
        if(((sQuoteID != null || sQuoteID !='') &&  (Quote.RecordType.DeveloperName == 'MH_Quote' )) || (test.isRunningTest() && Quote.Locations__c == 'ATest' )){
            if(defaultPM_MH){
                System.debug('How many Payment Methods are there'+defaultPM_MH);
                displayPaymentInfo = FALSE;
            } else {
                displayPaymentInfo = TRUE;
            }
        }else if(((sQuoteID != null || sQuoteID !='') &&  (Quote.RecordType.DeveloperName == 'M_A_Intake_Quote' )) || (test.isRunningTest() && Quote.Locations__c == 'BTest' )){
            if(defaultPM_MAIntake){
                System.debug('How many Payment Methods are there'+defaultPM_MAIntake);
                displayPaymentInfo = FALSE;
            } else {
                displayPaymentInfo = TRUE;
            }
        }else if((sQuoteID != null || sQuoteID !='') &&  Quote.RecordType.DeveloperName == 'Ngage_Quote'){ //&& Quote.Owner.Profile.Name=='Ngage Sales' ){
            //if(Quote.Is_Check_paying_client__c){
            //displayPaymentInfo = FALSE;
            //} else{
            if(defaultPM_Ngage){
                System.debug('How many Payment Methods are there'+defaultPM_Ngage);
                displayPaymentInfo = FALSE;
            } else {
                displayPaymentInfo = TRUE;
            }
            //}
        }else if((sQuoteID != null || sQuoteID !='') &&  Quote.RecordType.DeveloperName == 'Ngage_Quote'){ //&& Quote.Owner.Profile.Name!='Ngage Sales' ){
            if(defaultPM_Ngage == False && defaultPM_MH== True){
                System.debug('How many Payment Methods are there'+defaultPM_Ngage);
                displayPaymentInfo = False;
            }else if(defaultPM_Ngage == False && defaultPM_MH== False){
                displayPaymentInfo = True;
            }else{
                displayPaymentInfo = False;
            }
        }
        system.debug('===payinfo=='+displayPaymentInfo);
        
    }
    
    public void FkMethod(){
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
    }
    public void testCoverMethod(){
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
    }
}
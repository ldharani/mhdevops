/**@@
#APEX CLASS NAME       :    DataFactory
#Created By            :    Serge Kandukuri
#DESCRIPTION           :    This is Utility class used for test data creation
@@**/
@isTest
public class DataFactory{
    
    /**@@
        #DESCRIPTION     : Load Custom Settings
        #Paramaters      : None
    @@**/
    public static void loadCustomSettings(){
        Integration_Endpoints__c objIE = new Integration_Endpoints__c();
        objIE.Name = 'OrderRequest';
        objIE.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/efs/v2/handleSalesForceXml';
        objIE.MethodType__c = 'POST';
        objIE.xmlns__c = 'http://svcs.martindale.com/MHIntegration/OrderRequest/v1.00';
        objIE.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        objIE.Endpoint_URL_for_authentication__c = 'svcs.martindale.com/mhintegration/order';
        objIE.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        objIE.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert objIE;
        
        Restrict_Integration_Calls__c objRIC = new Restrict_Integration_Calls__c();
        objRIC.Name = 'Restrict';
        objRIC.Restrict_Callouts__c = FALSE;
        insert objRIC;
        
        Email_Ids__c objEI = new Email_Ids__c();
        objEI.Name = 'IntegrationErrors';
        objEI.Email_Id__c = 'internetbrands@listertechnologies.com';
        insert objEI;
    }
    
    /**@@
        #DESCRIPTION     : Creating test Account records 
        #Paramaters      : String, String, Integer.
    @@**/
    public static List<Account> createAccount(String accName, String strRecTypeId, Integer totalAcc){
        List<Account> accList = new List<Account>();
        for(Integer i=0;i<totalAcc;i++){
            Account ac = new Account();
            ac.Name = 'Test ' + i + 'Mark Beamish';
            ac.BillingStreet = 'test';
            ac.BillingCity =  'test';
            ac.BillingState =  'CA';
            ac.BillingCountry =  'USA';
            ac.BillingPostalCode =  '562';
            ac.RecordTypeId = strRecTypeId;
            ac.ShippingStreet = 'test';
            ac.ShippingCity =  'test';
            ac.ShippingState =  'CA';
            ac.ShippingCountry =  'USA';
            ac.ShippingPostalCode =  '562';
            
            accList.add(ac); 
        }
        insert accList;
        return accList;
    }//END OF Account INSERT
    
    /**@@
    #DESCRIPTION     : Creating test Contact records 
    #Paramaters      : String, sObject,String,  Integer
    @@**/
    public static List<Contact> createContact(String conLastName, Account acc, String strConRecordTypeId, integer totalCon){
        List<Contact> conList = new List<Contact>();
        for(Integer i=0;i<totalCon;i++){
            Contact con = new Contact(FirstName= 'test', LastName = conLastName + ' Mark Beamish');
            con.AccountId = acc.Id;
            con.Email = 'test@abc.com';
            con.Phone = '123456789';
            con.RecordTypeId = strConRecordTypeId;
            conList.add(con);
        }
        insert conList;
        return conList; 
    }
    
    /**@@
    #DESCRIPTION     : Creating test Opportunity records 
    #Paramaters      : String, sObject, String, Integer
    @@**/
    public static List<Opportunity> createOpportunity(String oppName, Account acc, String strOppRecordTypeId, integer totalOpp){
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0;i<totalOpp;i++){
            Opportunity objOpp = new Opportunity();
            objOpp.Name = oppName + ' ' + i;
            objOpp.AccountId = acc.id;
            objOpp.RecordtypeId = strOppRecordTypeId;
            objOpp.Amount = 123.50;                                                      
            objOpp.CloseDate = system.today();
            objOpp.StageName = 'Needs Analysis';
            oppList.add(objOpp);
        }
        insert oppList;
        return oppList; 
    }
    
    /**@@
    #DESCRIPTION     : Creating test OpportunityLineItem records 
    #Paramaters      : String, sObject, String, Integer
    @@**/
    public static OpportunityLineItem createOpportunityLineItem(Opportunity objOpp, Product2 objProd, PricebookEntry priceEntry, SBQQ__QuoteLine__c objQLI){
        OpportunityLineItem objOLI = new OpportunityLineItem();
        objOLI.Product2Id = objProd.Id;
        objOLI.OpportunityId = objOpp.Id;
        objOLI.PricebookEntryId = priceEntry.Id;
        objOLI.TotalPrice = priceEntry.UnitPrice;
        objOLI.SBQQ__QuoteLine__c = objQLI.Id;
        objOLI.Quantity = 1;
        insert objOLI;
        return objOLI; 
    }
    
    /**@@
    #DESCRIPTION     : Creating test Product records 
    #Paramaters      : String, sObject, Integer
    @@**/
    public static List<Product2> createProduct(String prdName, blng__BillingRule__c objBR, blng__RevenueRecognitionRule__c objRR, blng__TaxRule__c objTR, integer totalPrd){
        List<Product2> prodList = new List<Product2>();
        for(Integer i=0;i<totalPrd;i++){
            Product2 objProd = new Product2();
            objProd.Name = prdName + ' ' + i;
            objProd.Productcode = '12345' + i;
            objProd.IsActive = true;
            objProd.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            objProd.SBQQ__SubscriptionTerm__c = 12;
            // objProd.SBQQ__SubscriptionType__c = 'Evergreen';
            objProd.SBQQ__SubscriptionType__c = 'Renewable';
            objProd.SBQQ__ChargeType__c = 'Recurring';
            objProd.SBQQ__BillingFrequency__c = 'Monthly';
            objProd.SBQQ__BillingType__c = 'Arrears';
            objProd.SBQQ__PricingMethod__c = 'List';
            objProd.blng__BillingRule__c = objBR.Id;
            objProd.blng__RevenueRecognitionRule__c = objRR.Id;
            objProd.blng__TaxRule__c = objTR.Id; 
            prodList.add(objProd);
        }
        insert prodList;
        return prodList; 
    }
    
    /**@@
    #DESCRIPTION     : Creating test SBQQ__Quote__c records 
    #Paramaters      : sObject, sObject, String, Integer
    @@**/
    public static List<SBQQ__Quote__c> createQuote(Account acc, Opportunity objOpp, String strQuoteRecordTypeId, integer totalQuote){
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        for(Integer i=0;i<totalQuote;i++){
            SBQQ__Quote__c objQuote = new SBQQ__Quote__c();
            objQuote.SBQQ__Account__c = acc.id;
            objQuote.SBQQ__PricebookId__c = Test.getStandardPricebookId();
            objQuote.RecordtypeId = strQuoteRecordTypeId; 
            objQuote.SBQQ__Opportunity2__c = objOpp.id;
            objQuote.SBQQ__StartDate__c = system.today();
            objQuote.SBQQ__EndDate__c = system.today().adddays(30);
            objQuote.SBQQ__SubscriptionTerm__c = 12;
            objQuote.SBQQ__Primary__c = True;
            objQuote.SBQQ__Status__c = 'Approved';
            objQuote.SBQQ__ExpirationDate__c = system.today().adddays(30);
            objQuote.SBQQ__BillingFrequency__c = 'Monthly';  
            quoteList.add(objQuote);
        }
        insert quoteList;
        return quoteList; 
    }
    
    /**@@
    #DESCRIPTION     : Creating test PricebookEntry records 
    #Paramaters      : sObject, Decimal
    @@**/
    public static PricebookEntry createPricebookEntry(Product2 objProd, Decimal amount) {
        PricebookEntry objPBEntry = new PricebookEntry();
        objPBEntry.Pricebook2Id = Test.getStandardPricebookId();
        objPBEntry.Product2Id = objProd.Id;
        objPBEntry.UnitPrice = amount;
        objPBEntry.IsActive = true;        
        insert objPBEntry;
        return objPBEntry; 
    }
    
    /**@@
    #DESCRIPTION     : Creating test SBQQ__QuoteLine__c records 
    #Paramaters      : sObject, sObject, sObject, Integer
    @@**/
    public static SBQQ__QuoteLine__c createQuoteLine(SBQQ__Quote__c objQuote, Product2 objProd, PricebookEntry priceEntry, String qliMAIntakeRectypeId, integer totalQLI){
        SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Quote__c = objQuote.id;
        objQLI.SBQQ__Product__c = objProd.Id;
        objQLI.SBQQ__PricebookEntryId__c = priceEntry.Id;
        objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__BillingFrequency__c = 'Monthly';
        objQLI.SBQQ__BillingType__c = 'Advance';
        objQLI.RecordTypeId = qliMAIntakeRectypeId;
        objQLI.Usage_List_Price__c = 100;
        objQLI.SBQQ__SubscriptionTerm__c = 1;
        insert objQLI;
        return objQLI; 
    }
    
    /**@@
    #DESCRIPTION     : Creating test blng__BillingRule__c records 
    #Paramaters      : None
    @@**/
    public static blng__BillingRule__c createBillingRule(){
        blng__BillingRule__c objBR = new blng__BillingRule__c();
        objBR.Name = 'Test';
        objBR.blng__Active__c = TRUE;
        objBR.blng__AmendmentBillCycleDateAlignment__c = 'Do not align amended Order Product';
        objBR.blng__GenerateInvoices__c = 'Yes';
        objBR.blng__InitialBillingTrigger__c = 'Order Product Activation Date ';
        objBR.blng__Notes__c = 'Test';
        objBR.blng__PartialPeriodTreatment__c = 'Separate';
        insert objBR;
       
        return objBR;
    }
    
    /**@@
    #DESCRIPTION     : Creating test blng__RevenueRecognitionRule__c records 
    #Paramaters      : None
    @@**/
    public static blng__RevenueRecognitionRule__c createRevenueRecognitionRule(){
        blng__RevenueRecognitionRule__c objRR = new blng__RevenueRecognitionRule__c();
        objRR.Name = 'Test';
        objRR.blng__Active__c = TRUE;
        objRR.blng__CreateRevenueSchedule__c= 'Yes';
        objRR.blng__Notes__c = 'Test';
        insert objRR;
       
        return objRR;
    }
    
    /**@@
    #DESCRIPTION     : Creating test blng__TaxRule__c records 
    #Paramaters      : None
    @@**/
    public static blng__TaxRule__c createTaxRule(){
        blng__TaxRule__c objTR = new blng__TaxRule__c();
        objTR.Name = 'Test';
        objTR.blng__Active__c = TRUE;
        objTR.blng__TaxableYesNo__c = 'No';
        objTR.blng__Notes__c = 'Test';
        insert objTR;
       
        return objTR;
    }
    
    /**@@
    #DESCRIPTION     : Creating test Attribute_Configuration__c records 
    #Paramaters      : None
    @@**/
    public static Attribute_Configuration__c createAtrConfiguration(String strName, Integer intOrder, String strDataType){
        
        Attribute_Configuration__c objAC = new Attribute_Configuration__c();
        objAC.Name = strName;
        objAC.AttributeOrder__c = intOrder;
        objAC.AttributeType__c = strDataType;
        insert objAC;
        return objAC; 
    }
    
    /**@@
    #DESCRIPTION     : Creating test ProductAttribute__c records 
    #Paramaters      : None
    @@**/
    public static ProductAttribute__c createProductAttribute(Attribute_Configuration__c objAC, Product2 objProd, String strDataType){
        
        ProductAttribute__c objPA = new ProductAttribute__c();
        objPA.AttributeConfiguration__c = objAC.Id;
        objPA.AttributeType__c = strDataType;
        objPA.Product__c = objProd.Id;
        insert objPA;
        return objPA; 
    }
    
    /**@@
    #DESCRIPTION     : Creating test Attribute_Lines__c records 
    #Paramaters      : None
    @@**/
    public static Attribute_Lines__c createAttributeLines(Attribute_Relationship__c objAR, String strAtName, String strDataType, String strValue, String strMSValue){
        
        Attribute_Lines__c objAL = new Attribute_Lines__c();
        objAL.Attribute_Junction__c = objAR.Id;
        objAL.Attribute_Name__c = strAtName;
        objAL.Attribute_Type__c = strDataType;
        objAL.String_Value__c = strValue;
        objAL.Multi_Select_Value__c = strMSValue;
        insert objAL;
        return objAL; 
    }
    
    /**@@
    #DESCRIPTION     : Creating test Usage_State_and_County__c records 
    #Paramaters      : None
    @@**/
    public static List<Usage_State_and_County__c> createUsageStateandCounty(){
        List<Usage_State_and_County__c> uscList = new List<Usage_State_and_County__c>();
        Usage_State_and_County__c objUSC = new Usage_State_and_County__c();
        objUSC.Practice_Area__c = 'SSDI';
        objUSC.Practice_Area_Integration_Id__c = '169071';
        uscList.add(objUSC);
        
        objUSC = new Usage_State_and_County__c();
        objUSC.State_Abbreviation__c = 'North Carolina';
        objUSC.County_Name__c = 'Surry';
        objUSC.County_Integration_Id__c = '83296';
        objUSC.State_Integration_Id__c = '80407';
        uscList.add(objUSC);
        
        insert uscList;
        return uscList; 
    }
    
    /**@@
    #DESCRIPTION     : Creating test Contract record
    #Paramaters      : None
    @@**/
    public static Contract createContract(Account objAcc, Opportunity objOpp){
        Id contractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('M-A Intake Contract').getRecordTypeId();
         
        Contract objContract = new Contract();
        objContract.AccountId = objAcc.Id;
        objContract.SBQQ__Opportunity__c = objOpp.Id;
        objContract.Status = 'Draft';
        objContract.StartDate = Date.today();
        objContract.ContractTerm = 2;
        objContract.RecordtypeId = contractRecordTypeId;
        insert objContract;
        
        objContract.Status = 'Activated';
        Update objContract;
        
        return objContract;
 
    }
    
    /**@@
    #DESCRIPTION     : Creating test SBQQ__Subscription__c record
    #Paramaters      : sObject, sObject, sObject, sObject
    @@**/
    public static SBQQ__Subscription__c createSubscription(Account objAcc, Contract objContract, Product2 objProd, SBQQ__QuoteLine__c objQLI) {
        SBQQ__Subscription__c objSubs = new SBQQ__Subscription__c();
        objSubs.SBQQ__Account__c = objAcc.Id;
        objSubs.SBQQ__Contract__c = objContract.Id; 
        objSubs.SBQQ__Product__c = objProd.Id; 
        objSubs.SBQQ__Quantity__c = 1;
        objSubs.SBQQ__NetPrice__c = 100;
        objSubs.SBQQ__SubscriptionEndDate__c = Date.today().addYears(1);
        objSubs.SBQQ__QuoteLine__c = objQLI.Id;
        insert objSubs;
        return objSubs;
    }
    
    /**@@
    #DESCRIPTION     : Creating test blng__UsageSummary__c record
    #Paramaters      : sObject, sObject, sObject
    @@**/
    public static blng__UsageSummary__c createUsageSummary(Account objAcc, Order objOrder, OrderItem objOI){
        blng__UsageSummary__c objUSummary = new blng__UsageSummary__c();
        objUSummary.blng__MatchingId__c = '1234';
        objUSummary.blng__MatchingAttribute__c = 'Quarterly';
        objUSummary.blng__UnitOfMeasure__c = 'Hours';
        objUSummary.blng__Account__c = objAcc.Id;
        objUSummary.blng__Order__c = objOrder.Id;
        objUSummary.blng__OrderProduct__c = objOI.Id;
        objUSummary.blng__TotalQuantity__c = 1;
        objUSummary.blng__SummaryStartDate__c = objOI.ServiceDate;
        objUSummary.blng__SummaryEndDate__c = objOI.ServiceDate.adddays(1);
        insert objUSummary;
        return objUSummary;
    }
    
    
    
    /**@@
    #DESCRIPTION     : Creating test SBQQ__QuoteLineConsumptionSchedule__c  record
    #Paramaters      : sObject, sObject, sObject
    @@**/
    public static ConsumptionSchedule createConsumptionSchedule(blng__BillingRule__c objBR, blng__RevenueRecognitionRule__c objRR, blng__TaxRule__c objTR){
   
        ConsumptionSchedule objCS = new ConsumptionSchedule();
        objCS.blng__BillingRule__c = objBR.Id;
        objCS.SBQQ__Category__c = 'Rates';
        objCS.blng__RevenueRecognitionRule__c = objRR.Id;
        objCS.blng__TaxRule__c = objTR.Id;
        objCS.IsActive = FALSE;
        objCS.Name = 'Bill';
        objCS.RatingMethod = 'Tier';
        objCS.BillingTerm = 1;
        objCS.BillingTermUnit = 'Month';
        objCS.UnitOfMeasure = 'Cases';
        objCS.MatchingAttribute = 'Hours';
        objCS.Type = 'Range';
        insert objCS;
        return objCS;
    }
    
    /**@@
    #DESCRIPTION     : Creating test SBQQ__QuoteLineConsumptionSchedule__c  record
    #Paramaters      : sObject, sObject
    @@**/
    public static ProductConsumptionSchedule creatProductConsumptionSchedule(ConsumptionSchedule objCS, Product2 objProd){
   
        ProductConsumptionSchedule objPCS = new ProductConsumptionSchedule();
        objPCS.ConsumptionScheduleId = objCS.Id;    
        objPCS.ProductId = objProd.Id;
        insert objPCS;
        return objPCS;
    }
    
    /**@@
    #DESCRIPTION     : Creating test ConsumptionRate record
    #Paramaters      : sObject, sObject
    @@**/
    public static ConsumptionRate creatConsumptionRate(ConsumptionSchedule objCS){
   
        ConsumptionRate objCR = new ConsumptionRate();
        objCR.ProcessingOrder = 10;
        objCR.LowerBound = 1;
        objCR.UpperBound = 20;
        objCR.Price = 0;
        objCR.PricingMethod = 'PerUnit';
        objCR.ConsumptionScheduleId = objCS.Id;
        insert objCR;
        return objCR;
    }
    
    
    /**@@
    #DESCRIPTION     : Creating test SBQQ__QuoteLineConsumptionSchedule__c  record
    #Paramaters      : sObject, sObject, sObject
    @@**/
    public static SBQQ__QuoteLineConsumptionSchedule__c createQLIConsumptionSchedule(ConsumptionSchedule objCS, SBQQ__QuoteLine__c objQLI){
   
        SBQQ__QuoteLineConsumptionSchedule__c objQLICS = new SBQQ__QuoteLineConsumptionSchedule__c();
        objQLICS.SBQQ__ConsumptionSchedule__c = objCS.Id;    
        objQLICS.SBQQ__QuoteLine__c = objQLI.Id;
        objQLICS.SBQQ__BillingTermUnit__c = 'Month';
        objQLICS.SBQQ__BillingTerm__c = 1;
        objQLICS.SBQQ__Category__c = 'Rates';
        objQLICS.SBQQ__RatingMethod__c = 'Tier';
        objQLICS.SBQQ__Type__c = 'Range';
        insert objQLICS;
        return objQLICS;
    }
}